public class gFRS_Ltng_ApplicationTriggerHandler {
    
    public void updateRFIStaus(List<gFRS_Ltng_Application__c> appnewlist ,map<id,gFRS_Ltng_Application__c> appoldMap)
    {  
        
        //system.debug('list of new values'+appnewlist);
        //system.debug('list of old values '+appoldMap.values() );
        if(appoldMap!= null){                                                /* added code as part of test class coverage - NullPointerException **Yodhini  */
            for(gFRS_Ltng_Application__c appObj : appnewlist)
            {
                if(appObj.Status__c == 'Compliance' && appObj.Sub_Status__c =='RFI Received'){
                    appObj.RFI_StatusCheck__c = true;
                }
                else if(appoldMap!=null){
                    gFRS_Ltng_Application__c oldApp = appoldMap.get(appObj.ID);
                    
                    if(appObj.Status__c == 'RFI' && oldApp.Status__c=='Compliance' && oldApp.Sub_Status__c == 'RFI Received'){
                        appObj.RFI_StatusCheck__c = true;
                    }
                    //appObj.RFI_StatusCheck__c = false;
                }else{
                    appObj.RFI_StatusCheck__c = false;
                }
            }
        }
    }
    

    /*
    * Evaluates if requests needs to be considered for 33% calculations - NonCopay
    * Not invoked by trigger - created to be used in addApprAmountToOrg() method
    * GFRS Dev Team - Sasidhar - 09/21/2021 
    */
    public Boolean checkRequestEligibilty(gFRS_Ltng_Application__c newApp ,gFRS_Ltng_Application__c oldApp){
        Date dateSubmitted = newApp.Date_Submitted__c;
        List<String> extFundType = new List<String>{'Community Giving','Independent Medical Education (CME)',
            'Patient and Health Focused Giving', 'Scientific and Research Focused Giving',
            'Education Focused Giving K-12','Education Focused Giving Graduate and Post-Graduate'};
        Boolean isEligible = false;
        
        if(newApp.Record_Type__c != null && extFundType.contains(newApp.Record_Type__c)
           && dateSubmitted != null && dateSubmitted.year() == Date.today().year()){
               if(oldApp != null){
                   if((newApp.Sub_Status__c != null && (oldApp.Sub_Status__c == null || newApp.Sub_Status__c != oldApp.Sub_Status__c) && (newApp.Sub_Status__c == 'Canceled' || newApp.Sub_Status__c == 'Denied')) 
                      || (newApp.Approved_Amount__c != null && (oldApp.Approved_Amount__c == null || newApp.Approved_Amount__c != oldApp.Approved_Amount__c))
                      || (newApp.Approved_Amount__c == null && oldApp.Approved_Amount__c != null)){
                          isEligible = True;
                      }
               }else{
                   if(newApp.Sub_Status__c != null 
                      && (newApp.Sub_Status__c != 'Canceled' && newApp.Sub_Status__c != 'Denied')
                      && newApp.Approved_Amount__c != null){
                          isEligible = True;   
                      }
               }
           }
        return isEligible;        
    }
    
    /*
     * Method to evaluate application changes and recalculate organization total approved amount if required
     * GFRS Dev Team - Sasidhar - 09/21/2021 
     */	
    public void addApprAmountToOrg(List<gFRS_Ltng_Application__c> newAppList ,map<id,gFRS_Ltng_Application__c> oldAppMap){
        

        if(newAppList.size() == 1){
            String cafOrgs = System.Label.gFRS_CAF_OrgList;
            List<String> cafOrgList = cafOrgs.split(',');
            gFRS_Ltng_Application__c appRec = newAppList[0];
            if(cafOrgList.contains(appRec.Organization__r.Name)){
            	gFRS_Ltng_Copay_Util.doLimtCal_NonCopay(appRec.Organization__c, appRec.Date_for_Limit_Calculation__c);
                return;
            }         
        }
        try{            
            if(oldAppMap!= null){             
                List<gFRS_Ltng_Organization__c> orgList = new List<gFRS_Ltng_Organization__c>();            
                set<Id> orgIds = new set<Id>();
                for(gFRS_Ltng_Application__c appObj : newAppList){  
                    orgIds.add(appObj.Organization__c);
                    gFRS_Ltng_Application__c oldApp = oldAppMap.get(appObj.ID);                
                    Boolean recalculate =  checkRequestEligibilty(appObj,oldApp);
                    System.debug('Limit calculation - checkRequestEligibilty ' + appObj.ID + recalculate);
                    if(recalculate == true){
                        orgIds.add(appObj.Organization__c);
                    }
                }
                if(orgIds.size() > 0){
                    for(gFRS_Ltng_Organization__c  orgListRec : [select id, gFRS_Tot_Aprv_Crnt_Yr__c, 
                                                                 (select id, sub_status__c, Date_Submitted__c, Record_Type__c, Approved_Amount__c from FRS_Applications__r WHERE sub_status__c NOT IN ('Canceled','Denied')),
                                                                 (select id, Internal_Sub_Status__c, Date_for_Limit_Calculation__c, Total_Approved_Amount__c from gFRS_CAF_Applications__r WHERE Internal_Sub_Status__c NOT IN ('Canceled','Denied'))
                                                                 from gFRS_Ltng_Organization__c where id IN:orgIds])
                    {
                        orgListRec.gFRS_Tot_Aprv_Crnt_Yr__c = 0.0; 
                        for(gFRS_Ltng_Application__c orgApp : orgListRec.FRS_Applications__r){
                            Boolean considerApp = checkRequestEligibilty(orgApp,null);
                            if(considerApp == true){
                                orgListRec.gFRS_Tot_Aprv_Crnt_Yr__c = orgListRec.gFRS_Tot_Aprv_Crnt_Yr__c + orgApp.Approved_Amount__c;    
                            }
                        }   
                        for(gFRS_Ltng_CAF_Application__c orgApp : orgListRec.gFRS_CAF_Applications__r){
                            Boolean considerApp = gFRS_Ltng_Copay_Util.checkRequestEligibilty(orgApp,null);
                            if(considerApp == true){
                                orgListRec.gFRS_Tot_Aprv_Crnt_Yr__c = orgListRec.gFRS_Tot_Aprv_Crnt_Yr__c + orgApp.Total_Approved_Amount__c;    
                            }
                        }   
                        orgList.add(orgListRec); 
                    }         
                    
                    update orgList;
                }
            }            
        }catch(exception ex){
            System.debug('Error occured in addApprAmountToOrg - ' + ex.getMessage());    
        }     
    }
    
    

    // Added by Divyan
	 public void updateFocusAreaOnPrograms(Map<Id, gFRS_Ltng_Application__c> newRequestsMap, Map<Id, gFRS_Ltng_Application__c> oldRequestsMap){
        
         List<String> IdOfGfrsApplication = new List<String>();
         List<gFRS_Application_RecordType_Change__e> listOfPlatformEvnt = new List<gFRS_Application_RecordType_Change__e>();
         
         for (gFRS_Ltng_Application__c app : newRequestsMap.values()){
             if (app.Focus_Area__c  != oldRequestsMap.get(app.id).Focus_Area__c){
                 IdOfGfrsApplication.add(app.id);
             }
             if (app.RecordTypeId  != oldRequestsMap.get(app.id).RecordTypeId){
                 gFRS_Application_RecordType_Change__e platEvnt = new gFRS_Application_RecordType_Change__e();
                 platEvnt.Record_Id__c = app.id;
                 platEvnt.Record_Type_Name__c  = 'test';
                 listOfPlatformEvnt.add(platEvnt);
             } 
         }
         
         List<gFRS_Ltng_Program__c > listOfPrograms = [Select gFRS_Focus_Area__c ,gFRS_Sub_Focus_Area__c,gFRS_Application__c 
                                                      from gFRS_Ltng_Program__c
                                                      where gFRS_Application__c =: IdOfGfrsApplication];
         
         List<gFRS_Ltng_Program__c> ProgramsToUpdate = new List<gFRS_Ltng_Program__c>();
         if (!listOfPrograms.isEmpty()){
             for (gFRS_Ltng_Program__c prog : listOfPrograms){
                 prog.gFRS_Focus_Area__c = newRequestsMap.get(prog.gFRS_Application__c).Focus_Area__c;
                 prog.gFRS_Sub_Focus_Area__c = '';
                 ProgramsToUpdate.add(prog);
             }
         }
         
         if (!ProgramsToUpdate.isEmpty()){
             update ProgramsToUpdate;
         }
         
         if (!listOfPlatformEvnt.isEmpty()){
             EventBus.publish(listOfPlatformEvnt[0]);
         }
         
    }

    
    public void addSharingForApprovers(Map<Id, gFRS_Ltng_Application__c> newRequestsMap, Map<Id, gFRS_Ltng_Application__c> oldRequestsMap) {
        List<GFRS_Ltng_Application__Share> shrForBrAndBaApprovers = new List<GFRS_Ltng_Application__Share>();
        List<gFRS_Ltng_Application__c> requestMeetingCriteriaToAddSharing = new List<gFRS_Ltng_Application__c>();        
        List<gFRS_Ltng_Application__c> requestMeetingCriteriaToAddSharingInternal = new List<gFRS_Ltng_Application__c>(); 
        for (gFRS_Ltng_Application__c newRequest : newRequestsMap.values()) {
            gFRS_Ltng_Application__c oldRequest = oldRequestsMap.get(newRequest.Id);
            if (newRequest.Legal_Approver__c != oldRequest.Legal_Approver__c) {
                requestMeetingCriteriaToAddSharing.add(newRequest);
            }
            if(newRequest.Record_Type__c == 'Field Exhibits' || newRequest.Record_Type__c == 'Corporate Memberships' || newRequest.Record_Type__c == 'Commercial Sponsorship' || newRequest.Record_Type__c == 'Non-Commercial Sponsorship'){
                if (newRequest.Business_Approver__c != oldRequest.Business_Approver__c || newRequest.Finance_Approver__c != oldRequest.Finance_Approver__c || newRequest.Finance_Manager__c != oldRequest.Finance_Manager__c) {
                    requestMeetingCriteriaToAddSharingInternal.add(newRequest);
                }
            }
        }

        for (gFRS_Ltng_Application__c tmpRequest : requestMeetingCriteriaToAddSharing) {
            //Add Read sharing
            GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
            shrFundingRequest.ParentId = tmpRequest.Id;
            shrFundingRequest.UserOrGroupId = tmpRequest.Legal_Approver__c;
            shrFundingRequest.AccessLevel = 'Read';
            shrFundingRequest.RowCause = 'Manual';
            shrForBrAndBaApprovers.add(shrFundingRequest);                  
        }

        for (gFRS_Ltng_Application__c tmpRequest : requestMeetingCriteriaToAddSharingInternal) {
            //Add Read sharing
            if(tmpRequest.Business_Approver__c != null){
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Business_Approver__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);  
            }
            
            if(tmpRequest.Finance_Approver__c != null){
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Finance_Approver__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);  
            }
            
            if(tmpRequest.Finance_Manager__c != null){
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Finance_Manager__c;
                shrFundingRequest.AccessLevel = 'Edit';
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);  
            }
        }        
        
        if (!shrForBrAndBaApprovers.isEmpty()) {
            
            Database.SaveResult [] srList = gFRS_Ltng_Util_NoShare.insertSharingRecs(shrForBrAndBaApprovers);
            String errorOutput = '';
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    if (errorOutput == '') {
                        errorOutput = 'Following errors occured while inserting sharings for BR and BAs';
                    }
                    for (Database.Error err : sr.getErrors()) {
                        errorOutput += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                    }
                }
            }
            System.debug(errorOutput);
        }        
    }

    public void createAppropriateTask(Map<Id, gFRS_Ltng_Application__c> newRequestsMap, Map<Id, gFRS_Ltng_Application__c> oldRequestsMap) {
 		List<gFRS_Ltng_Task__c> taskList = new List<gFRS_Ltng_Task__c>();
        Map<Id, gFRS_Ltng_Task__c> taskMap = new Map<Id, gFRS_Ltng_Task__c>();
        //Set<Id> appIDs = newRequestsMap.keySet();
        Set<Id> appIDs = new Set<Id>();
        Set<Id> appRfiIDs = new Set<Id>();
        
        for (gFRS_Ltng_Application__c newReq : newRequestsMap.values()) {
            if(newReq.Status__c == 'Processing & Disposition' && oldRequestsMap.get(newReq.id).Status__c != 'Processing & Disposition'){
                appIDs.add(newReq.Id);
            }
            
            if(newReq.Status__c != 'RFI' && oldRequestsMap.get(newReq.id).Status__c == 'RFI' && 
               newReq.Sub_Status__c != 'RFI' && oldRequestsMap.get(newReq.id).Sub_Status__c == 'RFI'){
                appRfiIDs.add(newReq.Id);
            }
        }
        
        List<gFRS_Ltng_Task__c> taskToUpdate = new List<gFRS_Ltng_Task__c>();
        List<gFRS_Ltng_Task__c> tasks = new List<gFRS_Ltng_Task__c>();
        List<gFRS_Ltng_Task__c> RFItasks = new List<gFRS_Ltng_Task__c>();
        
        if(appIDs.size() > 0){
            tasks = [SELECT Id, Action_Type__c, gFRS_Application__c FROM gFRS_Ltng_Task__c WHERE Action_Type__c = 'Payment Method' and Status__c = 'Open' and gFRS_Application__c IN :appIDs];
        }
        
        if(appRfiIDs.size() > 0){
            RFItasks = [SELECT Id, Action_Type__c, gFRS_Application__c FROM gFRS_Ltng_Task__c WHERE Action_Type__c = 'RFI' and Status__c = 'Open' and gFRS_Application__c IN :appRfiIDs];
        }
        
        if(RFItasks.size() > 0){
            for (gFRS_Ltng_Task__c task : RFItasks) {
                gFRS_Ltng_Task__c RfiTask = new gFRS_Ltng_Task__c();
                RfiTask.Id = task.Id;
                RfiTask.Status__c = 'Completed';
                
                taskToUpdate.add(RfiTask);
            }
        }
        
        if(tasks.size() > 0){
            for(gFRS_Ltng_Task__c task :tasks){
                taskMap.put(task.gFRS_Application__c, task);
            }
        }
        
        for (gFRS_Ltng_Application__c newRequest : newRequestsMap.values()) {
            if(newRequest.Sub_Status__c == 'New' && oldRequestsMap.get(newRequest.id).Sub_Status__c == 'Not Submitted' && gFRS_Ltng_Util.isInternalRequest(newRequest.Record_Type__c)){        
                gFRS_Ltng_Task__c createTask = new gFRS_Ltng_Task__c();
                
                createTask.gFRS_Application__c = newRequest.Id;
                createTask.Status__c		   = 'Open';
                createTask.Action_Type__c 	   = 'Payment Method';
                createTask.Description__c 	   = 'Please respond to the ACH task for Funding Request: ' + newRequest.Name;
                createTask.Subject__c		   = 'ACH Task';
                Date todaysDate 			   = System.today();
                createTask.Start_Date__c       = todaysDate;  
                
                taskList.add(createTask);
            }
            if(newRequest.Status__c == 'Processing & Disposition' && oldRequestsMap.get(newRequest.id).Status__c != 'Processing & Disposition'){
                gFRS_Ltng_Task__c pmtMethodTask = new gFRS_Ltng_Task__c();
                if(taskMap.containsKey(newRequest.Id)){
                    pmtMethodTask = taskMap.get(newRequest.Id);
                    pmtMethodTask.Status__c = 'Completed';
                    taskToUpdate.add(pmtMethodTask);
                }
                
            }
        }    
        
        if(taskToUpdate.size() > 0){
            update taskToUpdate;
        }
        
        if(taskList.size() > 0){
            insert taskList;
            
            emailtemplate et = [SELECT Subject, Name, Id, Description, Body, HtmlValue, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_2_0_Email_Templates' and DeveloperName = 'gFRS_2_0_Payment_Method_Task_Email'];
            
            for (gFRS_Ltng_Application__c newRequest : newRequestsMap.values()) {
                //String body = replaceEmailBody(et.HtmlValue, newRequest);
                String communityURL = System.Label.gFRS_Ltng_Community_URL;
                String body = et.HtmlValue.replace('{!gFRS_Ltng_Application__c.Name}', newRequest.Name);
                body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', newRequest.Event_Program_Title__c);
                body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c}', newRequest.First_Name__c);
                body = body.replace('{!gFRS_Ltng_Application__c.Last_Name__c}', newRequest.Last_Name__c); 
                body = body.replace('{!gFRS_Ltng_Application__c.Attention_To__c}', newRequest.Attention_To__c);
                body = body.replace('{!gFRS_Ltng_Application__c.Person_To_Whom_Payment_should_addressed__c}', newRequest.Person_To_Whom_Payment_should_addressed__c);
                //body = body.replace('<<Community Link>>', communityURL);
                body = body.replace(']]>','');
                
                body += '\n\n' + '[ref:' + newRequest.id + ']';
                String subject = et.Subject.replace('<<Request Name>>', newRequest.Name);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{newRequest.Person_To_Whom_Payment_should_addressed__c});
                mail.setSubject(subject);
                //mail.setPlainTextBody(body);
                mail.setHtmlBody(body);
                mail.setTreatBodiesAsTemplate(true);

                mail.setOrgWideEmailAddressId([SELECT Id, Address FROM OrgWideEmailAddress
                                               WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
                GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
                if (myOrgCS.gFRS_Inbound_Email__c != null) {
                    string bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
                    mail.setBccAddresses(new List<String>{bccEmailAddress});                            
                }                               
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                /* if(results[0].success){
                    try{
                        Attachment a       = new Attachment();
                        a.ParentId         = Id.valueOf(newRequest.Id);
                        a.ContentType = '.pdf';
                        String fileContent = '';
                        
                        fileContent +='From: '+Userinfo.getUserEmail()+'\n';
                        fileContent +='To: '+mail.toAddresses+'\n';
                        
                        if(mail.ccAddresses == null){
                            fileContent +='CC: \n';  
                        }else{
                            fileContent +='CC: '+mail.ccAddresses+'\n';
                        }
                        //fileContent =fileContent.replace(')','').replace('(','');
                        fileContent +='Subject: '+mail.subject+'\n\n';
                        
                        
                        if(mail.plainTextBody != null){
                            fileContent += EncodingUtil.urlDecode(mail.plainTextBody,'UTF-8');
                        }  
                        
                        a.Body = Blob.valueOf(fileContent);  
                        a.Name = mail.subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                        
                        if(mail.toaddresses != null){
                            a.Description='Sent by ' +mail.toaddresses;
                        }else{                  
                            a.Description='test';
                            
                        }  
                        
                        //insert a;       
                        gFRS_Ltng_Util_NoShare.saveLockedAttachment(a);
                        
                    }
                    
                    catch(Exception e){
                        system.debug('@@ Error while sending email.');
                    }
                } */
            }
        }
        
    }
    
    /** 
* @Author gFRS Dev Team
* @date 14/10/2021
* @description replaceEmailBody method set dynamic values in defined in body of emailTemplate
* 
*/
    public static String replaceEmailBody(String emailBody, gFRS_Ltng_Application__c req) {
        
        String outputBody = '';
        
        if (emailBody != null) {
            String communityURL = System.Label.gFRS_Ltng_Community_URL;
            
            outputBody = emailBody.replace('<<Request Name>>', req.Name);
            outputBody = outputBody.replace('<<Program Title>>', req.Event_Program_Title__c);
            outputBody = outputBody.replace('<<Auth First Name>>', req.First_Name__c);
            outputBody = outputBody.replace('<<Auth Last Name>>', req.Last_Name__c);            
            outputBody = outputBody.replace('<<Attn To>>', req.Person_To_Whom_Payment_should_addressed__c);
            outputBody = outputBody.replace('<<Community Link>>', communityURL);
            outputBody = outputBody.replace(']]>','');
        }
        
        return outputBody;
    }    
   /*
    * creation of evaluation task method 
    * 
    *  
    */
    public void createEvaluationTask(Map<Id, gFRS_Ltng_Application__c> newRequestsMap, Map<Id, gFRS_Ltng_Application__c> oldRequestsMap) {
 		List<gFRS_Ltng_Task__c> taskList = new List<gFRS_Ltng_Task__c>();
        gFRS_Ltng_Task_Update__c taskUpdateObj = new gFRS_Ltng_Task_Update__c();
        for (gFRS_Ltng_Application__c newRequest : newRequestsMap.values()) {
            if(oldRequestsMap.get(newRequest.id).Sub_Status__c!=newRequest.Sub_Status__c && newRequest.Status__c == 'Processing & Disposition' && newRequest.Sub_Status__c == 'Approved-Program Evaluations' && newRequest.Is_Evaluation_Required__c ==True && newRequest.Record_Type__c != 'Independent Medical Education (CME)'){        
                gFRS_Ltng_Task__c createTask = new gFRS_Ltng_Task__c();
                
                createTask.gFRS_Application__c = newRequest.Id;
                createTask.Status__c		   = 'Open';
                createTask.Action_Type__c 	   = 'Evaluation';
                createTask.Description__c 	   = 'Please respond to the Evaluation task for Funding Request: ' + newRequest.Name;
                createTask.Subject__c		   = 'Evaluation Task';
                Date todaysDate 			   = System.today();
                createTask.Start_Date__c       = todaysDate; 
                taskList.add(createTask);               
                
                taskUpdateObj.gFRS_Application__c = newRequest.Id;
                taskUpdateObj.Name = 'Evaluation';
                
            }
        }    
        
        if(taskList.size() > 0){
            insert taskList;
            insert taskUpdateObj;
        }
        
    }
    
    /**
	* @Author ADMD Team
	* @date 11/12/2021
	* @description updateUnixID method - When user is changing 'Payment Delivery/Notification' field, Payment_Email_Notification__c field is also updated.
	*/

    /*public void updatePaymentEmailNotification(final gFRS_Ltng_Application__c[] newApps,final Map<Id, gFRS_Ltng_Application__c> oldApplicationsMap) {
        
        Set<Id> userIds = new Set<Id>();
        Set<gFRS_Ltng_Application__c> impactedAppList = new Set<gFRS_Ltng_Application__c>();
        
        for(gFRS_Ltng_Application__c newApp : newApps){
            gFRS_Ltng_Application__c oldApp = oldApplicationsMap.get(newApp.Id);
            if(String.isNotBlank(newApp.Payment_Delivery_Notification__c) && newApp.Payment_Delivery_Notification__c != oldApp.Payment_Delivery_Notification__c){
            	impactedAppList.add(newApp);
                userIds.add(newApp.Payment_Delivery_Notification__c);
            }else if(String.isBlank(newApp.Payment_Delivery_Notification__c) && String.isNotBlank(oldApp.Payment_Delivery_Notification__c)){
            	newApp.Payment_Email_Notification__c = '';    
            }
        }
        
        Map<Id,User> usersMap = new Map<Id,User>([SELECT Alias FROM User WHERE Id IN : userIds]);
        
        for(gFRS_Ltng_Application__c gFRSapp : impactedAppList){
            User userInfo = usersMap.get(gFRSapp.Payment_Delivery_Notification__c);
        	gFRSapp.Payment_Email_Notification__c = userInfo.Alias;	    
        }       
        
    }*/   
    @future
	public static void generateDecisionFlagForBulkApproval(string newRequestRec) {
        gFRS_Ltng_Application__c newRequest = (gFRS_Ltng_Application__c)JSON.deserialize(newRequestRec, gFRS_Ltng_Application__c.class);
        if(newRequest.Record_Type__c == 'Community Giving' || newRequest.Record_Type__c == 'Education Focused Giving K-12' ||
           newRequest.Record_Type__c == 'Foundation Undergraduate' || newRequest.Record_Type__c == 'Foundation Safety Net Support'){
               String compliancedocumentName = 'Decision_Flags_' + newRequest.Name;                   
               gFRS_Ltng_Compliance_Flag_Util_Foun_CG.generatePDF(newRequest.Id,compliancedocumentName);                        
           } 
        if(newRequest.Record_Type__c == 'Patient and Health Focused Giving'){
            String compliancedocumentName = 'Decision_Flags_' + newRequest.Name;                    
            gFRS_Ltng_Compliance_Flag_Util_Patient.generatePDF(newRequest.Id,compliancedocumentName);
        }
        if(newRequest.Record_Type__c == 'Scientific and Research Focused Giving' || newRequest.Record_Type__c == 'Education Focused Giving Graduate and Post-Graduate'){
            String compliancedocumentName = 'Decision_Flags_' + newRequest.Name;                    
            gFRS_Ltng_Compliance_Flag_Util_Scien_Edu.generatePDF(newRequest.Id,compliancedocumentName);
        }
    
    }
}