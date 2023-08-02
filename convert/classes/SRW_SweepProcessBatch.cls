/* @Author Michal Szewczyk
* @description Batch class processing SalesData record to generate csv file
*/  

global class SRW_SweepProcessBatch implements Database.Batchable<sObject>,Database.Stateful {
	
	String query;
	global final SRW_DataMonths__c dataMonthInContext;
	global String csvFileBody;
	global Set<Id> dataMonthToUpdate;
	global User contextUser;
	global Integer recordCounter;
    global Boolean isSweep;
    global Map<String,SRW_Sales_Data_gne__c> finalReSweepScope;
	global SRW_SweepProcessBatch(SRW_DataMonths__c param1,Boolean param2) {

			dataMonthInContext = param1;
			isSweep = param2;
			recordCounter = 0;
			dataMonthToUpdate = new Set<Id>();
			finalReSweepScope = new Map<String,SRW_Sales_Data_gne__c>();
			contextUser = [Select Id,Name,Email from User where Id =:UserInfo.getUserId()];
			List<String> headers = new List<String> {'Distributor Name', 'Distributor Party ID', 'Distributor COE ID', 'Distributor Branch ID', 'Distributor Fax', 'Transaction Date', 'DEA Number', 'Physician Last Name', 'Physician First Name', 'Organization Name', 'Address1', 'Address2', 'City', 'State', 'Zip', 'Location Identifier', 'Product Name', 'Product NDC','GNE List No.','Sale Quantity', 'Comp Sales Flag'}; 
			//Create file header ( columns)
		    csvFileBody = ''; 
 
		    for(String colName : headers)
		    {
		        csvFileBody +=  colName + ',';
		    } 
		    csvFileBody += '\n';
	}
	/** @date 28/11/2014
    * @Author Michal Szewczyk
    * @description initialise scope of batch
    */  
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		query = 'Select id,'+
					'Trading_Partner_gne__r.Trading_Partner_Name_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Unique_Identifier_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,'+
					'Prescriber_Organization_Location_gne__r.City_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Identifier_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Location_Identifier_gne__c,'+
					'Prescriber_Organization_Location_gne__r.State_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Type_of_Identifier_gne__c,'+
					'Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,'+
					'Trading_Partner_gne__r.Type_of_Identifier_gne__c,'+
					'Trading_Partner_gne__r.Identifier_gne__c,'+
					'Trading_Partner_gne__r.Trading_Partner_Fax_gne__c,'+
					'Product_gne__r.Name,'+
					'Product_gne__r.NDC_Number_gne__c,'+
					'Quantity_gne__c,'+
					'TP_Data_Month_gne__r.Data_Month_Status_gne__c,'+
					'TP_Data_Month_gne__r.SRW_Data_Month_gne__c,'+
					'TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,'+
					'TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Sweep_Default_Date_gne__c,'+
					'TP_Data_Month_gne__r.Trading_Partner_gne__c,'+
					'TP_Data_Month_gne__c, '+
					'Sweep_Data_Month_gne__c, '+
					'Set_Sequence_Number_gne__c '+
					'From SRW_Sales_Data_gne__c ';

		if(isSweep) {

			query += 'where TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Sweep_Default_Date_gne__c <= '+ String.valueOf(dataMonthInContext.Sweep_Default_Date_gne__c) +
			' and TP_Data_Month_gne__r.Data_Month_Status_gne__c = \'Submitted - Sales\'' +
			' Order By TP_Data_Month_gne__c,Trading_Partner_gne__c,Prescriber_Organization_Location_gne__c';
		} else {

			/*query += 'where Sweep_Data_Month_gne__c = \''+ dataMonthInContext.Id + '\''+
			' and (TP_Data_Month_gne__r.Data_Month_Status_gne__c = \'Resubmitted\' OR TP_Data_Month_gne__r.Data_Month_Status_gne__c = \'Sweep\'' +
			' Order By TP_Data_Month_gne__c,Trading_Partner_gne__c,Prescriber_Organization_Location_gne__c,Set_Sequence_Number_gne__c';*/
			query += 'where Sweep_Data_Month_gne__c = \''+ dataMonthInContext.Id + '\''+
			' Order By TP_Data_Month_gne__c,Trading_Partner_gne__c,Prescriber_Organization_Location_gne__c,Set_Sequence_Number_gne__c';
		}
		return Database.getQueryLocator(query);
	}
	/** @date 28/11/2014
    * @Author Michal Szewczyk
    * @description batch main processing method
    */  
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		List<SRW_Sales_Data_gne__c> saleDataToUpdate = new List<SRW_Sales_Data_gne__c>();
   		String recordKey = '';
   		for(SRW_Sales_Data_gne__c temp : (List<SRW_Sales_Data_gne__c>) scope){

   			if(isSweep) {
   				// logic for Sweep
	   			temp.Sweep_Data_Month_gne__c = dataMonthInContext.Id;
	   			csvFileBody += createSweepCvsRow(temp);

	   			// add sweep data month in which SD was in scope.
	   			saleDataToUpdate.add(temp);

   			} else {
   				// logic for ReSweep
   				recordKey = '' + temp.Trading_Partner_gne__c + temp.Prescriber_Organization_Location_gne__c + temp.Product_gne__c + temp.TP_Data_Month_gne__c ;
   				system.debug('MICK_LOKO recordKey: ' +recordKey);
   				if(finalReSweepScope.containsKey(recordKey)) {
   					SRW_Sales_Data_gne__c addedRec = finalReSweepScope.get(recordKey);
   					system.debug('MICK_LOKO addedRec: ' + addedRec);
   					if(addedRec.Set_Sequence_Number_gne__c < temp.Set_Sequence_Number_gne__c)
   						finalReSweepScope.remove(recordKey);
   						finalReSweepScope.put(recordKey,temp);
				} else {

					finalReSweepScope.put(recordKey,temp);
				}
   			}
   			
   			//build TP DataMonth map to change status after processing 
   			dataMonthToUpdate.add(temp.TP_Data_Month_gne__c);
   			recordCounter++;
   		}

   		try {
   			 
   			if(isSweep) {
   			 	update saleDataToUpdate;
   			}
   		}
   		catch (Exception e) {


   		}
	
	}
	/** @date 28/11/2014
    * @Author Michal Szewczyk
    * @description method triggered as a last in batch doing updates and inserting records 
    */  
	global void finish(Database.BatchableContext BC) {

		Boolean processedOK = false;
		String  attachmentID ='';
		String htmlBodyContent = '';
		Messaging.EmailFileAttachment cvsFile;
		Savepoint sp = Database.setSavepoint();
			
		system.debug('MICK_LOKO: recordCounter:  ' + recordCounter);
		
			if(!isSweep) {
				// for ReSweep Only

				for(SRW_Sales_Data_gne__c temp : finalReSweepScope.values()) {

					csvFileBody += createSweepCvsRow(temp);
				}
			}


			try {

				// insert file as a attachment 
				Blob csvBlob = Blob.valueOf(csvFileBody);
				Attachment AttachmentObj;
				String currentDMName = '';
				currentDMName += dataMonthInContext.Data_Year_gne__c;
				if(dataMonthInContext.Data_Month_Number_gne__c < 10)
					currentDMName += '0' + dataMonthInContext.Data_Month_Number_gne__c.format();
				else
					currentDMName +=  dataMonthInContext.Data_Month_Number_gne__c.format();


				if(!isSweep) {
				// for ReSweep Only
				SRW_ReSweep_File__c reSweepFile = new SRW_ReSweep_File__c();
					reSweepFile.Data_Month_gne__c = dataMonthInContext.Id;
					reSweepFile.ReSweep_Date_gne__c = system.now();
				insert reSweepFile;

		        	AttachmentObj = new Attachment(Body = csvBlob,Name = 'CPI_SRW_MT_SHIP_GNE_N_' + currentDMName + '_TS' + System.now().format('yyyyMMddhhmmss') + '.CSV',
                      parentId = reSweepFile.Id);

		    	} else {
			        AttachmentObj = new Attachment(Body = csvBlob,Name = 'CPI_SRW_MT_SHIP_GNE_N_' + currentDMName + '_TS' + System.now().format('yyyyMMddhhmmss') + '.CSV',
                      parentId = dataMonthInContext.Id);

		    	}
		        
		        insert AttachmentObj;

		        attachmentID = AttachmentObj.Id;

		        if(isSweep) {
	        		// Create the email attachment
				    cvsFile = new Messaging.EmailFileAttachment();
				    cvsFile.setFileName('CPI_SRW_MT_SHIP_GNE_N_' + currentDMName + '_TS' + System.now().format('yyyyMMddhhmmss') + '.CSV');
				    cvsFile.setBody(csvBlob);
				}
		        //change TP DataMonth records to Sweep or ReSweep
		        // Take all that are on Submit No Sales Data
		        for(SRW_TP_Data_Months__c tmp : [Select Id from SRW_TP_Data_Months__c  where Data_Month_Status_gne__c = 'Submitted - No Sales Reported' and SRW_Data_Month_gne__r.Name <= :dataMonthInContext.Name]){

		        	dataMonthToUpdate.add(tmp.Id);
		        }

	    		List<SRW_TP_Data_Months__c> dmTPforUpdate = [Select Id,Data_Month_Status_gne__c from SRW_TP_Data_Months__c where id in :dataMonthToUpdate];
				for(SRW_TP_Data_Months__c temp : dmTPforUpdate){
					if(isSweep)
						temp.Data_Month_Status_gne__c = 'Sweep';
					else 
						if(temp.Data_Month_Status_gne__c != 'Reopen')
							temp.Data_Month_Status_gne__c = 'ReSweep';
				}
		        update dmTPforUpdate;

		        if(isSweep) {
			        dataMonthInContext.Real_Sweep_Date_gne__c = system.now();
		        	dataMonthInContext.Sweep_Status_gne__c = 'Sweep';
		        } else {
					dataMonthInContext.Sweep_Status_gne__c = 'ReSweep';
		        }

		        update dataMonthInContext;

		        List<SRW_DataMonths__c> currentDM = [Select Id,Last_Sweep_Occurrence_Date_gne__c from SRW_DataMonths__c where Sweep_Status_gne__c = 'Current' limit 1];
		        if(!currentDM.isEmpty()) {

		        		currentDM[0].Last_Sweep_Occurrence_Date_gne__c = system.now();

		        	update currentDM;
		        }


		        processedOK = true;
			}
			catch (Exception e) {

				Database.rollback(sp);
				processedOK = false;
				system.debug('MICK_LOKO: recordCounter:  ' + recordCounter);
				system.debug('MICK_LOKO:Something went wrong :  ' + e);
			}

		htmlBodyContent += '<html>'; 
		if(processedOK &&  recordCounter > 0 ) {
			if(isSweep) {
				htmlBodyContent += 'Batch Sweep processing has finished.';
							} else { 
				
				String fileURL = URL.getSalesforceBaseUrl().toExternalForm();
				fileURL += '/servlet/servlet.FileDownload?file=' + attachmentID;
				htmlBodyContent += 'Batch ReSweep processing has finished.<br>Click on the link to download csv file : ';
				htmlBodyContent += '<a href="'+ fileURL +'" target="_blank" title="Download Attachment">Download ReSweep File</a>';	
			}
		}
		else if (recordCounter ==0){
				
		        dataMonthInContext.Real_Sweep_Date_gne__c = system.now();
		        dataMonthInContext.Sweep_Status_gne__c = 'Sweep';
		        update dataMonthInContext;

			if(isSweep)
				htmlBodyContent += 'Batch Sweep processing has finished.<br> No data were in scope.';
			else 
				htmlBodyContent += 'Batch ReSweep processing has finished.<br> No data were in scope.';
		} else if(!processedOK) {

			if(isSweep)
				htmlBodyContent += 'Batch Sweep processing has finished with errors.<br>Please contact support for further investigation.';
			else
				htmlBodyContent += 'Batch ReSweep processing has finished with errors.<br>Please contact support for further investigation.';
		}

		htmlBodyContent += '</html>';

		// Send email with status of Sweep 
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      	String foimDLAddress = SRW_Utils.getSettingByName('FOIM DL');
		email.setToAddresses(new String[] {foimDLAddress});
		email.setReplyTo(foimDLAddress);
		if(isSweep) {
			email.setSenderDisplayName('Sweep Batch Process');
			email.setSubject('Sweep Batch Process Completed');
			email.setFileAttachments(new Messaging.EmailFileAttachment[] {cvsFile});
		} else {
			email.setSenderDisplayName('ReSweep Batch Process');
			email.setSubject('ReSweep Batch Process Completed');
		}
		email.setHtmlBody(htmlBodyContent);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

		// email to ESB team 
		// get settings for Sweep
		if(processedOK && isSweep) {

			String emailAddress = SRW_Utils.getSettingByName('SweepEmailAddress');
			Messaging.SingleEmailMessage emailESB = new Messaging.SingleEmailMessage();
	      
				emailESB.setToAddresses(new String[] {emailAddress});
				emailESB.setReplyTo(emailAddress);
				emailESB.setSenderDisplayName('gST Monthly Sweep file');
				emailESB.setSubject('gST Monthly Sweep file -' + datetime.now().format('dd MMMM YYYY'));
				emailESB.setFileAttachments(new Messaging.EmailFileAttachment[] {cvsFile});
				emailESB.setHtmlBody('<html>gST Monthly Sweep file -' + datetime.now().format('dd MMMM YYYY') + '</html>');
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailESB });
		}

		if(isSweep)
			upsert new SRW_Settings__c( Name = 'Sweep Status',Value_gne__c = '') Name;
		else 
			upsert new SRW_Settings__c( Name = 'ReSweep Status',Value_gne__c = '') Name;
	}
	/** @date 28/11/2014
    * @Author Michal Szewczyk
    * @description method generate row in csv file based on source record 
    */  
    private String createSweepCvsRow (SRW_Sales_Data_gne__c sourceRec) {

    	String csvRow = '';
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Trading_Partner_gne__r.Trading_Partner_Name_gne__c)) + '\",'; //Distributor Name
	        csvRow +=  'null,';  //Distributor Party ID 
	        csvRow +=  'ignore' + ',';  // Distributor COE ID
	        csvRow +=   valueOrBlank(String.valueOf(sourceRec.Trading_Partner_gne__r.Identifier_gne__c)) + ',';  // Distributor Branch ID
	        csvRow +=   valueOrBlank(String.valueOf(sourceRec.Trading_Partner_gne__r.Trading_Partner_Fax_gne__c)) + ',';  // Distributor Fax
	        csvRow +=   valueOrBlank(String.valueOf(transactionDateFormat(sourceRec.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Sweep_Default_Date_gne__c))) + ',';  // Transaction Date
	        csvRow +=   valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Identifier_gne__c)) + ',';  // DEA Number
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c)) + '\",';  // Physician Last Name
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c)) + '\",';  // Physician First Name
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c)) + '\",';  // Organization Name
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c)) + '\",';  // Address1
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Street_Address_2_gne__c)) + '\",';  // Address2
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.City_gne__c))  + '\",';   // City
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.State_gne__c))  + '\",';  // State
	        csvRow +=  valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Zip_Code_gne__c)) + ',';  // Zip
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Prescriber_Organization_Location_gne__r.Location_Identifier_gne__c))  + '\",';  // Location Identifier
	        csvRow +=  '\"' + valueOrBlank(String.valueOf(sourceRec.Product_gne__r.Name)) + '\",';  // Product Name
	        csvRow +=  valueOrBlank(String.valueOf(sourceRec.Product_gne__r.NDC_Number_gne__c))+ ',';  // Product NDC
	        csvRow +=  '\"' + '12345' + '\",';  // GNE List No.
	        csvRow +=  valueOrBlank(String.valueOf(sourceRec.Quantity_gne__c)) + ',';  // Sale Quantity
	        csvRow +=  'N' + ',';  // Comp Sales Flag
	        csvRow +=  '\n';
	    return csvRow;
	}	

	private String valueOrBlank(String val) {

		if(val == null)
			return '';
		else
			return val;
	}

	private String transactionDateFormat(Date val) {
		
		String retVal ='';
		
		 if(val != null) {
		 	Date startMonthDate = val.addMonths(-1).toStartOfMonth();
		 	Datetime dt = DateTime.newInstance(startMonthDate, time.newInstance(0, 0, 0, 0));
		 	retVal = dt.format('MM/dd/yyyy');
		}
		return retVal;
	}

}