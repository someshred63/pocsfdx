@isTest
private class CFAR_PaymentReport_ControllerTest {
    @testSetup 
    static void setup() {        
        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c(
            Name = 'type 1',
            Active_gne__c = true
        );
        insert trialType;
        
        CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial( 0);
        t1.CTMS_gne__c = '09999';
        t1.Trial_Type_ref_gne__c = trialType.Id;
        t1.Other_Trial_gne_Id__c = '99983';
        CFAR_Trial_gne__c t2 = CFAR_DataFactory.createTrial(1);
        t2.CTMS_gne__c = '09996';
        t2.Trial_Type_ref_gne__c = trialType.Id;
        t2.Other_Trial_gne_Id__c = '99985';
        insert new List<CFAR_Trial_gne__c> {t1, t2}; 
        
        CFAR_Contact_gne__c contact1 = CFAR_DataFactory.createContact('contact one', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
        contact1.Last_Name_gne__c = 'lastName1';
        CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('contact two', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
        contact2.Last_Name_gne__c = 'lastName2';
        insert new List<CFAR_Contact_gne__c> {contact1, contact2};
            
        CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
        insert parentOrg;
            
        CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'x-lab');
        insert institution;
        
        CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress(institution);
        insert new List<CFAR_Contact_Address_gne__c> {contactAddress};
            
        CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress);
        insert new List<CFAR_Contact_Address_JO_gne__c> {caJO};
        
        CFAR_Team_Member_gne__c teamMember1 = CFAR_DataFactory.createTeamMember(t1, 'team memb one', caJO, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
        CFAR_Team_Member_gne__c teamMember2 = CFAR_DataFactory.createTeamMember(t1, 'team memb two', caJO, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
        insert new List<CFAR_Team_Member_gne__c> {teamMember1, teamMember2};
            
        CFAR_Budget_Contract_gne__c bc1 = CFAR_DataFactory.createBudgetContract(teamMember1);
        CFAR_Budget_Contract_gne__c bc2 = CFAR_DataFactory.createBudgetContract(teamMember2);
        insert new List<CFAR_Budget_Contract_gne__c> {bc1, bc2};
            
        CFAR_Rate_Table_gne__c rt1 = CFAR_DataFactory.createRateTable(bc1);
        CFAR_Rate_Table_gne__c rt2 = CFAR_DataFactory.createRateTable(bc2);
        insert new List<CFAR_Rate_Table_gne__c> {rt1, rt2};
    }
    
    @isTest 
    static void controllerInitTest() {
        PageReference pageRef = Page.CFAR_PaymentReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_PaymentReport_Controller controller = new CFAR_PaymentReport_Controller();
        
        Test.startTest();
            List<SelectOption> ctmsOptions = controller.getCtmsOptions();
            controller.selectedTrialId = [
                SELECT Id 
                FROM CFAR_Trial_gne__c 
                WHERE CTMS_gne__c  = '09999'
            ].Id;
            List<SelectOption> investigatorsOptions = controller.getInvestigatorsOptions();
            controller.generateReport();
            
        Test.stopTest();
        
        System.assertEquals(3, controller.wholeTrialSearchList.size());
        System.assertEquals(2, ctmsOptions.size());
        System.assertEquals(2, investigatorsOptions.size());
        System.assertEquals('At least one PI/Sub-I must be selected.', controller.errorMessage);  
    }
    
    @isTest 
    static void testErrorfinalTrialIdIsNull() {
        PageReference pageRef = Page.CFAR_PaymentReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_PaymentReport_Controller controller = new CFAR_PaymentReport_Controller();
        CFAR_Team_Member_gne__c member = [SELECT ID FROM CFAR_Team_Member_gne__c WHERE Name = 'team memb one'];
        
        Test.startTest();
            List<SelectOption> ctmsOptions = controller.getCtmsOptions();
            List<SelectOption> ctmsOptions1 = controller.getCTMSSelectOptions1();
            List<SelectOption> ctmsOptions2 = controller.getCTMSSelectOptions2();
            List<SelectOption> ctmsOptions3 = controller.getCTMSSelectOptions3();
            List<SelectOption> ctmsOptions4 = controller.getCTMSSelectOptions4();
            List<SelectOption> trialOptions1 = controller.getTrialSelectOptions1();
            List<SelectOption> trialOptions2 = controller.getTrialSelectOptions2();
            List<SelectOption> trialOptions3 = controller.getTrialSelectOptions3();
            List<SelectOption> trialOptions4 = controller.getTrialSelectOptions4();
            List<SelectOption> investigatorsOptions = controller.getInvestigatorsOptions();
            controller.selectedPISubIs = new List<String> {member.Id};
            controller.generateReport();
            
        Test.stopTest();
        System.assertEquals('You must choose one Trial or CTMS Number.', controller.errorMessage);  
    }
    
    @isTest 
    static void testGenerateReport() {
        PageReference pageRef = Page.CFAR_PaymentReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_PaymentReport_Controller controller = new CFAR_PaymentReport_Controller();
        CFAR_Team_Member_gne__c member = [SELECT ID FROM CFAR_Team_Member_gne__c WHERE Name = 'team memb one'];
        
        Test.startTest();
            List<SelectOption> ctmsOptions = controller.getCtmsOptions();
            controller.selectedTrialId = [
                SELECT Id 
                FROM CFAR_Trial_gne__c 
                WHERE CTMS_gne__c  = '09999'
            ].Id;
            List<SelectOption> investigatorsOptions = controller.getInvestigatorsOptions();
            controller.selectedPISubIs = new List<String> {member.Id};
            String refPage = controller.generateReport().getUrl();
            
        Test.stopTest();
        System.assert(refPage.contains('/apex/CFAR_BudgetReport'));
    }
    
    @isTest 
    static void testCancelGenerateReport() {
        PageReference pageRef = Page.CFAR_PaymentReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_PaymentReport_Controller controller = new CFAR_PaymentReport_Controller();
        CFAR_Team_Member_gne__c member = [SELECT ID FROM CFAR_Team_Member_gne__c WHERE Name = 'team memb one'];
        
        Test.startTest();
            List<SelectOption> ctmsOptions = controller.getCtmsOptions();
            controller.selectedTrialId = [
                SELECT Id 
                FROM CFAR_Trial_gne__c 
                WHERE CTMS_gne__c  = '09999'
            ].Id;
            List<SelectOption> investigatorsOptions = controller.getInvestigatorsOptions();
            controller.selectedPISubIs = new List<String> {member.Id};
            String refPage = controller.cancelGenerateReport().getUrl();
            
        Test.stopTest();
        System.assert(refPage.contains('/apex/CFAR_TrialReportNav'));
    }
    
    @isTest 
    static void testClearFilters() {
        PageReference pageRef = Page.CFAR_PaymentReport;
        Test.setCurrentPage(pageRef);
      
        CFAR_PaymentReport_Controller controller = new CFAR_PaymentReport_Controller();
        CFAR_Team_Member_gne__c member = [SELECT ID FROM CFAR_Team_Member_gne__c WHERE Name = 'team memb one'];
        
        Test.startTest();
            List<SelectOption> ctmsOptions = controller.getCtmsOptions();
            controller.selectedTrialId = [
                SELECT Id 
                FROM CFAR_Trial_gne__c 
                WHERE CTMS_gne__c  = '09999'
            ].Id;
            List<SelectOption> investigatorsOptions = controller.getInvestigatorsOptions();
            controller.clearFilters();
            
        Test.stopTest();
        System.assertEquals(null, controller.selectedTrialId);
        System.assertEquals(null, controller.selectedCtmsTrialId);       
    }

}