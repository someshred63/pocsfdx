/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-01
*  Description: This is a trigger for handling Account Tactic child record updates
*  Test class: GNE_SFA2_Account_Tactic_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Acct_Tactic_Child_Record_Update {
	
	private static void archiveDeletedTactics(List<Account_Tactic_vod__c> triggerOld) {
		List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedTactics = new List<FRM_Deleted_Account_Plan_Tactic_gne__c>();
    
	    for (Account_Tactic_vod__c accountTactic : triggerOld) {
	        FRM_Deleted_Account_Plan_Tactic_gne__c deletedTactic = new FRM_Deleted_Account_Plan_Tactic_gne__c();
	        deletedTactic.Object_Name_gne__c = 'Account_Tactic_vod__c';
	        deletedTactic.Record_Id_gne__c = accountTactic.Id;
	    
	        deletedTactics.add(deletedTactic);
	    }
	
	    if (deletedTactics.size() > 0){
	        insert deletedTactics;
	    }
	}
	
	public static void onBeforeDelete(List<Account_Tactic_vod__c> triggerOld) {
		archiveDeletedTactics(triggerOld);
	}
}