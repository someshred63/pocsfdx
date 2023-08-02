@isTest
private class CFAR_FinanceReport_ControllerTest {
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
            Active_gne__c = true,
            Name = 'Test product',
            Generic_Name_gne__c = 'generic'
        );
        insert product1;
        
        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c(
            Name = 'type 1',
            Active_gne__c = true
        );
        insert trialType;
        
        CFAR_WBS_gne__c wbs = CFAR_DataFactory.createWbs('Actemra FIALA');
        wbs.GSR_WBS_gne__c = 'GN09544PML28241';
        insert new List<CFAR_WBS_gne__c> {wbs}; 
            
        CFAR_Therapeutic_Area_gne__c ta = new CFAR_Therapeutic_Area_gne__c(Name = 'TA 1', 	Active_gne__c = true);
        insert ta;
        
        CFAR_General_Indication_gne__c gi = new CFAR_General_Indication_gne__c(Name = 'GA 1', Active_gne__c = true);
        insert gi;
        
        
        CFAR_Trial_Status_gne__c trialStatus = new CFAR_Trial_Status_gne__c(Name = 'TS ACTIVE', Active_gne__c = true);
        insert trialStatus;
        
        CFAR_Dollar_and_Drug_gne__c dd = new CFAR_Dollar_and_Drug_gne__c(Name = 'dollar', Active_gne__c = true);
        insert dd;
        
        CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial( 0);
        t1.CTMS_gne__c = '09999';
        t1.Trial_Type_ref_gne__c = trialType.Id;
        t1.Other_Trial_gne_Id__c = '99983';
        t1.Name = 'ALE10686';
        t1.CFAR_WBS_ref_gne__c = wbs.Id;
        t1.Product_ref_gne__c = product1.Id;
        t1.Therapeutic_Area_ref_gne__c = ta.Id;
        t1.CFAR_General_Indication_ref_gne__c = gi.Id;
        t1.Trial_Status_ref_gne__c = trialStatus.Id;
        t1.Dollar_and_Drug_ref_gne__c = dd.Id;
        t1.Subject_Type__c = 'Human';
        t1.Title_gne__c = 'Trial title';
        t1.Other_Agents_gne__c = 'OT AGENT 007';
        t1.Regimen_gne__c = 'RG1';
        t1.Planned_Enrollment_gne__c = 10000;
        t1.Non_Interventional_gne__c = 'Yes';
        
        CFAR_Trial_gne__c t2 = CFAR_DataFactory.createTrial(1);
        t2.CTMS_gne__c = '09996';
        t2.Trial_Type_ref_gne__c = trialType.Id;
        t2.Other_Trial_gne_Id__c = '99985';
        t2.CFAR_WBS_ref_gne__c = wbs.Id;
        t2.Product_ref_gne__c = product1.Id;
        List<CFAR_Trial_gne__c> trialList = new List<CFAR_Trial_gne__c> {t1, t2};
        insert trialList;
            
        CFAR_General_Indication_for_Trial_gne__c gift = new CFAR_General_Indication_for_Trial_gne__c(
            CFAR_Trial_ref_gne__c = t1.Id,
            CFAR_General_Indication_ref_gne__c = gi.Id
        );
        insert gift;
            
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
        CFAR_Team_Member_gne__c teamMember2 = CFAR_DataFactory.createTeamMember(t1, 'team memb two', caJO, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE);
        insert new List<CFAR_Team_Member_gne__c> {teamMember1, teamMember2};

        for (CFAR_Trial_gne__c trial : trialList) {
            trial.Genentech_Primary_Contact_ref_gne__c = contact1.Id;
        }
        update trialList;
            
        CFAR_Budget_Contract_gne__c bc1 = CFAR_DataFactory.createBudgetContract(teamMember1);
        bc1.PO_Number_gne__c = 'PO10033';
        bc1.Total_payments_gne__c = 500;
        bc1.Prior_Years_Paid_gne__c = 500;
        bc1.Year_to_Date_Paid_gne__c = 0;
        insert bc1;
            
        CFAR_Specific_Indication_gne__c si = CFAR_DataFactory.createSpecificIndication('test si');
        insert si;
        
        CFAR_Specific_Indication_for_Trial_gne__c sift = CFAR_DataFactory.createSpecificIndicationForTrial(si, t1);
        insert sift;        
        
        CFAR_Budget_Contract_Type_gne__c bctype = CFAR_DataFactory.createBudgetContractType();
        bctype.Name = 'Original Contract';
        insert bctype;
        
        CFAR_Budget_Contract_Tracking_gne__c bctracing = CFAR_DataFactory.createBudgetContractTracking(bc1, bctype, 1000 );
        bctracing.Fully_Executed_Date_gne__c = date.newinstance(System.now().year(), 5, 1);
        bctracing.Contract_Expiry_Date_gne__c = date.newinstance(System.now().year(), 5, 1).addMonths(10);
        bctracing.Contract_Requested_Date__c = date.newinstance(System.now().year(), 5, 1);
        bctracing.txt_Type_gne__c = 'Original Contract';
        insert bctracing;
        
        CFAR_Rate_Table_gne__c rt = CFAR_DataFactory.createRateTable(bc1);
        insert rt;
            
        CFAR_Payment_Schedule_Status_gne__c  pss = CFAR_DataFactory.createPaymentScheduleStatus('pss 1');
        insert pss;
        
        CFAR_Budget_CPS_Payments_gne__c bcp = CFAR_DataFactory.createBudgePayments(rt, bc1, pss);
        insert bcp;
        
        CFAR_Milestone_Activity_gne__c mil1 = CFAR_DataFactory.createMilestoneActivity(t1, 'Activation');
        CFAR_Milestone_Activity_gne__c mil2 = CFAR_DataFactory.createMilestoneActivity(t1, 'Proposal Approval');
        CFAR_Milestone_Activity_gne__c mil3 = CFAR_DataFactory.createMilestoneActivity(t1, 'Draft Protocol Approval');
        CFAR_Milestone_Activity_gne__c mil4 = CFAR_DataFactory.createMilestoneActivity(t1, 'IMD Approval');
        CFAR_Milestone_Activity_gne__c mil5 = CFAR_DataFactory.createMilestoneActivity(t1, 'SRT Protocol Approval');
        CFAR_Milestone_Activity_gne__c mil6 = CFAR_DataFactory.createMilestoneActivity(t1, 'TRAC Protocol Approval');
        CFAR_Milestone_Activity_gne__c mil7 = CFAR_DataFactory.createMilestoneActivity(t1, 'FPI');
        CFAR_Milestone_Activity_gne__c mil8 = CFAR_DataFactory.createMilestoneActivity(t1, 'LPI');
        CFAR_Milestone_Activity_gne__c mil9 = CFAR_DataFactory.createMilestoneActivity(t1, 'LPO');
        CFAR_Milestone_Activity_gne__c mil10 = CFAR_DataFactory.createMilestoneActivity(t1, 'Study Closure');
        insert new List<CFAR_Milestone_Activity_gne__c> {mil1, mil2, mil3, mil4, mil5, mil6, mil7, mil8, mil9, mil10};
            
        CFAR_Trial_Other_GNE_Agent_gne__c toa = new CFAR_Trial_Other_GNE_Agent_gne__c(
            Other_GNE_Agent_ref_gne__c = product1.Id,
            CFAR_Trial_ref_gne__c = t1.Id
        );
        insert toa;
        
        CFAR_Comment_gne__c comm = CFAR_DataFactory.createComment(t1, 'test comment');
        insert comm;

        CFAR_Comment_gne__c comm2 = CFAR_TestUtils.createComment(t1, contact1, Date.newInstance(2016,2,10), 'test comment text 1234');


        Integer year = System.today().Year();
        CFAR_Budget_CPS_Projection_gne__c projectionY2 = CFAR_DataFactory.createBudgetProjection(t1, 10, 40, 100, 500);
        projectionY2.Year_gne__c = String.valueOf(year + 2);
        CFAR_Budget_CPS_Projection_gne__c projectionY3 = CFAR_DataFactory.createBudgetProjection(t1, 10, 40, 100, 500);
        projectionY3.Year_gne__c = String.valueOf(year + 3);
        insert new List<CFAR_Budget_CPS_Projection_gne__c> {projectionY2, projectionY3};
    }
    
    @isTest 
    static void controllerInitTest() {
        PageReference pageRef = Page.CFAR_FinanceReportXLS;
        Test.setCurrentPage(pageRef);
        CFAR_FinanceReport_Controller controller = new CFAR_FinanceReport_Controller();
        
        Test.startTest();
            String workbook = controller.getWorkbookProperties();
            String fileName = controller.getFileName();
            Integer currentYear = controller.getCurrentYear();
            Integer currentYear1 = controller.getYear1Fwd() ;
            Integer currentYear2 = controller.getYear2Fwd();
            Integer currentYear3 = controller.getYear3Fwd();
        Test.stopTest();
        
        String workbookToCompare = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + 
            'Finance Report' + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/>' + 
            '</x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        
        System.assertEquals(workbookToCompare, workbook);
        System.assertEquals('Finance_Report_' + String.valueOf(Date.today()), fileName);
        System.assertEquals(System.today().year(), currentYear);
        System.assertEquals(System.today().year() + 1, currentYear1);
        System.assertEquals(System.today().year() + 2, currentYear2);
        System.assertEquals(System.today().year() + 3, currentYear3);
    }
    
    @isTest 
    static void testDataQuality() {
        PageReference pageRef = Page.CFAR_FinanceReportXLS;
        Test.setCurrentPage(pageRef);
        CFAR_FinanceReport_Controller controller = new CFAR_FinanceReport_Controller();
        CFAR_Product_gne__c p1 = [SELECT Id FROM CFAR_Product_gne__c LIMIT 1];
        CFAR_Trial_gne__c trial = [SELECT Id, Name FROM CFAR_Trial_gne__c WHERE CTMS_gne__c = '09999' LIMIT 1];
        CFAR_General_Indication_gne__c gi = [SELECT Id FROM CFAR_General_Indication_gne__c LIMIT 1];
        CFAR_Trial_Status_gne__c trialStatus = [SELECT ID FROM CFAR_Trial_Status_gne__c LIMIT 1];
        CFAR_Therapeutic_Area_gne__c ta = [SELECT Id FROM CFAR_Therapeutic_Area_gne__c LIMIT 1];
        CFAR_Trial_Type_gne__c trialType = [SELECT Id FROM CFAR_Trial_Type_gne__c LIMIT 1];
        
        pageRef.getParameters().put('product', p1.Id); 
        pageRef.getParameters().put('indication', gi.Id); 
        pageRef.getParameters().put('studyNo', trial.Name);
        pageRef.getParameters().put('studyStatus', trialStatus.Id);
        pageRef.getParameters().put('therapeuticArea', ta.Id);
        pageRef.getParameters().put('trialType', trialType.Id);
        pageRef.getParameters().put('subjectType', 'Human');
        pageRef.getParameters().put('ctms', '09999');
        pageRef.getParameters().put('wbs', 'GN09544PML28241');
        
        Test.startTest();
            CFAR_FinanceReport_DataModel.ReportDataWrapper wrapper = controller.getReportData();
        Test.stopTest();
        
        System.assertEquals(1, wrapper.allRows.size());
        
        CFAR_FinanceReport_DataModel.SingleRowWrapper swr = wrapper.allRows[0];
        
        //therapeuticArea
        System.assertEquals('TA 1', swr.therapeuticArea);        
        //productName
        System.assertEquals('Test product', swr.productName);        
        //primaryGeneralIndication
        System.assertEquals('GA 1', swr.primaryGeneralIndication);       
        //theme
        System.assertEquals('GA 1', swr.primaryGeneralIndication);        
        //investigatorSponsorName
        System.assertEquals('lastName1,', swr.investigatorSponsorName);        
        //institutionName
        System.assert(swr.institutionName.contains('x-lab'));
        //trialStatus
        System.assertEquals('TS ACTIVE', swr.trialStatus);
        // trialType 
        System.assertEquals('type 1', swr.trialType);
        //gneSupport
        System.assertEquals('dollar', swr.gneSupport);
        //WBSCode
        System.assertEquals('GN09544PML28241', swr.WBSCode);
        //protocolNo
        System.assertEquals('99983', swr.protocolNo);
        //CTMSNo
        System.assertEquals('09999', swr.CTMSNo);
        //gstarsTrialNo
        System.assertEquals(trial.Name, swr.gstarsTrialNo);
        //poNumber
        System.assertEquals('PO10033', swr.poNumber);
        //contractFullyExecutedDate
        System.assertEquals(date.newinstance(System.now().year(), 5, 1).format(), swr.contractFullyExecutedDate);
        //contractExpiryDate
        System.assertEquals(date.newinstance(System.now().year(), 5, 1).addMonths(10).format(), swr.contractExpiryDate);
        //currentContractAmount
        System.assertEquals(1000, swr.currentContractAmount);
        //totalPaid
        System.assertEquals(500, swr.totalPaid);
        //balanceAmount
        System.assertEquals(1000, swr.balanceAmount);
        //balanceLeftToProject
        System.assertEquals(500, swr.balanceLeftToProject);
        //specificIndication
        System.assertEquals('test si', swr.specificIndication);
        //protocolTitle
        System.assertEquals('Trial title', swr.protocolTitle);
        //gneAgents
        //System.assertEquals('generic', swr.gneAgents);
        //otherAgents
        System.assertEquals('OT AGENT 007', swr.otherAgents);
        //regimen
        System.assertEquals('RG1', swr.regimen);
        //sampleSize
        System.assertEquals(10000, swr.sampleSize);
        //totalEnrolled
        System.assertEquals(0, swr.totalEnrolled);
        //proposalApprovedPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.proposalApprovedPlanned);
        //proposalApprovedActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.proposalApprovedActual);
        //draftProtocolApprovedPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.draftProtocolApprovedPlanned);
        //draftProtocolApprovedActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.draftProtocolApprovedActual);
        //imlApprovedActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.imlApprovedActual);
        //srrtProtocolApprovedPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.srrtProtocolApprovedPlanned);
        //srrtProtocolApprovedActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.srrtProtocolApprovedActual);
        //tracProtocolApprovedPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.tracProtocolApprovedPlanned);
        //tracProtocolApprovedActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.tracProtocolApprovedActual);
        //activationPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.activationPlanned);
        //activationActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.activationActual);
        //fpiPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.fpiPlanned);
        //fpiActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.fpiActual);
        //lpiPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.lpiPlanned);
        //lpiActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.lpiActual);
        //lpoPlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.lpoPlanned);
        //lpoActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.lpoActual);
        //studyClosurePlanned
        System.assertEquals(System.today().addMonths(2).format(), swr.studyClosurePlanned);
        //studyClosureActual
        System.assertEquals(System.today().addMonths(-1).format(), swr.studyClosureActual);
        //lastComment
        System.assertEquals('test comment', swr.lastComment);
        //interventional
        System.assertEquals('Yes', swr.interventional);
        //q1
        System.assertEquals(0, swr.q1);
        //q2
        System.assertEquals(182, swr.q2);
        //q3
        System.assertEquals(273, swr.q3);
        //q4
        System.assertEquals(273, swr.q4);
        //year1FwdProjectionsTotal
        System.assertEquals(273, swr.year1FwdProjectionsTotal);
        //year2FwdProjectionsTotal
        System.assertEquals(650, swr.year2FwdProjectionsTotal);
        //year3FwdProjectionsTotal
        System.assertEquals(650, swr.year3FwdProjectionsTotal);
        //csm
        System.assertEquals('lastName1,', swr.csm);
        //csa
        System.assertEquals('lastName1,', swr.csa);
    }

}