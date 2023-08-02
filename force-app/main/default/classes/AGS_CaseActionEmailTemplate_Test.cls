/**
* @date 06/8/2017
* @author Gabriel Juriewicz
* @description Unit tests for AGS_CaseActionEmailTemplate_Controller
*/
@isTest
private class AGS_CaseActionEmailTemplate_Test {
    
    private static final String ENV_NAME = AGS_CaseActionEmailTemplate_Controller.getEnvironmentName();
    
    @testSetup
    static void testSetup() {
        // init custom settings
        insert new AGS_Email_Links__c(
            AGS_IFU_Training_Link__c = 'http://training.com/infu',
            AGS_CommPortal_Link__c = 'http://commportal.com/{0}',
            AGS_Training_Link__c = 'http://training.com',
            AGS_B2B_link__c = 'http://b2b.com',
            Name = ENV_NAME
        );
        insert new AGS_Environment_Domain_gne__c(
            Site_Domain_gne__c = 'unit.test.site.domain',
            Name = ENV_NAME
        );
        // init AGS Case
        final AGS_Case_gne__c cse = AGS_TestUtil.createAgsCase();
        // init AGS Case Action
        final AGS_Case_Action_gne__c cseAction = new AGS_Case_Action_gne__c(
            Action_gne__c = AGS_CaseActionEmailTemplate_Controller.CONFIR_MGR_ACTION,
            Action_Status_internal_gne__c = 'Open',
            Send_Error_Email__c = false,
            AGS_Case_gne__c = cse.Id,
            OwnerId = cse.OwnerId
        );
        insert cseAction;
        // init AGS Spend Expense Transaction
        final AGS_Spend_Expense_Transaction_gne__c txn = AGS_TestUtil.createSpendExpenseTrans(
            AGS_TestUtil.createSpendRecipient(), cse.OwnerId
        );
        txn.Infrequent_User_Flag_gne__c = true;
        update txn;
        // init AGS Case 2 AGS Spend Expense Transaction association
        AGS_TestUtil.createAGSSpendCCOCase(cse, txn);
    }
    
    @isTest
    static void testCaseActionOwnerShouldNeverBeNull() {
        // given
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        final User actualOwner = ctrlUnderTest.caseActionOwner;
        Test.stopTest();
        // then
        System.assertNotEquals(null, actualOwner);
        System.assertEquals(null, actualOwner.Id);
        System.assertEquals(null, actualOwner.Name);
        System.assertNotEquals(null, actualOwner.Profile);
        System.assertEquals(null, actualOwner.Profile.Id);
        System.assertEquals(null, actualOwner.Profile.Name);
    }
    
    @isTest
    static void testCaseActionLinkShouldNeverBeNull() {
        // given
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        final String actualLink = ctrlUnderTest.caseActionLink;
        Test.stopTest();
        // then
        System.assertEquals(String.format('{0}/{1}000000000000', new String[]{
            System.URL.getSalesforceBaseUrl().toExternalForm(),
            sObjectType.AGS_Case_Action_gne__c.keyPrefix
        }), actualLink);
    }
    
    @isTest
    static void testTrainingLinkShouldNeverBeNull() {
        // given
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        final String actualLink = ctrlUnderTest.trainingLink;
        Test.stopTest();
        // then
        System.assertEquals(AGS_Email_Links__c.getValues(ENV_NAME).AGS_Training_Link__c, actualLink);
    }
    
    @isTest
    static void testCaseActionShouldNotBeFound() {
        // given
        final Id caseActionId = sObjectType.AGS_Case_Action_gne__c.keyPrefix + '000000000000';
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        ctrlUnderTest.caseActionId = caseActionId;
        Test.stopTest();
        // then
        System.assertNotEquals(null, ctrlUnderTest.caseActionId);
        System.assertNotEquals(null, ctrlUnderTest.caseActionOwner);
    }
    
    @isTest
    static void testErrorCaseAction() {
        // given
        final AGS_Case_Action_gne__c caseAction = [SELECT Id FROM AGS_Case_Action_gne__c LIMIT 1];
        caseAction.Send_Error_Email__c = true;
        update caseAction;
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        ctrlUnderTest.caseActionId = caseAction.Id;
        Test.stopTest();
        // then
        System.assertEquals(caseAction.Id, ctrlUnderTest.caseActionId);
        System.assertNotEquals(null, ctrlUnderTest.caseActionUser);
        System.assertEquals(String.format('{0}/{1}', new String[]{
            System.URL.getSalesforceBaseUrl().toExternalForm(),
            caseAction.Id
        }), ctrlUnderTest.caseActionLink);
    }
    
    @isTest
    static void testFrequentUserForMissingCommPortalUrl() {
        // given
        final AGS_Email_Links__c emailLinks = AGS_Email_Links__c.getValues(ENV_NAME);
        emailLinks.AGS_CommPortal_Link__c = null;
        update emailLinks;
        final AGS_Case_Action_gne__c caseAction = [SELECT AGS_Case_gne__c, OwnerId FROM AGS_Case_Action_gne__c LIMIT 1];
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        ctrlUnderTest.caseActionId = caseAction.Id;
        Test.stopTest();
        // then
        final PageReference actualRef = new PageReference(ctrlUnderTest.caseActionLink);
        final Map<String, String> actualParams = actualRef.getParameters();
        System.assertNotEquals(null, ctrlUnderTest.caseActionOwner.Profile, ctrlUnderTest.caseActionOwner);
        System.assertEquals('GNE-FREQUENT-USER', ctrlUnderTest.caseActionOwner.Profile.Name, ctrlUnderTest.caseActionOwner);
        System.assertEquals(AGS_Email_Links__c.getValues(ENV_NAME).AGS_Training_Link__c, ctrlUnderTest.trainingLink);
        System.assertEquals(true, actualRef.getUrl().startsWith(String.format('{0}/{1}', new String[]{
            System.URL.getSalesforceBaseUrl().toExternalForm(),
            caseAction.Id
        })), actualRef);
        System.assertEquals(emailLinks.AGS_Training_Link__c, ctrlUnderTest.trainingLink);
        System.assertEquals([
            SELECT External_ID_gne__c FROM User WHERE Id = :caseAction.OwnerId
        ].External_ID_gne__c, actualParams.get('spenduser'), actualRef);
        System.assertEquals(caseAction.Id, actualParams.get('caseactionid'), actualRef);
        System.assertEquals(caseAction.AGS_Case_gne__c, actualParams.get('caseid'), actualRef);
        System.assertEquals('confirm', actualParams.get('mode'), actualRef.getParameters());
        System.assertEquals('/apex/AGS_ConfirmPolicy', actualParams.get('targetUrl'), actualRef);
        System.assertEquals([
            SELECT AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c FROM AGSSpendCCOCase_gne__c LIMIT 1
        ].AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c, actualParams.get('interactionid'), actualRef);
    }
    
    @isTest
    static void testFrequentUserForProvidedCommPortalUrl() {
        // given
        final AGS_Email_Links__c emailLinks = AGS_Email_Links__c.getValues(ENV_NAME);
        final AGS_Case_Action_gne__c caseAction = [SELECT Id FROM AGS_Case_Action_gne__c LIMIT 1];
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        ctrlUnderTest.caseActionId = caseAction.Id;
        Test.stopTest();
        // then
        System.assertEquals('GNE-FREQUENT-USER', ctrlUnderTest.caseActionOwner.Profile.Name, ctrlUnderTest.caseActionOwner);
        System.assertEquals(AGS_Email_Links__c.getValues(ENV_NAME).AGS_Training_Link__c, ctrlUnderTest.trainingLink);
        System.assertEquals(String.format(emailLinks.AGS_CommPortal_Link__c, new String[]{
            caseAction.Id
        }), ctrlUnderTest.caseActionLink);
    }
    
    @isTest
    static void testInfrequentUserForPleaseValidateDataAction() {
        // given
        final AGS_Case_Action_gne__c caseAction = [SELECT AGS_Case_gne__c, OwnerId FROM AGS_Case_Action_gne__c LIMIT 1];
        caseAction.Action_gne__c = AGS_CaseActionEmailTemplate_Controller.VALID_DATA_ACTION;
        update caseAction;
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        ctrlUnderTest.caseActionId = caseAction.Id;
        Test.stopTest();
        // then
        final PageReference actualRef = new PageReference(ctrlUnderTest.caseActionLink);
        final Map<String, String> actualParams = actualRef.getParameters();
        System.assertEquals(AGS_CaseActionEmailTemplate_Controller.INFU_PROFILE_NAME,
            ctrlUnderTest.caseActionOwner.Profile.Name, ctrlUnderTest.caseActionOwner
        );
        System.assertEquals(AGS_Email_Links__c.getValues(ENV_NAME).AGS_IFU_Training_Link__c, ctrlUnderTest.trainingLink);
        System.assertEquals(true, actualRef.getUrl().startsWith(String.format('http://{0}/infu', new String[]{
            AGS_Environment_Domain_gne__c.getAll().values()[0].Site_Domain_gne__c
        })), actualRef);
        System.assertEquals([
            SELECT External_ID_gne__c FROM User WHERE Id = :caseAction.OwnerId
        ].External_ID_gne__c, actualParams.get('spenduser'), actualRef);
        System.assertEquals('/apex/IRecord', actualParams.get('targetUrl'), actualRef);
        System.assertEquals(caseAction.Id, actualParams.get('caseactionid'), actualRef);
        System.assertEquals('confirm', actualParams.get('mode'), actualRef.getParameters());
        System.assertEquals(caseAction.AGS_Case_gne__c, actualParams.get('caseid'), actualRef);
        System.assertEquals([
            SELECT AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c FROM AGSSpendCCOCase_gne__c LIMIT 1
        ].AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c, actualParams.get('interactionid'), actualRef);
    }
    
    @isTest
    static void testInfrequentUserForNonPleaseValidateDataAction() {
        // given
        final AGS_Case_Action_gne__c caseAction = [SELECT AGS_Case_gne__c, OwnerId FROM AGS_Case_Action_gne__c LIMIT 1];
        caseAction.Action_gne__c = AGS_CaseActionEmailTemplate_Controller.VALID_DATA_ACTION + Crypto.getRandomLong();
        update caseAction;
        final AGS_CaseActionEmailTemplate_Controller ctrlUnderTest = new AGS_CaseActionEmailTemplate_Controller();
        // when
        Test.startTest();
        ctrlUnderTest.caseActionId = caseAction.Id;
        Test.stopTest();
        // then
        final PageReference actualRef = new PageReference(ctrlUnderTest.caseActionLink);
        final Map<String, String> actualParams = actualRef.getParameters();
        System.assertEquals(AGS_CaseActionEmailTemplate_Controller.INFU_PROFILE_NAME,
            ctrlUnderTest.caseActionOwner.Profile.Name, ctrlUnderTest.caseActionOwner
        );
        System.assertEquals(AGS_Email_Links__c.getValues(ENV_NAME).AGS_IFU_Training_Link__c, ctrlUnderTest.trainingLink);
        System.assertEquals(true, actualRef.getUrl().startsWith(String.format('http://{0}/infu', new String[]{
            AGS_Environment_Domain_gne__c.getAll().values()[0].Site_Domain_gne__c
        })), actualRef);
        System.assertEquals([
            SELECT External_ID_gne__c FROM User WHERE Id = :caseAction.OwnerId
        ].External_ID_gne__c, actualParams.get('spenduser'), actualRef);
        System.assertEquals(caseAction.Id, actualParams.get('caseactionid'), actualRef);
        System.assertEquals('confirm', actualParams.get('mode'), actualRef.getParameters());
        System.assertEquals(caseAction.AGS_Case_gne__c, actualParams.get('caseid'), actualRef);
        System.assertEquals('/apex/AGS_ConfirmPolicy', actualParams.get('targetUrl'), actualRef);
        System.assertEquals([
            SELECT AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c FROM AGSSpendCCOCase_gne__c LIMIT 1
        ].AGS_Spend_Expense_Transaction_gne__r.Event_ID_gne__c, actualParams.get('interactionid'), actualRef);
    }
}