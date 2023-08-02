public with sharing class CORE_Subscribe_Field_Handler_JsonList implements CORE_Subscribe_Interface.Field_Handler {
    
    public Object handle(sObject sourceObject, sObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc){
        String value = (String)sourceObject.get(fc.Source_Field_gne__c);
        String result = '';
        if(value != null){
            List<Wrapper> wrappers = (List<Wrapper>)JSON.deserialize((String)value, List<Wrapper>.class);
            system.debug(wrappers);
            for(Wrapper wrapper : wrappers){
                result += wrapper.value+';';
            }
            result = result.substring(0, result.length()-1);
        }
        return result;
    }
    
     class Wrapper{
        public String value;
    }
}