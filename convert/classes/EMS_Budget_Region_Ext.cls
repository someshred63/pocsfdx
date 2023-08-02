public with sharing class EMS_Budget_Region_Ext extends EMS_DynamicVFLoader {

    private EMS_Budget_Region_gne__c regionBudget;

    public Boolean renderChildTerritories {
        get {
            return String.isNotBlank(regionBudget.Cost_Center_Type_gne__c) &&
                    !regionBudget.Cost_Center_Type_gne__c.containsIgnoreCase('medical');
        }
    }

    public EMS_Budget_Region_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Budget_Region_Layout');
        regionBudget = (EMS_Budget_Region_gne__c) myObject;
    }

    public PageReference edit() {
        PageReference pageReference = new PageReference('/apex/EMS_Budget_Region_Edit_Create_Layout?id=' + myObject.Id);
        pageReference.setRedirect(true);
        return pageReference;
    }

    //noinspection ApexUnusedDeclaration
    public PageReference budgetPlanningClick() {
        PageReference pageRef = Page.EMS_Budget_Planning;
        pageRef.getParameters().put('id', myObject.Id);
        pageRef.getParameters().put('retUrl', ApexPages.currentPage().getUrl());
        return pageRef;
    }

    public PageReference reactiveBudgetClick() {
        regionBudget.Status_gne__c = 'Active';

        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = true;

        try {
            update regionBudget;
        } catch (DmlException ex) {
            // show error message
        }
        init();
        regionBudget = (EMS_Budget_Region_gne__c) myObject;

        List<Schema.RecordTypeInfo> sobjectRecordTypes = GNE_SFA2_Application_Cache.describeObject('EMS_Budget_Region_gne__c').getRecordTypeInfos();
        if (sobjectRecordTypes.size() == 1 || myObject.get('RecordTypeId') == null) {
            recordTypeName = '';
        } else {
            recordTypeName = [SELECT DeveloperName FROM RecordType WHERE Id = :(String) myObject.get('RecordTypeId')].DeveloperName;
        }

        return null;
    }

    public PageReference newFundRequestClick() {
        PageReference pageRef = Page.EMS_Fund_Request_Edit_Create_Layout;
        pageRef.getParameters().put('regionId', myObject.Id);
        pageRef.getParameters().put('productId', ((EMS_Budget_Region_gne__c) myObject).EMS_Budget_Product_gne__c);
        pageRef.getParameters().put('preSetRecordType', getRecordTypeByDeveloperName('Region_Fund_Allocation'));
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public PageReference newTerritoryBudgetClick() {
        PageReference pageRef = Page.EMS_Budget_Territory_Edit_Create_Layout;
        pageRef.getParameters().put('regionId', ((EMS_Budget_Region_gne__c) myObject).Id);
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public override PageReference callMethod(String methodName) {
        if (methodName.equalsIgnoreCase('newFundRequestClick')) {
            return newFundRequestClick();
        } else if (methodName.equalsIgnoreCase('newTerritoryBudgetClick')) {
            return newTerritoryBudgetClick();
        } else {
            return null;
        }
    }

    private static Id getRecordTypeByDeveloperName(String recordType) {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName LIKE :recordType limit 1];
        return rt.Id;
    }

    public Boolean getCanSeeHisoryAndDetails() {
        if (EMS_Util.isAdmin() || EMS_Util.getUserRole() == 'FC' || EMS_Util.getUserRole() == 'PM' || EMS_Util.getUserRole() == 'MM') {
            return true;
        } else if (regionBudget.Assigned_to_gne__c == UserInfo.getUserId()) {
            return true;
        } else {
            return false;
        }
    }

    //noinspection ApexUnusedDeclaration
    public Boolean getCanPlan() {
        if (EMS_Util.isAdmin()) {
            return true;
        } else if ((EMS_Util.getUserRole() == 'RSM' || EMS_Util.getUserRole() == 'PM') && regionBudget.Assigned_to_gne__c == UserInfo.getUserId()) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean getCanReactive() {
        return EMS_Util.isAdmin() && regionBudget.Status_gne__c == 'Inactive';
    }

    public List<String> getRelatedFieldSetListOverwritten() {
        EMS_Budget_Region_gne__c regionBudget = (EMS_Budget_Region_gne__c) myObject;

        Set <String> relatedListDisplayed = new Set<String>();
        relatedListDisplayed.add('Fund Requests');
        relatedListDisplayed.add('Event Budget Allocation');
        if(!EMS_Access.isRep()) {
            relatedListDisplayed.add('Territory Budgets');
        }

        for (String s : relatedFieldSetList) {
            if (relatedFieldSetMap.get(s) != null) {
                List<SFA2_Configuration_Object_Detail_gne__c> overwrittenRelatedList = new List<SFA2_Configuration_Object_Detail_gne__c>();
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : relatedFieldSetMap.get(s)) {
                    if (confDetail.Type_gne__c == 'Related List' && confDetail.API_Name_gne__c == 'EMS_Fund_Request_gne__c' && (regionBudget.Assigned_to_gne__c != UserInfo.getUserId()) && EMS_Access.isPM()) {
                        relatedListAttributes.get(confDetail.API_Name_gne__c).hideEditLink = true;
                        relatedListAttributes.get(confDetail.API_Name_gne__c).hideDeleteLink = true;
                        relatedListAttributes.get(confDetail.API_Name_gne__c).customButtonsList = null;
                    }
                    if (confDetail.Type_gne__c == 'Related List' && confDetail.API_Name_gne__c == 'EMS_Budget_Territory_gne__c' && (regionBudget.Assigned_to_gne__c != UserInfo.getUserId()) && EMS_Access.isPM()) {
                        relatedListAttributes.get(confDetail.API_Name_gne__c).hideEditLink = true;
                        relatedListAttributes.get(confDetail.API_Name_gne__c).hideDeleteLink = true;
                        relatedListAttributes.get(confDetail.API_Name_gne__c).customButtonsList = null;
                    }

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

}