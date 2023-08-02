public with sharing class GNE_SFA2_Field_Handler_AddressInactive implements CORE_Subscribe_Interface.Field_Handler {
	
	/*If account is default it has to be active */    
    public Object handle(sObject sourceObject, sObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc){
        Boolean value = (Boolean)sourceObject.get(fc.Source_Field_gne__c);
        if (value == true){
            return false;
        }else if(targetObject.get(fc.Target_Field_gne__c) != null){
            return Boolean.valueOf(targetObject.get(fc.Target_Field_gne__c));
        }else{
        	return false;
        }
    }
}