global class EDM_Send_Remainder_To_Prt_Usr_Schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        EDM_Send_Remainder_To_Partner_Usr_Batch b = new EDM_Send_Remainder_To_Partner_Usr_Batch();
        database.executebatch(b);
    }
}