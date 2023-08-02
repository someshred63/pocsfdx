public class gFRS_Ltng_Change_Approver_Controller {
    
    @AuraEnabled
    public static void updateRec(Id recordid,String newBAString,String newFAString,String newFMString){
        
        List<User> userRecs = new List<User>();
        Id newBA = newBAString==''?null:Id.valueOf(newBAString);
        Id newFA = newFAString==''?null:Id.valueOf(newFAString);
        Id newFM = newFMString==''?null:Id.valueOf(newFMString);
        
        if(newBA != null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newBA];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
        
        if(newFA != null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newFA];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
        
        if(newFM != null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newFM];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
        
        if(userRecs.size() > 0){
            //update userRecs;
            gFRS_Ltng_Util_NoShare.updateUserRec(userRecs);
        }
        
        updateRecordAndShare(recordid, newBAString, newFAString, newFMString);
    }
    
    @future
    public static void updateRecordAndShare(Id recordid,String newBAString,String newFAString,String newFMString){
        
        Boolean BA = false;
        Boolean FA = false;
        Boolean FM = false;
        Id newBA = newBAString==''?null:Id.valueOf(newBAString);
        Id newFA = newFAString==''?null:Id.valueOf(newFAString);
        Id newFM = newFMString==''?null:Id.valueOf(newFMString);
        
        EmailTemplate et = [SELECT Name, Body, Description, DeveloperName, FolderId, HtmlValue, Subject, TemplateStyle, TemplateType
                                FROM EmailTemplate WHERE name = 'gFRS 2.0 UC-05 Approving / Rejecting Requests Approval Pending (Notify Approver)'].get(0);
        String bccEmailAddress='';
            GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
            if(myOrgCS.gFRS_Inbound_Email__c != null){
                   bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            }
         Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;
        System.debug('-->newBA '+newBA);
        System.debug('-->newFA '+newFA);
        System.debug('-->newFM '+newFM);
        List<gFRS_Ltng_Application__c> appRecLst=new List<gFRS_Ltng_Application__c>();
        List<GFRS_Ltng_Application__Share> shrForNewApprovers = new List<GFRS_Ltng_Application__Share>();
        Set<Id> delShrForOldApprovers = new Set<Id>();
        ProcessInstanceWorkitem PIWI = new ProcessInstanceWorkitem();
        appRecLst=[SELECT Id,Name,Event_Program_Title__c,Record_Type__c,Program_Start_Date_Min__c,Requested_Amount__c,Status__c,Sub_Status__c,Business_Approver__c,Finance_Approver__c,Finance_Manager__c FROM gFRS_Ltng_Application__c where id =:recordid];
        
        if(!appRecLst.isEmpty()){
            
            //Add Read sharing
            if(newBA != null){
                
                if(appRecLst[0].Business_Approver__c !=null && appRecLst[0].Business_Approver__c!= newBA)
                    delShrForOldApprovers.add( appRecLst[0].Business_Approver__c);
                appRecLst[0].Business_Approver__c = newBA;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Business_Approver__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Business Approver'){
                    BA=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Business_Approver__c;
                    
                }
            }
            
            if(newFA != null ){
                
                if(appRecLst[0].Finance_Approver__c !=null && appRecLst[0].Finance_Approver__c != newFA)
                    delShrForOldApprovers.add( appRecLst[0].Finance_Approver__c);
                appRecLst[0].Finance_Approver__c = newFA;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Finance_Approver__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Financial Approver'){
                    FA=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Finance_Approver__c;
                    
                }
            }
            
            if(newFM != null){
                
                if(appRecLst[0].Finance_Manager__c !=null && newFM!= appRecLst[0].Finance_Manager__c)
                    delShrForOldApprovers.add( appRecLst[0].Finance_Manager__c);
                appRecLst[0].Finance_Manager__c = newFM;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Finance_Manager__c;
                shrFundingRequest.AccessLevel = 'Edit';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Finance Manager'){
                    FM=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Finance_Manager__c;
                    
                }
            }
            try{
                gFRS_Ltng_Util_NoShare.updateAppRecord(appRecLst[0]);
                
                // ****** Start ****** Please don't delete this dummy email code. This will trigger email service *******
                if(appRecLst[0].Sub_Status__c != 'New' && appRecLst[0].Sub_Status__c != 'Compliance Approver'){
                    Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                    string body     = 'RequestId:' + appRecLst[0].Id + '\n';
                    body            += 'ApproverId:' + PIWI.ActorId;
                    GFRS_Ltng_OrgSettings__c myOrgCS1 = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
                    
                    mail1.setSubject('Dummy email for Re-assigning approver for ' + appRecLst[0].Name);
                    mail1.setPlainTextBody(body);
                    mail1.setToAddresses(new List<String>{myOrgCS1.Reassign_Inbound_Email__c});
                    mail1.setTreatBodiesAsTemplate(true);
                    
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                }
                // ****** End ***** Please don't delete this dummy email code. This will trigger email service *******
                
                if(appRecLst[0].Sub_Status__c != 'New' && appRecLst[0].Sub_Status__c != 'Compliance Approver'){
                    User user;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    String toEmailAddress;
                    if(BA){
                        user = [Select u.email From User u Where u.Id = :newBA ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }else if(FA){
                        user = [Select u.email From User u Where u.Id = :newFA ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }else If(FM){
                        user = [Select u.email From User u Where u.Id = :newFM ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }
                     
                }
            }
            catch(exception e){  
                system.debug('@@@:::Msg:::'+e.getMessage());
                system.debug('@@@LineNum:::'+e.getLineNumber());
                AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                system.debug('auraExceptionObj'+auraExceptionObj);
                throw auraExceptionObj; 
                
            }  
            
        }
        if (!shrForNewApprovers.isEmpty()) {
            System.debug('****New Shr Lst Size:::'+shrForNewApprovers.size());
            Database.SaveResult [] srList = gFRS_Ltng_Util_NoShare.insertSharingRecs(shrForNewApprovers);
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
        }   if(!delShrForOldApprovers.isEmpty() && appRecLst[0].Id!=null){
            
            System.debug('**** Shr Del Lst Size:::'+delShrForOldApprovers.size());
            List<GFRS_Ltng_Application__Share> delListShr = [SELECT Id from GFRS_Ltng_Application__Share where ParentId =: appRecLst[0].Id AND UserOrGroupId IN:delShrForOldApprovers];
            if(!delListShr.isEmpty()){
                Database.delete(delListShr, false); 
            }
        }     
    }     
    
    @AuraEnabled
    public static wrapperEmailData getEmailContent(String RecId){
        
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        
        gFRS_Ltng_Application__c gfrsRequest=[
            SELECT Id,Event_Program_Title__c,Name,Email_Address__c,Accountable_Employee_Internal__r.email,
            Accountable_Employee_Internal__r.FirstName,Accountable_Employee_Internal__r.LastName,Contact_Us_URL1__c,
            DocusignAttach_PDF__c,Owner.Name,Owner.Email,Owner.FirstName,Owner.LastName,Status__c,Sub_Status__c,
            Decision_Reasons__c,Program_Start_Date_Min__c,Program_End_Date_max__c,First_Name__c,Last_Name__c,
            Payment_Cost_Center__c,Disease_State__c,LastModifiedBy.Name,Approved_Amount__c,Requested_Amount__c,
            Record_Type__c,RecordType.Name,Business_Approver__c,Business_Approver_2__c,Compliance_Approver__c,
            Finance_Approver__c,Legal_Approver__c,DocuSign_Revised_LOA_Id__c FROM gFRS_Ltng_Application__c WHERE Id = :RecId
        ]; // GFRS-1048
        String emailName = '';
        if(gfrsRequest.RecordType.Name == 'Foundation Safety Net Support' || gfrsRequest.RecordType.Name == 'Foundation Undergraduate'){
            emailName = 'LOA_DocuSign_Review_Attachment_Foundation';
        }else{
            emailName = 'LOA_DocuSign_Review_Attachment';
        }
        EmailTemplate  emailCon = [SELECT Subject, Name, Id, Markup,Description,HTMLValue, Body,DeveloperName
                                   FROM EmailTemplate WHERE DeveloperName =: emailName];
        
        system.debug('Application values' +gfrsRequest);
        
        string prgStartDate =  string.valueOf(gfrsRequest.Program_Start_Date_Min__c);
        String programDate = '';
        if(String.isNotBlank(prgStartDate)){
            Date dt=gfrsRequest.Program_Start_Date_Min__c;
            programDate=dt.format();
        }
        
        String emailSub = emailCon.Subject;
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', gfrsRequest.Name); 

        String title = gfrsRequest.Event_Program_Title__c;
        //string appAmount = string.valueOf(gfrsRequest.Approved_Amount__c);
        Decimal appAmountDec = gfrsRequest.Approved_Amount__c;
        String appAmount;
        String y = String.valueOf(appAmountDec);
        String z = '.';
        if(y.contains(',')) z = ',';
        y = y.substring(0, y.indexOf(z));
        
        if(appAmountDec - Decimal.valueOf(y) == 0)
            appAmount = '$' + String.valueOf(appAmountDec.format()) + z + '00';
        else 
            appAmount = '$' + String.valueOf(appAmountDec.format());

        String htmlBody = emailCon.Body;
        htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Name}', gfrsRequest.Name); 

        if(gfrsRequest.Event_Program_Title__c != null && gfrsRequest.Event_Program_Title__c != '') {
            //body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', gfrsRequest.Event_Program_Title__c);
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', gfrsRequest.Event_Program_Title__c);
        } else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        
        if(gfrsRequest.Record_Type__c != null && gfrsRequest.Record_Type__c != ''){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Record_Type__c}', gfrsRequest.Record_Type__c);
        }
        else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Record_Type__c}','');
        }
        
        if(String.isNotBlank(appAmount)){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}', appAmount);
        }
         else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}','');
        }
        if(gfrsRequest.First_Name__c != null && gfrsRequest.First_Name__c != '') {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.First_Name__c}', gfrsRequest.First_Name__c);
        }
        else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.First_Name__c}','');
        }
        if(gfrsRequest.Last_Name__c != null && gfrsRequest.Last_Name__c != '') {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Last_Name__c}', gfrsRequest.Last_Name__c);
        }
        else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Last_Name__c}','');
        }
        
        if(String.isNotBlank(programDate)){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate); 
        }else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
        }
        
        htmlBody = htmlBody.replace(']]>', '');
        //htmlBody += '\n\n' + '[ref:' + gfrsRequest.id + ']';
        
        returnwrapperClass.emailBody = htmlBody;

        returnwrapperClass.subject = emailSub;
        returnwrapperClass.authEmail = gfrsRequest.Email_Address__c;
        returnwrapperClass.authName = gfrsRequest.First_Name__c+' '+gfrsRequest.Last_Name__c;
        
        String recordType = gfrsRequest.Record_Type__c;
        if(recordType == 'Commercial Sponsorship' || recordType == 'Corporate Memberships' || recordType == 'Non-Commercial Sponsorship'){
            returnwrapperClass.ownerEmail = gfrsRequest.Accountable_Employee_Internal__r.email;
            returnwrapperClass.ownerName = gfrsRequest.Accountable_Employee_Internal__r.FirstName+''+gfrsRequest.Accountable_Employee_Internal__r.LastName;
        }else{
            returnwrapperClass.ownerEmail = gfrsRequest.owner.email; /* add code as part of defect fix - Sending email to the record owner email add code as part of defect fix **Kiran */
            returnwrapperClass.ownerName = gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName;
        }
        if(gfrsRequest.DocuSign_Revised_LOA_Id__c != null) { // GFRS-1048
            returnwrapperClass.docuSignRevisedLOAId = gfrsRequest.DocuSign_Revised_LOA_Id__c;
        }
        return returnwrapperClass;
        
    }
    
    public class wrapperEmailData{
        @AuraEnabled
        public String emailBody {get;set;}
        @AuraEnabled
        public String ownerEmail {get;set;}
        @AuraEnabled
        public String subject {get;set;}
        @AuraEnabled 
        public String authEmail {get;set;}
        @AuraEnabled
        public String authName {get;set;}
        //@AuraEnabled public String recStatus{get;set;}
        @AuraEnabled
        public String ownerName {get;set;}
        @AuraEnabled
        public String docuSignRevisedLOAId {get; set;} // GFRS-1048
    }
    
    @AuraEnabled
    public static void generateLOA(Id appId){
        gFRS_Ltng_Application__c appRec = [SELECT Id,RecordType.Name
                                          FROM gFRS_Ltng_Application__c WHERE Id =: appId LIMIT 1];
        if(appRec.RecordType.Name == 'Commercial Sponsorship' || appRec.RecordType.Name == 'Corporate Memberships' || appRec.RecordType.Name == 'Non-Commercial Sponsorship'){
            gFRS_DocusignAttachPDF_Internal.InsertDocument(appId);
        }
        if(appRec.RecordType.Name == 'Independent Medical Education (CME)'){
            gFRS_DocusignAttachPDF_CME.InsertDocument(appId,'');
        }
        if(appRec.RecordType.Name == 'Community Giving' || appRec.RecordType.Name == 'Education Focused Giving K-12'){
            gFRS_DocusignAttachPDF_CG_K12.InsertDocument(appId,'');
        }
        if(appRec.RecordType.Name == 'Patient and Health Focused Giving' || appRec.RecordType.Name == 'Scientific and Research Focused Giving' || appRec.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate'){
            gFRS_DocusignAttachPDF_Pat_Sci_Edu.InsertDocument(appId,'');
        }
        if(appRec.RecordType.Name == 'Foundation Safety Net Support' || appRec.RecordType.Name == 'Foundation Undergraduate'){
            gFRS_DocusignAttachPDF_Foundation.InsertDocument(appId,'');
        }
    }
    @AuraEnabled
    public static void sendLoaReminder(Id appId,String CCUser){
        SendNowLOAReminder(appId,CCUser);
    }
    @future(callout=true)   
    public static void SendNowLOAReminder(Id sourceId,String CCUser){
       String envelopeId;
       GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
       String accountId = orgCS.DocuSign_AccountId__c;
       String userId = orgCS.DocuSign_UserId__c;
       String password = orgCS.DocuSign_Password__c;
       String integratorsKey = orgCS.DocuSign_IntegratorsKey__c;    //DocuSign_IntegratorsKey__c
       String webServiceUrl = orgCS.DocuSign_WebServiceUrl__c;  //DocuSign_WebServiceUrl__c
        
    /* String accountId = '95bf06d3-cfb9-452a-9d7d-e1ce96948270';   //DocuSign_AccountId__c
       String userId = '3bb814d2-2623-415f-90c5-2e16e4af6019';  //DocuSign_UserId__c
       String password = 'Demo2021';    //DocuSign_Password__c
       String integratorsKey = '7b3934f7-593a-411b-8a56-c9a254e73348';  //DocuSign_IntegratorsKey__c
       String webServiceUrl = 'https://demo.docusign.net/api/3.0/dsapi.asmx';   //DocuSign_WebServiceUrl__c*/
       gFRS_Ltng_Application__c appRec = [
        SELECT Id,Name,Approved_Amount__c,Event_Program_Title__c,Record_Type__c,RecordType.Name,EnvelopeId__c,
        Owner.FirstName,Owner.LastName,Owner.email,Program_Start_Date_Min__c,DocusignAttach_PDF_ID__c,DocuSign_Revised_LOA_Id__c,
        Email_Address__c,First_Name__c,Last_Name__c,Authorized_Signer__r.Name,Accountable_Employee_Internal__r.email,
        Accountable_Employee_Internal__r.FirstName,Accountable_Employee_Internal__r.LastName FROM gFRS_Ltng_Application__c 
        WHERE Id =: sourceId LIMIT 1
        ];

        String documentId = String.isNotBlank(appRec.DocuSign_Revised_LOA_Id__c) ? 
        appRec.DocuSign_Revised_LOA_Id__c : appRec.DocusignAttach_PDF_ID__c;
        
       Blob pdfBlob = [SELECT Id,VersionData from ContentVersion WHERE ContentDocumentId =: documentId LIMIT 1].VersionData;
        String emailName = '';
        if(appRec.RecordType.Name == 'Foundation Safety Net Support' || appRec.RecordType.Name == 'Foundation Undergraduate'){
            emailName = 'LOA_DocuSign_Review_Attachment_Foundation';
        }else{
            emailName = 'LOA_DocuSign_Review_Attachment';
        }
        EmailTemplate  emailCon = [SELECT Subject, Name, Id, Description,HTMLValue,Body,DeveloperName
                                   FROM EmailTemplate WHERE DeveloperName =: emailName];
        //emailCon.setTargetObjectId(appRec.Id);
        
        string prgStartDate =  string.valueOf(appRec.Program_Start_Date_Min__c);
        String programDate = '';
        if(String.isNotBlank(prgStartDate)){
            Date dt=appRec.Program_Start_Date_Min__c;
            programDate=dt.format();
        }
        
        string Subject = emailCon.Subject.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
        
        String body = emailCon.HTMLValue.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
        String plainTextBody = emailCon.Body.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
        
        body = body.replace('{!gFRS_Ltng_Application__c.Record_Type__c}',appRec.Record_Type__c);
        plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Record_Type__c}',appRec.Record_Type__c);
        
        //body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c} {!gFRS_Ltng_Application__c.Last_Name__c}',appRec.First_Name__c + appRec.Last_Name__c);
        if(string.isNotBlank(appRec.First_Name__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c}',appRec.First_Name__c);
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.First_Name__c}',appRec.First_Name__c);
        }
        if(string.isNotBlank(appRec.Last_Name__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.Last_Name__c}',appRec.Last_Name__c);
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Last_Name__c}',appRec.Last_Name__c);
        }
        
        Decimal input=appRec.Approved_Amount__c;
        String AppAmount = '$' + String.valueOf(input.format());
        body = body.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}',AppAmount);
        plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}',AppAmount);
        
        if(string.isNotBlank(appRec.Event_Program_Title__c)) {
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', appRec.Event_Program_Title__c);
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', appRec.Event_Program_Title__c);
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        
        if(String.isNotBlank(programDate)){
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate); 
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate);
        }else {
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
            plainTextBody = plainTextBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
        }
        
        body = body.replace(']]>', '');
        body += '\n\n' + '[ref:' + appRec.id + ']';
        
        DocuSignAPI.APIServiceSoap dsApiSend = new DocuSignAPI.APIServiceSoap();
        dsApiSend.endpoint_x = webServiceUrl;

        //Set Authentication
        String auth = '<DocuSignCredentials><Username>'+ userId 
            +'</Username><Password>' + password 
            + '</Password><IntegratorKey>' + integratorsKey 
            + '</IntegratorKey></DocuSignCredentials>';
        System.debug('Setting authentication to: ' + auth);
            
        dsApiSend.inputHttpHeaders_x = new Map<String, String>();
        dsApiSend.inputHttpHeaders_x.put('X-DocuSign-Authentication', 
            auth);
 
        DocuSignAPI.Envelope envelope = new DocuSignAPI.Envelope();
        envelope.Subject = Subject;
        //envelope.EmailBlurb = 'I am sending you this request for your electronic signature, please review and electronically sign by following the link below.';
        envelope.EmailBlurb = body;
        envelope.AccountId  = accountId; 


        // Render the contract
       // System.debug('Rendering the contract');
        //PageReference pageRef = new PageReference('/apex/RenderContract');
       // pageRef.getParameters().put('id',contract.Id);
        //Blob pdfBlob = pageRef.getContent();     
        //Blob pdfBlob = [SELECT Id,ContentDocumentId,ContentBodyId,ContentSize,VersionData from ContentVersion].VersionData;
        

        // Document
        DocuSignAPI.Document document = new DocuSignAPI.Document();
        document.ID = 1;
        document.pdfBytes = EncodingUtil.base64Encode(pdfBlob);
        document.Name = appRec.Name+'_Executed LOA';
        document.FileExtension = 'pdf';
        envelope.Documents = new DocuSignAPI.ArrayOfDocument();
        envelope.Documents.Document = new DocuSignAPI.Document[1];
        envelope.Documents.Document[0] = document;
        
        // Recipient
        System.debug('getting the contact');
        
        DocuSignAPI.Recipient recipient = new DocuSignAPI.Recipient();
        recipient.ID = 1;
        recipient.Type_x = 'Signer';
        recipient.RoutingOrder = 1;
        recipient.Email = appRec.Email_Address__c;
        //recipient.UserName = appRec.Authorized_Signer__r.Name;
        recipient.UserName = appRec.First_Name__c+' '+appRec.Last_Name__c;
            
        // This setting seems required or you see the error:
        // "The string '' is not a valid Boolean value. 
        // at System.Xml.XmlConvert.ToBoolean(String s)" 
        recipient.RequireIDLookup = false;      
        
        DocuSignAPI.Recipient ccrecipient = new DocuSignAPI.Recipient();
        ccrecipient.ID = 1;
        ccrecipient.Type_x = 'CarbonCopy';
        ccrecipient.RoutingOrder = 1;
        String recordType = appRec.Record_Type__c;
        if(recordType == 'Commercial Sponsorship' || recordType == 'Corporate Memberships' || recordType == 'Non-Commercial Sponsorship'){
            ccrecipient.Email = appRec.Accountable_Employee_Internal__r.email;
            ccrecipient.UserName = appRec.Accountable_Employee_Internal__r.FirstName+''+appRec.Accountable_Employee_Internal__r.LastName;
        }else{
            ccrecipient.Email = appRec.Owner.email;
            ccrecipient.UserName = appRec.Owner.FirstName + appRec.Owner.LastName;
        }
        ccrecipient.RequireIDLookup = false; 
         
        
        DocuSignAPI.Recipient ccrecipientUser = new DocuSignAPI.Recipient();
        if(String.isNotEmpty(CCUser)){
        ccrecipientUser.ID = 1;
        ccrecipientUser.Type_x = 'CarbonCopy';
        ccrecipientUser.RoutingOrder = 1;
        ccrecipientUser.Email =CCUser;
        ccrecipientUser.UserName = CCUser;
        ccrecipientUser.RequireIDLookup = false; 
        }
        
        envelope.Recipients = new DocuSignAPI.ArrayOfRecipient();
        envelope.Recipients.Recipient = new DocuSignAPI.Recipient[3];
        envelope.Recipients.Recipient[0] = recipient;
        if(recipient.Email != ccrecipient.Email){
            envelope.Recipients.Recipient[1] = ccrecipient;
        }
        if(String.isNotEmpty(CCUser)){
        if(recipient.Email!=ccrecipientUser.Email&&ccrecipient.Email!=ccrecipientUser.Email){
            envelope.Recipients.Recipient[2] = ccrecipientUser;
        }
        }
        
        
        // Tab
        DocuSignAPI.Tab tab1 = new DocuSignAPI.Tab();
        tab1.Type_x = 'SignHere';
        tab1.RecipientID = 1;
        tab1.DocumentID = 1;
        tab1.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab1.AnchorTabItem.AnchorTabString = 'By:';
        tab1.AnchorTabItem.XOffset = 50;
        //tab1.AnchorTabItem.YOffset = 100;
        //tab1.PageNumber = 1;
        //tab1.XPosition = 100;
        //tab1.YPosition = 100;

        
        DocuSignAPI.Tab tab2 = new DocuSignAPI.Tab();
        tab2.Type_x = 'DateSigned';
        tab2.RecipientID = 1;
        tab2.DocumentID = 1;
        tab2.AnchorTabItem = new DocuSignAPI.AnchorTab();
        tab2.AnchorTabItem.AnchorTabString = 'Date/Time:';
        tab2.AnchorTabItem.XOffset = 80;
        //tab2.XPosition = 100;
        //tab2.YPosition = 100;       
        envelope.Tabs = new DocuSignAPI.ArrayOfTab();
        envelope.Tabs.Tab = new DocuSignAPI.Tab[2];
        envelope.Tabs.Tab[0] = tab1;        
        envelope.Tabs.Tab[1] = tab2;        
        system.debug('tabs'+envelope.Tabs);
        System.debug('Calling the API');
        try {
            DocuSignAPI.EnvelopeStatus es 
            = dsApiSend.CreateAndSendEnvelope(envelope);
            envelopeId = es.EnvelopeID;
            gFRS_Ltng_Application__c appObj = new gFRS_Ltng_Application__c();
            if(appRec.EnvelopeId__c == ''){
                appObj.Docusign_Task_Check__c = True;
            }
            appObj.EnvelopeId__c = es.EnvelopeID;
            appObj.Id = sourceId;
            update appObj;
            try{
                    Attachment a       = new Attachment();
                    a.ParentId         = sourceId;
                    a.ContentType = '.pdf';
                    String fileContent = '';
                    
                    fileContent +='From: '+'No-ReplySignRequest <No-ReplySignRequest@demodocusign.roche.com>'+'\n';
                    fileContent +='To: '+recipient.Email+'\n';
                    
                    if(ccrecipient.Email == null){
                        fileContent +='CC: \n';  
                    }else{
                        fileContent +='CC: '+ccrecipient.Email+'\n';
                    }
                    
                    fileContent =fileContent.replace(')','').replace('(','');
                    fileContent +='Subject: '+Subject+'\n\n';
                    
                    
                    if(body != null){
                        fileContent += EncodingUtil.urlDecode(plainTextBody,'UTF-8');
                        //fileContent += EncodingUtil.base64Decode(base64Data);
                    } 

                    //fileContent+=EncodingUtil.urlDecode(email.htmlbody.stripHtmlTags(),'UTF-8');
                    
                    a.Body = Blob.valueOf(fileContent);  
                    a.Name = Subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                    
                    if(recipient.Email != null){
                        a.Description='Sent by ' +recipient.Email;
                    }else{                  
                        a.Description='test';
                        
                    }  
                    
                    insert a;                                
                }
                catch(Exception e){
                }
            system.debug('status'+es.EnvelopeID);

        } catch ( CalloutException e) {
            System.debug('Exception - ' + e );
            envelopeId = 'Exception - ' + e;
        }
      
    }
    
        public static Messaging.SingleEmailMessage createRemainderEmail(gFRS_Ltng_Application__c request,string  ToEmailAddress, EmailTemplate emailTemplate, Id senderId, String bcc) {
        string emailTemplateBody = emailTemplate.HtmlValue;
        string Recid = request.Id;
        string str = '<'+RecId.left(9)+'@'+RecId.right(9)+'>';
        String reff = 'References: 1*'+str+' CRLF'; 
        
        List<string> bCCEmails = new List<String>();       
        bCCEmails.add(bcc);
        GFRS_Ltng_OrgSettings__c gfrsOrgSettings = GFRS_Ltng_OrgSettings__c.getOrgDefaults();

        String requestReminderLink = String.isNotBlank(gfrsOrgSettings.Server_URL__c) ?
                                      gfrsOrgSettings.Server_URL__c + '/' + request.Id :
                                      System.Label.GFRS_Server_URL + '/' + request.Id;

        emailTemplateBody = 
        emailTemplateBody.replace('{!gFRS_Ltng_Application__c.Name}', request.Name)
        .replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}',request.Event_Program_Title__c)
        .replace('{!gFRS_Ltng_Application__c.Record_Type__c}',request.Record_Type__c)
        .replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}', 
            (request.Program_Start_Date_Min__c != null? String.valueOF(request.Program_Start_Date_Min__c) : '') )
        .replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}', 
            (request.Requested_Amount__c!= null? String.valueOF(request.Requested_Amount__c):'') )
        .replace('{!gFRS_Ltng_Application__c.Id}', request.Id )
        .replace('{!gFRS_Ltng_Application__c.Name}', requestReminderLink);

        emailTemplateBody += '\n\n' + '[ref:' + request.id + ']';
                                                
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(senderId!=null){
            mail.setOrgWideEmailAddressId(senderId);
        }                   
        mail.setToAddresses(new List<String>{ToEmailAddress});        
        mail.setHtmlBody(emailTemplateBody);
            mail.setTreatBodiesAsTemplate(true);
        //mail.setPlainTextBody(emailTemplateBody);      
        if(bcc != null){
            mail.setBccAddresses(bCCEmails);
        }        
        mail.setSubject(emailTemplate.Subject.replace('{!gFRS_Ltng_Application__c.Name}',request.Name));
        mail.setSaveAsActivity(false);   
               
        return mail;
    }
    @AuraEnabled
    public static void updateRecExternal(Id recordid,String newGA1String,String newGA2String,String newFA1String,String newFA2String,String newFA3String,String newFA4String){
        
        List<User> userRecs = new List<User>();
        Id newGA1 = newGA1String==''?null:Id.valueOf(newGA1String);
        Id newGA2 = newGA2String==''?null:Id.valueOf(newGA2String);
        Id newFA1 = newFA1String==''?null:Id.valueOf(newFA1String);
		Id newFA2 = newFA2String==''?null:Id.valueOf(newFA2String);
        Id newFA3 = newFA3String==''?null:Id.valueOf(newFA3String);
        Id newFA4 = newFA4String==''?null:Id.valueOf(newFA4String);
        
        if(newGA1 != null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newGA1];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
		if(newGA2!= null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newGA2];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
		if(newFA1!= null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newFA1];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
		if(newFA2!= null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newFA2];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
		if(newFA3!= null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newFA3];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
		if(newFA4!= null){
            User userRec = [SELECT Id, Name, Isactive FROM User WHERE Id = :newFA4];
            if(userRec.Isactive == false){
                userRec.Isactive = true;
                userRecs.add(userRec);
            }
        }
        
        
        if(userRecs.size() > 0){
            //update userRecs;
            gFRS_Ltng_Util_NoShare.updateUserRec(userRecs);
        }
        
        updateRecordAndShareExternal(recordid,newGA1String,newGA2String,newFA1String,newFA2String,newFA3String,newFA4String);
    }
     @future
    public static void updateRecordAndShareExternal(Id recordid,String newGA1String,String newGA2String,String newFA1String,String newFA2String,String newFA3String,String newFA4String){
        
        Boolean GA1 = false;
        Boolean GA2 = false;
        Boolean FA1 = false;
		Boolean FA2 = false;
        Boolean FA3 = false;
        Boolean FA4 = false;
		
        Id newGA1 = newGA1String==''?null:Id.valueOf(newGA1String);
        Id newGA2 = newGA2String==''?null:Id.valueOf(newGA2String);
        Id newFA1 = newFA1String==''?null:Id.valueOf(newFA1String);
		Id newFA2 = newFA2String==''?null:Id.valueOf(newFA2String);
		Id newFA3 = newFA3String==''?null:Id.valueOf(newFA3String);
		Id newFA4 = newFA4String==''?null:Id.valueOf(newFA4String);
        
        EmailTemplate et = [SELECT Name, Body, Description, DeveloperName, FolderId, HtmlValue, Subject, TemplateStyle, TemplateType
                                FROM EmailTemplate WHERE name = 'gFRS 2.0 UC-05 Approving / Rejecting Requests Approval Pending (Notify Approver)'].get(0);
        String bccEmailAddress='';
            GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
            if(myOrgCS.gFRS_Inbound_Email__c != null){
                   bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            }
         Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;
        
        List<gFRS_Ltng_Application__c> appRecLst=new List<gFRS_Ltng_Application__c>();
        List<GFRS_Ltng_Application__Share> shrForNewApprovers = new List<GFRS_Ltng_Application__Share>();
        Set<Id> delShrForOldApprovers = new Set<Id>();
        ProcessInstanceWorkitem PIWI = new ProcessInstanceWorkitem();
        appRecLst=[SELECT Id,Name,Record_Type__c,Program_Start_Date_Min__c,Requested_Amount__c,Event_Program_Title__c,Status__c,Sub_Status__c,Business_Approver__c,Business_Approver_2__c,Financial_Approver_1__c,Financial_Approver_2__c,Financial_Approver_3__c,Financial_Approver_4__c FROM gFRS_Ltng_Application__c where id =:recordid];
        
        if(!appRecLst.isEmpty()){
            
            //Add Read sharing
            if(newGA1 != null){
                
                if(appRecLst[0].Business_Approver__c !=null && appRecLst[0].Business_Approver__c!= newGA1)
                    delShrForOldApprovers.add( appRecLst[0].Business_Approver__c);
                appRecLst[0].Business_Approver__c = newGA1;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Business_Approver__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Grant Approver 1'){
                    GA1=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Business_Approver__c;
                    
                }
            }
			if(newGA2 != null){
                
                if(appRecLst[0].Business_Approver_2__c !=null && appRecLst[0].Business_Approver_2__c!= newGA2)
                    delShrForOldApprovers.add( appRecLst[0].Business_Approver_2__c);
                appRecLst[0].Business_Approver_2__c = newGA2;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Business_Approver_2__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Grant Approver 2'){
                    GA2=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Business_Approver_2__c;
                    update PIWI;
                }
            }
			if(newFA1 != null){
                
                if(appRecLst[0].Financial_Approver_1__c !=null && appRecLst[0].Financial_Approver_1__c!= newFA1)
                    delShrForOldApprovers.add( appRecLst[0].Financial_Approver_1__c);
                appRecLst[0].Financial_Approver_1__c = newFA1;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Financial_Approver_1__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Financial Approval 1'){
                    FA1=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Financial_Approver_1__c;
                    update PIWI;
                }
            }
			if(newFA2 != null){
                
                if(appRecLst[0].Financial_Approver_2__c !=null && appRecLst[0].Financial_Approver_2__c!= newFA2)
                    delShrForOldApprovers.add( appRecLst[0].Financial_Approver_2__c);
                appRecLst[0].Financial_Approver_2__c = newFA2;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Financial_Approver_2__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Financial Approval 2'){
                    FA2=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Financial_Approver_2__c;
                    update PIWI;
                }
            }
			if(newFA3 != null){
                
                if(appRecLst[0].Financial_Approver_3__c !=null && appRecLst[0].Financial_Approver_3__c!= newFA3)
                    delShrForOldApprovers.add( appRecLst[0].Financial_Approver_3__c);
                appRecLst[0].Financial_Approver_3__c = newFA3;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Financial_Approver_3__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Financial Approval 3'){
                    FA3=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Financial_Approver_3__c;
                    update PIWI;
                }
            }
            if(newFA4 != null){
                
                if(appRecLst[0].Financial_Approver_4__c !=null && appRecLst[0].Financial_Approver_4__c!= newFA4)
                    delShrForOldApprovers.add( appRecLst[0].Financial_Approver_4__c);
                appRecLst[0].Financial_Approver_4__c = newFA4;
                GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
                shrFundingRequest.ParentId = appRecLst[0].Id;
                shrFundingRequest.UserOrGroupId = appRecLst[0].Financial_Approver_4__c;
                shrFundingRequest.AccessLevel = 'Read';
                shrFundingRequest.RowCause = 'Manual';
                shrForNewApprovers.add(shrFundingRequest);  
                
                if(appRecLst[0].Sub_Status__c == 'Financial Approval 4'){
                    FA4=true;
                    PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: appRecLst[0].Id];
                    PIWI.ActorId = appRecLst[0].Financial_Approver_4__c;
                    update PIWI;
                }
            }
            
            try{
                gFRS_Ltng_Util_NoShare.updateAppRecord(appRecLst[0]);
                
                // ****** Start ****** Please don't delete this dummy email code. This will trigger email service *******
                if(appRecLst[0].Sub_Status__c != 'New' && appRecLst[0].Sub_Status__c != 'Compliance Approver'){
                    Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
                    string body     = 'RequestId:' + appRecLst[0].Id + '\n';
                    body            += 'ApproverId:' + PIWI.ActorId;
                    GFRS_Ltng_OrgSettings__c myOrgCS1 = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
                    
                    mail1.setSubject('Dummy email for Re-assigning approver for ' + appRecLst[0].Name);
                    mail1.setPlainTextBody(body);
                    mail1.setToAddresses(new List<String>{myOrgCS1.Reassign_Inbound_Email__c});
                    mail1.setTreatBodiesAsTemplate(true);
                    
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
                }
                // ****** End ***** Please don't delete this dummy email code. This will trigger email service *******
                
                if(appRecLst[0].Sub_Status__c != 'New' && appRecLst[0].Sub_Status__c != 'Compliance Approver'){
                    User user;
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                    String toEmailAddress;
                    if(GA1){
                        user = [Select u.email From User u Where u.Id = :newGA1 ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }else if(GA2){
                        user = [Select u.email From User u Where u.Id = :newGA2 ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }else If(FA1){
                        user = [Select u.email From User u Where u.Id = :newFA1 ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }else If(FA2){
                        user = [Select u.email From User u Where u.Id = :newFA2 ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }else If(FA3){
                        user = [Select u.email From User u Where u.Id = :newFA3 ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }else If(FA4){
                        user = [Select u.email From User u Where u.Id = :newFA4 ];
                        toEmailAddress=user.email;                    
                        mail=createRemainderEmail(appRecLst[0],toEmailAddress,et, senderId, bccEmailAddress);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }
                     
                }
            }
            catch(exception e){  
                system.debug('@@@:::Msg:::'+e.getMessage());
                system.debug('@@@LineNum:::'+e.getLineNumber());
                AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                system.debug('auraExceptionObj'+auraExceptionObj);
                throw auraExceptionObj; 
                
            }  
            
        }
        if (!shrForNewApprovers.isEmpty()) {
            System.debug('****New Shr Lst Size:::'+shrForNewApprovers.size());
            Database.SaveResult [] srList = gFRS_Ltng_Util_NoShare.insertSharingRecs(shrForNewApprovers);
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
        }   if(!delShrForOldApprovers.isEmpty() && appRecLst[0].Id!=null){
            
            System.debug('**** Shr Del Lst Size:::'+delShrForOldApprovers.size());
            List<GFRS_Ltng_Application__Share> delListShr = [SELECT Id from GFRS_Ltng_Application__Share where ParentId =: appRecLst[0].Id AND UserOrGroupId IN:delShrForOldApprovers];
            if(!delListShr.isEmpty()){
                Database.delete(delListShr, false); 
            }
        }     
    }  
    @AuraEnabled
    public static User fetchUserID(String userName){
        String str = userName;
        String unixID = str.substring(str.indexOf('(')+1, str.indexOf(')'));
       return [Select Id,Name FROM User WHERE External_ID_gne__c =:unixID ];
        
    }
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchApplicationRec(String recordid){
        gFRS_Ltng_Application__c appRecLst=[SELECT Id,Name,Record_Type_Name__c,Event_Program_Title__c,Status__c,Sub_Status__c,Legal_Approver__c,Business_Approver__c,Business_Approver_2__c,Financial_Approver_1__c,Financial_Approver_2__c,Financial_Approver_3__c,Financial_Approver_4__c FROM gFRS_Ltng_Application__c where id =:recordid];
        return appRecLst;
    }
}