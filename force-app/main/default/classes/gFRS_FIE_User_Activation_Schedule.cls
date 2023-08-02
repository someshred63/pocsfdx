global with sharing class gFRS_FIE_User_Activation_Schedule implements Schedulable {

    global void execute(SchedulableContext sc){
        Type targettype = Type.forName('gFRS_FIE_User_Activation_Batch');
        if (targettype != null) {
            Database.Batchable<sObject> obj = (Database.Batchable<sObject>) targettype.NewInstance();
            Database.executeBatch(obj);
        }
    }
}