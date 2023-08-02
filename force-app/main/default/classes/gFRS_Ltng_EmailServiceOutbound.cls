/** Class Name  : gFRS_Ltng_EmailServiceOutbound 
*  Description  : This class used to sending the email messages
*
*  Modification Log:  
*  ————————————————————————————————————————————–
*   Developer                Date                   Modification ID      Description 
*  —————————————————————————————————————————————
**/ 
public class gFRS_Ltng_EmailServiceOutbound {

    @AuraEnabled 
    public static List<User> getUsers(){    	
        List<User> usrlist = [select id, name,email,isActive from User where isactive = true];
        return usrlist;
    }
    @AuraEnabled 
    public static gFRS_Ltng_Customer_Intraction__c getCIEMail(String recId){    	
        gFRS_Ltng_Customer_Intraction__c custInteraction = [SELECT Id, Name, Email__c,Grant_Request_Number__c FROM gFRS_Ltng_Customer_Intraction__c where Id=:recId];
        return custInteraction ;
    }
    
    @AuraEnabled 
    public static void sendMailMethod(String mMail ,List<String> mCcMail, String mSubject ,String mbody,string recid,string attId){
        
        string subrec= mSubject + ' '+'<<ref:' + recid +'>>';
      	system.debug('>>body>>>'+subrec);
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailServiceAddress=System.Label.gFRS_Ltng_Outbound_Email_Service;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'gfrs_emailservice-d@gene.com'];
        
        if(!String.isBlank(attId)){
            
            Attachment file = [SELECT Name, Body, ContentType FROM Attachment WHERE Id =: attId];
            
            List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(file.Name);
            efa.setBody(file.Body);
            efa.setContentType(file.ContentType);
            attachments.add(efa);
            
            mail.setFileAttachments(attachments);    
            
        }
         
        List<String> sendTo = mMail.split(',');
        mail.setOrgWideEmailAddressId(owea.get(0).Id);
        mail.setToAddresses(sendTo); 
        mail.setReplyTo(emailServiceAddress); // change it with your mail address.
        mail.setCcAddresses(mCcMail);        
        mail.setSubject(subrec); 
        mail.setHtmlBody(mbody);
        mails.add(mail);
        try {
            //Add Inbound Email Message for contact
            EmailMessage caseEmailMessage = new EmailMessage();
            caseEmailMessage.fromAddress= UserInfo.getUserEmail();
            caseEmailMessage.ToAddress = mMail;
            caseEmailMessage.Subject = mSubject;
            caseEmailMessage.HtmlBody = mbody;
            caseEmailMessage.Incoming= False;
            caseEmailMessage.TextBody = mbody;
            caseEmailMessage.status = '3';
            caseEmailMessage.gFRS_Customer_Interaction__c = recid;
            insert caseEmailMessage; 
            
            gFRS_Ltng_Customer_Intraction__c custInteraction = [SELECT Id, Name, Email__c,Grant_Request_Number__c,Count_of_emails__c FROM gFRS_Ltng_Customer_Intraction__c where Id=:recId];
            gFRS_Ltng_Customer_Intraction__c upCstRec=new gFRS_Ltng_Customer_Intraction__c();
            Decimal count;
            if(custInteraction.Count_of_emails__c!=null){
                 count=custInteraction.Count_of_emails__c;   
            }else{
                count=0;
            }
            upCstRec.Id=recid;
        	upCstRec.Customer_Replied__c='No';
            upCstRec.Count_of_emails__c=count+1; 
            
            update upCstRec; 
            
            // Add Email Message Relation for id of the sender
            EmailMessageRelation emr = new EmailMessageRelation();
            emr.EmailMessageId = caseEmailMessage.id;
            emr.RelationAddress = UserInfo.getUserEmail();
            emr.RelationType = 'FromAddress'; 
 	    	insert emr;
            
            
            // Send all emails in the master list
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            //Messaging.sendEmail(mails);
            system.debug('>>>>>=='+ mails);
        }
        catch(Exception e){
            System.debug('Queryue: ' + e.getMessage());
            System.assertEquals(1,2);
        }

    }


    
     @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
 		//system.debug('fileId'+fileId);
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
 
        return Id.valueOf(fileId);
    }
 
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
 
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
 
        insert oAttachment;
 		system.debug('oAttachment'+oAttachment);
        return oAttachment.Id;
    }
 
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
 
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
 
        String existingBody = EncodingUtil.base64Encode(a.Body);
 
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
 
        update a;
    }
    
	@AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        List<String> prlst=new List<String>{'GNE-CRM','GNE-CRM-Manager','GNE-Field','GNE-GFRS-Compliance Approver',
                'GNE-GFRS-Copay-Reviewer','GNE-GFRS-Copay-User','GNE-GFRS-External Applicant','GNE-GFRS-Finance Approver',
                'GNE-GFRS-Finance Manager','GNE-GFRS-Grant Approver','GNE-GFRS-Home','GNE-GFRS-Legal Approver',
                'GNE-GFRS-OPS','GNE-GFRS-PowerUser','GNE-GFRS-User','GNE-MCCO-AM','GNE-MedAffairs-MSL-Manager','GNE-SFA-Manager','GNE-SFA-PREP-Manager','GNE-TLS',
                'GNE-TLS-ABM-Approver','GNE-TLS-SpeakerBureauLead'};
		
         string tempInput = '%' + value + '%';
         for(sObject so :[select id, name,email,isActive from User where isactive = true and Profile.Name IN:prlst AND Name LIKE :tempInput]) {
            String fieldvalue = (String)so.get(fieldName);
            String fieldEmail = (String)so.get('email');
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id, fieldEmail));
        }
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String recEmail;
        
        public SObJectResult(String recNameTemp, Id recIdTemp, String recEmailTemp) {
            recName = recNameTemp;
            recEmail = recEmailTemp;
            recId = recIdTemp;
        }
    }
    
}