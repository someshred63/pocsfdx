global with sharing class gFRS_Ltng_ApprovalEmailReminder implements Schedulable {

    global void execute(SchedulableContext sc){
        Type targettype = Type.forName('gFRS_Ltng_ApprovalEmailReminderBatch');
        if (targettype != null) {
        System.debug('PN::gFRS_Ltng_ApprovalEmailReminder : start');
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        System.debug('PN::gFRS_Ltng_ApprovalEmailReminder : end'); 
        }
    }
}