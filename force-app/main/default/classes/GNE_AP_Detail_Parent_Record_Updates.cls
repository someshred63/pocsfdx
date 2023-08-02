public without sharing class GNE_AP_Detail_Parent_Record_Updates{
	
	public static void onAfterInsert(List<AP_Detail_gne__c> accDetailList) {
		changeAccPlanStatus(accDetailList);
	}
	
	public static void onAfterUpdate(List<AP_Detail_gne__c> accDetailList) {
		changeAccPlanStatus(accDetailList);
	}
	
	public static void onAfterDelete(List<AP_Detail_gne__c> accDetailList) {
		changeAccPlanStatus(accDetailList);
	}
	
	private static void changeAccPlanStatus(List<AP_Detail_gne__c> accDetailList){
		Set<Id> accountPlanningIds = new Set<Id>();
		List<AP_Account_Planning_gne__c> updateAccPlans = new List<AP_Account_Planning_gne__c>();
		for (AP_Detail_gne__c apDetail : accDetailList){
			accountPlanningIds.add(apDetail.AP_Account_Planning_gne__c);
		}
		for (AP_Account_Planning_gne__c accPlan : [SELECT Id, Display_Status_gne__c, Action_gne__c, Status_gne__c FROM AP_Account_Planning_gne__c WHERE Status_gne__c =: GNE_AP_Util.AP_APPROVED AND Id IN :accountPlanningIds]){
			GNE_AP_Util.setAccountPlanActionAndStatus(accPlan, GNE_AP_Util.AP_NEW_STATUS);
			updateAccPlans.add(accPlan);
		}
		GNE_AP_Util.removeAccountPlanSharing(accountPlanningIds);
		update updateAccPlans;
	}
}