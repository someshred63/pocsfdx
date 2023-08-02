global class GCSVoiceCallBusinessHoursUpdateScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {
         GCSVoiceCallBusinessHoursUpdate b = new GCSVoiceCallBusinessHoursUpdate(); 
      		database.executebatch(b);
    }
}