/** Class Name   : EmailServiceInbound 
*  Description  : For all incoming email messages , this class invoke.
*
*  Modification Log:  
*  ————————————————————————————————————————————–
*   Developer                Date                   Modification ID      Description 
*  —————————————————————————————————————————————
**/
global class gFRS_Ltng_EmailServiceInbound implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        system.debug('in');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();        
        String emailContent   = email.plainTextBody.trim();
        string sss= email.subject;
        string [] a = sss.split('\\<<ref:');
        string [] bb = a[1].split('\\>>');
        String subrecid = bb[0];
        system.debug('subrecid'+subrecid);
        List<Attachment> attachments = new List<Attachment>();
        if(email.textAttachments != null)
        {
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = subrecid;
                attachments.add(attachment);
            }
        }
        if(email.binaryAttachments != null)
        {
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                Attachment attachment = new Attachment();
                
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = subrecid;
                attachments.add(attachment);
            }
        }
        if(attachments.size() > 0)
        {
            insert attachments;
        }
        //Add Inbound Email Message for gFRS_Ltng_Application__c
        EmailMessage conEmailMessage = new EmailMessage();
        conEmailMessage.ToAddress =  String.join(email.toAddresses, ',');
        conEmailMessage.FromAddress = email.FromAddress;
        conEmailMessage.FromName = email.FromName;
        conEmailMessage.Subject = email.subject;
        conEmailMessage.status = '2';
        conEmailMessage.HtmlBody = email.htmlBody;
        conEmailMessage.Incoming= True;
        conEmailMessage.TextBody = email.plainTextBody;            
        conEmailMessage.gFRS_Customer_Interaction__c =subrecid;
        insert conEmailMessage;
        // Add Email Message Relation for id of the sender
        EmailMessageRelation emr = new EmailMessageRelation();
        emr.EmailMessageId = conEmailMessage.id;
        emr.RelationAddress = email.FromAddress;
        emr.RelationType = 'FromAddress';
        insert emr; 
        
        
        gFRS_Ltng_Customer_Intraction__c custInteraction = [SELECT Id, Name, Email__c,Grant_Request_Number__c,Count_of_emails__c FROM gFRS_Ltng_Customer_Intraction__c where Id=:subrecid];
        gFRS_Ltng_Customer_Intraction__c upCstRec=new gFRS_Ltng_Customer_Intraction__c();
        Decimal count;
        if(custInteraction.Count_of_emails__c!=null){
            count=custInteraction.Count_of_emails__c;   
        }else{
            count=0;
        }
        upCstRec.Id=subrecid;
        upCstRec.Customer_Replied__c='Yes';
        upCstRec.Status__c='New';
        upCstRec.Count_of_emails__c=count+1;
        update upCstRec;
        
        
        return result;
    }
}