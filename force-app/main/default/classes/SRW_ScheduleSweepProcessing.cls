global class SRW_ScheduleSweepProcessing implements Schedulable {
	
  private Date cToday;

  global void execute(SchedulableContext sc) {

    cToday = system.today();

		List<SRW_DataMonths__c> contexDataMonth = [Select Id,Sweep_Default_Date_gne__c,Sweep_Custom_Date_gne__c,Name,Data_Year_gne__c,Data_Month_Number_gne__c
                                               from SRW_DataMonths__c 
                                               where ((Sweep_Default_Date_gne__c =: cToday AND Sweep_Custom_Date_gne__c = NULL) OR (Sweep_Custom_Date_gne__c =: cToday))
                                               AND (Sweep_Status_gne__c = 'Active' OR Sweep_Status_gne__c = 'Current') limit 1];
    //check if today is 2 days before sweep
    cToday = cToday.addDays(2);
    List<SRW_DataMonths__c> twoDaysBeforeSweep = [Select Id,Sweep_Default_Date_gne__c,Sweep_Custom_Date_gne__c 
                                               from SRW_DataMonths__c 
                                               where ((Sweep_Default_Date_gne__c =: cToday AND Sweep_Custom_Date_gne__c = NULL) OR (Sweep_Custom_Date_gne__c =: cToday))
                                               AND (Sweep_Status_gne__c = 'Active' OR Sweep_Status_gne__c = 'Current') limit 1];
    cToday = cToday.addDays(-2);
		// check date and if it is last day of month create new Data Month
    // and ssign product to TP for new one
		Date lastDayinMonth = cToday.addMonths(1).toStartofMonth().addDays(-1) ;
    system.debug('MICK_LOKO lastDayinMonth : ' + lastDayinMonth);
		if (lastDayinMonth.isSameDay(cToday)) {
			 if(contexDataMonth.isEmpty())
                addNextDataMonth(false);
        else
                addNextDataMonth(true);
		} else if (cToday.isSameDay(cToday.toStartOfWeek().addDays(4))){
      //check is today is thursday
      sendWeekReports();
    } else if (!twoDaysBeforeSweep.isEmpty()){
      sendReportForBackFillExceptions();
    }
		//Check that batch should trigger if yes perform Sweep logic
		if(!contexDataMonth.isEmpty()) {
      
      if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 10){
            SRW_SweepProcessBatch batchJob = new SRW_SweepProcessBatch(contexDataMonth[0],true);
            Database.executeBatch(batchJob); 
        }else {

             //send email to developer to inform about batch limit
              List<String> emailAddressList = new List<String>();
              emailAddressList.add('michal.szewczyk@contractors.roche.com');
              List<Messaging.SingleEmailMessage> mailsList = new List<Messaging.SingleEmailMessage>();
              Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
              mail.setToAddresses(emailAddressList);
              mail.setSubject('gST Sweep / Batch limit exceeded');
              mail.setHtmlBody('Batch will be schedule one more time. Time : ' + system.now());
              mailsList.add(mail);
              List<Messaging.SendEmailResult> emailResultList = Messaging.sendEmail(mailsList);

              String hour = String.valueOf(Datetime.now().hour());
              String min = String.valueOf(Datetime.now().minute()+1); 
              String ss = String.valueOf(Datetime.now().second());

              //parse to cron expression
              String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

              SRW_EmergencySweepScheduleJob s = new SRW_EmergencySweepScheduleJob(); 
              System.schedule('gST Daily job re-run (Sweep batch only) ' + String.valueOf(Datetime.now()), nextFireTime, s);
        }   
		}

	}

		/** @date 27/11/2014
    * @Author Michal Szewczyk
    * @description method generate current DataMonth record 
    */
    private void addNextDataMonth(Boolean isBatch){
        system.debug('MICK_LOKO: addNextDataMonth isBatch :' + isBatch);
        List<SRW_DataMonths__c> allDataMonths = [Select Id,
                                                        Sweep_Status_gne__c
                                                from SRW_DataMonths__c 
                                                where Sweep_Status_gne__c ='Current' Limit 1];
        SRW_DataMonths__c lastSweepOccurs = [Select Real_Sweep_Date_gne__c from SRW_DataMonths__c where Sweep_Status_gne__c = 'Sweep' ORDER BY Real_Sweep_Date_gne__c DESC limit 1];
         // if list is empty means that sweep occurs before last day in month take last record with'Sweep' status then
         if(allDataMonths.isEmpty()) {

            allDataMonths = [Select Id,
                                    Sweep_Status_gne__c
                            from SRW_DataMonths__c 
                            where Sweep_Status_gne__c ='Sweep' ORDER BY Sweep_Default_Date_gne__c DESC Limit 1];

         }
         // Change status only if record was not sweept
        for(SRW_DataMonths__c tmp : allDataMonths) {
        	 if(tmp.Sweep_Status_gne__c == 'Current') {
              tmp.Sweep_Status_gne__c = 'Active';
           }
        }

        SRW_DataMonths__c newDataMonth = new SRW_DataMonths__c();
        
        Date nextDate = cToday;

        newDataMonth.Data_Year_gne__c = String.valueOf(nextDate.year());
        newDataMonth.Data_Month_gne__c = nrToMonthName.get(nextDate.month());
        newDataMonth.Sweep_Default_Date_gne__c = nextDate.addMonths(2).toStartofMonth().addDays(-1);
        newDataMonth.Sweep_Status_gne__c = 'Current';
        if(isBatch)
          newDataMonth.Last_Sweep_Occurrence_Date_gne__c = system.now();
        else 
          newDataMonth.Last_Sweep_Occurrence_Date_gne__c = lastSweepOccurs.Real_Sweep_Date_gne__c;
        
        allDataMonths.add(newDataMonth);
        try {

           List<Database.UpsertResult> upsResults = Database.upsert(allDataMonths);
           assignDataMonthToTP(upsResults);
        }   
        catch(Exception e) {

           system.debug('MICK_LOKO error:' + e);
        }
    }
    /** @date 27/11/2014
    * @Author Michal Szewczyk
    * @description method generate current DataMonth record 
    */  
     private void assignDataMonthToTP(List<Database.UpsertResult> upsRst) {
        
        List<SRW_TP_Data_Months__c> dmTAssignment = new List<SRW_TP_Data_Months__c>();
        Id newDataMonthId = null;
        
        for(Database.UpsertResult tempRec : upsRst) {

            if(tempRec.isSuccess() && tempRec.isCreated()) {
               newDataMonthId= tempRec.getId();

              for(SRW_Trading_Partner_Profile__c temp : [Select Id ,Contract_Effective_Date_gne__c,(select id from SRW_Security_Community_Data__r where Status_gne__c IN('Active','Locked')) from SRW_Trading_Partner_Profile__c]) {

                  if(temp.SRW_Security_Community_Data__r.size()>0){

                      if(temp.Contract_Effective_Date_gne__c == null)
                        dmTAssignment.add(new SRW_TP_Data_Months__c(Trading_Partner_gne__c = temp.Id,SRW_Data_Month_gne__c = newDataMonthId , Data_Month_Status_gne__c = 'Open'));
                      else if(temp.Contract_Effective_Date_gne__c <= system.today())
                        dmTAssignment.add(new SRW_TP_Data_Months__c(Trading_Partner_gne__c = temp.Id,SRW_Data_Month_gne__c = newDataMonthId , Data_Month_Status_gne__c = 'Open'));
                  }
              }

              try {
                    insert dmTAssignment;
              }   
              catch(Exception e) {
                system.debug('MICK_LOKO error:' + e);

              }

           }
        }
     }


    /** @date 27/11/2014
    * @Author Michal Szewczyk
    * @description map storing number to month name
    */  
    private map<Integer,String> nrToMonthName = new map<Integer,String> { 1 => 'January',
                                                                          2 => 'February',
                                                                          3 => 'March',
                                                                          4 => 'April',
                                                                          5 => 'May',
                                                                          6 => 'June',
                                                                          7 => 'July',
                                                                          8 => 'August',
                                                                          9 => 'September',
                                                                          10 => 'October',
                                                                          11 => 'November',
                                                                          12 => 'December'};

    private void sendWeekReports(){
      sendReportForTPExceptions();
      sendReportForPOExceptions();
      sendReportForHistoricalMonthsUpedates();
    }


    private void sendReportForTPExceptions(){
      //return all exceptions from last week that tp identifier is not in mdm
      List<SRW_TP_Exception__c> tpExceptions = [SELECT id, 
                                                       Trading_Partner_gne__r.Trading_Partner_Name_gne__c, 
                                                       Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,  
                                                       Trading_Partner_gne__r.Trading_Partner_Address_2_gne__c,
                                                       Trading_Partner_gne__r.State_gne__c,
                                                       Trading_Partner_gne__r.City_gne__c,
                                                       Trading_Partner_gne__r.Type_of_Identifier_gne__c,
                                                       Trading_Partner_gne__r.Identifier_gne__c,
                                                       Trading_Partner_gne__r.Contact_First_Name_gne__c,
                                                       Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                                                       Trading_Partner_gne__r.Trading_Partner_Phone_gne__c
                                                FROM SRW_TP_Exception__c WHERE CreatedDate >= :system.today()-7];

      String htmlBody = '<h2>TRADING PARTNER IDENTIFIER NOT MATCH - WEEK REPORT</h2><table><thead><tr><th>Trading Partner Name</th>' +
                                                                                                      '<th>Street Address 1</th>' +
                                                                                                      '<th>Street Address 2</th>' +
                                                                                                      '<th>City</th>' +
                                                                                                      '<th>State</th>' +
                                                                                                      '<th>Type Of Identifier</th>' +
                                                                                                      '<th>Identifier</th>' +
                                                                                                      '<th>Contact First Name</th>' +
                                                                                                      '<th>Contact Last Name</th>' +
                                                                                                      '<th>Contact Phone</th></tr></thead><tbody>';
                            for(SRW_TP_Exception__c e : tpExceptions){
                              htmlBody += '<tr>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Trading_Partner_Name_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Trading_Partner_Address_2_gne__c  + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.City_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.State_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Type_of_Identifier_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Identifier_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Contact_First_Name_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Contact_Last_Name_gne__c + '</td>';
                                htmlBody += '<td>' + e.Trading_Partner_gne__r.Trading_Partner_Phone_gne__c + '</td></tr>';}
               htmlBody += '</tbody></table>';
      String subject = 'TRADING PARTNER IDENTIFIER NOT MATCH - WEEK REPORT';
      sendEmail(subject, htmlBody);
    } 

    private void sendReportForPOExceptions(){
      //return all exceptions from last week that customer identifier is not in mdm
      List<SRW_PO_Exception__c> poExceptions = [Select id,
                                                       Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.id,
                                                       Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Type_of_Identifier_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Identifier_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Location_Identifier_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.City_gne__c,
                                                       Prscr_Or_Org_Location_gne__r.State_gne__c
                                                FROM SRW_PO_Exception__c WHERE CreatedDate >= :system.today()-7];

      String htmlBody = '<h2>CUSTOMER IDENTIFIER NOT MATCH - WEEK REPORT</h2><table><thead><tr><th>Trading Partner Name</th>' +
                                                                                               '<th>Trading Partner Id</th>' + 
                                                                                               '<th>Type of Identifier</th>' +
                                                                                               '<th>Identifier</th>' +
                                                                                               '<th>Customer Name</th>' +
                                                                                               '<th>Customer Address</th>' +
                                                                                               '<th>Customer City</th>' +
                                                                                               '<th>Custoemr State</th>' +
                                                                                               '<th>Location Identifer</th>' +
                                                                                               '</tr></thead><tbody>';
                          for(SRW_PO_Exception__c e : poExceptions){
                            htmlBody += '<tr>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c + '</td>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.id + '</td>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.Type_of_Identifier_gne__c + '</td>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.Identifier_gne__c + '</td>';
                              htmlBody += 'Prescriber'.equals(e.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? '<td>' + e.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + e.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c + '</td>' : '<td>' + e.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c + '</td>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c + '</td>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.City_gne__c + '</td>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.State_gne__c + '</td>';
                              htmlBody += '<td>' + e.Prscr_Or_Org_Location_gne__r.Location_Identifier_gne__c + '</td>';
                            htmlBody += '</tr>';
                          }
      htmlBody += '</tbody></table>';
      String subject = 'CUSTOMER IDENTIFIER NOT MATCH - WEEK REPORT';
      sendEmail(subject, htmlBody);
    }

    private void sendReportForHistoricalMonthsUpedates(){
      //return all historical week updates from  
      List<SRW_Sales_Data_Exception__c> exceptions = [SELECT id,
                                                             SRW_Trading_Partner_Profile_gne__r.id,
                                                             SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c,
                                                             SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.City_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.State_gne__c,
                                                             Quantity_gne__c,
                                                             Historical_Sales_Data_Update_gne__c,
                                                             Original_Submission_Time_Stamp_gne__c,
                                                             Product_gne__r.Name,
                                                             Product_gne__r.NDC_Number_gne__c
                                                      FROM SRW_Sales_Data_Exception__c WHERE CreatedDate >= :system.today()-7 AND Historical_Sales_Data_Update_gne__c = 'Yes']; //where to change 

      String htmlBody = '<h2>HISTORIC DATA MONTH UPDATE EXCEPTION - WEEK REPORT</h2><table></table><thead><tr><th>Trading Partner Name</th>' +
                                                                                                             '<th>Data Month</th>' +
                                                                                                             '<th>Customer Name</th>' +
                                                                                                             '<th>Customer Address</th>' +
                                                                                                             '<th>Custoemr City</th>' +
                                                                                                             '<th>Customer State</th>' +
                                                                                                             '<th>Product Name</th>' +
                                                                                                             '<th>Product NDC</th>' +
                                                                                                             '<th>Quantity</th>' +
                                                                                                             '<th>Submission Time Stamp</th>' +
                                                                                                             '</tr></thead><tbody>';
                        for(SRW_Sales_Data_Exception__c e : exceptions){
                          htmlBody += '<tr>';
                            htmlBody += '<td>' + e.SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c + '</td>';
                            htmlBody += 'Prescriber'.equals(e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c + '</td>' : '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.City_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.State_gne__c + '</td>';
                            htmlBody += '<td>' + e.Product_gne__r.Name + '</td>';
                            htmlBody += '<td>' + e.Product_gne__r.NDC_Number_gne__c + '</td>';
                            htmlBody += '<td>' + e.Quantity_gne__c + '</td>';
                            htmlBody += '<td>' + e.Original_Submission_Time_Stamp_gne__c + '</td>';
                          htmlBody += '</tr>';
                        }
      htmlBody += '</tbody></table>';
      String subject = 'HISTORIC DATA MONTH UPDATE EXCEPTION - WEEK REPORT';
      sendEmail(subject, htmlBody);
    }

    private void sendReportForBackFillExceptions(){
      //return all sales data exceptions from last month for backfill entry (2 days befor sweep)
      List<SRW_Sales_Data_Exception__c> exceptions = [SELECT id,
                                                             SRW_Trading_Partner_Profile_gne__r.id,
                                                             SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c,
                                                             SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.City_gne__c,
                                                             SRW_Prescriber_Organization_Location_gne__r.State_gne__c,
                                                             Quantity_gne__c,
                                                             Historical_Sales_Data_Update_gne__c,
                                                             Original_Submission_Time_Stamp_gne__c,
                                                             Product_gne__r.Name,
                                                             Product_gne__r.NDC_Number_gne__c
                                                      FROM SRW_Sales_Data_Exception__c WHERE CreatedDate >= :system.today()-30 AND Historical_Sales_Data_Update_gne__c = 'No']; //where to change 

      String htmlBody = '<h2>BACK FILL EXCEPTION - MONTH REPORT</h2><table></table><thead><tr><th>Trading Partner Name</th>' +
                                                                                              '<th>Data Month</th>' +
                                                                                              '<th>Customer Name</th>' +
                                                                                              '<th>Customer Address</th>' +
                                                                                              '<th>Custoemr City</th>' +
                                                                                              '<th>Custoemr State</th>' +
                                                                                              '<th>Product Name</th>' +
                                                                                              '<th>Product NDC</th>' +
                                                                                              '<th>Quantity reported</th>' +
                                                                                              '<th>Submission Time Stamp</th>' +
                                                                                              '</tr></thead><tbody>';
                        for(SRW_Sales_Data_Exception__c e : exceptions){
                          htmlBody += '<tr>';
                            htmlBody += '<td>' + e.SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c + '</td>';
                            htmlBody += 'Prescriber'.equals(e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c + '</td>' : '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.City_gne__c + '</td>';
                            htmlBody += '<td>' + e.SRW_Prescriber_Organization_Location_gne__r.State_gne__c + '</td>';
                            htmlBody += '<td>' + e.Product_gne__r.Name + '</td>';
                            htmlBody += '<td>' + e.Product_gne__r.NDC_Number_gne__c + '</td>';
                            htmlBody += '<td>' + e.Quantity_gne__c + '</td>';
                            htmlBody += '<td>' + e.Original_Submission_Time_Stamp_gne__c + '</td>';
                          htmlBody += '</tr>';
                        }
      htmlBody += '</tbody></table>';
      String subject = 'BACK FILL EXCEPTION - MONTH REPORT';  
      sendEmail(subject, htmlBody);                                              
    }

    private void sendEmail(String subject, String htmlBody){
      Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();      
      List<String> addresses = new List<String>();
      //!change address below
      sem.setHtmlBody(htmlBody);
      sem.setSubject(subject);
      //!change email below
      String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
      OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
      addresses.add(owea[0].Address);
      sem.setToAddresses(addresses);
      sem.setOrgWideEmailAddressId(owea[0].id);
      Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
    }
}