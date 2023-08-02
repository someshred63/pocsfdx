global class GNE_CM_PACT_Activation_EmailScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GNE_CM_PACT_Activation_Email_Sender());
    }
}