/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2013-01-13
*  Description: This is a helper class for GNE_SFA2_View_Config_Trigger for handling child record updates
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_View_Config_Child_Record_Update {
	
	/*
	*	Removes related user preferences on delete
	*/
	private static void deleteRelatedUserPreferences(List<SFA2_View_Config_gne__c> viewConfigs) {
		List<SFA2_User_Preferences_gne__c> userPreferencesToDelete = [ SELECT Id FROM SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__c IN :viewConfigs ];
		delete userPreferencesToDelete;
	}
	
	
	public static void onBeforeDelete(List<SFA2_View_Config_gne__c> viewConfigs) {
		deleteRelatedUserPreferences(viewConfigs);
	}
}