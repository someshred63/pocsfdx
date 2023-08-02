public class gFRS_Ltng_AdministrativeBudgetController {
    
    public static FinalReturnWrapperClass budgetRecordList { get; set; }
    public static string selectedBudgetNameVal { get; set; }
    public static Map<String, GFRS_Administrative_Budget_Line_Item__c> budgetLI_MapDupe { get; set; }
    public static Map<String, BudgetHelper> budgetHelperListDupe { get; set; }
    public static SummaryOfBudgetLineItems budgetSummary { get; set; }
    
    public gFRS_Ltng_AdministrativeBudgetController() {
        
        if (ApexPages.currentPage().getParameters().containsKey('id')) {
            string selectedBudget = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
            system.debug('@@@ selectedBudget : '+selectedBudget);
            generateReport(selectedBudget);
        } else {
            system.debug('@@@ Null : ');
            // do nothing
        }
    }
    
    @AuraEnabled
    public static List<GFRS_Administrative_Budget__c> getAvailableAmdmnistrativeBudgets() {
        
        List<GFRS_Administrative_Budget__c> budgets = new List<GFRS_Administrative_Budget__c>();
        budgets = [SELECT Name,Id,SYS_Fiscal_Year__c FROM GFRS_Administrative_Budget__c ORDER BY SYS_Fiscal_Year__c ASC];
        
        return budgets;
        
    }
    
    @AuraEnabled
    public static FinalReturnWrapperClass generateReport(string selectedBudgetId) {
        
        Date selectedBudgetFiscalYear = null;
        String delimiter = '-';
        String key = null, budgetType = null, recordTypeName = null;
        String [] associatedFundingTypesForBudgetType;
        Map<String, BudgetHelper> budgetHelperList =new Map<String, BudgetHelper>();
        Map<String, GFRS_Administrative_Budget_Line_Item__c> budgetLI_Map =new Map<String, GFRS_Administrative_Budget_Line_Item__c>();
        Boolean isFirstLoopIteration = true;
        string selectedBudgetName;
        
        //this.budgetSummary = new SummaryOfBudgetLineItems(getBudgetHelperList());
        FinalReturnWrapperClass flWrapper=new FinalReturnWrapperClass();
        
        selectedBudgetFiscalYear = [SELECT Fiscal_Year__c FROM GFRS_Administrative_Budget__c WHERE Id = :selectedBudgetId][0].Fiscal_Year__c;
        
        for (GFRS_Administrative_Budget_Line_Item__c objAdminBudgetLi : [
            SELECT Id, Name,WBS_Code__c,WBS_Description__c, Administrative_Budget__r.Name, Administrative_Budget__r.RecordType.Name, 
            Cost_Center__c,Administrative_Budget__r.Fiscal_Year__c,Planned_Allocation__c FROM GFRS_Administrative_Budget_Line_Item__c
            WHERE Administrative_Budget__r.Id = :selectedBudgetId]) 
        {
            if (isFirstLoopIteration) {
                selectedBudgetName = objAdminBudgetLi.Administrative_Budget__r.Name;  
                selectedBudgetNameVal = objAdminBudgetLi.Administrative_Budget__r.Name;  
                if (objAdminBudgetLi.Administrative_Budget__r.RecordType.Name == 'CAPP') {
                    associatedFundingTypesForBudgetType = new String[]{
                        'Community Giving', 'Education Focused Giving Graduate and Post-Graduate', 'Education Focused Giving K-12', 'Patient and Health Focused Giving', 'Scientific and Research Focused Giving'
                            };
                                } else if (objAdminBudgetLi.Administrative_Budget__r.RecordType.Name == 'DEV') {
                                    associatedFundingTypesForBudgetType = new String[]{
                                    };
                                        } else if (objAdminBudgetLi.Administrative_Budget__r.RecordType.Name == 'IMED') {
                                            associatedFundingTypesForBudgetType = new String[]{
                                                'Independent Medical Education (CME)'
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
        budgetLI_MapDupe = budgetLI_Map;
        system.debug('associatedFundingTypesForBudgetType'+associatedFundingTypesForBudgetType);
        if (associatedFundingTypesForBudgetType != null) {
            for (gFRS_Ltng_Funding_Allocation_Line_Item__c allocationLI : [
                SELECT Name, Id, WBS_Code__r.WBS__c,WBS_Description__c,
                gFRS_Funding_Allocation__r.gFRS_Application__c,
                gFRS_Funding_Allocation__r.gFRS_Application__r.Name,
                Percent__c,
                gFRS_Funding_Allocation__r.gFRS_Application__r.Record_Type__c,gFRS_Funding_Allocation__r.gFRS_Application__r.Decision_Date__c,
                gFRS_Funding_Allocation__r.RecordType.Name,
                gFRS_Funding_Allocation__r.Refund_Amount__c,
                Cost_Center_Code__r.Cost_Center__c, Line_Item_Total__c
                FROM gFRS_Ltng_Funding_Allocation_Line_Item__c
                
                WHERE gFRS_Funding_Allocation__r.gFRS_Application__r.Status__c != 'Intake'
                AND gFRS_Funding_Allocation__r.gFRS_Application__r.Status__c != 'Compliance'
                AND gFRS_Funding_Allocation__r.gFRS_Application__r.Status__c != 'RFI'
                AND gFRS_Funding_Allocation__r.gFRS_Application__r.Status__c != 'Decision'
                AND gFRS_Funding_Allocation__r.RecordType.Name IN ('Payment', 'Refund')
                AND CALENDAR_YEAR(gFRS_Funding_Allocation__r.gFRS_Application__r.Decision_Date__c) = :selectedBudgetFiscalYear.year()
                AND gFRS_Funding_Allocation__r.gFRS_Application__r.Record_Type__c IN :associatedFundingTypesForBudgetType
            ]) {
                budgetType = '';
                recordTypeName = allocationLI.gFRS_Funding_Allocation__r.gFRS_Application__r.Record_Type__c;
                if (recordTypeName != null) {
                    if (recordTypeName == 'Independent Medical Education (CME)') {
                            budgetType = gFRS_Util.BUDGET_RT_IMED;
                        } else if (recordTypeName == 'Community Giving' || recordTypeName == 'Education Focused Giving Graduate and Post-Graduate' || recordTypeName == 'Education Focused Giving K-12' || recordTypeName == 'Patient and Health Focused Giving' || recordTypeName == 'Scientific and Research Focused Giving') {
                            budgetType = gFRS_Util.BUDGET_RT_CAPP;
                        } else {
                            //-- do nothing
                            System.debug('unknow Funding Record Type:' + recordTypeName);
                        }
                }     
                if (allocationLI.gFRS_Funding_Allocation__r != null && allocationLI.gFRS_Funding_Allocation__r.gFRS_Application__r != null && allocationLI.gFRS_Funding_Allocation__r.gFRS_Application__r.Decision_Date__c != null) {
                    key = String.valueOf(allocationLI.gFRS_Funding_Allocation__r.gFRS_Application__r.Decision_Date__c.year()) + budgetType + delimiter + allocationLI.WBS_Code__r.WBS__c + delimiter + allocationLI.Cost_Center_Code__r.Cost_Center__c;
                } else {
                    
                    key = budgetType + delimiter + allocationLI.WBS_Code__r.WBS__c + delimiter + allocationLI.Cost_Center_Code__r.Cost_Center__c;
                }
                if (budgetLI_Map.containsKey(key)) {
                    if (budgetHelperList.containsKey(key)) {
                        
                        BudgetHelper tmpItem = budgetHelperList.get(key);
                        tmpItem.assignedFundingAllocationToBudgetLineItem.add(allocationLI);
                        if (allocationLI.gFRS_Funding_Allocation__r.RecordType.Name == 'Refund') {
                            tmpItem.totalAllocated -= allocationLI.Line_Item_Total__c ;
                            tmpItem.amountUnlocated += allocationLI.Line_Item_Total__c;
                        } else {
                            tmpItem.totalAllocated += allocationLI.Line_Item_Total__c;
                            tmpItem.amountUnlocated -= allocationLI.Line_Item_Total__c;
                        }
                        
                    } else {
                        budgetHelperList.put(key, new BudgetHelper(allocationLI.Line_Item_Total__c, budgetLI_Map.get(key), new gFRS_Ltng_Funding_Allocation_Line_Item__c[]{
                            allocationLI
                                }, true));
                        
                        flWrapper.budgetHelperList=budgetHelperList;
                        // flWrapper.budgetLI_Map= budgetLI_Map.get(key);
                    }
                } 
            }
            
        }
        
        if(flWrapper.budgetHelperList == null){
            for (String keyVal : budgetLI_Map.keySet()) {
                if (!budgetHelperList.containsKey(keyVal)) {
                    budgetHelperList.put(keyVal, new BudgetHelper(0, budgetLI_Map.get(keyVal), null, false));
                }
                  
            }
            flWrapper.budgetHelperList=budgetHelperList;
        }
        
        SummaryOfBudgetLineItems budgetSummary = new SummaryOfBudgetLineItems(getBudgetHelperList(budgetLI_Map, budgetHelperList));
        flWrapper.budgetSummary = budgetSummary;
        budgetRecordList = flWrapper;
        budgetHelperListDupe = budgetHelperList;
        return flWrapper;
        
    }
    
    public static List<BudgetHelper> getBudgetHelperList(Map<String, GFRS_Administrative_Budget_Line_Item__c> budgetLI_Map, Map<String, BudgetHelper> budgetHelperList) {
        
        for (String key : budgetLI_Map.keySet()) {
            if (!budgetHelperList.containsKey(key)) {
                budgetHelperList.put(key, new BudgetHelper(0, budgetLI_Map.get(key), null, false));
            }
        }
        return budgetHelperList.values();
    }
    
    public class BudgetHelper {
        @AuraEnabled
        public Decimal totalAllocated { get; set; }
        @AuraEnabled
        public Id adminBdgLineItemId { get; set; }
        @AuraEnabled
        public Decimal amountUnlocated { get; set; }
        @AuraEnabled
        public Boolean haveAllocationLineItem { get; set; }
        @AuraEnabled
        public GFRS_Administrative_Budget_Line_Item__c budgetLineItem { get; set; }
        @AuraEnabled
        public List<gFRS_Ltng_Funding_Allocation_Line_Item__c> assignedFundingAllocationToBudgetLineItem { get; set; }
        
        public BudgetHelper(Decimal liAmonut, GFRS_Administrative_Budget_Line_Item__c budgetItem, List<gFRS_Ltng_Funding_Allocation_Line_Item__c> lineItemList, Boolean haveLI) {
            
            
            this.totalAllocated = liAmonut;
            this.adminBdgLineItemId = budgetItem.Id;
            system.debug('1'+totalAllocated);
            
            this.budgetLineItem = budgetItem;
            this.amountUnlocated = budgetLineItem.Planned_Allocation__c - this.totalAllocated;
            this.assignedFundingAllocationToBudgetLineItem = lineItemList;
            this.haveAllocationLineItem = haveLI;
        }
    }
    public class SummaryOfBudgetLineItems {
        @AuraEnabled
        public Decimal totalPlanned { get; set; }
        @AuraEnabled
        public Decimal totalAllocated { get; set; }
        @AuraEnabled
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
    public class FinalReturnWrapperClass {
        @AuraEnabled
        public  Map<String, BudgetHelper> budgetHelperList {get; set;}
        @AuraEnabled
        public SummaryOfBudgetLineItems budgetSummary { get; set; }
        @AuraEnabled
        public List<gFRS_Ltng_Funding_Allocation_Line_Item__c> budgetLineItemList { get; set; }
        @AuraEnabled
        public Map<String, GFRS_Administrative_Budget_Line_Item__c> budgetLI_Map { get; set; }
        
    }
    
    public class BudgetListItem {
        @AuraEnabled
        public Decimal totalAllocated;
        @AuraEnabled
        public Decimal plannedAllocation;
        @AuraEnabled
        public String allocationName;
        
        public BudgetListItem(Decimal totalAllocated, Decimal plannedAllocation, String allocationName) {
            this.totalAllocated = totalAllocated;
            this.plannedAllocation = plannedAllocation;
            this.allocationName = allocationName;
        }
    }
    
    @AuraEnabled
    public static void exportToExcel(string selectedBudgetId) {
        try{
            //ApexPages.currentPage().getParameters().put('id', selectedBudgetId);
            PageReference pageRefToReturn = Page.gFRS_Ltng_AdministrativeBudgetExcel;
            pageRefToReturn.setRedirect(false);
        }
        catch(Exception e){

            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
}