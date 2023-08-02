public virtual class AGS_AbstractCaseBatch implements Database.Batchable<sObject> {
    
    public final String nextJobClassName { get; private set; }
    
    public final String nextJobName { get; private set; }
    
    public final String query { get; private set; }
    
    protected AGS_AbstractCaseBatch(final String schedulableClassName, final String jobName, final String soql) {
        nextJobClassName = schedulableClassName;
        nextJobName = jobName;
        query = soql;
    }
    
    protected AGS_AbstractCaseBatch(final String query) {
        this(null, null, query);
    }
    
    public virtual DateTime getNextJobScheduledRun() {
        return String.isBlank(nextJobClassName) || isJobRunning(nextJobClassName) ? null : System.now().addMinutes(5);
    }
    
    public virtual System.Type getNextJobClass() {
        return String.isBlank(nextJobClassName) ? null : Type.forName(nextJobClassName);
    }
    
    public virtual String getNextJobName() {
        return nextJobName;
    }
    
    public virtual Database.QueryLocator start(final Database.BatchableContext ctx) {
        System.debug(LoggingLevel.INFO, query);
        return Database.getQueryLocator(query);
    }
    
    public virtual void execute(final Database.BatchableContext ctx, final sObject[] scope) {}
    
    public virtual void finish(final Database.BatchableContext ctx) {
        final AsyncApexJob currentJob = [
            SELECT ApexClass.Name, CreatedBy.Email, NumberOfErrors, Status, TotalJobItems
            FROM AsyncApexJob WHERE Id = :ctx.getJobId() LIMIT 1
        ];
        final String envName = Test.isRunningTest() ? UserInfo.getUserId() : getEnvironmentName();
        final AGS_Environment_Domain_gne__c[] envDomain = [
            SELECT Mail_Domain__c FROM AGS_Environment_Domain_gne__c WHERE Name = :envName LIMIT 1
        ];
        final Set<String> toAddresses = new Set<String>{ currentJob.CreatedBy.Email };
        toAddresses.add(envDomain.isEmpty() ? null : envDomain[0].Mail_Domain__c);
        toAddresses.remove(null);
        final Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>(toAddresses));
        mail.setSubject('Apex Batch ' + currentJob.Status + ': ' + currentJob.ApexClass.Name);
        mail.setPlainTextBody(String.format('The batch Apex job {0} processed {1} batches with {2} failures.',
            new String[]{ ctx.getJobId(), '' + currentJob.TotalJobItems, '' + currentJob.NumberOfErrors }
        ));
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{ mail }, false);
        final DateTime nextJobRun = getNextJobScheduledRun();
        final System.Type schedulableClass = getNextJobClass();
        final Object schedulableObject = schedulableClass == null ? null : schedulableClass.newInstance();
        if (schedulableObject instanceof Schedulable && nextJobRun > System.now()) {
            final String cronExpr = '0 ' + nextJobRun.minute() + ' ' + nextJobRun.hour() +
                ' ' + nextJobRun.day() + ' ' + nextJobRun.month() + ' ? ' + nextJobRun.year();
            System.schedule(getNextJobName() + ' ' + cronExpr, cronExpr, (Schedulable) schedulableObject);
        }
    }
    
    public static Boolean isJobRunning(final String jobClassName) {
        return [
            SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'ScheduledApex' AND ApexClass.Name = :jobClassName
            AND Status IN ('Queued', 'Preparing', 'Processing') LIMIT 1
        ] > 0;
    }
    
    public static String getEnvironmentName() {
        final String domainName = 'gene.com';
        final String userName = UserInfo.getUserName().toLowerCase();
        return userName.endsWith(domainName) ? 'prod' : userName.substring(userName.indexOf(domainName) + 9);
    }
}