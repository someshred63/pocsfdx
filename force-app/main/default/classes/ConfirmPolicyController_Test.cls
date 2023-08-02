@isTest
private class ConfirmPolicyController_Test {

	@testSetup
	static void testSetup() {
		AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();

		RecordType rt = [select Id from RecordType where Name = : AGS_TestUtil.AGS_CASEACTION_RT_VALIDATE_DATA];
		insert new AGS_Case_Action_gne__c(ownerId = agsCase.OwnerId, AGS_Case_gne__c = agsCase.Id,
			Action_gne__c = AGS_TestUtil.AGS_CASEACTION_SACTION_PLEASE_VALIDATE_DATA, Action_Status_internal_gne__c = 'Open', recordtypeid = rt.Id,
			Send_Email__c = true);
	}

	static testMethod void submitConfirmCompliance_ShouldSubmitCaseAction () {
		//GIVEN
		AGS_Case_Action_gne__c validateDataAction = [SELECT AGS_Validate_Data_1_box_gne__c, AGS_Case_gne__c FROM AGS_Case_Action_gne__c];

		System.assertEquals(false, validateDataAction.AGS_Validate_Data_1_box_gne__c);
		ApexPages.currentPage().getParameters().put('mode', 'confirm');
		ApexPages.currentPage().getParameters().put('caseid', validateDataAction.AGS_Case_gne__c);
		ApexPages.currentPage().getParameters().put('caseactionid', validateDataAction.Id);
		ApexPages.currentPage().getParameters().put('interactionid', 'testInteractionId');
		ConfirmPolicyController ctrl = new ConfirmPolicyController();
		ctrl.blCheckboxConfirmCompliance = true;

		//WHEN
		PageReference returnUrl = ctrl.submitConfirmCompliance();

		//THEN
		System.assertEquals(2, [SELECT COUNT() FROM AGS_Case_Action_gne__c], 
			'Should return 2 records in total - updated Please Validate Data Case Action, and newly created Confirm Compliance Understanding Case Action');

		validateDataAction = [SELECT AGS_Validate_Data_1_box_gne__c, Action_Status_internal_gne__c, AGS_Case_gne__c FROM AGS_Case_Action_gne__c WHERE Id = :validateDataAction.Id];
		System.assertEquals(true, validateDataAction.AGS_Validate_Data_1_box_gne__c, 'Should set AGS_Validate_Data_1_box_gne__c to true after confirming Comliance.');
		System.assertEquals('Open', validateDataAction.Action_Status_internal_gne__c, 'Should set Action_Status_internal_gne__c to Open after confirming Comliance.');

		AGS_Case_Action_gne__c confrimComplianceAction = 
			[SELECT Confirm_Compliance_Understanding_gne__c, AGS_Case_gne__c, Action_Status_internal_gne__c, Send_Email__c 
			FROM AGS_Case_Action_gne__c WHERE Action_gne__c = : AGS_TestUtil.AGS_CASEACTION_SACTION_CONFIRM_COMPILANCE_UNDERSTANDING];

		System.assertEquals(true, confrimComplianceAction.Confirm_Compliance_Understanding_gne__c, 'Should create new Case Action of Confirm Compliance Understanding type');
		System.assertEquals(validateDataAction.AGS_Case_gne__c, confrimComplianceAction.AGS_Case_gne__c, 'Should create new Case Action of Confirm Compliance Understanding type');
		System.assertEquals('Open', confrimComplianceAction.Action_Status_internal_gne__c, 'Should create new Case Action of Confirm Compliance Understanding type');
		System.assertEquals(true, confrimComplianceAction.Send_Email__c, 'Should create new Case Action of Confirm Compliance Understanding type');

		String expectedUrl =  'https://' + ApexPages.currentPage().getHeaders().get('Host') 
			+ '/apex/IRecord?caseactionid=' + validateDataAction.Id + '&caseid=' + validateDataAction.AGS_Case_gne__c 
			+ '&interactionid=testInteractionId&mode=confirm';

		System.assertEquals(expectedUrl, returnUrl.getUrl());
	}

	static testMethod void submitConfirmCompliance_ShouldNotSubmitIfAlreadySubmitted () {
		//GIVEN
		AGS_Case_Action_gne__c validateDataAction = [SELECT AGS_Validate_Data_1_box_gne__c, AGS_Case_gne__c FROM AGS_Case_Action_gne__c];

		System.assertEquals(false, validateDataAction.AGS_Validate_Data_1_box_gne__c);
		ApexPages.currentPage().getParameters().put('mode', 'confirm');
		ApexPages.currentPage().getParameters().put('caseid', validateDataAction.AGS_Case_gne__c);
		ApexPages.currentPage().getParameters().put('caseactionid', validateDataAction.Id);
		ApexPages.currentPage().getParameters().put('interactionid', 'testInteractionId');
		ConfirmPolicyController ctrl = new ConfirmPolicyController();
		ctrl.blCheckboxConfirmCompliance = true;

		//WHEN
		validateDataAction.AGS_Validate_Data_1_box_gne__c = true;
		update validateDataAction;
		ctrl.submitConfirmCompliance();

		//THEN
		System.assertEquals(0, [SELECT COUNT() FROM AGS_Case_Action_gne__c WHERE  Action_gne__c = : AGS_TestUtil.AGS_CASEACTION_SACTION_CONFIRM_COMPILANCE_UNDERSTANDING], 
			'Should not execute submit function (create Confirm Compliance Record) if Pleas Validate Data case action is not open');
	}
}