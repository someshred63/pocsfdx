public with sharing class EMS_Budget_Territory_Ext extends EMS_DynamicVFLoader {

    private EMS_Budget_Territory_gne__c territoryBudget;

    public EMS_Budget_Territory_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Budget_Territory_Layout');
        territoryBudget = (EMS_Budget_Territory_gne__c) myObject;
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Budget_Territory_Edit_Create_Layout?id=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference reactiveBudgetClick() {
        territoryBudget.Status_gne__c = 'Active';

        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = true;

        try {
            update territoryBudget;
        } catch (DMLException ex) {
            // show error message
        }
        init();
        territoryBudget = (EMS_Budget_Territory_gne__c) myObject;

        List<Schema.RecordTypeInfo> sobjectRecordTypes = GNE_SFA2_Application_Cache.describeObject('EMS_Budget_Territory_gne__c').getRecordTypeInfos();
        if (sobjectRecordTypes.size() == 1 || myObject.get('RecordTypeId') == null) {
            recordTypeName = '';
        } else {
            recordTypeName = [SELECT DeveloperName FROM RecordType WHERE Id = :(String) myObject.get('RecordTypeId')].DeveloperName;
        }

        return null;
    }

    public PageReference newFundRequestClick() {
        PageReference pageRef = Page.EMS_Fund_Request_Edit_Create_Layout;
        pageRef.getParameters().put('territoryId', myObject.Id);
        pageRef.getParameters().put('regionId', ((EMS_Budget_Territory_gne__c) myObject).EMS_Budget_Region_gne__c);
        pageRef.getParameters().put('preSetRecordType', getRecordTypeByDeveloperName('Territory_Fund_Allocation'));
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public override PageReference callMethod(String methodName) {
        if (methodName.equalsIgnoreCase('newFundRequestClick')) {
            return newFundRequestClick();
        } else {
            return null;
        }
    }

    private static Id getRecordTypeByDeveloperName(String recordType) {
        RecordType rt = [SELECT Id FROM RecordType WHERE DeveloperName LIKE :recordType limit 1];
        return rt.Id;
    }

    public boolean getCanSeeHistory() {
        if (EMS_Util.isAdmin() || EMS_Util.getUserRole() == 'FC') {
            return true;
        } else if (EMS_Util.getUserRole() == 'Rep' && territoryBudget.Assigned_To_gne__c == UserInfo.getUserId()) {
            return true;
        } else if (EMS_Util.getUserRole() == 'PM' || EMS_Util.getUserRole() == 'RSM') {
            return true;
        } else {
            return false;
        }
    }

    public boolean getCanReactive() {
        return EMS_Util.isAdmin() && territoryBudget.Status_gne__c == 'Inactive';
    }

    public List<String> getRelatedFieldSetListOverwritten() {
        for (String s : relatedFieldSetList) {
            if (relatedFieldSetMap.get(s) != null) {
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : relatedFieldSetMap.get(s)) {
                    if (confDetail.Type_gne__c == 'Related List' && confDetail.API_Name_gne__c == 'EMS_Fund_Request_gne__c' && (territoryBudget.Assigned_To_gne__c != UserInfo.getUserId()) && EMS_Util.getUserRole() == 'RSM') {
                        relatedListAttributes.get(confDetail.API_Name_gne__c).hideEditLink = true;
                        relatedListAttributes.get(confDetail.API_Name_gne__c).hideDeleteLink = true;
                        relatedListAttributes.get(confDetail.API_Name_gne__c).customButtonsList = null;
                    }
                }
            }
        }
        return relatedFieldSetList;
    }

}