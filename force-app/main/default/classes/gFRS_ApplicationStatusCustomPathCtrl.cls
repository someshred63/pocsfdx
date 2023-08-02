public class gFRS_ApplicationStatusCustomPathCtrl {
@AuraEnabled
    public static StatusWrapper getStatusPicklistValues(String recordId) {
        StatusWrapper customWrapper = new StatusWrapper();
        Map<String,String> options = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Application__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry eachPicklistValue:picklist) {
            options.put((String)eachPicklistValue.getLabel(),(String)eachPicklistValue.getValue());
            //options.put((String)eachPicklistValue.getLabel(),)
        }
        customWrapper.options = options;        
        customWrapper.objApp = [select id,Status__c,RFI_StatusCheck__c  from gFRS_Ltng_Application__c where id=:recordId];

     return customWrapper;  
    }
    
    public class StatusWrapper {
        @AuraEnabled
        public Map<String,String> options = new Map<String,String>();
        @AuraEnabled
        public gFRS_Ltng_Application__c objApp;
    }
}