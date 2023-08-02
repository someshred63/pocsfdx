/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-12
*  Description: This is a helper class for handling IRF field updates
*  Test class: GNE_SFA2_IRF_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_IRF_Field_Updates {
	
	private static void insertResolvedDateField(List<Issue_gne__c> triggerNew){
		for (Integer i = 0; i < triggerNew.size(); i++){        
        	if(triggerNew[i].Status_frm_gne__c == 'Open'){
            	triggerNew[i].Resolved_Date_frm_gne__c = null;         
        	} else {
            	triggerNew[i].Resolved_Date_frm_gne__c = System.Today();
        	}           
        }
	}
	
	private static void updateResolvedDateField(List<Issue_gne__c> triggerOld, List<Issue_gne__c> triggerNew){
		for (Integer i = 0; i < triggerNew.size(); i++){        
        	if(triggerOld[i].Status_frm_gne__c == 'Resolved' && triggerOld[i].Resolved_Date_frm_gne__c != null && triggerNew[i].Status_frm_gne__c == 'Open'){
            	triggerNew[i].Resolved_Date_frm_gne__c = null;         
        	} else if(triggerOld[i].Status_frm_gne__c == 'Open' && triggerOld[i].Resolved_Date_frm_gne__c == null && triggerNew[i].Status_frm_gne__c == 'Resolved'){
            	triggerNew[i].Resolved_Date_frm_gne__c = System.Today();
        	}           
        }
	}
	
	public static void onBeforeInsert(List<Issue_gne__c> triggerNew){
		insertResolvedDateField(triggerNew);	
	}
	
	public static void onBeforeUpdate(List<Issue_gne__c> triggerOld, List<Issue_gne__c> triggerNew){
		updateResolvedDateField(triggerOld, triggerNew);	
	}

}