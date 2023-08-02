global without sharing class GNE_CM_PACT_Activation_Email_Sender implements Database.Batchable<sObject>
{   
    // This property is public only for testing purposes
    public String query { get; set; }
    
    global GNE_CM_PACT_Activation_Email_Sender()
    {   
        query = 'SELECT Id, Email_Address__c, Activation_Email_Sent_Date__c, Activation_Hash_Number__c, User_Status__c FROM GNE_CM_MPS_User__c WHERE Workflow_State__c = \'ACTIVATION_EMAIL_SENT\'';
    }
    
    global Database.QueryLocator start (Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    private Integer daysBetween(Datetime dt) {
    	Long millisecond = DateTime.now().getTime() - dt.getTime();
    	millisecond *= millisecond < 0 ? -1 : 1;
    	return (millisecond / 24 / 60 / 60 / 1000).intValue();
    }
    
    public List<Id> filterMpsUsersWithPactApprovedByEmailInterval (List<GNE_CM_MPS_User__c> mpsUsers) {
    	List<Id> mpsUsersForEmailIds = new List<Id>();
        Integer sendPeriod = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Email_Send_Period__c;
        Integer sendInterval = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Email_Send_Interval__c;
        Integer activationDays = (Integer)GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Activation_Link_Validity_Days__c;
        Datetime validActivationStartDate = DateTime.now().addDays(-1 * activationDays);
        List<GNE_CM_MPS_User__c> mpsUsersToUpdate = new List<GNE_CM_MPS_User__c>();
        for (GNE_CM_MPS_User__c mpsUser : mpsUsers) {
        	if (mpsUser.User_Status__c == GNE_CM_IHCP_PACT_Service.MPS_USER_APPROVED_FOR_PACT_STATUS) {
	            if (mpsUser.Activation_Email_Sent_Date__c >= validActivationStartDate) {
	                Integer daysBetween = daysBetween(mpsUser.Activation_Email_Sent_Date__c);
	                if (daysBetween != 0 && (Math.mod(daysBetween, sendInterval) == 0) && daysBetween <= 21)  {
	                    mpsUsersForEmailIds.add(mpsUser.Id);
	                    mpsUsersToUpdate.add(mpsUser);
	                }
	            } else {
	                mpsUser.Workflow_State__c = 'ACTIVATION_LINK_EXPIRED';
	                mpsUsersToUpdate.add(mpsUser);
	            }
        	}
        }        
        if (!mpsUsersToUpdate.isEmpty()) {
        	update mpsUsersToUpdate;
        }
        return mpsUsersForEmailIds;
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        try
        {
            List<Id> mpsUsersForEmailIds = filterMpsUsersWithPactApprovedByEmailInterval((List<GNE_CM_MPS_User__c>)scope);
            if (!mpsUsersForEmailIds.isEmpty()) {
            	GNE_CM_IHCP_PACT_Service.sendActivationEmail(mpsUsersForEmailIds, false);
            }
        }
        catch (Exception e)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_PACT_Activation_Email_Sender', 'High', 'execute', 'Apex Class', e);
            insert err;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
        // no action
    }
}