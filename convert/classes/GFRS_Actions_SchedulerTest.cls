@IsTest
private class GFRS_Actions_SchedulerTest {

    private static final String OWEA = 'fundingrequestsystem-donotreply-d@gene.com';
    private static final String INBOUND_EMAIL = 'fundingrequestsystem-donotreply-d=gene.com@example.com';
    private static final String SENDER_DISPLAY_NAME = 'Funding Requests System';
    private static final String RECONCILIATION_SCHEDULED_ACTIONS = 'GFRS Reconcilation Scheduled Actions';
    private static final String SUNSHINE_SCHEDULED_ACTIONS = 'GFRS Sunshine Scheduled Actions';

    private static GFRS_Funding_Request__c queryFundingRequest(String taskActionType) {
        return [
            SELECT
                Id,
                Sub_Status__c,
                External_Sub_status__c,
                Reconciliation_Required_Status_Date__c,
                (SELECT Id FROM gFRS_Tasks__r WHERE Action_Type__c != NULL AND Action_Type__c =: taskActionType)
            FROM
                    GFRS_Funding_Request__c
            LIMIT 1
        ];
    }

    @testSetup
    private static void setup() {
        insertSettings();

        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(
            testOrganization.Id,
            testLocation.Id,
            GFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION,
            GFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES,
            GFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES,
            'Cardiology',
            'Acromegaly',
            'Organization;Location;Application;Third Party;Program;Budget;Attachments');

        fundingRequest.LOA_Signed__c = 'Yes';
        fundingRequest.SYS_Request_Approved__c = 'Yes';
        fundingRequest.SAP_Payment_ID__c = 'Test';

        insert fundingRequest;

        GFRS_Program__c program = gFRS_UnitTestHelper.createProgram(fundingRequest.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_IMED_RECTYPE);
        program.Venue_city__c = 'Test';
        program.End_Date__c = Date.today() - 1;
        insert program;

        Contact communicationContact = new Contact(FirstName = 'test', LastName = 'test', Email = 'test@test.com');
        insert communicationContact;
    }

    private static void insertSettings() {
        Set<String> jobs = new Set<String>{'GFRS Reconcilation Scheduled Actions', 'GFRS Sunshine Scheduled Actions'};

        for (CronTrigger ct : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN : jobs]){
            System.abortJob(ct.Id);
        }

        GFRS_OrgSettings__c orgCS = GFRS_OrgSettings__c.getOrgDefaults();
        orgCS.gFRS_Inbound_Email__c = INBOUND_EMAIL;
        orgCS.Org_Wide_Email_Address__c = OWEA;
        orgCS.Notification_Sender_Display_Name__c = SENDER_DISPLAY_NAME;
        orgCS.Act_Sched_Batch_Size__c = 200;
        orgCS.Act_Sched_Reconciliation_Cron_Exp__c = '0 0 18/12 * * ? *';
        orgCS.Act_Sched_Sunshine_Cron_Exp__c = '0 0 22/12 * * ? *';
        upsert orgCS;

        List<GFRS_Scheduled_Actions__c> toDelete =  GFRS_Scheduled_Actions__c.getAll().values();
        if(toDelete.size() > 0)
            delete toDelete;

        List<GFRS_Scheduled_Actions__c> l = new List<GFRS_Scheduled_Actions__c>();

        l.add(new GFRS_Scheduled_Actions__c(
                Name = 'Reconciliation Requested',
                Trigger_Field__c = 'Program_End_Date_max__c',
                Trigger_Days__c = 1,
                Invoke_Only_On_Trigger_Date__c = false,
                Email_Template__c = 'UC_12_Reconcile_Request_Enter_Outcomes_3_7_Email_38',
                Email_CC__c = '',
                Apex_Interface__c = 'GFRS_Scheduled_Action_Generic.GFRS_Scheduled_Action_Recon_Requested'
        ));
        l.add(new GFRS_Scheduled_Actions__c(
                Name = 'Reconcilation First Reminder',
                Trigger_Field__c = 'Program_End_Date_max__c',
                Trigger_Days__c = 45,
                Invoke_Only_On_Trigger_Date__c = true,
                Email_Template__c = 'UC_12_Reconcile_Request_Reminder_Email_39',
                Email_CC__c = '',
                Apex_Interface__c = 'GFRS_Scheduled_Action_Generic'
        ));
        l.add(new GFRS_Scheduled_Actions__c(
                Name = 'Reconcilation Second Reminder',
                Trigger_Field__c = 'Program_End_Date_max__c',
                Trigger_Days__c = 75,
                Invoke_Only_On_Trigger_Date__c = true,
                Email_Template__c = 'UC_12_Reconcile_Request_Reminder_Email_39',
                Email_CC__c = '',
                Apex_Interface__c = 'GFRS_Scheduled_Action_Generic'
        ));
        l.add(new GFRS_Scheduled_Actions__c(
                Name = 'Reconcilation Lockout',
                Trigger_Field__c = 'Program_End_Date_max__c',
                Trigger_Days__c = 91,
                Invoke_Only_On_Trigger_Date__c = true,
                Email_Template__c = 'UC_12_Reconcile_Request_Lock_Out_Notification_Email_42',
                Email_CC__c = '',
                Apex_Interface__c = 'GFRS_Scheduled_Action_Generic'
        ));
        l.add(new GFRS_Scheduled_Actions__c(
                Name = 'Sunshine Requested',
                Trigger_Field__c = 'Last_Live_Program_End_Date__c',
                Trigger_Days__c = 1,
                Invoke_Only_On_Trigger_Date__c = false,
                Email_Template__c = 'gFRS_Sunshine_Act_Disclosure_Notification_Email',
                Email_CC__c = '',
                Apex_Interface__c = 'GFRS_Scheduled_Action_Generic.GFRS_Scheduled_Action_Sunshine_Requested'
        ));
        l.add(new GFRS_Scheduled_Actions__c(
                Name = 'Sunshine First Reminder',
                Trigger_Field__c = 'Last_Live_Program_End_Date__c',
                Trigger_Days__c = 45,
                Invoke_Only_On_Trigger_Date__c = true,
                Email_Template__c = 'gFRS_Sunshine_Act_Disclosure_Notification_Reminder_Email',
                Email_CC__c = '',
                Apex_Interface__c = 'GFRS_Scheduled_Action_Generic'
        ));
        l.add(new GFRS_Scheduled_Actions__c(
                Name = 'Sunshine Second Reminder',
                Trigger_Field__c = 'Last_Live_Program_End_Date__c',
                Trigger_Days__c = 75,
                Invoke_Only_On_Trigger_Date__c = true,
                Email_Template__c = 'gFRS_Sunshine_Act_Disclosure_Notification_Reminder_Email',
                Email_CC__c = '',
                Apex_Interface__c = 'GFRS_Scheduled_Action_Generic'
        ));

        upsert l;

        GFRS_OrgSettings__c currentUserInstance = GFRS_OrgSettings__c.getInstance(UserInfo.getUserId());
        currentUserInstance.Act_Sched_Bypass_Validations__c  = true;
        upsert currentUserInstance;

    }

    private static testMethod void  testScheduleReconciliationActions() {

        Test.startTest();
            new GFRS_Actions_Scheduler(
                new List<String>{
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_RECONCILATION_REQUESTED,
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_RECONCILATION_FIRST_REMINDER,
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_RECONCILATION_SECOND_REMINDER,
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_RECONCILATION_LOCKOUT
                }, gFRS_Actions_Scheduler.getReconcilationQuery()
            ).schedule(
                RECONCILIATION_SCHEDULED_ACTIONS,
                gFRS_Actions_Scheduler.getReconciliationCronExp()
            );
        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: RECONCILIATION_SCHEDULED_ACTIONS];
        System.assertEquals(1, ct.size(), 'One Reconciliation job should be scheduled');

    }

    private static testMethod void testScheduleSunshineActions() {

        Test.startTest();
            new GFRS_Actions_Scheduler(
                new List<String>{
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_SUNSHINE_REQUESTED,
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_SUNSHINE_FIRST_REMINDER,
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_SUNSHINE_SECOND_REMINDER
                }, gFRS_Actions_Scheduler.getSunshineQuery()
            ).schedule(
                SUNSHINE_SCHEDULED_ACTIONS,
                gFRS_Actions_Scheduler.getSunshineCronExp()
            );
        Test.stopTest();

        List<CronTrigger> ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name =: SUNSHINE_SCHEDULED_ACTIONS];
        System.assertEquals(1, ct.size(), 'One Sunshine job should be scheduled');
    }

    private static testMethod void testBatchReconciliationRequested() {

        GFRS_Funding_Request__c fundingRequest;

        fundingRequest = queryFundingRequest(gFRS_Util.TASK_RECONCILIATION);

        System.assertNotEquals('Reconciliation Required', fundingRequest.Sub_Status__c);
        System.assertNotEquals('Reconciliation Required', fundingRequest.External_Sub_status__c);
        System.assertEquals(fundingRequest.Reconciliation_Required_Status_Date__c, null);
        System.assertEquals(0, fundingRequest.gFRS_Tasks__r.size());

        Test.startTest();

            new GFRS_Actions_Scheduler(
                new List<String>{
                        gFRS_Actions_Scheduler.SCHEDULED_ACTION_RECONCILATION_REQUESTED
                }, gFRS_Actions_Scheduler.getReconcilationQuery()
            ).execute(null);

        Test.stopTest();

        fundingRequest = queryFundingRequest(gFRS_Util.TASK_RECONCILIATION);

        System.assertEquals('Reconciliation Required', fundingRequest.Sub_Status__c);
        System.assertEquals('Reconciliation Required', fundingRequest.External_Sub_status__c);
        System.assertEquals(fundingRequest.Reconciliation_Required_Status_Date__c, Date.today());
        System.assertEquals(1, fundingRequest.gFRS_Tasks__r.size());

    }


    private static testMethod void testBatchSunshineRequested() {

        GFRS_Funding_Request__c fundingRequest;

        fundingRequest = queryFundingRequest(gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE);

        System.assertNotEquals('Sunshine Act Disclosure', fundingRequest.Sub_Status__c);
        System.assertNotEquals('Sunshine Act Disclosure', fundingRequest.External_Sub_status__c);
        System.assertEquals(0, fundingRequest.gFRS_Tasks__r.size());

        Test.startTest();

            new GFRS_Actions_Scheduler(
                    new List<String>{
                            gFRS_Actions_Scheduler.SCHEDULED_ACTION_SUNSHINE_REQUESTED
                    }, gFRS_Actions_Scheduler.getSunshineQuery()
            ).execute(null);

        Test.stopTest();

        fundingRequest = queryFundingRequest(gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE);

        System.assertEquals('Sunshine Act Disclosure', fundingRequest.Sub_Status__c);
        System.assertEquals('Sunshine Act Disclosure', fundingRequest.External_Sub_status__c);
        System.assertEquals(1, fundingRequest.gFRS_Tasks__r.size());

    }
}