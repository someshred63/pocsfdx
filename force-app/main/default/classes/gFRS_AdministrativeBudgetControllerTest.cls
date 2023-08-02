@isTest(SeeAllData=true)
private class gFRS_AdministrativeBudgetControllerTest {
	
    static testMethod void checkControlerProperties(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
        gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();
        String userData=adminBudg.getUserInfo;
        List<SelectOption> budgets=adminBudg.getAvailableAmdmnistrativeBudgets();
    }
    
    static testMethod void checkControlerWithParam(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
        gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();
        String userData=adminBudg.getUserInfo;
        List<SelectOption> budgets=adminBudg.getAvailableAmdmnistrativeBudgets();
        
        PageReference pageRef = Page.gFRS_AdministrativeBudgetReport;
        if(!budgets.isEmpty()){
            SelectOption opt = budgets.get(0);
            pageRef.getParameters().put('id',opt.getValue());
        }
        Test.setCurrentPage(pageRef);
        
        gFRS_AdministrativeBudgetController adminBudg1=new gFRS_AdministrativeBudgetController();
        try{
        	PageReference pageRef3=adminBudg1.exportToExcel();
        }catch(Exception ex){}    
    }
    
    static testMethod void checkControlerWithParam1(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
        gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();
        String userData=adminBudg.getUserInfo;
        List<SelectOption> budgets=adminBudg.getAvailableAmdmnistrativeBudgets();
        
        PageReference pageRef = Page.gFRS_AdministrativeBudgetReport;
        if(!budgets.isEmpty() && budgets.size()>1){
            SelectOption opt = budgets.get(1);
            pageRef.getParameters().put('id',opt.getValue());
        }
        Test.setCurrentPage(pageRef);
        
        gFRS_AdministrativeBudgetController adminBudg1=new gFRS_AdministrativeBudgetController(); 
    }
    
    static testMethod void checkControlerWithParam2(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
        gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();
        String userData=adminBudg.getUserInfo;
        List<SelectOption> budgets=adminBudg.getAvailableAmdmnistrativeBudgets();
        
        PageReference pageRef = Page.gFRS_AdministrativeBudgetReport;
        if(!budgets.isEmpty() && budgets.size()>2){
            SelectOption opt = budgets.get(2);
            pageRef.getParameters().put('id',opt.getValue());
        }
        Test.setCurrentPage(pageRef);
        
        gFRS_AdministrativeBudgetController adminBudg1=new gFRS_AdministrativeBudgetController(); 
    }
    
    static testMethod void checkControlerWithParam3(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
        gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();
        String userData=adminBudg.getUserInfo;
        List<SelectOption> budgets=adminBudg.getAvailableAmdmnistrativeBudgets();
        
        PageReference pageRef = Page.gFRS_AdministrativeBudgetReport;
        if(!budgets.isEmpty() && budgets.size()>3){
            SelectOption opt = budgets.get(3);
            pageRef.getParameters().put('id',opt.getValue());
        }
        Test.setCurrentPage(pageRef);
        
        gFRS_AdministrativeBudgetController adminBudg1=new gFRS_AdministrativeBudgetController(); 
    }

    static testMethod void getBudgetListForBarChartTest(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
        gFRS_UnitTestHelper.createAdministrativeBudget();
        gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();

        List<SelectOption> budgets=adminBudg.getAvailableAmdmnistrativeBudgets();
        adminBudg.selectedBudget = budgets.get(1).getValue();
        adminBudg.generateReport();

        List<gFRS_AdministrativeBudgetController.BudgetHelper> budgetHelperList = adminBudg.getBudgetHelperList();
        List<gFRS_AdministrativeBudgetController.BudgetListItem> budgetListItems = adminBudg.getBudgetListForBarChart();

        for(gFRS_AdministrativeBudgetController.BudgetListItem b : budgetListItems){
            for(gFRS_AdministrativeBudgetController.BudgetHelper  t : budgetHelperList){
                if(t.budgetLineItem.WBS_Description__c.equals(b.allocationName)){
                     System.assertEquals(t.totalAllocated,b.totalAllocated);
                     System.assertEquals(t.budgetLineItem.Planned_Allocation__c,b.plannedAllocation);
                }
                if(b.allocationName.equals('Total')){
                     System.assertEquals(b.totalAllocated,adminBudg.budgetSummary.totalAllocated);
                     System.assertEquals(b.plannedAllocation,adminBudg.budgetSummary.totalPlanned);
                }
            }
        }
    }

    static testMethod void generateReportForDEV(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
       gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();
       
       Date fiscalYear = Date.newInstance( Date.today().year(), 01, 01 );
       String adminBudgetName = 'Budget DEV Test';
       Id recordType_Id = [SELECT Id FROM RecordType WHERE Name = 'DEV' AND SobjectType = 'GFRS_Administrative_Budget__c'].Id;
       GFRS_Administrative_Budget__c administrative_budget = new GFRS_Administrative_Budget__c(Fiscal_Year__c = fiscalYear, Name =  adminBudgetName, RecordTypeId = recordType_Id);
       insert administrative_budget;

       List<GFRS_Administrative_Budget_Line_Item__c> administrative_budget_line_items = new List<GFRS_Administrative_Budget_Line_Item__c>();
       administrative_budget_line_items.add(new GFRS_Administrative_Budget_Line_Item__c( 
                                                Administrative_Budget__c = administrative_budget.Id, 
                                                Planned_Allocation__c = 18000000, 
                                                WBS_Code__c = '101.02107', 
                                                WBS_Description__c = '2H7 Immu/RA/SB'));
       administrative_budget_line_items.add(new GFRS_Administrative_Budget_Line_Item__c( 
                                                Administrative_Budget__c = administrative_budget.Id, 
                                                Planned_Allocation__c = 18000000, 
                                                WBS_Code__c = '101.01031', 
                                                WBS_Description__c = '2H7 Immu/General/R&D Collab Settlmnt'));

       insert administrative_budget_line_items;

       adminBudg.selectedBudget = administrative_budget.Id;
       adminBudg.generateReport();


    }

    static testMethod void generateReportForIMED(){
        gFRS_UnitTestHelper.createAdministrativeBudget();
       gFRS_AdministrativeBudgetController adminBudg=new gFRS_AdministrativeBudgetController();
       
       Date fiscalYear = Date.newInstance( Date.today().year(), 01, 01 );
       String adminBudgetName = 'Budget IMED Test';
       Id recordType_Id = [SELECT Id FROM RecordType WHERE Name = 'IMED' AND SobjectType = 'GFRS_Administrative_Budget__c'].Id;
       GFRS_Administrative_Budget__c administrative_budget = new GFRS_Administrative_Budget__c(Fiscal_Year__c = fiscalYear, Name =  adminBudgetName, RecordTypeId = recordType_Id);
       insert administrative_budget;

       List<GFRS_Administrative_Budget_Line_Item__c> administrative_budget_line_items = new List<GFRS_Administrative_Budget_Line_Item__c>();
       administrative_budget_line_items.add(new GFRS_Administrative_Budget_Line_Item__c( 
                                                Administrative_Budget__c = administrative_budget.Id, 
                                                Planned_Allocation__c = 18000000, 
                                                WBS_Code__c = '101.01001', 
                                                WBS_Description__c = '2H7 (rhuMAb 2H7)/General/General Dev'));
       administrative_budget_line_items.add(new GFRS_Administrative_Budget_Line_Item__c( 
                                                Administrative_Budget__c = administrative_budget.Id, 
                                                Planned_Allocation__c = 18000000, 
                                                WBS_Code__c = '101.02105', 
                                                WBS_Description__c = '2H7 Immu/RA/IA'));

       insert administrative_budget_line_items;

       adminBudg.selectedBudget = administrative_budget.Id;
       adminBudg.generateReport();


    }
}