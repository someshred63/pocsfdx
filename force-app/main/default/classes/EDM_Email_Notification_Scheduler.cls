global class EDM_Email_Notification_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        EDM_ADM_Periodical_Notification classificationReminder = new EDM_ADM_Periodical_Notification();
    }
}