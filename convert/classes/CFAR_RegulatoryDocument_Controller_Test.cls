@isTest(SeeAllData = false)
private class CFAR_RegulatoryDocument_Controller_Test {
	
	@testSetup
	static void setup(){
		CFAR_TestUtils.createTrialStatuses();
	}
	@isTest 
	static void testTrialClosure() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();

			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_HOLD);
			if(testTrial.Trial_Status_ref_gne__c != null) {
				System.debug('#STW#');
				cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
				System.assertEquals(true, cont.statusEditMode);
			}
			System.debug('#TTrial: '+cont.trialWrapper);
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			if(testTrial.Trial_Status_ref_gne__c != null) {
				System.debug('#STW#');
				cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
				System.assertEquals(true, cont.statusEditMode);
			}
			System.debug('#TTrial: '+cont.trialWrapper); 
			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='Study Closure Received',Active_gne__c=true);
			insert rta;

            Test.startTest();
			cont.currentRDT = CFAR_TestUtils.createRegDoc(testTrial, 'Study Closure Received', Date.today().addDays(5), Date.today(), false); 
			cont.saveRDT();
			testTrial = CFAR_TestUtils.refreshTrial(testTrial);
			
			System.debug('---- Study_Closure_Letter_Received_gne__c ' + testTrial.Study_Closure_Letter_Received_gne__c);
			System.debug('---- Study_Closure_Received_Date_gne__c ' + testTrial.Study_Closure_Received_Date_gne__c);
			
			CFAR_TestUtils.setActualDateForMilestones(testTrial, Date.today());
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_ENROLLMENT);
			CFAR_TestUtils.createComment(testTrial, 'Test Comment');
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED);
			
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			System.debug('----- ' +  testTrial.frm_Trial_Status_ref_gne__c);
			System.assertEquals(false, cont.statusEditMode);
			
			testTrial.IRB_Required_gne__c = 'No';
			testTrial.FSR_Required_gne__c = 'No';
			testTrial.Study_Closure_Letter_Received_gne__c=true;
			testTrial.Study_Closure_Received_Date_gne__c=Date.today();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			System.debug('----- ' +  testTrial.frm_Trial_Status_ref_gne__c);
			System.assertEquals(false, cont.statusEditMode);
			
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			System.assertEquals(false, cont.statusEditMode);
            Test.stopTest();
		}
	}

	@isTest 
	static void testStudyClosureReceived() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='Study Closure Letter Sent',Active_gne__c=true, Study_Stage__c='Closure');
			insert rta;

			cont.currentRDT = CFAR_TestUtils.createRegDoc(testTrial, 'Study Closure Letter Sent', Date.today().addDays(5), Date.today(), false); 
			cont.editRDT();
			cont.saveRDT();
			testTrial = CFAR_TestUtils.refreshTrial(testTrial);
			
			System.assertEquals(true, testTrial.Study_Closure_Letter_Received_gne__c);
			System.assertEquals(cont.currentRDT.Date_Received_gne__c, testTrial.Study_Closure_Received_Date_gne__c);
		}
	}

	@isTest 
	static void testIRBRenewal() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);			
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.trial.IRB_Required_gne__c = 'Yes'; 
			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='IRB Renewal',Active_gne__c=true, Study_Stage__c='Closure');
			insert rta;

			cont.currentRDT = CFAR_TestUtils.createRegDoc(testTrial, 'IRB Renewal', Date.today().addDays(5), Date.today(), false); 
			System.debug('#RDTE: '+cont.currentRDT);
			cont.editRDT();
			cont.saveRDT();
			testTrial = CFAR_TestUtils.refreshTrial(testTrial);
			System.assertEquals(cont.currentRDT.Expiry_Date_gne__c, testTrial.IRB_Renewal_Date_gne__c);
		}
	}

	@isTest 
	static void testIRBClosureLetter() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial.IRB_Required_gne__c = 'YES';
			update testTrial;
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='IRB Closure Letter Received',Active_gne__c=true, Study_Stage__c='Closure');
			insert rta;

			cont.currentRDT = CFAR_TestUtils.createRegDoc(testTrial, 'IRB Closure Letter Received', Date.today().addDays(5), Date.today(), false); 
			cont.editRDT();
			cont.saveRDT();
			testTrial = CFAR_TestUtils.refreshTrial(testTrial);
			System.assertEquals(true, testTrial.IRB_Closure_Letter_Received_gne__c);
			System.assertEquals(cont.currentRDT.Date_Received_gne__c, testTrial.IRB_Closure_Received_Date_gne__c);
		}
	}

	@isTest 
	static void testFinalStudyReportReceived() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial.FSR_Required_gne__c = 'YES';
			update testTrial;
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='Final Study Report Received',Active_gne__c=true, Study_Stage__c='Closure');
			insert rta;

			cont.currentRDT = CFAR_TestUtils.createRegDoc(testTrial, 'Final Study Report Received', Date.today().addDays(5), Date.today(), false);
			cont.editRDT();
			cont.saveRDT();
			SYstem.debug('====test test currentRDT: ' + cont.currentRDT);
			testTrial = CFAR_TestUtils.refreshTrial(testTrial);
			System.assertEquals(true, testTrial.Final_Study_Report_Received_gne__c);
			System.assertEquals(cont.currentRDT.Date_Received_gne__c, testTrial.Final_Study_Report_Received_Date_gne__c);
		}
	}


	@isTest
	static void testEditMode() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_HOLD);
			if (testTrial.Trial_Status_ref_gne__c != null)
				cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			System.assertEquals(true, cont.statusEditMode);

			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			System.assertEquals(true, cont.statusEditMode);

			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, Label.CFAR_GSTARS_TRIAL_STATUS_COMPLETED_ENROLLMENT);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			System.assertEquals(true, cont.statusEditMode);
		}
	}

	@isTest 
	static void testRDTRecievedDate() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='IRB Renewal',Active_gne__c=true);
			insert rta;

			cont.currentRDT = CFAR_TestUtils.createRegDoc(testTrial, 'IRB Renewal', Date.today().addDays(5), Date.today().addDays(1), false); 
			cont.saveRDT();
			System.assertEquals('Date cannot be in the future', cont.errorMessage);
			System.assertEquals(true, cont.isError);
			cont.cancelRDT();
			System.assertEquals(false, cont.isError);
		}
	}

	@isTest 
	static void testRDTEdit() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='IRB Renewal',Active_gne__c=true);
			insert rta;
			CFAR_Tracking_Activity_gne__c rta1 = new CFAR_Tracking_Activity_gne__c(name='IRB Closure Letter',Active_gne__c=true);
			insert rta1;


			CFAR_Regulatory_Document_Tracking_gne__c rdt1 = CFAR_TestUtils.createRegDoc(testTrial, 'IRB Renewal', Date.today().addDays(5), Date.today(), false); 
			cont.currentRDT = rdt1; 
			cont.saveRDT();
			System.assertEquals(cont.currentRDT.Id, rdt1.Id);
			
			CFAR_Regulatory_Document_Tracking_gne__c rdt2 = CFAR_TestUtils.createRegDoc(testTrial, 'IRB Closure Letter', Date.today().addDays(5), Date.today(), false); 
			cont.currentRDT = rdt2;
			cont.saveRDT();
			System.assertEquals(cont.currentRDT, rdt2);
			cont.currentRDTId = rdt1.Id;
			cont.editRDT();			
			System.assertEquals(cont.currentRDT.Id, rdt1.Id);
			System.assertEquals(false, cont.editMode);
			System.assertEquals(false, cont.isError);
		}
	}

	@isTest 
	static void testRDTEditActivation() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='ML (Medical License)',Active_gne__c=true, Study_Stage__c='Activation');
			insert rta;

			CFAR_Regulatory_Document_Tracking_gne__c rdt1 = CFAR_TestUtils.createRegDoc(testTrial, 'ML (Medical License)', Date.today().addDays(5), Date.today(), false); 
			cont.currentRDT = rdt1; 
			cont.saveRDT();
			System.assertEquals(cont.currentRDT.Id, rdt1.Id);

			cont.activationCurrentRDTId = rdt1.Id;
			cont.editRDT();
			cont.saveAllActivationRtds();
			
		}
	}
	
	@isTest 
	static void testRDTEditAClosure() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta1 = new CFAR_Tracking_Activity_gne__c(name='Study Closure Letter Sent',Active_gne__c=true, Study_Stage__c='Closure');
			insert rta1;
			
			CFAR_Regulatory_Document_Tracking_gne__c rdt2 = CFAR_TestUtils.createRegDoc(testTrial, 'Study Closure Letter Sent', Date.today().addDays(5), Date.today(), false); 
			cont.currentRDT = rdt2;
			cont.saveRDT();
			System.assertEquals(cont.currentRDT, rdt2);

			cont.activationCurrentRDTId = rdt2.Id;
			cont.editRDT();
			cont.saveAllClosureRtds();
			
		}
	}

	@isTest 
	static void testRDTEditMaintenance() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta1 = new CFAR_Tracking_Activity_gne__c(name='Maintenance Activity',Active_gne__c=true, Study_Stage__c='Maintenance');
			insert rta1;
			
			CFAR_Regulatory_Document_Tracking_gne__c rdt2 = CFAR_TestUtils.createRegDoc(testTrial, 'Maintenance Activity', Date.today().addDays(5), Date.today(), false); 
			cont.currentRDT = rdt2;
			cont.saveRDT();
			System.assertEquals(cont.currentRDT, rdt2);

			cont.activationCurrentRDTId = rdt2.Id;
			cont.editRDT();
			cont.saveAllAMaintenanceRtds();
			
		}
	} 

	@isTest 
	static void testAddNewRDT() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='IRB Renewal',Active_gne__c=true);
			insert rta;

			CFAR_Regulatory_Document_Tracking_gne__c rdt1 = CFAR_TestUtils.createRegDoc(testTrial, 'IRB Renewal', Date.today().addDays(5), Date.today(), false); 
			cont.currentRDT = rdt1; 
			cont.saveRDT();
			System.assertEquals(cont.currentRDT.Id, rdt1.Id);
			cont.addNewRDT();
			System.assertEquals(cont.currentRDT.Id, null);
			System.assertEquals(testTrial.id, cont.currentRDT.CFAR_Trial_gne__c);
		}
	}

	@isTest 
	static void testEditTrial() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.editTrial();
			
        //iNDNumber = trial.IND_gne__c;
        //tempTrial.Regulatory_Document_Complete_Date_gne__c = trial.Regulatory_Document_Complete_Date_gne__c;  
			System.assertEquals(true, cont.editMode);
			//((CFAR_Trial_gne__c)cont.trialWrapper.trial)
			cont.trial.IRB_Required_gne__c = 'YES';
			cont.tempTrial.IND_Exempt_Letter_Date_gne__c = Date.today();
			cont.cancelTrial();
			System.assertNotEquals('YES', cont.trial.IRB_Required_gne__c);
			System.assertNotEquals(Date.today(), cont.trial.IND_Exempt_Letter_Date_gne__c);
			
			cont.editTrial();
			cont.tempTrial.IND_Exempt_Letter_Date_gne__c = Date.today();
			cont.selectedINDRequired = 'YES';
	        cont.selectedIRBRequired = 'YES';
	        cont.selectedFSRRequired = 'YES';

			cont.saveTrial();
			System.assertEquals('YES', cont.trial.IND_Required_gne__c);
			System.assertEquals('YES', cont.trial.FSR_Required_gne__c);
			System.assertEquals('YES', cont.trial.IRB_Required_gne__c);
			System.assertEquals(Date.today(), cont.trial.IND_Exempt_Letter_Date_gne__c);
			
		}
	}

	@isTest 
	static void testSaveRDT() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);

			CFAR_Tracking_Activity_gne__c rta = new CFAR_Tracking_Activity_gne__c(name='Study Closure Letter',Active_gne__c=true);
			insert rta;

			cont.currentRDT = CFAR_TestUtils.createRegDoc(testTrial, 'Study Closure Letter', Date.today().addDays(5), Date.today(), false); 
			cont.saveRDT();
			
			List<CFAR_Regulatory_Document_Tracking_gne__c> testRDT = [Select Id from CFAR_Regulatory_Document_Tracking_gne__c where CFAR_Trial_gne__c = :testTrial.Id];
			System.assertEquals(1, testRDT.size());

		}
	}

	@isTest 
	static void testSavePub() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			
			//CFAR_Publication_gne__c currentPublication = new CFAR_Publication_gne__c(CFAR_Trial_ref_gne__c = trialId);
        	
			cont.createNewPublication();
			System.assertEquals(cont.currentPublication.CFAR_Trial_ref_gne__c, testTrial.Id); 
			cont.currentPublication.Author_gne__c = 'MSP_TEST';
			cont.currentPublication.Date_Published_gne__c = Date.today();
			cont.submitPublication();
			System.assertEquals(1, cont.getPubications().size());
			 
			List<CFAR_Publication_gne__c> testPub = [Select Id from CFAR_Publication_gne__c where CFAR_Trial_ref_gne__c = :testTrial.Id];
			System.assertEquals(1, testPub.size());

		}
	}
	

	@isTest 
	static void testSavePubIncorrectDate() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser) {
			CFAR_RegulatoryDocument_Controller cont = new CFAR_RegulatoryDocument_Controller();			
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial();
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			
			cont.createNewPublication();
			System.assertEquals(cont.currentPublication.CFAR_Trial_ref_gne__c, testTrial.Id); 
			cont.currentPublication.Author_gne__c = 'MSP_TEST';
			cont.currentPublication.Date_Received_gne__c = Date.today().addDays(1);
			cont.submitPublication();
			System.assertEquals('Date Received cannot be in the future',cont.errorMessage);
			 
			List<CFAR_Publication_gne__c> testPub = [Select Id from CFAR_Publication_gne__c where CFAR_Trial_ref_gne__c = :testTrial.Id];
			System.assertEquals(0, testPub.size());
		}
	}

	@isTest static void test_method_two() {
		// Implement test code
	}
}