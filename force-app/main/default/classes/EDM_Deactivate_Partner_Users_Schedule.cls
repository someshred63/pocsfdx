global class EDM_Deactivate_Partner_Users_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        EDM_Deactivate_Partner_Users_Batch b = new EDM_Deactivate_Partner_Users_Batch();
        database.executebatch(b);
    }
}