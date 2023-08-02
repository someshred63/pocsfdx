global with sharing class gFRS_AnnualEvalutationTaskCreator implements Schedulable{

    global void execute(SchedulableContext sc) {
        Type targettype = Type.forName('gFRS_CreateAnnualReportTasksBatch');

        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
    }
}