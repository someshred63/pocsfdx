public class EventLogAdminController {

    private final SFDC2Insights__c SFDC2Insights;
    public string pageMode = 'View';
    public List<EventLogFile> eventLogFileList = [SELECT CreatedDate, EventType ,Id ,LogDate,LogFileContentType,LogFileLength FROM EventLogFile ORDER BY CreatedDate DESC LIMIT 10000];
/*    public List<LogFile_Info__c> logInfoFileList = [SELECT Name, of_Events__c, Date__c, Events_Reported__c, LogFile_Type__c, ID__c, Status__c, CreatedDate, 
                                                        EventLogFilePollingHistory__c,
                                                        EventLogFilePollingHistory__r.Name,
                                                        EventLogFilePollingHistory__r.PollingTime__c
                                                        FROM logFile_Info__c LIMIT 1000]; */
    
    public EventLogAdminController(ApexPages.StandardController stdController){
        List<SFDC2Insights__c> s2is = [SELECT Id, Advanced_Data__c, Custom_Event__c, PollingFrequency__c, Max_Insights_Intake__c, NR_Account_ID__c, PollingMode__c, PollingTime__c FROM SFDC2Insights__c LIMIT 1];
        if(s2is.isEmpty()){
            this.SFDC2Insights = (SFDC2Insights__c)stdController.getRecord();
        }
        else{
            this.SFDC2Insights = s2is[0];
        }
    }
    
    public String getPageMode(){
        return PageMode;
    }
    
    public void setPageMode(string PageMode){
        this.PageMode = pageMode;
    }
    
    public void setPagemodeToEdit(){
        this.pageMode = 'Edit';
    }
    
    public void setPagemodeToView(){
        this.pageMode = 'View';
    }    
    
    Public static Set<String> runningStatuses(){
        Set<String> runningStatuses = new Set<String>();
        runningStatuses.add('WAITING');
        runningStatuses.add('QUEUED');
        runningStatuses.add('ACQUIRED');
        runningStatuses.add('EXECUTING');
        runningStatuses.add('PAUSED');
        return runningStatuses;
    }
    
    // public static final List<LogFile_Info__c> InProgressEventLogs = [SELECT Id, Name, of_Events__c, Date__c, Events_Reported__c, ID__c, LogFile_Type__c, Status__c FROM LogFile_Info__c WHERE Status__c = 'IN PROGRESS' ORDER BY LastModifiedDate DESC LIMIT 1000];

    public SFDC2Insights__c getCurrentRecord(){

        SFDC2Insights__c currentRecord = SFDC2Insights;
        if(currentRecord.Id == null){

        }

        return currentRecord;
    }

    private static Set<Id> allRecordIds(){
        List<SFDC2Insights__c> allRecords = [SELECT Id FROM SFDC2Insights__c LIMIT 10000];
        Set<Id> allRecordIds = new Set<Id>();
        for(SFDC2Insights__c allRec : allRecords){
            allRecordIds.add(allRec.Id);
        }
        return allRecordIds;
    }
    
    public static Boolean getIsSchedulerRunning(){
        Boolean isSchedulerRunning = false;
        Set<String> runningStatuses = runningStatuses();
        List<CronTrigger> ctsELF = [SELECT ID, CronJobDetailID, cronJobDetail.Name FROM CronTrigger WHERE cronJobDetail.Name LIKE 'EventLogFile_%' AND State IN : runningStatuses LIMIT 10000];
        if(ctsElf.isEmpty() != true){ 
            isSchedulerRunning  = true;
        }
        return isSchedulerRunning ;
    }
    
    public void InsightsSetup(){
        II.InsightsSetup('new_account');
    }
    
    public PageReference setup(){
        PageReference pr = new PageReference('/apex/II_Setup');
		return pr;
    }

    public void stopPolling(){
        Set<Id> cronDetailsToDelete = new Set<Id>();
        Set<String> runningStatuses = runningStatuses();
        List<CronTrigger> cts = [SELECT ID, CronJobDetailID, cronJobDetail.Name FROM CronTrigger WHERE cronJobDetail.Name LIKE 'EventLogFile_%' AND State IN: runningStatuses ORDER BY PreviousFireTime DESC LIMIT 100];
        for(CronTrigger ct : cts){
            system.abortJob(ct.Id);
        }
        SFDC2Insights.PollingTime__c = '--:--';
        Save();
    }
    public void startPolling(){
        stopPolling();
    
        Elf_Scheduler m = new Elf_Scheduler();
        DateTime nowPlus1Min = system.now().addMinutes(+1);
        String nowMn = string.valueOf(nowPlus1Min.minute());
        String nowHr = string.valueOf(nowPlus1Min.hour());
        String nowDy = string.valueOf(nowPlus1Min.day());
        String nowMo = string.valueOf(nowPlus1Min.month());
        String nowYr = string.valueOf(nowPlus1Min.year());
        String nowCron = '0 '+ nowMn + ' ' + nowHr + ' ' + nowDy + ' ' + nowMo + ' ? ' + nowYr;
        String nowName = nowYr + '-' + nowMn + '-' + nowDy + '-' + nowHr + ':' + nowMn;
        String jobName = 'EventLogFile_' + nowName;
        String jobID = system.schedule(jobName, nowCron , m);

        SFDC2Insights.PollingTime__c = string.valueOf(nowPlus1Min);

        Save();
        
     }

    public void resetSchedule(){
    }
    
    public string getNextPollingTime(){
        Set<String> runningStatuses = runningStatuses();
        List<CronTrigger> ctsELF = [SELECT ID, CronJobDetailID, nextFireTime, cronJobDetail.Name FROM CronTrigger WHERE cronJobDetail.Name LIKE 'EventLogFile_%' AND State IN : runningStatuses ORDER BY CreatedDate DESC LIMIT 1];
        String nextPollingTime;
        if(!ctsELF.isEmpty()){
            nextPollingTime = string.valueOf(ctsELF[0].NextFireTime);
        }
        else{
            nextPollingTime = '--:--';
        }
        return nextPollingTime;
    }

    public void Save(){
        Set<Id> allRecordIds = new Set<Id>();
        allRecordIds = allRecordIds();
        if(allRecordIds.isEmpty()){
            SFDC2Insights.Name = 'Default App Settings';
            insert SFDC2Insights;

        }
        else if(allRecordIds.size() > 1){
            Id currentId = SFDC2Insights.Id;
            allRecordIds.remove(currentId);
            SFDC2Insights__c recordsToDelete = [SELECT ID FROM SFDC2Insights__c WHERE Id IN : allRecordIds];
            delete RecordsToDelete;
            update SFDC2Insights;
        }
        else{
            update SFDC2Insights;
        }
        setPageModeToView();
    }
}