trigger CORE_Pub_TDDD_License_Trigger on CORE_Pub_TDDD_License__c (before insert, before update) {
    if (Trigger.isInsert) {
        CORE_Pub_Module.populateLookupRefColumn (Trigger.new, 'Party_Id_gne__c', 'Party_Id_ref_gne__c', 'CORE_Pub_Party__c', 'Party_Id_gne__c');
    }
}