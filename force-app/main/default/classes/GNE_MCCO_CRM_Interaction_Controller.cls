public with sharing class GNE_MCCO_CRM_Interaction_Controller extends GNE_MCCO_CRM_Base_Ctrl {

    public String iconBase64 {get; private set;}

    // private transient
    private transient Id accountId;
    private transient Account callAccount;
    private transient Boolean attendeeSectionVisible;
    private transient Boolean collabDetailsSectionVisible;
    private transient Boolean threatsSectionVisible;
    private transient Boolean mealOptOutEnabled;
    private transient Boolean unsolicitedReqFieldExists;
    private transient Boolean simpleEditMode;
    private transient Boolean strategyVisible;
    private transient Boolean tacticVisible;
    protected transient Boolean materialSectionVisible;
    protected transient Boolean dependentMaterialsEnabled;
    protected transient Boolean dependentMaterialsPerAttProdEnabled;
    private transient Boolean multipleAccountsMode;
    private transient Boolean newModeWithoutRecord;
    private transient List<GNE_MCCO_CRM_Base_Ctrl.Field> attendeesAdditionalFields;
    protected transient List<GNE_MCCO_CRM_Base_Ctrl.Field> materialsAdditionalFields;
    private transient List<GNE_MCCO_CRM_Base_Ctrl.Field> objectivesAdditionalFields;
    private transient List<GNE_MCCO_CRM_Base_Ctrl.Field> collaborationAdditionalFields;
    private transient List<GNE_MCCO_CRM_Base_Ctrl.Field> threatAdditionalFields;
    private transient Map<String, Schema.DescribeFieldResult> callDiscussionFieldsDescribe;
    private transient Map<String, Schema.DescribeFieldResult> callSampleFieldsDescribe;
    private transient Map<String, Schema.DescribeFieldResult> callCollaborationFieldsDescribe;
    private transient Map<String, Schema.DescribeFieldResult> callThreatFieldsDescribe;
    private transient Set<Id> productIds;
    private transient Id callDiscussionRecordTypeId;
    private transient Id callCollaborationRecordTypeId;
    private transient Id callThreatRecordTypeId;
    private transient Map<String, SObject> recordsCache;
    private transient Map<Id, SObject> childRecordsToRemoveMap;
    private transient List<Call2_vod__c> mainCallsToUpsert;
    protected transient List<Call2_Sample_vod__c> materialsToUpsert;
    private transient List<Call2_vod__c> attendeesToUpsert;
    private transient List<Call2_Detail_vod__c> detailsToUpsert;
    private transient List<Call2_Discussion_vod__c> discussionsToUpsert;
    private transient List<Call2_Discussion_vod__c> collabsToUpsert;
    protected transient Map<Id,Call2_vod__c> hcpIdToCallMap;
    protected transient Map<Id,Call2_vod__c> contactIdToCallMap;
    private transient List<Call2_Threat_vod__c> threatsToUpsert;
    private transient Map<Id, Call2_vod__c> accountIdToCallMap;
    protected transient Map<String,TableRowWrapper> recToWrapperMap;

    // static
    private static Map<String, String> attendeeTypeValueToLabelMap;
    private static String staticCurrentUserProfileName;


    public GNE_MCCO_CRM_Interaction_Controller(ApexPages.StandardController sctrl) {
        this();
    }
    
    public GNE_MCCO_CRM_Interaction_Controller(Map<String, String> params) {
        this.params = params.clone();
    }
      
    public GNE_MCCO_CRM_Interaction_Controller() {
        super();
        iconBase64 = GNE_MCCO_CRM_Util.getDocumentBase64('Interaction_Tab_Icon');
    }

    public override GNE_MCCO_CRM_Base_Ctrl.DataWrapper init(Map<String, String> params) {
        attendeeSectionVisible = false;
        collabDetailsSectionVisible = false;
        threatsSectionVisible = false;
        materialSectionVisible = false;
        dependentMaterialsEnabled = false;
        dependentMaterialsPerAttProdEnabled = false;
        mealOptOutEnabled = false;
        unsolicitedReqFieldExists = false;
        simpleEditMode = false;
        strategyVisible = false;
        tacticVisible = false;
        multipleAccountsMode = params.containsKey('accountIds');
        newModeWithoutRecord = !params.containsKey('accountId') && !params.containsKey('id');
        return super.init(params);
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper initNewMode() {
        this.params.put('sObjectType', 'Call2_vod__c');
        return super.initNewMode();
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper getDataWrapper(GNE_MCCO_CRM_Base_Ctrl.DataWrapper dataWrapper) {
        DataWrapper result = (DataWrapper)super.getDataWrapper(dataWrapper);
        // General
        Call2_vod__c call = (Call2_vod__c)record;
        Boolean isCompleted = result.isCompleted = call.Interaction_Status_gne__c == 'Completed';
        Boolean hasUnsolicitedFieldEditAvailibleCanada = false;
        result.simpleEditMode = simpleEditMode = isCompleted && hasUnsolicitedFieldEditAvailibleCanada;
        result.multipleAccountsMode = multipleAccountsMode;
        // Multiple Accounts
        if (multipleAccountsMode) {
            result.multipleAccountsData = getMultipleAccountsData();
        } else if (!newModeWithoutRecord) {
            // Account
            result.callAccount = new AccountWrapper(callAccount);
            // Addresses
            result.addresses = getAddresses();
            // Attendees
            if (attendeeSectionVisible) {
                List<GNE_MCCO_CRM_Base_Ctrl.Field> attendeeColumns = getAttendeeColumns();
                List<GNE_MCCO_CRM_Base_Ctrl.Field> attendeeSearchColumns = getAttendeeSearchColumns();
                List<AttendeeOptionWrapper> attendeeOptions = getAttedeeOptions(attendeeColumns, attendeeSearchColumns);
                List<AttendeeWrapper> attendees = getSelectedAttendess(attendeeColumns);
                result.attendeeData = new AttendeeData(attendeeOptions, attendeeColumns, attendeeSearchColumns, attendees);
            }
        }

        // Collaboration Details
        if (collabDetailsSectionVisible) {
            List<GNE_MCCO_CRM_Base_Ctrl.Field> collabDetailsColumns = getCollabDetailsColumns();
            CollabDetailsWrapper collabTemplate = getCollabDetailsTemplate(collabDetailsColumns);        
            List<CollabDetailsOptionWrapper> collabOptions = getCollabDetailsOptions(collabDetailsColumns);
            List<CollabDetailsWrapper> collabDetailsWrappers = getCollabDetailsWrappers(collabDetailsColumns);
            List<CollabDetailsTactics> collabTactics = getCollabDetailsTactics();
            List<CollabDetailsMarketingMaterials> collabMarketingMaterials = getCollabDetailsMarketingMaterials();
            result.collabDetailsData = new CollabDetailsData(collabOptions, collabDetailsColumns, collabTemplate, collabDetailsWrappers, collabTactics, collabMarketingMaterials);
        }

        // Materials
        if(materialSectionVisible) {
            List<GNE_MCCO_CRM_Base_Ctrl.Field> columns = getMaterialsColumns();
            MaterialWrapper wrapperTemplate = getMaterialTemplate(columns);
            List<MaterialWrapper> materialWrappers = getMaterialWrappers(columns);
            Set<Id> productIds = new Set<Id>();
            for (MaterialWrapper mw : materialWrappers) {
                GNE_MCCO_CRM_Base_Ctrl.Field matId = mw.getField('Product_vod__c');
                if (matId != null && String.isNotEmpty(matId.value)) {
                    productIds.add(Id.valueOf(matId.value));
                }
            }
            List<MaterialProductItem> mProducts = getMaterialProducts(productIds);
            result.isMaterialPerAttendeeAndProductModeEnabled = dependentMaterialsPerAttProdEnabled;
            result.materialData = new MaterialData(columns, wrapperTemplate, materialWrappers, mProducts);
        }

        // Competitive Threats
        if (threatsSectionVisible) {
            List<GNE_MCCO_CRM_Base_Ctrl.Field> threatColumns = getThreatColumns();
            ThreatWrapper threatTemplate = getThreatTemplate(threatColumns);        
            List<ThreatOptionWrapper> threatOptions = getThreatOptions(threatColumns);
            List<ThreatWrapper> threatWrappers = getThreatWrappers(threatColumns);
            result.threatData = new ThreatData(threatOptions, threatColumns, threatTemplate, threatWrappers);
        }

        if (String.isNotBlank(call.Id)) {
            result.callName = call.Name;
            result.callId = call.Id;
        }                          

        return result;
    }

    private List<GNE_MCCO_CRM_Base_Ctrl.Field> getMaterialsColumns() {
        return materialsAdditionalFields;
    }

    private List<Call2_Sample_vod__c> getMeterials() {
        List<Call2_Sample_vod__c> result = null;
        Id callId = record.Id;

        if(String.isNotBlank(callId)) {
            Map<String,Schema.DescribeFieldResult> fieldsDescribe = getCallSampleFieldsDescribe();
            Set<String> materialFields = new Set<String>{'Call2_vod__c'};

            for (GNE_MCCO_CRM_Base_Ctrl.Field field : materialsAdditionalFields) {
                String fieldName = field.name.toLowerCase();
                materialFields.add(fieldName);

                if(fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                    materialFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                }
            }

            result = GNE_SFA2_Util.getDbWithoutSharingExecutor().executeQuery(
                    String.format('SELECT {0} FROM Call2_Sample_vod__c WHERE Call2_vod__c = {1} OR Call2_vod__r.Parent_Call_vod__c = {1}',
                            new String[]{String.join(new List<String>(materialFields), ','), '\'' + callId + '\''})
            );
        }

        return result;
    }

    public List<MaterialProductItem> getMaterialProducts(Set<Id> usedProductIds) {
        List<MaterialProductItem> result = new List<MaterialProductItem>();
        Set<String> invalidProductTypes = new Set<String>{'Detail', 'Market', 'Sample', 'PFG'};
        Map<Id, Product_vod__c> mProducts = new Map<Id, Product_vod__c>([
                SELECT Id, Name, Product_Type_vod__c, Parent_Product_vod__c, Active__c
                FROM Product_vod__c
                WHERE Parent_Product_vod__c IN :productIds
                AND Active__c = true
                AND Product_Type_vod__c NOT IN :invalidProductTypes
                ORDER BY Product_Type_vod__c, Name
        ]);

        Set<Id> missingIds = new Set<Id>();
        for (Id pid : usedProductIds) {
            if (!mProducts.containsKey(pid)) {
                missingIds.add(pid);
            }
        }

        if (missingIds.size() > 0) {
            /*
            * Additional query to append products which were previously selected by the user and are already associated with the interaction,
            * but can't be fetched by the base query above because of sharing rules or the product being inactive.
            */
            String queryStr = 'SELECT Name, Product_Type_vod__c, Parent_Product_vod__c, Active__c FROM Product_vod__c WHERE Id IN ' + GNE_SFA2_Util.createInListForQuery(missingIds);
            List<Product_vod__c> selectedProducts = GNE_SFA2_Util.getDbWithoutSharingExecutor().executeQuery(queryStr);
            for (Product_vod__c mProd : selectedProducts) {
                mProducts.put(mProd.Id, mProd);
            }
        }

        Set<String> visitedSamples = new Set<String>();
        for(Product_vod__c mProduct : mProducts.values()) {
            String sampleKey = ((dependentMaterialsEnabled && String.isNotBlank(mProduct.Parent_Product_vod__c) ? String.valueOf(mProduct.Parent_Product_vod__c) : '') + mProduct.Product_Type_vod__c + '_' + mProduct.Name).toUpperCase();
            if(!visitedSamples.contains(sampleKey)) {
                MaterialProductItem mpi = new MaterialProductItem(mProduct, dependentMaterialsEnabled);
                result.add(mpi);
                visitedSamples.add(sampleKey);
            }
        }

        result.sort();
        return result;
    }

    protected override String checkInputParam(String paramName) {
        String result = super.checkInputParam(paramName);

        if (paramName == 'accountId') {
            try {
                Id.valueOf(result);
            } catch (Exception e) {
                throw createException(new GNE_MCCO_CRM_Base_Ctrl.WrongInputParamTypeErrorException(), new Object[] {paramName, result, 'Id'});
            }
        }

        return result;
    }

    private DataWrapper getDataWrapperWithMultipleAccountsData() {
        DataWrapper result = (DataWrapper)(dataWrapper = getDataWrapperInstance());

        try {
            result.multipleAccountsData = getMultipleAccountsData();
        } catch (Exception ex) {
            handleException(ex);
        }

        result.onActionFinish('Get Multiple Accounts Data');
        return result;
    }

    private List<MultipleAccountWrapper> getMultipleAccountsData() {
        List<String> accountIds = params.get('accountIds').split(',');
        List<MultipleAccountWrapper> result = new List<MultipleAccountWrapper>();
        
        for (Account acc : [
            SELECT Id, Name, IsPersonAccount,
                    (SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c
                     FROM Contacts
                     WHERE Active_gne__c = true
                                           ORDER BY LastName NULLS LAST),
                    (SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c, PFG_BDTD_gne__c
                     FROM Address_vod__r
                     WHERE Inactive_vod__c = false AND Primary_vod__c = true
                                             LIMIT 1)
            FROM Account
            WHERE Id IN :accountIds]) {
            Address_vod__c addr = !acc.Address_vod__r.isEmpty() ? acc.Address_vod__r[0] : null;
            MultipleAccountWrapper accWrapper = new MultipleAccountWrapper(acc, addr);
            List<MultipleAttendeeWrapper> attendees = new List<MultipleAttendeeWrapper>();

            for (Contact con : acc.Contacts) {
                MultipleAttendeeWrapper attendeeWrapper = new MultipleAttendeeWrapper(con);
                accWrapper.attendees.add(attendeeWrapper);
            }

            result.add(accWrapper);
        }
        
        return result;
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.UserWrapper getCurrentUser() {
        currentUser = super.getCurrentUser();
        staticCurrentUserProfileName = getCurrentUserProfileName();
        return currentUser;
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.AppContext getAppContext() {
        if (appContext == null && getCurrentUserProfileName() == 'GNE-SYS-DataSupport-Merge') {
            GNE_SFA2_User_App_Context_gne__c appc = GNE_SFA2_Util.getApplicationContextByRecordOwner(params.get('id'));

            if (appc != null) {
                return new GNE_MCCO_CRM_Base_Ctrl.AppContext(currentUser, appc.App_Name_gne__c, appc.Brand_gne__c, appc.Role_gne__c);
            }
        }

        return super.getAppContext();
    }

    protected override SObject getRecord(List<SFA2_Configuration_Object_gne__c> configObjects) {
        callAccount = null;

        if (String.isNotBlank(recordId)) {
            Call2_vod__c call = [
                                    SELECT Id, Account_vod__c, Parent_Call_vod__c, Parent_Call_vod__r.Account_vod__c
            FROM Call2_vod__c WHERE Id = : recordId];
            recordId = String.isNotBlank(call.Parent_Call_vod__c) ? call.Parent_Call_vod__c : recordId;
            accountId = String.isNotBlank(call.Parent_Call_vod__c) ? call.Parent_Call_vod__r.Account_vod__c : call.Account_vod__c;
        } else if (multipleAccountsMode != true) {
            if (!newModeWithoutRecord) {
                accountId = checkInputParam('accountId');
            }
        }

        if (String.isNotBlank(accountId)) {
            callAccount = [
            SELECT Id, Name, IsPersonAccount,
            (SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c, PFG_BDTD_gne__c
            FROM Address_vod__r
                               WHERE Inactive_vod__c = false
            ORDER BY Name)
                              FROM Account WHERE Id = :accountId
                          ];
        }

        Call2_vod__c call = (Call2_vod__c)super.getRecord(configObjects);

        if (callAccount != null) {
                call.Account_vod__c = callAccount.Id;
                call.Account_vod__r = callAccount;
            }
            
        if (call.Id == null) {
            call.Call_Datetime_vod__c = Datetime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0);
            call.Interaction_Status_gne__c = 'Planned';
        }

        return call;
    }

    protected override GNE_MCCO_CRM_Base_Ctrl.ConfigItem readConfigObject(SFA2_Configuration_Object_gne__c conf, List<GNE_MCCO_CRM_Base_Ctrl.Button> buttons, List<GNE_MCCO_CRM_Base_Ctrl.Section> sections, List<GNE_MCCO_CRM_Base_Ctrl.RelatedList> relatedList) {

        GNE_MCCO_CRM_Base_Ctrl.ConfigItem ci;

        if (conf.Name == 'CallCollabDetails') {
            
            GNE_MCCO_CRM_Base_Ctrl.Section sec = new GNE_MCCO_CRM_Base_Ctrl.Section(conf, new List<GNE_MCCO_CRM_Base_Ctrl.Field>());

            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallCollaborationFieldsDescribe();
            collaborationAdditionalFields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_MCCO_CRM_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase());
                    collaborationAdditionalFields.add(new GNE_MCCO_CRM_Base_Ctrl.Field(confDetail, null, null, fieldDescribe, 'Call2_Discussion_vod__c'));
                }
            }

            sec.fields = collaborationAdditionalFields;
            sections.add(sec);
            ci = sec;
        } else if(conf.Name == 'CallMaterials') {
            materialSectionVisible = true;
            dependentMaterialsEnabled = getCurrentUser().isCanada();
            GNE_MCCO_CRM_Base_Ctrl.Section sec = new GNE_MCCO_CRM_Base_Ctrl.Section(conf, new List<GNE_MCCO_CRM_Base_Ctrl.Field>());
            sections.add(sec);
            ci = sec;

            Map<String,Schema.DescribeFieldResult> fieldsDescribe = getCallSampleFieldsDescribe();
            materialsAdditionalFields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if(confDetail.Type_gne__c == GNE_MCCO_CRM_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase());
                    materialsAdditionalFields.add(new GNE_MCCO_CRM_Base_Ctrl.Field(confDetail, null, null, fieldDescribe, 'Call2_Sample_vod__c'));
                }
            }

            Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get('Contact_vod__c'.toLowerCase());
            materialsAdditionalFields.add(new GNE_MCCO_CRM_Base_Ctrl.Field('Contact', null, true, false, fieldDescribe, 'Call2_Sample_vod__c'));
        } else if (conf.Name == 'CallThreats') {
            GNE_MCCO_CRM_Base_Ctrl.Section sec = new GNE_MCCO_CRM_Base_Ctrl.Section(conf, new List<GNE_MCCO_CRM_Base_Ctrl.Field>());

            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallThreatFieldsDescribe();
            threatAdditionalFields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_MCCO_CRM_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase());
                    threatAdditionalFields.add(new GNE_MCCO_CRM_Base_Ctrl.Field(confDetail, null, null, fieldDescribe, 'Call2_Threat_vod__c'));
                }
            }

            sec.fields = threatAdditionalFields;
            sections.add(sec);
            ci = sec;
        } else {
            ci = super.readConfigObject(conf, buttons, sections, relatedList);
        }

        GNE_MCCO_CRM_Base_Ctrl.Section section = ci!=null && ci instanceof GNE_MCCO_CRM_Base_Ctrl.Section ? (GNE_MCCO_CRM_Base_Ctrl.Section)ci : null;

        mealOptOutEnabled |= (conf.Name == 'CallMealExpense' && String.isNotBlank(conf.Attributes_gne__c) && conf.Attributes_gne__c.contains('--mealOptOut'));
        attendeeSectionVisible |= conf.Name == 'CallAttendees';
        collabDetailsSectionVisible |= conf.Name == 'CallCollabDetails';
        threatsSectionVisible |= conf.Name == 'CallThreats';

        dependentMaterialsPerAttProdEnabled |= (conf.Name == 'CallMaterials' && section.attributeFlags != null && section.attributeFlags.contains('attproddependend') && record != null && String.valueOf(record.get('Interaction_Status_gne__c')) != 'Completed' && callAccount != null && callAccount.IsPersonAccount);


        if (ci != null && ci instanceof GNE_MCCO_CRM_Base_Ctrl.Section && ci.attributeFlags != null && ci.attributeFlags.contains('hideHeader')) {
            ci.label = null;
        }

        if (ci != null && ci instanceof GNE_MCCO_CRM_Base_Ctrl.Section && ci.name == 'CallDetail') {
            String unsolicitedReqField = String.valueOf(Call2_vod__c.Unsolicited_Request_gne__c);

            for (GNE_MCCO_CRM_Base_Ctrl.Field field : ((GNE_MCCO_CRM_Base_Ctrl.Section)ci).fields) {
                if (field.name == unsolicitedReqField) {
                    unsolicitedReqFieldExists = true;
                    break;
                } else if (field.name == String.valueOf(Call2_vod__c.HCP_Account_Meal_Opt_Out_gne__c) && callAccount != null && !callAccount.IsPersonAccount) {
                    field.changeToBlankSpace();
                }
            }
        } else if (ci != null && ci instanceof GNE_MCCO_CRM_Base_Ctrl.Section && ci.name == 'CallAttendees') {
            attendeesAdditionalFields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();
            List<GNE_MCCO_CRM_Base_Ctrl.Field> fields = ((GNE_MCCO_CRM_Base_Ctrl.Section)ci).fields;

            for (Integer i = fields.size() - 1; i >= 0; i--) {
                GNE_MCCO_CRM_Base_Ctrl.Field field = fields[i];

                if (field.attributeFlags != null && field.attributeFlags.contains('columnField')) {
                    fields.remove(i);
                }

                attendeesAdditionalFields.add(field);
            }
        } else if (ci != null && ci instanceof GNE_MCCO_CRM_Base_Ctrl.Section && ci.name == 'CallMealExpense') {
            ((DataWrapper)dataWrapper).mealExpenseLabel = System.Label.GNE_SFA2_Meal_Opt_Out_Acknowledgement_Statement;
        }
        
        return ci;
    }

    protected override Set<String> getQueryFieldsFromConfigObject(SFA2_Configuration_Object_gne__c conf) {
        Set<String> fieldNames = new Set<String>();
        if (conf.Name == 'CallAttendees') {
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getSObjectFieldsDescribe();
            Set<String> attendeeFields = new Set<String> {'id', 'name', 'account_vod__c', 'ems_international_speaker_gne__c', 'contact_vod__c', 'user_vod__c',
                    'attendee_type_vod__c', 'hcp_attendee_meal_opt_out_gne__c', 'hcp_or_attendee_meal_opt_out_gne__c', 'attendee_type_fpm_gne__c'
                                                         };


            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_MCCO_CRM_Base_Ctrl.FIELD && confDetail.Attributes_gne__c != null && confDetail.Attributes_gne__c.contains('--columnField') && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();
                    attendeeFields.add(fieldName);
                }
            }

            for (String fieldName : attendeeFields) {
                if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                    attendeeFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                }
            }

            fieldNames.add(String.format('(SELECT {0} FROM Call2_vod__r)', new String[] {String.join(new List<String>(attendeeFields), ',')}));
        } else if (conf.Name == 'CallObjectives') {
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallDiscussionFieldsDescribe();
            Set<String> objectiveFields = new Set<String> {'recordtypeid', 'zvod_Product_Map_vod__c'};

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_MCCO_CRM_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();
                    objectiveFields.add(fieldName);

                    if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                        objectiveFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                    }
                }
            }

            fieldNames.add(String.format('(SELECT {0} FROM Call2_Discussion_vod__r WHERE Product_vod__c != null ORDER BY {1})', new String[] {String.join(new List<String>(objectiveFields), ','), String.valueOf(Call2_Discussion_vod__c.Detail_Priority_gne__c)}));
        } else if (conf.Name == 'CallProducts') {
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Detail_vod__r WHERE Product_vod__c != null ORDER BY {1})', new String[] {String.join(new List<String>{'Id', 'Product_vod__c', 'Product_vod__r.Name'}, ','), String.valueOf(Call2_Detail_vod__c.Detail_Priority_vod__c)}));
        } else if (conf.Name == 'CallCollabDetails') {
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallCollaborationFieldsDescribe();
            Set<String> callCollabFields = new Set<String> {'recordtypeid'};

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_MCCO_CRM_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();
                    callCollabFields.add(fieldName);

                    if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                        callCollabFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                    }
                }
            }

            for (String fieldName : callCollabFields) {
                if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                    callCollabFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                }
            }
                        
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Discussion_vod__r ORDER BY {1})', new String[] {String.join(new List<String>(callCollabFields), ','), String.valueOf(Call2_Discussion_vod__c.Detail_Priority_gne__c)}));
        } else if (conf.Name == 'CallThreats') {
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallThreatFieldsDescribe();
            Set<String> callThreatFields = new Set<String> {};

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_MCCO_CRM_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();
                    callThreatFields.add(fieldName);

                    if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                        callThreatFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                    }
                }
            }

            for (String fieldName : callThreatFields) {
                if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                    callThreatFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                }
            }
                        
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Threat_vod__r ORDER BY {1})', new String[] {String.join(new List<String>(callThreatFields), ','), String.valueOf(Call2_Threat_vod__c.Detail_Priority__c)}));
        } else {
            fieldNames.addAll(super.getQueryFieldsFromConfigObject(conf));
        }        

        return fieldNames;
    }

    private List<AddressWrapper> getAddresses() {
        List<AddressWrapper> result = new List<AddressWrapper>();

        for (Address_vod__c address : callAccount.Address_vod__r) {
            result.add(new AddressWrapper(address));
        }

        return result;
    }

    private Map<String, Schema.DescribeFieldResult> getCallDiscussionFieldsDescribe() {
        cacheCallDiscussionFieldsDescribe();
        return callDiscussionFieldsDescribe;
    }

    private Id getCallDiscussionRecordTypeId() {
        cacheCallDiscussionFieldsDescribe();
        return callDiscussionRecordTypeId;
    }

    private void cacheCallDiscussionFieldsDescribe() {
        if (callDiscussionFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Call2_Discussion_vod__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            callDiscussionFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                callDiscussionFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }

            for (Schema.RecordTypeInfo rtInfo : sObjectDescribe.getRecordTypeInfos()) {
                if (rtInfo.isDefaultRecordTypeMapping()) {
                    callDiscussionRecordTypeId = rtInfo.getRecordTypeId();
                }

                if (rtInfo.getName() == recordType.Name) {
                    callDiscussionRecordTypeId = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }
    }
    
    private Map<String, Schema.DescribeFieldResult> getCallCollaborationFieldsDescribe() {
        cacheCallCollaborationFieldsDescribe();
        return callCollaborationFieldsDescribe;
    }

    private Id getCallCollaborationRecordTypeId() {
        cacheCallCollaborationFieldsDescribe();
        return callCollaborationRecordTypeId;
    }

    private void cacheCallCollaborationFieldsDescribe() {
        if (callCollaborationFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Call2_Discussion_vod__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            callCollaborationFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                callCollaborationFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }

            for (Schema.RecordTypeInfo rtInfo : sObjectDescribe.getRecordTypeInfos()) {
                if (rtInfo.isDefaultRecordTypeMapping()) {
                    callCollaborationRecordTypeId = rtInfo.getRecordTypeId();
                }

                if (rtInfo.getName() == recordType.Name) {
                    callCollaborationRecordTypeId = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }
    }    
    
    private Map<String, Schema.DescribeFieldResult> getCallThreatFieldsDescribe() {
        cacheCallThreatFieldsDescribe();
        return callThreatFieldsDescribe;
    }

    private void cacheCallThreatFieldsDescribe() {
        if (callThreatFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Call2_Threat_vod__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            callThreatFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                callThreatFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }

            for (Schema.RecordTypeInfo rtInfo : sObjectDescribe.getRecordTypeInfos()) {
                if (rtInfo.isDefaultRecordTypeMapping()) {
                    callThreatRecordTypeId = rtInfo.getRecordTypeId();
                }

                if (rtInfo.getName() == recordType.Name) {
                    callThreatRecordTypeId = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }
    }  

    private Map<String, Schema.DescribeFieldResult> getCallSampleFieldsDescribe() {
        cacheCallSampleFieldsDescribe();
        return callSampleFieldsDescribe;
    }

    private void cacheCallSampleFieldsDescribe() {
        if (callSampleFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Call2_Sample_vod__c.sObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            callSampleFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                callSampleFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
        }
    }

    private List<GNE_MCCO_CRM_Base_Ctrl.Field> getAttendeeColumns() {
        List<GNE_MCCO_CRM_Base_Ctrl.Field> result = new List<GNE_MCCO_CRM_Base_Ctrl.Field> {
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeName', 'Attendee'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeType', 'Type')
        };

        if (getIsFPMProfile()) {
            result.add(new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeTypeFPM', 'Attendee Type'));
        }

        if (mealOptOutEnabled) {
            result.add(new GNE_MCCO_CRM_Base_Ctrl.Field('HCP_Attendee_Meal_Opt_Out_gne__c', 'Meal Opt Out', null, null, null, null, false, false, null, new GNE_MCCO_CRM_Base_Ctrl.FieldDescribe(Call2_vod__c.HCP_Attendee_Meal_Opt_Out_gne__c.getDescribe(), sObjectType)));
        }

        result.addAll(attendeesAdditionalFields);
        return result;
    }

    private List<GNE_MCCO_CRM_Base_Ctrl.Field> getAttendeeSearchColumns() {
        List<GNE_MCCO_CRM_Base_Ctrl.Field> result = new List<GNE_MCCO_CRM_Base_Ctrl.Field> {
            new GNE_MCCO_CRM_Base_Ctrl.Field('name', 'Name'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('address', 'Address'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeType', 'Type')
        };

        if (getIsFPMProfile()) {
            result.add(new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeTypeFPM', 'Attendee Type'));
        }

        return result;
    }

    private List<AttendeeOptionWrapper> getAttedeeOptions(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
        List<AttendeeOptionWrapper> result = new List<AttendeeOptionWrapper>();
        Call2_vod__c call = (Call2_vod__c)record;
        Id accountId = call.Account_vod__c;
        Set<Id> resultIds = new Set<Id>();
        Integer resultSizeLimit = 100;

            for (Contact con : [
                SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c
                FROM Contact
                WHERE AccountId = :accountId AND Active_gne__c = true
                ORDER BY LastName NULLS LAST]) {
                AttendeeOptionWrapper aow = new AttendeeOptionWrapper(con, columns, searchColumns);
                result.add(aow);
                resultIds.add(con.Id);

            
                if(resultIds.size() == resultSizeLimit) {
                    break;
                }
            }
        return result;
    }

    private List<AttendeeWrapper> getSelectedAttendess(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
        List<AttendeeWrapper> result = new List<AttendeeWrapper>();
        Call2_vod__c call = (Call2_vod__c)record;

        if (call.Call2_vod__r != null) {
            for (Call2_vod__c attendeeCall : call.Call2_vod__r) {
                    AttendeeWrapper aw = new AttendeeWrapper(attendeeCall, columns);
                    result.add(aw);
            }
        }

        return result;
    }

    private List<GNE_MCCO_CRM_Base_Ctrl.Field> getCollabDetailsColumns() {
        return collaborationAdditionalFields;
    }    


    private CollabDetailsWrapper getCollabDetailsTemplate(List<GNE_MCCO_CRM_Base_Ctrl.Field> collabColumns) {
        Id recordTypeId = getCallCollaborationRecordTypeId();       
        return new CollabDetailsWrapper('0', new Call2_Discussion_vod__c(), recordTypeId, collabColumns);
    }

    private List<CollabDetailsOptionWrapper> getCollabDetailsOptions(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
        List<CollabDetailsOptionWrapper> result = new List<CollabDetailsOptionWrapper>();
        productIds = new Set<Id>();
        Id userId = currentUser.id;
        Integer idx = 0;

        for (My_Setup_Products_vod__c msRec : [
                    SELECT Product_vod__c, Product_vod__r.Id, Product_vod__r.Name, Product_vod__r.Product_Type_vod__c
                    FROM My_Setup_Products_vod__c
                    WHERE ownerId = :userId AND Product_vod__c != null AND Product_vod__r.Name != null
                                    ORDER BY Product_vod__r.Name]) {
            CollabDetailsOptionWrapper pow = new CollabDetailsOptionWrapper(msRec.Product_vod__c, msRec.Product_vod__r, getCallCollaborationRecordTypeId(), columns);
            result.add(pow);
            productIds.add(msRec.Product_vod__c);
        }

        return result;
    }

    private List<CollabDetailsWrapper> getCollabDetailsWrappers(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
        List<CollabDetailsWrapper> result = new List<CollabDetailsWrapper>();

        Call2_vod__c call = (Call2_vod__c)record;

        if (call.Call2_Discussion_vod__r != null) {
            Integer idx = 0;
            for (Call2_Discussion_vod__c cd : call.Call2_Discussion_vod__r) {
                CollabDetailsWrapper cdw = new CollabDetailsWrapper(cd.Id + String.valueOf(idx++), cd, cd.RecordTypeId, columns);
                result.add(cdw);
            }
        }
        return result;
    }
    
    private List<CollabDetailsTactics> getCollabDetailsTactics() {
        List<CollabDetailsTactics> result = new List<CollabDetailsTactics>();
        List<String> names = new List<String>(GNE_MCCO_CRM_Tactics__c.getAll().keySet());
        names.sort();
        for (String name : names) {
            CollabDetailsTactics tt = new CollabDetailsTactics(GNE_MCCO_CRM_Tactics__c.getAll().get(name).Meeting_Objective__c, GNE_MCCO_CRM_Tactics__c.getAll().get(name).Tactic__c);
            result.add(tt);
        }
        return result;
    }
    
    private List<CollabDetailsMarketingMaterials> getCollabDetailsMarketingMaterials() {
        List<CollabDetailsMarketingMaterials> result = new List<CollabDetailsMarketingMaterials>();
        for (GNE_MCCO_CRM_Products_Materials__c rec : [
                    SELECT Meeting_Objective__c, Product__c, Marketing_Material__c
                    FROM GNE_MCCO_CRM_Products_Materials__c
                    ORDER BY Meeting_Objective__c, Product__c, Marketing_Material__c ]) {
            CollabDetailsMarketingMaterials tmm = new CollabDetailsMarketingMaterials(rec.Meeting_Objective__c, rec.Product__c, rec.Marketing_Material__c);
            result.add(tmm);
        }
        return result;
    }    
    
    private List<GNE_MCCO_CRM_Base_Ctrl.Field> getThreatColumns() {
        return threatAdditionalFields;
    }    


    private ThreatWrapper getThreatTemplate(List<GNE_MCCO_CRM_Base_Ctrl.Field> threatColumns) {
        return new ThreatWrapper('0', new Call2_Threat_vod__c(), threatColumns);
    }

    private List<ThreatOptionWrapper> getThreatOptions(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
        List<ThreatOptionWrapper> result = new List<ThreatOptionWrapper>();
        productIds = new Set<Id>();
        Id userId = currentUser.id;
        Integer idx = 0;

        for (My_Setup_Products_vod__c msRec : [
                    SELECT Product_vod__c, Product_vod__r.Id, Product_vod__r.Name, Product_vod__r.Product_Type_vod__c
                    FROM My_Setup_Products_vod__c
                    WHERE ownerId = :userId AND Product_vod__c != null AND Product_vod__r.Name != null
                                    ORDER BY Product_vod__r.Name]) {
            ThreatOptionWrapper pow = new ThreatOptionWrapper(msRec.Product_vod__c, msRec.Product_vod__r, columns);
            result.add(pow);
            productIds.add(msRec.Product_vod__c);
        }

        return result;
    }

    private List<ThreatWrapper> getThreatWrappers(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
        List<ThreatWrapper> result = new List<ThreatWrapper>();

        Call2_vod__c call = (Call2_vod__c)record;

        if (call.Call2_Threat_vod__r != null) {
            Integer idx = 0;
            for (Call2_Threat_vod__c cd : call.Call2_Threat_vod__r) {
                ThreatWrapper cdw = new ThreatWrapper(cd.Id + String.valueOf(idx++), cd, columns);
                result.add(cdw);
            }
        }
        return result;
    }
    
    private DataWrapper searchAttendees(Map<String, Object> params) {
        dataWrapper = getDataWrapperInstance();

        try {
            dataWrapper = intSearchAttendees(params);
        } catch (Exception ex) {
            handleException(ex);
        }

        dataWrapper.onActionFinish('Search Attendees');
        return (DataWrapper)dataWrapper;
    }

    private DataWrapper intSearchAttendees(Map<String, Object> params) {
        List<AttendeeOptionWrapper> attendees = new List<AttendeeOptionWrapper>();
        String searchPhrase = (String)params.get('searchPhrase');
        Integer recordsLimit = ((Decimal)params.get('recordsLimit')).intValue();
        Boolean onlyPersonAccounts = (Boolean)params.get('onlyPersonAccounts');
        Id accountId = (String)params.get('accountId');
        Id userId = (String)params.get('userId');
        String mode = (String)params.get('mode');
        dataWrapper.appContext = (GNE_MCCO_CRM_Base_Ctrl.AppContext)JSON.deserialize((String)params.get('appContext'), GNE_MCCO_CRM_Base_Ctrl.AppContext.class);
        List<GNE_MCCO_CRM_Base_Ctrl.Field> columns = (List<GNE_MCCO_CRM_Base_Ctrl.Field>)JSON.deserialize((String)params.get('attendeeColumns'), List<GNE_MCCO_CRM_Base_Ctrl.Field>.class);
        List<GNE_MCCO_CRM_Base_Ctrl.Field> searchcolumns = (List<GNE_MCCO_CRM_Base_Ctrl.Field>)JSON.deserialize((String)params.get('searchColumns'), List<GNE_MCCO_CRM_Base_Ctrl.Field>.class);
        staticCurrentUserProfileName =  dataWrapper.appContext.currentUser.profileName;

        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> saws = searchContactsAccountsFromUserTerritories(searchPhrase, recordsLimit, new List<Id> {accountId}, String.isNotBlank(userId) ? userId : UserInfo.getUserId());

        for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper saw : saws) {
            attendees.add(new AttendeeOptionWrapper(saw, columns, searchColumns));
        }

        ((DataWrapper)dataWrapper).attendeeData = new AttendeeData(attendees, columns, searchColumns, null);
        return (DataWrapper)dataWrapper;
    }

    private List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchContactsAccountsFromUserTerritories(String searchString, Integer recordLimit, List<Id> ignoredIds, Id userId) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
        Set<String> terrNames = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Address_vod__c> addressesMap = new Map<Id, Address_vod__c>();
        
        for (Territory2 t : GNE_SFA2_Util.getUserTerritories(userId)) {
            terrNames.add(t.Name);
        }

        for (TSF_vod__c tsf : [SELECT Account_vod__c, Address_vod__c, Address_vod__r.Name, Address_vod__r.City_vod__c, Address_vod__r.State_vod__c, Address_vod__r.Zip_vod__c  FROM TSF_vod__c WHERE Territory_vod__c in :terrNames]) {
            accountIds.add(tsf.Account_vod__c);
            if(String.isNotBlank(tsf.Address_vod__c) && !addressesMap.containsKey(tsf.Account_vod__c)) {
                addressesMap.put(tsf.Account_vod__c, new Address_vod__c(
                                                                Name = tsf.Address_vod__r.Name,
                                                                City_vod__c = tsf.Address_vod__r.City_vod__c,
                                                                State_vod__c = tsf.Address_vod__r.State_vod__c,
                                                                Zip_vod__c = tsf.Address_vod__r.Zip_vod__c
                                                            ));
            }
        }

        // Search Contacts
        String queryString = 'SELECT Id, FirstName, LastName, Name, AccountId, MailingStreet, MailingCity, State_Province_gne__c, MailingPostalCode, MailingCountry, IsPersonAccount FROM Contact WHERE Name LIKE :searchString AND AccountId IN :accountIds AND isPersonAccount=false ORDER BY Name limit :recordLimit';
        for (Contact c : Database.query(queryString)) {
            if (result.size() == recordLimit) {
                break;
            }
            
            if(String.isNotBlank(c.MailingStreet) || String.isNotBlank(c.MailingCity) || String.isNotBlank(c.State_Province_gne__c) || String.isNotBlank(c.MailingPostalCode)) {
                result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(c, new Address_vod__c(
                                                                                                                Name = c.MailingStreet,
                                                                                                                City_vod__c = c.MailingCity,
                                                                                                                State_vod__c = c.State_Province_gne__c,
                                                                                                                Zip_vod__c = c.MailingPostalCode
                                                                                                            )));
            } else if (addressesMap.containsKey(c.AccountId)) {
                result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(c, addressesMap.get(c.AccountId)));
            } else {
                result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(c, null));
            }
        }

        // Search Accounts
        if(result.size() < recordLimit) {
            queryString = 'SELECT Id, FirstName, LastName, Territory_vod__c, Name, IsPersonAccount FROM Account WHERE  Name LIKE :searchString AND Id IN :accountIds AND id NOT IN :ignoredIds AND isPersonAccount=true ORDER BY Name limit :recordLimit';
            for (Account a : Database.query(queryString)) {
                if (result.size() == recordLimit) {
                    break;
                }

                if (addressesMap.containsKey(a.Id)) {
                    result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(a, addressesMap.get(a.Id)));
                } else {
                    result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(a, null));
                }
            }
        }

        return result;

    }

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper intSaveRecord() {
        accountIdToCallMap = new Map<Id, Call2_vod__c>();
        hcpIdToCallMap = new Map<Id,Call2_vod__c>();
        contactIdToCallMap = new Map<Id,Call2_vod__c>();
        mainCallsToUpsert = new List<Call2_vod__c>();
        dataWrapper = super.intSaveRecord();
        DataWrapper resultData = (DataWrapper)dataWrapper;
        DataWrapper saveData = (DataWrapper)inputDataWrapper;

        if (resultData.success) {
            if (saveData.attendeeData != null || saveData.multipleAccountsData != null) {
                saveAttendees();
                resultData.attendeeData = saveData.attendeeData;
            }

            if (saveData.collabDetailsData != null) {
                saveCollabDetails();
                resultData.collabDetailsData = saveData.collabDetailsData;
            }

            if (saveData.threatData != null) {
                saveThreats();
                resultData.threatData = saveData.threatData;
            }

            if(saveData.materialData!=null) {
                saveMaterials();
                resultData.materialData = saveData.materialData;
            }

            deleteChildRecords();
            upsertChildRecords();

            resultData.simpleEditMode = saveData.simpleEditMode == true || saveData.completeMode == true;
            resultData.isCompleted = saveData.completeMode == true;
            resultData.callName = String.isNotBlank(saveData.callName) ? saveData.callName : (String)recordAfterSave.get('Name');
            resultData.callId = String.isNotBlank(saveData.callId) ? saveData.callId : (String)recordAfterSave.get('Id');

            if (saveData.multipleAccountsMode == true) {
                resultData.retUrl = Page.GNE_MCCO_CRM_MyAccounts.getUrl();
            }
        }

        return dataWrapper;
    }

    protected override void upsertRecord() {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        Call2_vod__c call = (Call2_vod__c)record;

        if (saveData.multipleAccountsMode == true) {
            for (MultipleAccountWrapper callAccount : saveData.multipleAccountsData) {
                call.Account_vod__c = callAccount.id;
                setCallAddress(call, callAccount.address);
                accountIdToCallMap.put(call.Account_vod__c, call);
                mainCallsToUpsert.add(call);
                call = call.clone();
            }

            executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.UPS, mainCallsToUpsert);
        } else {
            call.Account_vod__c = saveData.callAccount.id;
            accountIdToCallMap.put(call.Account_vod__c, call);
            mainCallsToUpsert.add(call);
            super.upsertRecord();
        }
    }

    private void upsertChildRecords() {
        executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.UPS, detailsToUpsert);
        executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.UPS, collabsToUpsert);
        executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.UPS, threatsToUpsert);
        executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.UPS, materialsToUpsert);
    }

    private void deleteChildRecords() {
        if (childRecordsToRemoveMap != null && !childRecordsToRemoveMap.isEmpty()) {
            Set<Id> deletedAttendeeIds = new Set<Id>();

            for (SObject rec : childRecordsToRemoveMap.values()) {
                if (rec instanceof Call2_vod__c) {
                    deletedAttendeeIds.add(rec.Id);
                }
            }

            for (SObject rec : new List<SObject>(childRecordsToRemoveMap.values())) {
                if (!(rec instanceof Call2_vod__c) && deletedAttendeeIds.contains((Id)rec.get('Call2_vod__c'))) {
                    childRecordsToRemoveMap.remove(rec.Id);
                }
            }

            executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.DEL, childRecordsToRemoveMap.values());
        }
    }

    protected override void updateRecordFields() {
        super.updateRecordFields();
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        Call2_vod__c call = (Call2_vod__c)record;

        if (saveData.completeMode == true) {
            call.Completed_gne__c = true;
            call.Interaction_Status_gne__c = 'Completed';
            call.Date_Completed_gne__c = Date.today();
        }

        call.HCP_OR_Attendee_Meal_Opt_Out_gne__c = call.HCP_Account_Meal_Opt_Out_gne__c == true;

        if (saveData.attendeeData != null) {
            call.Attendees_vod__c = saveData.attendeeData.rows.size();
            AccountWrapper accWrapper = saveData.callAccount;
            if (accWrapper.isPersonAccount) {
                call.Attendee_Type_vod__c = 'Person_Account_vod';
                call.Attendees_vod__c += 1;
            } else if (call.EMS_International_Speaker_gne__c != null) {
                call.Attendee_Type_vod__c = 'iHCP_Account_vod';
                call.Attendees_vod__c += 1;
            } else {
                call.Attendee_Type_vod__c = 'Group_Account_vod';
            }

            if (!call.HCP_OR_Attendee_Meal_Opt_Out_gne__c) {
                for (AttendeeWrapper wrapper : saveData.attendeeData.rows) {
                    GNE_MCCO_CRM_Base_Ctrl.Field fld = wrapper.getField('HCP_Attendee_Meal_Opt_Out_gne__c');
                    Boolean isAttendeeMealOptOut = fld != null && fld.getValue() == true;
                    if (isAttendeeMealOptOut) {
                        call.HCP_OR_Attendee_Meal_Opt_Out_gne__c = true;
                        break;
                    }
                }
            }
        }

        if (saveData.collabDetailsData != null) {
            List<String> productNames = new List<String>();
            Set<String> visitedProdNames = new Set<String>();
            for (CollabDetailsWrapper cw : saveData.collabDetailsData.rows) {
                GNE_MCCO_CRM_Base_Ctrl.Field fld = cw.getField('Product_vod__c');

                if (String.isNotBlank(fld.displayValue)) {
                    productNames.add(fld.displayValue);
                    visitedProdNames.add(fld.displayValue);
                }
            }

            call.Detailed_Products_vod__c = String.join(productNames, '  ').abbreviate(Call2_vod__c.Detailed_Products_vod__c.getDescribe().getLength());
        }
        

        if (saveData.multipleAccountsMode != true) {
            for (AddressWrapper addrWrapper : saveData.addresses) {
                if (addrWrapper.value == call.Parent_Address_vod__c) {
                    setCallAddress(call, addrWrapper);
                    break;
                }
            }
        }
    }

    private void setCallAddress(Call2_vod__c call, AddressWrapper addrWrapper) {
        setCallAddress(call, addrWrapper != null ? addrWrapper.getAddressRecord() : null);
    }

    private void setCallAddress(Call2_vod__c call, Address_vod__c callAddress) {
        if (callAddress != null) {
            DataWrapper saveData = (DataWrapper)inputDataWrapper;
            call.Parent_Address_vod__c = callAddress.Id;
            call.Parent_Address_vod__r = callAddress;
            call.Address_vod__c =  GNE_SFA2_Util.getAddressAsString(callAddress);
            call.Address_Line_1_vod__c = callAddress.Name;
            call.Address_line_2_vod__c = callAddress.Address_line_2_vod__c;
            call.Zip_4_vod__c = callAddress.Zip_4_vod__c;
            call.Zip_vod__c = callAddress.Zip_vod__c;
            call.City_vod__c = callAddress.City_vod__c;
            call.State_vod__c = callAddress.State_vod__c;

            if (saveData.isCompleted != true) {
                call.PFG_BDTD_gne__c = callAddress.PFG_BDTD_gne__c;
            }
        }
    }

    protected override Boolean validateRecord() {
        Boolean result = super.validateRecord();
        Call2_vod__c call = (Call2_vod__c)record;

        if (result && call.HCP_OR_Attendee_Meal_Opt_Out_gne__c == true) {
            result = validateMealOptOut();
        }

        return result;
    }

    private Boolean validateMealOptOut() {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        Call2_vod__c call = (Call2_vod__c)record;
        Boolean isValid = true;
        Integer attendeesMealOptOutSize = 0;
        Integer allAttendees = 0;

        if (saveData.attendeeData != null) {
            for (AttendeeWrapper wrapper : saveData.attendeeData.rows) {
                GNE_MCCO_CRM_Base_Ctrl.Field fld = wrapper.getField('HCP_Attendee_Meal_Opt_Out_gne__c');
                Boolean isAttendeeMealOptOut = fld != null && fld.getValue() == true;

                if (isAttendeeMealOptOut) {
                    attendeesMealOptOutSize++;
                }

                allAttendees++;
            }
        }

        if (call.Meal_Expense_gne__c != true && (call.HCP_Account_Meal_Opt_Out_gne__c == true || attendeesMealOptOutSize > 0)) {
            dataWrapper.addError(createException(new MealOptOutEventNotCompletedException()));
            isValid = false;
        } else if (call.Meal_Expense_gne__c == true && saveData.attendeeData != null) {
            if (saveData.callAccount.isPersonAccount == true && call.HCP_Account_Meal_Opt_Out_gne__c != true) {
                attendeesMealOptOutSize++;
            }
            //When Meal Out Opt is selected: Actual Meal Recipients number entered must be greater than, or equal to, the number of people who were not opted out of a meal expense + the CS
            if (call.Actual_Attendees_gne__c == null ||  call.Actual_Attendees_gne__c < ((allAttendees - attendeesMealOptOutSize) + 1)) {
                dataWrapper.addError(createException(new MealOptOutActualMealRecipientException()));
                isValid = false;
            }

        }

        return isValid;
    }

    protected override Set<String> getQueryFieldsAfterSave() {
        Set<String> fieldNames = super.getQueryFieldsAfterSave();
        fieldNames.add('account_vod__c');
        fieldNames.add('contact_vod__c');
        fieldNames.add('user_vod__c');
        fieldNames.add('ems_international_speaker_gne__c');
        fieldNames.add('parent_call_vod__c');
        DataWrapper saveData = (DataWrapper)inputDataWrapper;

        if (saveData.collabDetailsData != null) {
            fieldNames.add('(SELECT Id, Call2_vod__c, Detail_Priority_gne__c FROM Call2_Discussion_vod__r)');
            fieldNames.add('(SELECT Id, Call2_vod__c, Product_vod__c FROM Call2_Detail_vod__r)');
        }

        if (saveData.threatData != null) {
            fieldNames.add('(SELECT Id, Call2_vod__c, Detail_Priority__c FROM Call2_Threat_vod__r)');
            fieldNames.add('(SELECT Id, Call2_vod__c, Product_vod__c FROM Call2_Detail_vod__r)');
        }

        if(saveData.materialData!=null) {
            Set<String> childFieldNames = new Set<String>{
                    String.valueOf(Call2_Sample_vod__c.Id).toLowerCase(), String.valueOf(Call2_Sample_vod__c.iPhone_Request_Id_gne__c).toLowerCase(),
                    String.valueOf(Call2_Sample_vod__c.Call2_vod__c).toLowerCase(), String.valueOf(Call2_Sample_vod__c.Product_vod__c).toLowerCase(), String.valueOf(Call2_Sample_vod__c.Account_vod__c).toLowerCase()
            };
            childFieldNames.addAll(getFieldNamesFromRows(saveData.materialData.rows));
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Sample_vod__r)', new String[]{String.join(new List<String>(childFieldNames),',')}));
        }

        return fieldNames;
    }

    public Set<String> getFieldNamesFromRows(List<TableRowWrapper> rows) {
        Set<String> result = new Set<String>();

        if(rows!=null) {
            for(TableRowWrapper row : rows) {
                result.addAll(row.getFieldNames());
            }
        }

        return result;
    }

    protected override SObject getRecordAfterSave(Set<String> fieldNames) {
        SObject result = null;
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        List<Call2_vod__c> callAndAttendess = Database.query(String.format('SELECT {0} FROM {1} WHERE Id = :recordId{2}', new String[] {
                                                  String.join(new List<String>(fieldNames), ','),
                                                  sObjectType,
                                                  saveData.attendeeData != null ? ' OR Parent_Call_vod__c = :recordId' : ''
                                              }));

        for (Call2_vod__c call : callAndAttendess) {
            if (call.Parent_Call_vod__c == null) {
                result = call;
            } else if (saveData.attendeeData != null) {
                cacheChildRecordAfterSave(call);
            }

            if (saveData.collabDetailsData != null) {
                cacheChildRecordsAfterSave(call.Call2_Discussion_vod__r);
                cacheChildRecordsAfterSave(call.Call2_Detail_vod__r);
            }

            if(saveData.materialData!=null) {
                cacheChildRecordsAfterSave(call.Call2_Sample_vod__r);
            }

            if (saveData.threatData != null) {
                cacheChildRecordsAfterSave(call.Call2_Threat_vod__r);
                cacheChildRecordsAfterSave(call.Call2_Detail_vod__r);
            }
        }

        return result;
    }

    private void cacheChildRecordsAfterSave(List<SObject> recs) {
        if (recs != null) {
            for (SObject rec : recs) {
                cacheChildRecordAfterSave(rec);
            }
        }
    }

    private void cacheChildRecordAfterSave(SObject rec) {
        if (recordsCache == null) {
            recordsCache = new Map<String, SObject>();
            childRecordsToRemoveMap = new Map<Id, SObject>();
        }

        recordsCache.put(getRecordKey(rec), rec);
        childRecordsToRemoveMap.put(rec.Id, rec);
    }

    private SObject getRecordFromCache(SObject rec) {
        return recordsCache != null ? recordsCache.get(getRecordKey(rec)) : null;
    }

    private String getRecordKey(SObject rec) {
        String result = null;

        if (rec instanceof Call2_vod__c) {
            result = getRecordKey((Call2_vod__c)rec);
        } else if (rec instanceof Call2_Discussion_vod__c) {
            result = getRecordKey((Call2_Discussion_vod__c)rec);
        } else if (rec instanceof Call2_Threat_vod__c) {
            result = getRecordKey((Call2_Threat_vod__c)rec);
        } else if (rec instanceof Call2_Detail_vod__c) {
            result = getRecordKey((Call2_Detail_vod__c)rec);
        } else if (rec instanceof Call2_Key_Message_vod__c) {
            result = getRecordKey((Call2_Key_Message_vod__c)rec);
        } else if (rec instanceof Call2_Sample_vod__c) {
            result = getRecordKey((Call2_Sample_vod__c)rec);
        }
        return result;
    }

    private String getRecordKey(Call2_vod__c call) {
        return String.format('call_{0}_{1}_{2}_{3}_{4}', new String[] {call.Parent_Call_vod__c, call.Account_vod__c, call.Contact_vod__c, call.User_vod__c, call.EMS_International_Speaker_gne__c});
    }

    private String getRecordKey(Call2_Discussion_vod__c cd) {
        return String.format('callDiscussion_{0}_{1}', new String[] {cd.Call2_vod__c, cd.Detail_Priority_gne__c != null ? String.valueOf(cd.Detail_Priority_gne__c) : null});
    }

    private String getRecordKey(Call2_Threat_vod__c cd) {
        return String.format('callThreat_{0}_{1}', new String[] {cd.Call2_vod__c, cd.Detail_Priority__c != null ? String.valueOf(cd.Detail_Priority__c) : null});
    }

    private String getRecordKey(Call2_Detail_vod__c cd) {
        return String.format('callDetail_{0}_{1}', new String[] {cd.Call2_vod__c, cd.Product_vod__c});
    }

    private String getRecordKey(Call2_Sample_vod__c cs) {
        return String.format('callSample_{0}_{1}_{2}', new String[] {cs.Call2_vod__c, cs.Product_vod__c, cs.Account_vod__c});
    }

    private void setRecordIdFromExisting(SObject rec) {
        SObject existingRec = getRecordFromCache(rec);

        if (existingRec != null && childRecordsToRemoveMap.containsKey(existingRec.Id)) {
            rec.Id = existingRec.Id;
            childRecordsToRemoveMap.remove(rec.Id);
        }
    }

    public void setRecordIdFromExisting(SObject rec, TableRowWrapper trw) {

        SObject existingRec = getRecordFromCache(rec);
        if(existingRec!=null && childRecordsToRemoveMap.containsKey(existingRec.Id)) {
            rec.Id = existingRec.Id;
            childRecordsToRemoveMap.remove(rec.Id);

            if(recToWrapperMap==null) {
                recToWrapperMap = new Map<String,TableRowWrapper>();
            }

            recToWrapperMap.put(getRecordKey(rec), trw);
        }
    }

    private void saveAttendees() {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        attendeesToUpsert = new List<Call2_vod__c>();
        Map<Id, List<AttendeeWrapper>> accountIdToAttendeesMap = new Map<Id, List<AttendeeWrapper>>();

        if (saveData.multipleAccountsMode == true) {
            for (MultipleAccountWrapper callAccount : saveData.multipleAccountsData) {
                accountIdToAttendeesMap.put(callAccount.id, callAccount.attendees);
            }
        } else {
            accountIdToAttendeesMap.put(saveData.callAccount.id, saveData.attendeeData.rows);
        }

        if (saveData.completeMode == true) {

        }
        List<GNE_CRM_Default_Attendee_Type__c> defaultsToUpsert = new List<GNE_CRM_Default_Attendee_Type__c>();
        for (Id callAccountId : accountIdToAttendeesMap.keySet()) {
            Call2_vod__c call = accountIdToCallMap.get(callAccountId);

            for (AttendeeWrapper aw : accountIdToAttendeesMap.get(callAccountId)) {
                Call2_vod__c callAttendee = (Call2_vod__c)aw.getRecord(Call2_vod__c.class);
                callAttendee.Parent_Call_vod__c = call.Id;
                setCallAddress(callAttendee, call.Parent_Address_vod__r);
                callAttendee.RecordTypeId = call.RecordTypeId;
                callAttendee.Detailed_Products_vod__c = call.Detailed_Products_vod__c;
                callAttendee.Completed_gne__c = call.Completed_gne__c;
                callAttendee.Date_Completed_gne__c = call.Date_Completed_gne__c;
                callAttendee.HCP_OR_Attendee_Meal_Opt_Out_gne__c = call.HCP_OR_Attendee_Meal_Opt_Out_gne__c;

                if (String.isNotEmpty(call.OwnerId)) {
                    callAttendee.OwnerId = call.OwnerId;
                }

                setRecordIdFromExisting(callAttendee);

                Set<String> excludedFieldNames = new Set<String> {'hcp_account_meal_opt_out_gne__c', 'hcp_attendee_meal_opt_out_gne__c', 'account_vod__c'};

                for (GNE_MCCO_CRM_Base_Ctrl.Field siField : inputDataWrapper.inputFields) {
                    String fieldName = siField.name;
                    if (callAttendee.get(fieldName) == null && !excludedFieldNames.contains(fieldName.toLowerCase())) {
                        callAttendee.put(fieldName, call.get(fieldName));
                    }
                }

                attendeesToUpsert.add(callAttendee);

                if (callAttendee.Account_vod__c != null) {
                    accountIdToCallMap.put(callAttendee.Account_vod__c, callAttendee);
                }

                if(callAttendee.Contact_vod__c!=null) {
                    contactIdToCallMap.put(callAttendee.Contact_vod__c,callAttendee);
                }


                if(callAttendee.Contact_vod__c != null){
                    GNE_CRM_Default_Attendee_Type__c defaultRecord = GNE_CRM_Default_Attendee_Type__c.getInstance(callAttendee.Contact_vod__c);
                    if(defaultRecord != null){
                        defaultRecord.Attendee_Type_gne__c = callAttendee.Attendee_Type_vod__c;
                    } else {
                        defaultRecord = new GNE_CRM_Default_Attendee_Type__c(Name = callAttendee.Contact_vod__c, Attendee_Type_gne__c = callAttendee.Attendee_Type_vod__c);
                    }
                    defaultsToUpsert.add(defaultRecord);
                }
            }
        }

        executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.UPS, defaultsToUpsert);
        executeDML(GNE_MCCO_CRM_Base_Ctrl.DmlOperations.UPS, attendeesToUpsert);
    }

    private void saveCollabDetails() {
        List<Call2_vod__c> calls = new List<Call2_vod__c>(mainCallsToUpsert);
        detailsToUpsert = new List<Call2_Detail_vod__c>();
        collabsToUpsert = new List<Call2_Discussion_vod__c>();

        for (Call2_vod__c call : calls) {
            saveCollabProductsForCall(call);
        }
    }

    private MaterialWrapper getMaterialTemplate(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
        return new MaterialWrapper('0', new Call2_Sample_vod__c(Quantity_vod__c = 1), columns);
    }

    private List<MaterialWrapper> getMaterialWrappers(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
        List<MaterialWrapper> result = new List<MaterialWrapper>();

        List<Call2_Sample_vod__c> materialRecs = getMeterials();

        if(materialRecs!=null) {
            Integer rowIdx=0;

            for(Call2_Sample_vod__c cs : materialRecs) {
                MaterialWrapper mw = new MaterialWrapper('call-material-' + String.valueOf(rowIdx++), cs, columns);
                result.add(mw);
            }
        }

        return result;
    }

    private void saveMaterials() {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        materialsToUpsert = new List<Call2_Sample_vod__c>();

        for(Call2_vod__c call : mainCallsToUpsert) {
            for(MaterialWrapper mw : saveData.materialData.rows) {
                Call2_Sample_vod__c cs = (Call2_Sample_vod__c)mw.getRecord(Call2_Sample_vod__c.class);
                if(cs.Account_vod__c != null && accountIdToCallMap.containsKey(cs.Account_vod__c)) {
                    cs.Call2_vod__c = accountIdToCallMap.get(cs.Account_vod__c).Id;
                } else if(cs.Contact_vod__c != null && contactIdToCallMap.containsKey(cs.Contact_vod__c)) {
                    cs.Call2_vod__c = contactIdToCallMap.get(cs.Contact_vod__c).Id;
                }
                setRecordIdFromExisting(cs, mw);
                materialsToUpsert.add(cs);
            }
        }
    }
    
    private void saveCollabProductsForCall(Call2_vod__c call) {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;

        List<Product_vod__c> noProductDiscussed = [ SELECT Id, Name FROM Product_vod__c WHERE Name = 'No Product discussed' LIMIT 1 ];
        Integer idx = 0;
        for (CollabDetailsWrapper cw : saveData.collabDetailsData.rows) {
            Id productId = cw.getField('Product_vod__c').value;
            if (String.isBlank(productId) && noProductDiscussed.size()>=1) {
                productId = noProductDiscussed.get(0).Id;
            }
            Call2_Detail_vod__c cDetail = new Call2_Detail_vod__c(Product_vod__c = productId, Call2_vod__c = call.Id);
            cDetail.Detail_Priority_vod__c = idx;
            cDetail.Type_vod__c = 'Paper_Detail_vod';
            setRecordIdFromExisting(cDetail);
            detailsToUpsert.add(cDetail);

            Call2_Discussion_vod__c cd = (Call2_Discussion_vod__c)cw.getRecord(Call2_Discussion_vod__c.class);
            cd.Product_vod__c = productId;
            cd.Call2_vod__c = call.Id;
            cd.Detail_Priority_gne__c = idx;
            setRecordIdFromExisting(cd);
            collabsToUpsert.add(cd);

            idx++;
        }
    }     
    
    private void saveThreats() {
        List<Call2_vod__c> calls = new List<Call2_vod__c>(mainCallsToUpsert);
        threatsToUpsert = new List<Call2_Threat_vod__c>();

        for (Call2_vod__c call : calls) {
            saveThreatProductsForCall(call);
        }
    }   
    
    private void saveThreatProductsForCall(Call2_vod__c call) { 
        DataWrapper saveData = (DataWrapper)inputDataWrapper;

        List<Product_vod__c> noProductDiscussed = [ SELECT Id, Name FROM Product_vod__c WHERE Name = 'No Product discussed' LIMIT 1 ];
        Integer idx = 0;
        for (ThreatWrapper cw : saveData.ThreatData.rows) {
            Id productId = cw.getField('Product_vod__c').value;
            if (String.isBlank(productId) && noProductDiscussed.size()>=1) {
                productId = noProductDiscussed.get(0).Id;
            }

            Call2_Threat_vod__c cd = (Call2_Threat_vod__c)cw.getRecord(Call2_Threat_vod__c.class);
            cd.Product_vod__c = productId;
            cd.Call2_vod__c = call.Id;
            cd.Detail_Priority__c = idx;
            setRecordIdFromExisting(cd);
            threatsToUpsert.add(cd);

            idx++;
        }
    } 

    protected override GNE_MCCO_CRM_Base_Ctrl.DataWrapper intDeleteRecord() {
        GNE_MCCO_CRM_Base_Ctrl.DataWrapper result = super.intDeleteRecord();
        DataWrapper inputData = (DataWrapper)inputDataWrapper;
        Id accId = inputData.callAccount.id;
        result.retUrl = '/' + accId;
        return result;
    }

    public class DataWrapper extends GNE_MCCO_CRM_Base_Ctrl.DataWrapper {
        private List<AddressWrapper> addresses;
        private AttendeeData attendeeData;
        private Boolean simpleEditMode;
        private AccountWrapper callAccount;
        private List<MultipleAccountWrapper> multipleAccountsData;
        public Boolean isMaterialPerAttendeeAndProductModeEnabled;
        public MaterialData materialData;
        private Boolean isCompleted;
        private Boolean completeMode;
        private Boolean multipleAccountsMode;
        private collabDetailsData collabDetailsData;
        private threatData threatData;
        private String callName;
        private String callId;
        private String mealExpenseLabel;

        private DataWrapper() {}
    }

    public class MaterialData {
        public List<GNE_MCCO_CRM_Base_Ctrl.Field> columns;
        public MaterialWrapper rowTemplate;
        public List<MaterialWrapper> rows;
        public List<MaterialProductItem> materialProducts;

        public MaterialData(List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, MaterialWrapper rowTemplate, List<MaterialWrapper> rows, List<MaterialProductItem> materialProducts) {
            this.columns = columns;
            this.rowTemplate = rowTemplate;
            this.rows = rows;
            this.materialProducts = materialProducts;
        }
    }

    public virtual class MaterialWrapper extends TableRowWrapper {
        public MaterialWrapper() {}

        public MaterialWrapper(String rowId, Call2_Sample_vod__c csRec, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
            this.rowId = rowId;
            this.fields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();

            for(GNE_MCCO_CRM_Base_Ctrl.Field column : columns) {
                GNE_MCCO_CRM_Base_Ctrl.Field field = new GNE_MCCO_CRM_Base_Ctrl.Field(column);
                if(column.describe.type == 'reference' && csRec.getSObject(column.describe.relationshipName)!=null) {
                    field.displayValue = (String)csRec.getSObject(column.describe.relationshipName).get('Name');
                }

                field.setValue(csRec.get(field.name));
                this.fields.add(field);
            }
        }
    }

    public class MaterialProductItem implements Comparable {
        private String value;
        private String label;
        private String type;
        private Boolean isActive;
        private String controllingProductId;

        private MaterialProductItem(Product_vod__c mProduct, Boolean isDependend) {
            this.value = mProduct.Id;
            this.label = mProduct.Name;
            this.type = mProduct.Product_Type_vod__c;
            this.isActive = mProduct.Active__c;
            this.controllingProductId = isDependend ? mProduct.Parent_Product_vod__c : null;
        }

        public Integer compareTo(Object compareTo) {
            MaterialProductItem otherObj = (MaterialProductItem)compareTo;
            //ORDER BY Product_Type_vod__c, Name
            if (this.type > otherObj.type) {
                return 1;
            } else if (this.type < otherObj.type) {
                return -1;
            } else {
                if (this.label > otherObj.label) {
                    return 1;
                } else {
                    return -1;
                }
            }
        }
    }

    private virtual class AccountWrapper {
        private Id id;
        private String name;
        private Boolean isPersonAccount;

        private AccountWrapper(Account acc) {
            this.id = acc.Id;
            this.name = acc.name;
            this.isPersonAccount = acc.IsPersonAccount;
        }
    }

    private class MultipleAccountWrapper extends AccountWrapper {
        private AddressWrapper address;
        private List<MultipleAttendeeWrapper> attendees;

        private MultipleAccountWrapper(Account acc, Address_vod__c addr) {
            super(acc);
            this.attendees = new List<MultipleAttendeeWrapper>();
            this.address = addr != null ? new AddressWrapper(addr) : null;
        }
    }


    private class AddressWrapper {
        private String label;
        private Id value;
        private String name;
        private String suitFloor;
        private String city;
        private String state;
        private String zip;
        private String zip4;
        private String province;
        private String postalCode;
        private String pfgBDTD;

        private AddressWrapper(Address_vod__c address) {
            this(GNE_SFA2_SearchAccounts_Controller.getAddressDesciption(address), address.Id);
            this.name = address.Name;
            this.suitFloor = address.Address_line_2_vod__c;
            this.city = address.City_vod__c;
            this.state = address.State_vod__c;
            this.zip = address.Zip_vod__c;
            this.zip4 = address.Zip_4_vod__c;
            this.province = address.Province_can_gne__c;
            this.postalCode = address.Postal_Code_can_gne__c;
            this.pfgBDTD = address.PFG_BDTD_gne__c;
        }

        private AddressWrapper(String label, Id value) {
            this.label = label;
            this.value = value;
        }

        private Address_vod__c getAddressRecord() {
            return new Address_vod__c(
                       Id = this.value,
                       Name = this.name,
                       Address_line_2_vod__c = this.suitFloor,
                       City_vod__c = this.city,
                       State_vod__c = this.state,
                       Zip_vod__c = this.zip,
                       Zip_4_vod__c = this.zip4,
                       Province_can_gne__c = this.province,
                       Postal_Code_can_gne__c = this.postalCode,
                       PFG_BDTD_gne__c = this.pfgBDTD
                   );
        }
    }

    private class AttendeeData {
        private List<AttendeeOptionWrapper> options;
        private List<GNE_MCCO_CRM_Base_Ctrl.Field> columns;
        private List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns;
        private List<AttendeeWrapper> rows;

        private AttendeeData(List<AttendeeOptionWrapper> options, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns, List<AttendeeWrapper> rows) {
            this.options = options;
            this.columns = columns;
            this.searchColumns = searchColumns;
            this.rows = rows;
        }
    }

    private virtual class AttendeeWrapper extends TableRowWrapper {

        private AttendeeWrapper() {}

        private AttendeeWrapper(Call2_vod__c attendee, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
            this(attendee, null, columns);
        }

        private AttendeeWrapper(Call2_vod__c attendee, String attendeeTypeFPM, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
            this.fields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();
            String defaultAttendeeType;
            if(attendee.Contact_vod__c != null){
                GNE_CRM_Default_Attendee_Type__c defaultAttendeeSetting = GNE_CRM_Default_Attendee_Type__c.getInstance(attendee.Contact_vod__c);
                if(defaultAttendeeSetting != null){
                    defaultAttendeeType = defaultAttendeeSetting.Attendee_Type_gne__c;
                }
            }
            
            for (GNE_MCCO_CRM_Base_Ctrl.Field column : columns) {
                GNE_MCCO_CRM_Base_Ctrl.Field field = new GNE_MCCO_CRM_Base_Ctrl.Field(column);
                Object fieldValue;

                if (field.name == 'attendeeName') {
                    if (attendee.Contact_vod__c != null) {
                        field.describe = new GNE_MCCO_CRM_Base_Ctrl.FieldDescribe(Call2_vod__c.Contact_vod__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.Contact_vod__c;
                        field.displayValue = attendee.Contact_vod__r.Name;
                    } else if (attendee.User_vod__c != null) {
                        field.describe = new GNE_MCCO_CRM_Base_Ctrl.FieldDescribe(Call2_vod__c.User_vod__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.User_vod__c;
                        field.displayValue = attendee.User_vod__r.Name;
                    } else if (attendee.EMS_International_Speaker_gne__c != null) {
                        field.describe = new GNE_MCCO_CRM_Base_Ctrl.FieldDescribe(Call2_vod__c.EMS_International_Speaker_gne__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.EMS_International_Speaker_gne__c;
                        field.displayValue = attendee.EMS_International_Speaker_gne__r.Name;
                    } else {
                        field.describe = new GNE_MCCO_CRM_Base_Ctrl.FieldDescribe(Call2_vod__c.Account_vod__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.Account_vod__c;
                        field.displayValue = attendee.Account_vod__r.Name;
                    }
                    this.rowId = String.valueOf(fieldValue);
                } else if (field.name == 'attendeeType') {
                    attendee.Attendee_Type_vod__c = String.isNotBlank(defaultAttendeeType) ? defaultAttendeeType : attendee.Attendee_Type_vod__c;                    
                    fieldValue = attendee.Attendee_Type_vod__c;
                    Map<String, String> attTypeValueToLabelMap = getAttendeeTypeValueToLabelMap();
                    String attType = attendee.Attendee_Type_vod__c != null ? attendee.Attendee_Type_vod__c.toUpperCase() : null;
                    field.displayValue = attTypeValueToLabelMap.containsKey(attType) ? attTypeValueToLabelMap.get(attType) : attendee.Attendee_Type_vod__c;
                } else if (field.name == 'attendeeTypeFPM') {
                    fieldValue = String.isNotBlank(attendeeTypeFPM) ? attendeeTypeFPM : attendee.Attendee_Type_FPM_gne__c;
                } else {
                    fieldValue = attendee.get(field.name);
                }

                if (field.describe != null && !field.describe.sObjectType.endsWith('-child')) {
                    field.describe.sObjectType += '-child';
                }

                field.setValue(fieldValue);
                this.fields.add(field);
            }
        }

        private override SObject getRecord(System.Type sObjectType) {
            Call2_vod__c result = (Call2_vod__c)super.getRecord(sObjectType);
            GNE_MCCO_CRM_Base_Ctrl.Field attTypeField = getField('attendeeType');
                        
            if (attTypeField != null) {
                result.Attendee_Type_vod__c = attTypeField.value;
            }

            return result;
        }
    }

    private class AttendeeOptionWrapper extends AttendeeWrapper {
        private String label;
        private String addressDescription;
        private List<GNE_MCCO_CRM_Base_Ctrl.Field> searchResultFields;

        private AttendeeOptionWrapper(User u, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(User_vod__c = u.Id, User_vod__r = u, Attendee_Type_vod__c = 'User_vod'),
                 columns, searchColumns, u.LastName + (String.isNotBlank(u.FirstName) ? ', ' + u.FirstName : ''));
        }

        private AttendeeOptionWrapper(Account acc, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(Account_vod__c = acc.Id, Account_vod__r = acc, Attendee_Type_vod__c = 'Person_Account_vod'),
                 columns, searchColumns, acc.LastName + (String.isNotBlank(acc.FirstName) ? ', ' + acc.FirstName : ''));
        }

        private AttendeeOptionWrapper(Contact con, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(Contact_vod__c = con.Id, Contact_vod__r = con, Attendee_Type_vod__c = con.IsPersonAccount ? 'Person_Account_vod' : 'Contact_vod'),
                 getIsFPMProfile() ? con.Type_gne__c : null,
                 columns, searchColumns, con.LastName + (String.isNotBlank(con.FirstName) ? ', ' + con.FirstName : ''));
        }

        private AttendeeOptionWrapper(EMS_International_Speaker_gne__c ihcp, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(EMS_International_Speaker_gne__c = ihcp.Id, EMS_International_Speaker_gne__r = ihcp, Attendee_Type_vod__c = 'iHCP_Account_vod'),
                 columns, searchColumns, ihcp.Last_Name_gne__c + (String.isNotBlank(ihcp.First_Name_gne__c) ? ', ' + ihcp.First_Name_gne__c : ''));
        }

        private AttendeeOptionWrapper(Call2_vod__c attendeeCall, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns, String label) {
            this(attendeeCall, null, columns, searchColumns, label);
        }

        private AttendeeOptionWrapper(Call2_vod__c attendeeCall, String attendeeTypeFPM, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns, String label) {
            super(attendeeCall, attendeeTypeFPM, columns);
            this.label = label;

            if (searchColumns != null) {
                setSearchFields(searchColumns);
            }
        }

        private AttendeeOptionWrapper(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper saw, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
            if (saw.isUser) {
                this((User)saw.record, columns, null);
            } else if (saw.isContact) {
                this((Contact)saw.record, columns, null);
            } else if (saw.recordType == 'iHCP') {
                this((EMS_International_Speaker_gne__c)saw.record, columns, null);
            } else {
                this((Account)saw.record, columns, null);
            }

            this.setAddressDescription(saw.addressDescription);
            this.setSearchFields(searchColumns);
        }
        

        private void setAddressDescription(String addressDescription) {
            this.addressDescription = addressDescription;
        }

        private void setSearchFields(List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
            Map<String, GNE_MCCO_CRM_Base_Ctrl.Field> fieldMap = new Map<String, GNE_MCCO_CRM_Base_Ctrl.Field>();

            for (GNE_MCCO_CRM_Base_Ctrl.Field field : this.fields) {
                fieldMap.put(field.name, field);
            }

            this.searchResultFields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();

            for (GNE_MCCO_CRM_Base_Ctrl.Field searchColumn : searchColumns) {
                GNE_MCCO_CRM_Base_Ctrl.Field field = new GNE_MCCO_CRM_Base_Ctrl.Field(searchColumn);
                Object fieldValue;

                if (field.name == 'name') {
                    fieldValue = this.label;
                } else if (field.name == 'address') {
                    fieldValue = this.addressDescription;
                } else {
                    fieldValue = fieldMap.get(field.name).value;
                    field.displayValue = fieldMap.get(field.name).displayValue;
                }

                field.setValue(fieldValue);
                searchResultFields.add(field);
            }
        }
    }

    private class MultipleAttendeeWrapper extends AttendeeWrapper {
        private Id id;
        private String name;

        public MultipleAttendeeWrapper(Contact con) {
            super(
                new Call2_vod__c(Contact_vod__c = con.Id, Contact_vod__r = con, Attendee_Type_vod__c = con.IsPersonAccount ? 'Person_Account_vod' : 'Contact_vod'),
            new List<GNE_MCCO_CRM_Base_Ctrl.Field> {
                new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeName', 'Attendee'),
                new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeType', 'Type')
            });

            this.id = this.rowId;
            this.name = getField('attendeeName').displayValue;
        }
    }

    private class CollabDetailsData {
        private List<CollabDetailsOptionWrapper> options;
        private List<GNE_MCCO_CRM_Base_Ctrl.Field> columns;
        private CollabDetailsWrapper collabTemplate;
        private List<CollabDetailsWrapper> rows;
        private List<CollabDetailsTactics> tactics;
        private List<CollabDetailsMarketingMaterials> marketingMaterials;

        private CollabDetailsData(List<CollabDetailsOptionWrapper> options, 
                                  List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, 
                                  CollabDetailsWrapper collabTemplate, 
                                  List<CollabDetailsWrapper> rows, 
                                  List<CollabDetailsTactics> tactics,
                                  List<CollabDetailsMarketingMaterials> marketingMaterials) {
            this.options = options;
            this.columns = columns;
            this.collabTemplate = collabTemplate;
            this.rows = rows;
            this.tactics = tactics;
            this.marketingMaterials = marketingMaterials;
        }
    }    
    
    private virtual class CollabDetailsWrapper extends TableRowWrapper {
        private Id recordTypeId;

        private CollabDetailsWrapper(String rowId, SObject cd, Id recordTypeId, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
            this.rowId = rowId;
            this.recordTypeId = recordTypeId;            
            this.fields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();

            for (GNE_MCCO_CRM_Base_Ctrl.Field column : columns) {
                GNE_MCCO_CRM_Base_Ctrl.Field field = new GNE_MCCO_CRM_Base_Ctrl.Field(column);
                Object fieldValue;
                fieldValue = cd.get(field.name);

                if (column.describe.type == 'reference' && cd.getSObject(column.describe.relationshipName) != null) {
                    field.displayValue = (String)cd.getSObject(column.describe.relationshipName).get('Name');
                }

                field.setValue(fieldValue);
                this.fields.add(field);
            }
        }

        private override SObject getRecord(System.Type sObjectType) {
            Call2_Discussion_vod__c result = (Call2_Discussion_vod__c)super.getRecord(sObjectType);
            
            if (String.isNotBlank(recordTypeId)) {
                result.RecordTypeId = recordTypeId;
            }
                        
            return result;
        }
    }

    private class CollabDetailsTactics {
        private String meetingObjective;
        private String tactic;

        private CollabDetailsTactics(String meetingObjective, String tactic) {
            this.meetingObjective = meetingObjective;
            this.tactic = tactic;
        }
    }    

    private class CollabDetailsMarketingMaterials {
        private String meetingObjective;
        private String product;
        private String marketingMaterial;

        private CollabDetailsMarketingMaterials(String meetingObjective, String product, String marketingMaterial) {
            this.meetingObjective = meetingObjective;
            this.product = product;
            this.marketingMaterial = marketingMaterial;
        }
    }    
    
    private virtual class CollabDetailsOptionWrapper extends CollabDetailsWrapper {
        private String label;

        private CollabDetailsOptionWrapper(String rowId, Product_vod__c prod, Id recordTypeId, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
            super(rowId,(SObject)new Call2_Discussion_vod__c(Product_vod__c = prod.Id, Product_vod__r = prod, RecordTypeId = recordTypeId), recordTypeId, columns);
            this.label = prod.Name;
        }
    } 
    
    private class ThreatData {
        private List<ThreatOptionWrapper> options;
        private List<GNE_MCCO_CRM_Base_Ctrl.Field> columns;
        private ThreatWrapper threatTemplate;
        private List<ThreatWrapper> rows;

        private ThreatData(List<ThreatOptionWrapper> options, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, ThreatWrapper threatTemplate, List<ThreatWrapper> rows) {
            this.options = options;
            this.columns = columns;
            this.threatTemplate = threatTemplate;
            this.rows = rows;
        }
    }    
    
    private virtual class ThreatWrapper extends TableRowWrapper {

        private ThreatWrapper(String rowId, SObject cd, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
            this.rowId = rowId;
            this.fields = new List<GNE_MCCO_CRM_Base_Ctrl.Field>();

            for (GNE_MCCO_CRM_Base_Ctrl.Field column : columns) {
                GNE_MCCO_CRM_Base_Ctrl.Field field = new GNE_MCCO_CRM_Base_Ctrl.Field(column);
                Object fieldValue;
                fieldValue = cd.get(field.name);

                if (column.describe.type == 'reference' && cd.getSObject(column.describe.relationshipName) != null) {
                    field.displayValue = (String)cd.getSObject(column.describe.relationshipName).get('Name');
                }

                field.setValue(fieldValue);
                this.fields.add(field);
            }
        }

        private override SObject getRecord(System.Type sObjectType) {
            Call2_Threat_vod__c result = (Call2_Threat_vod__c)super.getRecord(sObjectType);
            return result; 
        }
    }
    
    private virtual class ThreatOptionWrapper extends ThreatWrapper {
        private String label;

        private ThreatOptionWrapper(String rowId, Product_vod__c prod, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns) {
            super(rowId,(SObject)new Call2_Threat_vod__c(Product_vod__c = prod.Id, Product_vod__r = prod), columns);
            this.label = prod.Name;
        }
    }

    @TestVisible
    private class UpdateDataWrapper {
        private List<AddressWrapper> addresses;
        private AccountWrapper callAccount;
        private AttendeeData attendeeData;

        private UpdateDataWrapper(List<AddressWrapper> addresses, AccountWrapper callAccount, AttendeeData attendeeData) {
            this.addresses = addresses;
            this.callAccount = callAccount;
            this.attendeeData = attendeeData;
        }
    }

    private class AttendeeOptions {
        private String label;
        private String rowId;

        private AttendeeOptions(String label, String rowId) {
            this.label = label;
            this.rowId = rowId;
        }
    }

    private virtual class TableRowWrapper {
        private String rowId;
        private List<GNE_MCCO_CRM_Base_Ctrl.Field> fields;

        private TableRowWrapper() {}

        private GNE_MCCO_CRM_Base_Ctrl.Field getField(String fieldName) {
            GNE_MCCO_CRM_Base_Ctrl.Field result = null;
            if (fields != null) {
                for (GNE_MCCO_CRM_Base_Ctrl.Field fld : fields) {
                    if (fld.name == fieldName) {
                        result = fld;
                        break;
                    }
                }
            }

            return result;
        }

        private virtual SObject getRecord(System.Type sObjectType) {
            SObject result = (SObject)sObjectType.newInstance();

            if (fields != null) {
                for (GNE_MCCO_CRM_Base_Ctrl.Field fld : fields) {
                    if (fld.describe != null && (!fld.describe.calculated && fld.describe.updateable && fld.describe.createable)) {
                        result.put(fld.describe.name, fld.getValue());
                    }
                }
            }

            return result;
        }

        protected virtual Set<String> getFieldNames() {
            Set<String> result = new Set<String>();

            if(fields!=null) {
                for(GNE_MCCO_CRM_Base_Ctrl.Field fld : fields) {
                    if(fld.describe!=null && String.isNotBlank(fld.describe.name)) {
                        result.add(fld.describe.name.toLowerCase());
                    }
                }
            }

            return result;
        }
    }

    private class MealOptOutEventNotCompletedException extends GNE_MCCO_CRM_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_MCCO_CRM_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'MealOptOutEventNotCompleted';
            label = System.Label.GNE_SFA2_Meal_Opt_Out_Meal_Event_Not_Completed;
        }
    }

    private class MealOptOutActualMealRecipientException extends GNE_MCCO_CRM_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_MCCO_CRM_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'MealOptOutActualMealRecipient';
            label = System.Label.GNE_SFA2_Meal_Opt_Out_Actual_Meal_Recipient_Validation;
        }
    }

    // static methods

    @RemoteAction @ReadOnly
    public static DataWrapper initViewModuleData(Map<String, String> params) {
        return (DataWrapper)(new GNE_MCCO_CRM_Interaction_Controller()).init(params);
    }

    @RemoteAction
    public static DataWrapper saveRecord(String inputDataInJSON) {
        return (DataWrapper)(new GNE_MCCO_CRM_Interaction_Controller()).saveRecord(inputDataInJSON, GNE_MCCO_CRM_Interaction_Controller.DataWrapper.class);
    }

    @RemoteAction
    public static DataWrapper deleteRecord(String inputDataInJSON) {
        return (DataWrapper)(new GNE_MCCO_CRM_Interaction_Controller()).deleteRecord(inputDataInJSON, GNE_MCCO_CRM_Interaction_Controller.DataWrapper.class);
    }

    @RemoteAction @ReadOnly
    public static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchAccounts (Map<String, String> params) {
        return GNE_SFA2_SearchAccounts_Controller.searchHCOs(params.get('searchValue'), Integer.valueOf(params.get('recordLimit')), false);
    }

    @RemoteAction @ReadOnly
    public static DataWrapper searchAttendeesWithPhrase(Map<String, Object> params) {
        return (new GNE_MCCO_CRM_Interaction_Controller()).searchAttendees(params);
    }

    @RemoteAction @ReadOnly
    public static DataWrapper getMultipleAccountsData(Map<String, String> params) {
        return new GNE_MCCO_CRM_Interaction_Controller(params).getDataWrapperWithMultipleAccountsData();
    }

    @RemoteAction
    public static UpdateDataWrapper updateDataAfterChangeAccount(Id recordId) {
        Account callAccount = [
                                  SELECT Id, Name, IsPersonAccount,
                                  (SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c, PFG_BDTD_gne__c
                                   FROM Address_vod__r
                                   WHERE Inactive_vod__c = false
                                           ORDER BY Name)
                                  FROM Account WHERE Id = : recordId
                              ];

        List<AddressWrapper> addresses = new List<AddressWrapper>();

        for (Address_vod__c address : callAccount.Address_vod__r) {
            addresses.add(new AddressWrapper(address));
        }

        List<GNE_MCCO_CRM_Base_Ctrl.Field> attendeeColumns = getAttendeeCol();
        List<GNE_MCCO_CRM_Base_Ctrl.Field> attendeeSearchColumns = getAttendeeSearchCol();
        List<AttendeeOptionWrapper> attendeeOptions = getAttedeeOpt(recordId, attendeeColumns, attendeeSearchColumns);

        return new UpdateDataWrapper(addresses, new AccountWrapper(callAccount), new AttendeeData(attendeeOptions, attendeeColumns, attendeeSearchColumns, new List<AttendeeWrapper>()));
    }

    private static List<GNE_MCCO_CRM_Base_Ctrl.Field> getAttendeeCol() {
        List<GNE_MCCO_CRM_Base_Ctrl.Field> result = new List<GNE_MCCO_CRM_Base_Ctrl.Field> {
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeName', 'Attendee'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeType', 'Type'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('HCP_Attendee_Meal_Opt_Out_gne__c', 'Meal Opt Out', false, 'Call2_vod__c')
        };
        return result;
    }

    private static List<GNE_MCCO_CRM_Base_Ctrl.Field> getAttendeeSearchCol() {
        List<GNE_MCCO_CRM_Base_Ctrl.Field> result = new List<GNE_MCCO_CRM_Base_Ctrl.Field> {
            new GNE_MCCO_CRM_Base_Ctrl.Field('name', 'Name'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('address', 'Address'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeType', 'Type')
        };

        return result;
    }

    private static List<AttendeeOptionWrapper> getAttedeeOpt(String accountId, List<GNE_MCCO_CRM_Base_Ctrl.Field> columns, List<GNE_MCCO_CRM_Base_Ctrl.Field> searchColumns) {
        List<AttendeeOptionWrapper> result = new List<AttendeeOptionWrapper>();
        Set<Id> resultIds = new Set<Id>();
        Integer resultSizeLimit = 100;

        for (Contact con : [
                    SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c
                    FROM Contact
                    WHERE AccountId = :accountId AND Active_gne__c = true
                                      ORDER BY LastName NULLS LAST]) {
            AttendeeOptionWrapper aow = new AttendeeOptionWrapper(con, columns, searchColumns);
            result.add(aow);
            resultIds.add(con.Id);


            if (resultIds.size() == resultSizeLimit) {
                break;
            }
        }
        return result;
    }
    
    private static Map<String, String> getAttendeeTypeValueToLabelMap() {
        if (attendeeTypeValueToLabelMap == null) {
            attendeeTypeValueToLabelMap = new Map<String, String>();

            for (Schema.PicklistEntry plValue : Call2_vod__c.Attendee_Type_vod__c.getDescribe().getPicklistValues()) {
                attendeeTypeValueToLabelMap.put(plValue.getValue().toUpperCase(), plValue.getLabel());
            }
        }

        return attendeeTypeValueToLabelMap;
    }

    private static Boolean getIsFPMProfile() {
        return staticGetCurrentUserProfileName().toUpperCase().contains('FPM');
    }

    private static String staticGetCurrentUserProfileName() {
        if (String.isBlank(staticCurrentUserProfileName)) {
            staticCurrentUserProfileName = [SELECT Name FROM Profile WHERE Id = : UserInfo.getProfileId() LIMIT 1].Name;
        }
        return staticCurrentUserProfileName;
    }

    @RemoteAction
    public static AttendeeOptionWrapper addNewAttendeeSF1(Id recordId) {
        AttendeeOptionWrapper aow;
        try{
            Contact con = [SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c
                    FROM Contact
                    WHERE Id = :recordId AND Active_gne__c = true LIMIT 1];
            List<GNE_MCCO_CRM_Base_Ctrl.Field> attendeeColumns = getAttendeeCol();
            List<GNE_MCCO_CRM_Base_Ctrl.Field> attendeeSearchColumns = getAttendeeSearchCol();
            aow = new AttendeeOptionWrapper(con, attendeeColumns, attendeeSearchColumns);
        } catch(Exception ex){
            system.debug(ex);
        }
        return aow;
    }

    @RemoteAction @ReadOnly
    public static Boolean isResultTruncated(Id accountId){
        return [SELECT id, accountId FROM Contact WHERE AccountId = :accountId AND Active_gne__c = true LIMIT 1 OFFSET 50].size() > 0;
    }

    @RemoteAction @ReadOnly
    public static Integer getContactsCount(Id accountId, String search) {
        Set<Id> alreadyDisplayed = new Set<Id>();
        for(Contact c :[SELECT Id FROM Contact WHERE AccountId = :accountId AND Active_gne__c = true ORDER BY LastName NULLS LAST LIMIT 50]) {
            alreadyDisplayed.add(c.Id);
        }
        String query = 'SELECT count() FROM Contact WHERE Active_gne__c = true AND AccountId = :accountId AND (NOT Id IN :alreadyDisplayed)';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ')';
        }

        query += ' LIMIT 49950';

        return Database.countQuery(query);
    }

    @RemoteAction
    public static List<Contact> getContacts(String accountId, Integer displayLength, Integer displayStart, String search) {
        Set<Id> alreadyDisplayed = new Set<Id>();
        for(Contact c :[SELECT Id FROM Contact WHERE AccountId = :accountId AND Active_gne__c = true ORDER BY LastName NULLS LAST LIMIT 50]) {
            alreadyDisplayed.add(c.Id);
        }

        List<Contact> result = new List<Contact>();

        String query = 'SELECT Id, FirstName, LastName, Name, AccountId, MailingStreet, MailingCity, State_Province_gne__c, MailingPostalCode, MailingCountry, IsPersonAccount FROM Contact WHERE AccountId = :accountId AND isPersonAccount=false AND Active_gne__c = true AND (NOT Id IN :alreadyDisplayed)';
        if (!String.isEmpty(search)) {
            query += ' AND (';
            query += 'Name Like \'%' + search + '%\'';
            query += ')';
        }
        query += ' ORDER BY LastName ASC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
            query += ' OFFSET ' + displayStart;
        }

        System.debug('##### Query === ' + query);

        result = Database.query(query);
        return result;
    }
    
    
    private GNE_MCCO_CRM_Base_Ctrl.DataWrapper fetchContactConfigurationPage() {
        GNE_MCCO_CRM_Contact_Controller controller = new GNE_MCCO_CRM_Contact_Controller();
        controller.setDataWrapper(new GNE_MCCO_CRM_Contact_Controller.DataWrapper(true));
        controller.newModeWithoutRecord = true;
        Map<String, String> params = new Map<String, String>{
            'uiType' => 'standard',
            'debugMode' => '',
            'apiStaticResource' => '',
            'uiStaticResource' => '',
            'pageStaticResource' => '',
            'isPopup' => 'false',
            'popupReturnAction' => ''
        };
        
        return controller.intInit(params);
    }
        
    public static GNE_MCCO_CRM_Base_Ctrl.DataWrapper saveContactRecord(GNE_MCCO_CRM_Contact_Controller.DataWrapper inputData) {
        String firstName;
        String lastName;
        String contactId;
        String accountId;
        Map<String, String> params = new Map<String, String>();
        for(GNE_MCCO_CRM_Base_Ctrl.Field f : inputData.inputFields){
            if(f.name.equalsIgnoreCase('firstname')){
                firstName = (String)f.getValue();
            } else if (f.name.equalsIgnoreCase('lastname')){
                lastName = (String)f.getValue();
            } else if (f.name.equalsIgnoreCase('contactId')){
                contactId = (String)f.getValue();
            } else if (f.name.equalsIgnoreCase('accountId')){
                accountId = (String)f.getValue();
            } 
        }
        if(String.isEmpty(contactId) ){
            Contact existingContact = iPhone_DAO.getContactByFirstAndLastName(firstName, lastName, accountId);
            if(existingContact != null) {
                inputData.contactId = existingContact.Id;
                inputData.recordDescribe.recordId = existingContact.Id;
            }
        }
        GNE_MCCO_CRM_Base_Ctrl.DataWrapper resultData = (new GNE_MCCO_CRM_Contact_Controller()).saveRecord(inputData, params);
        resultData.retUrl = null;
        return resultData;
    }
    
    public AttendeeWrapper fetchNewContact(Map<String, String> params) {
        String contactId = params.get('contactId');
        Contact myNewContact = [SELECT Full_Name_gne__c, AccountId FROM Contact WHERE Id = :contactId];
        String acctId = myNewContact.AccountId;
        String addrId = null;
        if(params.containsKey('addrId')) {
            addrId = params.get('addrId');
        }

        Address_vod__c addr = fetchAddress(acctId, addrId);       
        List<GNE_MCCO_CRM_Base_Ctrl.Field> result = new List<GNE_MCCO_CRM_Base_Ctrl.Field>{
            new GNE_MCCO_CRM_Base_Ctrl.Field('name', 'Name'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('address', 'Address'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeType', 'Type')
        };         
        List<GNE_MCCO_CRM_Base_Ctrl.Field> result1 = new List<GNE_MCCO_CRM_Base_Ctrl.Field>{
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeName', 'Attendee'),
            new GNE_MCCO_CRM_Base_Ctrl.Field('attendeeType', 'Type')
        };
        result1.add(
            new GNE_MCCO_CRM_Base_Ctrl.Field(
                'HCP_Attendee_Meal_Opt_Out_gne__c', 'Meal Opt Out', null, null, null, null, false, false, null, new GNE_MCCO_CRM_Base_Ctrl.FieldDescribe(Call2_vod__c.HCP_Attendee_Meal_Opt_Out_gne__c.getDescribe(), 'Call2_vod__c')
            )
        );
        
        Account acc = new Account(Id = acctId, LastName = addr.Account_vod__r.LastName, FirstName = addr.Account_vod__r.FirstName);
        
        GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper saw = new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(acc, addr);

        AttendeeOptionWrapper attWraper = new AttendeeOptionWrapper(saw, result1, result);
        
        for(GNE_MCCO_CRM_Base_Ctrl.Field column : attWraper.fields) {
            if(column.name == 'attendeeName') {
                column.describe = new GNE_MCCO_CRM_Base_Ctrl.FieldDescribe(Call2_vod__c.Contact_vod__c.getDescribe(), 'Call2_vod__c');
                column.displayValue = myNewContact.Full_Name_gne__c;
                column.value = contactId;
            }else if(column.name == 'attendeeType') {
                column.displayValue = 'Contact';
                column.value = 'Contact_vod';
            }
        }
        for(GNE_MCCO_CRM_Base_Ctrl.Field column :attWraper.searchResultFields){
            if(column.name == 'name') {
                column.displayValue = myNewContact.Full_Name_gne__c;
            }else if(column.name == 'attendeeType') {
                column.displayValue = 'Contact';
                column.value = 'Contact_vod';
            }
        }
        attWraper.rowId = contactId;
        return attWraper;
    }

    private static Address_vod__c fetchAddress(String acctId, String addrId){
        return Database.query(String.format('SELECT {0} FROM Address_vod__c WHERE {1} LIMIT 1', new String[]{
            'Id, Account_vod__c, Account_vod__r.FirstName, Account_vod__r.LastName, Account_vod__r.Formatted_Name_vod__c, Account_vod__r.Name,'+
            'Account_vod__r.Phone, Account_vod__r.MDMID_Status_gne__c, Address_Line_2_vod__c, Name, City_vod__c, State_vod__c, Zip_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s',
            'Account_vod__c =: acctId' + (String.isNotBlank(addrId) ? ' AND Id =: addrId': '')
        }));
    }        
          
    @RemoteAction
    public static GNE_MCCO_CRM_Base_Ctrl.DataWrapper saveContactRecord(String inputDataWrapperInJSON) {
        GNE_MCCO_CRM_Contact_Controller.DataWrapper inputData = (GNE_MCCO_CRM_Contact_Controller.DataWrapper)JSON.deserialize(inputDataWrapperInJSON, GNE_MCCO_CRM_Contact_Controller.DataWrapper.class);
        return saveContactRecord(inputData);
    }
            
    @RemoteAction
    public static AttendeeWrapper getNewContact(Map<String, String> params) {
        return (new GNE_MCCO_CRM_Interaction_Controller()).fetchNewContact(params);
    }

    @RemoteAction
    public static GNE_MCCO_CRM_Base_Ctrl.DataWrapper getNewContactConfigurationPage(Map<String, String> params) {
        return (new GNE_MCCO_CRM_Interaction_Controller()).fetchContactConfigurationPage();
    }    
}