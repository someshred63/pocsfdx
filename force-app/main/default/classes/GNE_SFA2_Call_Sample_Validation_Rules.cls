public without sharing class GNE_SFA2_Call_Sample_Validation_Rules {
	
	public static void OnBeforeUpdate (Map<Id,Call2_Sample_vod__c> oldCallSamplesMap,  Map<Id, Call2_Sample_vod__c> newCallSamplesMap){
		quantityValidation(newCallSamplesMap.values());
		giftComplianceCheck(newCallSamplesMap.values());
	}
	
	public static void OnBeforeInsert (Map<Id,Call2_Sample_vod__c> oldCallSamplesMap,  List<Call2_Sample_vod__c> newCallSamplesList){
		quantityValidation(newCallSamplesList);
		giftComplianceCheck(newCallSamplesList);
	}
	
	private static void quantityValidation( List<Call2_Sample_vod__c> newCallSamplesList){	
    for(Call2_Sample_vod__c callSample : newCallSamplesList){
      if(callSample.Quantity_vod__c <= 0) { 
        callSample.Quantity_vod__c.addError(System.Label.GNE_SFA2_ErrMsg_Quantity_More_Than_Zero);
      }
    }				
  }
	
	private static void giftComplianceCheck(List<Call2_Sample_vod__c> newCallSampleList){
		String profileName = GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase();
		
    if(profileName.startsWith('GNE-SFA') && !profileName.startsWith('GNE-SFA-OPS')) { 
      for(Call2_Sample_vod__c cSample : newCallSampleList) {
      	if(String.isNotBlank(cSample.Call2_vod__c) && !cSample.Is_Valid_For_Gift_calc_gne__c) {
          cSample.addError(System.Label.GNE_SFA2_ErrMsg_Gift_Compliance_Message);
        }
      }
    }
  }
}