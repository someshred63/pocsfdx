global class GNE_SFA2_CAN_Remove_Affiliations_Batch implements Database.Batchable<sObject>, Database.Stateful {

    private String query;
    public GNE_SFA2_CAN_Remove_Affiliations_Batch(String query) {
        this.query = query;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        Database.delete(scope, false);
    }

    global void finish(Database.BatchableContext BC) {

    }
}