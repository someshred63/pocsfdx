global  with sharing class gFRS_ApprovalEmailReminder implements Schedulable{
    
    global void execute(SchedulableContext sc){
        Type targettype = Type.forName('gFRS_ApprovalEmailReminderBatch');

        if (targettype != null) {
        System.debug('PN::gFRS_ApprovalEmailReminder : start');
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        System.debug('PN::gFRS_ApprovalEmailReminder : end'); 
        }
    }
}