global class gFRS_ACHDuetasks implements Schedulable {
    
    global void execute(SchedulableContext ctx) {
        
        Set<Id> reqId = new Set<Id>();
        List<gFRS_Tasks__c> postDueTasks = [SELECT Id, Name, Payment_Method_Due_On__c, gFRS_Funding_Request__r.id FROM gFRS_Tasks__c 
            WHERE  Payment_Method_Due_On__c < TODAY AND Action_Type__c = 'ACH' AND gFRS_Funding_Request__r.Organization__r.US_Organization__c='Yes'];
        if(postDueTasks.size() > 0){
            for(gFRS_Tasks__c task : postDueTasks){
                reqId.add(task.gFRS_Funding_Request__r.id);
            }
            
            List<Messaging.SingleEmailMessage>  myEmails = new List<Messaging.SingleEmailMessage>();        
            List<gFRS_Funding_Request__c> reqList = [SELECT Id, Name, Location__c, ACH_Override_by__c, Overriden_On__c, Overriding_reason__c, Payment_Method__c, ACH_Task_Open__c, Partner_Bank_Type__c, Bank_Lookup_Required__c, Signing_Authority_Email__c, Signing_Authority_First_Name__c, Signing_Authority_Last_Name__c, Event_Program_Title__c FROM gFRS_Funding_Request__c WHERE Id in : reqId];
            emailtemplate et = [SELECT Subject, Name, Id, Description, Body,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_Templates' and DeveloperName = 'QCO_Payment_Method_override_communication_email'];
            Id orgEmailId = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id;
            
            for(gFRS_Funding_Request__c req : reqList){
                req.Payment_Method__c = 'Check';
                req.Bank_Lookup_Required__c = 'No';
                req.Partner_Bank_Type__c = '';
                req.ACH_Task_Open__c = 'No';
                req.ACH_Override_by__c = UserInfo.getUserId();
                req.Overriden_On__c = DateTime.now();
                req.Overriding_reason__c = 'System Override';
                
                String body = gFRS_Util_NoShare.replaceEmailBody(et.Body, req);
                body += '\n\n' + '[ref:' + req.id + ']'; 
                String subject = gFRS_Util_NoShare.replaceEmailSubject(et.Subject, req);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{req.Signing_Authority_Email__c});
                mail.setBccAddresses(new List<String>{'fundingrequestsystem-donotreply-d@gene.com'});
                mail.setSubject(subject);
                mail.setPlainTextBody(body);
                mail.setOrgWideEmailAddressId(orgEmailId);
                
                myEmails.add(mail);
            }
            
            Update reqList;     
            delete postDueTasks;
            Messaging.sendEmail( myEmails );   
        }
    }
    
}