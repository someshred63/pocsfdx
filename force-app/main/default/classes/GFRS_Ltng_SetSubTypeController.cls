public with sharing class GFRS_Ltng_SetSubTypeController {

    @InvocableMethod(label='Publish Event')
    public static void fetchEventData(List<Info> input) {
        if (!System.isBatch() && !System.isFuture()) {
            publishEvent(input[0].recordId, input[0].recordTypeName);
        }
    }

    @future
    public static void publishEvent(String recordId, String recordTypeName) {
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        Integer delay = 1000 * Integer.valueOf(System.Label.Event_Delay);
        while ((finishTime - startTime) < delay) {
            // Sleep for mentioned delay
            finishTime = DateTime.now().getTime();
        }
        gFRS_Application_RecordType_Change__e evt = new gFRS_Application_RecordType_Change__e();
        evt.Record_Id__c = recordId;
        evt.Record_Type_Name__c = recordTypeName;
        Eventbus.publish(new List<gFRS_Application_RecordType_Change__e> {evt});
    }

    @AuraEnabled
    public static void updateFundingSubType(Id recordId, String subType) {
        gFRS_Ltng_Application__c obj = new gFRS_Ltng_Application__c();
        obj.Funding_Sub_Type__c = subType;
        obj.Id = recordId;
        update obj;
    }

    public class Info {
        @InvocableVariable
        public String recordId;
        @InvocableVariable
        public String recordTypeName;
    }
}