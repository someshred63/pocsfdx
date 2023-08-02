@isTest(SeeAllData=false)
private class CFAR_TrialReport_Controller_Test {
	static testMethod void testSaveGetEditDeleteFilter() {
		// save/get empty filter
		CFAR_TrialReport_Controller ctrl = new CFAR_TrialReport_Controller();
		CFAR_TrialReport_Controller.saveFilter(null, 'testFilter', 'testStudyNo', '', '', null, null, null, null, null, null, null, null, null, null, null, null, null);
		List<CFAR_TrialReport_Model.IdNameWrapper> resultFilterNames = CFAR_TrialReport_Controller.getFilterNames();
		system.assertEquals(1, resultFilterNames.size());
		system.assertEquals('testFilter', resultFilterNames[0].name);
		
		CFAR_Filter_gne__c filter = [SELECT Id, Name FROM CFAR_Filter_gne__c];
		
		// edit filter
		CFAR_TrialReport_Controller.saveFilter(filter.Id, 'testFilter123', 'testStudyNo1', 'testCTMS', 'testWBS',
			new List<String> {'product1'}, new List<String> {'therapeuticArea1'}, new List<String> {'indication1'},
			new List<String> {'trialType1'}, new List<String> {'studyStatus'}, new List<String> {'subjectType1'}, new List<String> {'No'},
			new List<String> {'specIndication1'}, new List<String> {'impact1'}, new List<String> {'SRT1'}, new List<String> {'teamMember1'},
			new List<String> {'GNE1'}, new List<String> {'inclusiveResearch1'}
		);
		CFAR_TrialReport_Model.SingleFilter resultSingleFilter = CFAR_TrialReport_Controller.getFilter(filter.Id);
		System.debug(resultSingleFilter);
		system.assertNotEquals(null, resultSingleFilter);
		system.assertEquals(1, resultSingleFilter.products.size());
		system.assertEquals(1, resultSingleFilter.indications.size());
		system.assertEquals(1, resultSingleFilter.trialTypes.size());
		system.assertEquals(1, resultSingleFilter.therapeuticAreas.size());
		system.assertEquals(1, resultSingleFilter.trialStatuses.size());
		system.assertEquals(1, resultSingleFilter.subjectTypes.size());
		system.assertEquals('testCTMS', resultSingleFilter.ctms);
		system.assertEquals('testWBS', resultSingleFilter.wbs);
		system.assertEquals(1, resultSingleFilter.pediatricStudies.size());
		
		//delete filter
		CFAR_TrialReport_Model.OperationStatus resultOperationStatusOfDelete = CFAR_TrialReport_Controller.deleteFilter(filter.Id);
		system.assertNotEquals(null, resultOperationStatusOfDelete);
		List<CFAR_Filter_gne__c> resultFilters = [SELECT Id FROM CFAR_Filter_gne__c];
		system.assertEquals(0, resultFilters.size());
	}

	static testMethod void testGetFilterData() {
		CFAR_Therapeutic_Area_gne__c tArea = new CFAR_Therapeutic_Area_gne__c(Name = 'testArea', Active_gne__c = true);
		insert tArea;
		CFAR_General_Indication_gne__c generalInd = new CFAR_General_Indication_gne__c(Name = 'testGeneralIndication', Active_gne__c = true);
		insert generalInd;
		CFAR_Product_gne__c product = new CFAR_Product_gne__c(Name = 'testProduct', Generic_Name_gne__c = 'generic');
		insert product;
		CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c(Name = 'testTrialStatus', Active_gne__c = true);
		insert trialStatus;
		CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c(Name = 'testTrialType', Active_gne__c = true);
		insert trialType;
		
		CFAR_TrialReport_Model.FilterData filterData = CFAR_TrialReport_Controller.getFilterData();
		system.assertEquals(1, filterData.therapeuticAreas.size());
		system.assertEquals(1, filterData.indications.size());
		system.assertEquals(1, filterData.products.size());
		system.assertEquals(1, filterData.trialStatuses.size());
		system.assertEquals(1, filterData.trialTypes.size());
		system.assertEquals(CFAR_Trial_gne__c.Subject_Type__c.getDescribe().getPicklistValues().size(), filterData.subjectTypes.size());
		system.assertEquals(CFAR_Trial_gne__c.Pediatric_Study_gne__c.getDescribe().getPicklistValues().size(), filterData.pediatricStudies.size());
	}
	
	static testMethod void testTableTabData() {
		CFAR_General_Indication_gne__c generalInd = new CFAR_General_Indication_gne__c(Name = 'testGeneralIndication', Active_gne__c = true);
		insert generalInd;
		CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c(Name = 'testTrialStatus', Active_gne__c = true);
		insert trialStatus;
	    CFAR_Roles_To_Users_Mapping_gne__c setting = new CFAR_Roles_To_Users_Mapping_gne__c();
	    setting.role_function_gne__c = 'Medical Science Liason';
	    setting.drop_down_value_gne__c  = 'testRole';
	    setting.Name = 'MSL';
	    setting.Permissions_gne__c='GNE-CFAR-ReadOnlyUser';
	    insert setting;
		CFAR_Contact_gne__c contact = CFAR_DataFactory.createContact2('testContact', 'testRole', 'firstName', 'lastName', Date.today());
		insert contact;
		
		CFAR_TrialReport_Model.TableTabData tableTabData = CFAR_TrialReport_Controller.getTableTabData();
		system.assertEquals(1, tableTabData.indications.size());
		system.assertEquals(1, tableTabData.statuses.size());
		system.assertEquals(1, tableTabData.msls.size());
	}
	
	static testMethod void testReportInitForEmptyData() {
		CFAR_TrialReportXLS_Controller ctrl = new CFAR_TrialReportXLS_Controller();
		system.assertEquals(0, ctrl.programSummaryXLS.statusData.size());
		system.assertEquals(0, ctrl.programSummaryXLS.statusTotalCount);
		system.assertEquals(0, ctrl.programSummaryXLS.indicationData.size());
		system.assertEquals(0, ctrl.programSummaryXLS.indicationTotalCount);
		system.assertEquals(0, ctrl.programSummaryXLS.trials.size());

		system.assertEquals(0, ctrl.infrepXLS.infreps.size());
		system.assertEquals(0, ctrl.budgetSummaryXLS.budgets.size());
		system.assertEquals(0, ctrl.accrualsXLS.accruals.size());
		system.assertEquals(0, ctrl.commentsXLS.comments.size());
		system.assertEquals(0, ctrl.publicationXLS.publications.size());
		//system.assertEquals(0, ctrl.paymentDataXLS.size());
	}
	
	static testMethod void testReportForProjectSummaryInfrepPublicationCommentsBudgetSummWithNoProjections() {
    	CFAR_WBS_gne__c wbs = CFAR_DataFactory.createWbs('testAVAwbs');
    	wbs.GSR_WBS_gne__c = '123456';
    	insert wbs;
		CFAR_Product_gne__c product1 = new CFAR_Product_gne__c(Name = 'Avastin', Generic_Name_gne__c = 'generic');
		CFAR_Product_gne__c product2 = new CFAR_Product_gne__c(Name = 'Actemra', Generic_Name_gne__c = 'generic2');
		List<CFAR_Product_gne__c> products = new List<CFAR_Product_gne__c> ();
		products.add(product1);
		products.add(product2);
		insert products;
    	CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c(Name = 'BioOncology');
    	insert area;
		CFAR_General_Indication_gne__c indication = new CFAR_General_Indication_gne__c();
		insert indication;
        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c(Name = 'type1', Active_gne__c = true);
        insert trialType;
		CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c(Name = 'Hold', Active_gne__c = true);
		insert trialStatus;
		
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert institution;
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	contact1.First_Name_gne__c = 'fName1';
    	contact1.Last_Name_gne__c = 'lName1';
    	CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('testXY', 'MSL = Medical Science Liaison');
    	contact2.First_Name_gne__c = 'fName2';
    	contact2.Last_Name_gne__c = 'lName2';
		List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
		contacts.add(contact1);
		contacts.add(contact2);
		insert contacts;
    	CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
    	insert contactAddress;
    	CFAR_Contact_Address_JO_gne__c cja1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress);
    	CFAR_Contact_Address_JO_gne__c cja2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress);
    	List<CFAR_Contact_Address_JO_gne__c> contactJoinAddress = new List<CFAR_Contact_Address_JO_gne__c> ();
    	contactJoinAddress.add(cja1);
    	contactJoinAddress.add(cja2);
    	insert contactJoinAddress;
    	
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	trial.CTMS_gne__c = 'testAVACtms';
    	trial.CFAR_WBS_ref_gne__c = wbs.Id;
    	trial.Product_ref_gne__c = product1.Id;
    	trial.Therapeutic_Area_ref_gne__c = area.Id;
    	trial.Trial_Type_ref_gne__c = trialType.Id;
    	trial.Trial_Status_ref_gne__c = trialStatus.Id;
    	trial.Subject_Type__c = 'Human';
    	trial.CFAR_General_Indication_ref_gne__c = indication.Id;
    	trial.Investigator_ref_gne__c = contact1.Id;
    	trial.Genentech_Primary_Contact_ref_gne__c =  contact1.Id;
    	trial.MSL_ref_gne__c = contact2.Id;
    	trial.Title_gne__c = 'testtitle';
    	trial.Regimen_gne__c = 'testRegimen';
    	trial.Brief_Title_gne__c = 'testBriefTitle';
    	insert trial;
    	CFAR_Trial_Other_GNE_Agent_gne__c trialOtherGNEAgent = CFAR_DataFactory.createTrialOtherAgent(trial, product2);
    	insert trialOtherGNEAgent;
    	CFAR_Comment_gne__c comment1 = CFAR_TestUtils.createComment(trial, contact1, Date.newInstance(2016,2,10), 'test comment text 123');
		CFAR_Comment_gne__c comment2 = CFAR_TestUtils.createComment(trial, contact1, Date.newInstance(2017,2,10), 'test comment text 1234');
    	CFAR_Team_Member_gne__c tm2 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember2', cja2, 'MSL = Medical Science Liaison');
    	CFAR_Team_Member_gne__c tm3 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember3', cja1, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	tm3.Is_Trial_Primary_Contact_gne__c = true;
    	CFAR_Team_Member_gne__c tm4 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember4', cja2, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE);
    	List<CFAR_Team_Member_gne__c> teamMembers = new List<CFAR_Team_Member_gne__c> ();
    	teamMembers.add(tm2);
    	teamMembers.add(tm3);
    	teamMembers.add(tm4);
    	CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger'});
    	insert teamMembers;
    	
    	CFAR_General_Indication_for_Trial_gne__c indicationToTrial = new CFAR_General_Indication_for_Trial_gne__c();
    	indicationToTrial.CFAR_General_Indication_ref_gne__c = indication.Id;
    	indicationToTrial.CFAR_Trial_ref_gne__c = trial.Id;
    	insert indicationToTrial;
    	
		ApexPages.currentPage().getParameters().put('indication', indication.Id);
		ApexPages.currentPage().getParameters().put('product', product1.Id);
		ApexPages.currentPage().getParameters().put('therapeuticArea', area.Id);
		ApexPages.currentPage().getParameters().put('studyNo', '');
		ApexPages.currentPage().getParameters().put('trialType', trialType.Id);
		ApexPages.currentPage().getParameters().put('studyStatus', trialStatus.Id);
		ApexPages.currentPage().getParameters().put('subjectType', 'Human');
		ApexPages.currentPage().getParameters().put('wbs', wbs.GSR_WBS_gne__c);
		ApexPages.currentPage().getParameters().put('ctms', 'testAVACtms');
		
		CFAR_Publication_gne__c publication = new CFAR_Publication_gne__c (
			CFAR_Trial_ref_gne__c = trial.Id, 
			Author_gne__c = 'testAuthor', 
			Date_Published_gne__c = Date.today(), 
			Date_Received_gne__c = Date.today(), 
			Reviewed_By_GNE_Prior_to_Submission_gne__c = false,
			Source_gne__c = 'testSource',
			Status_gne__c = 'Planned'
		);
		insert publication;
		
		CFAR_TrialReportXLS_Controller ctrl = new CFAR_TrialReportXLS_Controller();
		// program summary check
		system.assertEquals(1, ctrl.programSummaryXLS.indicationData.size());
		system.assertEquals(1, ctrl.programSummaryXLS.indicationTotalCount);
		system.assertEquals(8, ctrl.programSummaryXLS.statusData.size());
		system.assertEquals('Actively Accruing Studies', ctrl.programSummaryXLS.statusData[0].Name);
		system.assertEquals(0, ctrl.programSummaryXLS.statusData[0].size);
		system.assertEquals('Completed Enrollment', ctrl.programSummaryXLS.statusData[1].Name);
		system.assertEquals(0, ctrl.programSummaryXLS.statusData[1].size);
		system.assertEquals('Active Publication', ctrl.programSummaryXLS.statusData[2].Name);
		system.assertEquals(0, ctrl.programSummaryXLS.statusData[2].size);
		system.assertEquals('Proposal Approved Studies', ctrl.programSummaryXLS.statusData[3].Name);
		system.assertEquals(0, ctrl.programSummaryXLS.statusData[3].size);
		system.assertEquals('Protocol Approved Studies', ctrl.programSummaryXLS.statusData[4].Name);
		system.assertEquals(0, ctrl.programSummaryXLS.statusData[4].size);
		system.assertEquals('Closure Pending', ctrl.programSummaryXLS.statusData[5].Name);
		system.assertEquals(0, ctrl.programSummaryXLS.statusData[5].size);
		system.assertEquals('Hold', ctrl.programSummaryXLS.statusData[6].Name);
		system.assertEquals(1, ctrl.programSummaryXLS.statusData[6].size);
		system.assertEquals('Follow-up', ctrl.programSummaryXLS.statusData[7].Name);
		system.assertEquals(0, ctrl.programSummaryXLS.statusData[7].size);
		system.assertEquals(1, ctrl.programSummaryXLS.statusTotalCount);
		system.assertEquals(1, ctrl.programSummaryXLS.trials.size());
		system.assertEquals('testAVACtms', ctrl.programSummaryXLS.trials[0].ctmsMLNumber);
		system.assertEquals('testAVACtms', ctrl.programSummaryXLS.trials[0].protocolNumber);
		system.assertEquals('Hold', ctrl.programSummaryXLS.trials[0].trialStatus);
		// program summary xls check 
		system.assertEquals(1, ctrl.progSummDataXLS.size());
		system.assertEquals('testAVACtms', ctrl.progSummDataXLS[0].protocolNumber);
		system.assertEquals('testAVACtms', ctrl.progSummDataXLS[0].ctmsMLNumber);
		system.assertEquals(100, ctrl.progSummDataXLS[0].sampleSize);
		system.assertEquals('lName2, fName2', ctrl.progSummDataXLS[0].msl);
		system.assertEquals('lName1, fName1', ctrl.progSummDataXLS[0].investigatorSponsor);
		system.assertEquals('Hold', ctrl.progSummDataXLS[0].trialStatus);
		// infrep check
		system.assertEquals(1, ctrl.infrepXLS.infreps.size());
		system.assertEquals('testAVACtms', ctrl.infrepXLS.infreps[0].protocolNumber);
		system.assertEquals('testAVACtms', ctrl.infrepXLS.infreps[0].ctmsNumber);
		system.assertEquals('type1', ctrl.infrepXLS.infreps[0].trialType);
		system.assert(ctrl.infrepXLS.infreps[0].institutionName.contains('testInstitution'));
		system.assertEquals('Address City, NY 99999 USA', ctrl.infrepXLS.infreps[0].sponsorContactInformation);
		system.assertEquals('lName1, fName1', ctrl.infrepXLS.infreps[0].CSM);
		system.assertEquals('lName2, fName2', ctrl.infrepXLS.infreps[0].CSA);
		system.assertEquals('Yes', ctrl.infrepXLS.infreps[0].interventional);
		system.assertEquals('Avastin', ctrl.infrepXLS.infreps[0].productName);
		system.assertEquals(null, ctrl.infrepXLS.infreps[0].otherStudyName);
		system.assertEquals('lName1, fName1', ctrl.infrepXLS.infreps[0].investigatorSponsorName);
		system.assertEquals('lName2, fName2', ctrl.infrepXLS.infreps[0].msl);
		system.assertEquals('Hold', ctrl.infrepXLS.infreps[0].trialStatus);
		system.assertEquals(indication.Id, ctrl.infrepXLS.infreps[0].primaryIndication);
		system.assertEquals('testtitle', ctrl.infrepXLS.infreps[0].protocolTitle);
		system.assertEquals('generic2', ctrl.infrepXLS.infreps[0].gneAgents);
		system.assertEquals(null, ctrl.infrepXLS.infreps[0].otherAgents);
		system.assertEquals('testRegimen', ctrl.infrepXLS.infreps[0].regimen);
		system.assertEquals(null, ctrl.infrepXLS.infreps[0].dose);
		system.assertEquals('testBriefTitle', ctrl.infrepXLS.infreps[0].briefTitle);
		system.assertEquals('test comment text 1234', ctrl.infrepXLS.infreps[0].comments);
		// comments check
		system.assertEquals(2, ctrl.commentsXLS.comments.size());
		system.assertEquals('testAVACtms', ctrl.commentsXLS.comments[0].protocolNumber);
		system.assertEquals('testAVACtms', ctrl.commentsXLS.comments[0].ctmsNumber);
		system.assertEquals('Avastin', ctrl.commentsXLS.comments[0].product);
		system.assertEquals('type1', ctrl.commentsXLS.comments[0].trialType);
		system.assertEquals('Hold', ctrl.commentsXLS.comments[0].trialStatus);
		system.assertEquals('lName1, fName1', ctrl.commentsXLS.comments[0].investigator);
		system.assert(ctrl.commentsXLS.comments[0].institution.contains('testInstitution'));
		system.assertEquals('Address City, NY 99999 USA', ctrl.commentsXLS.comments[0].sponsorContactInformation);
		system.assertEquals('02/10/2016', ctrl.commentsXLS.comments[0].activityDate);
		system.assertEquals('lName1, fName1', ctrl.commentsXLS.comments[0].createdBy);
		system.assertEquals('test comment text 123', ctrl.commentsXLS.comments[0].commentText);
		// budget summary with empty projections check 
		system.assertEquals(1, ctrl.budgetSummaryXLS.budgets.size());
		system.assertEquals('testAVACtms', ctrl.budgetSummaryXLS.budgets[0].ctmsNumber);
		system.assertEquals('lName1, fName1', ctrl.budgetSummaryXLS.budgets[0].CSM);
		system.assertEquals(null, ctrl.budgetSummaryXLS.budgets[0].wbs);
		system.assertEquals('lName1, fName1', ctrl.budgetSummaryXLS.budgets[0].investigatorSponsorName);
		system.assertEquals('testAVACtms', ctrl.budgetSummaryXLS.budgets[0].studyNumber);
		system.assertEquals('123456', ctrl.budgetSummaryXLS.budgets[0].newWbs);
		system.assertEquals('type1', ctrl.budgetSummaryXLS.budgets[0].trialType);
		system.assertEquals(0, ctrl.budgetSummaryXLS.budgets[0].q1);
		system.assertEquals(0, ctrl.budgetSummaryXLS.budgets[0].q2);
		system.assertEquals(0, ctrl.budgetSummaryXLS.budgets[0].q3);
		system.assertEquals(0, ctrl.budgetSummaryXLS.budgets[0].q4);
		system.assertEquals(0, ctrl.budgetSummaryXLS.budgets[0].projectedSpend);
		system.assertEquals(0, ctrl.budgetSummaryXLS.budgets[0].projectedPatientAccrual);
		system.assertEquals(0, ctrl.budgetSummaryXLS.totalQ1);
		system.assertEquals(0, ctrl.budgetSummaryXLS.totalQ2);
		system.assertEquals(0, ctrl.budgetSummaryXLS.totalQ3);
		system.assertEquals(0, ctrl.budgetSummaryXLS.totalQ4);
		system.assertEquals(0, ctrl.budgetSummaryXLS.totalProjectedSpend);
		system.assertEquals(0, ctrl.budgetSummaryXLS.totalProjectedPatientAccrual);
		// publication check
		system.assertEquals(1, ctrl.publicationXLS.publications.size());
		system.assertEquals('lName2, fName2', ctrl.publicationXLS.publications[0].CSA);
		system.assertEquals('lName1, fName1', ctrl.publicationXLS.publications[0].CSM);
		system.assertEquals('testAuthor', ctrl.publicationXLS.publications[0].author);
		system.assertEquals('testAVACtms', ctrl.publicationXLS.publications[0].ctmsNumber);
		system.assertEquals('testAVACtms', ctrl.publicationXLS.publications[0].protocolNo);
		system.assertEquals('type1', ctrl.publicationXLS.publications[0].trialType);
		system.assertEquals('Planned', ctrl.publicationXLS.publications[0].status);
		system.assertEquals('testSource', ctrl.publicationXLS.publications[0].source);
		system.assertEquals('No', ctrl.publicationXLS.publications[0].reviewed);
	}
	

	static testMethod void testReportForAccrualsPayments() {
    	CFAR_WBS_gne__c wbs = CFAR_DataFactory.createWbs('testAVAwbs');
    	wbs.GSR_WBS_gne__c = '123456';
    	insert wbs;
		CFAR_Product_gne__c product1 = new CFAR_Product_gne__c(Name = 'Avastin', Generic_Name_gne__c = 'generic');
		CFAR_Product_gne__c product2 = new CFAR_Product_gne__c(Name = 'Actemra', Generic_Name_gne__c = 'generic2');
		List<CFAR_Product_gne__c> products = new List<CFAR_Product_gne__c> ();
		products.add(product1);
		products.add(product2);
		insert products;
    	CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c(Name = 'BioOncology');
    	insert area;
		CFAR_General_Indication_gne__c indication = new CFAR_General_Indication_gne__c();
		insert indication;
        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c(Name = 'type1', Active_gne__c = true);
        insert trialType;
		CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c(Name = 'Hold', Active_gne__c = true);
		insert trialStatus;
		
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert institution;
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	contact1.First_Name_gne__c = 'fName1';
    	contact1.Last_Name_gne__c = 'lName1';
    	CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('testXY', 'MSL = Medical Science Liaison');
    	contact2.First_Name_gne__c = 'fName2';
    	contact2.Last_Name_gne__c = 'lName2';
		List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
		contacts.add(contact1);
		contacts.add(contact2);
		insert contacts;
    	CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
    	insert contactAddress;
    	CFAR_Contact_Address_JO_gne__c cja1 = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress);
    	CFAR_Contact_Address_JO_gne__c cja2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress);
    	List<CFAR_Contact_Address_JO_gne__c> contactJoinAddress = new List<CFAR_Contact_Address_JO_gne__c> ();
    	contactJoinAddress.add(cja1);
    	contactJoinAddress.add(cja2);
    	insert contactJoinAddress;

    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	trial.CTMS_gne__c = 'testAVACtms';
    	trial.CFAR_WBS_ref_gne__c = wbs.Id;
    	trial.Product_ref_gne__c = product1.Id;
    	trial.Therapeutic_Area_ref_gne__c = area.Id;
    	trial.Trial_Type_ref_gne__c = trialType.Id;
    	trial.Trial_Status_ref_gne__c = trialStatus.Id;
    	trial.Subject_Type__c = 'Human';
    	trial.CFAR_General_Indication_ref_gne__c = indication.Id;
    	trial.Investigator_ref_gne__c = contact1.Id;
    	trial.MSL_ref_gne__c = contact2.Id;
    	trial.Title_gne__c = 'testtitle';
    	trial.Regimen_gne__c = 'testRegimen';
    	trial.Brief_Title_gne__c = 'testBriefTitle';
    	insert trial;
    	CFAR_Trial_Other_GNE_Agent_gne__c trialOtherGNEAgent = CFAR_DataFactory.createTrialOtherAgent(trial, product2);
    	insert trialOtherGNEAgent;
    	CFAR_Comment_gne__c comment1 = CFAR_TestUtils.createComment(trial, contact1, Date.newInstance(2016,2,10), 'test comment text 123');
    	
    	CFAR_Team_Member_gne__c tm1 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember1', cja1, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
    	CFAR_Team_Member_gne__c tm2 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember2', cja2, 'MSL = Medical Science Liaison');
    	CFAR_Team_Member_gne__c tm3 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember3', cja1, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	tm3.Is_Trial_Primary_Contact_gne__c = true;
    	CFAR_Team_Member_gne__c tm4 = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember4', cja2, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE);
    	List<CFAR_Team_Member_gne__c> teamMembers = new List<CFAR_Team_Member_gne__c> ();
    	teamMembers.add(tm1);
    	teamMembers.add(tm2);
    	teamMembers.add(tm3);
    	teamMembers.add(tm4);
    	insert teamMembers;
		trial.Genentech_Primary_Contact_ref_gne__c = contact1.Id;
		update trial;
    	
    	CFAR_General_Indication_for_Trial_gne__c indicationToTrial = new CFAR_General_Indication_for_Trial_gne__c();
    	indicationToTrial.CFAR_General_Indication_ref_gne__c = indication.Id;
    	indicationToTrial.CFAR_Trial_ref_gne__c = trial.Id;
    	insert indicationToTrial;
    	
    	CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(tm1);
    	insert budgetContract;
		List<CFAR_Rate_Table_gne__c> rateTables = new List<CFAR_Rate_Table_gne__c> (); 
    	CFAR_Rate_Table_gne__c rateTable1 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = budgetContract.Id, Payment_Type_gne__c = 'Subject', Status_gne__c = 'Active', Cost_gne__c = 200, Unit_gne__c = 10);
    	CFAR_Rate_Table_gne__c rateTable2 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = budgetContract.Id, Payment_Type_gne__c = 'Subject', Status_gne__c = 'Active', Cost_gne__c = 20, Unit_gne__c = 10);
    	CFAR_Rate_Table_gne__c rateTable3 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = budgetContract.Id, Payment_Type_gne__c = 'Invoiceable', Status_gne__c = 'Active', Cost_gne__c = 100, Unit_gne__c = 10);
    	CFAR_Rate_Table_gne__c rateTable4 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = budgetContract.Id, Payment_Type_gne__c = 'Invoiceable', Status_gne__c = 'Active', Cost_gne__c = 10, Unit_gne__c = 10);
    	rateTables.add(rateTable1);
    	rateTables.add(rateTable2);
    	rateTables.add(rateTable3);
    	rateTables.add(rateTable4);
    	insert rateTables;
    	CFAR_Budget_Contract_Type_gne__c contractType = CFAR_DataFactory.createBudgetContractType();
    	insert contractType;
    	CFAR_Budget_Contract_Tracking_gne__c bct = CFAR_DataFactory.createBudgetContractTracking(budgetContract, contractType, 10);
    	insert bct;

		Test.startTest();
    	CFAR_Payment_Schedule_Status_gne__c paymentStatus = CFAR_DataFactory.createPaymentScheduleStatus('testPaymentStatus');
    	insert paymentStatus;
    	List<CFAR_Budget_CPS_Payments_gne__c> payments = new List<CFAR_Budget_CPS_Payments_gne__c> ();
    	CFAR_Budget_CPS_Payments_gne__c payment1 = CFAR_DataFactory.createBudgePayments(rateTable1, budgetContract, paymentStatus);
    	payment1.Invoice_Amount_gne__c = 10;
    	payment1.Paid_On_gne__c = Date.today();
    	payment1.Invoice_Submitted_Date_gne__c = Date.today();
    	CFAR_Budget_CPS_Payments_gne__c payment2 = CFAR_DataFactory.createBudgePayments(rateTable1, budgetContract, paymentStatus);
    	payment2.Invoice_Amount_gne__c = 12;
    	payments.add(payment1);
    	payments.add(payment2);
    	insert payments;
    	
    	CFAR_Budget_CPS_Projection_gne__c projection = CFAR_DataFactory.createBudgetProjection(trial, 200, 300, 400, 500);
    	projection.Year_gne__c = String.valueOf(Date.today().year());
    	projection.Quarter_1_gne__c = 500;
    	projection.Quarter_2_gne__c = 501;
    	projection.Quarter_3_gne__c = 502;
    	projection.Quarter_4_gne__c = 503;
    	insert projection;
    	
    	CFAR_Milestone_Activity_gne__c milestone = CFAR_DataFactory.createMilestoneActivity(trial, 'testMilestoneName');
    	milestone.Actual_Date_gne__c = Date.today();
    	insert milestone;
    	CFAR_Projected_Subject_Accrual_gne_ref__c newAccrual = new CFAR_Projected_Subject_Accrual_gne_ref__c(CFAR_Trial_ref_gne__c = trial.id, CFAR_Year_gne__c = Date.today().year()); 
    	insert newAccrual;
    	
		ApexPages.currentPage().getParameters().put('indication', indication.Id);
		ApexPages.currentPage().getParameters().put('product', product1.Id);
		ApexPages.currentPage().getParameters().put('therapeuticArea', area.Id);
		ApexPages.currentPage().getParameters().put('studyNo', '');
		ApexPages.currentPage().getParameters().put('trialType', trialType.Id);
		ApexPages.currentPage().getParameters().put('studyStatus', trialStatus.Id);
		ApexPages.currentPage().getParameters().put('subjectType', 'Human');
		ApexPages.currentPage().getParameters().put('wbs', wbs.GSR_WBS_gne__c);
		ApexPages.currentPage().getParameters().put('ctms', 'testAVACtms');

		CFAR_TrialReportXLS_Controller ctrl = new CFAR_TrialReportXLS_Controller();
		system.assertEquals(1, ctrl.accrualsXLS.accruals.size());
		system.assertEquals('lName2, fName2', ctrl.accrualsXLS.accruals[0].CSA);
		system.assertEquals('lName1, fName1', ctrl.accrualsXLS.accruals[0].CSM);
		system.assertEquals('testAVACtms', ctrl.accrualsXLS.accruals[0].ctmsNumber);
		system.assertEquals('type1', ctrl.accrualsXLS.accruals[0].trialType);
		system.assertEquals('123456', ctrl.accrualsXLS.accruals[0].newWBS);
		system.assertEquals('lName1, fName1', ctrl.accrualsXLS.accruals[0].investigator);
		system.assertEquals('PI', ctrl.accrualsXLS.accruals[0].memberRole);
		system.assertEquals('testBriefTitle', ctrl.accrualsXLS.accruals[0].otherStudyName);
		system.assertEquals(indication.Id, ctrl.accrualsXLS.accruals[0].indication);
		system.assertEquals('Hold', ctrl.accrualsXLS.accruals[0].studyStatus);
		system.assertEquals('type1', ctrl.accrualsXLS.accruals[0].trialType);
		system.assertEquals(null, ctrl.accrualsXLS.accruals[0].activationDate);
		system.assertEquals(null, ctrl.accrualsXLS.accruals[0].monthsActive);
		system.assertEquals(100, ctrl.accrualsXLS.accruals[0].sampleSize);
		system.assertEquals(10, ctrl.accrualsXLS.accruals[0].totalStudyBudget);
		system.assertEquals(2006, ctrl.accrualsXLS.accruals[0].totalProjectedSpend);
		system.assertEquals(1100, ctrl.accrualsXLS.accruals[0].invoiceables);
		system.assertEquals(500, ctrl.accrualsXLS.accruals[0].q1ProjectedSpend);
		system.assertEquals(501, ctrl.accrualsXLS.accruals[0].q2ProjectedSpend);
		system.assertEquals(502, ctrl.accrualsXLS.accruals[0].q3ProjectedSpend);
		system.assertEquals(503, ctrl.accrualsXLS.accruals[0].q4ProjectedSpend);
	}
    static testMethod void testReportForBOM() {
        CFAR_Trial_Status_gne__c testTrialStatus = new CFAR_Trial_Status_gne__c();
        insert testTrialStatus;
        CFAR_Dollar_and_Drug_gne__c testgneSupport = new CFAR_Dollar_and_Drug_gne__c();
        insert testgneSupport;
        CFAR_Picklist_Value_gne__c testSRTTeam = new CFAR_Picklist_Value_gne__c(RecordTypeId = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('SRT Team').getRecordTypeId());
        CFAR_Picklist_Value_gne__c testImpact = new CFAR_Picklist_Value_gne__c(RecordTypeId = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('Impact').getRecordTypeId());
        insert new List<CFAR_Picklist_Value_gne__c> {testSRTTeam, testImpact};
        CFAR_Trial_gne__c testTrial = new CFAR_Trial_gne__c(
            Subject_Type__c = 'Animal',
            Trial_Status_ref_gne__c = testTrialStatus.Id,
            Pediatric_Study_gne__c = 'Yes',
            Dollar_and_Drug_ref_gne__c = testgneSupport.id,
            SRT_Team_ref_gne__c = testSRTTeam.Id,
            Lab_Support_gne__c = 'YES',
            Impacts_gne__c = testImpact.Id,
            Planned_Enrollment_gne__c = 322,
            Received_Date_gne__c = Date.today(),
            Inclusive_Research_gne__c = 'Yes',
			Biomarker_Description_gne__c = 'Test BOM Description',
			CTMS_gne__c = '1234',
			Sub_Patient_Population_gne__c = 'Other'
        );
        insert testTrial;

        CFAR_TrialReport_Model.BOMTabData bomData = CFAR_TrialReport_Controller.getBOMTabData('', '', '', new List<String>(), new List<String>(), new List<String>(), new List<String>(), new List<String>(), new List<String>{'Animal'}, new List<String>(), new List<String>(),
            new List<String>{testImpact.Id},
            new List<String>{testSRTTeam.Id},
            new List<String>(),
            new List<String>{testgneSupport.Id},
            new List<String>{'Yes'}
        );
		CFAR_TrialReport_Model.PaymentsTabData paymentData = CFAR_TrialReport_Controller.getPaymentTabData('', '', '', new List<String>(), new List<String>(), new List<String>(), new List<String>(), new List<String>(), new List<String>{'Animal'}, new List<String>(), new List<String>(),
				new List<String>{testImpact.Id},
				new List<String>{testSRTTeam.Id},
				new List<String>(),
				new List<String>{testgneSupport.Id},
				new List<String>{'Yes'}
		);
		System.assert(bomData.boms.size() > 0);
		CFAR_TrialReport_Model.BOMData singleBomData = bomData.boms.get(0);
		System.assertEquals(singleBomData.BOMDescription, 'Test BOM Description');
		System.assertEquals(singleBomData.ctmsNumber, '1234');
		System.assertEquals(singleBomData.patSubPop, 'Other');
    }
}