public with sharing class EMS_Message_Controller {
    static Set<Id> excludedUsers = new Set<Id> {
            '0050g000006f9cUAAQ'
    };

    public EMS_Message_Controller() {
    }

    @RemoteAction
    public static List<EMS_Message__c> getMessages() {
        if(excludedUsers.contains(UserInfo.getUserId())) {
            return new List<EMS_Message__c>();
        }

        return [
                SELECT Id, Name, Body__c, Title__c, Video_URL__c, Start_Date__c, End_Date__c, Active__c
                FROM EMS_Message__c
                WHERE Start_Date__c <= :Date.today() AND (End_Date__c >= :Date.today() OR End_Date__c = NULL)
                AND Active__c = TRUE
                AND Id NOT IN (SELECT EMS_Message__c FROM EMS_Message_Awareness__c WHERE CreatedById = :UserInfo.getUserId())
                ORDER BY Start_Date__c ASC, CreatedDate ASC
        ];
    }

    @RemoteAction
    public static Object confirmMessage(EMS_Message__c message) {
        EMS_Message_Awareness__c awareness = new EMS_Message_Awareness__c(
                EMS_Message__c = message.Id
        );
        Database.SaveResult saveResult = Database.insert(awareness);
        return new Map<String, Object>{
                'status' => saveResult.isSuccess(),
                'EMS_Message__c' => message,
                'EMS_Message_Awareness__c' => awareness,
                'SaveResult' => saveResult,
                'errors' => saveResult.getErrors()
        };
    }
}