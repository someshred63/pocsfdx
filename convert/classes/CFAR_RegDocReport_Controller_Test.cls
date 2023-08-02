@isTest(SeeAllData=false)
private class CFAR_RegDocReport_Controller_Test {
	static testMethod void testRegDocReport() {
		CFAR_WBS_gne__c wbs = CFAR_DataFactory.createWbs('testAVAwbs');
    	wbs.GSR_WBS_gne__c = '123456';
    	insert wbs;
		CFAR_Product_gne__c product1 = new CFAR_Product_gne__c(Name = 'Avastin', Generic_Name_gne__c = 'generic');
		insert product1;
    	CFAR_Therapeutic_Area_gne__c area = new CFAR_Therapeutic_Area_gne__c(Name = 'BioOncology');
    	insert area;
		List<CFAR_General_Indication_gne__c> generalIndications = new List<CFAR_General_Indication_gne__c> ();
		CFAR_General_Indication_gne__c indication = new CFAR_General_Indication_gne__c(Name = 'testGeneralInd1');
		CFAR_General_Indication_gne__c indication2 = new CFAR_General_Indication_gne__c(Name = 'testGeneralInd2');
		generalIndications.add(indication);
		generalIndications.add(indication2);
		insert generalIndications;
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
    	trial.Title_gne__c = 'testtitle';
    	trial.Regimen_gne__c = 'testRegimen';
    	trial.Brief_Title_gne__c = 'testBriefTitle';
    	insert trial;
    	
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
    	
    	List<CFAR_General_Indication_for_Trial_gne__c> generalIndicationsForTrial = new List<CFAR_General_Indication_for_Trial_gne__c> ();
    	CFAR_General_Indication_for_Trial_gne__c indicationToTrial1 = new CFAR_General_Indication_for_Trial_gne__c(CFAR_General_Indication_ref_gne__c = indication.Id, CFAR_Trial_ref_gne__c = trial.Id);
    	CFAR_General_Indication_for_Trial_gne__c indicationToTrial2 = new CFAR_General_Indication_for_Trial_gne__c(CFAR_General_Indication_ref_gne__c = indication2.Id, CFAR_Trial_ref_gne__c = trial.Id);
		generalIndicationsForTrial.add(indicationToTrial1);
		generalIndicationsForTrial.add(indicationToTrial2);
    	insert generalIndicationsForTrial;
		
		CFAR_Tracking_Activity_gne__c trackingActivity = new CFAR_Tracking_Activity_gne__c(Name = 'Study Closure Received', Active_gne__c = true);
		insert trackingActivity;
		CFAR_Regulatory_Document_Tracking_gne__c regDocTracking = CFAR_TestUtils.createRegDoc(trial, 'Study Closure Received', Date.today().addDays(2), Date.today(), false);
		regDocTracking.Reg_Doc_Investigator_gne__c = tm1.Id;
		insert regDocTracking;
		
		CFAR_Budget_Contract_gne__c budgetContract = CFAR_DataFactory.createBudgetContract(tm1);
    	insert budgetContract;
		List<CFAR_Rate_Table_gne__c> rateTables = new List<CFAR_Rate_Table_gne__c> (); 
    	CFAR_Rate_Table_gne__c rateTable1 = new CFAR_Rate_Table_gne__c(Budget_Contract_ref_gne__c = budgetContract.Id, Payment_Type_gne__c = 'Subject', Status_gne__c = 'Active', Cost_gne__c = 200, Unit_gne__c = 10);
    	insert rateTable1;
    	CFAR_Budget_Contract_Type_gne__c contractType = CFAR_DataFactory.createBudgetContractType();
    	contractType.Name = 'Original Contract';
    	insert contractType;
    	CFAR_Budget_Contract_Tracking_gne__c bct = CFAR_DataFactory.createBudgetContractTracking(budgetContract, contractType, 10);
    	bct.Contract_Expiry_Date_gne__c = Date.today();
		bct.Contract_Requested_Date__c = Date.Today();
    	insert bct;
		
		ApexPages.currentPage().getParameters().put('indication', indication.Id);
		ApexPages.currentPage().getParameters().put('product', product1.Id);
		ApexPages.currentPage().getParameters().put('studyNo', '');
		ApexPages.currentPage().getParameters().put('studyStatus', trialStatus.Id);
		ApexPages.currentPage().getParameters().put('therapeuticArea', area.Id);
		ApexPages.currentPage().getParameters().put('trialType', trialType.Id);
		ApexPages.currentPage().getParameters().put('subjectType', 'Human');
		ApexPages.currentPage().getParameters().put('ctms', 'testAVACtms');
		ApexPages.currentPage().getParameters().put('wbs', '123456');
		
		CFAR_RegDocReport_Controller ctrl = new CFAR_RegDocReport_Controller();
		CFAR_RegDocReport_Controller.RegDocReportDataWrapper regDocWrapper = ctrl.getRegDocReportData();
		List<List<CFAR_RegDocReport_Controller.RegDocReportCommentWrapper>> commentWrapper = ctrl.getRegDocCommentsData();
		
		system.assertEquals(1, regDocWrapper.regDocActivitiesList.size());
		system.assertEquals('Study Closure Received', regDocWrapper.regDocActivitiesList[0]);
		system.assertEquals(1, regDocWrapper.regDocHeaderToActivityMap.size());
		system.assertEquals(1, regDocWrapper.regDocHeadersList.size());
		system.assertEquals(1, regDocWrapper.trials.size());
		system.assertEquals(1, regDocWrapper.trials[0].trials.size());
		system.assertEquals('testAVACtms', regDocWrapper.trials[0].trials[0].CTMS);
		system.assertEquals('Yes', regDocWrapper.trials[0].trials[0].mainSite);
		system.assertEquals('lName2, fName2', regDocWrapper.trials[0].trials[0].csa);
		system.assertEquals('lName1, fName1', regDocWrapper.trials[0].trials[0].invastigatorSponsorName);
		system.assertEquals('testAVACtms', regDocWrapper.trials[0].trials[0].protocolNumber);
		system.assertEquals('Hold', regDocWrapper.trials[0].trials[0].trialStatus);
		system.assertEquals(1, commentWrapper.size());
		system.assertEquals(1, commentWrapper[0].size());

        //test inactive csa
        tm4.Active_On_gne__c = System.Today();
        tm4.Inactive_On_gne__c = System.Today().addDays(-2);
        update tm4;
        regDocWrapper = ctrl.getRegDocReportData();
        system.assertEquals('', regDocWrapper.trials[0].trials[0].csa, 
            'Should filter just active CSA team members to populate in CSA column');
	}
}