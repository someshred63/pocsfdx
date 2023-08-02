@isTest
private class CFAR_ClinicalSupplyDemandReportTest {
    
    @testSetup 
    static void setup() {
        CFAR_Theme_gne__c theme = new CFAR_Theme_gne__c(
            Name = '99999',
            Theme_Name_gne__c = 'Accutane',
            Active_gne__c = true
        );
        insert theme;

        CFAR_Product_gne__c product1 = new CFAR_Product_gne__c(
            Theme_ref_gne__c = theme.Id,
            Name = 'Accutane',
            Generic_Name_gne__c = 'acc',
            Active_gne__c = true
        );
        insert product1;
        
        CFAR_Unit_Type_gne__c unitType = new CFAR_Unit_Type_gne__c();
        unitType.Name = 'Tablet';
        unitType.Active_gne__c = true;
        insert unitType;
        
        CFAR_Molecule_Configuration_gne__c molecConfig = new CFAR_Molecule_Configuration_gne__c(
            Product_gne__c = product1.Id,
            CFAR_Unit_Type_ref_gne__c = unitType.id,
            Configuration_gne__c = '100mg',
            Active_gne__c = true            
        );
        insert molecConfig;
        
        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c(
            Name = 'type 1',
            Active_gne__c = true
        );
        insert trialType;
        
        CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial( 0);
        t1.CTMS_gne__c = '09999';
        t1.Trial_Type_ref_gne__c = trialType.Id;
        t1.Other_Trial_gne_Id__c = '99983';
        t1.Genentech_Primary_Contact_ref_gne__c = CFAR_TestUtils.createTestPrimaryContact().Id;
        CFAR_Trial_gne__c t2 = CFAR_DataFactory.createTrial(1);
        t2.CTMS_gne__c = '09996';
        t2.Trial_Type_ref_gne__c = trialType.Id;
        t2.Other_Trial_gne_Id__c = '99985';
        t2.Genentech_Primary_Contact_ref_gne__c = CFAR_TestUtils.createTestPrimaryContact().Id;
        insert new List<CFAR_Trial_gne__c> {t1, t2};        
        
        CFAR_Cohort_gne__c coh1 = CFAR_DataFactory.createCohort(t1, 1, 50);
        CFAR_Cohort_gne__c coh2 = CFAR_DataFactory.createCohort(t2, 2, 50);
        insert new List<CFAR_Cohort_gne__c> {coh1, coh2};   
            
        CFAR_Cohort_Molecule_gne__c cm1 = CFAR_DataFactory.createCohortMolecule(coh1, 5, 1, molecConfig);
        CFAR_Cohort_Molecule_gne__c cm2 = CFAR_DataFactory.createCohortMolecule(coh2, 2, 1, molecConfig);
        insert new List<CFAR_Cohort_Molecule_gne__c> {cm1, cm2};  
            
        /*CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('contact one', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
        contact1.Last_Name_gne__c = 'lastName1';
        contact1.First_Name_gne__c = 'firstName1';
        contact1.Active_Date_gne__c = Date.Today();
        CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('contact two', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
        contact2.Last_Name_gne__c = 'lastName2';
        contact2.First_Name_gne__c = 'firstName2';
        contact2.Active_Date_gne__c = Date.Today();
        insert new List<CFAR_Contact_gne__c> {contact1, contact2};
*/
        CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact2('contact one', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER, 'Jan', 'Kowalski', Date.Today()); 
        CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact2('contact two', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR, 'Jan2', 'Kowalski2', Date.Today()); 
		insert new List<CFAR_Contact_gne__c> {contact1, contact2};
        
        CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
        insert parentOrg;
            
        CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'x-lab');
        insert institution;
        
        CFAR_Address_Type_gne__c addressType = new CFAR_Address_Type_gne__c();
        addressType.Name = 'addressType';
        addressType.Active_gne__c = true;
        insert addressType;
        
       /* CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress(institution);
        insert new List<CFAR_Contact_Address_gne__c> {contactAddress};
		*/
		CFAR_Contact_Address_gne__c contactAddress = CFAR_DataFactory.createContactAddress2(institution, addressType);
        insert new List<CFAR_Contact_Address_gne__c> {contactAddress};        

        CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress);
        insert new List<CFAR_Contact_Address_JO_gne__c> {caJO};
        
        CFAR_Team_Member_gne__c teamMember1 = CFAR_DataFactory.createTeamMemberWithActiveOn(t1, 'team memb one', caJO, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER, Date.Today());
        CFAR_Team_Member_gne__c teamMember2 = CFAR_DataFactory.createTeamMemberWithActiveOn(t1, 'team memb two', caJO, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR, Date.Today());
        insert new List<CFAR_Team_Member_gne__c> {teamMember1, teamMember2};
    }
    
    @isTest 
    static void controllerInitTest() {
        PageReference pageRef = Page.CFAR_ClinicalSupplyDemandReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_ClinicalSupplyDemandReport_Ctr controller = new CFAR_ClinicalSupplyDemandReport_Ctr();
        
        Test.startTest();
            System.assertEquals(false, controller.isButtonVisible);
            controller.initWholeTrialSelectOptions();
            controller.initWholeCSMSelectOptions();
            controller.initWholePISelectOptions();
            controller.getConfigurationsOptions();
            controller.initWholeCTMSSelectOptions();
            controller.getFilterNames();
            controller.initWholeProductSelectOptions();
            controller.initWholeProtocolSelectOptions();
            controller.getTrialStatusOptions();
            controller.getUnitTypeOptions();
            controller.getTrialTypeOptions();
            controller.selectedProducts = new List<String>();
            controller.selectedPiMembers = new List<String> {controller.wholePISelectOptions[0].getValue()};
            controller.selectedStatuses = new List<String> ();
            controller.selectedConfiguration = new List<String> ();
            controller.selectedProtocols = new List<String> ();
            controller.selectedTrialTypes = new List<String> ();
            controller.selectedCtms = new List<String> ();
            controller.selectedTrials = new List<String> ();
            controller.selectedUnitTypes = new List<String> ();
            controller.selectedCsms = new List<String> ();
        
        	controller.getCSMOptions1();
        	controller.getCSMOptions2();
        	controller.getCSMOptions3();
        	controller.getCSMOptions4();
            controller.getPIOptions1();
        	controller.getPIOptions2();
        	controller.getPIOptions3();
        	controller.getPIOptions4();
            controller.getTrialOptions1();
        	controller.getTrialOptions2();
        	controller.getTrialOptions3();
        	controller.getTrialOptions4();
            controller.getCTMSOptions1();
        	controller.getCTMSOptions2();
        	controller.getCTMSOptions3();
        	controller.getCTMSOptions4();
            controller.getProtocolOptions1();
        	controller.getProtocolOptions2();
        	controller.getProtocolOptions3();
        	controller.getProtocolOptions4();
            controller.getConfigurationOptions1();
        	controller.getConfigurationOptions2();
        	controller.getConfigurationOptions3();
        	controller.getConfigurationOptions4();
            controller.getProductsOptions1();
        	controller.getProductsOptions2();
        	controller.getProductsOptions3();
        	controller.getProductsOptions4();
        
            controller.generateReport();
            
        Test.stopTest();
        
        System.assertEquals(2, controller.wholeTrialSelectOptions.size());
        System.assertEquals(3, controller.wholeCSMSelectOptions.size());
        System.assertEquals(1, controller.wholePISelectOptions.size());
        System.assertEquals(1, controller.unitTypes.size());  
        System.assertEquals(2, controller.wholeCTMSSelectOptions.size());
        System.assertEquals(1, controller.trialTypes.size());
        System.assertEquals(2, controller.wholeProtocolSelectOptions.size());
        System.assertEquals(1, controller.wholeConfigurationSelectOptions.size());
        System.assertEquals(1, controller.wholeProductSelectOptions.size());
        System.assertEquals(2, CFAR_ClinicalSupplyDemandReport_Ctr.getSupplyDemandReportData('').molecules.size());
    }
    
    @isTest 
    static void testCancelGenerateReport(){
        PageReference pageRef = Page.CFAR_ClinicalSupplyDemandReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_ClinicalSupplyDemandReport_Ctr controller = new CFAR_ClinicalSupplyDemandReport_Ctr();
        Test.startTest();
            String refPage = controller.cancelGenerateReport().getUrl();
        Test.stopTest();
        
        System.assertEquals('/apex/CFAR_TrialReportNav', refPage);        
    }
    
    @isTest 
    static void testFilters(){
        PageReference pageRef = Page.CFAR_ClinicalSupplyDemandReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_ClinicalSupplyDemandReport_Ctr controller = new CFAR_ClinicalSupplyDemandReport_Ctr();
        Test.startTest();
            controller.initWholeProductSelectOptions();
            controller.initWholeTrialSelectOptions();
            controller.saveNewFilter();
            controller.filterName = 'testFilter';
            controller.selectedProducts = new List<String>{controller.wholeProductSelectOptions[0].getValue()};
            controller.selectedTrials = new List<String>{controller.wholeTrialSelectOptions[0].getValue()};
            controller.saveNewFilter();
            controller.selectedFilter = [SELECT RecordTypeId, Name From CFAR_Filter_gne__c WHERE Name = 'testFilter' LIMIT 1].Id;
            System.assertEquals(true, controller.isButtonVisible);
            controller.selectedStatuses = new List<String> ();
            controller.selectedConfiguration = new List<String> ();
            controller.selectedProtocols = new List<String> ();
            controller.selectedTrialTypes = new List<String> ();
            controller.selectedCtms = new List<String> ();
            controller.selectedUnitTypes = new List<String> ();
            controller.selectedPiMembers = new List<String> ();
            controller.selectedCsms = new List<String> ();
            controller.fechFilterOptions();
        Test.stopTest();
        
        CFAR_Filter_gne__c [] filters = [
            SELECT RecordTypeId, Name, 
                (SELECT Id,  Name, Field_Name_gne__c, Value_gne__c FROM CFAR_Filter_Options__r) 
            From CFAR_Filter_gne__c
        ];
        
        System.assertEquals(1, filters.size());
        CFAR_Product_gne__c product1 = [SELECT Id FROM CFAR_Product_gne__c LIMIT 1];
        for(CFAR_Filter_Option_gne__c fo : filters[0].CFAR_Filter_Options__r){
            if(fo.Field_Name_gne__c == 'selectedProducts'){
                //System.assertEquals(product1.Id, controller.products[0].getValue());
            }
        }    
    }
    
    @isTest 
    static void testSaveFilter(){
        PageReference pageRef = Page.CFAR_ClinicalSupplyDemandReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_ClinicalSupplyDemandReport_Ctr controller = new CFAR_ClinicalSupplyDemandReport_Ctr();
        Test.startTest();
            controller.initWholeProductSelectOptions();
            controller.initWholeTrialSelectOptions();
            controller.saveNewFilter();
            controller.filterName = 'testFilter';
            controller.selectedProducts = new List<String>{controller.wholeProductSelectOptions[0].getValue()};
            controller.selectedTrials = new List<String>{controller.wholeTrialSelectOptions[0].getValue()};
            controller.saveNewFilter();
            controller.initWholeProtocolSelectOptions();
            controller.selectedProtocols = new List<String>{controller.wholeProtocolSelectOptions[0].getValue()};
            controller.selectedFilter = [SELECT RecordTypeId, Name From CFAR_Filter_gne__c WHERE Name = 'testFilter' LIMIT 1].Id;
            controller.saveFilter();
        Test.stopTest();
        
        CFAR_Filter_gne__c [] filters = [
            SELECT RecordTypeId, Name, 
                (SELECT Id,  Name, Field_Name_gne__c, Value_gne__c FROM CFAR_Filter_Options__r) 
            From CFAR_Filter_gne__c
        ];
        
    }
    
    @isTest
    static void testCancelNewFilter(){
        PageReference pageRef = Page.CFAR_ClinicalSupplyDemandReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_ClinicalSupplyDemandReport_Ctr controller = new CFAR_ClinicalSupplyDemandReport_Ctr();
        Test.startTest();
            controller.saveNewFilter();
            System.assertEquals(true, controller.isPanelVisible);
            controller.cancelNewFilter();
        Test.stopTest();
        
        System.assertEquals(false, controller.isPanelVisible);
    }
    
    @isTest
    static void testDeleteFilter(){
        PageReference pageRef = Page.CFAR_ClinicalSupplyDemandReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_ClinicalSupplyDemandReport_Ctr controller = new CFAR_ClinicalSupplyDemandReport_Ctr();
        Test.startTest();
            controller.initWholeProductSelectOptions();
            controller.initWholeTrialSelectOptions();
            controller.saveNewFilter();
            controller.filterName = 'testFilter';
            controller.selectedProducts = new List<String>{controller.wholeProductSelectOptions[0].getValue()};
            controller.selectedTrials = new List<String>{controller.wholeTrialSelectOptions[0].getValue()};
            controller.saveNewFilter();
            CFAR_Filter_gne__c [] filters = [SELECT Id, RecordTypeId, Name From CFAR_Filter_gne__c WHERE Name = 'testFilter'];
            System.assertEquals(1, filters.size());
            controller.selectedFilter = filters[0].Id;
            controller.deleteFilter();
            
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id, RecordTypeId, Name From CFAR_Filter_gne__c WHERE Name = 'testFilter'].size());        
    }
}