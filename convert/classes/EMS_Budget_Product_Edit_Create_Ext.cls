public without sharing class EMS_Budget_Product_Edit_Create_Ext {

    public String selectedCostCenterType { get; set; }
    public List<SelectOption> costCenters { get; set; }
    public Boolean isClone { get; set; }
    public String pageErrorMessage { get; set; }
    protected String retURL;
    private EMS_Budget_Product_gne__c productBudget;
    private Id oldBudgetId;

    public EMS_Budget_Product_Edit_Create_Ext(ApexPages.StandardController controller) {
        if (!test.isRunningTest()) {
            controller.addFields(new List<String>{
                    'Cost_Center_gne__c'
            });
        }
        productBudget = (EMS_Budget_Product_gne__c) controller.getRecord();
        isClone = ApexPages.currentPage().getParameters().containsKey('isClone');

        if (productBudget.Id == null && !isClone) {
            productBudget.Year_gne__c = EMS_Util.getCalendarYearForNewBudget();
        }

        if (productBudget.Id != null && isClone) {
            oldBudgetId = productBudget.Id;

            productBudget.Total_Product_Funds_Approved_gne__c = 0;
            productBudget.Start_Date_gne__c = null;
            productBudget.End_Date_gne__c = null;
            productBudget.Budget_State_gne__c = null;
            productBudget.Status_gne__c = 'Active';
        }

        costCenters = getAvailableCostCenters();
        refreshCostCenterType();
    }

    public Boolean getIsEditable() {
        if (EMS_Util.isAdmin()) {
            return true;
        } else if (productBudget.Id == null) {
            return true;
        } else {
            return false;
        }
    }

    public List<SelectOption> getAvailableCostCenters() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None Selected--'));
        for (EMS_Cost_Center_gne__c costCenter : [SELECT Name, Product_Indication_Department_gne__c FROM EMS_Cost_Center_gne__c WHERE Is_Active_gne__c = true ORDER BY Name ASC]) {
            result.add(new SelectOption(costCenter.Id, costCenter.Name + ' - ' + costCenter.Product_Indication_Department_gne__c));
        }
        return result;
    }

    public PageReference refreshCostCenterType() {
        if (productBudget.Cost_Center_gne__c != null) {
            EMS_Cost_Center_gne__c selectedCostCenter = [SELECT Cost_Center_Type_gne__r.Name, Product_Indication_Department_gne__c FROM EMS_Cost_Center_gne__c WHERE Id = :productBudget.Cost_Center_gne__c LIMIT 1];
            selectedCostCenterType = selectedCostCenter.Cost_Center_Type_gne__r.Name;
        } else {
            selectedCostCenterType = null;
        }
        return null;
    }

    public List<SelectOption> getAvailableTerritories() {
        return EMS_Util.getUserTerritorySelectOptions(productBudget.Assigned_to_gne__c);
    }

    public PageReference save() {
        PageReference newpage;
        pageErrorMessage = '';
        try {
            if (!isClone) {
                if (productBudget.Id == null) {

                }
                Database.UpsertResult ur = Database.upsert(productBudget);

                newpage = Page.EMS_Budget_Product_Layout;
                newpage.getParameters().put('id', productBudget.Id);
                newpage.setRedirect(true);

                if (ur.isCreated()) {
                    newpage.getParameters().put('msg', 'Your budget was created successfully');
                }

                return newpage;
            } else {
                EMS_Budget_Product_gne__c clonedBudget = productBudget.clone(false, true, false, false);
                insert clonedBudget;

                newpage = Page.EMS_Budget_Product_Layout;
                newpage.getParameters().put('id', clonedBudget.Id);
                newpage.getParameters().put('msg', 'Your budget was created successfully');
                newpage.setRedirect(true);
                return newpage;
            }
        } catch (Exception e) {
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                pageErrorMessage = 'Budget with given Cost Center/Territory/Year already exists.';
                return null;
            } else if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                if (e.getTypeName() == 'System.DmlException') {
                    DmlException eDML = (DmlException) e;
                    for (Integer i = 0; i < eDML.getNumDml(); i++) {
                        pageErrorMessage += (i == 0) ? eDML.getDmlMessage(i) : '; ' + eDML.getDmlMessage(i);
                    }
                } else {
                    pageErrorMessage = e.getMessage();
                }
                return null;
            } else if (e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                pageErrorMessage = 'Value does not exist or does not match filter criteria.';
                return null;
            } else if (e.getMessage().contains('TRANSFER_REQUIRES_READ')) {
                pageErrorMessage = 'User you selected can not be owner of the record. New owner must have object read permission.';
                return null;
            } else if (e.getMessage().contains('CIRCULAR_DEPENDENCY')) {
                pageErrorMessage = e.getMessage();
                return null;
            } else if (e.getMessage().contains('INVALID_CROSS_REFERENCE_KEY')) {
                pageErrorMessage = e.getMessage();
                return null;
            } else if (e.getMessage().contains('INSUFFICIENT')) {
                return GNE_SFA2_Util.redirectToErrorPage('You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', Apexpages.currentPage().getUrl(), e.getMessage());
            } else if (e.getMessage().contains('ENTITY_IS_LOCKED')) {
                pageErrorMessage = 'You cannot update the record, because it\'s locked for editing.';
                return null;
            } else {
                pageErrorMessage = e.getMessage();
                return null;
            }
            return null;
        }
        newpage.setRedirect(true);
        return newpage;
    }
}