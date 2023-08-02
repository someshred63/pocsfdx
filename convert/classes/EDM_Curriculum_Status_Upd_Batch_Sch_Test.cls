@isTest
private class EDM_Curriculum_Status_Upd_Batch_Sch_Test{
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
 

    static testmethod void test() {
    
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new EDM_Curriculum_Status_Update_Batch_Sch());           

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
     
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);   

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();

    }

    public static testMethod void curriculumStatusUpdateBatchTest(){

        insert new Event_Curriculum_gne__c(
            Deactivation_Date_gne__c = Date.today()
        );
        EDM_Curriculum_Status_Update_Batch b = new EDM_Curriculum_Status_Update_Batch();
        database.executebatch(b);

        Event_Curriculum_gne__c ec = [Select Curriculum_Status_gne__c From Event_Curriculum_gne__c];
        System.assertEquals('Inactive',ec.Curriculum_Status_gne__c);
    }

}