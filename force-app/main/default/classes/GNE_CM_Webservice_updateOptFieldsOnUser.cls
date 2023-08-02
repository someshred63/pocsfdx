global class GNE_CM_Webservice_updateOptFieldsOnUser
{   
	private static final Boolean LOG_PROGRESS = false;
	private static List<Error_Log_gne__c> logs = new List<Error_Log_gne__c>();
    
    @future 
	public static void updateOptFieldsOnUser(String email)
    {
        try {
        	Map<Id,Id> mpsUserIdsToSfdcUserIds = new Map<Id, Id>();
        	for (GNE_CM_MPS_User__c u : [SELECT Id, SFDC_User__c FROM GNE_CM_MPS_User__c WHERE Email_address__c = :email]) {
        		mpsUserIdsToSfdcUserIds.put(u.Id, u.SFDC_User__c);
        	}
        	
        	Map<Id,GNE_CM_MPS_User_Preferences__c> mpsUserIdsToMpsUserPreferences = new Map<Id,GNE_CM_MPS_User_Preferences__c>();
        	for (GNE_CM_MPS_User_Preferences__c pref : [SELECT Id, MPS_User__c, Email_Settings__c FROM GNE_CM_MPS_User_Preferences__c WHERE MPS_User__c IN :mpsUserIdsToSfdcUserIds.keySet()]) {
        		pref.Email_Settings__c = null;
        		mpsUserIdsToMpsUserPreferences.put(pref.MPS_User__c, pref);
        	}
        	
        	if (LOG_PROGRESS) {
        		for (Id mpsUserId : mpsUserIdsToSfdcUserIds.keySet()) {
	        		String errorDesc = '';
	        		if (!mpsUserIdsToMpsUserPreferences.containsKey(mpsUserId)) {
	        			errorDesc = 'Mps User Preferences not found for Mps User #' + mpsUserId + '(Sfdc User #' + mpsUserIdsToSfdcUserIds.get(mpsUserId) + ')';
	        			system.debug(errorDesc);
	        			logs.add(new Error_Log_gne__c(
							Object_Name__c = 'APEX CLASS', 
							Error_Level_gne__c = 'Low',
							Snippet_Name__c = 'GNE_CM_Webservice_updateOptFieldsOnUser', 
							Code_Type__c = 'Apex', 
							Error_Description__c = errorDesc, 
							User_Name__c = GNE_CM_MPS_Utils.getUserName()
		    			));
	        		}
	        	}
        	}
        	
        	if (!mpsUserIdsToMpsUserPreferences.isEmpty()) {
        		update mpsUserIdsToMpsUserPreferences.values();
        		if (LOG_PROGRESS) {
        			logs.add(new Error_Log_gne__c(
						Object_Name__c = 'APEX CLASS', 
						Error_Level_gne__c = 'Low',
						Snippet_Name__c = 'GNE_CM_Webservice_updateOptFieldsOnUser', 
						Code_Type__c = 'Apex', 
						Error_Description__c = 'Mps User Preferences updated for email: ' + email + ', total updated records: ' + mpsUserIdsToMpsUserPreferences.size(), 
						User_Name__c = GNE_CM_MPS_Utils.getUserName()
	    			));
        		}
        	}
        	
        	if (LOG_PROGRESS && !logs.isEmpty()) {
        		insert logs;
        	}
        }
        catch (Exception e) {
        	Error_Log_gne__c error = GNE_CM_MPS_Utils.createError('APEX CLASS', 'Low', 'GNE_CM_Webservice_updateOptFieldsOnUser', 'Apex', e);
        	insert error;
        }
    }
}