global class EMS_Delegation_Scheduler implements Schedulable {

    public EMS_Delegation_Scheduler() {

    }

    global void execute(SchedulableContext ctx) {
        EMS_User_Delegation_Batch udb = new EMS_User_Delegation_Batch();
        Database.executeBatch(udb);
    }
}