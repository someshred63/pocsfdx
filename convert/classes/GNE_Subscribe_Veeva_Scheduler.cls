global class GNE_Subscribe_Veeva_Scheduler  implements Schedulable {

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new GNE_Subscribe_Veeva(), 10);
    }
}