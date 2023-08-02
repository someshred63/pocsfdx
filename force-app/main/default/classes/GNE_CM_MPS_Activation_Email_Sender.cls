/**
 * Batch class that sends e-mails at certain intervals (7 days by default) for a certain period of time (30 days by default).
 *
 * Test class/method: GNE_CM_MPS_Activation_Emails_Test.testActivationReminders
 *
 * @author Radek Krawiec
 * @created 07/20/2012
 */
global without sharing class GNE_CM_MPS_Activation_Email_Sender implements Database.Batchable<sObject>
{   
    // This property is public only for testing purposes
    public String query { get; set; }
    
    global GNE_CM_MPS_Activation_Email_Sender()
    {   
        // find unactivated users to whom email should be sent on the current day
        query = 'SELECT Id, Email_Address__c, Activation_Email_Sent_Date__c, Activation_Hash_Number__c, User_Status__c FROM GNE_CM_MPS_User__c WHERE Workflow_State__c = \'ACTIVATION_EMAIL_SENT\'';
    }
    
    global Database.QueryLocator start (Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
     private integer daysBetween(DateTime dt) {
    	Long millisecond = DateTime.now().getTime() - dt.getTime();
    	millisecond *= millisecond < 0 ? -1 : 1;
    	return millisecond.intValue() / 24 / 60 / 60 / 1000;
    }
    
    /**
     * This method takes a list of MPS users and filters them retaining only those whose (currentDate - Activation_Email_Sent_Date__c) & sendInterval == 0.
     *
     * Note: this method is public only for testing purposes
     */
    public List<Id> filterMpsUsersByEmailInterval (List<GNE_CM_MPS_User__c> mpsUsers)
    {
        List<Id> mpsUsersForEmailIds = new List<Id>();
        Integer sendInterval = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Email_Send_Interval__c;
        Integer sendPeriod = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Email_Send_Period__c;
        
        // get the date from which activations are valid, i.e. activations older than that date won't are expired
        Datetime validActivationStartDate = DateTime.now().addDays(-1 * sendPeriod);
        
        for (GNE_CM_MPS_User__c mpsUser : mpsUsers)
        {
        	if (mpsUser.User_Status__c != GNE_CM_IHCP_PACT_Service.MPS_USER_APPROVED_FOR_PACT_STATUS) 
        	{
	            if(mpsUser.Activation_Email_Sent_Date__c >= validActivationStartDate)
	            {
	                Integer daysBetween = daysBetween(mpsUser.Activation_Email_Sent_Date__c);
	                if (daysBetween != 0 && Math.mod(daysBetween, sendInterval) == 0) 
	                {
	                    // an activation email will be sent to this user
	                    mpsUsersForEmailIds.add(mpsUser.Id);
	                }
	            }
	            else
	            {
	                mpsUser.Workflow_State__c = 'ACTIVATION_LINK_EXPIRED';
	            }
        	}
        }        
        update mpsUsers;
        
        return mpsUsersForEmailIds;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        System.debug('Activation email batch scope before 7 day interval filtering: ' + scope);
        
        try
        {
            List<Id> mpsUsersForEmailIds = filterMpsUsersByEmailInterval((List<GNE_CM_MPS_User__c>)scope);
            System.debug('Sending activation emails to MPS users: ' + mpsUsersForEmailIds);
            
            if (mpsUsersForEmailIds != null && !mpsUsersForEmailIds.isEmpty())
            {
           		// send activation reminders
            	GNE_CM_MPS_Email_Utils.sendActivationEmails(mpsUsersForEmailIds, true, true);
            }
        }
        catch (Exception e)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_Activation_Email_Sender', 'High', 'execute', 'Apex Class', e);
            insert err;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        // no action
    }
}