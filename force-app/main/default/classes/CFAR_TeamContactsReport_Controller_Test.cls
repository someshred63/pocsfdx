@isTest
private class CFAR_TeamContactsReport_Controller_Test {
    
    @testSetup
    static void setup() {
    	CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
    	insert parentOrg;
    	CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testInstitution');
    	insert institution;
    	CFAR_Contact_gne__c contact = CFAR_DataFactory.createContact('testX', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
    	CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('testXY', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE);
		List<CFAR_Contact_gne__c> contacts = new List<CFAR_Contact_gne__c> ();
		contacts.add(contact);
		contacts.add(contact1);
		insert contacts;
    	CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress(institution);
    	insert contactAddress;
    	CFAR_Contact_Address_JO_gne__c contactJoinAddress = CFAR_DataFactory.createContactAddressJO(contact, contactAddress);
    	insert contactJoinAddress;
    	CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(3);
    	trial.Genentech_Primary_Contact_ref_gne__c = contact.Id;
    	insert trial;
    	CFAR_Team_Member_gne__c tm = CFAR_DataFactory.createTeamMember(trial, 'testTeamMember', contactJoinAddress, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE);
    	insert tm;
		CFAR_Product_gne__c product = new CFAR_Product_gne__c(Name = 'Accutane', Generic_Name_gne__c = 'generic');
    	insert product;
    	CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c(Active_gne__c = true, Name = 'testStatus');
    	insert trialStatus;
    	List<CFAR_Roles_To_Users_Mapping_gne__c> rolesToUsersMapp = CFAR_TestUtils.createRolesToUsersMapping();
    }
    
    @isTest 
    static void testInitReport() {
        PageReference pageRef = Page.CFAR_TeamContactsReport;
        Test.setCurrentPage(pageRef);
        CFAR_TeamContactsReport_Controller controller = new CFAR_TeamContactsReport_Controller();
		List<SelectOption> allTMNames = controller.initWholeTMNameSelectOptions();
		List<SelectOption> allProtocols = controller.initGStarsSelectOptions();
		List<SelectOption> allCTMS = controller.initCtmsSelectOptions();
		List<SelectOption> allProducts = controller.initWholeProductSelectOptions();
		List<SelectOption> allCSM = controller.initWholeCSMSelectOptions();
		List<SelectOption> allCSA = controller.initWholeCSASelectOptions();
		List<SelectOption> allOrganizations = controller.initWholeOrganizationSelectOptions();
		List<SelectOption> allInstitutions = controller.initWholeInstitutionSelectOptions();
		List<SelectOption> tmStatusOptions = controller.getTMStatusOptions();
		List<SelectOption> studyStatusOptions = controller.getStudyStatusOptions();
		List<SelectOption> internalExternalOptions = controller.getInternalExternalOptions();
		List<SelectOption> functionRoleOptions = controller.getFunctionRoleOptions();
		
		List<SelectOption> tmNameOptionsPack1 = controller.getTmNameSelectOptions1();
		List<SelectOption> tmNameOptionsPack2 = controller.getTmNameSelectOptions2();
		List<SelectOption> tmNameOptionsPack3 = controller.getTmNameSelectOptions3();
		List<SelectOption> tmNameOptionsPack4 = controller.getTmNameSelectOptions4();
		List<SelectOption> tmNameOptionsPack5 = controller.getTmNameSelectOptions5();
		
		List<SelectOption> csmOptionsPack1 = controller.getCSMOptions1();
		List<SelectOption> csmOptionsPack2 = controller.getCSMOptions2();
		List<SelectOption> csmOptionsPack3 = controller.getCSMOptions3();
		List<SelectOption> csmOptionsPack4 = controller.getCSMOptions4();

		List<SelectOption> csaOptionsPack1 = controller.getCSAOptions1();
		List<SelectOption> csaOptionsPack2 = controller.getCSAOptions2();
		List<SelectOption> csaOptionsPack3 = controller.getCSAOptions3();
		List<SelectOption> csaOptionsPack4 = controller.getCSAOptions4();
		
		List<SelectOption> organizationOptionsPack1 = controller.getOrganizationOptions1();
		List<SelectOption> organizationOptionsPack2 = controller.getOrganizationOptions2();
		List<SelectOption> organizationOptionsPack3 = controller.getOrganizationOptions3();
		List<SelectOption> organizationOptionsPack4 = controller.getOrganizationOptions4();

		List<SelectOption> institutionOptionsPack1 = controller.getInstitutionOptions1();
		List<SelectOption> institutionOptionsPack2 = controller.getInstitutionOptions2();
		List<SelectOption> institutionOptionsPack3 = controller.getInstitutionOptions3();
		List<SelectOption> institutionOptionsPack4 = controller.getInstitutionOptions4();
		
		List<SelectOption> protocolsOptionsPack1 = controller.getGStarsOptions1();
		List<SelectOption> protocolsOptionsPack2 = controller.getGStarsOptions2();
		List<SelectOption> protocolsOptionsPack3 = controller.getGStarsOptions3();
		List<SelectOption> protocolsOptionsPack4 = controller.getGStarsOptions4();
		
		List<SelectOption> productsOptionsPack1 = controller.getProductsOptions1();
		List<SelectOption> productsOptionsPack2 = controller.getProductsOptions2();
		List<SelectOption> productsOptionsPack3 = controller.getProductsOptions3();
		List<SelectOption> productsOptionsPack4 = controller.getProductsOptions4();
		
        system.assertEquals(1, allTMNames.size());
        system.assertEquals(1, allProtocols.size());
        system.assertEquals(1, allProducts.size());
        system.assertEquals(1, allCSM.size());
        system.assertEquals(1, allCSA.size());
        system.assertEquals(1, allOrganizations.size());
        system.assertEquals(1, allInstitutions.size());
        system.assertEquals(2, tmStatusOptions.size());
        system.assertEquals(1, studyStatusOptions.size());
        system.assertEquals(3, internalExternalOptions.size());
        system.assertEquals(20, functionRoleOptions.size());
        
        system.assertEquals(1, tmNameOptionsPack1.size());
        system.assertEquals(0, tmNameOptionsPack2.size());
        system.assertEquals(0, tmNameOptionsPack3.size());
        system.assertEquals(0, tmNameOptionsPack4.size());
        system.assertEquals(0, tmNameOptionsPack5.size());
        
        system.assertEquals(1, csmOptionsPack1.size());
        system.assertEquals(0, csmOptionsPack2.size());
        system.assertEquals(0, csmOptionsPack3.size());
        system.assertEquals(0, csmOptionsPack4.size());
        
        system.assertEquals(1, csaOptionsPack1.size());
        system.assertEquals(0, csaOptionsPack2.size());
        system.assertEquals(0, csaOptionsPack3.size());
        system.assertEquals(0, csaOptionsPack4.size());
        
        system.assertEquals(1, organizationOptionsPack1.size());
        system.assertEquals(0, organizationOptionsPack2.size());
        system.assertEquals(0, organizationOptionsPack3.size());
        system.assertEquals(0, organizationOptionsPack4.size());
        
        system.assertEquals(1, institutionOptionsPack1.size());
        system.assertEquals(0, institutionOptionsPack2.size());
        system.assertEquals(0, institutionOptionsPack3.size());
        system.assertEquals(0, institutionOptionsPack4.size());
        
        system.assertEquals(1, protocolsOptionsPack1.size());
        system.assertEquals(0, protocolsOptionsPack2.size());
        system.assertEquals(0, protocolsOptionsPack3.size());
        system.assertEquals(0, protocolsOptionsPack4.size());
        
        system.assertEquals(1, productsOptionsPack1.size());
        system.assertEquals(0, productsOptionsPack2.size());
        system.assertEquals(0, productsOptionsPack3.size());
        system.assertEquals(0, productsOptionsPack4.size());
    }
    
 @isTest 
    static void testGenerateReport() {
        PageReference pageRef = Page.CFAR_TeamContactsReport;
        Test.setCurrentPage(pageRef);
        CFAR_TeamContactsReport_Controller controller = new CFAR_TeamContactsReport_Controller();
        controller.selectedProducts = new List<String> {'product'};
        controller.selectedTMNames = new List<String> {'memberName'};
        controller.selectedCSMs = new List<String> {'csm'};
        controller.selectedCSAs = new List<String> {'csa'};
        controller.selectedParentOrganizations = new List<String> {'organization'};
        controller.selectedStudyStatus = new List<String> {'status'};
        controller.selectedInstitutions = new List<String> {'institution'};
        controller.selectedGStarsNo = new List<String> {'gstarsNo'};
        controller.selectedCtmsNo = new List<String> {'ctmsNo'};
        controller.selectedTMStatus =  'All';
        controller.selectedInternalExternal = 'Internal';  
        controller.selectedFunctionRoles = new List<String> {'functionrole'};
        
        PageReference result = controller.generateReport();
        
        system.assert(result.getUrl().startsWith('/apex/CFAR_TeamContactsReportXLS'));
        system.assertEquals('product', result.getParameters().get('products'));
        system.assertEquals('memberName', result.getParameters().get('tmNames'));
        system.assertEquals('csm', result.getParameters().get('csm'));
        system.assertEquals('csa', result.getParameters().get('csa'));
        system.assertEquals('organization', result.getParameters().get('parentOrganizations'));
        system.assertEquals('status', result.getParameters().get('studyStatus'));
        system.assertEquals('institution', result.getParameters().get('institutions'));
        system.assertEquals('gstarsNo', result.getParameters().get('gstarsNo'));
        system.assertEquals('All', result.getParameters().get('tmstatus'));
        system.assertEquals('Internal', result.getParameters().get('internalExternal'));
        system.assertEquals('functionrole', result.getParameters().get('functionRoles'));
    }
        
 	@isTest 
    static void testCancelGenerateReport() {
        PageReference pageRef = Page.CFAR_TeamContactsReport;
        Test.setCurrentPage(pageRef);
        CFAR_TeamContactsReport_Controller controller = new CFAR_TeamContactsReport_Controller();
        PageReference result = controller.cancelGenerateReport();
        system.assert(result.getUrl().startsWith('/apex/CFAR_TrialReportNav'));
    }

 	@isTest 
    static void testCancelCreatingFilter() {
        PageReference pageRef = Page.CFAR_TeamContactsReport;
        Test.setCurrentPage(pageRef);
        CFAR_TeamContactsReport_Controller controller = new CFAR_TeamContactsReport_Controller();
        PageReference result = controller.saveNewFilter();
        result = controller.cancelNewFilter();
        system.assertEquals(false, controller.isPanelVisible);
    }
    
 	@isTest 
    static void testSaveNewDeleteFilter() {
        PageReference pageRef = Page.CFAR_TeamContactsReport;
        Test.setCurrentPage(pageRef);
        CFAR_TeamContactsReport_Controller controller = new CFAR_TeamContactsReport_Controller();
        controller.filterName = 'testFilter';
        controller.selectedProducts = new List<String> {'product'};
        controller.selectedTMNames = new List<String> {'memberName'};
        controller.selectedCSMs = new List<String> {'csm'};
        controller.selectedCSAs = new List<String> {'csa'};
        controller.selectedParentOrganizations = new List<String> {'organization'};
        controller.selectedStudyStatus = new List<String> {'status'};
        controller.selectedInstitutions = new List<String> {'institution'};
        controller.selectedGStarsNo = new List<String> {'gstarsNo'};
        controller.selectedCtmsNo = new List<String> ();
        controller.selectedTMStatus =  'tmstatus';
        controller.selectedInternalExternal = 'Internal';  
        controller.selectedFunctionRoles = new List<String> {'functionrole'};
        
        // first to set isPanelVisible to true
        PageReference result = controller.saveNewFilter();
        result = controller.saveNewFilter();
        
        List<SelectOption> filterNames = controller.getFilterNames();
        system.assertEquals(2, filterNames.size());
        system.assertEquals('testFilter', filterNames[1].getLabel());
        
        controller.deleteFilter();
       	filterNames = controller.getFilterNames();
        system.assertEquals(1, filterNames.size());
        system.assertEquals(0, controller.selectedProducts.size());
        system.assertEquals(0, controller.selectedTMNames.size());
        system.assertEquals(0, controller.selectedCSMs.size());
        system.assertEquals(0, controller.selectedCSAs.size());
        system.assertEquals(0, controller.selectedParentOrganizations.size());
        system.assertEquals(0, controller.selectedStudyStatus.size());
        system.assertEquals(0, controller.selectedInstitutions.size());
        system.assertEquals(0, controller.selectedGStarsNo.size());
        system.assertEquals('All', controller.selectedTMStatus);
        system.assertEquals('All', controller.selectedInternalExternal);
        system.assertEquals(0, controller.selectedFunctionRoles.size());
    }
        
 	@isTest 
    static void testSaveFetchFilter() {
        PageReference pageRef = Page.CFAR_TeamContactsReport;
        Test.setCurrentPage(pageRef);
        CFAR_TeamContactsReport_Controller controller = new CFAR_TeamContactsReport_Controller();
        controller.filterName = 'testFilter';
        controller.selectedProducts = new List<String> {'product'};
        controller.selectedTMStatus =  'tmstatus';
        controller.selectedInternalExternal = 'Internal';  
        
        controller.selectedTMNames = new List<String> ();
        controller.selectedCSMs = new List<String> ();
        controller.selectedCSAs = new List<String> ();
        controller.selectedParentOrganizations = new List<String> ();
        controller.selectedStudyStatus = new List<String> ();
        controller.selectedInstitutions = new List<String> ();
        controller.selectedGStarsNo = new List<String> ();
        controller.selectedCtmsNo = new List<String> ();
        controller.selectedFunctionRoles = new List<String> ();
        
        // first to set isPanelVisible to true
        PageReference result = controller.saveNewFilter();
        result = controller.saveNewFilter();
        
        controller.selectedProducts.add('product2');
        result = controller.saveFilter();
        result = controller.fetchFilterOptions();
        
        List<CFAR_Filter_gne__c> filters = [SELECT Id FROM CFAR_Filter_gne__c ORDER BY CreatedDate desc LIMIT 1];
        
        List<CFAR_Filter_Option_gne__c> options = [
        	SELECT Id, Field_Name_gne__c, Value_gne__c 
			FROM CFAR_Filter_Option_gne__c 
			WHERE CFAR_Filter_ref_gne__c = :filters[0].Id
		];
        system.assertEquals(4, options.size());
        system.assertEquals('product', options[0].Value_gne__c);
        system.assertEquals('product2', options[1].Value_gne__c);
        system.assertEquals('tmstatus', options[2].Value_gne__c);
        system.assertEquals('Internal', options[3].Value_gne__c);
        
        List<SelectOption> filterNames = controller.getFilterNames();
        system.assertEquals(2, filterNames.size());
        system.assertEquals('testFilter', filterNames[1].getLabel());
    }
}