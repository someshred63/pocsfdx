public with sharing class EDM_Process_Builder_Actions {

    @InvocableMethod
    public static void retriggerSpeakerBureauAgencies (List<Id> ids) {

        List<SObject> dummyUpdate = new List<SObject>();

        List<SObject> relatedMembers = [SELECT Id FROM Speaker_Bureau_Membership_gne__c WHERE Speaker_Bureau_ID_gne__c IN :ids];
        if (!relatedMembers.isEmpty()) {
            dummyUpdate.addAll(relatedMembers);
        }
         
        List<SObject> relatedEvents = [SELECT Id FROM Event_Curriculum_gne__c WHERE Id IN (SELECT Event_Curriculum_gne__c FROM Curriculum_Speaker_Bureau_gne__c WHERE Speaker_Bureau_gne__c IN :ids)];
        if (!relatedEvents.isEmpty()) {
            dummyUpdate.addAll(relatedEvents);
        }

        if (!dummyUpdate.isEmpty()) {
            update dummyUpdate;
        }
    }
}