@isTest
private class AGS_UserActivationCaseActionsAssign_Test {
    
    @testSetup
    public static void setUpCaseActionForInactiveUser() {
        final QueueSobject caseActionQueue = [
            SELECT QueueId FROM QueueSobject WHERE sObjectType = 'AGS_Case_Action_gne__c' LIMIT 1
        ];
        final AGS_Case_gne__c cse = AGS_TestUtil.createAgsCase(AGS_TestUtil.createAgsCcoCaseReason(
            AGS_TestUtil.AGS_CASEACTION_REASONTYPE_INSTANCE_RULE
        ));
        final AGS_Case_Action_gne__c action = AGS_TestUtil.createActionCase(cse);
        action.Inactive_Owner_gne__c = cse.Analyst_gne__c;
        action.OwnerId = caseActionQueue.QueueId;
        update action;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update new User(Id = action.Inactive_Owner_gne__c, IsActive = false);
        }
    }
    
    @isTest
    public static void testInactiveOwnerShouldBeActivated() {
        // given
        AGS_TestUtil.createAGSUserActivationFinish('Process');
        final AGS_AbstractCaseBatch batchUnderTest = new AGS_UserActivationCaseActionsAssingment();
        // when
        Test.startTest();
        Database.executeBatch(batchUnderTest);
        Test.stopTest();
        // then
        final AGS_Case_Action_gne__c actualAction = [
            SELECT OwnerId, Inactive_Owner_gne__r.IsActive FROM AGS_Case_Action_gne__c LIMIT 1
        ];
        System.assertEquals(true, actualAction.Inactive_Owner_gne__r.IsActive);
        System.assertEquals(actualAction.Inactive_Owner_gne__c, actualAction.OwnerId, actualAction);
        System.assertEquals(false, AGS_User_Activation_Finish_gne__c.getAll().isEmpty());
        System.assertEquals('Proceed', AGS_User_Activation_Finish_gne__c.getAll().values()[0].Status_gne__c);
        final CronTrigger[] actualCronTriggers = [
            SELECT CronExpression, CronJobDetail.JobType, CronJobDetail.Name
            FROM CronTrigger ORDER BY CreatedDate DESC LIMIT 1
        ];
        final AsyncApexJob[] actualJobs = [
            SELECT Id FROM AsyncApexJob WHERE JobType = 'ScheduledApex'
            AND ApexClass.Name = :batchUnderTest.nextJobClassName LIMIT 1
        ];
        System.assertEquals(false, actualCronTriggers.isEmpty(), actualCronTriggers);
        System.assertEquals('7', actualCronTriggers[0].CronJobDetail.JobType, actualCronTriggers[0]);
        System.assertEquals(true, actualCronTriggers[0].CronJobDetail.Name.startsWith(
            batchUnderTest.nextJobName
        ), actualCronTriggers[0]);
        System.assertEquals(true, actualCronTriggers[0].CronExpression.startsWith(
            '0 ' + AGS_UserActivationCaseActionsAssingment.MINUTE
        ), actualCronTriggers[0]);
    }
}