global with sharing class gFRS_Ltng_Internal_User_Activation_Sched implements Schedulable {

    global void execute(SchedulableContext sc){
        Type targettype = Type.forName('gFRS_Ltng_Internal_User_Activation_Batch');
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
    }
}