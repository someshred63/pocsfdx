global with sharing class gFRS_RFIlEmailReminderBatch implements Database.Batchable<sObject> {

    global Database.Querylocator start(Database.BatchableContext BC){     
        gFRS_SOQLBuilder soqlBuilder = new gFRS_SOQLBuilder()
        .SELECTFields(new String[] {'Id', 'Name', 'Status__c', 'owner.email', 'Sub_Status__c','External_Status__c'
                                    
                                   })
        .FROMObject('gFRS_Ltng_Application__c')
        .WHEREField('Status__c', '=', 'RFI')
        .WHEREField('AND', 'Sub_Status__c', '=', 'RFI')
        .WHEREField('AND', 'External_Status__c', '=', 'RFI');

        return soqlBuilder.getQueryLocator();
    }
     global void execute(Database.BatchableContext BC, List<sObject> scope){
         List<Id> reqIds = new List<Id>();
        
        for(sObject obj : scope){
            reqIds.add(((gFRS_Ltng_Application__c)obj).Id);
        }
          Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        System.debug('application' +reqIds);        
        Map<Id,Attachment> attachmap1 = new Map<Id,Attachment>();
       List<String> AttchmentId = new List<String>(); 
       List<gFRS_Ltng_Application__c> reqs =[select id,name,owner.Email,RFI_SubmitDate__c, (select id ,name from attachments order by createddate desc limit 1 )from gFRS_Ltng_Application__c where id=:reqIds];
        System.debug('application res' +reqs);
        for(gFRS_Ltng_Application__c app: reqs) {
            for(Attachment attachmentRecord: app.Attachments) {
                AttchmentId.add(attachmentRecord.id);                
            }
            
        }
        List<Attachment> attach =[select id,Name,body,parentId from attachment where id=:AttchmentId];
         System.debug('Attchments' +attach);
        for(Attachment attachmentRecord: attach) {
            attachmap1.put(attachmentRecord.parentId,attachmentRecord);
        }
        for(gFRS_Ltng_Application__c app: reqs) {
            if(attachmap1.containsKey(app.Id)){
                mails.add( createRemainderEmail(app, attachmap1.get(app.Id) ,senderId));
            }
        }
        system.debug('AttchmentId' +AttchmentId);
        system.debug('AttchmentId' +attach);
        Messaging.sendEmail(mails); 
         
     }
    global void finish(Database.BatchableContext BC){
        
    }
    public static Messaging.SingleEmailMessage createRemainderEmail(gFRS_Ltng_Application__c request,attachment attch, Id senderId) {
      
     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     String bodyContent = attch.body.toString();
     String s2 = bodyContent.substringAfter('Request for Information');
   
     List<string> emails = new List<String>();
     system.debug('email' +request.owner.email);
     emails.add(request.owner.email);     
     if(senderId!=null){
         mail.setOrgWideEmailAddressId(senderId);
     }
     
     mail.setToAddresses(emails);       
     mail.setPlainTextBody(s2);  
     mail.setSubject('Request for Information (RFI) -  Reminder Genentech Funding Request ID '+request.Name);
     mail.setSaveAsActivity(false);
     return mail;
 }
}