public virtual class AGS_AbstractCaseSchedule implements Schedulable {
    
    public final Integer batchSize { get; private set; }
    
    public final String batchClassName { get; private set; }
    
    protected AGS_AbstractCaseSchedule(final String batchClass, final Integer batchScope) {
        batchSize = String.isBlank(batchClass) ? null : Test.isRunningTest() ? 200 : batchScope;
        batchClassName = batchClass;
    }
    
    protected AGS_AbstractCaseSchedule(final String batchClass) {
        this(batchClass, 200);
    }
    
    protected AGS_AbstractCaseSchedule() {
        this(null);
    }
    
    protected virtual Boolean isBatchExecutable() {
        return String.isNotBlank(batchClassName);
    }
    
    public virtual void execute(final SchedulableContext ctx) {
        Id batchId;
        final String className = String.valueOf(this).split(':')[0];
        try {
            for (CronTrigger cron : [SELECT Id FROM CronTrigger WHERE State = 'Complete' LIMIT 100]) {
                System.abortJob(batchId = cron.Id);
            }
        } catch (Exception e) {
            insert new AGS_Error_Log__c(
                Custom_Error_Message__c = 'There was an error while aborting completed jobs: ' + ctx.getTriggerId(),
                System_Error_Message__c = e.getMessage(),
                Object_Name__c = 'CronTrigger',
                Method_Name__c = 'execute',
                Class_Name__c = className,
                Error_Type__c = 'Error',
                Batch_Id__c = batchId
            );
        } finally {
            final System.Type batchClass = String.isBlank(batchClassName) ? null : Type.forName(batchClassName);
            final Object batchObject = batchClass == null ? null : batchClass.newInstance();
            if (batchObject instanceof Database.Batchable<sObject> && isBatchExecutable()) {
                insert new AGS_Error_Log__c(
                    Custom_Error_Message__c = batchClassName + ' submitted for execution: ' + ctx.getTriggerId(),
                    Batch_Id__c = Database.executeBatch((Database.Batchable<sObject>) batchObject, batchSize),
                    Method_Name__c = 'execute',
                    Class_Name__c = className,
                    Error_Type__c = 'Success'
                );
            }
        }
    }
}