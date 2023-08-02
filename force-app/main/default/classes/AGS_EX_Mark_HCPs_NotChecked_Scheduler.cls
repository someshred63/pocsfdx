global class AGS_EX_Mark_HCPs_NotChecked_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        AGS_EX_Mark_HCPs_NotChecked_Batch markHCPs = new AGS_EX_Mark_HCPs_NotChecked_Batch();
        database.executebatch(markHCPs);
    }
}