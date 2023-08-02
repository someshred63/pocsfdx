public without sharing class GNE_AP_Terr_Plan_Parent_Record_Updates{
	
	public static void onAfterInsert(List<AP_Territory_Planning_gne__c> terrPlanList) {
		changeAccPlanStatus(terrPlanList);
	}
	
	public static void onAfterUpdate(List<AP_Territory_Planning_gne__c> terrPlanList) {
		changeAccPlanStatus(terrPlanList);
	}
	
	public static void onAfterDelete(List<AP_Territory_Planning_gne__c> terrPlanList){
		changeAccPlanStatus(terrPlanList);
	}
	
	private static void changeAccPlanStatus(List<AP_Territory_Planning_gne__c> terrPlanList){
		Set<Id> accountPlanningIds = new Set<Id>();
		List<AP_Account_Planning_gne__c> updateAccPlans = new List<AP_Account_Planning_gne__c>();
		for (AP_Territory_Planning_gne__c apTerr:terrPlanList){
			accountPlanningIds.add(apTerr.AP_Account_Planning_gne__c);
		}
		for (AP_Account_Planning_gne__c accPlan:[select Id, Display_Status_gne__c, Action_gne__c, Status_gne__c FROM AP_Account_Planning_gne__c WHERE Status_gne__c =: 'Approved' AND Id IN:accountPlanningIds ]){
			GNE_AP_Util.setAccountPlanActionAndStatus(accPlan, GNE_AP_Util.AP_NEW_STATUS);
			updateAccPlans.add(accPlan);
		}
		GNE_AP_Util.removeAccountPlanSharing(accountPlanningIds);
		update updateAccPlans;
	}
}