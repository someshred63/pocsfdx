/*
@author ADMD Team
@date 2013-07-15
@description gFRS_AdministrativeBudgetController - controller class used under page:gFRS_AdministrativeBudgetReport 
*/

public without sharing class gFRS_AdministrativeBudgetController {

    public Id selectedBudget { get; set; }
    public String selectedBudgetName { get; set; }
    public String [] associatedFundingTypesForBudgetType { get; set; }
    public String selectedBudgetLineItem { get; set; }
    public Boolean showReportSection { get; set; }
    public Map<String, BudgetHelper> budgetHelperList;
    public Map<String, GFRS_Administrative_Budget_Line_Item__c> budgetLI_Map { get; set; }
    public String selectedBudgetKey { get; set; }
    public SummaryOfBudgetLineItems budgetSummary { get; set; }
    public Boolean isBarChartRendered { get; set; }

    /*
    @author ADMD Team
    @date 2013-07-15
    @description gFRS_AdministrativeBudgetController - class constructor initiate properties under controller class
    */
    public gFRS_AdministrativeBudgetController() {
        budgetHelperList = new Map<String, BudgetHelper>();
        budgetLI_Map = new Map<String, GFRS_Administrative_Budget_Line_Item__c>();

        if (ApexPages.currentPage().getParameters().containsKey('id')) {
            selectedBudget = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
            generateReport();
        } else {
            selectedBudget = [SELECT Name, Id FROM GFRS_Administrative_Budget__c ORDER BY SYS_Fiscal_Year__c ASC][0].Id;
        }
    }

    public String getUserInfo {
        get {
            return UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        }
    }
    /*
    @author ADMD Team
    @date 2013-07-15
    @description getAvailableAmdmnistrativeBudgets - property which returns all defined Administrative Budgets in the system.
    */
    public List<SelectOption> getAvailableAmdmnistrativeBudgets() {
        List<SelectOption> budgets = new List<SelectOption>();

        for (GFRS_Administrative_Budget__c budget : [SELECT Name, Id FROM GFRS_Administrative_Budget__c ORDER BY SYS_Fiscal_Year__c ASC]) {
            budgets.add(new SelectOption(budget.Id, budget.Name));
        }
        return budgets;
    }

    /*
    @author ADMD Team
    @date 2013-07-15
    @description generateReport - method which rendering report for selected administrative budget 
    */
    public void generateReport() {
        getAdnministrativeBudgetLIForBudget();
        this.budgetSummary = new SummaryOfBudgetLineItems(getBudgetHelperList());

        /* bar chart */

        this.isBarChartRendered = true;
    }

    /*
    @author ADMD Team
    @date 2015-09-04
    @Description getBudgetListForBarChart - method to fetch needed data for bar chart
    */
    public List<BudgetListItem> getBudgetListForBarChart() {
        List<BudgetListItem> tempBudgetList = new List<BudgetListItem>();

        for (BudgetHelper b : budgetHelperList.values()) {
            tempBudgetList.add(new BudgetListItem(
                    b.totalAllocated,
                    b.budgetLineItem.Planned_Allocation__c,
                    b.budgetLineItem.WBS_Description__c
            ));
        }

        tempBudgetList.add(new BudgetListItem(
                budgetSummary.totalAllocated,
                budgetSummary.totalPlanned,
                'Total'
        ));

        return tempBudgetList;
    }

    /*
    @author ADMD Team
    @date 2015-09-04
    @Description BudgetListItem helper class to hold needed bar chart date
    */
    public class BudgetListItem {
        public Decimal totalAllocated;
        public Decimal plannedAllocation;
        public String allocationName;

        public BudgetListItem(Decimal totalAllocated, Decimal plannedAllocation, String allocationName) {
            this.totalAllocated = totalAllocated;
            this.plannedAllocation = plannedAllocation;
            this.allocationName = allocationName;
        }
    }

    /*
    @author ADMD Team
    @date 2013-07-15
    @description getAdnministrativeBudgetLIForBudget - method wich agregate Budget Line Items and Funding Allocation Line Items from selected Administative Budget.
    */
    public void getAdnministrativeBudgetLIForBudget() {
        budgetLI_Map = new Map<String, GFRS_Administrative_Budget_Line_Item__c>();
        budgetHelperList = new Map<String, BudgetHelper>();

        Date selectedBudgetFiscalYear = null;
        String delimiter = '-';
        String key = null, budgetType = null, recordTypeName = null;

        if (selectedBudget != null) {
            /*
            Following loop takes all Administrative Budget Line Items assigned to selected admnistrative budget and creates map
            */
            Boolean isFirstLoopIteration = true;
            selectedBudgetFiscalYear = [SELECT Fiscal_Year__c FROM GFRS_Administrative_Budget__c WHERE Id = :selectedBudget][0].Fiscal_Year__c;
            for (GFRS_Administrative_Budget_Line_Item__c objAdminBudgetLi : [
                    SELECT Id, Name, WBS_Code__c,WBS_Description__c, Administrative_Budget__r.Name, Administrative_Budget__r.RecordType.Name, Cost_Center__c,Administrative_Budget__r.Fiscal_Year__c,Planned_Allocation__c
                    FROM GFRS_Administrative_Budget_Line_Item__c
                    WHERE Administrative_Budget__r.Id = :selectedBudget
            ]) {
                if (isFirstLoopIteration) {
                    this.selectedBudgetName = objAdminBudgetLi.Administrative_Budget__r.Name;
                    if (objAdminBudgetLi.Administrative_Budget__r.RecordType.Name == 'CAPP') {
                        this.associatedFundingTypesForBudgetType = new String[]{
                                gFRS_Util.TYPE_HC_CHAR_NAME, gFRS_Util.TYPE_PHILANTHROPIC_NAME, gFRS_Util.TYPE_FELLOWSHIPS_NAME, gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME
                        };
                    } else if (objAdminBudgetLi.Administrative_Budget__r.RecordType.Name == 'DEV') {
                        this.associatedFundingTypesForBudgetType = new String[]{
                        };
                    } else if (objAdminBudgetLi.Administrative_Budget__r.RecordType.Name == 'IMED') {
                        this.associatedFundingTypesForBudgetType = new String[]{
                                gFRS_Util.TYPE_IMED_NAME
                        };
                    }
                }
                key = delimiter + objAdminBudgetLi.WBS_Code__c + delimiter + objAdminBudgetLi.Cost_Center__c;

                if (objAdminBudgetLi.Administrative_Budget__r != null && objAdminBudgetLi.Administrative_Budget__r.RecordType != null) {
                    key = objAdminBudgetLi.Administrative_Budget__r.RecordType.Name + key;
                }
                if (objAdminBudgetLi.Administrative_Budget__r != null && objAdminBudgetLi.Administrative_Budget__r.Fiscal_Year__c != null) {
                    key = String.valueOf(objAdminBudgetLi.Administrative_Budget__r.Fiscal_Year__c.year()) + key;
                }
                if (budgetLI_Map.containsKey(key)) {
                    System.debug('budgetLI_Map[' + key + '] is not unique, old value is discarded:' + budgetLI_Map.get(key));
                } else {
                    budgetLI_Map.put(key, objAdminBudgetLi);
                }
                isFirstLoopIteration = false;
            }

            /*
            Following loop takes all Funding Allocation Line Items which are assigned to requests which Year of Decision Date is the same as in selected Administrative Budget.
            */
            if (this.associatedFundingTypesForBudgetType != null) {
                for (GFRS_Funding_Allocation_Line_Item__c allocationLI : [
                        SELECT Name, Id, Funding_Record_Type__c, WBS__c,WBS_Description__c,
                                Funding_Allocation__r.Grant_Request__r.SYS_Request_Approved__c,
                                Funding_Allocation__r.Grant_Request__c,
                                Funding_Allocation__r.Grant_Request__r.Name,
                                Percent__c,
                                Funding_Allocation__r.Grant_Request__r.Record_Type_Name__c,Funding_Allocation__r.Grant_Request__r.Decision_Date__c,
                                Funding_Allocation__r.RecordType.Name,
                                Funding_Allocation__r.Refund_Amount__c,
                                Cost_Center__c, Line_Item_Total__c
                        FROM GFRS_Funding_Allocation_Line_Item__c

                        WHERE Funding_Allocation__r.Grant_Request__r.Foundation_Classified__c = 'FALSE'
                        AND Funding_Allocation__r.Grant_Request__r.SYS_Request_Approved__c = 'Yes'
                        AND Funding_Allocation__r.RecordType.Name IN ('Payment', 'Refund')
                        AND CALENDAR_YEAR(Funding_Allocation__r.Grant_Request__r.Decision_Date__c) = :selectedBudgetFiscalYear.year()
                        AND Funding_Allocation__r.Grant_Request__r.Record_Type_Name__c IN :this.associatedFundingTypesForBudgetType
                ]) {

                    budgetType = '';
                    recordTypeName = allocationLI.Funding_Allocation__r.Grant_Request__r.Record_Type_Name__c;

                    if (recordTypeName != null) {
                        if (gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals(recordTypeName) ||
                                gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME.equals(recordTypeName) ||
                                gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(recordTypeName) ||
                                gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME.equals(recordTypeName)) {
                            //Internal, no need add value to the key
                            budgetType = '';
                        } else if (gFRS_Util.TYPE_IMED_NAME.equals(recordTypeName)) {
                            budgetType = gFRS_Util.BUDGET_RT_IMED;
                        } else if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(recordTypeName) || gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals(recordTypeName)) {
                            budgetType = gFRS_Util.BUDGET_RT_CAPP;
                        } else if (gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals(recordTypeName) || gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME.equals(recordTypeName)) {
                            //MG 2012-11-30
                            //According to problems with data projection vs WBS reporting DEV has to be added to CAPP budget.
                            //budgetType = gFRS_Util.BUDGET_RT_DEV;
                            budgetType = gFRS_Util.BUDGET_RT_CAPP;
                        } else {
                            //-- do nothing
                            System.debug('unknow Funding Record Type:' + recordTypeName);
                        }
                    }

                    if (allocationLI.Funding_Allocation__r != null && allocationLI.Funding_Allocation__r.Grant_Request__r != null && allocationLI.Funding_Allocation__r.Grant_Request__r.Decision_Date__c != null) {
                        key = String.valueOf(allocationLI.Funding_Allocation__r.Grant_Request__r.Decision_Date__c.year()) + budgetType + delimiter + allocationLI.WBS__c + delimiter + allocationLI.Cost_Center__c;
                    } else {
                        key = budgetType + delimiter + allocationLI.WBS__c + delimiter + allocationLI.Cost_Center__c;
                    }

                    if (budgetLI_Map.containsKey(key)) {

                        if (budgetHelperList.containsKey(key)) {
                            BudgetHelper tmpItem = budgetHelperList.get(key);
                            tmpItem.assignedFundingAllocationToBudgetLineItem.add(allocationLI);
                            if (allocationLI.Funding_Allocation__r.RecordType.Name == 'Refund') {
                                tmpItem.totalAllocated -= allocationLI.Line_Item_Total__c ;
                                tmpItem.amountUnlocated += allocationLI.Line_Item_Total__c;
                            } else {
                                tmpItem.totalAllocated += allocationLI.Line_Item_Total__c;
                                tmpItem.amountUnlocated -= allocationLI.Line_Item_Total__c;
                            }

                        } else {
                            budgetHelperList.put(key, new BudgetHelper(allocationLI.Line_Item_Total__c, budgetLI_Map.get(key), new GFRS_Funding_Allocation_Line_Item__c[]{
                                    allocationLI
                            }, true));
                        }
                    }
                }
            }
        }
    }

    /*
    @author ADMD Team
    @date 2013-07-15
    @description
    */
    public List<BudgetHelper> getBudgetHelperList() {
        for (String key : budgetLI_Map.keySet()) {
            if (!budgetHelperList.containsKey(key)) {
                budgetHelperList.put(key, new BudgetHelper(0, budgetLI_Map.get(key), null, false));
            }
        }
        return budgetHelperList.values();
    }

    /*
    @author ADMD Team
    @date 2013-07-15
    @description exportToExcel - method which generate excel file (redirect to gFRS_AdministrativeBudgetReportExcel page )
    */
    public PageReference exportToExcel() {
        PageReference pageRefToReturn = Page.gFRS_AdministrativeBudgetReportExcel;
        return pageRefToReturn.setRedirect(false);
    }

    /*
    @author ADMD Team
    @date 2013-07-15
    @description budgetHelper - helper class
    */
    public class BudgetHelper {
        public Decimal totalAllocated { get; set; }
        public Decimal amountUnlocated { get; set; }
        public Boolean haveAllocationLineItem { get; set; }
        public GFRS_Administrative_Budget_Line_Item__c budgetLineItem { get; set; }
        public List<GFRS_Funding_Allocation_Line_Item__c> assignedFundingAllocationToBudgetLineItem { get; set; }

        public BudgetHelper(Decimal liAmonut, GFRS_Administrative_Budget_Line_Item__c budgetItem, List<GFRS_Funding_Allocation_Line_Item__c> lineItemList, Boolean haveLI) {
            this.totalAllocated = liAmonut;
            this.budgetLineItem = budgetItem;
            this.amountUnlocated = budgetLineItem.Planned_Allocation__c - this.totalAllocated;
            this.assignedFundingAllocationToBudgetLineItem = lineItemList;
            this.haveAllocationLineItem = haveLI;
        }
    }

    /*
    @author ADMD Team
    @date 2013-07-15
    @description summaryOfBudgetLineItems - helper class used to get total Allocated, Planned Allocation, and UnAllocated funds under selected budget.
    */
    public class SummaryOfBudgetLineItems {
        public Decimal totalPlanned { get; set; }
        public Decimal totalAllocated { get; set; }
        public Decimal totaUnallocated { get; set; }

        /*
        @author ADMD Team
        @date 2013-07-15    
        @description
        */
        public SummaryOfBudgetLineItems(List<BudgetHelper> budgetLIinSelectedBudget) {
            totalPlanned = 0;
            totalAllocated = 0;
            totaUnallocated = 0;
            for (BudgetHelper item : budgetLIinSelectedBudget) {
                this.totalPlanned += item.budgetLineItem.Planned_Allocation__c;
                this.totalAllocated += item.totalAllocated;
                this.totaUnallocated += item.amountUnlocated;
            }
        }
    }
}