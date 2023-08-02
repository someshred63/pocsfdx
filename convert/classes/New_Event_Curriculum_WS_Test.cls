/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class New_Event_Curriculum_WS_Test {

	static testMethod void SpeakerBureauCurriculumNDispositionNoUpdateTest () {
		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'N';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);

		System.debug(loggingLevel.Error, '*** nc.Disposition: ' + nc.Disposition);

		System.assertEquals('SUCCESS',msg.Status);
		System.assertEquals('',msg.Message);
	}

	@isTest
	static void shouldSavePRCCodeAsName() {
		//given 
		Speaker_Bureau_gne__c sb = getBureau();
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = 'ABC0000000';
		nc.name = 'Alamakota';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'other';
		nc.SpeakerBureauCurriculum = 'Y';

		//when
		New_Event_Curriculum_WS.Messages msg = New_Event_Curriculum_WS.create_new_curriculum(nc);        

		//then
		//System.assertEquals(new New_Event_Curriculum_WS.Messages(), msg);
		Event_Curriculum_gne__c curriculum = [SELECT Id, Name FROM Event_Curriculum_gne__c LIMIT 1];
		System.assertEquals('ABC0000000', curriculum.Name);
	}

	@isTest
	static void shouldSetPRCodeAsNameOnUpdate() {
		//given 
		Speaker_Bureau_gne__c sb = getBureau();
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = 'ABC0000000';
		nc.name = 'Alamakota';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';
		New_Event_Curriculum_WS.create_new_curriculum(nc);

		//when
		Event_Curriculum_gne__c curriculum = [SELECT Id, Name FROM Event_Curriculum_gne__c LIMIT 1];
		curriculum.Name = 'Not PRC';
		update curriculum;

		//then
		Event_Curriculum_gne__c refreshedCurriculum = [SELECT Id, Name FROM Event_Curriculum_gne__c LIMIT 1];
		System.assertEquals('ABC0000000', refreshedCurriculum.Name);
	}

	private static Speaker_Bureau_gne__c getBureau() {
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];
		return sb;
	}

	static testMethod void SpeakerBureauCurriculumNDispositionUpdateTest () {
		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'Update';
		nc.SpeakerBureauCurriculum = 'N';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('SUCCESS',msg.Status);
		System.assertEquals('',msg.Message);
	}
	
	static testMethod void SpeakerBureauCurriculumNDispositionUpdate2Test () {
		
		Event_Curriculum_gne__c e1 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '1233'
		);
		insert e1;
		Event_Curriculum_gne__c e3 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '1235'        
		);
		insert e3;
		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '1234',
			Replacing_Curr_gne__c = e1.Id,
			Replaced_By_Curr_gne__c = e3.Id
		);
		insert e2;
		e3.Replacing_Curr_gne__c = e2.Id;
		e3.Aprimo_ID_gne__c = e3.Id;
		update e3;
		e1.Replaced_By_Curr_gne__c = e2.Id;
		e1.Aprimo_ID_gne__c = e1.Id;
		update e1;

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '1234';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'Update';
		nc.SpeakerBureauCurriculum = 'N';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('SUCCESS',msg.Status);
		System.assertEquals('',msg.Message);

		List<Event_Curriculum_gne__c> events = new List<Event_Curriculum_gne__c>([
			Select Id, Replacing_Curr_gne__c, Replaced_By_Curr_gne__c, EDM_is_deleted_gne__c From Event_Curriculum_gne__c
			Where EDM_is_deleted_gne__c = false
			Order by CreatedDate
		]);

		System.assertEquals(2, events.size());
		System.assertEquals(null, events[0].Replaced_By_Curr_gne__c);
		System.assertEquals(null, events[1].Replacing_Curr_gne__c);

		events = new List<Event_Curriculum_gne__c>([
			Select Id, Replacing_Curr_gne__c, Replaced_By_Curr_gne__c, EDM_is_deleted_gne__c From Event_Curriculum_gne__c
			Where EDM_is_deleted_gne__c = true
			Order by CreatedDate
		]);
		System.assertEquals(1, events.size());

	}

	static testMethod void SpeakerBureauInsCurriculumTest () {
		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assertEquals('ERROR: PRC CODE IS NULL',msg.Message);
	}

	static testMethod void SpeakerBureauInsCurriculumTest2() {
		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assertEquals('BUREAU ERROR: CHECK FOR EXISTING BUREAU\'S FAILED',msg.Message);
	}

	static testMethod void SpeakerBureauInsCurriculumTest3() {
		

		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '12345'
		);
		insert e2;

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assertEquals('BUREAU ERROR: CHECK FOR EXISTING BUREAU\'S FAILED',msg.Message);
	}

	static testMethod void SpeakerBureauInsCurriculumTest4() {
		

		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '12345'
		);
		insert e2;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '0001';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assertEquals('Previous curriculum PRC code not found',msg.Message);
	}

	static testMethod void SpeakerBureauInsCurriculumTest5() {
		
		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '12345'
		);
		insert e2;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12346';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '12345';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'WITHDRAW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assertEquals('WITHDRAW Disposition doesn\'t support insert operation',msg.Message);
	}

	static testMethod void SpeakerBureauInsCurriculumTest6() {
		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assertEquals('ERROR: NO SPEAKER BUREAU ID',msg.Message);
	}

	static testMethod void SpeakerBureauInsCurriculumTest7() {
		
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '0001';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assertEquals('Previous curriculum PRC code not found',msg.Message);
	}
	static testMethod void SpeakerBureauInsCurriculumTest8() {
		
		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '0001'
		);
		insert e2;
		insert new Speaker_Training_gne__c(
			Event_Curriculum_gne__c = e2.Id,
			Trained_Date_gne__c = Date.today()
		);
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '0001';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = 'No';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('SUCCESS',msg.Status);
		System.assertEquals('',msg.Message);
	}

	static testMethod void SpeakerBureauInsCurriculumTest9() {
		
		Event_Curriculum_gne__c e3 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '0001'
		);
		insert e3;
		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '12345'
		);
		insert e2;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.Previous_Version_Regulatory_Code = '0001';
		nc.Speaker_Retraining_Required = 'Yes';
		nc.Disposition = 'Withdraw';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('SUCCESS',msg.Status);
		System.assertEquals('',msg.Message);
	}
//EXCEPTIONS
	static testMethod void SpeakerBureauCurriculumNoNameTest () {
		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = '';
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('FAILURE',msg.Status);
		System.assert(msg.Message.contains('MODULES ERROR:'));
	}

	static testMethod void SpeakerBureauInsCurriculumExcTest () {

		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			//Aprimo_ID_gne__c = '12345',
			Curriculum_External_Id_gne__c = '12345'
		);
		insert e2;
		System.debug('e2: ' + e2 );

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];
		System.debug('sb: ' + sb );

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = 'Whatever';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = '';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);

		Event_Curriculum_gne__c current_curriculum = [SELECT ID, Name FROM Event_Curriculum_gne__c LIMIT 1];
		System.debug('current_curriculum: ' + current_curriculum );

		System.assertEquals('FAILURE',msg.Status);
		System.debug('msg.Message: ' + msg.Message );
		System.assert(msg.Message.contains('CURRICULUM ERROR:'));
	}

	static testMethod void duplicateTrainingRecordsIM10571615Test() {
		
		Event_Curriculum_gne__c e2 = new Event_Curriculum_gne__c(
			EDM_Is_Deleted_gne__c = false,
			Aprimo_ID_gne__c = '0001'
		);
		insert e2;
		insert new Speaker_Training_gne__c(
			Event_Curriculum_gne__c = e2.Id,
			Trained_Date_gne__c = Date.today()
		);
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'New Bureau'
		);
		insert sb;
		sb = [Select Name,Aprimo_Bureau_ID_gne__c From Speaker_Bureau_gne__c Limit 1];

		New_Event_Curriculum_WS.Messages msg = new New_Event_Curriculum_WS.Messages();
		
		New_Event_Curriculum_WS.New_Curriculum nc = new New_Event_Curriculum_WS.New_Curriculum();
		nc.PRC_Code = '12345';
		nc.name = '';
		nc.version_number = '';
		nc.Speaker_bureau_IDs = sb.Aprimo_Bureau_ID_gne__c;
		nc.start_date = Date.today();
		nc.Approval_date = Date.today();
		nc.Deactivation_Date = Date.today()+100;
		nc.prc_number = '';
		nc.brands = '';
		nc.Previous_Version_Regulatory_Code = '0001';
		nc.Replaced_Asset_Regulatory_Code = '';
		nc.Existing_T2E_Regulatory_Code = '';
		nc.Target_Audience = '';
		nc.Speaker_Retraining_Required = 'No';
		nc.Disposition = 'NEW';
		nc.SpeakerBureauCurriculum = 'Y';

		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('SUCCESS',msg.Status);
		System.assertEquals('',msg.Message);
		List<Speaker_Training_gne__c> speakerTrainings = [SELECT Id FROM Speaker_Training_gne__c WHERE Event_Curriculum_gne__c != :e2.Id];
		System.assertEquals(1, speakerTrainings.size());

		nc.Disposition = 'UPDATE';
		msg = New_Event_Curriculum_WS.create_new_curriculum(nc);
		System.assertEquals('SUCCESS',msg.Status);
		System.assertEquals('',msg.Message);

		List<Speaker_Training_gne__c> speakerTrainingsAfterUpdate = [SELECT Id FROM Speaker_Training_gne__c WHERE Event_Curriculum_gne__c != :e2.Id];
		System.assertEquals(1, speakerTrainingsAfterUpdate.size());
	}

	@isTest
	public static void shouldCopyNewestTrainingToSuccessor() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();
		Event_Curriculum_gne__c prev = insertCurriculum(null, 1);
		Account speaker = createSpeaker();
		createSpeakerTraining(speaker.Id, prev.Id, false, 0);
		createSpeakerTraining(speaker.Id, prev.Id, true, -5);

		//when
		New_Event_Curriculum_WS.Messages result = insertSuccessorCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c);

		//then
		System.assertEquals('', result.Message);
		List<Speaker_Training_gne__c> automaticSpeakerTrainings = [SELECT Id, Medical_Event_ID_gne__c FROM Speaker_Training_gne__c WHERE Delivery_Method_gne__c = 'Automatic'];        
		System.assertEquals(1, automaticSpeakerTrainings.size());
		System.debug(loggingLevel.Error, '*** automaticSpeakerTrainings: ' + automaticSpeakerTrainings);
		System.assert(automaticSpeakerTrainings[0].Medical_Event_ID_gne__c == null);
	}
    
	@isTest
	public static void shouldCopyNewestTrainingToSuccessorOnWithdrawal() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();
		Event_Curriculum_gne__c prev = insertCurriculum(null, 1);
		Event_Curriculum_gne__c succ = insertCurriculum(prev.Id, 2);
		prev.Replaced_By_Curr_gne__c = succ.Id;
		update prev;
		Account speaker = createSpeaker();
		Speaker_Training_gne__c trainingWithoutME = createSpeakerTraining(speaker.Id, prev.Id, false, 0);
		Speaker_Training_gne__c trainingWithME = createSpeakerTraining(speaker.Id, prev.Id, true, -5);

		//when
		New_Event_Curriculum_WS.Messages result = withdrawSuccessorCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c);

		//then
		System.assertEquals('', result.Message);
		List<Speaker_Training_gne__c> automaticSpeakerTrainings = [SELECT Id, Medical_Event_ID_gne__c, Trained_Date_gne__c FROM Speaker_Training_gne__c WHERE Delivery_Method_gne__c = 'Automatic'];        
		System.assertEquals(1, automaticSpeakerTrainings.size());
		System.assert(automaticSpeakerTrainings[0].Medical_Event_ID_gne__c == null);
		System.debug(loggingLevel.Error, '*** automaticSpeakerTrainings[0].Trained_Date_gne__c: ' + automaticSpeakerTrainings[0].Trained_Date_gne__c);
		System.debug(loggingLevel.Error, '*** prev.Approval_Date_gne__c: ' + prev.Approval_Date_gne__c);
		System.debug(loggingLevel.Error, '*** succ.Approval_Date_gne__c: ' + succ.Approval_Date_gne__c);
		System.debug(loggingLevel.Error, '*** trainingWithoutME.Trained_Date_gne__c: ' + trainingWithoutME.Trained_Date_gne__c);
		System.debug(loggingLevel.Error, '*** trainingWithME.Trained_Date_gne__c: ' + trainingWithME.Trained_Date_gne__c);
		System.debug(loggingLevel.Error, '*** automaticSpeakerTrainings: ' + automaticSpeakerTrainings);
	}


	@isTest
	public static void shouldNotCopyTrainingToSuccessorOnWithdrawalAsItAlreadyExists() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();
		Event_Curriculum_gne__c prev = insertCurriculum(null, 1);
		Event_Curriculum_gne__c succ = insertCurriculum(prev.Id, 2);
		prev.Replaced_By_Curr_gne__c = succ.Id;
		update prev;
		Account speaker = createSpeaker();
		createSpeakerTraining(speaker.Id, prev.Id, false, 0);
		createSpeakerTraining(speaker.Id, prev.Id, true, -5);
		New_Event_Curriculum_WS.Messages result;
		List<Speaker_Training_gne__c> automaticSpeakerTrainings;

		//when
		result = insertSuccessorCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c);
		result = withdrawSuccessorCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c);

		//then
		System.assertEquals('', result.Message);
		automaticSpeakerTrainings = [SELECT Id, Medical_Event_ID_gne__c FROM Speaker_Training_gne__c WHERE Delivery_Method_gne__c = 'Automatic'];
		System.assertEquals(1, automaticSpeakerTrainings.size());
		System.assert(automaticSpeakerTrainings[0].Medical_Event_ID_gne__c == null);
	}

	@isTest
	public static void shouldCopyAutomaticToSecondSuccessor() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();
		Event_Curriculum_gne__c orig = insertCurriculum(null, 1);
		Event_Curriculum_gne__c firstSucc = insertCurriculum(orig.Id, 2);
		Event_Curriculum_gne__c secondSucc = insertCurriculum(orig.Id, 3);
		orig.Replaced_By_Curr_gne__c = firstSucc.Id;
		firstSucc.Replacing_Curr_gne__c = orig.Id;
		firstSucc.Replaced_By_Curr_gne__c = secondSucc.Id;
		secondSucc.Replacing_Curr_gne__c = firstSucc.Id;
		update new List<Event_Curriculum_gne__c> {orig, firstSucc, secondSucc};

		Account speaker = createSpeaker();
		createSpeakerTraining(speaker.Id, orig.Id, false, 0);
		createSpeakerTraining(speaker.Id, orig.Id, true, -5);
		New_Event_Curriculum_WS.Messages result;
		List<Speaker_Training_gne__c> automaticSpeakerTrainings;

		//when
		Test.startTest();
		result = updateSuccessorCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 2);
		Test.stopTest();

		//then
		System.assertEquals('', result.Message);
		automaticSpeakerTrainings = [SELECT Id, Medical_Event_ID_gne__c, Trained_Date_gne__c FROM Speaker_Training_gne__c 
										WHERE Event_Curriculum_gne__c = :secondSucc.Id AND Delivery_Method_gne__c = 'Automatic'];
		System.assertEquals(1, automaticSpeakerTrainings.size());
		System.debug(loggingLevel.Error, '*** automaticSpeakerTrainings: ' + automaticSpeakerTrainings);
	}

	@isTest
	public static void shouldCreateBrandsRecords() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();

		//when
		New_Event_Curriculum_WS.Messages result = insertNewCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 'Brand1', '{"Brand1":["None"]}');

		//then
		System.assertEquals('', result.Message);
		System.assertEquals(1, [SELECT Count() FROM EDM_Event_Curriculum_Brand__c]);
	}


	@isTest
	public static void shouldRemediateOverlappingBrandsRecords() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();
		New_Event_Curriculum_WS.Messages result = insertNewCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 'Brand1', '{"Brand1":["None"]}');
		System.assertEquals('', result.Message);
		

		//when        
		result = updateCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 'Brand1;Brand2', '{"Brand1":["None"], "Brand2":["None"]}');

		//then
		System.assertEquals('', result.Message);
		System.assertEquals(2, [SELECT Count() FROM EDM_Event_Curriculum_Brand__c]);


		//when        
		result = updateCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 'Brand2;Brand3', '{"Brand2":["None"], "Brand3":["None"]}');

		//then
		System.assertEquals('', result.Message);
		System.assertEquals(2, [SELECT Count() FROM EDM_Event_Curriculum_Brand__c]);
		List<EDM_Event_Curriculum_Brand__c> brands = [SELECT EDM_Brand__c FROM EDM_Event_Curriculum_Brand__c ORDER BY EDM_Brand__c];
		System.assertEquals('Brand2', brands[0].EDM_Brand__c);
		System.assertEquals('Brand3', brands[1].EDM_Brand__c);
	}

	@isTest
	public static void shouldRemediateMutuallyExclusiveBrandsRecords() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();
		New_Event_Curriculum_WS.Messages result = insertNewCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 'Brand1;Brand2','{"Brand1":["None"], "Brand2":["None"]}');
		System.assertEquals('', result.Message);

		//when        
		result = updateCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 'Brand3;Brand4', '{"Brand3":["None"], "Brand4":["None"]}');

		//then
		System.assertEquals('', result.Message);
		System.assertEquals(2, [SELECT Count() FROM EDM_Event_Curriculum_Brand__c]);
		List<EDM_Event_Curriculum_Brand__c> brands = [SELECT EDM_Brand__c FROM EDM_Event_Curriculum_Brand__c ORDER BY EDM_Brand__c];
		System.assertEquals('Brand3', brands[0].EDM_Brand__c);
		System.assertEquals('Brand4', brands[1].EDM_Brand__c);
	}

	@isTest
	public static void shouldDeleteBrandsRecords() {
		//given
		Speaker_Bureau_gne__c bureau = createBureau();
		New_Event_Curriculum_WS.Messages result = insertNewCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, 'Brand1;Brand2', '{"Brand1":["None"], "Brand2":["None"]}');
		System.assertEquals('', result.Message);
		System.assertEquals(2, [SELECT Count() FROM EDM_Event_Curriculum_Brand__c]);
		//when        
		result = updateCurriculumUsingWebService(bureau.Aprimo_Bureau_ID_gne__c, '', '');

		//then
		System.assertEquals('', result.Message);
		System.assertEquals(0, [SELECT Count() FROM EDM_Event_Curriculum_Brand__c]);
	}

	private static Speaker_Bureau_gne__c createBureau() {
		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(
												Name='Bureau',
												Speaker_Bureau_Type_gne__c = 'Business'
											);
		insert bureau;
		return [SELECT Id, Name, Speaker_Bureau_Type_gne__c, Aprimo_Bureau_ID_gne__c FROM Speaker_Bureau_gne__c WHERE Id = :bureau.Id];
	}

	private static Event_Curriculum_gne__c insertCurriculum(Id previousId, Integer versionNr) {
		String prcCode = 'AVC/050815/0026(' + versionNr + ')';
		Event_Curriculum_gne__c curriculum = new Event_Curriculum_gne__c(
				Name = prcCode,
				Curriculum_External_Id_gne__c = prcCode,
				Aprimo_ID_gne__c = prcCode,
				PRC_Number_gne__c = prcCode,
				Brands_gne__c = 'Avastin',
				Target_Audience_gne__c = 'Physician',
				Approval_Date_gne__c = Date.parse('10/12/2016'),
				Start_Date_gne__c = Date.parse('10/13/2016'),
				Disposition_gne__c = 'NEW',
				Description_gne__c = '<Title Needed>',
				Replacing_Curr_gne__c = previousId,
				Speaker_Retraining_Required_gne__c = 'No'
			);
		insert curriculum;
		return curriculum;
	}

	private static Account createSpeaker() {
		String recTypeId = [SELECT Id FROM RecordType WHERE Name = 'Health Care Professional (Prescriber)' AND SobjectType = 'Account' LIMIT 1].Id;

		Account speaker = new Account();
		speaker.FirstName = 'Speaker1';
		speaker.LastName  = 'Speaker1';
		speaker.RecordTypeId = recTypeId;
		insert speaker;
		return speaker;
	}

	private static Speaker_Training_gne__c createSpeakerTraining(Id speakerId, Id curriculumId, Boolean withMedicalEvent, Integer trainedDateOffset) {
		Speaker_Training_gne__c st = new Speaker_Training_gne__c();
		st.Speaker_gne__c = speakerId;
		st.Event_Curriculum_gne__c = curriculumId;
		st.Delivery_Method_gne__c = 'Non-Automatic';
		st.Trained_Date_gne__c = Date.today() + trainedDateOffset;

		if (withMedicalEvent) {
			Medical_Event_vod__c mem = new Medical_Event_vod__c(
												Start_Date_vod__c = System.now().date(),
												End_Date_vod__c = System.now().date() + 1
											);
			insert mem;
			st.Medical_Event_ID_gne__c = mem.Id;
		}

		insert st;
		return st;
	}

	private static New_Event_Curriculum_WS.Messages updateCurriculumUsingWebService(String bureauId, String brands, String brandsWithIndications) {
		New_Event_Curriculum_WS.New_Curriculum newC = new New_Event_Curriculum_WS.New_Curriculum();
		newC.Approval_date = Date.parse('10/17/2016');
		newC.Disposition = 'UPDATE';
		newC.name = 'CRC Live GENIE 2016';
		newC.brands = brands;
		newC.brandsWithIndications = brandsWithIndications;
		newC.Speaker_bureau_IDs = bureauId;
		newC.Speaker_Retraining_Required = 'No';
		newC.start_date = Date.parse('10/17/2016');
		newC.SpeakerBureauCurriculum = 'Y';
		newC.Target_Audience = 'Physician';
		newC.PRC_Code = newC.prc_number = 'AVC/050815/0026';  
		
		return New_Event_Curriculum_WS.create_new_curriculum(newC);
	}

	private static New_Event_Curriculum_WS.Messages insertNewCurriculumUsingWebService(String bureauId, String brands, String brandsWithIndications) {
		New_Event_Curriculum_WS.New_Curriculum newC = new New_Event_Curriculum_WS.New_Curriculum();
		newC.Approval_date = Date.parse('10/17/2016');
		newC.Disposition = 'NEW';
		newC.name = 'CRC Live GENIE 2016';
		newC.brands = brands;
		newC.brandsWithIndications = brandsWithIndications;
		newC.Speaker_bureau_IDs = bureauId;
		newC.Speaker_Retraining_Required = 'No';
		newC.start_date = Date.parse('10/17/2016');
		newC.SpeakerBureauCurriculum = 'Y';
		newC.Target_Audience = 'Physician';
		newC.PRC_Code = newC.prc_number = 'AVC/050815/0026';  
		
		return New_Event_Curriculum_WS.create_new_curriculum(newC);
	}

	private static New_Event_Curriculum_WS.Messages insertSuccessorCurriculumUsingWebService(String bureauId) {
		New_Event_Curriculum_WS.New_Curriculum newC = new New_Event_Curriculum_WS.New_Curriculum();
		newC.Approval_date = Date.parse('10/17/2016');
		newC.Disposition = 'UPDATE';
		newC.name = 'CRC Live GENIE 2016';
		newC.brands = 'Avastin';
		newC.brandsWithIndications = '{"Avastin":["None"]}';
		newC.Previous_Version_Regulatory_Code = 'AVC/050815/0026(1)';
		newC.Speaker_bureau_IDs = bureauId;
		newC.Speaker_Retraining_Required = 'No';
		newC.start_date = Date.parse('10/17/2016');
		newC.SpeakerBureauCurriculum = 'Y';
		newC.Target_Audience = 'Physician';
		newC.PRC_Code = newC.prc_number = 'AVC/050815/0026(2)';  
		
		return New_Event_Curriculum_WS.create_new_curriculum(newC);
	}

	private static New_Event_Curriculum_WS.Messages withdrawSuccessorCurriculumUsingWebService(String bureauId) {
		New_Event_Curriculum_WS.New_Curriculum newC = new New_Event_Curriculum_WS.New_Curriculum();
		newC.Approval_date = Date.parse('10/17/2016');
		newC.Disposition = 'WITHDRAW';
		newC.name = 'CRC Live GENIE 2016';
		newC.brands = 'Avastin';
		newC.brandsWithIndications = '{"Avastin":["None"]}';
		newC.Previous_Version_Regulatory_Code = 'AVC/050815/0026(1)';
		newC.Speaker_bureau_IDs = bureauId;
		newC.Speaker_Retraining_Required = 'No';
		newC.start_date = Date.parse('10/17/2016');
		newC.SpeakerBureauCurriculum = 'Y';
		newC.Target_Audience = 'Physician';
		newC.PRC_Code = newC.prc_number = 'AVC/050815/0026(2)';  
		
		return New_Event_Curriculum_WS.create_new_curriculum(newC);
	}

	private static New_Event_Curriculum_WS.Messages updateSuccessorCurriculumUsingWebService(String bureauId, Integer versionNr) {
		New_Event_Curriculum_WS.New_Curriculum newC = new New_Event_Curriculum_WS.New_Curriculum();
		newC.Approval_date = Date.parse('10/17/2016');
		newC.Disposition = 'UPDATE';
		newC.name = 'CRC Live GENIE 2016';
		newC.brands = 'Avastin';
		newC.brandsWithIndications = '{"Avastin":["None"]}';
		newC.Previous_Version_Regulatory_Code = 'AVC/050815/0026(' + (versionNr - 1) + ')';
		newC.Speaker_bureau_IDs = bureauId;
		newC.Speaker_Retraining_Required = 'No';
		newC.start_date = Date.parse('10/17/2016');
		newC.SpeakerBureauCurriculum = 'Y';
		newC.Target_Audience = 'Physician';
		newC.PRC_Code = newC.prc_number = 'AVC/050815/0026(' + versionNr + ')';  
		
		return New_Event_Curriculum_WS.create_new_curriculum(newC);
	}
}