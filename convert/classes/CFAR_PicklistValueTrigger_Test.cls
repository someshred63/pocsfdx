@isTest
private class CFAR_PicklistValueTrigger_Test {

	@testSetup
	static void setup() {
		List<CFAR_Picklist_Value_gne__c> picklistValues = CFAR_TestUtils.createPicklistValue(new List<String> {'Label Expansion', 'Guidelines / Compendia Listing', 'CDP Data Gaps',
			'Published Manuscript', 'Congress: Oral Presentation', 'Congress: Abstract or Poster'}, 'Impact');

		CFAR_Trial_Picklist_gne__c[] trialPicklistJunctions = new List<CFAR_Trial_Picklist_gne__c>();
		CFAR_Trial_gne__c trial1 = CFAR_TestUtils.createTestTrial3('RO-IIS-2017-22222');
		CFAR_Trial_gne__c trial2 = CFAR_TestUtils.createTestTrial2();

		for (CFAR_Picklist_Value_gne__c pv : picklistValues) {
			if(pv.Name == 'Label Expansion'){
				trialPicklistJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_PicklistValue_ref_gne__c = pv.Id, CFAR_Trial_ref_gne__c = trial1.id));
				trialPicklistJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_PicklistValue_ref_gne__c = pv.Id, CFAR_Trial_ref_gne__c = trial2.id));
			} else if (pv.Name == 'CDP Data Gaps'){
				trialPicklistJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_PicklistValue_ref_gne__c = pv.Id, CFAR_Trial_ref_gne__c = trial1.id));
				trialPicklistJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_PicklistValue_ref_gne__c = pv.Id, CFAR_Trial_ref_gne__c = trial2.id));
			} else if (pv.Name == 'Published Manuscript'){
				trialPicklistJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_PicklistValue_ref_gne__c = pv.Id, CFAR_Trial_ref_gne__c = trial2.id));
			} else if (pv.Name == 'Guidelines / Compendia Listing'){
				trialPicklistJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_PicklistValue_ref_gne__c = pv.Id, CFAR_Trial_ref_gne__c = trial1.id));
			}
		}

		insert trialPicklistJunctions;
	}

	static testMethod void CFAR_PicklistValue_triggerShouldUpdateTrialImpacts() {
		//GIVEN
		CFAR_Picklist_Value_gne__c[] picklistValues = [SELECT Name FROM CFAR_Picklist_Value_gne__c WHERE Name IN ('Label Expansion', 'Published Manuscript')];
		for (CFAR_Picklist_Value_gne__c pv : picklistValues) {
			if (pv.Name == 'Label Expansion') {
				pv.Name = 'testVal1';
			} else {
				pv.Name = 'testVal2';
			}
		}

		//WHEN
		Test.startTest();
		update picklistValues;
		Test.stopTest();

		//THEN
		CFAR_Trial_gne__c trial1 = [SELECT Impacts_gne__c FROM CFAR_Trial_gne__c WHERE IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-22222'];
		//System.assertEquals('CDP Data Gaps;Guidelines / Compendia Listing;testVal1', trial1.Impacts_gne__c);

		CFAR_Trial_gne__c trial2 = [SELECT Impacts_gne__c FROM CFAR_Trial_gne__c WHERE IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-11111'];
		System.assertEquals('CDP Data Gaps;testVal1;testVal2', trial2.Impacts_gne__c);
	}
}