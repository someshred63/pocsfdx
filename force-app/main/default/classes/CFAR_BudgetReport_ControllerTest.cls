@isTest
private class CFAR_BudgetReport_ControllerTest {
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
        contact1.Phone_gne__c = '555 00 99 99';
        contact1.Fax_gne__c = '555 00 99 11';
        contact1.Email_gne__c = 'test@test.com.tv';
        CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('contact two', CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
        contact2.Last_Name_gne__c = 'lastName2';
        insert new List<CFAR_Contact_gne__c> {contact1, contact2};
            
        CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
        insert parentOrg;
            
        CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'x-lab');
        insert institution;
        
        CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress(institution);
        contactAddress.Address_gne__c = 'Sezam Street';
        contactAddress.City_gne__c = 'Chrzaszczyzewoszyce';
        contactAddress.Province_gne__c = 'Lekowody';
        contactAddress.State_gne__c = 'NY';
        insert new List<CFAR_Contact_Address_gne__c> {contactAddress};
            
        CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact1, contactAddress);
        caJO.Department_Division_gne__c = 'Dep X';
        insert new List<CFAR_Contact_Address_JO_gne__c> {caJO};
        
        CFAR_Team_Member_gne__c teamMember1 = CFAR_DataFactory.createTeamMember(t1, 'team memb one', caJO, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
        CFAR_Team_Member_gne__c teamMember2 = CFAR_DataFactory.createTeamMember(t1, 'team memb two', caJO, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
        insert new List<CFAR_Team_Member_gne__c> {teamMember1, teamMember2};
            
        CFAR_Budget_Contract_gne__c bc1 = CFAR_DataFactory.createBudgetContract(teamMember1);
        bc1.PO_Number_gne__c = 'PO10033';
        CFAR_Budget_Contract_gne__c bc2 = CFAR_DataFactory.createBudgetContract(teamMember2);
        insert new List<CFAR_Budget_Contract_gne__c> {bc1, bc2};
            
        CFAR_Rate_Table_gne__c rt1 = CFAR_DataFactory.createRateTable(bc1);
        rt1.Contract_Term_gne__c = 'CTR1';
        rt1.Unit_gne__c = 3; 
        rt1.Cost_gne__c = 500000;
        rt1.Payment_Type_gne__c = 'Invoiceable';
        CFAR_Rate_Table_gne__c rt2 = CFAR_DataFactory.createRateTable(bc2);
        insert new List<CFAR_Rate_Table_gne__c> {rt1, rt2};
            
        CFAR_Payment_Schedule_Status_gne__c pss1 = CFAR_DataFactory.createPaymentScheduleStatus('Invoice Paid');
        insert pss1;
        
        CFAR_Budget_CPS_Payments_gne__c payment1 = CFAR_DataFactory.createBudgePayments(rt1, bc1, pss1);
        payment1.Invoice_Submitted_Date_gne__c = System.today().addDays(-7);
        payment1.Invoice_Date_gne__c = System.today();
        payment1.Invoice_gne__c = '44';
        payment1.Paid_On_gne__c = System.today();
        payment1.Invoice_Amount_gne__c = 1500000;
        payment1.Check_Num_gne__c = 'check99999';
        CFAR_Budget_CPS_Payments_gne__c payment2 = CFAR_DataFactory.createBudgePayments(rt2, bc2, pss1);
        insert new List<CFAR_Budget_CPS_Payments_gne__c> {payment1, payment2};
    }
    
    @isTest 
    static void controllerInitTest() {
        PageReference pageRef = Page.CFAR_BudgetReport;
        Test.setCurrentPage(pageRef);
        CFAR_Trial_gne__c trial = [
            SELECT Id 
            FROM CFAR_Trial_gne__c 
            WHERE CTMS_gne__c  = '09999'
        ];
        String idsTms = '';
        For (CFAR_Team_Member_gne__c tm :[
            SELECT Id FROM CFAR_Team_Member_gne__c
        ]){
            idsTms += tm.Id +';';
        }
        pageRef.getParameters().put('piIds', idsTms); 
        pageRef.getParameters().put('includeSummary', 'true'); 
        pageRef.getParameters().put('tId', trial.Id); 

        CFAR_BudgetReport_Controller controller = new CFAR_BudgetReport_Controller();
      
        Test.startTest();
             String workbook = controller.getWorkbookProperties();
        Test.stopTest();
        System.assertEquals('Payment_Report_' + String.valueOf(System.today()), controller.fileName);
        System.assertEquals('<x:ExcelWorkbook><x:ExcelWorksheets>', workbook);
    }
    
    @isTest 
    static void testDataQuality() {
        PageReference pageRef = Page.CFAR_BudgetReport;
        Test.setCurrentPage(pageRef);
        CFAR_Trial_gne__c trial = [
            SELECT Id 
            FROM CFAR_Trial_gne__c 
            WHERE CTMS_gne__c  = '09999'
        ];
        String idsTms = '';
        For (CFAR_Team_Member_gne__c tm :[
            SELECT Id FROM CFAR_Team_Member_gne__c
            WHERE Name = 'team memb one'
        ]){
            idsTms += tm.Id +';';
        }
        
        System.debug('idsTms ' + idsTms);
        pageRef.getParameters().put('piIds', idsTms); 
        pageRef.getParameters().put('includeSummary', 'true'); 
        pageRef.getParameters().put('tId', trial.Id); 
      
        Test.startTest();
            CFAR_BudgetReport_Controller controller = new CFAR_BudgetReport_Controller();
        Test.stopTest();
        
        System.assertEquals(1, controller.rd.size());
        
        //Protocol Number => r.bi.protocolNumber
        CFAR_Budget_Contract_gne__c[] bcs = [
            SELECT PO_Number_gne__c 
            FROM CFAR_Budget_Contract_gne__c
            WHERE Team_Member_ref_gne__c = :idsTms.removeEnd(';')
        ];
        system.debug('bcs ' + bcs);
        System.assertEquals('99983', controller.rd[0].bi.protocolNumber);
        
        //PO # => r.bi.po
        System.assertEquals(bcs[0].PO_Number_gne__c, controller.rd[0].bi.po);
        System.assertEquals('PO10033', controller.rd[0].bi.po);
        
        //functionRole
        System.assertEquals('CSM', controller.rd[0].bi.functionRole);

        //Site => r.bi.institutionName
        CFAR_Institution_gne__c institution = [SELECT Name FROM CFAR_Institution_gne__c Limit 1];
        System.assertEquals(institution.Name, controller.rd[0].bi.institutionName);
        
        //r.bi.department
        System.assertEquals('Dep X', controller.rd[0].bi.department);
        
        //r.bi.address
        System.assertEquals('Sezam Street, Chrzaszczyzewoszyce, NY, 99999', controller.rd[0].bi.address);
        
        //r.bi.phone
        System.assertEquals('555 00 99 99', controller.rd[0].bi.phone);
        
        //r.bi.fax
        System.assertEquals('555 00 99 11', controller.rd[0].bi.fax);
        
        //email
        System.assertEquals('test@test.com.tv', controller.rd[0].bi.email);
        
        //r.bi.currentInvoice
        String ci = String.valueOf(System.today().addDays(-7)); 
        System.assertEquals(ci, controller.rd[0].bi.currentInvoice);
        
        //siteInvoiceDate
        String si = String.valueOf(System.today()); 
        //System.assertEquals(si, controller.rd[0].bi.siteInvoiceDate);
        
        //siteInvoiceNumber
        //System.assertEquals('44', controller.rd[0].bi.siteInvoiceNumber);
        
        // ------------- invoices ---------------------//
        CFAR_BudgetReport_Controller.ReportData rapData = controller.rd[0];
        System.assertEquals(2, rapData.invoices.size());
        CFAR_BudgetReport_Controller.Invoice inv = rapData.invoices[0];
        
        //datePaid
        System.assertEquals(si, inv.datePaid);
        //amount
        System.assertEquals(1500000, inv.amount);
        
        //invoiceNumber
        System.assertEquals('44', inv.invoiceNumber);
        
        //referenceNumber
        System.assertEquals('check99999', inv.referenceNumber);
        
        // ------------- CONTRACT SUMMARY ---------------------//
        System.assertEquals(2, rapData.contactSummarys.size());
        CFAR_BudgetReport_Controller.ContractSummary contSumm = rapData.contactSummarys[0];
        
        //contractTerm
        System.assertEquals('CTR1', contSumm.contractTerm);
        
        //paymentType
        System.assertEquals('Invoiceable', contSumm.paymentType);
        
        //approvedValue
        System.assertEquals(1500000, contSumm.approvedValue);
        
        //paidValue
        System.assertEquals(0, contSumm.paidValue);
        
        //remainingValue
        System.assertEquals(1500000, contSumm.remainingValue);
    }
}