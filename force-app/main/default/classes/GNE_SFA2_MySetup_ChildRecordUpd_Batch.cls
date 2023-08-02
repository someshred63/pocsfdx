global class GNE_SFA2_MySetup_ChildRecordUpd_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private Set<Id> idsForProcess;

    public GNE_SFA2_MySetup_ChildRecordUpd_Batch(Set<Id> idsForProcess) {
        this.idsForProcess = idsForProcess;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OwnerId FROM My_Setup_Products_vod__c WHERE Id IN :idsForProcess';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<My_Setup_Products_vod__c> scope) {
        GNE_SFA2_MySetup_ChildRecord_Update.stampTsfRecords(scope, false);
    }

    global void finish(Database.BatchableContext BC) {

    }
}