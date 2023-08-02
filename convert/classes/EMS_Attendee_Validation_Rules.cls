public without sharing class EMS_Attendee_Validation_Rules {

    public static boolean onBeforeUpdate(List<EMS_Attendee_gne__c> triggerOld, List<EMS_Attendee_gne__c> triggerNew) {
        boolean result = false;
        if (EMS_Attendee_Trigger_Helper.skipTriggerValidationRules == false) {
            result = checkRequiredFields(triggerNew);
        }
        return result;
    }

    public static boolean checkRequiredFields(List<EMS_Attendee_gne__c> triggerNew) {
        for (EMS_Attendee_gne__c newAtt : triggerNew) {
            if (String.isEmpty(newAtt.Status_gne__c)) {
                triggerNew[0].addError('Field Status is required.');
                return true;
            }
        }
        return false;
    }
}