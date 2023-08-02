public with sharing class EMS_Related_Budgets_Controller {
    public static SObject resultBudget { get; set; }

    public static sObject parent { get; private set; }
    public static Id parentId {
        get;
        set {
            parentId = value;
            initialize();
        }
    }

    public static String parentJSON {
        get {
            return JSON.serialize(parent);
        }
    }

    public static String parentApiName {
        get {
            return parentId.getSObjectType().getDescribe().getName();
        }
    }

    public static String parentCostCenterType {
        get {
            return (String) parent.get('Cost_Center_Type_gne__c');
        }
    }

    public static Boolean isParentProductBudget {
        get {
            return parentApiName == 'EMS_Budget_Product_gne__c';
        }
    }

    public static Boolean isParentRegionBudget {
        get {
            return parentApiName == 'EMS_Budget_Region_gne__c';
        }
    }

    public static Boolean isAdmin {
        get {
            return EMS_Util.isAdmin();
        }
    }

    private static Set<String> excludedRoles = new Set<String>{
            'ML'
    };
    public static Boolean canCreate {
        get {
            // Hide buttons is overriden by custom buttons
            return GNE_SFA2_Application_Cache.describeObject(objectApiName).isCreateable() && !isParentInactive && !excludedRoles.contains(userApplicationContext.Role_gne__c);
        }
    }

    public static Boolean canDelete {
        get {
            return GNE_SFA2_Application_Cache.describeObject(objectApiName).isDeletable() && !isParentInactive && budgetsConfiguration.hideEditLink == false;
        }
    }

    public static Boolean canUpdate {
        get {
            return GNE_SFA2_Application_Cache.describeObject(objectApiName).isUpdateable() && !isParentInactive && budgetsConfiguration.hideEditLink == false;
        }
    }

    public static String objectApiName {
        get {
            if (isParentProductBudget) {
                return 'EMS_Budget_Region_gne__c';
            } else if (isParentRegionBudget) {
                return 'EMS_Budget_Territory_gne__c';
            } else {
                return null;
            }
        }
    }

    public static String objectsName {
        get {
            return GNE_SFA2_Application_Cache.describeObject(objectApiName).getLabelPlural().removeStart('EMS ');
        }
    }

    public static String objectName {
        get {
            return GNE_SFA2_Application_Cache.describeObject(objectApiName).getLabel().removeStart('EMS ');
        }
    }

    public static Map<String, GNE_SFA2_RL_Component_AttributesWrapper> relatedListAttributes { get; private set; }
    public static GNE_SFA2_RL_Component_AttributesWrapper budgetsConfiguration {
        get {
            return relatedListAttributes.get(objectApiName);
        }
    }
    public static Boolean isParentInactive { get {return parent.get('Status_gne__c') == 'Inactive';} }

    public static List<String> tableFields { get; private set; }
    public static Decimal balance {
        get {
            if (isParentProductBudget) {
                return (Decimal) parent.get('Product_Balance_gne__c');
            } else if (isParentRegionBudget) {
                return (Decimal) parent.get('Region_Balance_gne__c');
            } else {
                return 0.0;
            }
        }
    }
    public static String balanceString { get {return EMS_Util.formatCurrency(balance);} }

    public static String transferBalanceField {
        get {
            if (isParentProductBudget) {
                return 'Region_Balance_gne__c';
            } else if (isParentRegionBudget) {
                return 'Territory_Balance_gne__c';
            } else {
                return '';
            }
        }
    }

    private static GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
    public EMS_Related_Budgets_Controller() {
    }

    private static void initialize() {
        if (tableFields == null) tableFields = new List<String>();

        loadParentObject();
        fetchRelatedListAttributes();
        tableFields = fetchFields(parentId);
    }

    public static void loadParentObject() {
        parent = fetchParentObject(parentId);
    }

    private static SObject fetchParentObject(Id parentObjectId) {
        SObject result;
        String apiName = parentObjectId.getSobjectType().getDescribe().getName();

        if (parentObjectId.getSobjectType() == EMS_Budget_Product_gne__c.sObjectType) {
            result = Database.query('SELECT Id, Name, Name_gne__c, Cost_Center_Type_gne__c, RecordTypeId, Product_Balance_gne__c, Assigned_to_gne__c, Assigned_To_Territory_gne__c, Status_gne__c, Year_gne__c, Start_Date_gne__c, End_Date_gne__c FROM ' + apiName + ' WHERE Id = :parentObjectId');
        } else if (parentObjectId.getSobjectType() == EMS_Budget_Region_gne__c.sObjectType) {
            result = Database.query('SELECT Id, Name, Name_gne__c, Cost_Center_Type_gne__c, RecordTypeId, Region_Balance_gne__c,  Assigned_to_gne__c, Assigned_To_Territory_gne__c, Status_gne__c, Year_gne__c, Start_Date_gne__c, End_Date_gne__c FROM ' + apiName + ' WHERE Id = :parentObjectId');
        } else {
            result = Database.query('SELECT Id, Name, Name_gne__c, RecordTypeId FROM ' + apiName + ' WHERE Id = :parentObjectId');
        }

        return result;
    }

    private static List<string> fetchFields(Id parentObjectId) {
        List<string> result = new List<String>{
                'Assigned_to_gne__c',
                'Assigned_To_Territory_gne__c'
        };

        if (parentObjectId.getSobjectType() == EMS_Budget_Product_gne__c.sObjectType) {
            result.add('Total_Region_Funds_Approved_gne__c');
            result.add('Region_Balance_gne__c');
        } else if (parentObjectId.getSobjectType() == EMS_Budget_Region_gne__c.sObjectType) {
            result.add('Total_Territory_Funds_Approved_gne__c');
            result.add('Territory_Balance_gne__c');
        }

        result.add('Year_gne__c');
        result.add('Status_gne__c');

        return result;
    }

    private static List<string> fetchQueryFields(Id parentObjectId) {
        List<string> result = new List<String>{
                'Assigned_to_gne__c',
                'Assigned_to_gne__r.Name',
                'Assigned_To_Territory_gne__c',
                'Name_gne__c',
                'Year_gne__c'
        };

        if (parentObjectId.getSobjectType() == EMS_Budget_Product_gne__c.sObjectType) {
            result.add('Total_Region_Funds_Approved_gne__c');
            result.add('Region_Balance_gne__c');
        } else if (parentObjectId.getSobjectType() == EMS_Budget_Region_gne__c.sObjectType) {
            result.add('Total_Territory_Funds_Approved_gne__c');
            result.add('Territory_Balance_gne__c');
        }

        result.add('Status_gne__c');

        return result;
    }

    private static void fetchRelatedListAttributes() {
        relatedListAttributes = new Map<String, GNE_SFA2_RL_Component_AttributesWrapper>();

        String recordTypeName;
        List<RecordType> parentRecordTypes = [Select DeveloperName from RecordType where id = :(Id) parent.get('RecordTypeId')];
        if (parentRecordTypes.isEmpty() == false) {
            recordTypeName = parentRecordTypes[0].DeveloperName;
        }

        List<SFA2_Configuration_Object_gne__c> layouts = getUIConfigurationObjects(userApplicationContext, parentApiName, recordTypeName);
        for (SFA2_Configuration_Object_gne__c layout : layouts) {
            for (SFA2_Configuration_Object_Detail_gne__c layoutDetails : layout.Configuration_Objects__r) {
                if (layoutDetails.Type_gne__c == 'Related List') {
                    GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(layoutDetails.Attributes_gne__c);
                    relatedListAttributes.put(layoutDetails.API_Name_gne__c, attributesWrapper);
                }
            }
        }
    }

    static List<SFA2_Configuration_Object_gne__c> getUIConfigurationObjects(GNE_SFA2_User_App_Context_gne__c context, String apiName, String recordTypeName) {
        System.debug(LoggingLevel.ERROR, '### Object_Name_gne__c : ' + apiName);
        System.debug(LoggingLevel.ERROR, '### Role_gne__c : ' + context.Role_gne__c);
        System.debug(LoggingLevel.ERROR, '### Brand_gne__c : ' + context.Brand_gne__c);
        System.debug(LoggingLevel.ERROR, '### Record_Type_gne__c : ' + recordTypeName);
        System.debug(LoggingLevel.ERROR, '### Application_Type__c : ' + context.App_Name_gne__c);

        return [
                SELECT Id, Name, Role_gne__c, External_ID_gne__c, Object_Name_gne__c, Section_Header_gne__c,
                        Record_Type_gne__c, Brand_gne__c, Is_Active_gne__c, Order_gne__c, Style_gne__c, Attributes_gne__c, (
                        SELECT Name, API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Read_Only_gne__c,
                                Is_Required_gne__c, Order_gne__c, Style_gne__c, Type_gne__c, Availability_Mode_gne__c
                        FROM Configuration_Objects__r
                        WHERE Is_Active_gne__c = true
                        ORDER BY Order_gne__c, API_Name_gne__c
                )
                FROM SFA2_Configuration_Object_gne__c
                WHERE Object_Name_gne__c = :apiName
                AND Role_gne__c = :context.Role_gne__c
                AND Brand_gne__c = :context.Brand_gne__c
                AND Record_Type_gne__c = :recordTypeName
                AND Application_Type__c = :context.App_Name_gne__c
                AND Is_Active_gne__c = true
                ORDER BY Order_gne__c, Section_Header_gne__c
        ];
    }

    private static Set<String> roleName(String apiName) {
        if (apiName == 'EMS_Budget_Region_gne__c') {
            return EMS_Budget_Region_Validation_Rules.allowedRoles;
        } else if (apiName == 'EMS_Budget_Territory_gne__c') {
            return EMS_Budget_Territory_Validation_Rules.allowedRoles;
        } else if (apiName == 'EMS_Budget_Product_gne__c') {
            return EMS_Budget_Product_Validation_Rules.allowedRoles;
        } else {
            return new Set<String>();
        }
    }

    // ---------- Remote actions

    @RemoteAction
    public static SObject[] getBudgets(String tableName, String referenceName, Id parentObjectId) {
        List<String> objectFields = fetchQueryFields(parentObjectId);
        return Database.query('SELECT Id, ' + String.join(objectFields, ', ') + ' FROM ' + tableName + ' WHERE ' + referenceName + ' = :parentObjectId ORDER BY CreatedDate ASC');
    }

    @RemoteAction
    public static SObject[] getBudgetsForTransfer(String tableName, String referenceName, Id parentObjectId) {
        List<String> objectFields = fetchQueryFields(parentObjectId);
        List<String> statuses = new List<String>{
                'Active'
        };
        List<SObject> result = new List<SObject>();
        result.add(fetchParentObject(parentObjectId));
        result.addAll(Database.query('SELECT Id, ' + String.join(objectFields, ', ') + ' FROM ' + tableName + ' WHERE ' + referenceName + ' = :parentObjectId AND Status_gne__c in :statuses ORDER BY CreatedDate ASC'));
        return result;
    }

    @RemoteAction
    public static SObject newBudget(Id parentObjectId) {
        sObject p = fetchParentObject(parentObjectId);
        SObject budget;

        if (p.getSobjectType() == EMS_Budget_Product_gne__c.sObjectType) {
            budget = new EMS_Budget_Region_gne__c(
                    Total_Region_Funds_Approved_gne__c = 0.0
            );
        } else if (p.getSobjectType() == EMS_Budget_Region_gne__c.sObjectType) {
            budget = new EMS_Budget_Territory_gne__c(
                    Total_Territory_Funds_Approved_gne__c = 0.0
            );
        }

        budget.put('Status_gne__c', 'Pending');
        budget.put('Year_gne__c', p.get('Year_gne__c'));
        budget.put('Start_Date_gne__c', p.get('Start_Date_gne__c'));
        budget.put('End_Date_gne__c', p.get('End_Date_gne__c'));

        budget.put(p.getSObjectType().getDescribe().getName(), parentObjectId);

        return budget;
    }

    @RemoteAction
    public static Map<Id, List<EMS_Util.EMS_Territory>> availableTerritories(Id[] userIds) {
        return EMS_Util.getUserTerritories(new Set<Id>(userIds));
    }

    @RemoteAction
    public static User[] getUsers(String apiName, String costCenterTypeName) {
        EMS_Cost_Center_Type_gne__c costCenterType = [SELECT Name, Allowed_Owners_gne__c FROM EMS_Cost_Center_Type_gne__c WHERE Name = :costCenterTypeName LIMIT 1];
        Set<String> userRoles = roleName(apiName).clone();
        userRoles.retainAll(costCenterType.Allowed_Owners_gne__c.split(';'));
        Map<Id, String> userRoleMap = EMS_Util.getUsersRolesFromSR();

        Set<Id> userIds = new Set<Id>();
        for (Id userId : userRoleMap.keySet()) {
            if (userRoles.contains(userRoleMap.get(userId))) {
                userIds.add(userId);
            }
        }
        return [SELECT Id, Name FROM User WHERE Id IN :userIds AND IsActive = TRUE ORDER BY Name];
    }

    @RemoteAction
    public static EMS_Remote_Response saveBudget(String apiName, String jsonData) {
        SObject sobjectData = (SObject) JSON.deserialize(jsonData, Type.forName(apiName));

        EMS_Remote_Response response = new EMS_Remote_Response();

        EMS_Product_Budget_Helper.skipTriggerValidationRules = isAdmin;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = isAdmin;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = isAdmin;
        EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = isAdmin;

        Savepoint save = Database.setSavepoint();
        try {
            Database.UpsertResult result = Database.upsert(sobjectData, false);
            response.addUpsertResult(result,
                    result.isCreated() ? 'Your budget was created successfully' : 'Your budget was updated successfully'
            );
        } catch (DmlException ex) {
            response.addError(ex.getMessage());
            Database.rollback(save);
        } catch (Exception ex) {
            response.addError(ex.getMessage());
            Database.rollback(save);
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response deleteBudget(String budgetId) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        Savepoint save = Database.setSavepoint();
        try {
            Database.DeleteResult result = Database.delete(budgetId, false);
            response.addDeleteResult(result, 'Your budget was deleted successfully');
        } catch (DmlException ex) {
            response.addError(ex.getMessage());
            Database.rollback(save);
        } catch (Exception ex) {
            response.addError(ex.getMessage());
            Database.rollback(save);
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response requestTransfer(Id sourceBudgetId, Id targetBudgetId, Decimal transferAmount) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        EMS_Fund_Request_gne__c transferRequest = new EMS_Fund_Request_gne__c(
                Requested_Amount_gne__c = transferAmount,
                Submitted_By_gne__c = UserInfo.getUserId(),
                Status_gne__c = 'Approved',
                Required_By_Date_gne__c = Date.today(),
                Approval_Rejection_Date_gne__c = Date.today(),
                Approver_gne__c = UserInfo.getUserId(),
                Reason_gne__c = 'Transfer Funds'
        );

        Map<String, RecordTypeInfo> recordTypes = EMS_Fund_Request_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName();
        Boolean isTransferType = sourceBudgetId.getSobjectType() == targetBudgetId.getSobjectType();

        if (sourceBudgetId.getSobjectType() == EMS_Budget_Product_gne__c.getSObjectType()) {
            transferRequest.Related_Product_Budget_gne__c = sourceBudgetId;
        } else if (sourceBudgetId.getSobjectType() == EMS_Budget_Region_gne__c.getSObjectType()) {
            transferRequest.Related_Region_Budget_gne__c = sourceBudgetId;
        } else if (sourceBudgetId.getSobjectType() == EMS_Budget_Territory_gne__c.getSObjectType()) {
            transferRequest.Related_Territory_Budget_gne__c = sourceBudgetId;
        } else {
            response.addError(('Unknown Source Budget Type: ' + sourceBudgetId.getSobjectType().getDescribe().getName()));
            return response;
        }

        if (targetBudgetId.getSobjectType() == EMS_Budget_Territory_gne__c.getSObjectType()) {
            if (isTransferType) {
                transferRequest.Target_Territory_Budget_ID_gne__c = targetBudgetId;
                transferRequest.RecordTypeId = recordTypes.get(EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS).getRecordTypeId();
            } else {
                transferRequest.Related_Territory_Budget_gne__c = targetBudgetId;
                transferRequest.RecordTypeId = recordTypes.get(EMS_Consts.RT_ALLOCATION_TERRITORY_FUNDS).getRecordTypeId();
            }
        } else if (targetBudgetId.getSobjectType() == EMS_Budget_Region_gne__c.getSObjectType()) {
            if (isTransferType) {
                transferRequest.Target_Region_Budget_ID_gne__c = targetBudgetId;
                transferRequest.RecordTypeId = recordTypes.get(EMS_Consts.RT_TRANSFER_REGION_FUNDS).getRecordTypeId();
            } else if (transferRequest.Related_Territory_Budget_gne__c != null) {
                transferRequest.Related_Region_Budget_gne__c = targetBudgetId;
                transferRequest.RecordTypeId = recordTypes.get(EMS_Consts.RT_DEALLOCATION_TERRITORY_FUNDS).getRecordTypeId();
                transferRequest.Requested_Amount_gne__c *= -1;
            } else {
                transferRequest.Related_Region_Budget_gne__c = targetBudgetId;
                transferRequest.RecordTypeId = recordTypes.get(EMS_Consts.RT_ALLOCATION_REGION_FUNDS).getRecordTypeId();
            }
        } else if (targetBudgetId.getSobjectType() == EMS_Budget_Product_gne__c.getSObjectType()) {
            transferRequest.Related_Product_Budget_gne__c = targetBudgetId;
            transferRequest.RecordTypeId = recordTypes.get(EMS_Consts.RT_DEALLOCATION_REGION_FUNDS).getRecordTypeId();
            transferRequest.Requested_Amount_gne__c *= -1;
        } else {
            response.addError('Unknown Target Budget Type: ' + targetBudgetId.getSobjectType().getDescribe().getName());
            return response;
        }

        Savepoint save = Database.setSavepoint();
        try {
            Database.SaveResult result = Database.insert(transferRequest, false);
            response.addSaveResult(result, 'Funds transferred successfully');
        } catch (DmlException ex) {
            response.addError(ex.getMessage());
            Database.rollback(save);
        } catch (Exception ex) {
            response.addError(ex.getMessage());
            Database.rollback(save);
        }
        return response;
    }
}