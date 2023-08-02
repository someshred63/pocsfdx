/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-08-13
*  Description: This is a helper class for handling MedComm validation rules
*  Test class: GNE_SFA2_MedComm_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_MedComm_Validation_Rules {
    
	private static boolean getUserWhichHasCanadianProfile(){
		return GNE_SFA2_Util.isCanadaUser();
	}
	
	private static void accountFieldValidationOnUpdate(List<Medical_Communication_gne__c> triggerOld, List<Medical_Communication_gne__c> triggerNew){
		Boolean canadianUserIsExist = getUserWhichHasCanadianProfile();
		if(canadianUserIsExist){
			for(Integer i = 0; i < triggerNew.size(); i++){        		
        		if(triggerOld[i].id == triggerNew[i].id && triggerOld[i].Account_gne__c != triggerNew[i].Account_gne__c){
                    triggerNew[i].addError(System.Label.Account_field_cannot_be_updated);
        		}	
        	}
		}	
	}
	
	private static void referralValidationOnDelete(List<Medical_Communication_gne__c> triggerOld){
		Id referralRecordTypeId = GNE_SFA2_MedComm_Trigger_Helper.getReferralRecordTypeId();
		Id referralCanadaRecordTypeId = GNE_SFA2_MedComm_Trigger_Helper.getReferralCanadaRecordTypeId();
        for (Medical_Communication_gne__c medCommOld : triggerOld){
        	if(medCommOld.RecordTypeId == referralRecordTypeId || medCommOld.RecordTypeId == referralCanadaRecordTypeId){
            	medCommOld.addError(System.Label.Medical_Referral_cannot_be_deleted);
        	}
        }
	}
	
	public static void onBeforeUpdate(List<Medical_Communication_gne__c> triggerOld, List<Medical_Communication_gne__c> triggerNew){
		accountFieldValidationOnUpdate(triggerOld, triggerNew);	
	}
	
	public static void onBeforeDelete(List<Medical_Communication_gne__c> triggerOld){
		referralValidationOnDelete(triggerOld);
	}

}