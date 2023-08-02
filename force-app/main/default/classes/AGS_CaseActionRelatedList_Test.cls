/** @date 18/10/2016
* @Author Gabriel Juriewicz
* @description Unit test for AGS_CaseActionRelatedList_Controller
*/
@isTest
private class AGS_CaseActionRelatedList_Test {
    
    @testSetup static void setUpCaseAction() {
        final AGS_Case_gne__c cse = AGS_TestUtil.createAgsCase();
        AGS_TestUtil.createActionCase(cse);
        AGS_TestUtil.createAGSSpendCCOCase(cse);
    }
    
    @isTest static void shouldGetActions() {
        // given
        final AGS_CaseActionRelatedList_Controller ctrlUnderTest = new AGS_CaseActionRelatedList_Controller();
        ctrlUnderTest.caseId = [SELECT Id FROM AGS_Case_gne__c LIMIT 1].Id;
        // when
        Test.startTest();
        final AGS_Case_Action_gne__c[] actualActions = ctrlUnderTest.getActions();
        Test.stopTest();
        // then
        System.assertEquals(1, actualActions.size());
    }
    
    @isTest static void shouldGetExpenses() {
        // given
        final AGS_CaseActionRelatedList_Controller ctrlUnderTest = new AGS_CaseActionRelatedList_Controller();
        ctrlUnderTest.caseId = [SELECT Id FROM AGS_Case_gne__c LIMIT 1].Id;
        // when
        Test.startTest();
        final AGSSpendCCOCase_gne__c[] actualExpenses = ctrlUnderTest.getExpenses();
        Test.stopTest();
        // then
        System.assertEquals(1, actualExpenses.size());
    }
    
    @isTest static void shouldGetCase() {
        // given
        final AGS_CaseActionRelatedList_Controller ctrlUnderTest = new AGS_CaseActionRelatedList_Controller();
        ctrlUnderTest.caseId = [SELECT Id FROM AGS_Case_gne__c LIMIT 1].Id;
        // when
        Test.startTest();
        final AGS_Case_gne__c actualCase = ctrlUnderTest.getCase();
        Test.stopTest();
        // then
        System.assertNotEquals(null, actualCase);
    }
}