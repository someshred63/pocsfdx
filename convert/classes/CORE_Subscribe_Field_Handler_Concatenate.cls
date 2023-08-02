public with sharing class CORE_Subscribe_Field_Handler_Concatenate implements CORE_Subscribe_Interface.Field_Handler {
    
    public Object handle(sObject sourceObject, sObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc){
    	if(sourceObject.get(fc.Source_Field_gne__c) != null){
	        return ((String)targetObject.get(fc.Target_Field_gne__c)) + ' '+ ((String)sourceObject.get(fc.Source_Field_gne__c));
    	}
    	return targetObject.get(fc.Target_Field_gne__c);
    }
}