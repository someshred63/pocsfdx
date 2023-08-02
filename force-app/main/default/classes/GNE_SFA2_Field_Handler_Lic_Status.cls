public with sharing class GNE_SFA2_Field_Handler_Lic_Status implements CORE_Subscribe_Interface.Field_Handler {

    public Object handle(SObject sourceObject, SObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc) {
        if (sourceObject instanceof CORE_Pub_License__c) {
            if (sourceObject.get(fc.Source_Field_gne__c) != null && sourceObject.get(fc.Source_Field_gne__c) == 'Y') {
                return 'Valid_vod';
            }
            return 'Invalid_vod';
        } else if (sourceObject instanceof CORE_Pub_TDDD_License__c) {
            if (sourceObject.get(fc.Source_Field_gne__c) != null && sourceObject.get(fc.Source_Field_gne__c) == 'A') {
                return 'ACTIVE';
            } else if (sourceObject.get(fc.Source_Field_gne__c) != null && sourceObject.get(fc.Source_Field_gne__c) == 'I') {
                return 'INACTIVE';
            }
        }
        return sourceObject.get(fc.Source_Field_gne__c);
    }
}