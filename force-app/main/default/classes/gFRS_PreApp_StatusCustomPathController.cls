public without sharing class gFRS_PreApp_StatusCustomPathController {
    @AuraEnabled
    public static StatusWrapper getStatusPicklistValues(String recordId) {
        StatusWrapper customWrapper = new StatusWrapper();
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Pre_Application__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry eachPicklistValue:picklist) {
            options.put((String)eachPicklistValue.getLabel(),(String)eachPicklistValue.getValue());
            //options.put((String)eachPicklistValue.getLabel(),)
        }
        customWrapper.options = options;
        customWrapper.statusPicklistValue = [select id, Status__c from gFRS_Ltng_Pre_Application__c where id=:recordId].Status__c;
        return customWrapper;
    }
    public class StatusWrapper {
        @AuraEnabled
        public Map<String,String> options = new Map<String,String>();
        @AuraEnabled
        public String statusPicklistValue;
    }
}