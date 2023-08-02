/******************************************************************************************************
@Name : GNE_ScheduleQueuableClassUtility
@Description : Schedules all types of queable classes to run immediately 
******************************************************************************************************/
public class GNE_ScheduleQueuableClassUtility {
    String classnameToBeScheduled   = '';
    String whenToRun                = '';
    String sObjectRecordIdToProcess = '';
    Integer runCounter              = 0;
    String resource;
    String method;
    String body;

    
    public GNE_ScheduleQueuableClassUtility(String classnameToBeScheduled, Integer pwhenToRun, String recordId,  String resource, String method, String body) {
        this.classnameToBeScheduled     = classnameToBeScheduled;
        datetime cronTorunNow = null;
        if (pwhenToRun == 0) {
            runCounter = runCounter + 5;
            cronTorunNow = Datetime.now().addSeconds(runCounter);
        } else {
            pwhenToRun = pwhenToRun + 2;
            cronTorunNow = Datetime.now().addSeconds(pwhenToRun);
        }
        String ppwhenToRun = String.valueOf(cronTOrunNow.second()) + ' ' + 
            String.valueof(cronTOrunNow.minute())+ ' ' + 
            String.valueof(cronTOrunNow.hour()) + ' ' + 
            String.valueof(cronTOrunNow.day()) + ' ' + 
            String.valueof(cronTOrunNow.month()) + ' ' + '?'  + ' ' + 
            String.valueof(cronTOrunNow.year());
        this.whenToRun = ppwhenToRun;          
        this.sObjectRecordIdToProcess   = recordId;
        this.resource                   = resource;
        this.method                     = method;
        this.body                       = body;
    }
    
    public void scheduleQueuableClass() {
        Type t = Type.forName(this.classnameToBeScheduled );
        GNE_SchedulableInterface classnameToBeSchedule = (GNE_SchedulableInterface)t.newInstance();
        try {
            Integer randomInt = System.Crypto.getRandomInteger();
            Id scheduleID  = System.schedule('Schedule Queue Class ' + classnameToBeScheduled + ' > ' + String.valueOf(randomInt), this.whenToRun, classnameToBeSchedule);
            GNE_Schedule_Information__c scheduleInfo = new GNE_Schedule_Information__c();
            scheduleInfo.GNE_ReferenceRecord_ID__c = this.sObjectRecordIdToProcess;
            scheduleInfo.Name = scheduleID;
            scheduleInfo.Request_Body__c = body;
            scheduleInfo.Request_Method__c = method;
            scheduleInfo.Request_Source__c = resource;

            insert scheduleInfo;
        } catch (Exception e){
            System.debug(e.getStackTraceString());
        }
    }  
}