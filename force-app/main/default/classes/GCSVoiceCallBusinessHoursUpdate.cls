public class GCSVoiceCallBusinessHoursUpdate implements Database.Batchable<sObject>{

    public string query;
    public BusinessHours bh;
    public Database.QueryLocator start(Database.BatchableContext BC){
        Datetime dtOneHourFifteenMinus = DateTime.now().addHours(-1).addMinutes(-15);
      	DateTime dtFiveMinuteMinus = DateTime.now().addMinutes(-5);
        String dis = 'Completed';
        
        query = 'SELECT Id, CallDisposition, Is_Within_Business_Hours__c, CallStartDateTime FROM VoiceCall WHERE Is_Within_Business_Hours__c = false AND CreatedDate >=:dtOneHourFifteenMinus AND CreatedDate <=: dtFiveMinuteMinus AND CallDisposition =\''+ dis +'\'';
          
      return Database.getQueryLocator(query);
   }

   public void execute(Database.BatchableContext BC, List<sObject> scope){
       List<VoiceCall> voiceCallList = new list<VoiceCall>();
     for(VoiceCall vc : (List<VoiceCall>)scope){
         System.debug('******vc*******'+vc);
         bh = [SELECT Id FROM BusinessHours WHERE Name =:'GCS Telephony Business Hours'];
  		vc.Is_Within_Business_Hours__c = BusinessHours.isWithin(bh.id, vc.CallStartDateTime);
         
         voiceCallList.add(vc);
     }
     database.update(voiceCallList, false);
    }

   public void finish(Database.BatchableContext BC){
   }
}