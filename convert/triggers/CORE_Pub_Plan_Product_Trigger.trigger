trigger CORE_Pub_Plan_Product_Trigger on CORE_Pub_Plan_Product__c (before insert, before update) {
    if(Trigger.isInsert){
    	CORE_Pub_Module.populateLookupRefColumn (trigger.new, 'Party_Id_gne__c', 'Party_Id_ref_gne__c', 'CORE_Pub_Party__c', 'Party_Id_gne__c');
    }
}