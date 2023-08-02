/** @date 18/10/2016
* @Author Gabriel Juriewicz
* @description Unit test for AGS_ConfirmPolicyController
*/
@IsTest
public class AGS_ConfirmPolicyController_Test {
    
    @testSetup
    static void setUpCase() {
        AGS_TestUtil.createAgsCase();
    }
    
    @isTest
    static void testCaseActionShouldBeSubmitted() {
        // GIVEN
        AGS_Case_gne__c agsCase = [SELECT Id, OwnerId FROM AGS_Case_gne__c LIMIT 1];
        AGS_Case_Action_gne__c caseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_PLEASE_VALIDATE_DATA_FOLLOWUP, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
        caseAction.Send_Email__c = true;
        update caseAction;
        ApexPages.currentPage().getParameters().put('caseActionId', caseAction.Id);
        ApexPages.currentPage().getParameters().put('usrUnixId', [
            SELECT External_ID_gne__c FROM User WHERE Id = :UserInfo.getUserId()
        ].External_ID_gne__c);
        AGS_ConfirmPolicyController ctrl = new AGS_ConfirmPolicyController(new ApexPages.StandardController(caseAction));
        // WHEN
        ctrl.blCheckbox = true;
        ctrl.submitCaseAction();
        // THEN
        caseAction = [SELECT AGS_Validate_Data_FollowUp_box_gne__c FROM AGS_Case_Action_gne__c WHERE Id = :caseAction.Id];
        System.assertEquals(true, caseAction.AGS_Validate_Data_FollowUp_box_gne__c, 'On Submit, should set AGS_Validate_Data_FollowUp_box_gne__c to true.');
        // WHEN
        caseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_CONFIRM_COMPILANCE_UNDERSTANDING, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
        caseAction.Send_Email__c = true;
        update caseAction;
        ApexPages.currentPage().getParameters().put('caseActionId', caseAction.Id);
        ctrl = new AGS_ConfirmPolicyController(new ApexPages.StandardController(caseAction));
        ctrl.blCheckbox = true;
        ctrl.submitCaseAction();
        // THEN
        caseAction = [SELECT Confirm_Compliance_Understanding_gne__c FROM AGS_Case_Action_gne__c WHERE Id = :caseAction.Id];
        System.assertEquals(true, caseAction.Confirm_Compliance_Understanding_gne__c, 'On Submit, should set Confirm_Compliance_Understanding_gne__c to true.');
        // WHEN
        caseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_MANAGER_ESCALATED, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
        caseAction.Send_Email__c = true;
        update caseAction;
        ApexPages.currentPage().getParameters().put('caseActionId', caseAction.Id);
        ctrl = new AGS_ConfirmPolicyController(new ApexPages.StandardController(caseAction));
        ctrl.blCheckbox = true;
        ctrl.submitCaseAction();
        // THEN
        caseAction = [SELECT AGS_Escalated_Confirm_Compliance_box_gne__c FROM AGS_Case_Action_gne__c WHERE Id = :caseAction.Id];
        System.assertEquals(true, caseAction.AGS_Escalated_Confirm_Compliance_box_gne__c, 'On Submit, should set AGS_Escalated_Confirm_Compliance_box_gne__c to true.');
        // WHEN
        caseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_ACKNOWLEDGE_AGGREGATE_LIMIT, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
        caseAction.Send_Email__c = true;
        update caseAction;
        ApexPages.currentPage().getParameters().put('caseActionId', caseAction.Id);
        ctrl = new AGS_ConfirmPolicyController(new ApexPages.StandardController(caseAction));
        ctrl.blCheckbox = true;
        ctrl.submitCaseAction();
        // THEN
        caseAction = [SELECT Ack_Stop_Spending_Limit_High_gne__c FROM AGS_Case_Action_gne__c WHERE Id = :caseAction.Id];
        System.assertEquals(true, caseAction.Ack_Stop_Spending_Limit_High_gne__c, 'On Submit, should set Ack_Stop_Spending_Limit_High_gne__c to true.');
        // WHEN
        caseAction = AGS_TestUtil.createActionCase(agsCase, AGS_TestUtil.AGS_CASEACTION_SACTION_ACKNOWLEDGE_AGGREGATE_LEGAL_LIMIT, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
        caseAction.Send_Email__c = true;
        update caseAction;
        ApexPages.currentPage().getParameters().put('caseActionId', caseAction.Id);
        ctrl = new AGS_ConfirmPolicyController(new ApexPages.StandardController(caseAction));
        ctrl.blCheckbox = true;
        ctrl.submitCaseAction();
        // THEN
        caseAction = [SELECT Ack_Stop_Spending_Limit_High_gne__c FROM AGS_Case_Action_gne__c WHERE Id = :caseAction.Id];
        System.assertEquals(true, caseAction.Ack_Stop_Spending_Limit_High_gne__c, 'On Submit, should set Ack_Stop_Spending_Limit_High_gne__c to true.');
    }
    
    @isTest
    static void testClosedCaseActionShouldNotBeSubmitted() {
        // given
        final AGS_Case_Action_gne__c caseAction = AGS_TestUtil.createActionCase([
            SELECT Id, OwnerId FROM AGS_Case_gne__c LIMIT 1
        ], AGS_TestUtil.AGS_CASEACTION_SACTION_PLEASE_VALIDATE_DATA_FOLLOWUP, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
        ApexPages.currentPage().getParameters().put('caseActionId', caseAction.Id);
        // when
        Test.startTest();
        final AGS_ConfirmPolicyController ctrlUnderTest = new AGS_ConfirmPolicyController(
            new ApexPages.StandardController(new AGS_Case_Action_gne__c())
        );
        ctrlUnderTest.blCheckbox = true;
        final PageReference actualPage = ctrlUnderTest.submitCaseAction();
        // then
        System.assertNotEquals(null, actualPage, 'On Submit, submitCaseAction function should update record and return PageReference.');
        System.assertEquals(null, ctrlUnderTest.submitCaseAction(), 'Once action is submitted, submitCaseAction function should not submit same action again, and should return null.');
        System.assertEquals(false, ApexPages.hasMessages(), ApexPages.getMessages());
    }
    
    @isTest
    static void testUnsupportedCaseActionShouldNotBeSubmitted() {
        // given
        final AGS_Case_Action_gne__c caseAction = AGS_TestUtil.createActionCase([
            SELECT Id, OwnerId FROM AGS_Case_gne__c LIMIT 1
        ], AGS_TestUtil.AGS_CASEACTION_SACTION_PLEASE_VALIDATE_DATA, AGS_TestUtil.AGS_CASEACTION_RT_CLOSE_CASE);
        ApexPages.currentPage().getParameters().put('caseActionId', caseAction.Id);
        // when
        Test.startTest();
        final AGS_ConfirmPolicyController ctrlUnderTest = new AGS_ConfirmPolicyController(
            new ApexPages.StandardController(new AGS_Case_Action_gne__c())
        );
        ctrlUnderTest.blCheckbox = true;
        final PageReference actualPage = ctrlUnderTest.submitCaseAction();
        Test.stopTest();
        // then
        System.assertEquals(null, actualPage);
        System.assertEquals(true, ApexPages.hasMessages());
        System.assertEquals(1, ApexPages.getMessages().size(), ApexPages.getMessages());
        System.assertEquals('Argument cannot be null.', ApexPages.getMessages()[0].getSummary(), ApexPages.getMessages());
    }
}