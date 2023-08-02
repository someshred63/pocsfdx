public class FCR_DeletePeepsBatch implements Database.Batchable<sObject>, Database.Stateful {
    private Datetime startProcessDT;
    public FCR_DeletePeepsBatch(Datetime startProcessDT) {
        this.startProcessDT = startProcessDT;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id FROM FCR_Peep_gne__c WHERE LastModifiedDate <  :startProcessDT AND Do_Not_Delete__c != true]);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }

}