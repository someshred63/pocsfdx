/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-22
*  Description: This is a helper clsass for GNE_SFA2_Time_Off_Territory_Day_Trigger for handling field updates
*  Test class: GNE_SFA2_Time_Off_Territory_Day_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_ToT_Day_Field_Updates {
	
	private static void synchronizeReason(List<Time_off_Territory_Day_gne__c> triggerNew) {
		User user = [ SELECT Profile_Name_gne__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
		for (Time_off_Territory_Day_gne__c row : triggerNew) {
            if (user.Profile_name_gne__c.contains('MCCO')) {
                row.Reason_gne__c = row.Reason_MCCO_gne__c;
                row.Reason_PC_gne__c = null;
                row.Reason_SFA_gne__c = null;
                row.Reason_MedAffair_gne__c = null;
            } else if (user.Profile_name_gne__c.contains('Primary-Care')) {
                row.Reason_gne__c = row.Reason_PC_gne__c;
                row.Reason_SFA_gne__c = null;
                row.Reason_MCCO_gne__c = null;
                row.Reason_MedAffair_gne__c = null;
            } else if (user.Profile_name_gne__c.contains('MedAffairs')) {
                row.Reason_gne__c = row.Reason_MedAffair_gne__c;
                row.Reason_PC_gne__c = null;
                row.Reason_SFA_gne__c = null;
                row.Reason_MCCO_gne__c = null;
            } else {
                row.Reason_gne__c = row.Reason_SFA_gne__c;
                row.Reason_MCCO_gne__c = null;
                row.Reason_PC_gne__c = null;
                row.Reason_MedAffair_gne__c = null;
            }   
        }
	}
	
	public static void onBeforeInsertUpdate(List<Time_off_Territory_Day_gne__c> triggerNew) {
		synchronizeReason(triggerNew);
	}
}