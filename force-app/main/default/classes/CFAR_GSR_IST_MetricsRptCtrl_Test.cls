@isTest(SeeAllData = false)
private class CFAR_GSR_IST_MetricsRptCtrl_Test {
	
	@isTest static void testReportGeneration() 
	{
		User testAvgUser = CFAR_TestUtils.createTestAverageUser();
		system.runAs(testAvgUser)
		{
			List<sObject> testRecords = new List<sObject>();
			Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
			Map<String,object> fieldsConfig = new Map<String, object>();
			//create products
			fieldsConfig.put('Name', 'Actemra');
			fieldsConfig.put('Description_gne__c', 'ABCD');
			fieldsConfig.put('Generic_Name_gne__c', 'GenName');
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProductActemra = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProductActemra);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Avastin');
			fieldsConfig.put('Description_gne__c', 'ABCD');
			fieldsConfig.put('Generic_Name_gne__c', 'GenName');
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProductAvastin = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProductAvastin);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Valcyte');
			fieldsConfig.put('Description_gne__c', 'ABCD');
			fieldsConfig.put('Generic_Name_gne__c', 'GenName');
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProductValcyte = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProductValcyte);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Nutropin');
			fieldsConfig.put('Description_gne__c', 'ABCD');
			fieldsConfig.put('Generic_Name_gne__c', 'GenName');
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProductNutropin = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarProductNutropin);
			insert testRecords;
			//create Therapeutic Areas
			testRecords = new List<sObject>();
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Immunology');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Therapeutic_Area_gne__c(), fieldsConfig);
			sObject cfarTaImmunology = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTaImmunology);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'BioOnc');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Therapeutic_Area_gne__c(), fieldsConfig);
			sObject cfarTaBioOnc = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTaBioOnc);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Infectious');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Therapeutic_Area_gne__c(), fieldsConfig);
			sObject cfarTaInfectious = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTaInfectious);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'CV-Met');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Therapeutic_Area_gne__c(), fieldsConfig);
			sObject cfarTaCVMET = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTaCVMET);
			insert testRecords;
			//create Contacts
			testRecords = new List<sObject>();
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('First_Name_gne__c', 'Program');
			fieldsConfig.put('Last_Name_gne__c', 'Manager');
			fieldsConfig.put('Primary_Role_Function_gne__c', 'CPL = Clinical Program Leader');
			fieldsConfig.put('User_ref_gne__c', testAvgUser.Id);
			fieldsConfig.put('Active_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Contact_gne__c(), fieldsConfig);
			sObject cfarPrimaryInvestigator = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarPrimaryInvestigator);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('First_Name_gne__c', 'Primary');
			fieldsConfig.put('Last_Name_gne__c', 'Investigator');
			fieldsConfig.put('Primary_Role_Function_gne__c', 'PI = Primary (or Principal) Investigator');
			fieldsConfig.put('Active_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Contact_gne__c(), fieldsConfig);
			sObject cfarInvestigator = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarInvestigator);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('First_Name_gne__c', 'Medical');
			fieldsConfig.put('Last_Name_gne__c', 'Liaison');
			fieldsConfig.put('Primary_Role_Function_gne__c', 'MSL = Medical Science Liaison');
			fieldsConfig.put('Active_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Contact_gne__c(), fieldsConfig);
			sObject cfarMSL = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarMSL);
			insert testRecords;
			//create Trials
			testRecords = new List<sObject>();
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Product_ref_gne__c', cfarProductActemra.get('Id'));
			fieldsConfig.put('Therapeutic_Area_ref_gne__c', cfarTaImmunology.get('Id'));
			fieldsConfig.put('Study_Phase_gne__c', 'Phase I');
			fieldsConfig.put('Subject_Type__c', 'Animal');
			fieldsConfig.put('Planned_Enrollment_gne__c', 1);
			fieldsConfig.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-11111');
			fieldsConfig.put('Genentech_Primary_Contact_ref_gne__c', cfarPrimaryInvestigator.get('Id'));
			fieldsConfig.put('Investigator_ref_gne__c', cfarInvestigator.get('Id'));
			fieldsConfig.put('MSL_ref_gne__c', cfarMSL.get('Id'));
			fieldsConfig.put('Received_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Trial_gne__c(), fieldsConfig);
			sObject cfarTrial1 = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTrial1);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Product_ref_gne__c', cfarProductAvastin.get('Id'));
			fieldsConfig.put('Therapeutic_Area_ref_gne__c', cfarTaBioOnc.get('Id'));
			fieldsConfig.put('Study_Phase_gne__c', 'Phase I');
			fieldsConfig.put('Subject_Type__c', 'Animal');
			fieldsConfig.put('Planned_Enrollment_gne__c', 1);
			fieldsConfig.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-11112');
			fieldsConfig.put('Genentech_Primary_Contact_ref_gne__c', cfarPrimaryInvestigator.get('Id'));
			fieldsConfig.put('Investigator_ref_gne__c', cfarInvestigator.get('Id'));
			fieldsConfig.put('MSL_ref_gne__c', cfarMSL.get('Id'));
			fieldsConfig.put('Received_Date_gne__c', System.today());
			fieldsConfig.put('Received_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Trial_gne__c(), fieldsConfig);
			sObject cfarTrial2 = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTrial2);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Product_ref_gne__c', cfarProductValcyte.get('Id'));
			fieldsConfig.put('Therapeutic_Area_ref_gne__c', cfarTaInfectious.get('Id'));
			fieldsConfig.put('Study_Phase_gne__c', 'Phase I');
			fieldsConfig.put('Subject_Type__c', 'Animal');
			fieldsConfig.put('Planned_Enrollment_gne__c', 1);
			fieldsConfig.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-11113');
			fieldsConfig.put('Genentech_Primary_Contact_ref_gne__c', cfarPrimaryInvestigator.get('Id'));
			fieldsConfig.put('Investigator_ref_gne__c', cfarInvestigator.get('Id'));
			fieldsConfig.put('MSL_ref_gne__c', cfarMSL.get('Id'));
			fieldsConfig.put('Received_Date_gne__c', System.today());
			fieldsConfig.put('Received_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Trial_gne__c(), fieldsConfig);
			sObject cfarTrial3 = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTrial3);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Product_ref_gne__c', cfarProductNutropin.get('Id'));
			fieldsConfig.put('Therapeutic_Area_ref_gne__c', cfarTaCVMET.get('Id'));
			fieldsConfig.put('Study_Phase_gne__c', 'Phase I');
			fieldsConfig.put('Subject_Type__c', 'Animal');
			fieldsConfig.put('Planned_Enrollment_gne__c', 1);
			fieldsConfig.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-11114');
			fieldsConfig.put('Genentech_Primary_Contact_ref_gne__c', cfarPrimaryInvestigator.get('Id'));
			fieldsConfig.put('Investigator_ref_gne__c', cfarInvestigator.get('Id'));
			fieldsConfig.put('MSL_ref_gne__c', cfarMSL.get('Id'));
			fieldsConfig.put('Received_Date_gne__c', System.today());
			fieldsConfig.put('Received_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Trial_gne__c(), fieldsConfig);
			sObject cfarTrial4 = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTrial4);
			insert testRecords;
			//create Milestone Activities
			testRecords = new List<sObject>();
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Actual_Date_gne__c', Date.today());
			fieldsConfig.put('CFAR_Trial_ref_gne__c', cfarTrial1.get('Id'));
			fieldsConfig.put('Name', 'Proposal Approval');
			objectConfig.put(new CFAR_Milestone_Activity_gne__c(), fieldsConfig);
			sObject cfarMaProposalApproval = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarMaProposalApproval);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Actual_Date_gne__c', Date.today().addDays(-500));
			fieldsConfig.put('CFAR_Trial_ref_gne__c', cfarTrial2.get('Id'));
			fieldsConfig.put('Name', 'TRAC Protocol Approval');
			objectConfig.put(new CFAR_Milestone_Activity_gne__c(), fieldsConfig);
			sObject cfarMaProtocolApproval = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarMaProtocolApproval);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Actual_Date_gne__c', Date.today().addDays(-900));
			fieldsConfig.put('CFAR_Trial_ref_gne__c', cfarTrial3.get('Id'));
			fieldsConfig.put('Name', 'Activation');
			objectConfig.put(new CFAR_Milestone_Activity_gne__c(), fieldsConfig);
			sObject cfarMaActivation = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarMaActivation);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Actual_Date_gne__c', Date.today().addDays(-1300));
			fieldsConfig.put('CFAR_Trial_ref_gne__c', cfarTrial4.get('Id'));
			fieldsConfig.put('Name', 'Study Closure');
			objectConfig.put(new CFAR_Milestone_Activity_gne__c(), fieldsConfig);
			sObject cfarMaStudyClosure = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarMaStudyClosure);
			insert testRecords;
			CFAR_GSR_IST_MetricsReport_Controller mrCtrl = new CFAR_GSR_IST_MetricsReport_Controller();
			system.assertNotEquals(mrCtrl.getWorkbookProperties(), '');
			system.assertNotEquals(mrCtrl.reportRows.size(), 0);
			system.assertEquals(mrCtrl.reportRows.size(), 4);
			for(CFAR_GSR_IST_MetricsReport_Controller.GSR_ReportRow rr : mrCtrl.reportRows)
			{
				if(rr.maTA == 'Immunology')
				{
					system.assertEquals(rr.product, 'Actemra');
					system.assertEquals(rr.year, String.valueOf(Date.today().year()));
					system.assertEquals(rr.proposalsApprovedCount, 1);
					system.assertEquals(rr.protocolsApprovedCount, 0);
					system.assertEquals(rr.activtionsCount, 0);
					system.assertEquals(rr.clousuresCount, 0);
					system.assertEquals(rr.totalStudiesCount, 1);
				}
				if(rr.maTA == 'BioOnc')
				{
					system.assertEquals(rr.product, 'Avastin');
					system.assertEquals(rr.year, String.valueOf(Date.today().addDays(-500).year()));
					system.assertEquals(rr.proposalsApprovedCount, 0);
					system.assertEquals(rr.protocolsApprovedCount, 1);
					system.assertEquals(rr.activtionsCount, 0);
					system.assertEquals(rr.clousuresCount, 0);
					system.assertEquals(rr.totalStudiesCount, 1);
				}
				if(rr.maTA == 'Infectious')
				{
					system.assertEquals(rr.product, 'Valcyte');
					system.assertEquals(rr.year, String.valueOf(Date.today().addDays(-900).year()));
					system.assertEquals(rr.proposalsApprovedCount, 0);
					system.assertEquals(rr.protocolsApprovedCount, 0);
					system.assertEquals(rr.activtionsCount, 1);
					system.assertEquals(rr.clousuresCount, 0);
					system.assertEquals(rr.totalStudiesCount, 1);
				}
				if(rr.maTA == 'CV-Met')
				{
					system.assertEquals(rr.product, 'Nutropin');
					system.assertEquals(rr.year, String.valueOf(Date.today().addDays(-1300).year()));
					system.assertEquals(rr.proposalsApprovedCount, 0);
					system.assertEquals(rr.protocolsApprovedCount, 0);
					system.assertEquals(rr.activtionsCount, 0);
					system.assertEquals(rr.clousuresCount, 1);
					system.assertEquals(rr.totalStudiesCount, 1);
				}
			}
			system.assertEquals(mrCtrl.reportRows[0].sortFormula, 'Actemra'+String.valueOf(Date.today().year()));
		}
	}
}