public without sharing class GNE_SFA2_Scheduler implements Database.Batchable<sObject>, Database.Stateful {
    public Enum JobType {Queued, Processing, Scheduled, Executed, Failed}
    
    private static final String SCHEDULER_JOB_PREFIX = 'SFA Scheduler - ';
    private static final String SCHEDULER_JOB_SUFIX_DATE_FORMAT = 'yyyy-MM-dd';
    private static final Integer BATCH_SIZE = 1;
    private static final String SCHEDULE_DISABLE_VALUE = 'disabled';
    
    
    private static Set<String> alreadyScheduled;
    private String jobType;
    
    // START STATIC METHODS
    
    public static Id scheduleJob(GNE_SFA2_Scheduler.Schedulable handler, String jobType, String scheduledExpression) {
        return scheduleJob(handler, jobType, scheduledExpression, null);
    } 
    
    public static Id scheduleJob(GNE_SFA2_Scheduler.Schedulable handler, String jobType, String scheduledExpression, Map<String,String> jobProperties) {
        Id newJobId = null;
        
        if(alreadyScheduled==null) {
            alreadyScheduled = new Set<String>();
        }
        
        if(alreadyScheduled.add(jobType.toUpperCase())) {
            newJobId = intScheduleJob(handler, jobType, scheduledExpression, jobProperties);
        }
        
        return newJobId;
    }
    
    private static Id intScheduleJob(GNE_SFA2_Scheduler.Schedulable handler, String jobType, String scheduledExpression, Map<String,String> jobProperties) {
        SFA2_Scheduler_Job_gne__c job = getSchedulerJob(jobType, true);
        
        if(job!=null) {
	        DateTime scheduleDT = getJobScheduleTime(scheduledExpression);
	        CronTrigger cronJob = getCurrentScheduleCronJob(job.Cron_Job_Id_gne__c);
	        DateTime nowTimeStamp = DateTime.now();
	        
	        if(scheduleDT!=null && cronJob==null && job.Status_gne__c!=GNE_SFA2_Scheduler.JobType.Queued.name()) {
	            job.Queued_Date_gne__c = nowTimeStamp;
	            job.Scheduled_Date_gne__c = job.Executed_Date_gne__c = null;
	            job.Status_gne__c = GNE_SFA2_Scheduler.JobType.Queued.name();
	            job.Status_Details_gne__c = null;
	            job.Cron_Job_Id_gne__c = null;
	            job.Job_Properties_json_gne__c = jobProperties!=null && !jobProperties.isEmpty() ? JSON.serialize(jobProperties) : null;
	            job.Scheduled_Expression_gne__c = scheduledExpression;
	            job.Handler_json_gne__c = JSON.serialize(handler);
	            job.Handler_Class_gne__c = handler.getSelfClass().getName();
	            job.OwnerId = UserInfo.getUserId();
	            
	            if(!System.isFuture() && !System.isBatch() && !System.isQueueable() && !System.isScheduled()) {
	                scheduleJob(job, true);
	            }
	            
	            Database.upsert(job, SFA2_Scheduler_Job_gne__c.Job_Type_gne__c, false);
	        }
        }
        
        return job!=null ? job.Id : null;
    }
    
    public static void onUpdateSchedulerJob(List<SFA2_Scheduler_Job_gne__c> triggerNew, List<SFA2_Scheduler_Job_gne__c> triggerOld) {
        Integer idx=0;
        for(SFA2_Scheduler_Job_gne__c job : triggerNew) {
            SFA2_Scheduler_Job_gne__c oldJob = triggerOld[idx++];
            
            if(job.Status_gne__c==GNE_SFA2_Scheduler.JobType.Processing.name() && oldJob.Status_gne__c==GNE_SFA2_Scheduler.JobType.Queued.name()) {
                scheduleJob(job);
            }
        }
    }
    
    public static void onDeleteSchedulerJob(List<SFA2_Scheduler_Job_gne__c> triggerOld) {
        Integer idx=0;
        for(SFA2_Scheduler_Job_gne__c job : triggerOld) {
            
            if(job.Status_gne__c==GNE_SFA2_Scheduler.JobType.Scheduled.name() && String.isNotBlank(job.Cron_Job_Id_gne__c) && job.Cron_Job_Id_gne__c instanceof Id) {
                try { System.abortJob(job.Cron_Job_Id_gne__c); } catch(Exception ex) {}
            }
        }
    }
    
    public static void scheduleJob(SFA2_Scheduler_Job_gne__c job) {
        scheduleJob(job, false);
    }
    
    public static void scheduleJob(SFA2_Scheduler_Job_gne__c job, Boolean tryAgainMode) {
        try {
            DateTime scheduleDT = getJobScheduleTime(job.Scheduled_Expression_gne__c);
            String jobType = job.Job_Type_gne__c;
            GNE_SFA2_Scheduler scheduler = new GNE_SFA2_Scheduler(jobType);
            job.Cron_Job_Id_gne__c = System.scheduleBatch(scheduler, SCHEDULER_JOB_PREFIX + jobType + ' ' + scheduleDT.format(SCHEDULER_JOB_SUFIX_DATE_FORMAT), Integer.valueOf((scheduleDT.getTime()-System.now().getTime())/(1000*60))+1, BATCH_SIZE);
            job.Status_gne__c = GNE_SFA2_Scheduler.JobType.Scheduled.name();    
            job.Scheduled_Date_gne__c = DateTime.now();
        } catch(Exception ex) {
            if(tryAgainMode!=true) {
                job.Status_gne__c = GNE_SFA2_Scheduler.JobType.Failed.name();
                job.Status_Details_gne__c = ex.getMessage() + '\n' + ex.getStackTraceString();
            }
            
            logException(ex, job.Job_Type_gne__c);  
        }
    }
    
    private static SFA2_Scheduler_Job_gne__c getSchedulerJob(String jobType, Boolean lockRecord) {
        SFA2_Scheduler_Job_gne__c result = null;
        
        if(lockRecord) {
            try {
	            List<SFA2_Scheduler_Job_gne__c> jobs = [
	                SELECT Job_Type_gne__c, Status_gne__c, Cron_Job_Id_gne__c,
	                    Job_Properties_json_gne__c, Handler_json_gne__c, Handler_Class_gne__c,
	                    Scheduled_Expression_gne__c, Queued_Date_gne__c, Scheduled_Date_gne__c, Executed_Date_gne__c
	                FROM SFA2_Scheduler_Job_gne__c
	                WHERE Job_Type_gne__c = :jobType
	                FOR UPDATE
	            ];
	            
	            result = !jobs.isEmpty() ? jobs[0] : new SFA2_Scheduler_Job_gne__c(Name = jobType, Job_Type_gne__c = jobType);
            } catch(Exception ex) {}
        } else {
	        List<SFA2_Scheduler_Job_gne__c> jobs = [
	            SELECT Job_Type_gne__c, Status_gne__c, Cron_Job_Id_gne__c,
	                Job_Properties_json_gne__c, Handler_json_gne__c, Handler_Class_gne__c,
	                Scheduled_Expression_gne__c, Queued_Date_gne__c, Scheduled_Date_gne__c, Executed_Date_gne__c
	            FROM SFA2_Scheduler_Job_gne__c
	            WHERE Job_Type_gne__c = :jobType
	        ];
	        
	        result = !jobs.isEmpty() ? jobs[0] : new SFA2_Scheduler_Job_gne__c(Name = jobType, Job_Type_gne__c = jobType);
        }
        return result;
    }
    
    private static DateTime getJobScheduleTime(String scheduledExpression) {
        DateTime result = null;
        String scheduleTimeAsString = scheduledExpression;
        
	    if(scheduleTimeAsString!=SCHEDULE_DISABLE_VALUE) {
	        Pattern dayAndTimePattern = Pattern.compile('(\\d|[\\*\\?]);(\\d{1,2}|[\\*\\?]):(\\d{1,2}|[\\*\\?])');
            scheduleTimeAsString = dayAndTimePattern.matcher(scheduleTimeAsString).matches() ? scheduleTimeAsString : '6;5:10';
	        DateTime now = DateTime.now();
	        Integer currentDay = Integer.valueOf(now.formatGmt('u'));
	        Integer currentHour = Integer.valueOf(now.formatGmt('HH'));
	        Integer currentMinute = Integer.valueOf(now.formatGmt('mm'));
	        
	        Matcher m = dayAndTimePattern.matcher(scheduleTimeAsString);
	        m.find();
	        Boolean dailyOrWeeklyMode = !m.group(1).isNumeric();
	        Integer dayOfWeek = dailyOrWeeklyMode ? currentDay : Integer.valueOf(m.group(1));
	        
	        Boolean hourlyMode = !m.group(2).isNumeric();
	        Integer hour = hourlyMode ? currentHour : Integer.valueOf(m.group(2));
	        
	        Boolean minutelyMode = !m.group(3).isNumeric();
	        Integer minute = minutelyMode ? currentMinute : Integer.valueOf(m.group(3));
	        
	        result = DateTime.newInstanceGmt(now.dateGmt(), Time.newInstance(hour,minute,0,0));
	        result = result.addDays(Math.mod(dayOfWeek+7-currentDay,7));
	        
	        result = result<=now ? result.addMinutes(minutelyMode ? 1 : 0) : result;
	        result = result<=now ? result.addHours(hourlyMode ? 1 : 0) : result;
	        result = result<=now ? result.addDays(dailyOrWeeklyMode ? 1 : 7) : result;
	    }
	    
	    return result;
    }
    
    private static CronTrigger getCurrentScheduleCronJob(String jobId) {
        CronTrigger job = null;
    
        if(String.isNotBlank(jobId)) {
            List<CronTrigger> jobs = [SELECT Id FROM CronTrigger WHERE Id = :jobId AND TimesTriggered = 0 LIMIT 1];
      
            for(CronTrigger iJob : jobs) {
                job = iJob;
            }
        }
    
        return job;
    }
    
    private static void logException(Exception ex, String jobType) {
        Batch_Runner_Error_Log_gne__c log = new Batch_Runner_Error_Log_gne__c(
            Batch_Name_gne__c = SCHEDULER_JOB_PREFIX + jobType,
            Batch_Class_gne__c = GNE_SFA2_Scheduler.class.getName(),
            Batch_Job_Id_gne__c = null,
            Batch_Start_Date_gne__c = DateTime.now(),
            Error_Type_gne__c = GNE_Batch_Runner.LogErrorType.APEX_ERROR.name(),
            Error_Subtype_gne__c = ex.getTypeName(),
            Error_Short_Description_gne__c = ex.getMessage(),
            Error_Description_gne__c = ex.getMessage() + '\nStackTrace:\n['+ ex.getStackTraceString() +']'
        );
                
        Database.insert(log, false); 
    }
    
    // END Static methods
    
    public GNE_SFA2_Scheduler(String jobType) {
        this.jobType = jobType;
    }
    
    public String getJobType() {
        return this.jobType;
    }
    
    public List<SObject> start(Database.BatchableContext BC) {
        return new List<SObject>();
    }
    
    public void execute(Database.BatchableContext BC, List<SObject> scope) {}
    
    public void finish(Database.BatchableContext BC) {
        SFA2_Scheduler_Job_gne__c job = getSchedulerJob(getJobType(), false);
        Boolean isExecuted = false;
        DateTime nowTimeStamp = DateTime.now();
        
        if(job!=null && job.Id!=null && job.Status_gne__c==GNE_SFA2_Scheduler.JobType.Scheduled.name()) {
            try {
	            Map<String,String> jobProperties = String.isNotBlank(job.Job_Properties_json_gne__c) ? (Map<String,String>)JSON.deserialize(job.Job_Properties_json_gne__c, Map<String,String>.class) : null;
	            SchedulableContext sc = new SchedulableContext(getJobType(), jobProperties, job.Queued_Date_gne__c, job.Scheduled_Date_gne__c, nowTimeStamp);
	            GNE_SFA2_Scheduler.Schedulable handler = (GNE_SFA2_Scheduler.Schedulable)JSON.deserialize(job.Handler_json_gne__c, System.Type.forName(job.Handler_Class_gne__c));
	            isExecuted = true;
	            handler.execute(sc);
            } catch(Exception ex) {
                GNE_SFA2_Scheduler.logException(ex, getJobType());
                job.Status_Details_gne__c = ex.getMessage() + '\n' + ex.getStackTraceString();
            } finally {
                job.Status_gne__c = isExecuted ? GNE_SFA2_Scheduler.JobType.Executed.name() : GNE_SFA2_Scheduler.JobType.Failed.name();
                job.Executed_Date_gne__c = isExecuted ? nowTimeStamp : null;
                Database.update(job, false);
            }
        }
    }
    
    public interface Schedulable {
        System.Type getSelfClass();
        void execute(SchedulableContext sc);
    }
    
    public class SchedulableContext {
        private transient String jobType;
        private transient Map<String,String> jobProperties;
        private transient DateTime queuedDate;
        private transient DateTime scheduledDate;
        private transient DateTime executedDate;
        
        public SchedulableContext(String jobType, Map<String,String> jobProperties, DateTime queuedDate, DateTime scheduledDate, DateTime executedDate) {
            this.jobType = jobType;
            this.jobProperties = jobProperties;
            this.queuedDate = queuedDate;
            this.scheduledDate = scheduledDate;
            this.executedDate = executedDate;
        }
        
        public String getJobType() {
            return this.jobType;
        }
        
        public Map<String,String> getJobProperties() {
            if(this.jobProperties==null) {
                this.jobProperties = new Map<String,String>();
            }
            
            return this.jobProperties;
        }
        
        public DateTime getQueuedDate() {
            return this.queuedDate;
        }
        
        public DateTime getScheduledDate() {
            return this.scheduledDate;
        }
        
        public DateTime getExecutedDate() {
            return this.executedDate;
        }
    }
}