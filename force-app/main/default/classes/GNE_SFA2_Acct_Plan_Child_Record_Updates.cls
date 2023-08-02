/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-01
*  Description: This is a trigger for handling Account Plan child record updates
*  Test class: GNE_SFA2_Account_Plan_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Acct_Plan_Child_Record_Updates {
	
	private static void archiveDeletedPlans(List<Account_Plan_vod__c> triggerOld) {
		List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedPlans = new List<FRM_Deleted_Account_Plan_Tactic_gne__c>();
    
	    for (Account_Plan_vod__c accountPlan : triggerOld) {
	        FRM_Deleted_Account_Plan_Tactic_gne__c deletedPlan = new FRM_Deleted_Account_Plan_Tactic_gne__c();
	        deletedPlan.Object_Name_gne__c = 'Account_Plan_vod__c';
	        deletedPlan.Record_Id_gne__c = accountPlan.Id;
	    
	        deletedPlans.add(deletedPlan);
	    }
	
	    if (deletedPlans.size() > 0){
	        insert deletedPlans;
	    }
	}
	
	public static void onBeforeDelete(List<Account_Plan_vod__c> triggerOld) {
		archiveDeletedPlans(triggerOld);
	}
}