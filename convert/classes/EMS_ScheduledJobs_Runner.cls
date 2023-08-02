global class EMS_ScheduledJobs_Runner implements Schedulable {

    /**
    This class is used to stop all scheduled jobs in EMS and run them after delay (10 minutes) only once
    */
    public static Integer delay = 2; // in minutes
    public static Map<String, String> scheduledClasses = new Map<String, String>{
            'EMS Close events' => 'EMS_Event_Close_Batch_Scheduler',
            'EMS Deactivate product budgets' => 'EMS_Budget_Product_PYInactive_Sch',
            'EMS Events territory assignment' => 'EMS_Event_Assign_Batch_Sch',
            'EMS Product budgets territory assignment' => 'EMS_Product_Budget_Assign_Batch_Sch',
            'EMS Region budgets territory assignment' => 'EMS_Region_Budget_Assign_Batch_Sch',
            'EMS Territory budgets territory assignment' => 'EMS_Territory_Budget_Assign_Batch_Sch',
            'EMS User Delegation Batch' => 'EMS_Delegation_Scheduler',
            'EMS iHCP subscribe batch' => 'EMS_Subscribe_iHCP_Batch_Schedulable'
    };

    public static Map<String, String> jobExpressions = new Map<String, String>{
            'EMS Close events' => '0 0 23 31 12 ? *',
            'EMS Deactivate product budgets' => '0 0 1 1 1 ? *',
            'EMS Events territory assignment' => '0 0 1 * * ? *',
            'EMS Product budgets territory assignment' => '0 0 2 * * ? *',
            'EMS Region budgets territory assignment' => '0 0 3 * * ? *',
            'EMS Territory budgets territory assignment' => '0 0 4 * * ? *',
            'EMS User Delegation Batch' => '0 0 2 * * ?',
            'EMS iHCP subscribe batch' => '0 0 5 * * ? *'
    };

    public List<Job> jobs {
        get {
            if (jobs == null) {
                jobs = new List<Job>();
            }
            return jobs;
        }
        private set;
    }

    public void addJob(String jobName, String cronExpression, String schedulableClass) {
        jobs.add(new Job(jobName, cronExpression, schedulableClass));
    }

    global void execute(SchedulableContext sc) {
        for (Job item : jobs) {
            try {
                system.schedule(item.jobName, item.cronExpression, (Schedulable) Type.forName(null, item.schedulableClass).newInstance());
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, '## error: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '## job : ' + item);
            }
        }
    }

    private class Job {
        public String jobName { get; set; }
        public String cronExpression { get; set; }
        public String schedulableClass { get; set; }

        Job(String jobName, String cronExpression, String schedulableClass) {
            this.jobName = jobName;
            this.cronExpression = cronExpression;
            this.schedulableClass = schedulableClass;
        }
    }
}