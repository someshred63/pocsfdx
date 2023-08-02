public class SPLOA_SendEmailRemainderBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        C_Ops_Captcha_Property__c captcha =[SELECT Id,Active__c,Auto_Renewal_Send_Cadence__c,Months_to_Expired__c FROM C_Ops_Captcha_Property__c WHERE Active__c = true LIMIT 1];
        
        Integer monthstoRemind = Integer.valueOf(captcha.Auto_Renewal_Send_Cadence__c);
        Integer monthsExpire = Integer.valueOf(captcha.Months_to_Expired__c);
        
        DateTime expirydate = System.now().addMonths(-monthsExpire);
        DateTime twentyOneMonthOldDate = System.now().addMonths(-monthstoRemind); 
        
        String query =  'SELECT ID, Name, C_Ops_SPLOA_Request_Status__c, C_Ops_SPLOA_Email__c , Email_Reminder_sent__c ' + 'FROM C_Ops_SPLOA_Request__c ' + 
            'WHERE C_Ops_SPLOA_Request_Status__c = \'Processed\'  '+
            'AND Processed_Date__c< :expirydate';
           
		system.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<C_Ops_SPLOA_Request__c> scope) {
        updateReqstatusExpired(scope);
      //  EmailTemplate template = getEmailTemplate('IAP resubmit'); 
       // sendEmailNotifications(scope, template);
    }    
    
    public void finish(Database.BatchableContext bc) {
    } 
    private void updateReqstatusExpired(List<C_Ops_SPLOA_Request__c> reqList){
     	List<C_Ops_SPLOA_Request__c> requestList = new List<C_Ops_SPLOA_Request__c>();
        if(reqList!= null && reqList.size()>0){
            for (C_Ops_SPLOA_Request__c request: reqList) {
                if(request.C_Ops_SPLOA_Request_Status__c != 'Expired'){
                C_Ops_SPLOA_Request__c newRequest = new C_Ops_SPLOA_Request__c();
                newRequest.Id = request.id; 
                newRequest.C_Ops_SPLOA_Request_Status__c = 'Expired';
                requestList.add(newRequest);
                }
            }
        }
        if(requestList.size()>0){
        update requestList;
        }
    }
    
   /* private EmailTemplate getEmailTemplate(String templateName) {
        EmailTemplate template = null;
        if(!String.isBlank(templateName)) {
            template = [
                SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
                FROM EmailTemplate 
                WHERE Name = :templateName 
            ];
        }
        return template;
    }
    
    private void sendEmailNotifications(List<C_Ops_SPLOA_Request__c> reqList, EmailTemplate template) {
        system.debug('reqList'+reqList.size());
        if(reqList!=null && !reqList.isEmpty()) {
            List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
            for(C_Ops_SPLOA_Request__c req: reqList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(req.Id);
                mail.setTreatTargetObjectAsRecipient(true);
                mail.setWhatId(req.Id);
                mail.setReplyTo('cop_sploa-d@gene.com');
                mail.setSenderDisplayName('C-OPS'); 
                mail.setTemplateId(template.id);
                mail.setSaveAsActivity(False);
                emailListToSend.add(mail);
                System.debug('++--mail:'+mail);
            }
           Messaging.SendEmailResult [] r = Messaging.sendEmail(emailListToSend);
           Set<id> targetIdsFailed = new Set<Id>();
        for(Messaging.SendEmailResult rr:r){
        	if(!rr.IsSuccess()){
          //   SendEmailError[] errArr = rr.getErrors();  
            // targetIdsFailed.add(errArr[0].getTargetObjectId());
          		}
    		}
        }
    }*/
}