public without sharing class EMS_Attachment_Validation_Rules {

    private static Map<Id, EMS_Event__c> relatedEventsMap = new Map<Id, EMS_Event__c>();
    private static Set<String> statusesAllowedForSignedContract = new Set<String>{
            'Contract Initiated',          'Closed', 'Payment Initiated',         'Contract Received',        // Overall Status
            'Awaiting Signature from HCP', 'Closed', 'Payment Request Initiated', 'Signed Agreement Received' // Status
    };

    private static Boolean validateSignedContractAARC(EMS_Attachment_gne__c newAttachment) {
        if (newAttachment.Type_gne__c == 'Signed Contract' && !EMS_Access.isBPS() && !EMS_Access.isAdmin()) {
            newAttachment.addError(System.Label.EMS_Signed_Contract_AARC);
            return true;
        } else {
            return false;
        }
    }

    private static Boolean validateSignedContractAwaitingSignature(EMS_Attachment_gne__c newAttachment) {
        String eventStatus = relatedEventsMap.get(newAttachment.EMS_Event_gne__c).Overall_Status_gne__c;
        if (newAttachment.Type_gne__c == 'Signed Contract' && !statusesAllowedForSignedContract.contains(eventStatus)) {
            newAttachment.addError(System.Label.EMS_Signed_Contract_Awaiting_Signature);
            return true;
        } else {
            return false;
        }
    }

    private static Boolean validateHyperlink(EMS_Attachment_gne__c newAttachment) {
        if (String.isBlank(newAttachment.File_gne__c) && String.isBlank(newAttachment.Description_gne__c)) {
            newAttachment.addError(System.Label.Must_Enter_A_Value + ': Hyperlink / File / Description');
            return false;
        } else {
            return false;
        }
    }

    private static Boolean validateType(EMS_Attachment_gne__c newAttachment) {
        if (String.isEmpty(newAttachment.Type_gne__c)) {
            newAttachment.Type_gne__c.addError(System.Label.Must_Enter_A_Value + ': ' + Schema.SObjectType.EMS_Attachment_gne__c.fields.Type_gne__c.label);
            return true;
        } else {
            return false;
        }
    }

    private static void fetchRelatedEvents(List<EMS_Attachment_gne__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Attachment_gne__c attachment : triggerNew) {
            eventIds.add(attachment.EMS_Event_gne__c);
        }
        // select related events
        for (EMS_Event__c event : [SELECT Status_gne__c, Overall_Status_gne__c FROM EMS_Event__c WHERE Id IN :eventIds]) {
            relatedEventsMap.put(event.Id, event);
        }
    }

    public static Boolean onBeforeInsertUpdate(List<EMS_Attachment_gne__c> triggerOld, List<EMS_Attachment_gne__c> triggerNew) {
        fetchRelatedEvents(triggerNew);
        Boolean result = false;
        for (EMS_Attachment_gne__c attachment : triggerNew) {
            result = validateSignedContractAwaitingSignature(attachment)
                    || validateHyperlink(attachment)
                    || validateSignedContractAARC(attachment)
                    || validateType(attachment);
        }

        return result;
    }

}