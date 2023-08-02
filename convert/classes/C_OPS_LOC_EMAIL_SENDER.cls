public with sharing class C_OPS_LOC_EMAIL_SENDER {

    public C_OPS_LOC_REQUEST__C myRequest; 
    private C_OPS_LOC_REQUEST_STAGING__C myStgRequest;  
    
    public string email_to {get;set;}
    public string email_cc {get;set;}
    public string email_bcc {get;set;}
    public string email_body {get;set;}
    public string email_subject {get;set;}
    public string email_from {get;set;}
    public string email_reply_to {get;set;}
    public string attachment_name {get;set;}
    public sObjectType theType{get;set;}
    
    public boolean displayAttachment {get;set;}
    public boolean displayAddAttachment {get;set;}
    public string  templateSelection{get;set;}
    
    public boolean sendAsPlainText {get;set;}
    public boolean assignmentChecked {get;set;}
    
    public Attachment pdfSummary {get;set;}
    
    
    public string getPreviewStyle{
        
        get{
            
            if(sendAsPlainText == FALSE){
                
                return 'block'; 
            }
            
            else {
                
                return 'none'; 
            }
        }
        
        set;
    }
    
    private Boolean emptyString(String s){
        if(s==null || s.trim().length()<=0) return true;
        else return false;
    }
    
    public string getRequestNumber(){
        
        return myRequest.LOC_Request_Number__c; 
    }
    
    public C_OPS_LOC_EMAIL_SENDER(ApexPages.StandardController stdController){
        
        theType = stdController.getRecord().getsObjectType();
        id theID = stdController.getId(); 
        
        if(theType == C_OPS_LOC_REQUEST__C.sObjectType){
            
            myRequest = [SELECT id, NAME, email__c, LOC_REQUEST_NUMBER__C, signer_first_name__c, signer_last_name__C, Assign_To__c from C_OPS_LOC_REQUEST__C where id =: theID]; 
        }
        
        else if(theType == C_OPS_LOC_REQUEST_STAGING__C.sObjectType){
            
            myStgRequest = [SELECT id, NAME, email__c, LOC_REQUEST_NUMBER__C, signer_first_name__c, signer_last_name__C from C_OPS_LOC_REQUEST_STAGING__C where id =: theID]; 
        }
        
        pdfSummary = [SELECT id, NAME, body, bodyLength FROM Attachment WHERE name like '%.pdf' AND parentID =: theId]; 
        
        attachment_name = pdfSummary.Name; 
        
        if(!emptyString(attachment_name)){
            
            displayAttachment = TRUE; 
            displayAddAttachment = FALSE; 
        }
        
        else{
            
            displayAddAttachment = TRUE; 
        }
        
        C_Ops_LOC_App_Properties__c properties=[select replay_to__c, from__c from C_Ops_LOC_App_Properties__c where active__c=true limit 1];
      
        if(properties!=null) {
            email_from =properties.from__c;
            email_reply_to =properties.replay_to__c;
        }
        else {
            email_from = 'contractops@gene.com'; 
            email_reply_to = 'contractops@gene.com';
        }
        
        sendAsPlainText = FALSE; 
    }
    
    //
    //
    //BEGIN TEMPLATE LOADING CODE
    //
    //
    public pageReference loadNoTemplate(){
        
        email_subject = ''; 
        //email_from = ''; 
        email_body = ''; 
        //email_reply_to = '';
        
        return ApexPages.currentPage(); 
    }
    
    public pageReference loadFollowUp(){
        
        emailTemplate theTemplate = [SELECT subject, htmlValue, body from emailTemplate where name = 'Follow-Up on LOC Submission']; 
        
        email_to = myRequest.Email__c;
        email_subject = resolveMergeFields(theTemplate.subject); 
        //email_from = 'contractops@gene.com'; 
        email_body = resolveMergeFields(theTemplate.htmlValue); 
        //email_reply_to = replyToAddress();
        
        return ApexPages.currentPage(); 
    }
    
    public pageReference loadProcessed(){
        
        emailTemplate theTemplate = [SELECT subject, htmlValue, body from emailTemplate where name = 'Inform on LOC Submission Status - Processed']; 
        
        email_to = myRequest.Email__c; 
        email_subject = resolveMergeFields(theTemplate.Subject); 
       // email_from = 'contractops@gene.com'; 
        email_body = resolveMergeFields(theTemplate.HtmlValue); 
        //email_reply_to = replyToAddress(); 
        
        return ApexPages.currentPage(); 
    }
    
    public pageReference loadUnableToProcess(){
        
        emailTemplate theTemplate = [SELECT subject, htmlValue, body from emailTemplate where name = 'Inform on LOC Submission Status - Unable to Process']; 
        
        email_to = myRequest.Email__c; 
        email_subject = resolveMergeFields(theTemplate.Subject); 
        //email_from = 'contractops@gene.com'; 
        email_body = resolveMergeFields(theTemplate.HtmlValue); 
        //email_reply_to = replyToAddress(); 
        
        return ApexPages.currentPage();  
    }
    
    //
    //
    //END TEMPLATE LOADING CODE
    //
    //
    
    public pageReference sendEmail(){
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>(); 
        
        boolean emailError = FALSE; 
        string  errorText=''; 
        
        //required fields for an email, to, subject, body
        
        if(emptyString(email_to)){
            
            emailError = TRUE; 
            errorText += 'An email requires a recipient in order to send.';  
        } 
        if(emptyString(email_body)){
            
            emailError = TRUE; 
            errorText += '<br/>An email requires a body in order to send.'; 
        } 
        if(emptyString(email_subject)){
            
            emailError = TRUE; 
            errorText += '<br/>An email requires a subject in order to send.'; 
        }
        
        if(emailError){
        
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,errorText);             
            ApexPages.addMessage(errorMsg);
            
            return ApexPages.currentPage(); 
        }

        else{
            
            message.setSenderDisplayName(email_from); 
            
            message.setToAddresses(splitAddresses(email_to)); 
            
            if(!emptyString(email_cc)){
                
                message.setCcAddresses(splitAddresses(email_cc));
            }
             
            if(!emptyString(email_bcc)){
                
                message.setBccAddresses(splitAddresses(email_bcc));
            }
             
            message.setReplyTo(email_reply_to); 
            message.setSubject(email_subject); 
            
            if(sendAsPlainText){
                
                message.setPlainTextBody(email_body);
            } else{
                
                message.setHtmlBody(email_body);
            }
            
            List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>(); 
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            if(!emptyString(attachment_name)){
                
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment(); 
                efa.setFileName(attachment_Name); 
                efa.setBody(pdfSummary.body); 
                attachments.add(efa); 
                
                message.fileattachments = attachments; 
            }
            
            emails.add(message); 
            
            Try{
                
                results = Messaging.sendEmail(emails);
            }
            
            Catch(exception e){
                
                ApexPages.Message sendError = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()); 
                ApexPages.addMessage(sendError); 
                
                return ApexPages.currentPage(); 
            }
            
            for(Messaging.SendEmailResult s : results){
                
                if(s.isSuccess()){
                    
                    trackEmailResult(); 
                    
                    PageReference viewRecord; 
                    
                    if(theType == C_OPS_LOC_REQUEST__C.sObjectType){
                        
                       viewRecord = (new ApexPages.StandardController(myRequest)).view();
                    } else{
                        
                       viewRecord = (new ApexPages.StandardController(myStgRequest)).view(); 
                    }
                    
                    return viewRecord; 
                }
                
                else{
                    
                    ApexPages.Message sendError = new ApexPages.Message(ApexPages.Severity.ERROR,s.getErrors()[0].getMessage()); 
                    ApexPages.addMessage(sendError); 
                    
                    return ApexPages.currentPage(); 
                }
            }  
            
            return null;
        }
    }
    
    public List<String> splitAddresses(string addressList){
        
        List<String> parsedAddresses = new List<String>(); 
        
        parsedAddresses = addressList.split(','); 
        
        return parsedAddresses;
    }
    
    public void trackEmailResult(){
        
        //if we successfully sent our email, add all our data to the tracker object
        C_OPS_LOC_EMAIL_TRACKER__C emailTracker = new C_OPS_LOC_EMAIL_TRACKER__C(); 
                    
        emailTracker.Address__c = email_to; 
        
        if(!emptyString(attachment_name)){
            
            emailTracker.attachment_included__c = TRUE; 
            emailTracker.Attachment_Name__c = attachment_name; 
        } else{
            
            emailTracker.Attachment_Included__c = FALSE; 
            emailTracker.Attachment_Name__c = ''; 
        }
        
        emailTracker.BCC_Addresses__c = email_bcc; 
        emailTracker.CC_Addresses__c = email_cc; 
        emailTracker.Body__c = email_body; 
        emailTracker.Sent_On__C = datetime.now(); 
        emailTracker.Sent_By__c = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        emailTracker.Subject__c = email_subject; 
        
        if(theType == C_OPS_LOC_REQUEST__C.sObjectType){
            
            emailTracker.C_Ops_LOC_Submission__c = myRequest.Id; 
        } //else{
            
           // emailTracker.C_Ops_LOC_Submissions_Staging__c = myStgRequest.Id; 
       // }
        
         CommitChange cc=new CommitChange();
        cc.insertEmailTracker(emailTracker);
        //insert emailTracker; 
        
        return; 
    }
    
    public pageReference removeAttachment(){
        
        if(emptyString(attachment_name)){
            
            //do nothing since there isn't an attachment
        }
        
        else{
            
            pdfSummary = new Attachment(); 
            attachment_name = NULL; 
            
            displayAttachment = FALSE; 
            displayAddAttachment = TRUE; 
        }
        
        return ApexPages.currentPage(); 
    }
    
    public pageReference addPDFAttachment(){
        
        string theID;
        
        if(theType == C_OPS_LOC_REQUEST__C.sObjectType){
            
           theID = myRequest.ID; 
        } else{
            
           theID = myStgRequest.ID;  
        }
        
        pdfSummary = [SELECT id, NAME, body, bodyLength FROM Attachment WHERE name like '%.pdf' AND parentID =: theID];
        
        attachment_name = pdfSummary.Name; 
        
        displayAttachment = TRUE; 
        displayAddAttachment = FALSE;
        
        return ApexPages.currentPage(); 
    }
    
    public pageReference refreshPage(){
        
        return ApexPages.currentPage(); 
    }
    
    public pageReference saveBodyChanges(){
        
        //if tihs is a regular request
        PageReference c_ops_loc_email_center = new PageReference('/apex/c_ops_loc_email_center'); 
        return c_ops_loc_email_center; 
    }
    
    public pageReference editEmailBody(){
        
        PageReference c_ops_loc_email_body_edit = new PageReference('/apex/c_ops_loc_email_body_edit'); 
        return c_ops_loc_email_body_edit; 
    }
    
    public pageReference cancel(){
        
        PageReference viewRecord;
        
        if(theType == C_OPS_LOC_REQUEST__C.sObjectType){
            
           viewRecord = (new ApexPages.StandardController(myRequest)).view();
        } else{
            
           viewRecord = (new ApexPages.StandardController(myStgRequest)).view(); 
        }
 
        return viewRecord; 
    }
    
    public pageReference backToRecord(){
        
        PageReference viewRecord;
        viewRecord = (new ApexPages.StandardController(myRequest)).view();
        return viewRecord;
    }
    
    public pageReference checkAssignment(){
        
        assignmentChecked = TRUE; 
        
        if(UserInfo.getUserId() != myRequest.Assign_To__c && assignmentChecked == FALSE){
            
            return ApexPages.CurrentPage(); 
            
        } else if (UserInfo.getUserId() != myRequest.Assign_To__c && assignmentChecked == TRUE){
            
            return NULL; 
        }
        
        PageReference emailSender = new PageReference('/apex/c_ops_loc_email_center'); 
        emailSender.setRedirect(false); 
        return emailSender; 
    }
    
    public pageReference viewPDF(){
        
        PageReference viewPDF; 
        
        viewPDF = new PageReference('/servlet/servlet.FileDownload?file=' + pdfSummary.Id);
        return viewPDF; 
    }
    
    public List<SelectOption> getSelectOptions(){
        
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('NONE', '--None--')); 
        options.add(new SelectOption('FOLLOWUP', 'Follow-Up on LOC Submission')); 
        options.add(new SelectOption('LOADPROCESSED', 'Inform on LOC Submission Status - Processed')); 
        options.add(new SelectOption('LOADUNPROCESSED', 'Inform on LOC Submission Status - Unable to Process')); 
        
        return options;
    }
    
    public void templateChange(){
        
        if(templateSelection == 'FOLLOWUP'){
            
            loadFollowUp(); 
        } else if(templateSelection == 'LOADPROCESSED'){
            
            loadProcessed(); 
        } else if(templateSelection == 'LOADUNPROCESSED'){
            
            loadunableToProcess(); 
        } else{
            
            loadNoTemplate(); 
        }
        
        return; 
    }
    
    public string resolveMergeFields(string target){
        
        string tempString;
        string tempString1; 
        string result;
        
        tempString = mergeRequestNumber(target); 
        tempString1 = mergeFirstName(tempString); 
        tempString = mergeLastName(tempString1);
        tempString1 = dropExtraTags(tempString); 

        result = tempString1; 
        
        return result; 
    }
    
    public string mergeRequestNumber(string s){
        
        string requestNumber = '<<SFDC Generated Confirmation Number>>'; 
        string requestNumber2 = '<<SFDC Generated confirmation #>>';
        
        string result; 
        
        if(s.contains(requestNumber)){
            
            result = s.replace(requestNumber, myRequest.LOC_Request_Number__c);
            
        } else if(s.contains(requestNumber2)){
            
            result = s.replace(requestNumber2, myRequest.LOC_Request_Number__c);
        }
        
        if(result == NULL){
            
            return s; 
        }
        
        else{
            
            return result; 
        }
    }
    
    public string mergeFirstName(string s){
        
        string firstName = '<<First Name>>'; 
        
        string result; 
        
        if(s.contains(firstName)){
            
            result = s.replace(firstName, myRequest.Signer_First_Name__c); 
        }
        
        if(result == NULL){
            
            return s; 
        }
        
        else{
            
            return result; 
        } 
    }
    
    public string mergeLastName(string s){
        
        string mergeLastName = '<<Last Name>>'; 
        
        string result;
        
        if(s.contains(mergeLastName)){
            
            result = s.replace(mergeLastName, myRequest.Signer_Last_Name__c); 
        }
        
        if(result == NULL){
            
            return s; 
        }
        
        else{
            
            return result; 
        } 
    }
    
    public string dropExtraTags(string st){
        
        string regEx = '[<]{2}[a-zA-z0-9 ]*[>]{2}'; 

        string result = st.replaceAll(regEx, ''); //replace all non matching merge tags with empty strings
        
        return result;
    }
     private without sharing class CommitChange{
        public commitChange(){}
        public void insertEmailTracker(C_OPS_LOC_EMAIL_TRACKER__C emailTracker){
            insert emailTracker; 
        }
        
    }
    

 /*   public string replyToAddress(){
        
        Organization org = [select IsSandbox from Organization where Id =: UserInfo.getOrganizationId()]; 
        
        if(org.IsSandbox){
            
            return 'LOC_Sandbox-d@gene.com'; 
        } else{
            
            return 'contractops@gene.com'; 
        }
    }*/
}