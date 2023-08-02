public with sharing class Budget_Allocation_Chart_Controller {
    public String costCenterName { get; set; }
    public String level { get; set; }
    public String budgetId { get; set; }
    public String budgetName { get; set; }
    public List<SelectOption> availableBudgets { get; set; }
    public List<SelectOption> availableCostCenters { get; set; }
    public String chartJsonData { get; set; }
    public String tableJsonData { get; set; }
    
    private Map<String, List<EMS_Budget_Allocation_gne__c>> budgetAllocations = new Map<String, List<EMS_Budget_Allocation_gne__c>>();
    private Map<Id, EMS_Budget_Product_gne__c> productBudgetsMap = new Map<Id, EMS_Budget_Product_gne__c>();
    private Map<Id, EMS_Budget_Region_gne__c> regionBudgetsMap = new Map<Id, EMS_Budget_Region_gne__c>();
    private Map<Id, EMS_Budget_Territory_gne__c> territoryBudgetsMap = new Map<Id, EMS_Budget_Territory_gne__c>();
    
    public Budget_Allocation_Chart_Controller() {
        level = 'National';
        availableCostCenters = loadAvailableCostCenters();
        if(!availableCostCenters.isEmpty()) {
            costCenterName = availableCostCenters[0].getValue();
        } else {
            costCenterName = '';
        }
        
        loadBudgetsData();
        
        availableBudgets = loadAvailableBudgets();
        if(!availableBudgets.isEmpty()) {
            budgetId = availableBudgets[0].getValue();
        } else {
            budgetId = '';
        }
        setBudgetName();
        
        List<BudgetAllocationWrapper> chartData = loadChartData();
        chartJsonData = getChartData(chartData);
        tableJsonData = getTableData(chartData);
    }
    
    private void loadBudgetsData() {
        productBudgetsMap.clear();
        regionBudgetsMap.clear();
        territoryBudgetsMap.clear();
        
        for(EMS_Budget_Product_gne__c pb : [ SELECT Id, Name, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Cost_Center_gne__r.Name = :costCenterName AND Year_gne__c = :String.valueOf(Date.today().year()) ]) {
            productBudgetsMap.put(pb.Id, pb);
        }
        for(EMS_Budget_Region_gne__c rb : [ SELECT Id, Name, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Cost_Center_gne__c = :costCenterName AND Year_gne__c = :String.valueOf(Date.today().year()) ]) {
            regionBudgetsMap.put(rb.Id, rb);
        }
        for(EMS_Budget_Territory_gne__c tb : [ SELECT Id, Name, Territory_Balance_gne__c FROM EMS_Budget_Territory_gne__c WHERE Cost_Center_gne__c = :costCenterName AND Year_gne__c = :String.valueOf(Date.today().year()) ]) {
            territoryBudgetsMap.put(tb.Id, tb);
        }
    }
    
    private void setBudgetName() {
        if(String.isNotEmpty(budgetId)) {
            if(productBudgetsMap.get(budgetId) != null) {
                budgetName = productBudgetsMap.get(budgetId).Name;
            } else if(regionBudgetsMap.get(budgetId) != null) {
                budgetName = regionBudgetsMap.get(budgetId).Name;
            } else if(territoryBudgetsMap.get(budgetId) != null) {
                budgetName = territoryBudgetsMap.get(budgetId).Name;
            }
        } else {
            budgetName = '';
        }
    }
    
    public List<SelectOption> loadAvailableCostCenters() {
        List<SelectOption> result = new List<SelectOption>();
        for(EMS_Cost_Center_gne__c cc : [ SELECT Name, Product_Indication_Department_gne__c FROM EMS_Cost_Center_gne__c ]) {
            result.add(new SelectOption(cc.Name, cc.Name + ' - ' + cc.Product_Indication_Department_gne__c));
        }
        return result;
    }
    
    public List<SelectOption> loadAvailableBudgets() {
        List<SelectOption> result = new List<SelectOption>();
        
        if(level == 'National') {
            for(EMS_Budget_Product_gne__c pb : productBudgetsMap.values()) {
                result.add(new SelectOption(pb.Id, pb.Name));
            }
        } else if(level == 'Region') {
            for(EMS_Budget_Region_gne__c rb : regionBudgetsMap.values()) {
                result.add(new SelectOption(rb.Id, rb.Name));
            }
        } else if(level == 'Territory') {
            for(EMS_Budget_Territory_gne__c tb : territoryBudgetsMap.values()) {
                result.add(new SelectOption(tb.Id, tb.Name));
            }
        }
        if(result.isEmpty()) {
            result.add(new SelectOption('', '---None--'));
        }
        return result;
    }
    
    public PageReference refreshBudgetsList() {
        loadBudgetsData();
        availableBudgets = loadAvailableBudgets();
        if(!availableBudgets.isEmpty()) {
            budgetId = availableBudgets[0].getValue();
        } else {
            budgetId = '';
        }
        setBudgetName();
        List<BudgetAllocationWrapper> chartData = loadChartData();
        chartJsonData = getChartData(chartData);
        tableJsonData = getTableData(chartData);
        return null;
    }
    
    public PageReference refreshChart() {
        List<BudgetAllocationWrapper> chartData = loadChartData();
        setBudgetName();
        chartJsonData = getChartData(chartData);
        tableJsonData = getTableData(chartData);
        return null;
    }
    
    public List<BudgetAllocationWrapper> loadChartData() { 
        List<BudgetAllocationWrapper> result;
        /*if(String.isNotEmpty(budgetId)) {
            result = new List<BudgetAllocationWrapper>();
            budgetAllocations.clear();
            for(EMS_Budget_Allocation_gne__c ba : [ SELECT Budget_Name_gne__c, Budget_Deductions_gne__c, Percentage_Contribution_gne__c, Budget_Id_gne__c, Allocated_Budget_gne__c, EMS_Event_gne__r.Total_Budget_Allocated_gne__c, EMS_Event_gne__r.Total_Commited_gne__c/*, EMS_Event_gne__r.Total_Expenses_gne__c* FROM EMS_Budget_Allocation_gne__c WHERE Budget_Id_gne__c = :budgetId.left(15) ]) {
                    if(budgetAllocations.get(ba.Budget_Id_gne__c) == null) {
                        budgetAllocations.put(ba.Budget_Id_gne__c, new List<EMS_Budget_Allocation_gne__c>());
                    }
                    budgetAllocations.get(ba.Budget_Id_gne__c).add(ba);
                }
            
            Decimal actual = 0;
            Decimal commited = 0;
            Decimal planned = 0;
            
            if(budgetAllocations.size() > 0) {
                for(String budgetId : budgetAllocations.keySet()) {
                    for(EMS_Budget_Allocation_gne__c ba : budgetAllocations.get(budgetId)) {
                        actual += ba.Budget_Deductions_gne__c;
                        commited += (ba.EMS_Event_gne__r.Total_Commited_gne__c * ba.Percentage_Contribution_gne__c);
                        planned += ba.Allocated_Budget_gne__c;
                    }
                    result.add(createBudgetAllocationWrapper(budgetId, actual, commited, planned));
                    actual = 0;
                    commited = 0;
                    planned = 0;
                }
            } else {
                result.add(createBudgetAllocationWrapper(budgetId, 0, 0, 0));
            }
        }*/
        return result;
    }
    
    // method used to convert absolute values to percentage and creation of budget allocation wrappers
    private BudgetAllocationWrapper createBudgetAllocationWrapper(String budgetId, Decimal actual, Decimal commited, Decimal planned) {
        BudgetAllocationWrapper result;
        Decimal unallocated;
        Decimal actualPercentage;
        Decimal commitedPercentage;
        Decimal plannedPercentage;
        Decimal unallocatedPercentage;
        
        if(String.isNotEmpty(budgetId)) {
            if(productBudgetsMap.get(budgetId) != null) {
                unallocated = productBudgetsMap.get(budgetId).Product_Balance_gne__c - actual - commited - planned;
                if(unallocated < 0) {
                    unallocated = productBudgetsMap.get(budgetId).Product_Balance_gne__c;
                }
                if(unallocated != 0) {
                    actualPercentage = actual / unallocated;
                    commitedPercentage = commited / unallocated;
                    plannedPercentage = planned / unallocated;
                    unallocatedPercentage = 1 - actualPercentage - commitedPercentage - plannedPercentage;
                } else {
                    actualPercentage = 0;
                    commitedPercentage = 0;
                    plannedPercentage = 0;
                    unallocatedPercentage = 0; 
                }
                
                if(unallocatedPercentage < 0) {
                    unallocatedPercentage = 0;
                }
                
                result = new BudgetAllocationWrapper(productBudgetsMap.get(budgetId).Name, productBudgetsMap.get(budgetId).Product_Balance_gne__c, actualPercentage, commitedPercentage, plannedPercentage, unallocatedPercentage);
            } else if(regionBudgetsMap.get(budgetId) != null) {
                unallocated = regionBudgetsMap.get(budgetId).Region_Balance_gne__c - actual - commited - planned;
                if(unallocated < 0) {
                    unallocated = regionBudgetsMap.get(budgetId).Region_Balance_gne__c;
                }
                if(unallocated != 0) {
                    actualPercentage = actual / unallocated;
                    commitedPercentage = commited / unallocated;
                    plannedPercentage = planned / unallocated;
                    unallocatedPercentage = 1 - actualPercentage - commitedPercentage - plannedPercentage;
                } else {
                    actualPercentage = 0;
                    commitedPercentage = 0;
                    plannedPercentage = 0;
                    unallocatedPercentage = 0; 
                }
                if(unallocatedPercentage < 0) {
                    unallocatedPercentage = 0;
                }
                
                result = new BudgetAllocationWrapper(regionBudgetsMap.get(budgetId).Name, regionBudgetsMap.get(budgetId).Region_Balance_gne__c, actualPercentage, commitedPercentage, plannedPercentage, unallocatedPercentage);
            } else if(territoryBudgetsMap.get(budgetId) != null) {
                unallocated = territoryBudgetsMap.get(budgetId).Territory_Balance_gne__c - actual - commited - planned;
                if(unallocated < 0) {
                    unallocated = territoryBudgetsMap.get(budgetId).Territory_Balance_gne__c;
                }
                if(unallocated != 0) {
                    actualPercentage = actual / unallocated;
                    commitedPercentage = commited / unallocated;
                    plannedPercentage = planned / unallocated;
                    unallocatedPercentage = 1 - actualPercentage - commitedPercentage - plannedPercentage;
                } else {
                    actualPercentage = 0;
                    commitedPercentage = 0;
                    plannedPercentage = 0;
                    unallocatedPercentage = 0; 
                }
                if(unallocatedPercentage < 0) {
                    unallocatedPercentage = 0;
                }
                
                result = new BudgetAllocationWrapper(territoryBudgetsMap.get(budgetId).Name, territoryBudgetsMap.get(budgetId).Territory_Balance_gne__c, actualPercentage, commitedPercentage, plannedPercentage, unallocatedPercentage);
            }
        }
        return result;
    }
    
    // Wrapper class
    public class BudgetAllocationWrapper {

        public String budgetName { get; set; }
        public Decimal actual { get; set; }
        public String actualTooltip { get {
                return 'Actual: $' + EMS_Util.currency(actual * budgetBalance); 
            } set; }
            
        public Decimal committed { get; set; }
        public String committedTooltip { get {          
                return 'Committed: $' + EMS_Util.currency(committed * budgetBalance);
            } set; }
            
        public Decimal planned { get; set; }
        public String plannedTooltip { get {                
                return 'Planned: $' + EMS_Util.currency(planned * budgetBalance); 
            } set; }
            
        public Decimal unallocated { get; set; }     
        public String unallocatedTooltip { get {
                return 'Unalllocated: $' + EMS_Util.currency(unallocated * budgetBalance); 
            } set; }
            
        public String budgetBalanceTooltip { get {
            return budgetName + ': $'+EMS_Util.currency(budgetBalance);
        } set;}
        
        public Decimal budgetBalance { get; set; }

        public BudgetAllocationWrapper(String budgetName, Decimal budgetBalance, Decimal actual, Decimal committed, Decimal planned, Decimal unallocated) {
            this.budgetName = budgetName;
            this.budgetBalance = budgetBalance;
            this.actual = actual;
            this.committed = committed;
            this.planned = planned;
            this.unallocated = unallocated;
        }
    }
    
    private String getChartData(List<BudgetAllocationWrapper> chartData) {
        String result = '[ ';
        if(chartData != null) {
            for(BudgetAllocationWrapper baWrapper : chartData){
                result += '[ ';
                result += '\'' + baWrapper.budgetName + '\', ';
                result += baWrapper.actual + ', \'' +  + baWrapper.actualTooltip + '\', ';
                result += baWrapper.committed + ', \'' +  + baWrapper.committedTooltip + '\', ';
                result += baWrapper.planned + ', \'' +  + baWrapper.plannedTooltip + '\', ';            
                result += baWrapper.unallocated + ', \'' +  + baWrapper.unallocatedTooltip + '\', ';
                result += '1, 1, \'' +  baWrapper.budgetBalanceTooltip + '\'';
                result += ' ]';
            }
        }
        result += ' ]';
        return result;
    }
    
    private String getTableData(List<BudgetAllocationWrapper> chartData) {
        String result = '[ ';
        if(chartData != null) {
            for(BudgetAllocationWrapper baWrapper : chartData){
                Decimal actual = baWrapper.actual * baWrapper.budgetBalance;
                Decimal committed = baWrapper.committed * baWrapper.budgetBalance;
                Decimal planned = baWrapper.planned * baWrapper.budgetBalance;
                Decimal unallocated = baWrapper.unallocated * baWrapper.budgetBalance;
                
                result += '[ \'Actual\', ' + actual + ', ' + actual + ', ' + baWrapper.actual + ' ], ';
                result += '[ \'Commited\', ' + committed + ', ' + (actual+committed) + ', ' + (baWrapper.actual+baWrapper.committed) + ' ], ';
                result += '[ \'Planned\', ' + planned + ', ' + (actual+committed+planned) + ', ' + (baWrapper.actual+baWrapper.committed+baWrapper.planned) + ' ], ';
                result += '[ \'Unallocated\', ' + unallocated + ', ' + (actual+committed+planned+unallocated) + ', ' + (baWrapper.actual+baWrapper.committed+baWrapper.planned+baWrapper.unallocated) + ' ]';
            }
        }
        result += ' ]';
        return result;
    }
}