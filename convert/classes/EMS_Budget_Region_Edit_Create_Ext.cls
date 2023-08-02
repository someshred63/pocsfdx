public with sharing class EMS_Budget_Region_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {

    public EMS_Budget_Product_gne__c productBudget { get; set; }
    public String pageErrorMessage { get; set; }
    private EMS_Budget_Region_gne__c currentRecord;

    public EMS_Budget_Region_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Budget_Region_Layout');
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (controller.getRecord().Id == null) {
            EMS_Budget_Region_gne__c newBudgetRegion = new EMS_Budget_Region_gne__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');

            String productId = ApexPages.currentPage().getParameters().get('productId');

            if (preSetRecordTypeId != null) {
                newBudgetRegion.RecordTypeId = (Id) preSetRecordTypeId;
            }

            if (productId != null) {
                productBudget = [SELECT Id, Cost_Center_gne__c, Cost_Center_Type_gne__c, Product_Indication_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :((Id) productId) LIMIT 1];
                newBudgetRegion.EMS_Budget_Product_gne__c = productBudget.Id;
            }

            newBudgetRegion.Year_gne__c = EMS_Util.getCalendarYearForNewBudget();

            myObject = newBudgetRegion;
        } else {
            myObject = controller.getRecord();
            Id productBudgetId = [SELECT EMS_Budget_Product_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :((EMS_Budget_Region_gne__c) myObject).Id LIMIT 1].EMS_Budget_Product_gne__c;
            productBudget = [SELECT Id, Cost_Center_gne__c, Cost_Center_Type_gne__c, Product_Indication_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgetId LIMIT 1];
        }
        super.initController(controller);
    }

    public PageReference refreshProductBudget() {
        List<EMS_Budget_Product_gne__c> productBudgets = [SELECT Id, Cost_Center_gne__c, Cost_Center_Type_gne__c, Product_Indication_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :((EMS_Budget_Region_gne__c) myObject).EMS_Budget_Product_gne__c];
        if (productBudgets.size() > 0) {
            productBudget = productBudgets[0];
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid budget selected'));
        }

        return null;
    }

    public Boolean getIsEditable() {
        if (EMS_Util.isAdmin()) {
            return true;
        } else if (myObject.get('Id') == null) {
            return true;
        } else {
            return false;
        }
    }

    public List<SelectOption> getAvailableTerritories() {
        Id userId = ((EMS_Budget_Region_gne__c) myObject).Assigned_to_gne__c;
        return EMS_Util.getUserTerritorySelectOptions(userId);
    }

    public override PageReference save() {
        pageErrorMessage = null;
        isClone = (System.currentPageReference().getParameters().get('isClone') != null && System.currentPageReference().getParameters().get('isClone') == 'true');
        if (isClone) {
            myObject = myObject.clone();
        }
        if (myObject.id == null && !isClone) {
            if (recordTypeName != null && recordTypeName != '') {
                RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName AND SobjectType = :myObjectType limit 1][0];
                myObject.put('recordTypeId', recordType.Id);
            }
        }
        PageReference newpage;
        try {
            Database.UpsertResult ur = Database.upsert(myObject);

            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), myObject.Id);
            if (!userRecordAccess.HasReadAccess) {
                return Page.GNE_SFA2_Access_Denied;
            }
            String viewURL = viewPage + '?id=' + myObject.Id;
            if (retURL != null) {
                viewURL = viewURL + '&retURL=' + retURL;
            }
            newpage = new PageReference(viewURL);

            if (ur.isCreated()) {
                newpage.getParameters().put('msg', 'Your budget was created successfully');
            }
        } catch (Exception e) {
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                pageErrorMessage = 'Budget with given Cost Center/Territory/Year already exists.';
                return null;
            } else if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                // It's handled by styled apex:pageMessages
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

        if (myObjectType.equals('Task')) {
            if (retURL != null) {
                newpage = new PageReference(retURL);
            } else {
                newpage = new PageReference('/apex/GNE_SFA2_MyTasks');
            }
        }
        newpage.setredirect(true);
        return newpage;
    }
}