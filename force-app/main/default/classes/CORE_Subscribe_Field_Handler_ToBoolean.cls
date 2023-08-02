public with sharing class CORE_Subscribe_Field_Handler_ToBoolean implements CORE_Subscribe_Interface.Field_Handler {
    
    public Object handle(sObject sourceObject, sObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc){
        String value = (String)sourceObject.get(fc.Source_Field_gne__c);
        Boolean result; 
        if(value == null){
            result = false;
        }else if (value == 'Y' || value == 'A'){
            result = true;
        }else{
            result = false;
        }
        return result;
    }
}