global  with sharing class gFRS_Ltng_CAFApprovalEmailReminderBatch implements Database.Batchable<sObject> {
    
global Database.Querylocator start(Database.BatchableContext BC){     
        gFRS_SOQLBuilder soqlBuilder = new gFRS_SOQLBuilder()
        .SELECTFields(new String[] {'Id', 'CreatedById', 'CreatedDate', 'IsDeleted', 'LastModifiedById',
                                    'LastModifiedDate', 'Status', 'SystemModstamp', 'TargetObjectId' , 'ProcessInstance.TargetObject.Name'
                                   })
        .FROMObject('ProcessInstance')
        .WHEREField('ProcessInstance.TargetObject.Type', '=', 'gFRS_Ltng_CAF_Application__c')
        .WHEREField('AND', 'Status', '=', 'Pending');

        return soqlBuilder.getQueryLocator();
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 01/07/2012
    * @description Processing scope of Funding Requests.
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Id> listOfProcessInstanceIds = new List<Id>();
        
        for(sObject obj : scope){
            listOfProcessInstanceIds.add(((ProcessInstance)obj).Id);
        }
        Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;
        
        try{
            GFRS_Ltng_OrgSettings__c customSettings = GFRS_Ltng_OrgSettings__c.getOrgDefaults();       
            System.debug('customSettings: ' + customSettings );
            
            String excludedUserEmails = '';
            
            excludedUserEmails = (customSettings.ApprovalRemindersExcludeEmails__c != null) ? customSettings.ApprovalRemindersExcludeEmails__c : '';
            
            EmailTemplate et = [SELECT Name, Body, Description, DeveloperName, FolderId, HtmlValue, Subject, TemplateStyle, TemplateType
                                FROM EmailTemplate WHERE name = 'gFRS 2.0 CoPay Approving / Rejecting Requests Approval Pending (Notify Approver)'].get(0);
            
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                                                    
            Map<Id, ProcessInstance> mapProcessInstances = new Map<Id, ProcessInstance>(
                [SELECT Id, CreatedById, CreatedDate, IsDeleted, LastModifiedById, LastModifiedDate, Status, SystemModstamp, TargetObjectId ,
                 ProcessInstance.TargetObject.Name,
                 (SELECT SystemModstamp, ProcessInstanceId, OriginalActorId, IsDeleted, Id, CreatedDate, CreatedById, ActorId
                  FROM Workitems)
                 FROM ProcessInstance
                 WHERE Id IN :listOfProcessInstanceIds]
            );

            Set<Id> sActorIds = new Set<Id>();
            Set<Id> sFundingIds = new Set<Id>();

            for (ProcessInstance processInstance : mapProcessInstances.values()) {
                sFundingIds.add(processInstance.TargetObjectId);

                for (ProcessInstanceWorkitem workItem : processInstance.Workitems) {                   
                    sActorIds.add(workItem.ActorId);
            }
            }
                    
                        
            Map<Id, User> mapUsers = new Map<Id, User>(
                [SELECT id, username, Email
                 FROM User
                 WHERE id IN :sActorIds]
            );
            
            Map<Id, gFRS_Ltng_CAF_Application__c> mapFundingRequests = new Map<Id, gFRS_Ltng_CAF_Application__c>(
                [SELECT Id, Name
                 FROM gFRS_Ltng_CAF_Application__c
                 WHERE Id IN :sFundingIds]
            );
            
            System.debug('PN::mapProcessInstances.keySet(): ' + mapProcessInstances.keySet());
            System.debug('PN::mapProcessInstances.values().size(): ' + mapProcessInstances.values().size());
            
            String bccEmailAddress='';
            GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
            if(myOrgCS.gFRS_Inbound_Email__c != null){
                   bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            }
    
            for (ProcessInstance processInstance : mapProcessInstances.values()) {
                for (ProcessInstanceWorkitem processWorkItem : processInstance.Workitems) {
                    User workItemActor = mapUsers.get(processWorkItem.ActorId);
                    gFRS_Ltng_CAF_Application__c request = mapFundingRequests.get(processInstance.TargetObjectId);

                    Boolean sendRemainder = (
                                                workItemActor != null
                                                && !excludedUserEmails.contains(workItemActor.Email)
                                                && request != null
                                                //&& (request.Record_Type_Name__c == 'Commercial Sponsorship' || request.Record_Type_Name__c == 'Corporate Memberships' || request.Record_Type_Name__c == 'Field Exhibits' ||request.Record_Type_Name__c =='Non-Commercial Sponsorship')
                                            );
                            
                            
                    if (sendRemainder) {
                        Integer daysSinceRequestSubmit = 0;
                        Integer daysSinceLastRemindWasSent = 0;
                        Boolean forceSendReminder = false;
                            
                        if(customSettings.ApprovalRemindersDaysBetweenReminders__c !=null && customSettings.ApprovalRemindersDaysBetweenReminders__c>0){                                              
                            daysSinceRequestSubmit = Integer.valueOf(((Datetime.now().getTime() - processWorkItem.SystemModstamp.getTime()) / 86400000));
                            daysSinceLastRemindWasSent = Math.mod( daysSinceRequestSubmit, Integer.valueOf(customSettings.ApprovalRemindersDaysBetweenReminders__c));
                        }
                        else if (customSettings.ApprovalRemindersDaysBetweenReminders__c != null && customSettings.ApprovalRemindersDaysBetweenReminders__c == 0) {
                            forceSendReminder = true;   
                        }
                        else {
                            forceSendReminder = true;           
                        }   
                        
                        System.debug('PN::DEBUG: daysSinceLastRemindWasSent: ' + daysSinceLastRemindWasSent + ' daysSinceRequestSubmit: ' + daysSinceRequestSubmit);
    
                        if ( forceSendReminder || (daysSinceLastRemindWasSent == 0) ) {
                            String toEmailAddress = workItemActor.Email;
                            
                            if (customSettings.ApprovalRemindersProdModeOn__c == false) {
                                toEmailAddress = customSettings.ApprovalRemindersTestEmails__c;
                            }
                        
                            mails.add( createRemainderEmail(request, toEmailAddress, et, senderId, bccEmailAddress) );
                        }                           
                    }               

                }
            }                               
            Messaging.sendEmail(mails);    
        }
        catch (Exception ex) {
            system.debug('[EMAIL SEND FAILURE] Exception:' +ex.getMessage());
        }  
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 01/07/2012
    * @description Processing data FROM Funding Requests. Because we want to use Email Template we need to manually replace variables
    * FROM email template expression language with the data FROM database.
    */
    public static Messaging.SingleEmailMessage createRemainderEmail(gFRS_Ltng_CAF_Application__c request, string  ToEmailAddress, EmailTemplate emailTemplate, Id senderId, String bcc) {
        string emailTemplateBody = emailTemplate.Body;
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
        emailTemplateBody.replace('{!gFRS_Ltng_CAF_Application__c.Name}', request.Name)
        .replace('{!gFRS_Ltng_CAF_Application__c.Id}', request.Id )
        .replace('{!requestReminderLink}', requestReminderLink);

        emailTemplateBody += '\n\n' + '[ref:' + request.id + ']';
                                                
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(senderId!=null){
            mail.setOrgWideEmailAddressId(senderId);
        }                   
        mail.setToAddresses(new List<String>{ToEmailAddress});
        mail.setPlainTextBody(emailTemplateBody);       
        if(bcc != null){
            mail.setBccAddresses(bCCEmails);
        }
        mail.setReferences('References: 1*'+str+' CRLF');
        mail.setSubject(emailTemplate.Subject.replace('{!gFRS_Ltng_CAF_Application__c.Name}',request.Name));
        mail.setSaveAsActivity(false);   
               
        return mail;
    }
    
    /** 
     * @author ADMD Team
     * @date 08/19/2013
     * @description formatCurrency method - formats currency
     */
     public static String formatCurrency(Decimal currencyValue){
     
        List<String> args = new String[]{'0','number','###,###,##.00'};
        String requestedAmountFormatted = String.format(currencyValue.format(), args);

        String decimalSigns = requestedAmountFormatted.substringAfter('.');
        
        if(decimalSigns.length() == 0){
            requestedAmountFormatted += '.00'; 
        }
        else if (decimalSigns.length() == 1) {
            requestedAmountFormatted += '0';
        }

        requestedAmountFormatted = '$' + requestedAmountFormatted;  
        
        return requestedAmountFormatted;
        
     }
    
}