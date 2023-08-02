/**********************************************************************
Purpose: GCS_Spoilage_Request_EmailCtlr class is used to send 
	 email to customer regarding customer correction, forward request to
	 quality team and adverse event team in Lighting Experience 
=======================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL
1.0      Raheem       15/10/2020      INITIAL DEVELOPMENT 

***********************************************************************/

public class GCS_Spoilage_Request_EmailCtlr {

/***Description: get selected email template content
* param:selectedTemplate
**/ 
 @AuraEnabled
public static EmailtemplateContentWrapper getEmailtemplateContent(string selectedTemplate){
    EmailtemplateContentWrapper  etWrap = new EmailtemplateContentWrapper();
    if(String.isNotBlank(selectedTemplate)){
        List<EmailTemplate> templates = [select id, Name, body, subject, DeveloperName, HtmlValue from EmailTemplate where DeveloperName =:selectedTemplate];
        
        List<ChannelOps_App_Property__c> propertyList = [select Adverse_Event_Email_Address__c, QA_Email_Address__c from ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
    
        if(propertyList !=null && !propertyList.isEmpty()){
            if(selectedTemplate == 'Forward_Request_to_Genentech_Adverse_Events_Team'){
                etWrap.toAddress = propertyList[0].Adverse_Event_Email_Address__c; 
            }else if(selectedTemplate == 'ChannelOps_Forward_Request_to_Genentech_Quality_Team'){
                etWrap.toAddress = propertyList[0].QA_Email_Address__c ;
            }
        }
        if(templates !=null && !templates.isEmpty()){
            etWrap.tempSubject = templates[0].subject;
            etWrap.tempBody = templates[0].HtmlValue;
        }
    }
	return etWrap;
}
 /***Description: get email template content for Correction
* param:spoilReqId
**/ 
 @AuraEnabled
public static EmailtemplateContentWrapper getEmailTemplateForCorrection(string spoilReqId){
	
	 EmailtemplateContentWrapper  etWrap = new EmailtemplateContentWrapper();
	
	List<ChannelOps_Spoilage_Request__c> spoilageRequest = [Select Id, Name, Contact_Name__c, Submission_Date__c,
																	  Contact_Email__c, Status__c,License_Num__c,
																	  PDF_Attachment_ID__c
															   From ChannelOps_Spoilage_Request__c Where Id =: spoilReqId];
	if(!spoilageRequest.isEmpty()){
	   etWrap.spoilageRequestName =spoilageRequest[0].Name;
	}
	
	List<EmailTemplate> templateList = [select id, Name, body, subject, HtmlValue,DeveloperName From emailtemplate where DeveloperName = 'ChannelOps_Spoilage_Customer_Correction_Email' ];
  
	if(!templateList.isEmpty() && !spoilageRequest.isEmpty()){
		 etWrap.tempSubject=templateList[0].subject.replace('{!ChannelOps_Spoilage_Request__c.Name}', spoilageRequest[0].Name);
		 etWrap.tempBody=replaceFieldInEmailBody(templateList[0].HtmlValue, spoilageRequest[0]);  
		 etWrap.toAddress=(String.isNotBlank(spoilageRequest[0].Contact_Email__c)) ? spoilageRequest[0].Contact_Email__c: '';
	}
	
	return etWrap;
}
	private static String replaceFieldInEmailBody(String body, ChannelOps_Spoilage_Request__c spoilageRequest){
  
		if(String.isNotBlank(body) && spoilageRequest != null){
		
		body = (String.isNotBlank(spoilageRequest.Contact_Name__c)) ? body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Name__c}', spoilageRequest.Contact_Name__c) : body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Name__c}', 'Customer');
		body = (String.isNotBlank(spoilageRequest.Contact_Email__c)) ? body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Email__c}', spoilageRequest.Contact_Email__c) : body.replace('{!ChannelOps_Spoilage_Request__c.Contact_Email__c}', '');
		body = (String.isNotBlank(spoilageRequest.License_Num__c)) ? body.replace('{!ChannelOps_Spoilage_Request__c.License_Num__c}', spoilageRequest.License_Num__c) : body.replace('{!ChannelOps_Spoilage_Request__c.License_Num__c}', '');
		body = body.replace('{!ChannelOps_Spoilage_Request__c.Submission_Date__c}', ChannelOps_SpoilageRequest_Util.formatDateInMMDDYYYY(spoilageRequest.Submission_Date__c));
		body = body.replace('{!ChannelOps_Spoilage_Request_Site_URL}', Label.ChannelOps_Spoilage_Request_Site_Domain_URL +'/ChannelOps_SpoilageRequest_Selection');
		body = body.replace('{!ChannelOps_Spoilage_Request__c.Name}', spoilageRequest.Name);
	}
	System.debug('----------'+body);
	return body;
}
    /***Description: send email 
        * params: attachId = Attachment Id,emailTemplate= Selected Email Temaple for email request
        toAddress,bcc = To Address and Bcc for Both email request and Send to Customer Correction
        requestId = Spoilage Request ID,emailForm= boolean value for email request and Send to Customer Correction,
        subject= Send to Customer Correction email subject ,ccAdress= Send to Customer Correction email ccAdress
        content = Send to Customer Correction email body
    **/
    @AuraEnabled
    Public static void sendEmailForms(string attachId, String emailTemplate , string toAddress, string requestId, string bcc,
								  string emailForm,string subject,string ccAdress,string content) {
			  
        List <String> sendTo = new  List <String>();
        List <String> sendBcc = new List <String>();
        List <String> sendcc = new List <String>();  	 
        EmailTemplate et = new EmailTemplate();
                                            
        if(String.isNotBlank(toAddress)){
            sendTo = toAddress.split(';');
        }
        if(String.isNotBlank(bcc)){
            sendBcc = bcc.split(';');         
        }
        if(String.isNotBlank(ccAdress)){
            sendcc=ccAdress.split(';');
        }
                                
        List<Attachment> attachmentList  = null;
                                
        if(attachId != null){ 
            attachmentList = [select id, body, name from Attachment where id=:attachId Order by LastModifiedDate DESC limit 1];
        } 
        // Create the email attachment
        Messaging.EmailFileAttachment efa = null;
                                
        if(attachmentList != null && !attachmentList.isEmpty()){
            efa = new Messaging.EmailFileAttachment();     
            efa.setFileName(attachmentList[0].name );
            efa.setBody(attachmentList[0].body);
        }
        
        // Define the email 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
        if(emailForm == 'true' && String.isNotBlank(emailTemplate) && emailTemplate != 'None'){ 
            //only to make email template works well
            // Contact c=[select id, name, email from Contact where name='Lwo Monitor' limit 1];
            List<Contact> contactList = [SELECT ID FROM Contact WHERE Name =: ChannelOps_Constants.DEFAULT_CONTACT_NAME AND 
                                            RecordType.DeveloperName =: ChannelOps_Constants.GCS_CONTACT_RECORDTYPE_DEV_NAME LIMIT 1];
            if(contactList == null || contactList.isEmpty()){
                contactList = [SELECT ID FROM Contact WHERE Email != null AND 
                                    RecordType.DeveloperName =: ChannelOps_Constants.GCS_CONTACT_RECORDTYPE_DEV_NAME LIMIT 1];
            }
            if(!contactList.isEmpty()){
                mail.setTargetObjectId(contactList[0].Id);
            }
            List<EmailTemplate> templateList = [SELECT Id, name,Subject,HtmlValue, body FROM EmailTemplate WHERE DeveloperName =:emailTemplate ];
            if(!templateList.isEmpty()){
                et = templateList[0];
                mail.setTemplateId(et.Id);
            }                
        }else{                         
            mail.setHtmlBody(content);
            mail.setSubject(subject);
        }
                                
        mail.setTreatTargetObjectAsRecipient(false);
        mail.setWhatId(requestId);
        mail.setToAddresses(sendTo);
                                            
        if(sendBcc!=null && sendBcc.size()>0){
                mail.setBccAddresses(sendBcc);
        }
            if(sendcc != null && sendcc.size()>0){
            mail.setCcAddresses(sendcc);
        }
            
        //set from email address to org wide email address
        OrgWideEmailAddress orgWideAddress = null;
                                
        try{
            string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            
            orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreplyco-d@gene.com'];
            
            if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
                orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'gneforms-d@gene.com'];
            }
            
        } catch (Exception ex){
            system.debug('OrgWide address or configuration not found');
            throw new AuraHandledException('OrgWide address or configuration not found');
            
        }
        if(orgWideAddress != null){
            mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }                
        
        //set reply to to ChannelOpsCasesSendtemplatereply email service
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
        
        if(efa != null){
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        }
        
        // Sends the email 
        try{
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});  
        }catch(Exception e){
            System.debug('failed to send spoilage request confirmation email due to: '+e.getMessage());
            throw new AuraHandledException('failed to send spoilage request confirmation email due to: '+e.getMessage());
        }
        
        //log outbound emails
        GNE_Channel_Ops_Email_Tracker__c emailTracker =new GNE_Channel_Ops_Email_Tracker__c();
        emailTracker.Send_By__c=UserInfo.getUserId();
        emailTracker.From_Address__c =orgWideAddress.Address ;
        emailTracker.ChannelOps_Spoilage_Request__c=requestId;
                                
        if(emailForm == 'false'){ 
            emailTracker.Use_email_Tempate__c=false;
            emailTracker.Subject__c=subject;
            emailTracker.Body__c=content;
            emailTracker.CC__c='';
            for(String ccEmail: sendcc ) {
                emailTracker.CC__c+=ccEmail+',';
            }
        
        }else{
            emailTracker.Use_email_Tempate__c = true;
            emailTracker.Email_Template_Name__c = (et != null) ? et.name : ''; 
        }
        
        emailTracker.Time_Stamp__c=System.now();
        emailTracker.To_Address__c='';
                                
        for(String temp: sendTo) {
            emailTracker.To_Address__c+=temp+',';
        }
                                
        emailTracker.BCC__c = '';
                                
        for(String temp: sendBcc) {
            emailTracker.BCC__c += temp+',';
        }
                                
        if(attachmentList != null && !attachmentList.isEmpty()){
            emailTracker.Attachments__c=attachmentList[0].name;
        }
                                
        try{
            if(emailForm == 'false'){
                updateStatusOnCustomerCorrectionEmail(requestId);
            }
            insert emailTracker;
            
        }catch(Exception e){
            System.debug('Log email failed due to: '+e.getMessage());
            throw new AuraHandledException('Log email failed due to: '+e.getMessage());
        }
    } 

    /***Description: update the Status On Customer Correction Email send
    * param:id= spoilage Request Id
    **/ 
    @AuraEnabled
    Public static void updateStatusOnCustomerCorrectionEmail(string requestId){
        
        List<ChannelOps_Spoilage_Request__c> spoilageRequest = [Select Id, Name,Status__c From ChannelOps_Spoilage_Request__c Where Id =: requestId];                               
        
        if(!spoilageRequest.isEmpty()){
            for(ChannelOps_Spoilage_Request__c request : spoilageRequest ){
                request.Status__c = (request.Status__c != ChannelOps_Constants.SPOILAGE_STATUS_DRAFT) ?  ChannelOps_Constants.SPOILAGE_STATUS_PENDING_CUST_CORRECTION : request.Status__c;
            }
        update spoilageRequest;            
        }
        
              
    }
    /***Description: get Attachment
    * param:id= spoilage Request Id
    **/ 
    @AuraEnabled
    public static Attachment getAttachment(string spoilReqId){
        
        List<Attachment> att =[SELECT Id, Name,ContentType,LastModifiedDate FROM Attachment WHERE parentId=: spoilReqId LIMIT 1];
        
        if(!att.isEmpty()){
            return att[0]; 
        }else{
            return null;
        }
        
        
    }
	
      public class EmailtemplateContentWrapper{
        @AuraEnabled
        public string tempSubject{get;set;}
        @AuraEnabled
        public string tempBody{get;set;}
        @AuraEnabled
        public string  toAddress{get;set;}
        @AuraEnabled
        public string  spoilageRequestName{get;set;}
          
    }
    
}