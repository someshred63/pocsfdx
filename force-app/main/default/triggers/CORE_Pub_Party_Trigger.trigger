trigger CORE_Pub_Party_Trigger on CORE_Pub_Party__c (before insert, before update) {
    
    if(!CORE_Subscribe_Util.isSubscribeProcess()) {
        CORE_Pub_Module.checkCustomRequiredConditionsForParty(Trigger.new);
        CORE_Pub_Module.validPartyFieldsBasedOnType(Trigger.new);

        if(Trigger.isInsert) {
            CORE_Pub_Module.validateJSONFieldsFormat(Trigger.new, null);
        } else {
            CORE_Pub_Module.validateJSONFieldsFormat(Trigger.new, Trigger.old);
        }   

        if(CORE_Pub_Module.isPubAdminMode()) {
            CORE_Pub_Module.assignBatchIndex(Trigger.new);
            CORE_Pub_Module.updateLastPubUpsertDate(Trigger.new);
        }
    }

}