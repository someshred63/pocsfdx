/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-14
*  Description: This is a helper class for handling MedComm field updates
*  Test class: GNE_SFA2_MedComm_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_MedComm_Field_Updates {
	
	private static void referralAndMedCommAcountFieldsUpdate(List<Medical_Communication_gne__c> triggerNew){
		Id referralRecordTypeId = GNE_SFA2_MedComm_Trigger_Helper.getReferralRecordTypeId();
		Id referralCanadaRecordTypeId = GNE_SFA2_MedComm_Trigger_Helper.getReferralCanadaRecordTypeId();
		for (Integer i = 0; i < triggerNew.size(); i++){        
        	if(triggerNew[i].RecordTypeId == referralRecordTypeId || triggerNew[i].RecordTypeId == referralCanadaRecordTypeId){
            	triggerNew[i].Account_Referral_gne__c = triggerNew[i].Account_gne__c;         
        	}else{
            	triggerNew[i].Account_Medcom_gne__c = triggerNew[i].Account_gne__c;
        	}           
        }
	}
	
	public static void onBeforeInsert(List<Medical_Communication_gne__c> triggerNew){
		referralAndMedCommAcountFieldsUpdate(triggerNew);
	}
	
	public static void onBeforeUpdate(List<Medical_Communication_gne__c> triggerNew){
		referralAndMedCommAcountFieldsUpdate(triggerNew);
	}

}