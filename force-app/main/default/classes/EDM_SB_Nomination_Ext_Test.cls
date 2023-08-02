@isTest
private class EDM_SB_Nomination_Ext_Test{

	static testMethod void sbnSingleNominationTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);

		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		System.assert(!ext.multiple);
		System.assertEquals('TestBureau',ext.speakerBureauName);
		System.assertEquals('Business',ext.speakerBureauType);

	}

	static testMethod void sbnSpeakerBureauTypeErrorTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c();
		insert sb;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);

		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
        System.assertEquals(1,msgs.size(),msgs);
        System.assertEquals('Speaker_Bureau_Type_gne__c is null',msgs[0].getDetail());
	}

	static testMethod void sbnMultipleNominationNewRequestTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');

		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		System.assert(ext.multiple);
		System.assertEquals('TestBureau',ext.speakerBureauName);
		System.assertEquals('Business',ext.speakerBureauType);
		System.assertEquals('='+sb.Id+'&parentObjectName=Speaker_Bureau_gne__c&parentRecordType=',ext.returnSBMIds);
		System.assertEquals(0,ext.sbmIds.size());
	}

	static testMethod void sbnMultipleNominationAlreadySelectedAccountsTest(){

		Account acc = new Account(Name='TestAccount',AGS_EX_Exclusion_Status_base_gne__c = 'Not checked');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;
		
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = acc.Id, 
			Speaker_Bureau_Id_gne__c = sb.Id,
			Speaker_Status_gne__c = 'Pending'
		);
		insert sbm;

		EDM_Multiple_Nomination_Wrapper__c wrapper = new EDM_Multiple_Nomination_Wrapper__c(EDM_Multiple_Nomination_Ids__c = sbm.Id);
		insert wrapper;

		sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapper.Id);

		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		System.assert(ext.multiple);
		System.assertEquals('TestBureau',ext.speakerBureauName);
		System.assertEquals('Business',ext.speakerBureauType);
		System.assertEquals('='+sb.Id+'&parentObjectName=Speaker_Bureau_gne__c&parentRecordType=&wrapperId='+wrapper.Id,ext.returnSBMIds);
		System.assertEquals(1,ext.sbmIds.size());
		System.assertEquals('/apex/GNE_SFA2_SBMembership?br_id='+sb.Id+'&parentObjectName=Speaker_Bureau_gne__c&parentRecordType=&wrapperId='+wrapper.Id,ext.getRetUrl());
	}

	static testMethod void sbnMultipleNominationWrapperNotFoundTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;
		
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		ApexPages.currentPage().getParameters().put('wrapperId','WrongWrapperId');

		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		System.assert(ext.multiple);
		System.assertEquals(0,ext.sbmIds.size());
	}

	static testMethod void sbnGetContentNoActiveQuestionaresTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;
		
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.getContent();

		System.assert(ext.getErrorCondition());
		System.assertEquals('There are no active Questionnaires.',ext.getErrorMessage());
	}

	static testMethod void sbnGetContentTooMuchQuestionaresTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		
		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		Questionnaire_gne__c quest_2 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_2;
                
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.getContent();

		System.assert(ext.getErrorCondition());
		System.assertEquals('There are multiple active Questionnaires for this Bureau Category. Please contact your manager for support.',ext.getErrorMessage());
	}

	static testMethod void sbnGetContentSingleNominationTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		
		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		List<Question_gne__c> qList = new List<Question_gne__c>{
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'A,B,C',Values_gne__c = '1,2,3',Help_text_gne__c = 'Help'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'A,B,C',Values_gne__c = '1,2,3'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'A,B,C',Values_gne__c = '1,2,3')
		};
		insert qList;
                
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.getContent();

		List<EDM_SB_Nomination_Ext.Wrapper> il = ext.getinitial_list();
		System.assertEquals(3,il.size());
	}

	static testMethod void sbnGettersTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		ApexPages.currentPage().getParameters().put('retURL','sometestreturnurl');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);
		ext.getContent();

		System.assert(ext.geteditMode());
		System.assertEquals(acc.Id,ext.getAccountId());
		System.assertEquals(sb.Id,ext.getBureauId());
		System.assertEquals('Test',ext.getCurCat());
		System.assertEquals('sometestreturnurl',ext.getRetUrl());
	}

	static testMethod void sbnSurveyAnswersTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		
		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		List<Question_gne__c> qList = new List<Question_gne__c>{
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yse,No',Values_gne__c = '1,2',Help_text_gne__c = 'Help'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2')
		};
		insert qList;
                
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.getContent();

		List<EDM_SB_Nomination_Ext.Wrapper> il = ext.getinitial_list();
		for(EDM_SB_Nomination_Ext.Wrapper w : il){
			w.selectedOption_x = 'No';
		}
		ext.areAllAnswersYes();

		System.assertEquals(false,ext.allAnswersAreYes);

		ext.setSurveyAnswersToYes();
		ext.areAllAnswersYes();

		System.assertEquals(true,ext.allAnswersAreYes);
	}

	static testMethod void sbnClassificationRequestURLTest(){

		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		PageReference pr = Page.EDM_Classification_Request_Edit_Create;
        pr.getParameters().put('accountId', acc.Id);
        pr.getParameters().put('bureauId', sb.Id);
        pr.getParameters().put('nomination', 'true');
        pr.getParameters().put('typeOfClassification', 'Business');

        System.assertEquals(pr.getUrl(),ext.getURLForClassificationRequest());
	}

	static testMethod void sbnSaveRejectedTest(){

		Account acc = new Account(Name='TestAccount', EDM_Business_Classification_gne__c = 'National');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Speaker_Bureau_ID_gne__c = sb.Id);

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.allAnswersAreYes = false;
		ext.SBM = sbm;
		ext.saveSBMs();

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Rejected',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void sbnSavePendingTest(){

		Account acc = new Account(
			Name='TestAccount', 
			EDM_Business_Classification_gne__c = 'Local', 
			AGS_EX_Exclusion_Status_base_gne__c = 'Check pending'
		);
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		List<Question_gne__c> qList = new List<Question_gne__c>{
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yse,No',Values_gne__c = '1,2',Help_text_gne__c = 'Help'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2')
		};
		insert qList;
		
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Speaker_Bureau_ID_gne__c = sb.Id);

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.allAnswersAreYes = true;
		ext.getContent();
		ext.SBM = sbm;
		ext.saveSBMs();

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Pending',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void sbnSaveNominatedTest(){

		Account acc = new Account(
			Name='TestAccount', 
			EDM_Business_Classification_gne__c = 'Global', 
			AGS_EX_Exclusion_Status_base_gne__c = 'Verified and Clear'
		);
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		List<Question_gne__c> qList = new List<Question_gne__c>{
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yse,No',Values_gne__c = '1,2',Help_text_gne__c = 'Help'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2')
		};
		insert qList;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(Speaker_Bureau_ID_gne__c = sb.Id);

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('act_id',acc.Id);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.allAnswersAreYes = true;
		ext.getContent();
		ext.SBM = sbm;
		ext.saveSBMs();

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Nominated',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void sbnSaveMultipleTest(){

		Account acc = new Account(
			Name='TestAccount', 
			EDM_Business_Classification_gne__c = 'Global', 
			AGS_EX_Exclusion_Status_base_gne__c = 'Verified and Clear'
		);
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;
		Speaker_Bureau_gne__c sb2 = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test2'
		);
		insert sb2;
		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		List<Question_gne__c> qList = new List<Question_gne__c>{
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yse,No',Values_gne__c = '1,2',Help_text_gne__c = 'Help'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2')
		};
		insert qList;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = acc.Id, 
			Speaker_Bureau_Id_gne__c = sb2.Id,
			Speaker_Status_gne__c = 'Pending'
		);
		insert sbm;

		EDM_Multiple_Nomination_Wrapper__c wrapper = new EDM_Multiple_Nomination_Wrapper__c(EDM_Multiple_Nomination_Ids__c = sbm.Id);
		insert wrapper;

		sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapper.Id);
		
		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.allAnswersAreYes = true;
		ext.getContent();
		ext.SBM = sbm;
		ext.saveSBMs();

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c Where Speaker_Bureau_Id_gne__c = :sb.Id]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Nominated',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void sbnRequestMultipleExclusionsTest(){
		List<Account> accList = new List<Account>();
		Account a;
		a = new Account(Name = 'Account 1',AGS_EX_Exclusion_Status_base_gne__c = 'Not checked');
		accList.add(a);
		a = new Account(Name = 'Account 2',AGS_EX_Exclusion_Status_base_gne__c = 'Check pending');
		accList.add(a);
		a = new Account(Name = 'Account 3',AGS_EX_Exclusion_Status_base_gne__c = 'In Process');
		accList.add(a);
		a = new Account(Name = 'Account 4',AGS_EX_Exclusion_Status_base_gne__c = 'Verified and Clear');
		accList.add(a);
		insert accList;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account ac : accList){
			Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = ac.Id, 
				Speaker_Bureau_Id_gne__c = sb.Id,
				Speaker_Status_gne__c = 'Pending'
			);
			sbms.add(sbm);
		}
		insert sbms;	
		String  sbmsIds = '';
		Integer i = sbms.size();
		for(Speaker_Bureau_Membership_gne__c sbm : sbms){
			sbmsIds += sbm.Id;
			i--;
			if(i>0) sbmsIds += ';';
		}
		EDM_Multiple_Nomination_Wrapper__c wrapper = new EDM_Multiple_Nomination_Wrapper__c(EDM_Multiple_Nomination_Ids__c = sbmsIds);
		insert wrapper;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapper.Id);

		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.requestMultipleExclusions();

		System.assertEquals('Multiple Exclusion Requested',ext.popupType);
	}

	static testMethod void sbnRequestMultipleExclusionsExclusionDoneTest(){
		List<Account> accList = new List<Account>();
		Account a;
		a = new Account(Name = 'Account 4',AGS_EX_Exclusion_Status_base_gne__c = 'Verified and Clear');
		accList.add(a);
		insert accList;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account ac : accList){
			Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = ac.Id, 
				Speaker_Bureau_Id_gne__c = sb.Id,
				Speaker_Status_gne__c = 'Pending'
			);
			sbms.add(sbm);
		}
		insert sbms;	
		String  sbmsIds = '';
		Integer i = sbms.size();
		for(Speaker_Bureau_Membership_gne__c sbm : sbms){
			sbmsIds += sbm.Id;
			i--;
			if(i>0) sbmsIds += ';';
		}
		EDM_Multiple_Nomination_Wrapper__c wrapper = new EDM_Multiple_Nomination_Wrapper__c(EDM_Multiple_Nomination_Ids__c = sbmsIds);
		insert wrapper;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(sbm);
		ApexPages.currentPage().getParameters().put('spb_id',sb.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('retBureau',sb.Id);
		ApexPages.currentPage().getParameters().put('parentRecordType','');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapper.Id);

		EDM_SB_Nomination_Ext ext = new EDM_SB_Nomination_Ext(sc);

		ext.requestMultipleExclusions();

		System.assertEquals('Exclusion Done',ext.popupType);
	}

	static testMethod void sbnUpsertRejectedSBMTest(){
		Account a = new Account(Name = 'Account 4',AGS_EX_Exclusion_Status_base_gne__c = 'Verified and Clear');
		insert a;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		insert new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = a.ID,
			Speaker_Bureau_Id_gne__c = sb.Id,
			Speaker_Status_gne__c = 'Rejected'
		);

		EDM_SB_Nomination_Ext.saveNewSBM(a.Id, sb.Id, 'Pending');

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c Where Speaker_Bureau_Id_gne__c = :sb.Id]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Pending',sbms[0].Speaker_Status_gne__c);
	}

	static testMethod void sbnSaveNewSBMTest(){
		Account a = new Account(Name = 'Account 4',AGS_EX_Exclusion_Status_base_gne__c = 'Verified and Clear');
		insert a;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Category_gne__c = 'Test'
		);
		insert sb;

		Questionnaire_gne__c quest_1 = new Questionnaire_gne__c(
			Category_gne__c = 'Managed Care',
			ready_for_use_gne__c = true
		);
		insert quest_1;
		List<Question_gne__c> qList = new List<Question_gne__c>{
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yse,No',Values_gne__c = '1,2',Help_text_gne__c = 'Help'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2'),
			new Question_gne__c(Questionnaire_gne__c = quest_1.Id,Labels_gne__c = 'Yes,No',Values_gne__c = '1,2')
		};
		insert qList;

		EDM_SB_Nomination_Ext.saveNewSBM(a.Id, sb.Id, 'Pending');

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c Where Speaker_Bureau_Id_gne__c = :sb.Id]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Pending',sbms[0].Speaker_Status_gne__c);

		List<Survey_gne__c> surveys = new List<Survey_gne__c>(
			[Select id From Survey_gne__c]
		);
		System.assertEquals(1,surveys.size());

		List<Survey_Response_gne__c> surveyRspnses = new List<Survey_Response_gne__c>(
			[Select id From Survey_Response_gne__c]
		);
		System.assertEquals(3,surveyRspnses.size());
	}

	static testMethod void sbnUpdateExistingSBMTest(){
		Account a = new Account(Name = 'Account 4',AGS_EX_Exclusion_Status_base_gne__c = 'Verified and Clear');
		insert a;

		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert sb;

		insert new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = a.ID,
			Speaker_Bureau_Id_gne__c = sb.Id,
			Speaker_Status_gne__c = 'Rejected'
		);
		EDM_SB_Nomination_Ext.updateExisitngSBMStatus(a.Id, sb.Id, 'Nominated');

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>(
			[Select id,Speaker_Status_gne__c From Speaker_Bureau_Membership_gne__c Where Speaker_Bureau_Id_gne__c = :sb.Id]
		);
		System.assertEquals(1,sbms.size());
		System.assertEquals('Nominated',sbms[0].Speaker_Status_gne__c);
	}
}