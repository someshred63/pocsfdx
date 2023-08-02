/************************************************************
*  @author: Bartosz Osowiecki, Roche
*  Date: 2012-12-19
*  Description: Helper class for GNE_SFA2_Account_Trigger
*  Test class: GNE_SFA2_Account_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Account_Email_Notifications
{
	
    private static void sendEmailsAfterSpeakerClassificationUpdate(List<Account> triggerOld, List<Account> triggerNew) {
        Map<Id,Account> triggerNewMap = new Map<Id,Account>(triggerNew);
        Map<Id,Account> triggerOldMap = new Map<Id,Account>(triggerOld);
        Map<Id,Set<Speaker_Bureau_Membership_gne__c>> accountsWithUpdatedSBMs = GNE_SFA2_Account_Trigger_Helper.getAccountsWithUpdatedSBMs();
        
        if(!accountsWithUpdatedSBMs.isEmpty()) {
            Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[accountsWithUpdatedSBMs.size()];
            String currentUserUnixID = [SELECT External_Id_gne__c FROM User WHERE Id = :UserInfo.getUserId()].External_Id_gne__c;
            
	        Map<String,Speaker_Bureau_Notification_Email__c> settingsMap = Speaker_Bureau_Notification_Email__c.getAll();
	        /* //Commented by KaavyaK - 04/01/2013 - to add null check.
	        String[] toAddresses = new String[] {settingsMap.get('Email').Value__c};
	        String senderDisplayName = settingsMap.get('SenderDisplayName').Value__c;
	        String subject = System.Label.Speaker_Bureau_Notification_Email_Subject;
	        */
	        String[] toAddresses =  new String[]{};
	        String senderDisplayName = '';
	        if (settingsMap != null)
	        {
	            if (settingsMap.get('Email') != null)
	            {
	                toAddresses = new String[] {settingsMap.get('Email').Value__c};
	            }
	            if (settingsMap.get('SenderDisplayName') != null)
	            {
	                senderDisplayName = settingsMap.get('SenderDisplayName').Value__c;
	            }           
	        }
	        String subject = System.Label.Speaker_Bureau_Notification_Email_Subject;               
	        
	        Integer i = 0;
	        for(Id accId : accountsWithUpdatedSBMs.keySet()) {
	            Account accNew = triggerNewMap.get(accId);
	            Account accOld = triggerOldMap.get(accId);
	            
	            // send e-mail notification
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            mail.setToAddresses(toAddresses);
	            mail.setSenderDisplayName(senderDisplayName);
	            mail.setSubject(subject);
	            
	            String message = String.Format(System.Label.Speaker_Bureau_Notification_Email_Body,
	                                           new String[]{
	                                                currentUserUnixID, 
	                                                UserInfo.getFirstName() + ' ' + UserInfo.getLastName(),
	                                                System.now().format(settingsMap.get('DateTimeFormat').Value__c, settingsMap.get('DateTimeZone').Value__c),
	                                                accOld.Classification_gne__c,
	                                                accNew.Classification_gne__c,
	                                                System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + accId,
	                                                accNew.FirstName + ' ' + accNew.LastName,
	                                                accId,
	                                                accNew.MDMID_gne__c});
	            message += '<ul>';
	                
	            for(Speaker_Bureau_Membership_gne__c membership : accountsWithUpdatedSBMs.get(accId)) {   
	                message += '<li><a href=' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + membership.Id + '>' + membership.Speaker_Bureau_ID_gne__r.Name + '</a></li>';
	            }
	            
	            message += '</ul>';        
	            mail.setHtmlBody(message);
	            mails[i++] = mail;
	        }
	        
	        Messaging.sendEmail(mails, false);
	    }
    }
    
    public static void onAfterUpdate(List<Account> triggerOld, List<Account> triggerNew) {
        // .........:::::::::::::: THIS CODE RULE MUST BE ACTIVE DURING MERGE - NOT ADDING BYPASS :::::::::::::::::.................
        sendEmailsAfterSpeakerClassificationUpdate(triggerOld, triggerNew);
    }
    
    public static void onAfterInsert(List<Account> triggerOld, List<Account> triggerNew) { }
    
    public static void onAfterDelete(List<Account> triggerOld) { }
}