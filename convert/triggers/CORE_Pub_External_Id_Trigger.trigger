trigger CORE_Pub_External_Id_Trigger on CORE_Pub_External_Id__c (before insert, before update) {
    if(Trigger.isInsert){
	    CORE_Pub_Module.populateLookupRefColumn (Trigger.new, 'Party_Id_gne__c', 'Party_Id_ref_gne__c', 'CORE_Pub_Party__c', 'Party_Id_gne__c');
	    CORE_Pub_Module.populateLookupRefColumn (Trigger.new, 'Party_Location_Id_gne__c', 'Party_Location_Id_ref_gne__c', 'CORE_Pub_Location__c', 'Party_Location_Id_gne__c');
    }
}