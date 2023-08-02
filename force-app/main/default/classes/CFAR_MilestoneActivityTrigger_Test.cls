@isTest
private class CFAR_MilestoneActivityTrigger_Test {
	@testSetup
	static void setup() {
		CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
		CFAR_TestUtils.createTrialStatuses();
	}

	static testMethod void CFAR_MilestoneActivityTrigger_shouldUpdateTrialStatusWithLatestMa() {
		//GIVEN
		CFAR_Trial_gne__c testTrial = [SELECT frm_Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c];
		System.assertNotEquals(Label.CFAR_GSTARS_TRIAL_STATUS_COMPLETED_ENROLLMENT, testTrial.frm_Trial_Status_ref_gne__c);
		
		//WHEN
		CFAR_Milestone_Activity_gne__c[] milestoneActivities = [SELECT Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name IN ('LPI', 'LPO', 'Proposal Approval', 'SRT Protocol Approval', 'Activation')];
		for(CFAR_Milestone_Activity_gne__c ma : milestoneActivities){
			ma.Actual_Date_gne__c = System.Today();
		}
		
		update milestoneActivities;

		//THEN
		testTrial = [SELECT frm_Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c];
		System.assertEquals(Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION, testTrial.frm_Trial_Status_ref_gne__c,
			'Should update Trial Status to ' +  Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION + ' based on latest updated MA type.');
	}

	static testMethod void CFAR_MilestoneActivityTrigger_shouldUpdateTrialsWithStatusPropperForUpdatedMa() {
		//GIVEN
		CFAR_Milestone_Activity_gne__c[] milestoneActivities =
			[SELECT Name, Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name IN :CFAR_MilestonesUtils.maTypeToTrialStatus.keySet() LIMIT 10];

		Test.startTest();
		for (CFAR_Milestone_Activity_gne__c ma : milestoneActivities) {
			//WHEN
			ma.Actual_Date_gne__c = System.Today();
			update ma;

			//THEN
			System.assertEquals(CFAR_MilestonesUtils.maTypeToTrialStatus.get(ma.Name), [SELECT frm_Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c].frm_Trial_Status_ref_gne__c,
				'When Actual Date of MA is updated, trigger should update status of Trial with proper value');
		}
		Test.stopTest();
	}

	static testMethod void CFAR_MilestoneActivityTrigger_shouldNotUpdateTrialStatus() {
		//GIVEN
		String initialStatus = [SELECT frm_Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c].frm_Trial_Status_ref_gne__c;
		System.assertNotEquals(Label.CFAR_GSTARS_TRIAL_STATUS_COMPLETED_ENROLLMENT, initialStatus);

		CFAR_Milestone_Activity_gne__c[] milestoneActivities =
			[SELECT Name, Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name NOT IN :CFAR_MilestonesUtils.maTypeToTrialStatus.keySet() LIMIT 10];

		Test.startTest();
		for (CFAR_Milestone_Activity_gne__c ma : milestoneActivities) {
			//WHEN
			ma.Actual_Date_gne__c = System.Today();
			update ma;

			//THEN
			System.assertEquals(initialStatus, [SELECT frm_Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c].frm_Trial_Status_ref_gne__c,
				'Should not update Trial Status, if actual date is updated for Ma not from CFAR_MilestonesUtils.maTypeToTrialStatus');
		}
		Test.stopTest();
	}

	static testMethod void CFAR_MilestoneActivityTrigger_shouldUpdateActualDateLastChange() {
		//GIVEN
		CFAR_Milestone_Activity_gne__c randomMA = [SELECT Actual_Date_gne__c, Actual_Date_Last_Change_gne__c FROM CFAR_Milestone_Activity_gne__c LIMIT 1];
		randomMA.Actual_Date_Last_Change_gne__c = null;
		update randomMA;

		//WHEN
		randomMA.Actual_Date_gne__c = System.Today();
		update randomMA; 
	
		//THEN
		randomMA = [SELECT Actual_Date_Last_Change_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Id = :randomMA.Id];
		System.assertEquals(System.Today(), randomMA.Actual_Date_Last_Change_gne__c,
			'After updating Actual Date of any MA, trigger should set a timestamp on Actual_Date_Last_Change_gne__c field.');
	}

	static testMethod void CFAR_MilestoneActivityTrigger_shouldUpdateDatesOnTrial() {
		//GIVEN
		CFAR_Milestone_Activity_gne__c[] milestoneActivities = [SELECT Name, Actual_Date_gne__c, Actual_Date_Last_Change_gne__c, CFAR_Trial_ref_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name IN ('FPI', 'LPO', 'LPI')];
		
		//WHEN
		for(CFAR_Milestone_Activity_gne__c ma : milestoneActivities) {
			System.debug(ma.Name);
			ma.Actual_Date_gne__c = System.Today();
		}
		update milestoneActivities;

		//THEN
		CFAR_Trial_gne__c trial = [SELECT LPO_Actual_Date_gne__c, CFAR_Enrollment_Start_Date_gne__c, CFAR_Enrollment_End_Date_gne__c FROM CFAR_Trial_gne__c WHERE Id = : milestoneActivities[0].CFAR_Trial_ref_gne__c];
		CFAR_Milestone_Activity_gne__c lpoMA = [SELECT Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name = 'LPO'];
		System.assertEquals(lpoMA.Actual_Date_gne__c, trial.LPO_Actual_Date_gne__c,
			'Should update trial\'s LPO_Actual_Date_gne__c when Actual Date of lpo MA changes.');

		CFAR_Milestone_Activity_gne__c lpiMA = [SELECT Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name = 'LPI'];
		System.assertEquals(lpiMA.Actual_Date_gne__c, trial.CFAR_Enrollment_End_Date_gne__c,
			'Should update trial\'s CFAR_Enrollment_End_Date_gne__c when Actual Date of lpi MA changes.');

		CFAR_Milestone_Activity_gne__c fpiMA = [SELECT Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name = 'FPI'];
		System.assertEquals(fpiMA.Actual_Date_gne__c, trial.CFAR_Enrollment_Start_Date_gne__c,
			'Should update trial\'s CFAR_Enrollment_Start_Date_gne__c when Actual Date of fpi MA changes.');
	}

	static testMethod void CFAR_MilestoneActivityTrigger_shouldUpdatePlannedDatesOnTrial() {
		//WHEN
		CFAR_Milestone_Activity_gne__c lpi = [SELECT Name, Actual_Date_gne__c, CFAR_Trial_ref_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name = 'LPI'];
		lpi.Actual_Date_gne__c = null;
		lpi.Planned_Date_gne__c = System.Today().addDays(1); 

		CFAR_Milestone_Activity_gne__c fpi = [SELECT Name, Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Name = 'FPI'];
		fpi.Actual_Date_gne__c = null;
		fpi.Planned_Date_gne__c = System.Today().addDays(2); 

		update new List<CFAR_Milestone_Activity_gne__c>{lpi, fpi};
		
		//THEN
		CFAR_Trial_gne__c trial = [SELECT LPO_Actual_Date_gne__c, CFAR_Enrollment_Start_Date_gne__c, CFAR_Enrollment_End_Date_gne__c FROM CFAR_Trial_gne__c WHERE Id = : lpi.CFAR_Trial_ref_gne__c];
		System.assertEquals(System.Today().addDays(1), trial.CFAR_Enrollment_End_Date_gne__c,
			'Should update trial\'s CFAR_Enrollment_End_Date_gne__c with Planned Date of lpi when it changes and Actual Date is null.');
		System.assertEquals(System.Today().addDays(2), trial.CFAR_Enrollment_Start_Date_gne__c,
			'Should update trial\'s CFAR_Enrollment_Start_Date_gne__c with Planned Date of fpi when it changes and Actual Date is null.');
	}
	@isTest
	static void CFAR_MilestoneActivityTrigger_UpdateBaselineDates() {
		Test.startTest();
		List<CFAR_Milestone_Activity_gne__c> activitiesListBeforeUpdate = [SELECT Planned_Date_gne__c, Baselined_Date_gne__c FROM CFAR_Milestone_Activity_gne__c];
		for (CFAR_Milestone_Activity_gne__c activity : activitiesListBeforeUpdate) {
			System.assertEquals(null, activity.Baselined_Date_gne__c);
			activity.Planned_Date_gne__c = System.today();
		}

		update activitiesListBeforeUpdate;
		
		List<CFAR_Milestone_Activity_gne__c> activitiesListAfterUpdate = [SELECT Planned_date_gne__c, Baselined_Date_gne__c FROM CFAR_Milestone_Activity_gne__c];
		Test.stopTest();

		for (CFAR_Milestone_Activity_gne__c activity : activitiesListAfterUpdate) {
			System.assertEquals(activity.Planned_Date_gne__c, activity.Baselined_Date_gne__c);
			System.assertEquals(System.today(), activity.Baselined_Date_gne__c);
		}
	}	

	@IsTest
	static void CFAR_MilestoneActivityTrigger_MissingPlannedDates() {
		Test.startTest();
		List<CFAR_Milestone_Activity_gne__c> activitiesListBeforeUpdate = [SELECT Planned_Date_gne__c, Baselined_Date_gne__c FROM CFAR_Milestone_Activity_gne__c];
		
		activitiesListBeforeUpdate[0].Planned_Date_gne__c = System.today();
		activitiesListBeforeUpdate[2].Planned_Date_gne__c = System.today();
		activitiesListBeforeUpdate[4].Planned_Date_gne__c = System.today();

		update activitiesListBeforeUpdate;

		List<CFAR_Milestone_Activity_gne__c> activitiesListAfterUpdate = [SELECT Planned_date_gne__c, Baselined_Date_gne__c FROM CFAR_Milestone_Activity_gne__c];

		System.assertEquals(System.today(), activitiesListAfterUpdate[0].Planned_Date_gne__c);
		System.assertEquals(System.today(), activitiesListAfterUpdate[2].Planned_Date_gne__c);
		System.assertEquals(System.today(), activitiesListAfterUpdate[4].Planned_Date_gne__c);
		for (CFAR_Milestone_Activity_gne__c activity :activitiesListAfterUpdate) {
			System.assertEquals(null, activity.Baselined_Date_gne__c);
		}
	}

	@isTest
	static void CFAR_MilestoneActivityTrigger_NegativeDates() {
		Test.startTest();
		List<CFAR_Milestone_Activity_gne__c> activitiesListBeforeUpdate = [SELECT Planned_Date_gne__c, Baselined_Date_gne__c, Actual_Date_gne__c FROM CFAR_Milestone_Activity_gne__c];
		for (CFAR_Milestone_Activity_gne__c activity : activitiesListBeforeUpdate) {
			System.assertEquals(null, activity.Actual_Date_gne__c);
			System.assertEquals(null, activity.Baselined_Date_gne__c);
			activity.Planned_Date_gne__c = System.today().addDays(-2);
		}

		try {
			update activitiesListBeforeUpdate;
		} catch (Exception e) {
			List<CFAR_Milestone_Activity_gne__c> activitiesListAfterUpdate = [SELECT Planned_date_gne__c, Baselined_Date_gne__c FROM CFAR_Milestone_Activity_gne__c];
			for (CFAR_Milestone_Activity_gne__c activity : activitiesListAfterUpdate) {
				System.assertEquals(null, activity.Baselined_Date_gne__c);
				System.assertEquals(null, activity.Planned_Date_gne__c);
			}
			System.assert(e.getMessage().contains('Your Planned date is in the past please enter actual date'));
		}
		Test.stopTest();
	}
}