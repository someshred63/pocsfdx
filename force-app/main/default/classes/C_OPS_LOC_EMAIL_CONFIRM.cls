public with sharing class C_OPS_LOC_EMAIL_CONFIRM {

    public C_OPS_LOC_REQUEST__C theRequest;
    public C_Ops_LOC_Request_Staging__C stageRequest; //if we get a staging object instead of a regular object
    public Attachment att = new Attachment(); 
    public boolean isStageRequest; 
    
    //email tracker variables
    public string email_to {get;set;}
    public string attachment_name {get;set;}
    public string email_bcc {get;set;}
    public string email_cc {get;set;}
    public string email_body {get;set;}
    public sObjectType theType {get;set;}
    public string email_subject {get;set;}
    
    private string email_reply_to, email_from;
    
    public C_OPS_LOC_EMAIL_CONFIRM( C_OPS_LOC_REQUEST__C r ){
        
        theRequest = r;
        
        isStageRequest = FALSE;
        
        C_Ops_LOC_App_Properties__c properties=[select replay_to__c, from__c from C_Ops_LOC_App_Properties__c where active__c=true limit 1];
      
        if(properties!=null) {
            email_from =properties.from__c;
            email_reply_to =properties.replay_to__c;
        }
        else {
            email_from = 'contractops@gene.com'; 
            email_reply_to = 'contractops@gene.com';
        }
    }
    
    public C_OPS_LOC_EMAIL_CONFIRM( C_Ops_LOC_Request_Staging__C stg ){
        
        stageRequest = stg; 
        
        isStageRequest = TRUE; 
        
        C_Ops_LOC_App_Properties__c properties=[select replay_to__c, from__c from C_Ops_LOC_App_Properties__c where active__c=true limit 1];
      
        if(properties!=null) {
            email_from =properties.from__c;
            email_reply_to =properties.replay_to__c;
        }
        else {
            email_from = 'contractops@gene.com'; 
            email_reply_to = 'contractops@gene.com';
        }
    }
    
    public void sendEmailConfirmation(){
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        
        List<STring> address = new List<String>();
        List<String> documentID = new List<String>(); 
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>(); 
        
        if(!isStageRequest){
            Integer day = theRequest.Submission_Date__c.day();
            Integer month= theRequest.Submission_Date__c.month();
            Integer year = theRequest.Submission_Date__c.year();
            
            String plainTextBody = 'Dear ' + theRequest.Signer_First_Name__c + ' ' + theRequest.Signer_Last_Name__c + ', \n\n' 
                + 'Thank you for submitting a Genentech Letter of Commitment (LOC). We have received ' + theRequest.Participant_s_Name__c + '\'s LOC which was submitted on ' + month+'/'+ day+'/'+year +'.'
                + '\n\n' + 'The LOC submission confirmation number is: ' + theRequest.LOC_Request_Number__c + '. Please maintain this number for future reference.\n\n' 
                + 'Your LOC submission will be reviewed within 3 business days from the date it was received. \n\n'
                + 'Thank you, \n\n Genentech Contract Operations Team \n Contact Us: (877) 336-8454 | contractops@gene.com';
            
            address.Add(theRequest.Email__c); 
            
            email.setSubject('Genentech Letter of Commitment - Received (' + theRequest.LOC_Request_Number__c + ')'); 
            email.setToAddresses(address); 
            email.setPlainTextBody(plainTextBody);
            email.setReplyTo(email_reply_to);
            email.setSenderDisplayName(email_from); 
            
            emails.Add(email); 
            
            List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
            
            attachment_name = ''; 
            email_to = theRequest.Email__c; 
            email_bcc = '';
            email_cc = '';
            email_body = PlainTextBody; 
            email_subject = 'Genentech Letter of Commitment - Received (' + theRequest.LOC_Request_Number__c + ')';
            
            
            results = Messaging.sendEmail(emails);
            
            theRequest.Confirmation_Email_Sent__c = TRUE; 
            theRequest.Confirmation_Email_Sent_On__c = datetime.now();
            
            //update theRequest;    
            CommitChange cc=new CommitChange();
            cc.updateRequest(theRequest);
            
        } else {
            Integer day = stageRequest.Submission_Date__c.day();
            Integer month= stageRequest.Submission_Date__c.month();
            Integer year = stageRequest.Submission_Date__c.year();
            String plainTextBody = 'Dear ' + stageRequest.Signer_First_Name__c + ' ' + stageRequest.Signer_Last_Name__c + ', \n\n' 
                + 'Thank you for submitting a Genentech Letter of Commitment (LOC). We have received ' + stageRequest.Participant_s_Name__c + '\'s LOC which was submitted on ' + month+'/'+ day+'/'+year +'.' 
                + '\n\n' + 'The LOC submission confirmation number is: ' + stageRequest.LOC_Request_Number__c + '. Please maintain this number for future reference.\n\n' 
                + 'Your LOC submission will be reviewed within 3 business days from the date it was received. \n\n'
                + 'Thank you, \n\n Genentech Contract Operations Team \n Contact Us: (877) 336-8454 | contractops@gene.com'; 
            
            address.Add(stageRequest.Email__c); 
            
            email.setSubject('Genentech Letter of Commitment - Received (' + stageRequest.LOC_Request_Number__c + ')'); 
            email.setToAddresses(address); 
            email.setPlainTextBody(plainTextBody);
            email.setReplyTo(email_reply_to);
            email.setSenderDisplayName(email_from); 
            emails.Add(email); 
            
            List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();
            
            attachment_name = ''; 
            email_to = stageRequest.Email__c; 
            email_bcc = '';
            email_cc = '';
            email_body = PlainTextBody; 
            email_subject = 'Genentech Letter of Commitment - Received (' + stageRequest.LOC_Request_Number__c + ')';
            
            
            results = Messaging.sendEmail(emails);
            
            stageRequest.Confirmation_Email_Sent__c = TRUE; 
            stageRequest.Confirmation_Email_Sent_On__c = datetime.now();
            
            //update stageRequest;
            CommitChange cc=new CommitChange();
            cc.updateStagingRequest(stageRequest);
        }
        
        trackEmailResult(); 
       
        return; 
    }
    
    private without sharing class CommitChange{
        public commitChange(){}
        public void updateRequest(C_OPS_LOC_REQUEST__C theRequest){
            update theRequest; 
        }
        public void updateStagingRequest(C_Ops_LOC_Request_Staging__C stageRequest){
            update stageRequest; 
        }
        public void insertEmailTracker(C_OPS_LOC_EMAIL_TRACKER__C emailTracker){
            insert emailTracker; 
        }
        
    }
    
    private Boolean emptyString(String s){
        if(s==null || s.trim().length()<=0) return true;
        else return false;
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
        emailTracker.Sent_By__c = 'Letter of Commitment Online Portal'; 
        emailTracker.Subject__c = email_subject; 
        
        if(!isStageRequest){
            
            emailTracker.C_Ops_LOC_Submission__c = theRequest.Id; 
        } //else{
            
       //     emailTracker.C_Ops_LOC_Submissions_Staging__c = stageRequest.Id; 
        //}
        
        //insert emailTracker; 
        CommitChange cc=new CommitChange();
        cc.insertEmailTracker(emailTracker);
        
        return; 
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