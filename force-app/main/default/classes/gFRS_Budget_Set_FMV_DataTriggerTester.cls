@isTest
private class gFRS_Budget_Set_FMV_DataTriggerTester {
	
	public static final String CATEGORY_MEALS = 'Meals';
	public static final String SUBCATEGORY_LUNCH = 'Lunch';

    class TestSettings {
        public GFRS_Organization__c organization;
        public Account account;
        public GFRS_Funding_Request__c request;
        public GFRS_RequestBudget__c budget;
        public GFRS_Program__c program;
        public GFRS_FMV__c[] FMVs;
        
        public  String DEFAULT_STATUS = 'Intake';
        public  String DEFAULT_SUB_STATUS = 'Not Submitted';
        
        public TestSettings(){
            account = gFRS_TestCreationUtils.createAccount('test');
            insert account;
            organization = gFRS_TestCreationUtils.createOrganization('223344556', account);
            insert organization;
            
            delete [ select id from GFRS_FMV__c where Program_Name__c = :gFRS_Util.FMV_SYMPOSIUM ];
            
            FMVs = new GFRS_FMV__c[]{
            	gFRS_TestCreationUtils.createFMV( CATEGORY_MEALS, SUBCATEGORY_LUNCH, gFRS_Util.FMV_SYMPOSIUM, 10, 50, 100 ),
            	gFRS_TestCreationUtils.createFMV( CATEGORY_MEALS, SUBCATEGORY_LUNCH, gFRS_Util.FMV_GRAND, 10, 50, 100 ),
            	gFRS_TestCreationUtils.createFMV( CATEGORY_MEALS, SUBCATEGORY_LUNCH, gFRS_Util.FMV_ENDURING, 10, 50, 100 )
            };
            insert FMVs;
        }
        
        public void createFundingRequestImedWithProgram(String ProgramType, String BudgetSummaryDesc, String ProgramSubType){
            request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED, DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, null);
            insert request;
            request = [SELECT Record_Type_Name__c FROM GFRS_Funding_Request__c WHERE Id =: request.Id];
            Id recordTypeId = [select Id from RecordType where Name = :request.Record_Type_Name__c+' - Program'].Id;
            program = new GFRS_Program__c( Funding_Request__c = request.id, Type__c = programType, Expected_Number_of_Attendees__c = 0, Expected_of_attendees_that_are_HCPs__c = 0, Expected_of_Attendees_US_Based_HCPs__c = 0, RecordTypeId =  recordTypeId, Number_of_Activities__c = 1 );
            if (ProgramSubType != null) {
            	program.Program_Subtype__c = ProgramSubType;
            }
            insert program;
            budget = gFRS_TestCreationUtils.createRequestBudget_min(request);
            if (BudgetSummaryDesc != null) {
                budget.Budget_Summary_Description__c = BudgetSummaryDesc;
            }
            insert budget;
        }
    }


    static testMethod void testIdTriggerWorksForIMEDLive() {
        TestSettings ts = new TestSettings();
        ts.createFundingRequestImedWithProgram('Some program type', gFRS_Util.BUDGET_DESC_LIVE, null);
        
        GFRS_Request_Budget_Line_Item__c rbli = new GFRS_Request_Budget_Line_Item__c(Budget__c = ts.budget.Id, Budget_Category__c = CATEGORY_MEALS, Budget_Subcategory__c = SUBCATEGORY_LUNCH, Amount__c = 10 );
        insert rbli;
        
        rbli = [SELECT FMV_Lower__c, FMV_Median__c, FMV_Upper__c FROM GFRS_Request_Budget_Line_Item__c WHERE Id =: rbli.Id];

        GFRS_FMV__c fmv = ts.FMVs[0];
        
        System.assertEquals(fmv.Lower_Amount__c, rbli.FMV_Lower__c);
        System.assertEquals(fmv.Median_Amount__c, rbli.FMV_Median__c);
        System.assertEquals(fmv.Upper_Amount__c, rbli.FMV_Upper__c);
    }
    
    static testMethod void testIdTriggerWorksForIMEDGrand() {
        TestSettings ts = new TestSettings();
        ts.createFundingRequestImedWithProgram('Some program type', gFRS_Util.BUDGET_DESC_LIVE, gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE);
        
        GFRS_Request_Budget_Line_Item__c rbli = new GFRS_Request_Budget_Line_Item__c(Budget__c = ts.budget.Id, Budget_Category__c = CATEGORY_MEALS, Budget_Subcategory__c = SUBCATEGORY_LUNCH, Amount__c = 10 );
        insert rbli;
        
        rbli = [SELECT FMV_Lower__c, FMV_Median__c, FMV_Upper__c FROM GFRS_Request_Budget_Line_Item__c WHERE Id =: rbli.Id];

        GFRS_FMV__c fmv = ts.FMVs[0];
        
        System.assertEquals(fmv.Lower_Amount__c, rbli.FMV_Lower__c);
        System.assertEquals(fmv.Median_Amount__c, rbli.FMV_Median__c);
        System.assertEquals(fmv.Upper_Amount__c, rbli.FMV_Upper__c);
    }
    
    static testMethod void testIdTriggerWorksForIMEDEnduring() {
        TestSettings ts = new TestSettings();
        ts.createFundingRequestImedWithProgram('Some program type', null, null);
        
        GFRS_Request_Budget_Line_Item__c rbli = new GFRS_Request_Budget_Line_Item__c(Budget__c = ts.budget.Id, Budget_Category__c = CATEGORY_MEALS, Budget_Subcategory__c = SUBCATEGORY_LUNCH, Amount__c = 10 );
        insert rbli;
        
        rbli = [SELECT FMV_Lower__c, FMV_Median__c, FMV_Upper__c FROM GFRS_Request_Budget_Line_Item__c WHERE Id =: rbli.Id];

        GFRS_FMV__c fmv = ts.FMVs[0];
        
        System.assertEquals(fmv.Lower_Amount__c, rbli.FMV_Lower__c);
        System.assertEquals(fmv.Median_Amount__c, rbli.FMV_Median__c);
        System.assertEquals(fmv.Upper_Amount__c, rbli.FMV_Upper__c);
    }
}