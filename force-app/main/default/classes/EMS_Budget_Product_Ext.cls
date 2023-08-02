public with sharing class EMS_Budget_Product_Ext extends EMS_DynamicVFLoader {

    private EMS_Budget_Product_gne__c productBudget;

    public EMS_Budget_Product_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Budget_Product_Layout');
        productBudget = (EMS_Budget_Product_gne__c) myObject;
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Budget_Product_Edit_Create_Layout?id=' + productBudget.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference budgetPlanningClick() {
        PageReference pageRef = Page.EMS_Budget_Planning;
        pageRef.getParameters().put('id', productBudget.Id);
        pageRef.getParameters().put('retUrl', '/' + productBudget.Id);
        return pageRef;
    }

    public PageReference newRegionBudgetClick() {
        PageReference pageRef = Page.EMS_Budget_Region_Edit_Create_Layout;
        pageRef.getParameters().put('productId', productBudget.Id);
        pageRef.getParameters().put('retURL', '/' + productBudget.Id);
        return pageRef;
    }

    public PageReference newTerritoryBudgetClick() {
        PageReference pageRef = Page.EMS_Budget_Territory_Edit_Create_Layout;
        pageRef.getParameters().put('retURL', '/' + productBudget.Id);
        return pageRef;
    }

    public PageReference closeBudgetClick() {
        productBudget.Status_gne__c = 'Inactive';
        updateBudget();
        return null;
    }

    public PageReference reactiveBudgetClick() {
        productBudget.Status_gne__c = 'Active';
        updateBudget();
        return null;
    }

    private void updateBudget() {
        // bypass validation rules
        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = true;

        try {
            update productBudget;
        } catch (DMLException ex) {
            // show error message
        }
        // update product budget
        init();
        productBudget = (EMS_Budget_Product_gne__c) myObject;
        // refresh record type
        List<Schema.RecordTypeInfo> sobjectRecordTypes = GNE_SFA2_Application_Cache.describeObject('EMS_Budget_Product_gne__c').getRecordTypeInfos();
        if (sobjectRecordTypes.size() == 1 || myObject.get('RecordTypeId') == null) {
            recordTypeName = '';
        } else {
            recordTypeName = [Select DeveloperName from RecordType where id = :(String) myObject.get('RecordTypeId')].DeveloperName;
        }
    }

    public override PageReference callMethod(String methodName) {
        if (methodName.equalsIgnoreCase('newRegionBudgetClick')) {
            return newRegionBudgetClick();
        } else if (methodName.equalsIgnoreCase('newTerritoryBudgetClick')) {
            return newTerritoryBudgetClick();
        } else if (methodName.equalsIgnoreCase('budgetPlanningClick')) {
            return budgetPlanningClick();
        } else if (methodName.equalsIgnoreCase('closeBudgetClick')) {
            return closeBudgetClick();
        } else {
            return null;
        }
    }

    public List<String> getRelatedFieldSetListOverwritten() {
        List<SFA2_Configuration_Object_Detail_gne__c> overwrittenRelatedList;

        //add related lists names (represented by Labels on detail objects) which should be displayed on the page
        Set <String> relatedListDisplayed = new Set<String>();
        relatedListDisplayed.add('Fund Requests');
        relatedListDisplayed.add('Region Budgets');
        relatedListDisplayed.add('Event Budget Allocation');

        for (String s: relatedFieldSetList) {
            if (relatedFieldSetMap.get(s) != null) {
                overwrittenRelatedList = new List<SFA2_Configuration_Object_Detail_gne__c>();
                for (SFA2_Configuration_Object_Detail_gne__c confDetail: relatedFieldSetMap.get(s)) {
                    if (confDetail.Type_gne__c == 'Related List' && relatedListDisplayed.contains(confDetail.Label_gne__c)) {
                        overwrittenRelatedList.add(confDetail);
                    }
                }
                relatedFieldSetMap.get(s).clear();
                relatedFieldSetMap.get(s).addAll(overwrittenRelatedList);
            }
        }
        return relatedFieldSetList;
    }

    public boolean getCanClose() {
        if (productBudget.Status_gne__c == 'Inactive') {
            return false;
        } else if (EMS_Util.isAdmin() || EMS_Util.getUserRole() == 'FC') {
            return true;
        } else if ((EMS_Util.getUserRole() == 'PM' || EMS_Util.getUserRole() == 'MM') && productBudget.Assigned_To_gne__c == UserInfo.getUserId()) {
            return true;
        } else {
            return false;
        }
    }

    public boolean getCanPlan() {
        if (productBudget.Status_gne__c == 'Inactive') {
            return false;
        } else if (EMS_Util.isAdmin()) {
            return true;
        } else if ((EMS_Util.getUserRole() == 'PM' || EMS_Util.getUserRole() == 'MM') && productBudget.Assigned_To_gne__c == UserInfo.getUserId()) {
            return true;
        } else {
            return false;
        }
    }

    public boolean getCanSeeHisoryAndDetails() {
        if (EMS_Util.isAdmin() || EMS_Util.getUserRole() == 'FC' || EMS_Access.isBPS()) {
            return true;
        } else if ((EMS_Util.getUserRole() == 'PM' || EMS_Util.getUserRole() == 'MM') && productBudget.Assigned_To_gne__c == UserInfo.getUserId()) {
            return true;
        } else {
            return false;
        }
    }

    public boolean getCanReactive() {
        return (EMS_Access.isAdmin() || EMS_Access.isFCUser()) && productBudget.Status_gne__c == 'Inactive';
    }

    public boolean getCanDuplicate() {
        return productBudget.Status_gne__c != 'Inactive' && (EMS_Util.isAdmin() || EMS_Util.getUserRole() == 'FC');
    }

    public PageReference duplicateBudgetClick() {

        PageReference pref = new PageReference('/apex/EMS_Budget_Product_Edit_Create_Layout?isClone=true&id=' + productBudget.Id);
        pref.setRedirect(true);

        return pref;
    }
}