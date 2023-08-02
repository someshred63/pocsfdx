public without sharing class EMS_Budget_Allocation_Controller extends EMS_Table_With_Pagination_Base {
    public List<String> costCenterTypeFilter { get; set; }

    public static String BALANCE_OK = 'green';
    public static String BALANCE_FAIL = 'red';

    public EMS_WrapperList allBudgets { get; set; }
    public EMS_WrapperList myBudgets { get; set; }
    public Map<Id, BudgetAllocationWrapper> budgetAllocations { get; set; }
    public EMS_Budget_Allocation_Controller thisController { get; set; }
    public Boolean costCenterTypeLocked { get; set; }
    public EMS_Event__c event { get; set; }
    public Set<Id> selectedBudgets = new Set<Id>();

    public Id budgetId { get; set; }
    private Id eventId ;
    private String retURL;
    private List<EMS_Possible_Budget_Allocation_gne__c> possibleBAllocations;

    private String budgetType;

    private Map<String, RecordType> budgetAllocationRecordTypes = new Map<String, RecordType>();
    private Map<Id, EMS_Cost_Center_gne__c> costCentersMap = new Map<Id, EMS_Cost_Center_gne__c>([SELECT Id, Name FROM EMS_Cost_Center_gne__c]);

    public enum Budget_Allocation_Type {
        PRODUCT, REGION, TERRITORY
    }

    List<String> budgetFieldNames = new List<String>{
            'budgetName',
            'indication',
            'costCenter',
            'costCenterType',
            'assignedTo',
            'assignedToTerritory',
            'fundStatus'
    };

    private List<String> indicationFilter {
        get {
            return picklistFilterMap.get('indication');
        }
    }

    private List<String> centerTypeFilter {
        get {
            return picklistFilterMap.get('costCenterType');
        }
    }

    private List<String> territoryFilter {
        get {
            return picklistFilterMap.get('assignedToTerritory');
        }
    }


    public EMS_Budget_Allocation_Controller() {
        thisController = this;
        allBudgets = new EMS_WrapperList();
        allBudgets.objectList = new List<BudgetWrapper>();
        myBudgets = new EMS_WrapperList();
        myBudgets.objectList = new List<BudgetWrapper>();
        costCenterTypeFilter = new List<String>();

        initializeFilters(budgetFieldNames);

        if (System.currentPagereference().getParameters().get('objectid') != null) {
            eventId = System.currentPagereference().getParameters().get('objectid');
        }
        if (System.currentPagereference().getParameters().get('retURL') != null) {
            retURL = System.currentPagereference().getParameters().get('retURL');
        }
        if (eventId != null) {
            event = [SELECT Name, Start_Date_gne__c, End_Date_gne__c, Event_Type_gne__c, Event_Sub_Type_gne__c, Planned_Expenses_gne__c, Total_Budget_Allocated_gne__c, Event_Owner_gne__r.Name, Event_Requestor_gne__r.Name FROM EMS_Event__c WHERE id = :eventId];
        }
        if (event != null) {
            for (EMS_Possible_Budget_Allocation_gne__c pba : [
                    SELECT Budget_Type_gne__r.Name
                    FROM EMS_Possible_Budget_Allocation_gne__c
                    WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :event.Event_Type_gne__c
                    AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
            ]) {
                costCenterTypeFilter.add(pba.Budget_Type_gne__r.Name);
            }

            fetchMyBudgets();
            fetchAllBudgets();
            fetchBudgetAllocations();
        }
        for (RecordType rt : [SELECT Id, Name, DeveloperName, SObjectType FROM RecordType WHERE SObjectType = 'EMS_Budget_Allocation_gne__c']) {
            budgetAllocationRecordTypes.put(rt.DeveloperName, rt);
        }
    }

    public Map<Id, EMS_Cost_Center_gne__c> getCostCentersMap() {
        return costCentersMap;
    }

    public List<BudgetAllocationWrapper> getBudgetAllocationList() {
        List<BudgetAllocationWrapper> result = new List<BudgetAllocationWrapper>();
        if (budgetAllocations != null) {
            result = budgetAllocations.values();
            result.sort();
        }
        return result;
    }

    private void refreshEventInfo() {
        if (eventId != null) {
            event = [Select Name, Start_Date_gne__c, End_Date_gne__c, Event_Type_gne__c, Event_Sub_Type_gne__c, Planned_Expenses_gne__c, Total_Budget_Allocated_gne__c from EMS_Event__c where id = :eventId];
        }
    }

    private void fetchBudgetAllocations() {
        if (budgetAllocations == null) {
            budgetAllocations = new Map<Id, BudgetAllocationWrapper>();
        }
        if (eventId != null) {
            for (EMS_Budget_Allocation_gne__c budgetAllocation : [
                    SELECT Id, Name, Cost_Center_gne__c, Cost_Center_Type_gne__c, Product_Indication_gne__c, Allocated_Budget_gne__c, Percentage_Contribution_gne__c,
                            EMS_Product_Budget_gne__c, EMS_Region_Budget_gne__c, EMS_Territory_Budget_gne__c, EMS_Product_Budget_gne__r.Name, EMS_Product_Budget_gne__r.Product_Balance_gne__c, EMS_Region_Budget_gne__r.Name, EMS_Region_Budget_gne__r.Region_Balance_gne__c, EMS_Territory_Budget_gne__r.Name, EMS_Territory_Budget_gne__r.Territory_Balance_gne__c
                    FROM EMS_Budget_Allocation_gne__c
                    WHERE EMS_Event_gne__c = :eventId
            ]) {
                Id budgetId;
                String budgetName;
                Budget_Allocation_Type budgetType;
                Decimal budgetFunds = budgetAllocation.Allocated_Budget_gne__c;
                if (budgetAllocation.EMS_Product_Budget_gne__c != null) {
                    budgetId = budgetAllocation.EMS_Product_Budget_gne__c;
                    budgetName = budgetAllocation.EMS_Product_Budget_gne__r.Name;
                    budgetType = Budget_Allocation_Type.PRODUCT;
                    budgetFunds += budgetAllocation.EMS_Product_Budget_gne__r.Product_Balance_gne__c;
                }
                if (budgetAllocation.EMS_Region_Budget_gne__c != null) {
                    budgetId = budgetAllocation.EMS_Region_Budget_gne__c;
                    budgetName = budgetAllocation.EMS_Region_Budget_gne__r.Name;
                    budgetType = Budget_Allocation_Type.REGION;
                    budgetFunds += budgetAllocation.EMS_Region_Budget_gne__r.Region_Balance_gne__c;
                }
                if (budgetAllocation.EMS_Territory_Budget_gne__c != null) {
                    budgetId = budgetAllocation.EMS_Territory_Budget_gne__c;
                    budgetName = budgetAllocation.EMS_Territory_Budget_gne__r.Name;
                    budgetType = Budget_Allocation_Type.TERRITORY;
                    budgetFunds += budgetAllocation.EMS_Territory_Budget_gne__r.Territory_Balance_gne__c;
                }

                budgetAllocations.put(budgetId, new BudgetAllocationWrapper(budgetName, budgetId, budgetType, budgetAllocation.Product_Indication_gne__c, budgetAllocation.Cost_Center_gne__c, budgetAllocation.Cost_Center_Type_gne__c, budgetAllocation.Allocated_Budget_gne__c, budgetAllocation.Percentage_Contribution_gne__c, budgetFunds, true, budgetAllocation));
            }
        }
    }

    private void fetchMyBudgets() {
        List<EMS_Budget_Product_gne__c> myProductBudgets = queryMyProductBudgets();
        List<EMS_Budget_Region_gne__c> myRegionBudgets = queryMyRegionBudgets();
        List<EMS_Budget_Territory_gne__c> myTerritoryBudgets = queryMyTerritoryBudgets();

        buildBudgetWrapperLists(myBudgets, myProductBudgets, myRegionBudgets, myTerritoryBudgets);
    }

    private void fetchAllBudgets() {
        List<EMS_Budget_Product_gne__c> productBudgets = queryProductBudgets();
        List<EMS_Budget_Region_gne__c> regionBudgets = queryRegionBudgets();
        List<EMS_Budget_Territory_gne__c> territoryBudgets = queryTerritoryBudgets();

        buildBudgetWrapperLists(allBudgets, productBudgets, regionBudgets, territoryBudgets);

        clearPicklistValues();

        for (BudgetWrapper bw : (List<BudgetWrapper>) allBudgets.objectList) {
            addPicklistFilterValue('indication', bw.indication);
            addPicklistFilterValue('costCenterType', bw.costCenterType);
            addPicklistFilterValue('assignedToTerritory', bw.assignedToTerritory);
            addPicklistFilterValue('fundStatus', bw.fundStatus);
        }
    }

    public List<SelectOption> getCostCenterTypes() {
        List<SelectOption> options = new List<SelectOption>();
        for (EMS_Cost_Center_Type_gne__c costCenterType : [SELECT Name FROM EMS_Cost_Center_Type_gne__c]) {
            options.add(new SelectOption(costCenterType.Name, costCenterType.Name));
        }
        return options;
    }

    private void addBudgetAllocation(BudgetWrapper wrapper) {
        EMS_Budget_Allocation_gne__c budgetAllocation;
        Id budgetId;
        if (wrapper.budgetProduct != null) {
            budgetId = wrapper.budgetProduct.Id;
        }
        if (wrapper.budgetRegion != null) {
            budgetId = wrapper.budgetRegion.Id;
        }
        if (wrapper.budgetTerritory != null) {
            budgetId = wrapper.budgetTerritory.Id;
        }
        if (!budgetAllocations.containsKey(budgetId)) {
            budgetAllocation = new EMS_Budget_Allocation_gne__c(EMS_Event_gne__c = eventId, Percentage_Contribution_gne__c = 0, Allocated_Budget_gne__c = 0);
            Budget_Allocation_Type budgetType;
            Decimal budgetFunds;
            if (wrapper.budgetProduct != null) {
                budgetAllocation.EMS_Product_Budget_gne__c = wrapper.budgetProduct.Id;
                budgetType = Budget_Allocation_Type.PRODUCT;
                budgetFunds = wrapper.budgetProduct.Product_Balance_gne__c;
            }
            if (wrapper.budgetRegion != null) {
                budgetAllocation.EMS_Region_Budget_gne__c = wrapper.budgetRegion.Id;
                budgetType = Budget_Allocation_Type.REGION;
                budgetFunds = wrapper.budgetRegion.Region_Balance_gne__c;
            }
            if (wrapper.budgetTerritory != null) {
                budgetAllocation.EMS_Territory_Budget_gne__c = wrapper.budgetTerritory.Id;
                budgetType = Budget_Allocation_Type.TERRITORY;
                budgetFunds = wrapper.budgetTerritory.Territory_Balance_gne__c;
            }
            budgetAllocations.put(budgetId, new BudgetAllocationWrapper(wrapper.budgetName, budgetId, budgetType, wrapper.indication, wrapper.costCenter, wrapper.costCenterType, 0, 0, budgetFunds, false, budgetAllocation));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Budget ' + wrapper.budgetName + ' is already added'));
        }
    }

    public PageReference removeAllocation() {
        budgetAllocations.remove(budgetId);
        return null;
    }

    public override PageReference updateSelectedRecords() {

        for (EMS_Wrapper budget : myBudgets.objectList) {
            BudgetWrapper wrapper = (BudgetWrapper) budget;
            if (budget.selected != null && budget.selected) {
                // product selected - add budget allocation to map
                addBudgetAllocation(wrapper);
                budget.selected = false;
            }
        }

        for (EMS_Wrapper budget : allBudgets.objectList) {
            BudgetWrapper wrapper = (BudgetWrapper) budget;
            if (budget.selected != null && budget.selected) {
                // product selected
                addBudgetAllocation(wrapper);
                budget.selected = false;
            }
        }

        return null;
    }

    private Boolean validateBudgetAllocations(List<EMS_Budget_Allocation_gne__c> budgetAllocations) {
        Decimal allocatedAmount = 0;
        for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
            allocatedAmount += ba.Allocated_Budget_gne__c;
        }

        if (allocatedAmount > event.Planned_Expenses_gne__c) {
            return false;
        } else {
            return true;
        }
    }

    private Boolean saveBudgetAllocations() {
        Boolean isSuccess = true;
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsToUpsert = new List<EMS_Budget_Allocation_gne__c>();

        for (BudgetAllocationWrapper budget : budgetAllocations.values()) {
            EMS_Budget_Allocation_gne__c toInsert = budget.budgetAllocation;
            if (!budget.existingAllocation) {
                if (budget.budgetAllocationType == Budget_Allocation_Type.PRODUCT) {
                    toInsert.EMS_Product_Budget_gne__c = budget.budgetId;
                    toInsert.RecordTypeId = budgetAllocationRecordTypes.get('Product_Budget_Allocation').Id;
                } else if (budget.budgetAllocationType == Budget_Allocation_Type.REGION) {
                    toInsert.EMS_Region_Budget_gne__c = budget.budgetId;
                    toInsert.RecordTypeId = budgetAllocationRecordTypes.get('Region_Budget_Allocation').Id;
                } else if (budget.budgetAllocationType == Budget_Allocation_Type.TERRITORY) {
                    toInsert.EMS_Territory_Budget_gne__c = budget.budgetId;
                    toInsert.RecordTypeId = budgetAllocationRecordTypes.get('Territory_Budget_Allocation').Id;
                }
            }
            budgetAllocationsToUpsert.add(toInsert);
        }
        if (validateBudgetAllocations(budgetAllocationsToUpsert)) {

            if (budgetAllocationsToUpsert.size() > 0) {
                System.SavePoint sp = Database.setSavepoint();

                try {
                    EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
                    upsert budgetAllocationsToUpsert;
                    fetchBudgetAllocations();
                    refreshEventInfo();
                } catch (DMLException ex) {
                    Database.rollback(sp);
                    isSuccess = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getDmlMessage(0)));
                }
            }
        } else {
            isSuccess = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Allocated amount cannot be greater than Planned Expenses'));
        }
        return isSuccess;
    }

    public override PageReference applyFilters() {
        checkFilters(budgetFieldNames);
        fetchAllBudgets();
        return null;
    }

    public PageReference doSave() {
        saveBudgetAllocations();
        return null;
    }

    public PageReference doSaveAndReturn() {
        if (saveBudgetAllocations()) {
            if (retURL != null) {
                ApexPages.Pagereference pr = new Pagereference(retURL);
                pr.setRedirect(true);
                return pr;
            } else {
                ApexPages.Pagereference pr = Page.EMS_Home;
                pr.setRedirect(true);
                return pr;
            }
        } else {
            return null;
        }
    }

    public PageReference doCancel() {
        if (retURL != null) {
            ApexPages.Pagereference pr = new Pagereference(retURL);
            pr.setRedirect(true);
            return pr;
        } else {
            ApexPages.Pagereference pr = Page.EMS_Home;
            pr.setRedirect(true);
            return pr;
        }
    }

    private List<EMS_Budget_Product_gne__c> queryProductBudgets() {
        String queryString = 'Select Id,Name,Product_Indication_gne__c,Cost_Center_gne__r.Name,Cost_Center_Type_gne__c,Assigned_To_gne__r.Name, ' +
                +'Product_Balance_gne__c, Budget_State_gne__c, Assigned_To_Territory_gne__c from EMS_Budget_Product_gne__c WHERE ';

        List<String> conditions = new List<String>{
                'Status_gne__c = \'Active\''
        };

        if (String.isNotBlank(filterMap.get('budgetName'))) {
            conditions.add('Name LIKE \'%' + filterMap.get('budgetName') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('indication'))) {
            conditions.add('Product_Indication_gne__c LIKE \'%' + filterMap.get('indication') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('costCenterType'))) {
            conditions.add('Cost_Center_Type_gne__c LIKE \'%' + filterMap.get('costCenterType') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('costCenter'))) {
            conditions.add('Cost_Center_gne__r.Name LIKE \'%' + filterMap.get('costCenter') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('assignedTo'))) {
            conditions.add('Assigned_To_gne__r.Name LIKE \'%' + filterMap.get('assignedTo') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('assignedToTerritory'))) {
            conditions.add('Assigned_To_Territory_gne__c LIKE \'%' + filterMap.get('assignedToTerritory') + '%\'');
        }

        if (!costCenterTypeFilter.isEmpty()) {
            conditions.add('Cost_Center_Type_gne__c IN :costCenterTypeFilter');
        }

        queryString += String.join(conditions, ' AND ');
        return Database.query(queryString);
    }

    private List<EMS_Budget_Product_gne__c> queryMyProductBudgets() {
        if (costCenterTypeFilter.size() > 0) {
            return [
                    SELECT Id, Name, Product_Indication_gne__c, Cost_Center_gne__r.Name, Cost_Center_Type_gne__c, Assigned_To_gne__r.Name,
                            Product_Balance_gne__c, Assigned_To_Territory_gne__c
                    FROM EMS_Budget_Product_gne__c
                    WHERE Status_gne__c = 'Active' AND (Assigned_To_gne__r.Name = :event.Event_Owner_gne__r.Name OR Assigned_To_gne__r.Name = :event.Event_Requestor_gne__r.Name) AND Cost_Center_Type_gne__c IN :costCenterTypeFilter
            ];
        } else {
            return [
                    SELECT Id, Name, Product_Indication_gne__c, Cost_Center_gne__r.Name, Cost_Center_Type_gne__c, Assigned_To_gne__r.Name,
                            Product_Balance_gne__c, Budget_State_gne__c, Assigned_To_Territory_gne__c
                    FROM EMS_Budget_Product_gne__c
                    WHERE Status_gne__c = 'Active' AND (Assigned_To_gne__r.Name = :event.Event_Owner_gne__r.Name OR Assigned_To_gne__r.Name = :event.Event_Requestor_gne__r.Name)
            ];
        }
    }

    private List<EMS_Budget_Region_gne__c> queryRegionBudgets() {
        String queryString = 'Select Id,Name,Product_Indication_gne__c,Cost_Center_gne__c,Cost_Center_Type_gne__c,Assigned_To_gne__r.Name, ' +
                +'Region_Balance_gne__c, Assigned_To_Territory_gne__c from EMS_Budget_Region_gne__c WHERE ';

        List<String> conditions = new List<String>{
                'Status_gne__c = \'Active\''
        };

        if (String.isNotBlank(filterMap.get('budgetName'))) {
            conditions.add('Name LIKE \'%' + filterMap.get('budgetName') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('indication'))) {
            conditions.add('Product_Indication_gne__c LIKE \'%' + filterMap.get('indication') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('costCenter'))) {
            conditions.add('Cost_Center_gne__c LIKE \'%' + filterMap.get('costCenter') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('costCenterType'))) {
            conditions.add('Cost_Center_Type_gne__c LIKE \'%' + filterMap.get('costCenterType') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('assignedTo'))) {
            conditions.add('Assigned_To_gne__r.Name LIKE \'%' + filterMap.get('assignedTo') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('assignedToTerritory'))) {
            conditions.add('Assigned_To_Territory_gne__c LIKE \'%' + filterMap.get('assignedToTerritory') + '%\'');
        }

        if (!costCenterTypeFilter.isEmpty()) {
            conditions.add('Cost_Center_Type_gne__c IN :costCenterTypeFilter');
        }

        queryString += String.join(conditions, ' AND ');
        return Database.query(queryString);
    }

    private List<EMS_Budget_Region_gne__c> queryMyRegionBudgets() {
        if (costCenterTypeFilter.size() > 0) {
            return [
                    SELECT Id, Name, Product_Indication_gne__c, Cost_Center_gne__c, Cost_Center_Type_gne__c,
                            Assigned_To_gne__r.Name, Assigned_To_Territory_gne__c, Region_Balance_gne__c
                    FROM EMS_Budget_Region_gne__c
                    WHERE Status_gne__c = 'Active' AND (Assigned_To_gne__r.Name = :event.Event_Owner_gne__r.Name OR Assigned_To_gne__r.Name = :event.Event_Requestor_gne__r.Name) AND Cost_Center_Type_gne__c IN :costCenterTypeFilter
            ];
        } else {
            return [
                    SELECT Id, Name, Product_Indication_gne__c, Cost_Center_gne__c, Cost_Center_Type_gne__c,
                            Assigned_To_gne__r.Name, Assigned_To_Territory_gne__c, Region_Balance_gne__c
                    FROM EMS_Budget_Region_gne__c
                    WHERE Status_gne__c = 'Active' AND (Assigned_To_gne__r.Name = :event.Event_Owner_gne__r.Name OR Assigned_To_gne__r.Name = :event.Event_Requestor_gne__r.Name)
            ];
        }
    }

    private List<EMS_Budget_Territory_gne__c> queryTerritoryBudgets() {
        String queryString = 'Select Id,Name,Product_Indication_gne__c,Cost_Center_gne__c,Cost_Center_Type_gne__c,Assigned_To_gne__r.Name, ' +
                +'Assigned_To_Territory_gne__c, Territory_Balance_gne__c from EMS_Budget_Territory_gne__c WHERE ';

        List<String> conditions = new List<String>{
                'Status_gne__c = \'Active\''
        };

        if (String.isNotBlank(filterMap.get('budgetName'))) {
            conditions.add('Name LIKE \'%' + filterMap.get('budgetName') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('indication'))) {
            conditions.add('Product_Indication_gne__c LIKE \'%' + filterMap.get('indication') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('costCenter'))) {
            conditions.add('Cost_Center_gne__c LIKE \'%' + filterMap.get('costCenter') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('costCenterType'))) {
            conditions.add('Cost_Center_Type_gne__c LIKE \'%' + filterMap.get('costCenterType') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('assignedTo'))) {
            conditions.add('Assigned_To_gne__r.Name LIKE \'%' + filterMap.get('assignedTo') + '%\'');
        }
        if (String.isNotBlank(filterMap.get('assignedToTerritory'))) {
            conditions.add('Assigned_To_Territory_gne__c LIKE \'%' + filterMap.get('assignedToTerritory') + '%\'');
        }

        if (!costCenterTypeFilter.isEmpty()) {
            conditions.add('Cost_Center_Type_gne__c IN :costCenterTypeFilter');
        }

        queryString += String.join(conditions, ' AND ');
        return Database.query(queryString);
    }

    private List<EMS_Budget_Territory_gne__c> queryMyTerritoryBudgets() {
        if (costCenterTypeFilter.size() > 0) {
            return [
                    SELECT Id, Name, Product_Indication_gne__c, Cost_Center_gne__c, Cost_Center_Type_gne__c, Assigned_To_gne__r.Name,
                            Territory_Balance_gne__c, Assigned_To_Territory_gne__c
                    FROM EMS_Budget_Territory_gne__c
                    WHERE Status_gne__c = 'Active' AND (Assigned_To_gne__r.Name = :event.Event_Owner_gne__r.Name OR Assigned_To_gne__r.Name = :event.Event_Requestor_gne__r.Name) AND Cost_Center_Type_gne__c IN :costCenterTypeFilter
            ];
        } else {
            return [
                    SELECT Id, Name, Product_Indication_gne__c, Cost_Center_gne__c, Cost_Center_Type_gne__c, Assigned_To_gne__r.Name,
                            Territory_Balance_gne__c, Assigned_To_Territory_gne__c
                    FROM EMS_Budget_Territory_gne__c
                    WHERE Status_gne__c = 'Active' AND (Assigned_To_gne__r.Name = :event.Event_Owner_gne__r.Name OR Assigned_To_gne__r.Name = :event.Event_Requestor_gne__r.Name)
            ];
        }
    }

    private void buildBudgetWrapperLists(EMS_WrapperList resultList, List<EMS_Budget_Product_gne__c> productBudgets, List<EMS_Budget_Region_gne__c> regionBudgets, List<EMS_Budget_Territory_gne__c> territoryBudgets) {
        List<BudgetWrapper> allBudgetsWrapperList = new List<BudgetWrapper>();
        List<BudgetWrapper> myBudgetsWrapperList = new List<BudgetWrapper>();

        allBudgetsWrapperList.addAll(wrapProductBudgets(productBudgets));
        allBudgetsWrapperList.addAll(wrapRegionBudgets(regionBudgets));
        allBudgetsWrapperList.addAll(wrapTerritoryBudgets(territoryBudgets));

        myBudgetsWrapperList.addAll(wrapProductBudgets(productBudgets));
        myBudgetsWrapperList.addAll(wrapRegionBudgets(regionBudgets));
        myBudgetsWrapperList.addAll(wrapTerritoryBudgets(territoryBudgets));

        Map<String, String> headersMap = new Map<String, String>();
        headersMap.put('budgetName', 'Budget Name');
        headersMap.put('indication', 'Product/Indication');
        headersMap.put('costCenter', 'Cost Center Name');
        headersMap.put('costCenterType', 'Cost Center Type');
        headersMap.put('assignedTo', 'Assigned To');
        headersMap.put('assignedToTerritory', 'Assigned To Territory');
        headersMap.put('fundStatus', 'Fund Status');

        Map<String, String> fieldTypesMap = new Map<String, String>();
        fieldTypesMap.put('budgetName', 'String');
        fieldTypesMap.put('indication', 'String');
        fieldTypesMap.put('costCenter', 'String');
        fieldTypesMap.put('costCenterType', 'String');
        fieldTypesMap.put('assignedTo', 'String');
        fieldTypesMap.put('assignedToTerritory', 'String');
        fieldTypesMap.put('fundStatus', 'String');

        Map<String, Boolean> selectCheckboxesColumnMap = new Map<String, Boolean>();
        selectCheckboxesColumnMap.put('checkboxInitValue', false);

        resultList.objectList = allBudgetsWrapperList;
        resultList.headersMap = headersMap;
        resultList.fieldNames = budgetFieldNames;
        resultList.fieldTypesMap = fieldTypesMap;
        resultList.selectCheckboxesColumnMap = selectCheckboxesColumnMap;
        resultList.selectLabel = 'Select';
    }

    private List<BudgetWrapper> wrapProductBudgets(List<EMS_Budget_Product_gne__c> productBudgets) {
        List<BudgetWrapper> productBudgetWrappers = new List<BudgetWrapper>();
        if (productBudgets != null) {
            String fundFilter = filterMap.get('fundStatus');

            for (EMS_Budget_Product_gne__c pB: productBudgets) {
                BudgetWrapper bw = new BudgetWrapper(event, pb);

                if (bw.isStatus(fundFilter)) {
                    productBudgetWrappers.add(bw);
                }
            }
        }
        return productBudgetWrappers;
    }

    private List<BudgetWrapper> wrapRegionBudgets(List<EMS_Budget_Region_gne__c> regionBudgets) {
        List<BudgetWrapper> regionBudgetWrappers = new List<BudgetWrapper>();
        if (regionBudgets != null) {
            String fundFilter = filterMap.get('fundStatus');

            for (EMS_Budget_Region_gne__c rB: regionBudgets) {
                BudgetWrapper bw = new BudgetWrapper(event, rB);

                if (bw.isStatus(fundFilter)) {
                    regionBudgetWrappers.add(bw);
                }
            }
        }
        return regionBudgetWrappers;
    }

    private List<BudgetWrapper> wrapTerritoryBudgets(List<EMS_Budget_Territory_gne__c> territoryBudgets) {
        List<BudgetWrapper> territoryBudgetWrappers = new List<BudgetWrapper>();
        if (territoryBudgets != null) {
            String fundFilter = filterMap.get('fundStatus');

            for (EMS_Budget_Territory_gne__c tB: territoryBudgets) {
                BudgetWrapper bw = new BudgetWrapper(event, tB);

                if (bw.isStatus(fundFilter)) {
                    territoryBudgetWrappers.add(bw);
                }
            }
        }
        return territoryBudgetWrappers;
    }

    public PageReference nextAction() {
        return null;
    }

    public PageReference init() {
        if (eventId == null) {
            ApexPages.Message pageMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No event selected.');
            ApexPages.addMessage(pageMsg);
        }
        return null;
    }

    public class BudgetAllocationWrapper implements Comparable {
        public String budgetName { get; set; }
        public String budgetId { get; set; }
        public String productIndication { get; set; }
        public String costCenter { get; set; }
        public String costCenterType { get; set; }
        public Decimal allocatedBudget { get; set; }
        public Decimal percentageContribution { get; set; }
        public Decimal budgetFunds { get; set; }
        public Boolean existingAllocation { get; set; }
        public Budget_Allocation_Type budgetAllocationType { get; set; }
        public EMS_Budget_Allocation_gne__c budgetAllocation { get; set; }

        public BudgetAllocationWrapper(String budgetName, Id budgetId, Budget_Allocation_Type budgetAllocationType, String productIndication, String costCenter, String costCenterType, Decimal allocatedBudget, Decimal percentageContribution,
                Decimal budgetFunds, Boolean existingAllocation, EMS_Budget_Allocation_gne__c budgetAllocation) {

            this.budgetName = budgetName;
            this.budgetId = budgetId;
            this.productIndication = productIndication;
            this.costCenter = costCenter;
            this.costCenterType = costCenterType;
            this.allocatedBudget = allocatedBudget;
            this.percentageContribution = percentageContribution;
            this.budgetFunds = budgetFunds;
            this.existingAllocation = existingAllocation;
            this.budgetAllocationType = budgetAllocationType;
            this.budgetAllocation = budgetAllocation;
        }

        public Integer compareTo(Object compareTo) {
            BudgetAllocationWrapper otherBudgetAllocationWrapper = (BudgetAllocationWrapper) compareTo;
            if (existingAllocation && !otherBudgetAllocationWrapper.existingAllocation) {
                return -1;
            } else if (!existingAllocation && otherBudgetAllocationWrapper.existingAllocation) {
                return 1;
            } else {
                return budgetName.compareTo(otherBudgetAllocationWrapper.budgetName);
            }
        }
    }

    public void recalculateFundStatus() {
        Decimal totalBudgetAlocated = Decimal.valueOf(System.currentPageReference().getParameters().get('totalBudgetAlocated'));

        for (EMS_Wrapper wrapper : myBudgets.objectList) {
            BudgetWrapper budgetWrapper = (BudgetWrapper) wrapper;
            budgetWrapper.remainingEventExpenses = event.Planned_Expenses_gne__c - totalBudgetAlocated;
        }

        for (EMS_Wrapper wrapper : allBudgets.objectList) {
            BudgetWrapper budgetWrapper = (BudgetWrapper) wrapper;
            budgetWrapper.remainingEventExpenses = event.Planned_Expenses_gne__c - totalBudgetAlocated;
        }
    }


    public class BudgetWrapper extends EMS_Wrapper {
        public Id budgetId { get; set; }
        public String type { get; set; }
        public String assignedTo { get; set; }
        public String assignedToTerritory { get; set; }
        public String budgetName { get; set; }
        public String costCenter { get; set; }
        public String costCenterType { get; set; }
        public String indication { get; set; }
        public String newBudgetName { get; set; }
        public Decimal remainingEventExpenses { get; set; }
        public String fundStatus { get {return remainingEventExpenses > budgetBalance ? BALANCE_FAIL : BALANCE_OK;} }

        public Decimal budgetBalance {
            get {
                if (budgetProduct != null) {
                    return budgetProduct.Product_Balance_gne__c;
                } else if (budgetTerritory != null) {
                    return budgetTerritory.Territory_Balance_gne__c;
                } else if (budgetRegion != null) {
                    return budgetRegion.Region_Balance_gne__c;
                } else {
                    return 0.0;
                }
            }
        }

        public EMS_Budget_Product_gne__c budgetProduct { get; private set; }
        public EMS_Budget_Territory_gne__c budgetTerritory { get; private set; }
        public EMS_Budget_Region_gne__c budgetRegion { get; private set; }
        public EMS_Event__c event { get; private set; }

        public BudgetWrapper() {
            compareBy = 'budgetName';
            ascending = TRUE;
        }

        public BudgetWrapper(EMS_Event__c event, EMS_Budget_Product_gne__c budget) {
            this.event = event;
            this.budgetProduct = budget;
            this.type = 'Product Budget';

            assignedTo = budget.Assigned_To_gne__r.Name;
            assignedToTerritory = budget.Assigned_To_Territory_gne__c;
            budgetId = budget.Id;
            budgetName = budget.Name;
            indication = budget.Product_Indication_gne__c;
            costCenter = budget.Cost_Center_gne__r.Name;
            costCenterType = budget.Cost_Center_Type_gne__c;
            remainingEventExpenses = event.Planned_Expenses_gne__c - event.Total_Budget_Allocated_gne__c;
        }

        public BudgetWrapper(EMS_Event__c event, EMS_Budget_Territory_gne__c budget) {
            this.event = event;
            this.budgetTerritory = budget;
            this.type = 'Territory Budget';

            assignedTo = budget.Assigned_To_gne__r.Name;
            assignedToTerritory = budget.Assigned_To_Territory_gne__c;
            budgetId = budget.Id;
            budgetName = budget.Name;
            indication = budget.Product_Indication_gne__c;
            costCenter = budget.Cost_Center_gne__c;
            costCenterType = budget.Cost_Center_Type_gne__c;
            remainingEventExpenses = event.Planned_Expenses_gne__c - event.Total_Budget_Allocated_gne__c;
        }

        public BudgetWrapper(EMS_Event__c event, EMS_Budget_Region_gne__c budget) {
            this.event = event;
            this.budgetRegion = budget;
            this.type = 'Region Budget';

            assignedTo = budget.Assigned_To_gne__r.Name;
            assignedToTerritory = budget.Assigned_To_Territory_gne__c;
            budgetId = budget.Id;
            budgetName = budget.Name;
            indication = budget.Product_Indication_gne__c;
            costCenter = budget.Cost_Center_gne__c;
            costCenterType = budget.Cost_Center_Type_gne__c;
            remainingEventExpenses = event.Planned_Expenses_gne__c - event.Total_Budget_Allocated_gne__c;
        }

        public Boolean isStatus(String checkStatus) {
            return String.isBlank(checkStatus) || fundStatus.containsIgnoreCase(checkStatus);
        }

        public override Integer compareTo(Object compareTo) {
            if (compareBy == null || compareBy == '') {
                return 0;
            } else if (!ascending) {
                return compareToDescending(compareTo);
            } else {
                return compareToAscending(compareTo);
            }
        }

        public Integer compareToAscending(Object compareTo) {
            BudgetWrapper budgetCompare = (BudgetWrapper) compareTo;
            if (compareBy == 'budgetName') {
                return budgetName.compareTo(budgetCompare.budgetName);
            } else if (compareBy == 'indication') {
                return indication.compareTo(budgetCompare.indication);
            } else if (compareBy == 'costCenter') {
                return costCenter.compareTo(budgetCompare.costCenter);
            } else if (compareBy == 'costCenterType') {
                return costCenterType.compareTo(budgetCompare.costCenterType);
            } else if (compareBy == 'assignedTo') {
                return assignedTo.compareTo(budgetCompare.assignedTo);
            } else if (compareBy == 'assignedToTerritory') {
                return assignedToTerritory.compareTo(budgetCompare.assignedToTerritory);
            } else if (compareBy == 'fundStatus') {
                return fundStatus.compareTo(budgetCompare.fundStatus);
            } else {
                return 0;
            }
        }

        public Integer compareToDescending(Object compareTo) {
            BudgetWrapper budgetCompare = (BudgetWrapper) compareTo;
            if (compareBy == 'budgetName') {
                return budgetName.compareTo(budgetCompare.budgetName) * (-1);
            } else if (compareBy == 'indication') {
                return indication.compareTo(budgetCompare.indication) * (-1);
            } else if (compareBy == 'costCenter') {
                return costCenter.compareTo(budgetCompare.costCenter) * (-1);
            } else if (compareBy == 'costCenterType') {
                return costCenterType.compareTo(budgetCompare.costCenterType) * (-1);
            } else if (compareBy == 'assignedTo') {
                return assignedTo.compareTo(budgetCompare.assignedTo) * (-1);
            } else if (compareBy == 'assignedToTerritory') {
                return assignedToTerritory.compareTo(budgetCompare.assignedToTerritory) * (-1);
            } else if (compareBy == 'fundStatus') {
                return fundStatus.compareTo(budgetCompare.fundStatus) * (-1);
            } else {
                return 0;
            }
        }
    }
}