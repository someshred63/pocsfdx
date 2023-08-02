public with sharing class EDM_AABPDetails_Notification_Ctrl {
	
	public Id AnualPlanId {get;set;}

	public EDM_AABP_gne__c getAnualPlan() {

		EDM_AABP_gne__c ap = [Select id,EDM_AB_Lead_gne__r.Name,EDM_Group_gne__c, EDM_Team_gne__c, EDM_Unit_gne__c,EDM_Plan_Year_gne__c from EDM_AABP_gne__c where Id =:AnualPlanId];

		return ap;
	}


	public EDM_AABPDetails_Notification_Ctrl() {}
}