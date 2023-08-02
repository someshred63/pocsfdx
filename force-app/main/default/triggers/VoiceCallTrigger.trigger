trigger VoiceCallTrigger on VoiceCall (before update) {
    GCS_VoiceCallController voiceCallTriggerHandler = new GCS_VoiceCallController();
    BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name =:'GCS Telephony Business Hours'];
    for(VoiceCall v: trigger.new){
        
        if(v.CallDisposition == 'completed' && v.CallStartDateTime != null){
            v.Is_Within_Business_Hours__c = BusinessHours.isWithin(bh.id, v.CallStartDateTime);
        }
    }
    if(Trigger.isUpdate){
        voiceCallTriggerHandler.onBeforeUpdate(Trigger.new); 
    }
}