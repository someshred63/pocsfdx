global class GNE_Subscribe_MCE_Scheduler implements Schedulable {
  private static final String LAST_DELTA_SCHEDULE_JOB_ID_CONFIG_ITEM = 'MceDeltaLastScheduleJobId';
  private static final String DELTA_SCHEDULE_TIME_CONFIG_ITEM = 'MceDeltaScheduleTime';
  private static final String DELTA_SCHEDULE_DISABLE_VALUE = 'disabled';
  private static final Integer BATCH_SIZE = 100;
  
  private static Boolean alreadyScheduled;
  
  global void execute(SchedulableContext SC) {
    GNE_Subscribe_MCE_Batch mceBatch = new GNE_Subscribe_MCE_Batch(false);
    Database.executeBatch(mceBatch, BATCH_SIZE); 
  }
  
  public static void scheduleDeltaRefresh() {
    if(GNE_Subscribe_MCE_Batch.isMceBatchMode!=true && alreadyScheduled!=true) {
      alreadyScheduled = true;
      Id jobId = getLastDeltaScheduleJobId();
      Id newJobId = intScheduleDeltaRefresh(jobId);
      
      if(newJobId!=jobId) {
        setLastDeltaScheduleJobId(newJobId);
      }
    }
  }
  
  private static Id intScheduleDeltaRefresh(Id jobId) {
    Id newJobId = null;
    DateTime scheduleDT = getDeltaScheduleTime();
    
    if(scheduleDT!=null && getCurrentScheduleJob(jobId)==null) {
        GNE_Subscribe_MCE_Batch mceBatch = new GNE_Subscribe_MCE_Batch(true, null);
        try {
            newJobId = System.scheduleBatch(mceBatch, mceBatch.getBatchName() + scheduleDT.format(' yyyy-MM-dd'), Integer.valueOf((scheduleDT.getTime()-System.now().getTime())/(1000*60))+1, BATCH_SIZE);
        } catch(Exception ex) {
            Batch_Runner_Error_Log_gne__c log = new Batch_Runner_Error_Log_gne__c(
                Batch_Name_gne__c = mceBatch.getBatchName(),
                Batch_Class_gne__c = GNE_Subscribe_MCE_Batch.class.getName(),
                Batch_Job_Id_gne__c = null,
                Batch_Start_Date_gne__c = System.now(),
                Error_Type_gne__c = GNE_Batch_Runner.LogErrorType.TRIGGER_ERROR.name(),
                Error_Subtype_gne__c = ex.getTypeName(),
                Error_Short_Description_gne__c = ex.getMessage(),
                Error_Description_gne__c = ex.getMessage() + '\nStackTrace:\n['+ ex.getStackTraceString() +']'
            );
            
            Database.insert(log, false);
        }
    }
    
    return newJobId!=null ? newJobId : jobId;
  }
  
  private static CronTrigger getCurrentScheduleJob(Id jobId) {
    CronTrigger job = null;
    
    if(String.isNotBlank(jobId)) {
      List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE Id = :jobId AND TimesTriggered = 0 LIMIT 1];
      
      for(CronTrigger iJob : jobs) {
          job = iJob;
      }
    }
    
    return job;
  }
  
  private static Id getLastDeltaScheduleJobId() {
    GNE_Foun_Misc_Config_Items_gne__c configItem = GNE_Foun_Misc_Config_Items_gne__c.getAll().get(LAST_DELTA_SCHEDULE_JOB_ID_CONFIG_ITEM);
    String lastScheduleJobIdAsString =  configItem!=null ? configItem.Configuration_Value_gne__c : null;
    return String.isNotBlank(lastScheduleJobIdAsString) ? (Id)lastScheduleJobIdAsString : null;
  }
  
  private static void setLastDeltaScheduleJobId(Id jobId) {
    GNE_Foun_Misc_Config_Items_gne__c configItem = GNE_Foun_Misc_Config_Items_gne__c.getAll().get(LAST_DELTA_SCHEDULE_JOB_ID_CONFIG_ITEM);

    if(configItem==null) {
      configItem = new GNE_Foun_Misc_Config_Items_gne__c(Name = LAST_DELTA_SCHEDULE_JOB_ID_CONFIG_ITEM);
    }  
    
    configItem.Configuration_Value_gne__c = jobId;
    Database.upsert(configItem, false);
  }
  
  private static DateTime getDeltaScheduleTime() {
    GNE_Foun_Misc_Config_Items_gne__c configItem = GNE_Foun_Misc_Config_Items_gne__c.getAll().get(DELTA_SCHEDULE_TIME_CONFIG_ITEM);
    Pattern dayAndTimePattern = Pattern.compile('(\\d|[\\*\\?]);(\\d{1,2}):(\\d{1,2})');
    String scheduleTimeAsString =  configItem!=null && String.isNotBlank(configItem.Configuration_Value_gne__c) ? configItem.Configuration_Value_gne__c : '';
    DateTime scheduleDT = null;
    
    if(scheduleTimeAsString!=DELTA_SCHEDULE_DISABLE_VALUE) {
	    scheduleTimeAsString = dayAndTimePattern.matcher(scheduleTimeAsString).matches() ? scheduleTimeAsString : '6;5:10';
        DateTime now = System.now();
        Integer currentDay = Integer.valueOf(now.formatGmt('u'));
        
        Matcher m = dayAndTimePattern.matcher(scheduleTimeAsString);
        m.find();
        Boolean dailyOrWeeklyMode = !m.group(1).isNumeric();
        Integer dayOfWeek = dailyOrWeeklyMode ? currentDay : Integer.valueOf(m.group(1));
        Integer hour = Integer.valueOf(m.group(2));
        Integer minute = Integer.valueOf(m.group(3));
        
        scheduleDT = DateTime.newInstanceGmt(now.dateGmt(), Time.newInstance(hour,minute,0,0));
        scheduleDT = scheduleDT.addDays(Math.mod(dayOfWeek+7-currentDay,7));
        scheduleDT = scheduleDT<=now ? scheduleDT.addDays(dailyOrWeeklyMode ? 1 : 7) : scheduleDT;
    }
    
    return scheduleDT;
  }
}