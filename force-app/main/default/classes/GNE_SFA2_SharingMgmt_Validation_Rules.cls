/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-12
*  Description: This is a validation utils class for GNE_SFA2_SharingMgmt_Trigger
*    
*  Modification History
*  Date        Name        Description
*  2012-08-16  kwiatkol    Changed required field for CaseShare from User name to User id
*  2012-10-05  kwiatkol    Changed validation logic for AccountShare to allow Account Id or External Id
*  2012-10-15  kwiaktol    Added inserting AccountShares with User Id specified
*************************************************************/
public without sharing class GNE_SFA2_SharingMgmt_Validation_Rules {
	
	public static boolean isValidSharingMgmt(Sharing_Mgmt_gne__c shareMgmt) {
		Boolean result = true;
		if (String.isBlank(shareMgmt.Object_Name_gne__c) || String.isBlank(shareMgmt.Operation_gne__c) 
			|| String.isBlank(shareMgmt.Status_gne__c) || shareMgmt.Schedule_Date_Time_gne__c == null) {
				
			result = false;
		} else if(shareMgmt.Object_Name_gne__c == 'AccountShare') {
			if((String.isBlank(shareMgmt.Territory_Name_gne__c) && String.isBlank(shareMgmt.User_Id_gne__c)) 
				|| (!String.isBlank(shareMgmt.Territory_Name_gne__c) && !String.isBlank(shareMgmt.User_Id_gne__c))
				|| (String.isBlank(shareMgmt.External_Id_gne__c) && String.isBlank(shareMgmt.Account_Id_gne__c)) 
				|| (!String.isBlank(shareMgmt.External_Id_gne__c) && !String.isBlank(shareMgmt.Account_Id_gne__c))
				|| (!String.isBlank(shareMgmt.User_Id_gne__c) && (String.isBlank(shareMgmt.Account_Access_Level_gne__c) || String.isBlank(shareMgmt.Opportunity_Access_Level_gne__c)))){
					
					result = false;
			}
		} else if(shareMgmt.Object_Name_gne__c == 'CaseShare' && (String.isBlank(shareMgmt.User_Id_gne__c) 
					|| String.isBlank(shareMgmt.Case_Access_Level_gne__c) || String.isBlank(shareMgmt.External_Id_gne__c))){ 
			result = false;
		}
		return result;
	}
	
	public static void onBeforeInsertUpdate(List<Sharing_Mgmt_gne__c> triggerOld, List<Sharing_Mgmt_gne__c> triggerNew) {
		for(Sharing_Mgmt_gne__c shareMgmt : triggerNew) {
			if(! isValidSharingMgmt(shareMgmt)) {
				shareMgmt.addError(System.Label.GNE_SFA2_ErrorMsg_ALL_Required_Fields);
			}
		}
	}
}