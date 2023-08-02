/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-01
*  Description: This is a trigger for handling Account Plan validation rules
*  Test class: GNE_SFA2_Account_Plan_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Acct_Plan_Validation_Rules {
	
	private static boolean preventDeletingAccountPlansWithInteractions(List<Account_Plan_vod__c> triggerOld) {
		boolean validationFailed = false;
		Map<Id, Account_Plan_vod__c> accountPlans = new Map<Id, Account_Plan_vod__c>([ SELECT Id, Name FROM Account_Plan_vod__c WHERE Id IN :triggerOld ]);	 
		List<Call2_vod__c> interactions = [ SELECT Id, Account_Plan_vod__c FROM Call2_vod__c WHERE Account_Plan_vod__c IN :triggerOld ];
                   
        for(Call2_vod__c interaction : interactions) {
        	accountPlans.get(interaction.Account_Plan_vod__c).addError(System.Label.Cannot_Delete_Object_Call_References);
        	validationFailed = true;
        }
        return validationFailed;
	}
	
	private static boolean checkAccountTeamNotNull(List<Account_Plan_vod__c> triggerNew) {
		boolean result = false;
		for(Account_Plan_vod__c accountPlan : triggerNew) {
			if(accountPlan.Team_gne__c == null || accountPlan.Team_gne__c == '') {
				accountPlan.addError(System.Label.Value_Required);
				result = true;
			}
		}
		return result;
	}
	
	public static void onBeforeDelete(List<Account_Plan_vod__c> triggerOld) {
		preventDeletingAccountPlansWithInteractions(triggerOld);
	}
	
	public static boolean onBeforeInsertUpdate(List<Account_Plan_vod__c> triggerNew) {
		return checkAccountTeamNotNull(triggerNew);
	}
}