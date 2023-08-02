/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-03-10
*  Description: This is a test class for GNE_SFA2_Account_Ext class
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_Account_Ext_Test {
	
	public static testMethod void testEdit(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.edit();
		system.assertEquals(acc.Id, pr.getParameters().get('id'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_Edit_Create_Layout'), 'Wrong URL');
		
		pr = controller.editClick();
		system.assertEquals(acc.Id, pr.getParameters().get('id'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_Edit_Create_Layout'), 'Wrong URL');
	}

	public static testMethod void testAddContact(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		String canadaRecType = [Select id From RecordType where DeveloperName='GNE_SFA_Canada' and SobjectType='Contact' LIMIT 1].id;
		String sfa2RecType = [Select id From RecordType where DeveloperName='AssociatedContactRecordType' and SobjectType='Contact' LIMIT 1].id;

		PageReference pr = controller.addContactClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(sfa2RecType, pr.getParameters().get('recordTypeId'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Contact_Edit_Create_Layout'), 'Wrong URL');

		pr = controller.addContactCanClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(canadaRecType, pr.getParameters().get('recordTypeId'));
		system.assert(pr.getUrl().contains('GNE_SFA2_Contact_Edit_Create_Layout'), 'Wrong URL');
	}
	
	public static testMethod void testRecordACall(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.recordACallClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().toUpperCase().contains('GNE_SFA2_INTERACTION'), 'Wrong URL');
	}

	public static testMethod void testDataChangeRequestClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.dataChangeRequestClick();
		system.assertEquals(acc.Id, pr.getParameters().get('id'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_AccountDCR'), 'Wrong URL');
	}

	public static testMethod void testViewTerritoriesClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		String truncatedId = acc.Id;
		truncatedId = truncatedId.substring(0,truncatedId.length()-3);
		PageReference pr = controller.viewTerritoriesClick();
		system.assertEquals('00O70000001mLQz', pr.getParameters().get('id'));
		system.assertEquals(truncatedId, pr.getParameters().get('pv0'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Report_layout'), 'Wrong URL');
	}

	public static testMethod void testAffiliationsClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.allAffiliationsInteractionClick();
		system.assertEquals(UserInfo.getUserId(), pr.getParameters().get('pv0'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Report_layout'), 'Wrong URL');

		pr = controller.addAffiliationClick();
		system.assertEquals(acc.Id, pr.getParameters().get('CF00N70000001tDNo_lkid'));
		system.assertEquals('1', pr.getParameters().get('save_new'));
		system.assertEquals('1', pr.getParameters().get('sfdc.override'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Affiliation_Edit_Create_Layout'), 'Wrong URL');
	}

	public static testMethod void testMedicalClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.medicalCommunicationsClick();
		system.assertEquals(acc.Id, pr.getParameters().get('acctId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Create_MedComm_Layout'), 'Wrong URL');

		pr = controller.medicalReferralsClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Referral'), 'Wrong URL');
	}

	public static testMethod void testAddAddressClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.addAddressClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		//system.assertEquals(acc.Id, pr.getParameters().get('CF00N70000001tDKx_lkid'));
		//system.assertEquals('1', pr.getParameters().get('sfdc.override'));
		//system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		//system.assert(pr.getUrl().contains('GNE_SFA2_Account_Address_Search'), 'Wrong URL');
		system.assert(pr.getUrl().contains('gne_sfa2_sbc'), 'Wrong URL');
	}

	public static testMethod void testLicenseIssueClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.licenseIssueClick();
		system.assertEquals(acc.Id, pr.getParameters().get('id'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_LicenseIssueDCR'), 'Wrong URL');
	}

	public static testMethod void testNewDoCLocationClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.newDoCLocationClick();
		system.assertEquals(acc.Id, pr.getParameters().get('DoCId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_DoC_Layout'), 'Wrong URL');
	}

	public static testMethod void testViewHierarchyClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.viewHierarchyClick();
		system.assertEquals(acc.Id, pr.getParameters().get('Id'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_Hierarchy_Layout'), 'Wrong URL');
	}

	public static testMethod void testViewAndAddAttachmentClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.addAttachmentsClick();
		system.assertEquals(acc.Id, pr.getParameters().get('Id'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_UploadAttachment'), 'Wrong URL');

		pr = controller.viewAttachmentsClick();
		system.assertEquals(acc.Id, pr.getParameters().get('Id'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Attachment_layout'), 'Wrong URL');
	}

	public static testMethod void testAccountCalendarClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.accountCalendarClick();
		system.assertEquals(acc.Id, pr.getParameters().get('id'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_MyCalendar'), 'Wrong URL');
	}

	public static testMethod void testUpdateClassificationClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.updateClassificationClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('EDM_Cl_Req_Review_Edit_Create'), 'Wrong URL');
	}

	public static testMethod void testClassificationLogClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.classificationLogClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('EDM_Classif_Requests_Log_List'), 'Wrong URL');
	}

	public static testMethod void testCallMethdod(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		system.assertEquals(null, controller.callMethod('wrongMethodName'));

		PageReference pr = controller.callMethod('newHospitalDepartmentClick');
		system.assertEquals(acc.Id, pr.getParameters().get('sfacanadaparentId'));
		system.assertEquals('HospitalDepartment_vod', pr.getParameters().get('recordTypeName'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_Edit_Create_Layout'), 'Wrong URL');

		pr = controller.callMethod('newHospitalDepartmentCanadaClick');
		system.assertEquals(acc.Id, pr.getParameters().get('sfacanadaparentId'));
		system.assertEquals('GNE_SFA_Roche_Canada_Hospital_Depatment', pr.getParameters().get('recordTypeName'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_Edit_Create_Layout'), 'Wrong URL');

		pr = controller.callMethod('newSurveyClick');
		system.assertEquals(acc.Id, pr.getParameters().get('objectId'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Create_Survey_Layout'), 'Wrong URL');

		pr = controller.callMethod('newDoCLocationClick');
		system.assertEquals(acc.Id, pr.getParameters().get('DoCId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_DoC_Layout'), 'Wrong URL');

		pr = controller.callMethod('medicalCommunicationsClick');
		system.assertEquals(acc.Id, pr.getParameters().get('acctId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Create_MedComm_Layout'), 'Wrong URL');

		pr = controller.callMethod('medicalReferralsClick');
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Referral'), 'Wrong URL');

		pr = controller.callMethod('addAffiliationClick');
		system.assertEquals(acc.Id, pr.getParameters().get('CF00N70000001tDNo_lkid'));
		system.assertEquals('1', pr.getParameters().get('save_new'));
		system.assertEquals('1', pr.getParameters().get('sfdc.override'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Affiliation_Edit_Create_Layout'), 'Wrong URL');

		pr = controller.callMethod('addAddressClick');
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		//system.assertEquals(acc.Id, pr.getParameters().get('CF00N70000001tDKx_lkid'));
		//system.assertEquals('1', pr.getParameters().get('sfdc.override'));
		//system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		//system.assert(pr.getUrl().contains('GNE_SFA2_Account_Address_Search'), 'Wrong URL');
		system.assert(pr.getUrl().contains('gne_sfa2_sbc'), 'Wrong URL');

		pr = controller.callMethod('addAccountTeam');
		system.assertEquals(acc.Id, pr.getParameters().get('objectId'));
		system.assertEquals('/'+acc.Id, pr.getParameters().get('retUrl'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Std_AccTeam_Create_Layout'), 'Wrong URL');

		insert new AccountTeamMember(AccountId = acc.Id, UserId = UserInfo.getUserId());
		system.assertEquals(1, [SELECT Id From AccountTeamMember where AccountId =: acc.Id].size());
		pr = controller.callMethod('deleteAllTeams');
		system.assertEquals(acc.Id, pr.getParameters().get('Id'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_Account_Layout'), 'Wrong URL');
		system.assertEquals(0, [SELECT Id From AccountTeamMember where AccountId =: acc.Id].size());
	}

	public static testMethod void testAddSocietyMembershipClick(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		PageReference pr = controller.addSocietyMembershipClick();
		system.assertEquals(acc.Id, pr.getParameters().get('accountId'));
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains('GNE_SFA2_AccSocMem_Edit_Create'), 'Wrong URL');
	}

	public static testMethod void testVisualforceIncludesMap(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);

		List<String> possibleValues = new List<String>{'GNE_SFA2_ViewRHPage', 'GNE_SFA2_Ratings_Layout',
													   'GNE_SFA2_Territory_Alignment_Layout', 
													   'GNE_SFA2_Activase_Questions_Layout', 
													   'GNE_SFA2_RepSpecific_Layout',
													   'GNE_SFA2_TherapeuticAreas_Layout', 
													   'GNE_SFA2_EventParticipation_Layout',
													   'GNE_SFA2_InfluenceMetrics_Layout',
													   'GNE_SFA2_TargetsAndTiers_Layout', 
													   'GNE_SFA2_Planned_Frequency_Layout', 
													   'GNE_SFA2_Record_History_Page', 													   
													   'GNE_SFA2_Revegy_Account_Layout',
													   'GNE_SFA2_PREP_Testing_Information',
													   'GNE_SFA2_PREP_Testing_Objectives'
													};
		system.assertEquals(possibleValues.size(), controller.visualforceIncludesMap.keySet().size());
		for(String keyString : possibleValues){
			system.assertNotEquals(null, controller.visualforceIncludesMap.get(keyString));
			system.assertEquals(false, controller.visualforceIncludesMap.get(keyString));
		}

		SFA2_Configuration_Object_gne__c master = GNE_SFA2_Triggers_Test_Util.prepareSFA2_Configuration_Object_gne();
        master.Object_Name_gne__c = 'Account';
        master.Record_Type_gne__c = '';
        master.Is_Active_gne__c = true;
        master.Configuration_Type_gne__c='Page'; 
        insert master;

        String testApiName = possibleValues[0];
        String wrongName = 'sampleNameThatDoesntExistInMapYet';
        insert new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = testApiName, Type_gne__c = 'VF Page',
        												   Configuration_Object_ref_gne__c = master.Id, Is_Active_gne__c = true
        												  );
        insert new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = wrongName, Type_gne__c = 'VF Page',
        												   Configuration_Object_ref_gne__c = master.Id, Is_Active_gne__c = true
        												  );

        controller.init();

        system.assertEquals(true, controller.visualforceIncludesMap.get(testApiName));
        system.assertNotEquals(null, controller.visualforceIncludesMap.get(wrongName));
        system.assertEquals(true, controller.visualforceIncludesMap.get(wrongName));
        system.assertEquals(possibleValues.size() + 1, controller.visualforceIncludesMap.keySet().size());
                    
	}
}