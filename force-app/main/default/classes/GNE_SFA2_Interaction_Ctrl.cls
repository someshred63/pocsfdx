global without sharing virtual class GNE_SFA2_Interaction_Ctrl extends GNE_SFA2_Base_Ctrl {

    // private transient
    protected transient Id accountId;
    protected transient Account callAccount;
    protected transient Boolean attendeeSectionVisible;
    protected transient Boolean objectiveSectionVisible;
    protected transient Boolean productSectionVisible;
    protected transient Boolean keyMessageSectionVisible;
    protected transient Boolean materialSectionVisible;
    protected transient Boolean attachmentSectionVisible;
    protected transient Boolean preCallSectionVisible;
    protected transient Boolean dependentMaterialsEnabled;
    protected transient Boolean dependentMaterialsPerAttProdEnabled;
    protected transient Boolean mealOptOutEnabled;
    protected transient Boolean pfgEnabled;
    protected transient Boolean unsolicitedReqFieldExists;
    protected transient Boolean simpleEditMode;
    protected transient Boolean strategyVisible;
    protected transient Boolean tacticVisible;
    protected transient Boolean multipleAccountsMode;
    protected transient Boolean noAccountMode;
    protected transient Boolean referralMode;
    protected transient Boolean preCallNewMode;
    protected transient Boolean useRecordOwnerConfig;
    protected transient Boolean onlyContactAttendees;
    protected transient Id referralId;
    protected transient List<GNE_SFA2_Base_Ctrl.Field> attendeesAdditionalFields;
    protected transient List<GNE_SFA2_Base_Ctrl.Field> objectivesAdditionalFields;
    protected transient List<GNE_SFA2_Base_Ctrl.Field> materialsAdditionalFields;
    protected transient List<GNE_SFA2_Base_Ctrl.Field> preCallFields;
    protected transient Map<String, Schema.DescribeFieldResult> callDiscussionFieldsDescribe;
    protected transient Map<String, Schema.DescribeFieldResult> callSampleFieldsDescribe;
    protected transient Map<String, Schema.DescribeFieldResult> callPreCallFieldsDescribe;
    protected transient Set<Id> productIds;
    protected transient Id callDiscussionRecordTypeId;
    protected transient Map<String, SObject> recordsCache;
    protected transient Set<String> inputFieldNames;
    protected transient Set<String> attendeeExcludedFieldNames;
    public transient Map<Id, SObject> childRecordsToRemoveMap;
    protected transient List<Call2_vod__c> mainCallsToUpsert;
    protected transient List<Call2_vod__c> attendeesToUpsert;
    protected transient List<Call2_Detail_vod__c> detailsToUpsert;
    protected transient List<Call2_Interaction_Detail_vod__c> visitReasonDetailsToUpsert;
    protected transient List<Call2_Discussion_vod__c> discussionsToUpsert;
    protected transient List<Call2_Key_Message_vod__c> keyMessagesToUpsert;
    protected transient List<Call2_Sample_vod__c> materialsToUpsert;
    protected transient List<Call_Pre_Call_gne__c> preCallsToUpsert;
    public transient List<Call_PFG_Detail_gne__c> pfgDetailsToUpsert;
    protected transient Map<String, TableRowWrapper> recToWrapperMap;
    protected transient Map<Id, Call2_vod__c> accountIdToCallMap;
    protected transient Map<Id, Call2_vod__c> contactIdToCallMap;
    protected transient List<Attachment> attachmentsToUpsert;
    protected transient List<Attachment> attachmentsToDelete;
    protected transient ReferralWrapper referral;
    protected transient List<Medical_Communication_gne__c> medcomsToUpdate;
    protected transient List<Referral_Assignment_gne__c> referralsToUpdate;
    protected transient GNE_SFA2_PFG_Interaction_Ctrl pfgController;
    protected transient List<Call_Pre_Call_gne__c> existingsPreCalls;
    private Territory2 currentTerritory;

    public static transient Map<String, Set<String>> status2fields = new Map<String, Set<String>>{
            'New - Resolved' => new Set<String>{
                    'FRM_Issue_Diagnosed_gne__c', 'FRM_Issue_Resolved_gne__c'
            },
            'New - In Process' => new Set<String>{
                    'FRM_Issue_Diagnosed_gne__c', 'FRM_Issue_Triaged_gne__c', 'FRM_Complex_Issue_gne__c'
            },
            'New - Issue Unknown' => new Set<String>{
                    'FRM_Issue_Triaged_gne__c', 'FRM_Complex_Issue_gne__c'
            },
            'New - Out Of FRM Scope' => new Set<String>{
                    'FRM_Issue_Diagnosed_gne__c'
            },
            'Update - Issue Resolved' => new Set<String>{
                    'FRM_Complex_Issue_gne__c', 'FRM_Issue_Resolved_gne__c'
            },
            'Update - Still Working' => new Set<String>{
                    'FRM_Complex_Issue_gne__c'
            },
            'FieldsToClear' => new Set<String>{
                    'FRM_Issue_Diagnosed_gne__c', 'FRM_Issue_Resolved_gne__c', 'FRM_Issue_Triaged_gne__c', 'FRM_Complex_Issue_gne__c'
            }
    };

    public static transient Set<String> contentSectionCanadaProfilesSet = new Set<String> {
            'RCanada-SFA-Manager',
            'RCanada-SFA-TS',
            'RCanada-SFA-Ops'
    };

    // static
    private static Map<String, String> attendeeTypeValueToLabelMap;
    private static String staticCurrentUserProfileName;
    private static final String TEAMCODE_OPHTHA = 'OPHTHA';
    private static final String SUBTEAMCODE_OAM = 'OAM';
    private static final String SUBTEAMCODE_OPM = 'OPM';
    private static final String ROLE_OPHTHAOAM = 'OPHTHAOAM';
    private static final String ROLE_OPHTHAOPM = 'OPHTHAOPM';

    public GNE_SFA2_Interaction_Ctrl(ApexPages.StandardController sctrl) {
        this();
    }

    public GNE_SFA2_Interaction_Ctrl() {
        super();
    }

    public GNE_SFA2_Interaction_Ctrl(Map<String, String> params) {
        this.params = params.clone();
    }

    protected virtual override GNE_SFA2_Base_Ctrl.DataWrapper getConstructorData() {
        if (getCurrentUserProfileName() == 'GNE-SYS-DataSupport-Merge') {
            String currInteractionId = ApexPages.currentPage().getParameters().get('id');

            if (String.isNotBlank(currInteractionId)) {
                currentUser = null;
                String recordOwnerAlias = [SELECT Owner.Alias FROM Call2_vod__c WHERE Id = :currInteractionId].Owner.Alias;
                ApexPages.currentPage().getParameters().put('userAlias', recordOwnerAlias);
                useRecordOwnerConfig = true;
            }
        }

        return super.getConstructorData();
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper intInit(Map<String, String> params) {
        attendeeSectionVisible = false;
        objectiveSectionVisible = false;
        productSectionVisible = false;
        keyMessageSectionVisible = false;
        materialSectionVisible = false;
        attachmentSectionVisible = false;
        preCallSectionVisible = false;
        dependentMaterialsEnabled = false;
        dependentMaterialsPerAttProdEnabled = false;
        mealOptOutEnabled = false;
        pfgEnabled = false;
        unsolicitedReqFieldExists = false;
        simpleEditMode = false;
        strategyVisible = false;
        tacticVisible = false;
        onlyContactAttendees = getCurrentUser().isBam();
        multipleAccountsMode = params.containsKey('accountIds');
        noAccountMode = params.containsKey('noAccount');
        referralMode = params.containsKey('referralId');
        preCallNewMode = params.containsKey('preCallEnabled');
        activeMenuItem = 'My Interactions';
        pageExtId = 'interaction';

        GNE_SFA2_Base_Ctrl.DataWrapper result = super.intInit(params);

        if (((getCurrentUser().isCanada() && !GNE_SFA2_Interaction_Util.isExtendedCanadaUser(getCurrentUserProfileName())) || getCurrentUser().isCCEsbriet() || getCurrentUser().isBam())
                && result != null && result.config != null && result.config.mode == GNE_SFA2_Base_Ctrl.EDIT_MODE && ((DataWrapper) result).isCompleted == true) {
            result.config.mode = GNE_SFA2_Base_Ctrl.VIEW_MODE;
            result.addInfo(createException(new CannotEditCompletedInteractionInfoException()));
        }

        return result;
    }

    //this is exist in class GNE_SFA2_HCPtoFRMHCOMappingEngine on DEV
    private GNE_SFA2_Base_Ctrl.DataWrapper getSBCConfig() {
        GNE_SFA2_SBC_Ctrl sbc = new GNE_SFA2_SBC_Ctrl();
        sbc.DataWrapper = new GNE_SFA2_SBC_Ctrl.DataWrapper();
        Map<String, String> params = new Map<String, String>{
                'uiType' => 'standard',
                'debugMode' => '',
                'apiStaticResource' => '',
                'uiStaticResource' => '',
                'pageStaticResource' => '',
                'isPopup' => 'false',
                'popupReturnAction' => ''
        };

        return sbc.intInit(params);
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

    protected override Boolean pageDispatcher() {
        return (super.pageDispatcher() && getCurrentUser().isSfaBrand())
                || (getCurrentUser().isCanada() && !GNE_SFA2_Util.isCanadaSAMUser())
                || (getCurrentUser().isCrm() && !checkDispatchToCrm())
                || getCurrentUser().isFrm()
                || GNE_SFA2_Util.isCanadaINFUUser();
    }

    protected override PageReference getDispatcherOtherPage() {
        PageReference result = null;

        if (appContext.isSfa2Mode) {
            result = mode == GNE_SFA2_Base_Ctrl.VIEW_MODE ? Page.GNE_SFA2_Interaction_Layout : Page.GNE_SFA2_Interaction_Edit_Create;
        } else if (Pattern.matches('(?i)^GNE-CM-.*$|^GNE-AGS-CCO-Analyst$|^GNE-AGS-CCO-Manager$|^GNE-AGS-CCO-TempAnalyst$', getCurrentUserProfileName())) {
            result = Page.AGS_Interaction_Details_gne;
        } else if (Pattern.matches('(?i)^GNE-MCCO-AM$|^GNE-MCCO-Kaiser$', getCurrentUserProfileName())) {
            result = Page.GNE_MCCO_CRM_Interaction;
        } else if (checkDispatchToCrm()) {
            result = Page.GNE_CRM_Interaction;
        } else {
            result = new PageReference('/' + params.get('id') + '?nooverride=1');
        }

        return result;
    }

    private Boolean checkDispatchToCrm() {
        return getCurrentUser().isCrm() && ApexPages.currentPage() != null && ApexPages.currentPage().getUrl().startsWithIgnoreCase('/apex/GNE_SFA2_Interaction');
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper initNewMode() {
        this.params.put('sObjectType', 'Call2_vod__c');
        return super.initNewMode();
    }

    protected override virtual GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapper(GNE_SFA2_Base_Ctrl.DataWrapper dataWrapper) {
        DataWrapper result = (DataWrapper) super.getDataWrapper(dataWrapper);
        result.recordDescribe.sObjectLabel = 'Interaction';
        if (result.isStandardUI == true) {
            //result.iconBase64 = GNE_MCCO_CRM_Util.getDocumentBase64('Interaction_Tab_Icon');
        }
        // General
        Call2_vod__c call = (Call2_vod__c) record;
        Boolean isCompleted = result.isCompleted = call.Interaction_Status_gne__c == 'Completed';
        Boolean hasUnsolicitedFieldEditAvailibleCanada = unsolicitedReqFieldExists && GNE_SFA2_Interaction_Util.getHasUnsolicitedFieldEditAvailibleCanada();
        result.simpleEditMode = simpleEditMode = isCompleted && hasUnsolicitedFieldEditAvailibleCanada;
        result.multipleAccountsMode = multipleAccountsMode;
        result.noAccountMode = noAccountMode;

        // Multiple Accounts
        if (multipleAccountsMode) {
            result.multipleAccountsData = getMultipleAccountsData();
        } else if (noAccountMode && mode == NEW_MODE) {

        } else {
            // Account
            result.callAccount = new AccountWrapper(callAccount);
            // Addresses
            result.addresses = getAddresses();
            // Attendees

            if (attendeeSectionVisible) {
                List<GNE_SFA2_Base_Ctrl.Field> attendeeColumns = getAttendeeColumns();
                List<GNE_SFA2_Base_Ctrl.Field> attendeeSearchColumns = getAttendeeSearchColumns();
                List<AttendeeOptionWrapper> attendeeOptions = isSfaBrandUser ? new List<AttendeeOptionWrapper>() : getAttedeeOptions(attendeeColumns, attendeeSearchColumns, getCurrentUser().isBam());
                List<AttendeeWrapper> attendees = getSelectedAttendess(attendeeColumns);
                result.attendeeData = new AttendeeData(attendeeOptions, attendeeColumns, attendeeSearchColumns, attendees, onlyContactAttendees);
            }

            if (referralMode) {
                result.referralMode = referralMode;
                result.referral = referral;
                result.completeReferralQuestion = System.Label.GNE_SFA2_Referral_Interaction_Completed;
            }
        }

        // Objectives
        List<ProductOptionWrapper> objectiveOptions;
        if (objectiveSectionVisible) {
            List<GNE_SFA2_Base_Ctrl.Field> objectiveColumns = getProductColumns(true);
            objectiveOptions = getProductOptions(objectiveColumns, true);
            ProductWrapper objectiveTemplate = getObjectiveTemplate(objectiveColumns);
            List<ProductWrapper> objectives = getProductWrappers(objectiveColumns, true);
            List<DependentPicklistItem> productStrategyTacticItems = isSfaBrandUser ? null : getProductStrategyTacticItems(objectiveOptions);
            result.productData = new ProductData(objectiveOptions, objectiveColumns, objectiveTemplate, objectives, productStrategyTacticItems, getProductContents());
        } else if (productSectionVisible) {
            List<GNE_SFA2_Base_Ctrl.Field> productColumns = getProductColumns(false);
            List<ProductOptionWrapper> productOptions = getProductOptions(productColumns, false);
            List<ProductWrapper> productWrappers = getProductWrappers(productColumns, false);
            result.productData = new ProductData(productOptions, productColumns, null, productWrappers, null, null);
        }

        // Key Messages
        if (keyMessageSectionVisible) {
            List<GNE_SFA2_Base_Ctrl.Field> columns = getKeyMessagesColumns();
            List<KeyMessageOptionWrapper> options = getKeyMessageOptions(columns);
            List<KeyMessageWrapper> keyMessageWrappers = getKeyMessageWrappers(columns);
            result.keyMessageData = new KeyMessageData(options, columns, keyMessageWrappers);
        }

        // Materials
        if (materialSectionVisible) {
            List<GNE_SFA2_Base_Ctrl.Field> columns = getMaterialsColumns();
            MaterialWrapper wrapperTemplate = getMaterialTemplate(columns);
            List<MaterialWrapper> materialWrappers = getMaterialWrappers(columns);
            Set<Id> productIds = new Set<Id>();
            for (MaterialWrapper mw : materialWrappers) {
                GNE_SFA2_Base_Ctrl.Field matId = mw.getField('Product_vod__c');
                if (matId != null && String.isNotEmpty(matId.value)) {
                    productIds.add(Id.valueOf(matId.value));
                }
            }
            List<MaterialProductItem> mProducts = getMaterialProducts(productIds);
            result.isMaterialPerAttendeeAndProductModeEnabled = dependentMaterialsPerAttProdEnabled;
            result.materialData = new MaterialData(columns, wrapperTemplate, materialWrappers, mProducts);
        }

        //PreCall
        if (preCallSectionVisible) {
            List<GNE_SFA2_Base_Ctrl.Field> columns = getPreCallColumns();
            List<PreCallWrapper> rows = getPreCallsWrappers(columns);
            PreCallWrapper wrapperTemplate = getPreCallTemplate(columns);
            Set<Id>productIds = new Set<Id>();
            for (ProductOptionWrapper wrapper : objectiveOptions) {
                productIds.add(wrapper.rowId);
            }
            List<DependentPicklistItem> interactionObjectives = getPreCallObjectiveItems(productIds);
            List<QuestionItem> questions = getPreCallQuestionsItems();
            result.isPreCallEnabled = call.Pre_Call_Plan_gne__c;
            Datetime lmd = getPreCallsLastModifiedDate();
            String preCallLastModifiedDate = lmd != null ? lmd.format('MM/dd/yyyy') : '';
            result.preCallData = new PreCallData(columns, wrapperTemplate, rows, interactionObjectives, questions, getProductToSegmentMap(), preCallLastModifiedDate);
        }

        //Attachments
        if (attachmentSectionVisible) {
            result.attachmentData = getAttachments(call.Id);
        }

        // PFG
        if (pfgEnabled) {
            result = getPfgController().init(result);
        }

        return result;
    }

    protected virtual override GNE_SFA2_Base_Ctrl.AppContext getAppContext() {
        if (appContext == null && useRecordOwnerConfig == true && String.isNotBlank(params.get('id'))) {
            GNE_SFA2_User_App_Context_gne__c appc = GNE_SFA2_Util.getApplicationContextByRecordOwner(params.get('id'));

            if (appc != null) {
                Boolean hasSFA2Access = (appc.SFA2_Mode_gne__c && appc.Run_in_SFA2_UI_gne__c);
                appContext = new GNE_SFA2_Base_Ctrl.AppContext(currentUser, appc.App_Name_gne__c, appc.Brand_gne__c, appc.Role_gne__c, hasSFA2Access);
            }
        }

        super.getAppContext();

        if(getCurrentUser().isBam()) {
            String accId = accountId == null ? ApexPages.currentPage().getParameters().get('accountId') : accountId;
            if(accId == null){
                String currInteractionId = ApexPages.currentPage().getParameters().get('id');
                Call2_vod__c call = [
                        SELECT Id, Parent_Call_vod__c, Parent_Call_vod__r.Account_vod__c,
                                Account_vod__c, Account_vod__r.Id, Account_vod__r.Name, Account_vod__r.IsPersonAccount,
                                Referral_Assignment_gne__c, Parent_Call_vod__r.Referral_Assignment_gne__c
                        FROM Call2_vod__c
                        WHERE Id = :currInteractionId
                ];

                accId = String.isNotBlank(call.Parent_Call_vod__c) ? call.Parent_Call_vod__r.Account_vod__c : call.Account_vod__c;
            }
            overriveAppContext(accId);
        }

        return appContext;
    }

    private void overriveAppContext(Id accId) {
        Id currentTerritoryId = getCurrentTerritoryId();

        if(appContext == null) {
            appContext = new AppContext(currentUser, 'NoApp', null, null, false);
        }

        Territory2 terriotryFromAccount;
        List <Territory2> terrForUserAndCurrectAccount = [
                SELECT Id, Name, External_id_gne__c, ParentTerritory2Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
                FROM Territory2
                WHERE Id IN (Select Territory2Id FROM ObjectTerritory2Association WHERE ObjectId = :accId)
                AND ID IN (select Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId())
        ];
        Boolean isSelectedTerritoryFromScope = false;
        for(Territory2 terr : terrForUserAndCurrectAccount) {
            if(terr.Id == currentTerritoryId){
                isSelectedTerritoryFromScope = true;
            }
        }
        if(!isSelectedTerritoryFromScope && !terrForUserAndCurrectAccount.isEmpty()) {
            currentTerritoryId = terrForUserAndCurrectAccount[0].Id;
        }
        if(currentTerritoryId != null) {
            currentTerritory = [SELECT Id, Name, External_id_gne__c, ParentTerritory2Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c FROM Territory2 WHERE Id =:currentTerritoryId LIMIT 1];
            String teamCode = currentTerritory.Salesforce_Code_gne__c != null ? currentTerritory.Salesforce_Code_gne__c : '';
            String subTeamCode = currentTerritory.Salesforce_SubTeam_Code_gne__c != null ? currentTerritory.Salesforce_SubTeam_Code_gne__c : '';
            if (teamCode == TEAMCODE_OPHTHA) {
                if(subTeamCode == SUBTEAMCODE_OAM) {
                    appContext.role = ROLE_OPHTHAOAM;
                } else if(subTeamCode == SUBTEAMCODE_OPM) {
                    appContext.role = ROLE_OPHTHAOPM;
                }
            }
        }
    }

    protected virtual override Map<String, String> getTranslationsMap() {
        return new Map<String, String>{
                'errorAddressIsRequired' => String.format(System.Label.GNE_SFA2_HideAddress_Error_AddressIsRequired, new String[]{
                        'Interaction'
                })
        };
    }

    protected override String checkInputParam(String paramName) {
        String result = super.checkInputParam(paramName);

        if (paramName == 'accountId' || paramName == 'referralId') {
            try {
                Id.valueOf(result);
            } catch (Exception e) {
                throw createException(new GNE_SFA2_Base_Ctrl.WrongInputParamTypeErrorException(), new Object[]{
                        paramName, result, 'Id'
                });
            }
        }

        return result;
    }

    private DataWrapper getDataWrapperWithMultipleAccountsData() {
        DataWrapper result = (DataWrapper) (DataWrapper = getDataWrapperInstance());

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
        List<Account> accs = [
                SELECT Id, Name, IsPersonAccount, (
                        SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c
                        FROM Contacts
                        WHERE Active_gne__c = TRUE
                        ORDER BY LastName NULLS LAST
                ), (
                        SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c, PFG_BDTD_gne__c, PFG_BDTD_calc_gne__c
                        FROM Address_vod__r
                        WHERE Inactive_vod__c = FALSE AND Primary_vod__c = TRUE
                        LIMIT 1
                )
                FROM Account
                WHERE Id IN :accountIds
        ];

        for (Account acc : accs) {
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

    protected override GNE_SFA2_Base_Ctrl.UserWrapper getCurrentUser() {
        currentUser = super.getCurrentUser();
        staticCurrentUserProfileName = currentUser.getProfileName();
        return currentUser;
    }

    protected override SObject getRecord(List<SFA2_Configuration_Object_gne__c> configObjects) {
        callAccount = null;
        Account attendeeAccount = null;

        if (String.isNotBlank(recordId)) {
            getRecordAccess(getCurrentUser().id);
            Call2_vod__c call = [
                    SELECT Id, Parent_Call_vod__c, Parent_Call_vod__r.Account_vod__c,
                            Account_vod__c, Account_vod__r.Id, Account_vod__r.Name, Account_vod__r.IsPersonAccount,
                            Referral_Assignment_gne__c, Parent_Call_vod__r.Referral_Assignment_gne__c
                    FROM Call2_vod__c
                    WHERE Id = :recordId
            ];
            recordId = String.isNotBlank(call.Parent_Call_vod__c) ? call.Parent_Call_vod__c : recordId;
            accountId = String.isNotBlank(call.Parent_Call_vod__c) ? call.Parent_Call_vod__r.Account_vod__c : call.Account_vod__c;
            referralId = String.isNotBlank(call.Parent_Call_vod__c) ? call.Parent_Call_vod__r.Referral_Assignment_gne__c : call.Referral_Assignment_gne__c;
            referralMode = String.isNotBlank(referralId);
            attendeeAccount = call.Account_vod__r;
        }

        if (referralMode) {
            referralId = String.isNotBlank(referralId) ? referralId : (Id) checkInputParam('referralId');
            Referral_Assignment_gne__c ra = [
                    SELECT Id, Status_Referral_gne__c, Medical_Request_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Referral_History_gne__c,
                            Assigned_To_gne__r.Name, Assigned_To_gne__r.Profile_Name_gne__c
                    FROM Referral_Assignment_gne__c
                    WHERE Id = :referralId
            ];
            referral = new ReferralWrapper(ra);
            accountId = referral.accountId;
        } else if (String.isBlank(accountId) && !multipleAccountsMode && !noAccountMode) {
            accountId = checkInputParam('accountId');
        }

        if (String.isNotBlank(accountId)) {
            Set<Boolean> inactiveValues = isSfaBrandUser == true ? new Set<Boolean>{
                    false, true
            } : new Set<Boolean>{
                    false
            };
            try {
                callAccount = [
                        SELECT Id, Name, IsPersonAccount, (
                                SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c,
                                        PFG_BDTD_gne__c, PFG_BDTD_calc_gne__c, Location_gne__Latitude__s, Location_gne__Longitude__s
                                FROM Address_vod__r
                                WHERE Inactive_vod__c IN :inactiveValues
                                ORDER BY Name
                        )
                        FROM Account
                        WHERE Id = :accountId
                ];
            } catch (Exception e) {
                throw createException(new RecordPermissionErrorException(), new Object[]{
                        'Read', currentUser.name
                });
            }
        }

        Call2_vod__c call = (Call2_vod__c) super.getRecord(configObjects);
        if (GNE_SFA2_Util.isCanadaINFUUser()) {
            if (params.get('addrId') != null) {
                String addressId = checkInputParam('addrId');
                if (String.isNotBlank(addressId)) {
                    call.Parent_Address_vod__c = addressId;
                }
            }
        }

        if (callAccount != null) {
            if (isSfaBrandUser && attendeeAccount != null && !callAccount.IsPersonAccount) {
                call.Account_vod__c = attendeeAccount.Id;
                call.Account_vod__r = attendeeAccount;
            } else {
                call.Account_vod__c = callAccount.Id;
                call.Account_vod__r = callAccount;
            }
        }

        if (call.Id == null) {
            if (!getCurrentUser().isCCEsbriet()) {
                call.Call_Datetime_vod__c = Datetime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0);
            }
            call.Interaction_Status_gne__c = 'Planned';

            if (referralMode) {
                call.Referral_Assignment_gne__c = referralId;
                call.Visit_Reason_gne__c = 'Pending Follow-Up';

                if (currentUser.getProfileName() == GNE_Referral_Utils.MSLProfile || currentUser.getProfileName() == GNE_Referral_Utils.MSLManagerProfile) {
                    call.Primary_Interaction_Reason_gne__c = 'Responsive';
                }
            }
            if (preCallNewMode) {
                call.Pre_Call_Plan_gne__c = true;
            }
        }

        return call;
    }

    protected override GNE_SFA2_Base_Ctrl.RecordAccess getRecordAccess(String userId) {
        GNE_SFA2_Base_Ctrl.RecordAccess result = super.getRecordAccess(userId);

        if (isSfaBrandUser && callAccount != null && !callAccount.IsPersonAccount) {
            result.editAccess = false;
            result.deleteAccess = false;
            checkRecordAccess(result);
        }

        return result;
    }

    protected override GNE_SFA2_Base_Ctrl.Config getConfiguration(String recordTypeDeveloperName) {
        GNE_SFA2_Base_Ctrl.Config result = super.getConfiguration(recordTypeDeveloperName);

        unsolicitedReqFieldExists = getFieldByName(String.valueOf(Call2_vod__c.Unsolicited_Request_gne__c)) != null;
        GNE_SFA2_Base_Ctrl.Field hcpMealOptOutField = getFieldByName(String.valueOf(Call2_vod__c.HCP_Account_Meal_Opt_Out_gne__c));

        if (hcpMealOptOutField != null && callAccount != null && !callAccount.IsPersonAccount) {
            hcpMealOptOutField.changeToBlankSpace();
        }

        /*kozminsl: Only interactions vs HCP should contains PreCall Plan.*/
        if (preCallSectionVisible && !callAccount.IsPersonAccount) {
            preCallSectionVisible = false;
            GNE_SFA2_Base_Ctrl.Field preCallField = getFieldByName(String.valueOf(Call2_vod__c.Pre_Call_Plan_gne__c));
            if (preCallField != null) {
                preCallField.changeToBlankSpace();
            }
            Integer index = null;
            for (Integer i = 0; i < result.sections.size(); i++) {
                if (result.sections[i].name == 'CallPreCall') {
                    result.sections.remove(i);
                    break;
                }
            }
        }
        return result;
    }

    protected override GNE_SFA2_Base_Ctrl.ConfigItem readConfigObject(SFA2_Configuration_Object_gne__c conf, List<GNE_SFA2_Base_Ctrl.Button> buttons, List<GNE_SFA2_Base_Ctrl.Section> sections, List<GNE_SFA2_Base_Ctrl.RelatedList> relatedList) {
        GNE_SFA2_Base_Ctrl.ConfigItem ci;
        if (conf.Name == 'CallObjectives' || conf.Name == 'CallObjectivesWithoutOptions') {
            objectiveSectionVisible = true;
            GNE_SFA2_Base_Ctrl.Section sec = new GNE_SFA2_Base_Ctrl.Section(conf, new List<GNE_SFA2_Base_Ctrl.Field>());
            sections.add(sec);
            ci = sec;

            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallDiscussionFieldsDescribe();
            objectivesAdditionalFields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_SFA2_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    strategyVisible |= confDetail.API_Name_gne__c == String.valueOf(Call2_Discussion_vod__c.Product_Strategy_vod__c);
                    tacticVisible |= confDetail.API_Name_gne__c == String.valueOf(Call2_Discussion_vod__c.Product_Tactic_vod__c);
                    Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase());

                    if (fieldDescribe != null) {
                        GNE_SFA2_Base_Ctrl.Field field = confDetail.API_Name_gne__c == String.valueOf(Call2_Discussion_vod__c.Event_Curriculum_gne__c) ? getField(confDetail) : new GNE_SFA2_Base_Ctrl.Field(confDetail, fieldDescribe, 'Call2_Discussion_vod__c');
                        if (String.isNotEmpty(confDetail.Attributes_gne__c) && confDetail.Attributes_gne__c.contains('--hcpOnly') && callAccount.IsPersonAccount == false) continue;
                        objectivesAdditionalFields.add(field);
                    }
                }
            }
        } else if (conf.Name == 'CallMaterials') {
            materialSectionVisible = true;
            dependentMaterialsEnabled = getCurrentUser().isCanada();
            GNE_SFA2_Base_Ctrl.Section sec = new GNE_SFA2_Base_Ctrl.Section(conf, new List<GNE_SFA2_Base_Ctrl.Field>());
            sections.add(sec);
            ci = sec;

            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallSampleFieldsDescribe();
            materialsAdditionalFields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_SFA2_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase());
                    materialsAdditionalFields.add(new GNE_SFA2_Base_Ctrl.Field(confDetail, null, null, fieldDescribe, 'Call2_Sample_vod__c'));
                }
            }

            Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get('Contact_vod__c'.toLowerCase());
            materialsAdditionalFields.add(new GNE_SFA2_Base_Ctrl.Field('Contact', null, true, false, fieldDescribe, 'Call2_Sample_vod__c'));
        } else if (conf.Name == 'CallPreCall') {
            preCallSectionVisible = true;

            GNE_SFA2_Base_Ctrl.Section sec = new GNE_SFA2_Base_Ctrl.Section(conf, new List<GNE_SFA2_Base_Ctrl.Field>());
            sections.add(sec);
            ci = sec;

            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallPreCallFieldsDescribe();
            preCallFields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_SFA2_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase());
                    preCallFields.add(new GNE_SFA2_Base_Ctrl.Field(confDetail, null, null, fieldDescribe, 'Call_Pre_Call_gne__c'));
                }
            }
        } else {
            ci = super.readConfigObject(conf, buttons, sections, relatedList);
        }

        GNE_SFA2_Base_Ctrl.Section section = ci != null && ci instanceof GNE_SFA2_Base_Ctrl.Section ? (GNE_SFA2_Base_Ctrl.Section) ci : null;
        String sectionName = section != null ? section.name : null;

        mealOptOutEnabled |= (sectionName == 'CallMealExpense' && section.attributeFlags != null && section.attributeFlags.contains('mealOptOut'));
        attendeeSectionVisible |= sectionName == 'CallAttendees';
        productSectionVisible |= (sectionName == 'CallProducts' || sectionName == 'CallProductsOnly');
        keyMessageSectionVisible |= sectionName == 'CallKeyMessages';
        attachmentSectionVisible |= sectionName == 'CallAttachments';
        pfgEnabled |= sectionName == 'CallPfgs' && callAccount != null && callAccount.IsPersonAccount;
        dependentMaterialsPerAttProdEnabled |= (sectionName == 'CallMaterials' && section.attributeFlags != null && section.attributeFlags.contains('attproddependend') && record != null && String.valueOf(record.get('Interaction_Status_gne__c')) != 'Completed' && callAccount != null && callAccount.IsPersonAccount);

        if (section != null && section.attributeFlags != null && section.attributeFlags.contains('hideHeader')) {
            ci.label = null;
        }

        if (sectionName == 'CallAttendees') {
            attendeesAdditionalFields = new List<GNE_SFA2_Base_Ctrl.Field>();
            List<GNE_SFA2_Base_Ctrl.Field> fields = section.fields;

            for (Integer i = fields.size() - 1; i >= 0; i--) {
                GNE_SFA2_Base_Ctrl.Field field = fields[i];

                if (field.attributeFlags != null && field.attributeFlags.contains('columnField')) {
                    fields.remove(i);
                }

                attendeesAdditionalFields.add(field);
            }
        } else if (sectionName == 'CallMealExpense') {
            ((DataWrapper) DataWrapper).mealExpenseLabel = System.Label.GNE_SFA2_Meal_Opt_Out_Acknowledgement_Statement;
        } else if (sectionName == 'CallPfgs') {
            getPfgController().setPfgSectionFields(section);
        } else if (sectionName == 'CallDetail' && section.fields != null) {
            for (GNE_SFA2_Base_Ctrl.Field field :section.fields) {
                if(field.attributes != null  ){
                    Map<String, String> atrributeMap = parseAttributes(field.attributes);
                    if(atrributeMap.containsKey('multipicklistvalues')) {
                        List<PicklistValue> newPicklist = new List<PicklistValue>();
                        Set<String> pickListNewValues = new Set<String> (atrributeMap.get('multipicklistvalues').split('::'));
                        for(PicklistValue pv: field.describe.picklistValues) {
                            if(pickListNewValues.contains(pv.value)) {
                                newPicklist.add(pv);
                            }
                        }
                        field.describe.picklistValues.clear();
                        field.describe.picklistValues.addAll(newPicklist);
                    }
                }
            }
        }
        else if(sectionName == 'CallNotes') {
            ((DataWrapper) DataWrapper).callNotesDisclaimerLabel = System.Label.Independent_Insight_Label;
        }

        return ci;
    }

    private Map<String, String> parseAttributes(String data) {
        Map<String, String> result = new Map<String, String>();

        for (String d : data.split(';')) {
            List<String> attributeSplit = d.split('=');
            if (attributeSplit.size() == 2) {
                result.put(attributeSplit.get(0), attributeSplit.get(1));
            }
        }

        return result;
    }

    protected override GNE_SFA2_Base_Ctrl.Field getField(SFA2_Configuration_Object_Detail_gne__c confDetail) {
        GNE_SFA2_Base_Ctrl.Field fld = null;

        if (confDetail.API_Name_gne__c == String.valueOf(Call2_Discussion_vod__c.Event_Curriculum_gne__c)) {
            fld = new GNE_SFA2_Base_Ctrl.Field(confDetail, null, null, getCallDiscussionFieldsDescribe().get(confDetail.API_Name_gne__c.toLowerCase()), 'Call2_Discussion_vod__c');
            fld.describe.lookupData = new GNE_SFA2_Base_Ctrl.CustomLookupData('EDM_Curriculum_Lookup');
            fld.describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>{
                    new GNE_SFA2_Base_Ctrl.PicklistValue('', '--None--')
            };

            for (Event_Curriculum_gne__c ec : [SELECT Id, Name FROM Event_Curriculum_gne__c WHERE Curriculum_Status_gne__c = 'Active' AND Curriculum_External_Id_gne__c != null ORDER BY Name]) {
                fld.describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(ec.Id, ec.Name));
            }
        } else {
            fld = super.getField(confDetail);
        }

        if (fld.name == String.valueOf(Call2_vod__c.Account_Plan_vod__c)) {
            fld.describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>{
                    new GNE_SFA2_Base_Ctrl.PicklistValue('', '--None--')
            };

            if (callAccount != null) {
                List<Account_Plan_vod__c> aPlans = [SELECT Id, Name FROM Account_Plan_vod__c WHERE Active_vod__c = TRUE AND Account_vod__c = :callAccount.Id ORDER BY Name];

                for (Account_Plan_vod__c aPlan : aPlans) {
                    fld.describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(aPlan.Id, aPlan.Name));
                }
            }
        }
        return fld;
    }

    protected override Set<String> getQueryFieldsFromConfigObject(SFA2_Configuration_Object_gne__c conf) {
        Set<String> fieldNames = new Set<String>();
        if (conf.Name == 'CallAttendees') {
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getSObjectFieldsDescribe();
            Set<String> attendeeFields = new Set<String>{
                    'id', 'name', 'account_vod__c', 'ems_international_speaker_gne__c', 'contact_vod__c', 'user_vod__c',
                    'attendee_type_vod__c', 'hcp_attendee_meal_opt_out_gne__c', 'hcp_or_attendee_meal_opt_out_gne__c', 'attendee_type_fpm_gne__c',
                    'account_vod__r.lastname', 'account_vod__r.firstname', 'account_vod__r.ispersonaccount', 'other_attendees_count_gne__c'
            };

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_SFA2_Base_Ctrl.FIELD && confDetail.Attributes_gne__c != null && confDetail.Attributes_gne__c.contains('--columnField') && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();
                    attendeeFields.add(fieldName);
                }
            }

            for (String fieldName : attendeeFields) {
                if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                    attendeeFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                }
            }

            fieldNames.add(String.format('(SELECT {0} FROM Call2_vod__r)', new String[]{
                    String.join(new List<String>(attendeeFields), ',')
            }));
        } else if (conf.Name == 'CallObjectives') {
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallDiscussionFieldsDescribe();
            Set<String> objectiveFields = new Set<String>{
                    'recordtypeid', 'zvod_Product_Map_vod__c'
            };

            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == GNE_SFA2_Base_Ctrl.FIELD && String.isNotBlank(confDetail.API_Name_gne__c)) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();

                    Schema.DescribeFieldResult fDescribe = fieldsDescribe.get(fieldName);
                    Boolean isCallDiscussionField = false;

                    if (fDescribe != null) {
                        objectiveFields.add(fieldName);
                        isCallDiscussionField = true;
                    } else if ((fDescribe = getSObjectFieldsDescribe().get(fieldName)) != null) {
                        fieldNames.add(fieldName);
                    }

                    String displayFieldName = fieldName == String.valueOf(Call2_Discussion_vod__c.Event_Curriculum_gne__c) ? String.valueOf(Event_Curriculum_gne__c.Aprimo_ID_gne__c).toLowerCase() : 'name';
                    String ralationshipFieldName = fDescribe != null && String.isNotBlank(fDescribe.getRelationshipName()) ? (fDescribe.getRelationshipName() + '.' + displayFieldName) : null;

                    if (ralationshipFieldName != null) {
                        if (isCallDiscussionField) {
                            objectiveFields.add(ralationshipFieldName);
                        } else {
                            fieldNames.add(ralationshipFieldName);
                        }
                    }
                }
            }

            fieldNames.add(String.format('(SELECT {0} FROM Call2_Discussion_vod__r WHERE Product_vod__c != null ORDER BY {1})', new String[]{
                    String.join(new List<String>(objectiveFields), ','), String.valueOf(Call2_Discussion_vod__c.Detail_Priority_gne__c)
            }));
        } else if (conf.Name == 'CallProducts') {
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Detail_vod__r WHERE Product_vod__c != null ORDER BY {1})', new String[]{
                    String.join(new List<String>{
                            'Id', 'Product_vod__c', 'Product_vod__r.Name'
                    }, ','), String.valueOf(Call2_Detail_vod__c.Detail_Priority_vod__c)
            }));
        } else if (conf.Name == 'CallKeyMessages') {
            Set<String> keyMessageFieldName = new Set<String>{
                    'Id', 'Name',
                    String.valueOf(Call2_Key_Message_vod__c.Key_Message_vod__c), 'Key_Message_vod__r.Name', 'Key_Message_vod__r.Description_vod__c',
                    String.valueOf(Call2_Key_Message_vod__c.Reaction_vod__c),
                    String.valueOf(Call2_Key_Message_vod__c.Product_vod__c), 'Product_vod__r.Name'
            };
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Key_Message_vod__r ORDER BY {1})', new String[]{
                    String.join(new List<String>(keyMessageFieldName), ','), 'Product_vod__r.Name, Key_Message_vod__r.Name'
            }));
        } else if (conf.Name != 'CallMaterials') {
            fieldNames.addAll(super.getQueryFieldsFromConfigObject(conf));
        } else if (conf.Name != 'CallPfgs') {
            fieldNames.add(getPfgController().getPfgSubQuery());
        }

        return fieldNames;
    }

    private GNE_SFA2_PFG_Interaction_Ctrl getPfgController() {
        pfgController = pfgController != null ? pfgController : new GNE_SFA2_PFG_Interaction_Ctrl(this);
        return pfgController;
    }

    private List<AddressWrapper> getAddresses() {
        List<AddressWrapper> result = new List<AddressWrapper>();
        Set<Id> hiddenAddrIds = (new GNE_SFA2_UserPreference_Ctrl()).getHiddenAddressIds(getCurrentUser().id, callAccount.Id);

        for (Address_vod__c address : callAccount.Address_vod__r) {
            result.add(new AddressWrapper(address, hiddenAddrIds.contains(address.Id)));
        }

        return result;
    }

    private Map<String, Schema.DescribeFieldResult> getCallDiscussionFieldsDescribe() {
        cacheCallDiscussionFieldsDescribe();
        return callDiscussionFieldsDescribe;
    }

    public Id getCallDiscussionRecordTypeId() {
        cacheCallDiscussionFieldsDescribe();
        return callDiscussionRecordTypeId;
    }

    private void cacheCallDiscussionFieldsDescribe() {
        if (callDiscussionFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Call2_Discussion_vod__c.SObjectType.getDescribe();
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

                if (recordType != null && rtInfo.getName() == recordType.Name) {
                    callDiscussionRecordTypeId = rtInfo.getRecordTypeId();
                    break;
                }
            }
        }
    }

    private Map<String, Schema.DescribeFieldResult> getCallPreCallFieldsDescribe() {
        cacheCallPreCallFieldsDescribe();
        return callPreCallFieldsDescribe;
    }

    private Map<String, Schema.DescribeFieldResult> getCallSampleFieldsDescribe() {
        cacheCallSampleFieldsDescribe();
        return callSampleFieldsDescribe;
    }

    private void cacheCallPreCallFieldsDescribe() {
        if (callPreCallFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Call_Pre_Call_gne__c.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            callPreCallFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                callPreCallFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
        }
    }

    private void cacheCallSampleFieldsDescribe() {
        if (callSampleFieldsDescribe == null) {
            Schema.DescribeSObjectResult sObjectDescribe = Call2_Sample_vod__c.SObjectType.getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            callSampleFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();

            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                callSampleFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
        }
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getAttendeeColumns() {
        return getAttendeeColumns(isSfaBrandUser, getIsFPMProfile(), getIsBAMProfile(), mealOptOutEnabled, attendeesAdditionalFields);
    }

    private static List<GNE_SFA2_Base_Ctrl.Field> getAttendeeColumns(Boolean isSfaBrandUser, Boolean isFPMProfile, Boolean isBAMProfile, Boolean mealOptOutEnabled, List<GNE_SFA2_Base_Ctrl.Field> attendeesAdditionalFields) {
        List<GNE_SFA2_Base_Ctrl.Field> result;

        if (isSfaBrandUser) {
            result = new List<GNE_SFA2_Base_Ctrl.Field>{
                    new GNE_SFA2_Base_Ctrl.Field('lastName', 'LAST NAME', new List<String>{
                            GNE_SFA2_Base_Ctrl.NEW_MODE, GNE_SFA2_Base_Ctrl.EDIT_MODE
                    }),
                    new GNE_SFA2_Base_Ctrl.Field('firstName', 'FIRST NAME', new List<String>{
                            GNE_SFA2_Base_Ctrl.NEW_MODE, GNE_SFA2_Base_Ctrl.EDIT_MODE
                    }),
                    new GNE_SFA2_Base_Ctrl.Field('attendeeName', 'ATTENDEE', new List<String>{
                            GNE_SFA2_Base_Ctrl.VIEW_MODE
                    })
            };
        } else if (isBAMProfile) {
            GNE_SFA2_Base_Ctrl.Field attendeTypeField = new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type');
            attendeTypeField.readOnly = false;
            FieldDescribe fd = new FieldDescribe();
            fd.calculated = false;
            fd.caseSensitive = false;
            fd.createable = true;
            fd.dependentPicklist = false;
            fd.htmlFormatted = false;
            fd.inlineHelpText = null;
            fd.label = 'Type';
            fd.length = null;
            fd.name = 'Attendee_Type_vod__c';
            fd.nillable = true;
            fd.permissionable = true;
            fd.picklistValues = new List<PicklistValue>{
                    new PicklistValue('Contact_vod', 'Contact', true, true), new PicklistValue('Person_Account_vod', 'HCP', true, false)
            };
            fd.referenceTo = null;
            fd.relationshipName = null;
            fd.restrictedPicklist = false;
            fd.sObjectType = 'Call2_vod__c-child';
            fd.type = 'picklist';
            fd.updateable = true;

            attendeTypeField.describe = fd;
            result = new List<GNE_SFA2_Base_Ctrl.Field>{
                    new GNE_SFA2_Base_Ctrl.Field('attendeeName', 'Attendee'),
                    attendeTypeField
            };
        } else {
            result = new List<GNE_SFA2_Base_Ctrl.Field>{
                    new GNE_SFA2_Base_Ctrl.Field('attendeeName', 'Attendee'),
                    new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
            };
            if (isFPMProfile) {
                result.add(new GNE_SFA2_Base_Ctrl.Field('attendeeTypeFPM', 'Attendee Type'));
            }
        }

        if (mealOptOutEnabled) {
            result.add(new GNE_SFA2_Base_Ctrl.Field('HCP_Attendee_Meal_Opt_Out_gne__c', isSfaBrandUser ? 'MEAL OPT OUT?' : 'Meal Opt Out', null, null, null, null, false, false, null, new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.HCP_Attendee_Meal_Opt_Out_gne__c.getDescribe(), 'Call2_vod__c')));
        }

        result.addAll(attendeesAdditionalFields);
        return result;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getAttendeeSearchColumns() {
        List<GNE_SFA2_Base_Ctrl.Field> result;

        if (isSfaBrandUser) {
            result = new List<GNE_SFA2_Base_Ctrl.Field>{
                    new GNE_SFA2_Base_Ctrl.Field('lastName', 'LAST NAME'),
                    new GNE_SFA2_Base_Ctrl.Field('firstName', 'FIRST NAME')
            };
        } else if (getCurrentUser().isCanada()) {
            result = new List<GNE_SFA2_Base_Ctrl.Field>{
                    new GNE_SFA2_Base_Ctrl.Field('name', 'Name'),
                    new GNE_SFA2_Base_Ctrl.Field('accountType', 'Account Type'),
                    new GNE_SFA2_Base_Ctrl.Field('address', 'Address'),
                    new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
            };
        } else {
            result = new List<GNE_SFA2_Base_Ctrl.Field>{
                    new GNE_SFA2_Base_Ctrl.Field('name', 'Name'),
                    new GNE_SFA2_Base_Ctrl.Field('address', 'Address'),
                    new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
            };

            if (getIsFPMProfile()) {
                result.add(new GNE_SFA2_Base_Ctrl.Field('attendeeTypeFPM', 'Attendee Type'));
            }
        }

        return result;
    }

    private List<AttendeeOptionWrapper> getAttedeeOptions(List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns, Boolean onlyContactAttendees) {
        Call2_vod__c call = (Call2_vod__c) record;
        return getAttedeeOptions(call.Account_vod__c, columns, searchColumns, onlyContactAttendees);
    }

    private static Boolean useOnlyActiveContacts() {
        String userProfileName = staticGetCurrentUserProfileName();
        if(String.isBlank(userProfileName)) {
            userProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        }

        if (userProfileName.toUpperCase().startsWith('GNE-MCCO') || userProfileName.toUpperCase().startsWith('GNE-CRM')) {
            return true;
        }
        return false;
    }

    private static List<AttendeeOptionWrapper> getAttedeeOptions(Id accountId, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns, Boolean onlyContactAttendees) {
        List<AttendeeOptionWrapper> result = new List<AttendeeOptionWrapper>();
        Set<Id> resultIds = new Set<Id>();
        Integer resultSizeLimit = 1000;
        if (!onlyContactAttendees) {
            List<Affiliation_vod__c> affs = [
                    SELECT To_Account_vod__c, To_Account_vod__r.Id, To_Account_vod__r.FirstName, To_Account_vod__r.LastName, To_Account_vod__r.Territory_vod__c, To_Account_vod__r.Name, To_Account_vod__r.IsPersonAccount, To_Account_vod__r.Account_Type_gne__c,
                            To_Contact_vod__r.Id, To_Contact_vod__r.Active_gne__c, To_Contact_vod__r.FirstName, To_Contact_vod__r.LastName, To_Contact_vod__r.Name, To_Contact_vod__r.IsPersonAccount, To_Contact_vod__r.AccountId, To_Contact_vod__r.Type_gne__c
                    FROM Affiliation_vod__c
                    WHERE From_Account_vod__c = :accountId AND (To_Account_vod__r.IsPersonAccount = TRUE OR To_Contact_vod__c != NULL)
                    ORDER BY To_Account_vod__r.LastName NULLS LAST, To_Account_vod__r.FirstName, To_Contact_vod__r.LastName, To_Contact_vod__r.FirstName
            ];
            Set<Id> accountIds = new Set<Id>();
            for (Affiliation_vod__c aff : affs) {
                if(aff.To_Account_vod__c != null)accountIds.add(aff.To_Account_vod__c);
            }
            Map<Id, Account> accMap = new Map<Id, Account>([
                    SELECT Id, IsPersonAccount,FirstName, LastName, Territory_vod__c, Name, Account_Type_gne__c,
                    (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__r WHERE Active_Flag_gne__c = true AND Primary_vod__c=true)
                    FROM Account
                    WHERE Id IN: accountIds
            ]);

            for (Affiliation_vod__c aff : affs) {
                if (aff.To_Account_vod__r != null) {
                    Account tempAcc = accMap.get(aff.To_Account_vod__c);
                    if(!tempAcc.Address_vod__r.isEmpty()) {
                        result.add(new AttendeeOptionWrapper(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(tempAcc, tempAcc.Address_vod__r[0]), columns,searchcolumns));
                    } else {
                        AttendeeOptionWrapper aow = new AttendeeOptionWrapper(aff.To_Account_vod__r, columns, searchColumns);
                        aow.addressDescription = 'test';
                        result.add(aow);
                    }

                    resultIds.add(aff.To_Account_vod__r.Id);
                } else if (!GNE_SFA2_Util.isCanadaINFUUser() && aff.To_Contact_vod__r != null && (!useOnlyActiveContacts() || aff.To_Contact_vod__r.Active_gne__c)) {
                    AttendeeOptionWrapper aow = new AttendeeOptionWrapper(aff.To_Contact_vod__r, columns, searchColumns);
                    result.add(aow);
                    resultIds.add(aff.To_Contact_vod__r.Id);
                }

                if (resultIds.size() == resultSizeLimit) {
                    break;
                }
            }
        }

        if (resultIds.size() < resultSizeLimit) {
            Integer limitLeft = resultSizeLimit - resultIds.size();
            Set<Boolean> activeModes = new Set<Boolean>{
                    true
            };

            if (!useOnlyActiveContacts()) {
                activeModes.add(false);
            }

            List<Contact> contacts = [
                    SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c
                    FROM Contact
                    WHERE AccountId = :accountId AND IsPersonAccount = FALSE
                    AND Id NOT IN :resultIds
                    AND Active_gne__c IN :activeModes
                    ORDER BY LastName, FirstName
                    LIMIT :limitLeft
            ];

            for (Contact contact : contacts) {
                AttendeeOptionWrapper aow = new AttendeeOptionWrapper(contact, columns, searchColumns);
                result.add(aow);
            }
        }

        //GNE_SFA2_PREP_Interaction_Controller.onGetAffiliatedAccounts(result);
        return result;
    }

    private List<AttendeeWrapper> getSelectedAttendess(List<GNE_SFA2_Base_Ctrl.Field> columns) {
        List<AttendeeWrapper> result = new List<AttendeeWrapper>();
        Call2_vod__c call = (Call2_vod__c) record;

        if (call.Call2_vod__r != null) {
            for (Call2_vod__c attendeeCall : call.Call2_vod__r) {
                if (isSfaBrandUser && attendeeCall.Account_vod__r != null && attendeeCall.Account_vod__r.IsPersonAccount && (callAccount.IsPersonAccount || attendeeCall.Account_vod__c != call.Account_vod__c)) {
                    AttendeeWrapper aw = new AttendeeWrapper(attendeeCall, columns);
                    result.add(aw);
                } else {
                    AttendeeWrapper aw = new AttendeeWrapper(attendeeCall, columns);
                    result.add(aw);
                }
            }
        }

        return result;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getProductColumns(Boolean isObjective) {

        return isSfaBrandUser
                ? new List<GNE_SFA2_Base_Ctrl.Field>{
                        new GNE_SFA2_Base_Ctrl.Field('productName', 'PRODUCT')
                }
                : isObjective
                        ? objectivesAdditionalFields
                        : new List<GNE_SFA2_Base_Ctrl.Field>{
                                new GNE_SFA2_Base_Ctrl.Field('Product_vod__c', 'Product', null, null, null, null, true, false, null,
                                        new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_Detail_vod__c.Product_vod__c.getDescribe(), 'Call2_Detail_vod__c'))
                        };
    }

    private List<ProductOptionWrapper> getProductOptions(List<GNE_SFA2_Base_Ctrl.Field> columns, Boolean isObjective) {
        List<ProductOptionWrapper> result = new List<ProductOptionWrapper>();
        productIds = new Set<Id>();
        Id userId = currentUser.id;
        Integer idx = 0;

        String query = 'SELECT Product_vod__c, Product_vod__r.Id, Product_vod__r.Name, Product_vod__r.Product_Type_vod__c, Product_vod__r.Therapeutic_Area_Reference__c, Product_vod__r.Promotional__c, Product_vod__r.Non_Promotional__c FROM My_Setup_Products_vod__c ';
        String whereExpr = 'WHERE OwnerId = :userId AND Product_vod__c != null AND Product_vod__r.Name != null ';

        if (!GNE_SFA2_Util.isCanadaUser()) {
            whereExpr += 'AND Product_vod__r.Product_Type_vod__c = \'Detail\' ';

            query += whereExpr + ' ORDER BY Product_vod__r.Name LIMIT 55';

            for (My_Setup_Products_vod__c msRec : Database.query(query)) {
                ProductOptionWrapper pow = new ProductOptionWrapper(msRec.Product_vod__c, msRec.Product_vod__r, getCallDiscussionRecordTypeId(), columns, isObjective);
                result.add(pow);
                productIds.add(msRec.Product_vod__c);
            }
        } else {
            for (Product_vod__c product : [SELECT Id, Name, Product_Type_vod__c, Therapeutic_Area_Reference__c, Promotional__c, Non_Promotional__c FROM Product_vod__c WHERE (Promotional__c = true OR Non_Promotional__c = true) AND active__c = true ORDER BY Name]) {
                ProductOptionWrapper pow = new ProductOptionWrapper(product.Id, product, getCallDiscussionRecordTypeId(), columns, isObjective);
                result.add(pow);
                productIds.add(product.Id);
            }
        }

        return result;
    }

    private List<ProductWrapper> getProductWrappers(List<GNE_SFA2_Base_Ctrl.Field> columns, Boolean isObjective) {
        List<ProductWrapper> result = new List<ProductWrapper>();

        Call2_vod__c call = (Call2_vod__c) record;

        if (isObjective && call.Call2_Discussion_vod__r != null) {
            Integer idx = 0;
            for (Call2_Discussion_vod__c cd : call.Call2_Discussion_vod__r) {
                ProductWrapper pw = new ProductWrapper(cd.Id, cd, cd.RecordTypeId, columns);
                result.add(pw);
            }
        } else if (!isObjective && call.Call2_Detail_vod__r != null) {
            Integer idx = 0;
            for (Call2_Detail_vod__c cd : call.Call2_Detail_vod__r) {
                ProductWrapper pw = new ProductWrapper(cd.Id, cd, null, columns);
                result.add(pw);
            }
        }

        return result;
    }

    private ProductWrapper getObjectiveTemplate(List<GNE_SFA2_Base_Ctrl.Field> objectiveColumns) {
        Id recordTypeId = getCallDiscussionRecordTypeId();
        return new ProductWrapper('0', new Call2_Discussion_vod__c(RecordTypeId = recordTypeId), recordTypeId, objectiveColumns);
    }

    private List<QuestionItem> getPreCallQuestionsItems() {
        List<QuestionItem>result = new List<QuestionItem>();
        for (Pre_Call_Question_gne__c question : [SELECT Name, Question_gne__c, Category_gne__c FROM Pre_Call_Question_gne__c ORDER BY Category_gne__c, Name]) {
            result.add(new QuestionItem(question.Question_gne__c, question.Question_gne__c, question.Category_gne__c));
        }
        return result;
    }

    private List<DependentPicklistItem> getPreCallObjectiveItems(Set<Id>productIds) {
        List<Call_Objective_gne__c>callObjectives = [SELECT Name, Product_gne__c, Product_gne__r.Name FROM Call_Objective_gne__c WHERE Product_gne__c IN :productIds ORDER BY Name];
        Map<Id, DependentPicklistItem>productToPicklist = new Map<Id, DependentPicklistItem>();
        for (Call_Objective_gne__c objective : callObjectives) {
            if (!productToPicklist.containsKey(objective.Product_gne__c)) {
                productToPicklist.put(objective.Product_gne__c, new DependentPicklistItem(objective.Product_gne__c, objective.Product_gne__r.Name));
            }
            DependentPicklistItem picklist = productToPicklist.get(objective.Product_gne__c);
            picklist.addItem(new DependentPicklistItem(objective.Name, objective.Name));
        }
        return productToPicklist.values();
    }

    private List<DependentPicklistItem> getProductStrategyTacticItems(List<ProductOptionWrapper> productOptions) {
        List<DependentPicklistItem> result = new List<DependentPicklistItem>();
        Map<String, DependentPicklistItem> itemsMap = new Map<String, DependentPicklistItem>();

        for (ProductOptionWrapper opt : productOptions) {
            DependentPicklistItem item = new DependentPicklistItem(opt.rowId, opt.label);
            result.add(item);

            if (strategyVisible) {
                itemsMap.put(item.value, item);
            }
        }

        List<Product_Strategy_vod__c> strategies;

        if (strategyVisible && tacticVisible) {
            strategies = [
                    SELECT Id, Name, Groups_vod__c, Product_Plan_vod__r.Product_vod__c,
                        (
                            SELECT Id, Name, Product_Strategy_vod__c, Groups_vod__c
                            FROM Product_Tactic_vod__r
                            WHERE Profiles_Available_vod__c LIKE :'%' + staticCurrentUserProfileName + '%' AND Active_vod__c = TRUE ORDER BY Name
                        )
                    FROM Product_Strategy_vod__c
                    WHERE Profiles_Available_vod__c LIKE :'%' + staticCurrentUserProfileName + '%' AND
                    Active_vod__c = TRUE AND
                    Region_Code_gne__c = 2
                    ORDER BY Name
            ];
        } else if (strategyVisible) {
            strategies = [
                    SELECT Id, Name, Groups_vod__c, Product_Plan_vod__r.Product_vod__c
                    FROM Product_Strategy_vod__c
                    WHERE Product_Plan_vod__r.Product_vod__c IN :itemsMap.keySet()
                    AND Active_vod__c = TRUE
                    AND Product_Plan_vod__r.Active_vod__c = TRUE
                    ORDER BY Name
            ];
        }

        if (strategies != null) {
            for (Product_Strategy_vod__c strat : strategies) {
                DependentPicklistItem stratItem = new DependentPicklistItem(strat.Id, strat.Name, strat.Groups_vod__c);
                for(String prodId : itemsMap.keySet()) {
                    itemsMap.get(prodId).addItem(stratItem);
                }

                if (tacticVisible) {
                    for (Product_Tactic_vod__c tactic : strat.Product_Tactic_vod__r) {
                        DependentPicklistItem tacticItem = new DependentPicklistItem(tactic.Id, tactic.Name);
                        stratItem.addItem(tacticItem);

                    }
                }
            }
        }

        return result;
    }

    private List<DependentPicklistItem> getProductContents() {
        List<DependentPicklistItem> result = new List<DependentPicklistItem>();
        for (Product_vod__c product : [
                SELECT Id, Name, Profiles_Available_gne__c, Groups_gne__c
                FROM Product_vod__c
                WHERE Product_Type_vod__c = 'Content' AND
                Profiles_Available_gne__c LIKE :'%' + staticCurrentUserProfileName + '%'
        ]) {
            DependentPicklistItem item = new DependentPicklistItem(product.Id, product.Name, product.Groups_gne__c);
            result.add(item);
        }
        return result;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getKeyMessagesColumns() {
        List<GNE_SFA2_Base_Ctrl.Field> result = new List<GNE_SFA2_Base_Ctrl.Field>{
                new GNE_SFA2_Base_Ctrl.Field('productName', 'Product'),
                new GNE_SFA2_Base_Ctrl.Field('description', 'Message'),
                new GNE_SFA2_Base_Ctrl.Field('Reaction_vod__c', 'Reaction', null, null, null, null, false, true, null,
                        new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_Key_Message_vod__c.Reaction_vod__c.getDescribe(), 'Call2_Key_Message_vod__c'))
        };

        return result;
    }

    private List<KeyMessageOptionWrapper> getKeyMessageOptions(List<GNE_SFA2_Base_Ctrl.Field> columns) {
        List<KeyMessageOptionWrapper> result = new List<KeyMessageOptionWrapper>();
        List<Key_Message_vod__c> kms = [
                SELECT Id, Name, Product_vod__c, Product_vod__r.Id, Product_vod__r.Name, Description_vod__c
                FROM Key_Message_vod__c
                WHERE Product_vod__c IN :productIds AND Active_vod__c = TRUE
                ORDER BY Product_vod__r.Name, Name
        ];

        for (Key_Message_vod__c km : kms) {
            KeyMessageOptionWrapper kmow = new KeyMessageOptionWrapper(km, columns);
            result.add(kmow);
        }

        return result;
    }

    private List<KeyMessageWrapper> getKeyMessageWrappers(List<GNE_SFA2_Base_Ctrl.Field> columns) {
        List<KeyMessageWrapper> result = new List<KeyMessageWrapper>();

        Call2_vod__c call = (Call2_vod__c) record;

        if (call.Call2_Key_Message_vod__r != null) {
            Integer idx = 0;
            for (Call2_Key_Message_vod__c km : call.Call2_Key_Message_vod__r) {
                KeyMessageWrapper kmw = new KeyMessageWrapper(km, columns);
                result.add(kmw);
            }
        }

        return result;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getMaterialsColumns() {
        return materialsAdditionalFields;
    }

    private List<GNE_SFA2_Base_Ctrl.Field> getPreCallColumns() {
        return preCallFields;
    }

    private List<PreCallWrapper> getPreCallsWrappers(List<GNE_SFA2_Base_Ctrl.Field> columns) {
        List<PreCallWrapper> result = new List<PreCallWrapper>();
        for (Call_Pre_Call_gne__c preCall : getPreCalls()) {
            PreCallWrapper pw = new PreCallWrapper(preCall, columns);
            result.add(pw);
        }
        return result;
    }

    private List<Call_Pre_Call_gne__c>getPreCalls() {
        if (existingsPreCalls == null) {
            Id callId = record.Id;
            existingsPreCalls = [SELECT Id, Name, Call_gne__c, Customer_Segment_gne__c, Interaction_Objectives_gne__c, LastModifiedDate, Product_gne__c, Product_gne__r.Name, Decision_Cycle_gne__c, Implication_Questions_gne__c, Need_payoff_Questions_gne__c, Problem_Questions_gne__c FROM Call_Pre_Call_gne__c WHERE Call_gne__c = :callId];
        }
        return existingsPreCalls;
    }

    private Datetime getPreCallsLastModifiedDate() {
        Datetime newestDate = null;
        for (Call_Pre_Call_gne__c preCall : getPreCalls()) {
            if (newestDate == null || preCall.LastModifiedDate > newestDate) {
                newestDate = preCall.LastModifiedDate;
            }
        }
        return newestDate;
    }

    private PreCallWrapper getPreCallTemplate(List<GNE_SFA2_Base_Ctrl.Field> columns) {
        return new PreCallWrapper(new Call_Pre_Call_gne__c(), columns);
    }

    private MaterialWrapper getMaterialTemplate(List<GNE_SFA2_Base_Ctrl.Field> columns) {
        return new MaterialWrapper('0', new Call2_Sample_vod__c(Quantity_vod__c = 1), columns);
    }

    private List<MaterialWrapper> getMaterialWrappers(List<GNE_SFA2_Base_Ctrl.Field> columns) {
        List<MaterialWrapper> result = new List<MaterialWrapper>();

        List<Call2_Sample_vod__c> materialRecs = getMeterials();

        if (materialRecs != null) {
            Integer rowIdx = 0;

            for (Call2_Sample_vod__c cs : materialRecs) {
                MaterialWrapper mw = new MaterialWrapper('call-material-' + String.valueOf(rowIdx++), cs, columns);
                result.add(mw);
            }
        }

        return result;
    }

    private List<Call2_Sample_vod__c> getMeterials() {
        List<Call2_Sample_vod__c> result = null;
        Id callId = record.Id;

        if (String.isNotBlank(callId)) {
            Map<String, Schema.DescribeFieldResult> fieldsDescribe = getCallSampleFieldsDescribe();
            Set<String> materialFields = new Set<String>{
                    'Call2_vod__c'
            };

            for (GNE_SFA2_Base_Ctrl.Field field : materialsAdditionalFields) {
                String fieldName = field.name.toLowerCase();
                materialFields.add(fieldName);

                if (fieldsDescribe.containsKey(fieldName) && String.isNotBlank(fieldsDescribe.get(fieldName).getRelationshipName())) {
                    materialFields.add(fieldsDescribe.get(fieldName).getRelationshipName() + '.name');
                }
            }

            result = GNE_SFA2_Util.getDbWithoutSharingExecutor().executeQuery(
                    String.format('SELECT {0} FROM Call2_Sample_vod__c WHERE Call2_vod__c = {1} OR Call2_vod__r.Parent_Call_vod__c = {1}',
                            new String[]{
                                    String.join(new List<String>(materialFields), ','), '\'' + callId + '\''
                            })
            );
        }

        return result;
    }

    public List<MaterialProductItem> getMaterialProducts(Set<Id> usedProductIds) {
        List<MaterialProductItem> result = new List<MaterialProductItem>();
        Set<String> invalidProductTypes = new Set<String>{
                'Detail', 'Market', 'Sample', 'PFG'
        };
        Map<Id, Product_vod__c> mProducts;
        if(contentSectionCanadaProfilesSet.contains(GNE_SFA2_Util.getCurrentUserProfileName())) {
            mProducts = new Map<Id, Product_vod__c>([
                    SELECT Id, Name, Product_Type_vod__c, Parent_Product_vod__c, active__c, Promotional__c, Non_Promotional__c
                    FROM Product_vod__c
                    WHERE active__c = TRUE AND
                    Product_Type_vod__c IN ('Content') AND
                    Parent_Product_vod__r.Product_Type_vod__c IN ('Therapeutic Area', 'Detail')
                    ORDER BY Product_Type_vod__c
            ]);
        } else {
            mProducts = new Map<Id, Product_vod__c>([
                    SELECT Id, Name, Product_Type_vod__c, Parent_Product_vod__c, active__c
                    FROM Product_vod__c
                    WHERE Parent_Product_vod__c IN :productIds
                    AND active__c = TRUE
                    AND Product_Type_vod__c NOT IN :invalidProductTypes
                    ORDER BY Product_Type_vod__c, Name
            ]);
        }

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
        for (Product_vod__c mProduct : mProducts.values()) {
            String sampleKey = ((dependentMaterialsEnabled && String.isNotBlank(mProduct.Parent_Product_vod__c) ? String.valueOf(mProduct.Parent_Product_vod__c) : '') + mProduct.Product_Type_vod__c + '_' + mProduct.Name).toUpperCase();
            if (!visitedSamples.contains(sampleKey)) {
                MaterialProductItem mpi = new MaterialProductItem(mProduct, dependentMaterialsEnabled);
                result.add(mpi);
                visitedSamples.add(sampleKey);
            }
        }

        result.sort();
        return result;
    }

    private List<AttachmentWrapper> getAttachments(Id callId) {
        List<AttachmentWrapper> result = new List<AttachmentWrapper>();
        for (Attachment a : [SELECT Id, Name, Description FROM Attachment WHERE ParentId = :callId]) {
            result.add(new AttachmentWrapper(a.Id, a.Name, false, false, callId, null));
        }

        return result;
    }

    private DataWrapper searchAttendees(Map<String, Object> params) {
        DataWrapper = getDataWrapperInstance();

        try {
            DataWrapper = intSearchAttendees(params);
        } catch (Exception ex) {
            handleException(ex);
        }

        dataWrapper.onActionFinish('Search Attendees');
        return (DataWrapper) DataWrapper;
    }

    private DataWrapper intSearchAttendees(Map<String, Object> params) {
        List<AttendeeOptionWrapper> attendees = new List<AttendeeOptionWrapper>();
        String searchPhrase = (String) params.get('searchPhrase');
        Integer recordsLimit = ((Decimal) params.get('recordsLimit')).intValue();
        Boolean onlyPersonAccounts = (Boolean) params.get('onlyPersonAccounts');
        Id accountId = (String) params.get('accountId');
        Id userId = (String) params.get('userId');
        String mode = (String) params.get('mode');
        dataWrapper.appContext = (GNE_SFA2_Base_Ctrl.AppContext) JSON.deserialize((String) params.get('appContext'), GNE_SFA2_Base_Ctrl.appContext.class);
        List<GNE_SFA2_Base_Ctrl.Field> columns = (List<GNE_SFA2_Base_Ctrl.Field>) JSON.deserialize((String) params.get('attendeeColumns'), List<GNE_SFA2_Base_Ctrl.Field>.class);
        List<GNE_SFA2_Base_Ctrl.Field> searchcolumns = (List<GNE_SFA2_Base_Ctrl.Field>) JSON.deserialize((String) params.get('searchColumns'), List<GNE_SFA2_Base_Ctrl.Field>.class);
        staticCurrentUserProfileName = getCurrentUser().getProfileName();

        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> saws =
                GNE_SFA2_SearchAccounts_Controller.searchAccountsContactsEmployees(searchPhrase,
                        recordsLimit, true, onlyPersonAccounts, false, false, new List<Id>{accountId});

        if (getCurrentUser().isCanada() && !GNE_SFA2_Util.isCanadaINFUUser()) {
            // iHCP is enabled for Canadian users only
            saws.addAll(searchInternationalSpeakers(searchPhrase, recordsLimit));
        }

        for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper saw : saws) {
            attendees.add(new AttendeeOptionWrapper(saw, columns, searchcolumns));
        }

        if (getCurrentUser().isCanada()) {
            attendees.sort();
        }

        //GNE_SFA2_PREP_Interaction_Controller.onSearchAttendeesWithPhrase(attendees, searchColumns);
        ((DataWrapper) DataWrapper).attendeeData = new AttendeeData(attendees, columns, searchcolumns, null);
        return (DataWrapper) DataWrapper;
    }

    private DataWrapper getAttendeesMinList(Map<String, Object> params) {
        DataWrapper = getDataWrapperInstance();

        try {
            DataWrapper = intGetAttendeesMinList(params);
        } catch (Exception ex) {
            handleException(ex);
        }

        dataWrapper.onActionFinish('Get Attendees');
        return (DataWrapper) DataWrapper;
    }

    private DataWrapper intGetAttendeesMinList(Map<String, Object> params) {
        DataWrapper resultData = (DataWrapper) DataWrapper;
        List<AttendeeOptionWrapper> attendees = new List<AttendeeOptionWrapper>();
        String orderMode = (String) params.get('order');
        Id currentAccountId = (Id) params.get('accountId');
        Id currentUserId = (Id) params.get('userId');
        Set<String> currentTerrNames = getCurrentTerrNames(currentUserId);
        AddressWrapper addrWrapper = params.get('address') != null ? (AddressWrapper) JSON.deserialize((String) params.get('address'), AddressWrapper.class) : null;

        List<Account> resultList = null;
        Integer accLimit = 2000;
        String resultKey = orderMode;

        Double latitude, longitude;

        if (orderMode == 'GEO' && addrWrapper != null) {
            resultList = new List<Account>();
            resultKey += '_' + addrWrapper.value;

            ensureAddressLocation(addrWrapper);
            latitude = addrWrapper.latitude;
            longitude = addrWrapper.longitude;
        }

        Map<String, List<HcpWrapper>> hcpsMap = new Map<String, List<HcpWrapper>>{
                resultKey => new List<HcpWrapper>()
        };
        List<HcpWrapper> hcps = hcpsMap.get(resultKey);

        if (orderMode == 'GEO' && latitude != null && longitude != null) {
            List<Address_vod__c> addrs = Database.query(String.format('SELECT {0} FROM Address_vod__c WHERE {1} ORDER BY {2} LIMIT {3}', new String[]{
                    'Id, Account_vod__c, Account_vod__r.Id, Account_vod__r.FirstName, Account_vod__r.LastName, Location_gne__Latitude__s, Location_gne__Longitude__s',
                    'Account_vod__c IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :currentTerrNames AND Address_vod__c <> null AND Account_vod__r.IsPersonAccount = true AND Account_vod__c <> :currentAccountId)',
                    'DISTANCE(Location_gne__c,GEOLOCATION(' + latitude + ',' + longitude + '), \'mi\') ASC NULLS LAST, Account_vod__r.LastName, Account_vod__r.FirstName',
                    String.valueOf(accLimit * 4)
            }));
            Set<Id> visitedAccIds = new Set<Id>();

            for (Address_vod__c addr : addrs) {
                if (!visitedAccIds.contains(addr.Account_vod__c)) {
                    visitedAccIds.add(addr.Account_vod__c);
                    resultList.add(addr.Account_vod__r);

                    if (resultList.size() == accLimit) {
                        break;
                    }
                }
            }
        } else if (orderMode == 'COOP') {
            calculateAffiliatedHcpWrappers(currentAccountId, hcps, currentUserId, currentTerrNames);
        } else {
            resultList = [
                    SELECT Id, FirstName, LastName
                    FROM Account
                    WHERE Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :currentTerrNames AND Address_vod__c <> NULL)
                    AND IsPersonAccount = TRUE
                    AND Id <> :currentAccountId
                    ORDER BY LastName, FirstName
                    LIMIT :accLimit
            ];
        }

        if (hcps.isEmpty()) {
            for (Account hcp : resultList) {
                hcps.add(new HcpWrapper(hcp));
            }
        }

        resultData.attendeeData = new AttendeeData(hcpsMap);
        return resultData;
    }

    protected virtual List<HcpWrapper> calculateAffiliatedHcpWrappers(Id currentAccountId, List<HcpWrapper> hcps, Id currentUserId, Set<String> currentTerrNames) {
        List<Call2_vod__c> calls = [
                SELECT Id, Parent_Call_vod__c
                FROM Call2_vod__c
                WHERE Account_vod__c = :currentAccountId
                AND (Parent_Call_vod__c = NULL OR Parent_Call_vod__r.Account_vod__r.IsPersonAccount = TRUE)
                AND Call_Datetime_vod__c >= LAST_90_DAYS
                AND Call_Datetime_vod__c <= NEXT_90_DAYS
        ];
        Set<Id> parentCallIds = new Set<Id>();

        for (Call2_vod__c call : calls) {
            parentCallIds.add(String.isNotBlank(call.Parent_Call_vod__c) ? call.Parent_Call_vod__c : call.Id);
        }

        List<Call2_vod__c> affCalls = [
                SELECT Id, Parent_Call_vod__c, Account_vod__c, Account_vod__r.Id, Account_vod__r.FirstName, Account_vod__r.LastName
                FROM Call2_vod__c
                WHERE (Id IN :parentCallIds OR Parent_Call_vod__c IN :parentCallIds)
                AND Account_vod__c IN (
                        SELECT Account_vod__c
                        FROM TSF_vod__c
                        WHERE Account_vod__r.IsPersonAccount = TRUE
                        AND Account_vod__c <> :currentAccountId
                        AND Territory_vod__c IN :currentTerrNames
                        AND Address_vod__c <> NULL
                )
                ORDER BY CreatedDate DESC
        ];

        Map<Id, HcpWrapper> hcpWrappersMap = new Map<Id, HcpWrapper>();

        for (Call2_vod__c aCall : affCalls) {
            HcpWrapper hcpWrapper = hcpWrappersMap.get(aCall.Account_vod__c);

            if (hcpWrapper == null) {
                hcpWrapper = new HcpWrapper(aCall.Account_vod__r);
                hcps.add(hcpWrapper);
                hcpWrappersMap.put(aCall.Account_vod__c, hcpWrapper);
            }

            hcpWrapper.increaseRank(1);
        }

        hcps.sort();
        return hcps;
    }

    public String getCurrentTerrName(Id userId) {
        this.currentUser = this.currentUser != null ? this.currentUser : new UserWrapper(new User(Id = userId));
        Territory2 selectedTerr = getCurrentTerritory();
        return selectedTerr != null ? selectedTerr.Name : null;
    }

    private Set<String> getCurrentTerrNames(Id userId) {
        this.currentUser = this.currentUser != null ? this.currentUser : new UserWrapper(new User(Id = userId));
        Territory2 selectedTerr = getCurrentTerritory();
        List<Territory2> allTerritories = userTerritoriesCache;

        Set<String> result = new Set<String>();

        for (Territory2 terr : allTerritories) {
            if (String.isNotBlank(terr.External_Id_gne__c) && String.isNotBlank(selectedTerr.External_Id_gne__c) && terr.External_Id_gne__c.startsWithIgnoreCase(selectedTerr.External_Id_gne__c)) {
                result.add(terr.Name);
            }
        }

        return result;
    }

    private void ensureAddressLocation(AddressWrapper addrWrapper) {
        DataWrapper resultData = (DataWrapper) DataWrapper;
        Double latitude = addrWrapper.latitude;
        Double longitude = addrWrapper.longitude;

        if (latitude == null || longitude == null) {
            Address_vod__c addr = addrWrapper.getAddressRecord();
            addr.Force_Location_Update_gne__c = true;
            GNE_SFA2_AddressLocation_Util.setAddressLocation(addr);

            latitude = addrWrapper.latitude = addr.Location_gne__Latitude__s;
            longitude = addrWrapper.longitude = addr.Location_gne__Longitude__s;

            if (latitude != null && longitude != null) {
                GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
                Database.update(addr);
                GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);

                resultData.addresses = new List<AddressWrapper>{
                        addrWrapper
                };
            }
        }
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper intSaveRecord() {
        accountIdToCallMap = new Map<Id, Call2_vod__c>();
        contactIdToCallMap = new Map<Id, Call2_vod__c>();
        mainCallsToUpsert = new List<Call2_vod__c>();
        GNE_SFA2_Interaction_Trigger_Helper.setIsSfdcUiRequest(true);
        DataWrapper = super.intSaveRecord();
        DataWrapper resultData = (DataWrapper) DataWrapper;
        DataWrapper saveData = (DataWrapper) inputDataWrapper;

        if (resultData.success) {
            if (saveData.attendeeData != null || saveData.multipleAccountsData != null) {
                saveAttendees();
                resultData.attendeeData = saveData.attendeeData;
            }

            if (saveData.productData != null) {
                saveProducts();
                resultData.productData = saveData.productData;
            }

            if (saveData.keyMessageData != null) {
                saveKeyMessages();
                resultData.keyMessageData = saveData.keyMessageData;
            }

            if (saveData.materialData != null) {
                if(contentSectionCanadaProfilesSet.contains(GNE_SFA2_Util.getCurrentUserProfileName())) {
                    saveMaterialsForCanada();
                } else {
                    saveMaterials();
                }
                resultData.materialData = saveData.materialData;
            }

            if (saveData.attachmentData != null) {
                saveAttachments();
            }

            if (saveData.pfgData != null) {
                getPfgController().savePfgs();
                resultData.pfgData = saveData.pfgData;
            }

            if (saveData.referral != null) {
                saveReferral();
                resultData.referral = saveData.referral;
            }

            if (saveData.preCallData != null && saveData.isPreCallEnabled) {
                savePreCalls();
                resultData.preCallData = saveData.preCallData;
            }
            if (saveData.isPreCallEnabled == false) { /* Temporary fix by BOS */
                if (!getPreCalls().isEmpty()) {
                    delete getPreCalls();
                }
            }

            if (saveData.interactionDetailData != null) {
                saveVisitReasonDetails();
                resultData.interactionDetailData = saveData.interactionDetailData;
            }

            deleteChildRecords();
            upsertChildRecords();

            if (saveData.attachmentData != null) {
                for (Attachment a : attachmentsToUpsert) {
                    for (AttachmentWrapper aw : saveData.attachmentData) {
                        if (a.Name == aw.name) {
                            aw.id = a.Id;
                        }
                    }
                }
                resultData.attachmentData = saveData.attachmentData;
            }

            resultData.simpleEditMode = saveData.simpleEditMode == true || saveData.completeMode == true;
            resultData.isCompleted = saveData.isCompleted == true || saveData.completeMode == true;

            if (saveData.newCallMode == true) {
                Call2_vod__c call = (Call2_vod__c) record;
                PageReference pr = Page.GNE_SFA2_Interaction;
                pr.getParameters().put('accountId', call.Account_vod__c);
                pr.getParameters().put('preCallEnabled', 'true');
                resultData.retUrl = pr.getUrl();
            } else if (GNE_SFA2_Util.isCanadaINFUUser()) {
                PageReference pageRef = new PageReference(Page.GNE_SFA2_MyInteractions.getUrl());

                if (dataWrapper.urlParameters != null && dataWrapper.urlParameters.get('retURL') != null) {
                    pageRef = new PageReference(Page.EMS_Concur_Interaction_Connector.getUrl());
                    pageRef.getParameters().put('expenseType', dataWrapper.urlParameters.get('expenseType'));
                    pageRef.getParameters().put('expKey', dataWrapper.urlParameters.get('expKey'));
                    pageRef.getParameters().put('transactionAmount', dataWrapper.urlParameters.get('transactionAmount'));
                    pageRef.getParameters().put('itemUrl', dataWrapper.urlParameters.get('itemUrl'));
                }

                resultData.retUrl = pageRef.getUrl();

            } else if (saveData.multipleAccountsMode == true) {
                resultData.retUrl = Page.GNE_MCCO_CRM_MyAccounts.getUrl();
            } else if (saveData.appContext.appName != 'MCCO') {
                Call2_vod__c call = (Call2_vod__c) record;
                resultData.retUrl = '/' + call.Account_vod__c;
            }
        }

        GNE_SFA2_Interaction_Trigger_Helper.setIsSfdcUiRequest(false);
        return DataWrapper;
    }

    protected override void upsertRecord() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        Call2_vod__c call = (Call2_vod__c) record;

        if (saveData.multipleAccountsMode == true) {
            for (MultipleAccountWrapper callAccount : saveData.multipleAccountsData) {
                call.Account_vod__c = callAccount.id;
                setCallAddress(call, callAccount.address);
                accountIdToCallMap.put(call.Account_vod__c, call);
                mainCallsToUpsert.add(call);
                call = call.clone();
            }

            executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, mainCallsToUpsert);
        } else {
            call.Account_vod__c = saveData.callAccount.id;

            if (saveData.referral != null) {
                call.Referral_Assignment_gne__c = saveData.referral.id;
            }

            accountIdToCallMap.put(call.Account_vod__c, call);
            mainCallsToUpsert.add(call);
            executeDml(DmlOperations.UPS, call, false);
        }
    }

    protected virtual void upsertChildRecords() {
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, getChangedRecords(detailsToUpsert), false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, getChangedRecords(discussionsToUpsert), false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, getChangedRecords(keyMessagesToUpsert), false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, getChangedRecords(materialsToUpsert), false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, visitReasonDetailsToUpsert, false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, getChangedRecords(preCallsToUpsert), false);

        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, attachmentsToUpsert, false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, pfgDetailsToUpsert, false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPD, referralsToUpdate, false);
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPD, medcomsToUpdate, false);
    }

    protected virtual List<SObject> getChangedRecords(List<SObject> recs) {
        List<SObject> result = null;
        if (recs != null) {
            result = recs.clone();
            result.clear();

            for (SObject rec : recs) {
                String recKey = getRecordKey(rec);
                SObject existingRec = getRecordFromCache(rec);
                TableRowWrapper trw = recToWrapperMap != null ? recToWrapperMap.get(recKey) : null;

                if (trw == null || existingRec == null || !getChangedFields(rec, existingRec, trw).isEmpty()) {
                    result.add(rec);
                }
            }
        }

        return result;
    }

    protected virtual Set<String> getChangedFields(SObject newRec, SObject oldRec, TableRowWrapper trw) {
        Set<String> result = new Set<String>();
        Set<String> fieldNames = newRec instanceof Call2_Detail_vod__c
                ? new Set<String>{
                        String.valueOf(Call2_Detail_vod__c.iPhone_Request_Id_gne__c), String.valueOf(Call2_Detail_vod__c.Detail_Priority_vod__c).toLowerCase()
                }
                : trw.getFieldNames();

        if (newRec instanceof Call2_vod__c) {
            fieldNames.addAll(getInputFieldNames());
            fieldNames.removeAll(getAttendeeExcludedFieldNames());
            fieldNames.add(String.valueOf(Call2_vod__c.RecordTypeId));
            fieldNames.add(String.valueOf(Call2_vod__c.Detailed_Products_vod__c));
            fieldNames.add(String.valueOf(Call2_vod__c.HCP_OR_Attendee_Meal_Opt_Out_gne__c));
            fieldNames.add(String.valueOf(Call2_vod__c.Completed_gne__c));
            fieldNames.add(String.valueOf(Call2_vod__c.Date_Completed_gne__c));
        } else if (newRec instanceof Call2_Discussion_vod__c) {
            fieldNames.add(String.valueOf(Call2_Discussion_vod__c.Product_vod__c));
        }

        for (String fieldName : fieldNames) {
            Object newValue = newRec.get(fieldName);
            Object oldValue = oldRec.get(fieldName);

            if (newValue != null && (newValue instanceof Integer || newValue instanceof Decimal)) {
                newValue = Double.valueOf(newValue);
            }

            if (oldValue != null && (oldValue instanceof Integer || oldValue instanceof Decimal)) {
                oldValue = Double.valueOf(oldValue);
            }

            if (newValue instanceof Double && oldValue instanceof Double) {
                if (newValue != oldValue) {
                    result.add(fieldName + '(' + newValue + '!=' + oldValue + ')');
                }
            } else {
                String newValueString = newValue != null ? String.valueOf(newValue).trim() : '';
                String oldValueString = oldValue != null ? String.valueOf(oldValue).trim() : '';

                if (!newValueString.equals(oldValueString)) {
                    result.add(fieldName + '(' + newValueString + '!=' + oldValueString + ')');
                }
            }
        }

        return result;
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
                if (!(rec instanceof Call2_vod__c) && deletedAttendeeIds.contains((Id) rec.get((rec instanceof Call_PFG_Detail_gne__c || rec instanceof Call_Pre_Call_gne__c) ? 'Call_gne__c' : 'Call2_vod__c'))) {
                    childRecordsToRemoveMap.remove(rec.Id);
                }
            }

            DataWrapper saveData = (DataWrapper) inputDataWrapper;
            GNE_SFA2_Interaction_Trigger_Helper.setIsAllowDeleteAttendeeMode(!getCurrentUser().isFrm());
            executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.DEL, sortRecordsByType(childRecordsToRemoveMap), false);
        }

        if (attachmentsToDelete != null && !attachmentsToDelete.isEmpty()) {
            executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.DEL, attachmentsToDelete, false);
        }
    }

    private List<SObject> sortRecordsByType(Map<Id, SObject> recsMap) {
        List<SObject> sortedRecs = new List<SObject>();
        List<Id> sortedKeys = new List<Id>(recsMap.keySet());
        sortedKeys.sort();

        for (Id recKey : sortedKeys) {
            sortedRecs.add(recsMap.get(recKey));
        }

        return sortedRecs;
    }

    protected override void updateRecordFields() {
        super.updateRecordFields();
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        Call2_vod__c call = (Call2_vod__c) record;

        if (saveData.completeMode == true) {
            call.Completed_gne__c = true;
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
                    GNE_SFA2_Base_Ctrl.Field fld = wrapper.getField('HCP_Attendee_Meal_Opt_Out_gne__c');
                    Boolean isAttendeeMealOptOut = fld != null && fld.getValue() == true;
                    if (isAttendeeMealOptOut) {
                        call.HCP_OR_Attendee_Meal_Opt_Out_gne__c = true;
                        break;
                    }
                }
            }
        }

        if (saveData.productData != null) {
            List<String> productNames = new List<String>();
            Set<String> visitedProdNames = new Set<String>();
            for (ProductWrapper pWrapper : saveData.productData.rows) {
                String productName = pWrapper.getProductName();

                if (String.isNotBlank(productName)) {
                    productNames.add(productName);
                    visitedProdNames.add(productName);
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
        if (saveData.addresses != null && saveData.addresses.size() == 1) {
            setCallAddress(call, saveData.addresses[0]);
        }
    }

    private Boolean deleteAttachments(String attachIds) {
        List<String> ids = attachIds.split(',');
        if (!ids.isEmpty()) {
            List<Attachment> attachments = [SELECT Id FROM Attachment WHERE Id IN :ids];
            if (!attachments.isEmpty()) {
                executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.DEL, attachments);
            }
        }

        return true;
    }

    private void setCallAddress(Call2_vod__c call, AddressWrapper addrWrapper) {
        setCallAddress(call, addrWrapper != null ? addrWrapper.getAddressRecord() : null);
    }

    private void setCallAddress(Call2_vod__c call, Address_vod__c callAddress) {
        if (callAddress != null) {
            DataWrapper saveData = (DataWrapper) inputDataWrapper;
            call.Parent_Address_vod__c = callAddress.Id;
            call.Parent_Address_vod__r = callAddress;
            call.Address_vod__c = GNE_SFA2_Util.getAddressAsString(callAddress);
            call.Address_Line_1_vod__c = callAddress.Name;
            call.Address_Line_2_vod__c = callAddress.Address_line_2_vod__c;
            call.Zip_4_vod__c = callAddress.Zip_4_vod__c;
            call.Zip_vod__c = callAddress.Zip_vod__c;
            call.City_vod__c = callAddress.City_vod__c;
            call.State_vod__c = callAddress.State_vod__c;

            if (saveData.isCompleted != true) {
                call.PFG_BDTD_gne__c = callAddress.PFG_BDTD_gne__c;
            }
        }
    }

    protected override virtual Boolean validateRecord() {
        Boolean result = super.validateRecord();
        DataWrapper saveData = (DataWrapper) inputDataWrapper;

        Call2_vod__c call = (Call2_vod__c) record;

        if (result && call.HCP_OR_Attendee_Meal_Opt_Out_gne__c == true) {
            result = validateMealOptOut();
        }

        if (saveData.pfgData != null) {
            result &= getPfgController().validate();
        }

        return result;
    }

    private Boolean validateMealOptOut() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        Call2_vod__c call = (Call2_vod__c) record;
        Boolean isValid = true;
        Integer attendeesMealOptOutSize = 0;
        Integer allAttendees = 0;

        if (saveData.attendeeData != null) {
            for (AttendeeWrapper wrapper : saveData.attendeeData.rows) {
                GNE_SFA2_Base_Ctrl.Field fld = wrapper.getField('HCP_Attendee_Meal_Opt_Out_gne__c');
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
            if (saveData.callAccount.isPersonAccount == true) {
                if (call.HCP_Account_Meal_Opt_Out_gne__c == true) {
                    attendeesMealOptOutSize++;
                }

                allAttendees++;
            }
            //When Meal Out Opt is selected: Actual Meal Recipients number entered must be greater than, or equal to, the number of people who were not opted out of a meal expense + the CS
            if (call.Actual_Attendees_gne__c == null || call.Actual_Attendees_gne__c < ((allAttendees - attendeesMealOptOutSize) + 1)) {
                dataWrapper.addError(createException(new MealOptOutActualMealRecipientException()));
                isValid = false;
            }
        }

        return isValid;
    }

    protected override Set<String> getQueryFieldsAfterSave() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        Set<String> fieldNames = super.getQueryFieldsAfterSave();
        fieldNames.add(String.valueOf(Call2_vod__c.RecordTypeId).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.Detailed_Products_vod__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.HCP_OR_Attendee_Meal_Opt_Out_gne__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.Completed_gne__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.Date_Completed_gne__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.Account_vod__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.Contact_vod__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.User_vod__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.EMS_International_Speaker_gne__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.Parent_Call_vod__c).toLowerCase());
        fieldNames.add(String.valueOf(Call2_vod__c.iPhone_Request_Id_gne__c).toLowerCase());
        fieldNames.addAll(getInputFieldNames());

        if (saveData.attendeeData != null) {
            fieldNames.addAll(getFieldNamesFromRows(saveData.attendeeData.rows));
        }

        if (saveData.productData != null) {
            Set<String> childFieldNames = new Set<String>{
                    String.valueOf(Call2_Discussion_vod__c.Id).toLowerCase(), String.valueOf(Call2_Discussion_vod__c.iPhone_Request_Id_gne__c).toLowerCase(),
                    String.valueOf(Call2_Discussion_vod__c.Call2_vod__c).toLowerCase(), String.valueOf(Call2_Discussion_vod__c.Detail_Priority_gne__c).toLowerCase(),
                    String.valueOf(Call2_Discussion_vod__c.Product_vod__c).toLowerCase()
            };
            childFieldNames.addAll(getFieldNamesFromRows(saveData.productData.rows));
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Discussion_vod__r)', new String[]{
                    String.join(new List<String>(childFieldNames), ',')
            }));
            childFieldNames = new Set<String>{
                    String.valueOf(Call2_Detail_vod__c.Id).toLowerCase(), String.valueOf(Call2_Detail_vod__c.iPhone_Request_Id_gne__c).toLowerCase(),
                    String.valueOf(Call2_Detail_vod__c.Call2_vod__c).toLowerCase(), String.valueOf(Call2_Detail_vod__c.Product_vod__c).toLowerCase(), String.valueOf(Call2_Detail_vod__c.Detail_Priority_vod__c).toLowerCase()
            };
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Detail_vod__r)', new String[]{
                    String.join(new List<String>(childFieldNames), ',')
            }));
        }

        if (saveData.keyMessageData != null) {
            Set<String> childFieldNames = new Set<String>{
                    String.valueOf(Call2_Key_Message_vod__c.Id).toLowerCase(), String.valueOf(Call2_Key_Message_vod__c.iPhone_Request_Id__c).toLowerCase(),
                    String.valueOf(Call2_Key_Message_vod__c.Call2_vod__c).toLowerCase(), String.valueOf(Call2_Key_Message_vod__c.Product_vod__c).toLowerCase(), String.valueOf(Call2_Key_Message_vod__c.Key_Message_vod__c).toLowerCase()
            };
            childFieldNames.addAll(getFieldNamesFromRows(saveData.keyMessageData.rows));
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Key_Message_vod__r)', new String[]{
                    String.join(new List<String>(childFieldNames), ',')
            }));
        }

        if (saveData.materialData != null) {
            Set<String> childFieldNames = new Set<String>{
                    String.valueOf(Call2_Sample_vod__c.Id).toLowerCase(), String.valueOf(Call2_Sample_vod__c.iPhone_Request_Id_gne__c).toLowerCase(),
                    String.valueOf(Call2_Sample_vod__c.Call2_vod__c).toLowerCase(), String.valueOf(Call2_Sample_vod__c.Product_vod__c).toLowerCase(), String.valueOf(Call2_Sample_vod__c.Account_vod__c).toLowerCase()
            };
            childFieldNames.addAll(getFieldNamesFromRows(saveData.materialData.rows));
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Sample_vod__r)', new String[]{
                    String.join(new List<String>(childFieldNames), ',')
            }));
        }

        if (saveData.preCallData != null) {
            Set<String> childFieldNames = new Set<String>{
                    String.valueOf(Call_Pre_Call_gne__c.Id).toLowerCase(), String.valueOf(Call_Pre_Call_gne__c.iPhone_Request_Id__c).toLowerCase(),
                    String.valueOf(Call_Pre_Call_gne__c.Call_gne__c).toLowerCase(), String.valueOf(Call_Pre_Call_gne__c.Product_gne__c).toLowerCase()
            };
            childFieldNames.addAll(getFieldNamesFromRows(saveData.preCallData.rows));
            fieldNames.add(String.format('(SELECT {0} FROM Call_Pre_Calls__r)', new String[]{
                    String.join(new List<String>(childFieldNames), ',')
            }));
        }

        if (saveData.interactionDetailData != null) {
            Set<String> childFieldNames = new Set<String>{
                    String.valueOf(Call2_Interaction_Detail_vod__c.Id).toLowerCase(), String.valueOf(Call2_Interaction_Detail_vod__c.iPhone_Request_Id_gne__c).toLowerCase(),
                    String.valueOf(Call2_Interaction_Detail_vod__c.Call2_vod__c).toLowerCase(), String.valueOf(Call2_Interaction_Detail_vod__c.Visit_Reason_vod__c).toLowerCase()
            };
            childFieldNames.addAll(getFieldNamesFromRows(saveData.interactionDetailData.rows));
            fieldNames.add(String.format('(SELECT {0} FROM Call2_Interaction_Detail_vod__r)', new String[]{
                    String.join(new List<String>(childFieldNames), ',')
            }));
        }

        if (saveData.pfgData != null) {
            fieldNames.add(getPfgController().getPfgSubQuery());
        }

        return fieldNames;
    }

    public virtual Set<String> getInputFieldNames() {
        if (inputFieldNames == null) {
            inputFieldNames = new Set<String>();

            if (inputDataWrapper.inputFields != null) {
                for (GNE_SFA2_Base_Ctrl.Field fld : inputDataWrapper.inputFields) {
                    if (fld.describe != null && String.isNotBlank(fld.describe.name)) {
                        inputFieldNames.add(fld.describe.name.toLowerCase());
                    }
                }
            }
        }

        return inputFieldNames;
    }

    public Set<String> getFieldNamesFromRows(List<TableRowWrapper> rows) {
        Set<String> result = new Set<String>();

        if (rows != null) {
            for (TableRowWrapper row : rows) {
                result.addAll(row.getFieldNames());
            }
        }

        return result;
    }

    protected override SObject getRecordAfterSave(Set<String> fieldNames) {
        SObject result = null;
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        List<Call2_vod__c> callAndAttendess = Database.query(String.format('SELECT {0} FROM {1} WHERE Id = :recordId{2}', new String[]{
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

            if (saveData.productData != null) {
                cacheChildRecordsAfterSave(call.Call2_Discussion_vod__r);
                cacheChildRecordsAfterSave(call.Call2_Detail_vod__r);
            }

            if (saveData.keyMessageData != null) {
                cacheChildRecordsAfterSave(call.Call2_Key_Message_vod__r);
            }

            if (saveData.materialData != null) {
                cacheChildRecordsAfterSave(call.Call2_Sample_vod__r);
            }

            if (saveData.pfgData != null) {
                cacheChildRecordsAfterSave(call.Call_PFG_Details__r);
            }

            if (saveData.preCallData != null) {
                cacheChildRecordsAfterSave(call.Call_Pre_Calls__r);
            }

            if (saveData.interactionDetailData != null) {
                cacheChildRecordsAfterSave(call.Call2_Interaction_Detail_vod__r);
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
        return getRecordFromCache(getRecordKey(rec));
    }

    private SObject getRecordFromCache(String recKey) {
        return recordsCache != null ? recordsCache.get(recKey) : null;
    }

    private String getRecordKey(SObject rec) {
        String result = null;

        if (rec instanceof Call2_vod__c) {
            result = getRecordKey((Call2_vod__c) rec);
        } else if (rec instanceof Call2_Discussion_vod__c) {
            result = getRecordKey((Call2_Discussion_vod__c) rec);
        } else if (rec instanceof Call2_Detail_vod__c) {
            result = getRecordKey((Call2_Detail_vod__c) rec);
        } else if (rec instanceof Call2_Key_Message_vod__c) {
            result = getRecordKey((Call2_Key_Message_vod__c) rec);
        } else if (rec instanceof Call2_Sample_vod__c) {
            result = getRecordKey((Call2_Sample_vod__c) rec);
        } else if (rec instanceof Call_PFG_Detail_gne__c) {
            result = getRecordKey((Call_PFG_Detail_gne__c) rec);
        } else if (rec instanceof Call_Pre_Call_gne__c) {
            result = getRecordKey((Call_Pre_Call_gne__c) rec);
        } else if (rec instanceof Call2_Interaction_Detail_vod__c) {
            result = getRecordKey((Call2_Interaction_Detail_vod__c) rec);
        }

        return result;
    }

    private String getRecordKey(Call2_vod__c call) {
        return String.format('call_{0}_{1}_{2}_{3}_{4}', new String[]{
                call.Parent_Call_vod__c, call.Account_vod__c, call.Contact_vod__c, call.User_vod__c, call.EMS_International_Speaker_gne__c
        });
    }

    private String getRecordKey(Call2_Discussion_vod__c cd) {
        return String.format('callDiscussion_{0}_{1}', new String[]{
                cd.Call2_vod__c, cd.Detail_Priority_gne__c != null ? String.valueOf(cd.Detail_Priority_gne__c) : null
        });
    }

    private String getRecordKey(Call2_Detail_vod__c cd) {
        return String.format('callDetail_{0}_{1}', new String[]{
                cd.Call2_vod__c, cd.Product_vod__c
        });
    }

    private String getRecordKey(Call2_Key_Message_vod__c ckm) {
        return String.format('callKeyMessage_{0}_{1}_{2}', new String[]{
                ckm.Call2_vod__c, ckm.Product_vod__c, ckm.Key_Message_vod__c
        });
    }

    private String getRecordKey(Call2_Sample_vod__c cs) {
        return String.format('callSample_{0}_{1}_{2}', new String[]{
                cs.Call2_vod__c, cs.Product_vod__c, cs.Account_vod__c
        });
    }

    private String getRecordKey(Call_PFG_Detail_gne__c cpd) {
        return String.format('callPfg_{0}_{1}', new String[]{
                cpd.Call_gne__c, cpd.Product_gne__c
        });
    }

    private String getRecordKey(Call_Pre_Call_gne__c cpc) {
        return String.format('callPreCall_{0}_{1}', new String[]{
                cpc.Call_gne__c, cpc.Product_gne__c
        });
    }

    private String getRecordKey(Call2_Interaction_Detail_vod__c cid) {
        return String.format('callInteractionDetail_{0}_{1}', new String[]{
                cid.Call2_vod__c, cid.Visit_Reason_vod__c
        });
    }

    public void setRecordIdFromExisting(SObject rec, TableRowWrapper trw) {
        SObject existingRec = getRecordFromCache(rec);
        if (existingRec != null && childRecordsToRemoveMap.containsKey(existingRec.Id)) {
            rec.Id = existingRec.Id;
            childRecordsToRemoveMap.remove(rec.Id);

            if (recToWrapperMap == null) {
                recToWrapperMap = new Map<String, TableRowWrapper>();
            }

            recToWrapperMap.put(getRecordKey(rec), trw);
        }
    }

    private void saveAttendees() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        attendeesToUpsert = new List<Call2_vod__c>();
        Map<Id, List<AttendeeWrapper>> accountIdToAttendeesMap = new Map<Id, List<AttendeeWrapper>>();

        if (saveData.multipleAccountsMode == true) {
            for (MultipleAccountWrapper callAccount : saveData.multipleAccountsData) {
                accountIdToAttendeesMap.put(callAccount.id, callAccount.attendees);
            }
        } else {
            accountIdToAttendeesMap.put(saveData.callAccount.id, saveData.attendeeData.rows);
        }

        for (Id callAccountId : accountIdToAttendeesMap.keySet()) {
            Call2_vod__c call = accountIdToCallMap.get(callAccountId);

            for (AttendeeWrapper aw : accountIdToAttendeesMap.get(callAccountId)) {
                Call2_vod__c callAttendee = (Call2_vod__c) aw.getRecord(Call2_vod__c.class);
                callAttendee.Parent_Call_vod__c = call.Id;
                setCallAddress(callAttendee, call.Parent_Address_vod__r);
                callAttendee.RecordTypeId = call.RecordTypeId;
                callAttendee.Detailed_Products_vod__c = call.Detailed_Products_vod__c;
                callAttendee.HCP_OR_Attendee_Meal_Opt_Out_gne__c = call.HCP_OR_Attendee_Meal_Opt_Out_gne__c;

                if (saveData.completeMode == true || saveData.isCompleted == true) {
                    Call2_vod__c mainCall = (Call2_vod__c) recordAfterSave;
                    callAttendee.Completed_gne__c = mainCall.Completed_gne__c;
                    callAttendee.Date_Completed_gne__c = mainCall.Date_Completed_gne__c;
                }

                if (String.isNotEmpty(call.OwnerId)) {
                    callAttendee.OwnerId = call.OwnerId;
                }

                setRecordIdFromExisting(callAttendee, aw);

                Set<String> excludedFieldNames = getAttendeeExcludedFieldNames();

                for (GNE_SFA2_Base_Ctrl.Field siField : inputDataWrapper.inputFields) {
                    String fieldName = siField.name;
                    if (callAttendee.get(fieldName) == null && !excludedFieldNames.contains(fieldName.toLowerCase())) {
                        callAttendee.put(fieldName, call.get(fieldName));
                    }
                }

                attendeesToUpsert.add(callAttendee);

                if (callAttendee.Account_vod__c != null) {
                    accountIdToCallMap.put(callAttendee.Account_vod__c, callAttendee);
                }

                if (callAttendee.Contact_vod__c != null) {
                    contactIdToCallMap.put(callAttendee.Contact_vod__c, callAttendee);
                }
            }
        }
        executeDml(GNE_SFA2_Base_Ctrl.DmlOperations.UPS, getChangedRecords(attendeesToUpsert), false);
    }

    protected virtual Set<String> getAttendeeExcludedFieldNames() {
        if (attendeeExcludedFieldNames == null) {
            attendeeExcludedFieldNames = new Set<String>{
                    String.valueOf(Call2_vod__c.HCP_Account_Meal_Opt_Out_gne__c).toLowerCase(),
                    String.valueOf(Call2_vod__c.Account_vod__c).toLowerCase(),
                    String.valueOf(Call2_vod__c.Request_Signature_gne__c).toLowerCase(),
                    String.valueOf(Call2_vod__c.Request_Signature_Date_gne__c).toLowerCase(),
                    String.valueOf(Call2_vod__c.Signature_vod__c).toLowerCase(),
                    String.valueOf(Call2_vod__c.Signature_Date_vod__c).toLowerCase(),
                    String.valueOf(Call2_vod__c.License_vod__c).toLowerCase(),
                    String.valueOf(Call2_vod__c.Disclaimer_vod__c).toLowerCase()
            };
        }

        return attendeeExcludedFieldNames;
    }

    private void saveProducts() {
        List<Call2_vod__c> calls = new List<Call2_vod__c>(accountIdToCallMap.values());
        detailsToUpsert = new List<Call2_Detail_vod__c>();
        discussionsToUpsert = new List<Call2_Discussion_vod__c>();

        for (Call2_vod__c call : calls) {
            saveProductsForCall(call);
        }
    }

    private void saveProductsForCall(Call2_vod__c call) {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        Set<Id> visitedProdIds = new Set<Id>();
        Integer detPrio = 1, discPrio = 1;
        Set<String> productStrategyTacticUniq = new Set<String>();

        for (ProductWrapper pw : saveData.productData.rows) {
            Id productId = pw.getProductId();
            if (String.isNotBlank(productId)) {
                if (!visitedProdIds.contains(productId)) {
                    visitedProdIds.add(productId);
                    Call2_Detail_vod__c cDetail = new Call2_Detail_vod__c(Product_vod__c = productId, Call2_vod__c = call.Id);
                    cDetail.Detail_Priority_vod__c = detPrio++;
                    cDetail.Type_vod__c = 'Paper_Detail_vod';

                    if (recordId != call.Id && String.isNotBlank(cDetail.iPhone_Request_Id_gne__c)) {
                        cDetail.iPhone_Request_Id_gne__c = null;
                    }

                    setRecordIdFromExisting(cDetail, pw);
                    detailsToUpsert.add(cDetail);
                }

                if (saveData.productData.objectiveOrProductMode == true) {
                    Call2_Discussion_vod__c cd = (Call2_Discussion_vod__c) pw.getRecord(Call2_Discussion_vod__c.class);
                    cd.Call2_vod__c = call.Id;

                    if (recordId != call.Id && String.isNotBlank(cd.iPhone_Request_Id_gne__c)) {
                        cd.iPhone_Request_Id_gne__c = null;
                    }

                    List<String> productTactics = cd.Product_Tactic_vod__c == null ? new List<String>{
                            null
                    } : ((String) cd.Product_Tactic_vod__c).split(';');
                    for (Integer i = 0; i < productTactics.size(); i++) {
                        if (productTactics.get(i) != null) {
                            if (productStrategyTacticUniq.contains(cd.Product_vod__c + '#' + cd.Product_Strategy_vod__c + '#' + productTactics.get(i))) {
                                continue;
                            } else {
                                productStrategyTacticUniq.add(cd.Product_vod__c + '#' + cd.Product_Strategy_vod__c + '#' + productTactics.get(i));
                            }
                        }

                        if (i > 0) {
                            cd = cd.clone(false, true);
                        }

                        cd.Detail_Priority_gne__c = discPrio++;
                        cd.Product_Tactic_vod__c = productTactics.get(i);

                        setRecordIdFromExisting(cd, pw);
                        //frm logic SFA-2363
                        if (GNE_SFA2_Util.isFrmUser() && cd.FRM_Issue_Status__c != null) {
                            callDiscussisonAssignValues(cd);
                        }
                        discussionsToUpsert.add(cd);
                    }
                }

            }
        }
    }

    private void saveKeyMessages() {
        List<Call2_vod__c> calls = new List<Call2_vod__c>(accountIdToCallMap.values());
        keyMessagesToUpsert = new List<Call2_Key_Message_vod__c>();

        for (Call2_vod__c call : calls) {
            saveKeyMessagesForCall(call);
        }
    }

    private void callDiscussisonAssignValues(Call2_Discussion_vod__c cd) {
        if (status2fields.get(cd.FRM_Issue_Status__c) == null) {
            return;
        }
        callDiscussisonClearValues(cd);
        for (String field : status2fields.get(cd.FRM_Issue_Status__c)) {
            cd.put(field, true);
        }
    }

    private void callDiscussisonClearValues(Call2_Discussion_vod__c cd) {
        for (String field : status2fields.get('FieldsToClear')) {
            cd.put(field, false);
        }
    }

    private void saveKeyMessagesForCall(Call2_vod__c call) {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;

        for (KeyMessageWrapper kmw : saveData.keyMessageData.rows) {
            Call2_Key_Message_vod__c ckm = (Call2_Key_Message_vod__c) kmw.getRecord(Call2_Key_Message_vod__c.class);
            ckm.Call2_vod__c = call.Id;
            ckm.Account_vod__c = call.Account_vod__c;
            setRecordIdFromExisting(ckm, kmw);
            keyMessagesToUpsert.add(ckm);
        }
    }

    private void saveMaterials() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        materialsToUpsert = new List<Call2_Sample_vod__c>();

        for (Call2_vod__c call : mainCallsToUpsert) {
            for (MaterialWrapper mw : saveData.materialData.rows) {
                Call2_Sample_vod__c cs = (Call2_Sample_vod__c) mw.getRecord(Call2_Sample_vod__c.class);
                if (cs.Account_vod__c != null && accountIdToCallMap.containsKey(cs.Account_vod__c)) {
                    cs.Call2_vod__c = accountIdToCallMap.get(cs.Account_vod__c).Id;
                } else if (cs.Contact_vod__c != null && contactIdToCallMap.containsKey(cs.Contact_vod__c)) {
                    cs.Call2_vod__c = contactIdToCallMap.get(cs.Contact_vod__c).Id;
                }
                setRecordIdFromExisting(cs, mw);
                materialsToUpsert.add(cs);
            }
        }
    }

    private void saveMaterialsForCanada() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        materialsToUpsert = new List<Call2_Sample_vod__c>();
        for (Call2_vod__c call : mainCallsToUpsert) {
            for (MaterialWrapper mw : saveData.materialData.rows) {
                Call2_Sample_vod__c cs = (Call2_Sample_vod__c) mw.getRecord(Call2_Sample_vod__c.class);
                if (cs.Quantity_vod__c == null || cs.Quantity_vod__c == 0) {
                    cs.Quantity_vod__c = 1;
                }
                if(String.isBlank(cs.Call2_vod__c)) {
                    cs.Call2_vod__c = call.Id;
                }
                setRecordIdFromExisting(cs, mw);
                materialsToUpsert.add(cs);
            }
        }
    }

    private void saveVisitReasonDetails() {
        List<Call2_vod__c> calls = new List<Call2_vod__c>(accountIdToCallMap.values());

        for (Call2_vod__c call : calls) {
            saveVisitReasonDetailsForCall(call);
        }
    }

    private void saveVisitReasonDetailsForCall(Call2_vod__c call) {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        visitReasonDetailsToUpsert = new List<Call2_Interaction_Detail_vod__c>();

        for (InteractionDetailWrapper vrw : saveData.interactionDetailData.rows) {
            Call2_Interaction_Detail_vod__c cid = (Call2_Interaction_Detail_vod__c) vrw.getRecord(Call2_Interaction_Detail_vod__c.class);
            cid.Call2_vod__c = call.Id;
            setRecordIdFromExisting(cid, vrw);

            visitReasonDetailsToUpsert.add(cid);
        }
    }

    private void saveAttachments() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        attachmentsToDelete = new List<Attachment>();
        attachmentsToUpsert = new List<Attachment>();

        Set<Id> attForDelete = new Set<Id>();
        Set<Id> attForUpsert = new Set<Id>();

        for (AttachmentWrapper a : saveData.attachmentData) {
            if (a.isTemp) {
                attForUpsert.add(a.id);
            }

            if (a.forDelete) {
                attForDelete.add(a.id);
            }
        }

        for (Attachment a : [SELECT Id, Name, Body, ContentType FROM Attachment WHERE Id IN :attForUpsert]) {
            attachmentsToDelete.add(a);
            for (Call2_vod__c mctu : mainCallsToUpsert) {
                if (String.isEmpty(mctu.Parent_Call_vod__c)) {
                    Attachment newAttach = new Attachment();
                    newAttach.Name = a.Name;
                    newAttach.Body = a.Body;
                    newAttach.ContentType = a.ContentType;
                    newAttach.ParentId = mctu.Id;
                    attachmentsToUpsert.add(newAttach);
                }
            }
        }

        for (Attachment a : [SELECT Id FROM Attachment WHERE Id IN :attForDelete]) {
            attachmentsToDelete.add(a);
        }

        List<AttachmentWrapper> existingAttachments = new List<AttachmentWrapper>();
        for (Integer i = 0; i < saveData.attachmentData.size(); i++) {
            if (!saveData.attachmentData[i].forDelete) {
                existingAttachments.add(saveData.attachmentData[i]);
            }
        }

        saveData.attachmentData = existingAttachments;
    }

    private void saveReferral() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        UserWrapper cUser = saveData.appContext.currentUser;
        medcomsToUpdate = new List<Medical_Communication_gne__c>();
        referralsToUpdate = new List<Referral_Assignment_gne__c>();
        Call2_vod__c call = (Call2_vod__c) record;
        referral = saveData.referral;
        Referral_Assignment_gne__c ra = new Referral_Assignment_gne__c(Id = referral.id, Call2_vod__c = call.Id);

        if (saveData.completeMode == true) {
            String refHistory = String.join(new List<String>{
                    Datetime.now().format(GNE_Referral_Utils.strPSTFormat, GNE_Referral_Utils.strPST),
                    GNE_Referral_Utils.strStatusUpdate,
                    cUser.name,
                    referral.assignedToName,
                    referral.assignedToName,
                    referral.assignedToProfileName,
                    GNE_Referral_Utils.strFulfilled
            }, ',') + ';';

            Medical_Communication_gne__c mc = new Medical_Communication_gne__c(
                    Id = referral.mcId,
                    Unsolicited_Request_Verified_gne__c = true,
                    Unsolicited_Request_Verified_By_gne__c = cUser.id,
                    Unsolicited_Request_Verified_Date_gne__c = Date.today(),
                    Referral_History_gne__c = (String.isNotBlank(referral.history) ? referral.history : '') + refHistory
            );

            medcomsToUpdate.add(mc);

            if (referral.status != GNE_Referral_Utils.strFulfilled) {
                GNE_Referral_Utils.sendReferralEmail(ra, new Medical_Communication_gne__c(Id = mc.Id), GNE_Referral_Utils.strFulfilled);
            }

            referral.status = ra.Status_Referral_gne__c = GNE_Referral_Utils.strFulfilled;
            referral.history = mc.Referral_History_gne__c;
        }

        referralsToUpdate.add(ra);
    }

    private void savePreCalls() {
        DataWrapper saveData = (DataWrapper) inputDataWrapper;
        preCallsToUpsert = new List<Call_Pre_Call_gne__c>();

        for (Call2_vod__c call : mainCallsToUpsert) {
            for (PreCallWrapper pw : saveData.preCallData.rows) {
                Call_Pre_Call_gne__c pc = (Call_Pre_Call_gne__c) pw.getRecord(Call_Pre_Call_gne__c.class);
                pc.Call_gne__c = call.Id;
                setRecordIdFromExisting(pc, pw);
                preCallsToUpsert.add(pc);
            }
        }
    }

    private Map<Id, String> getProductToSegmentMap() {
        Call2_vod__c call = (Call2_vod__c) record;
        Map<Id, String>productIdToSegment = new Map<Id, String>();
        String terrName = getCurrentTerrName(UserInfo.getUserId());
        for (Targets_and_Tiers_can_gne__c target : [SELECT Product_Catalog_gne__c, Segment_gne__c FROM Targets_and_Tiers_can_gne__c WHERE Account_can_gne__c = :call.Account_vod__c AND Territory_gne__c = :terrName AND Segment_gne__c != NULL]) {
            if (!productIdToSegment.containsKey(target.Product_Catalog_gne__c)) {
                productIdToSegment.put(target.Product_Catalog_gne__c, target.Segment_gne__c);
            }
        }
        return productIdToSegment;
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper intDeleteRecord() {
        GNE_SFA2_Base_Ctrl.DataWrapper result = super.intDeleteRecord();
        DataWrapper inputData = (DataWrapper) inputDataWrapper;
        Id accId = inputData.callAccount.id;
        result.retUrl = '/' + accId;
        return result;
    }

    protected override RecordType getRecordType(Boolean isNewMode) {
        RecordType result = super.getRecordType(isNewMode);
        if (isNewMode) {
            String rtDeveloperName = getDefaultRecordTypeBasedOnTerritory(getCurrentTerritoryId());
            if (String.isNotBlank(rtDeveloperName)) {
                for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Call2_vod__c' AND DeveloperName = :rtDeveloperName LIMIT 1]) {
                    result = rt;
                }
            }
            System.debug('Res: ' + result);
        }
        return result;
    }

    private String getDefaultRecordTypeBasedOnTerritory(Id currentTerritoryId) {
        String defaultRecordType = null;
        try {
            Territory2 terr = [SELECT Salesforce_Code_gne__c FROM Territory2 WHERE Id = :currentTerritoryId LIMIT 1];
            if (terr.Salesforce_Code_gne__c != null) {
                GNE_SFA2_Territory_Record_Type_mapping__c terrToRTmapping = GNE_SFA2_Territory_Record_Type_mapping__c.getInstance(terr.Salesforce_Code_gne__c);
                if (terrToRTmapping != null) {
                    defaultRecordType = terrToRTmapping.Record_Type_DeveloperName__c;
                }
            }
        } catch (Exception ex) {
            System.debug('Exception while retrieving default record type: ' + ex);
        }
        return defaultRecordType;
    }

    global virtual class DataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
        public List<AddressWrapper> addresses;
        public AttendeeData attendeeData;
        public ProductData productData;
        public KeyMessageData keyMessageData;
        public MaterialData materialData;
        public Boolean isMaterialPerAttendeeAndProductModeEnabled;
        public Boolean isPreCallEnabled;
        public PreCallData preCallData;
        public Boolean simpleEditMode;
        public AccountWrapper callAccount;
        public ReferralWrapper referral;
        public List<MultipleAccountWrapper> multipleAccountsData;
        public Boolean isCompleted;
        public Boolean completeMode;
        public Boolean multipleAccountsMode;
        public Boolean noAccountMode;
        public List<AttachmentWrapper> attachmentData;
        public Boolean referralMode;
        public String completeReferralQuestion;
        public String mealExpenseLabel;
        public String callNotesDisclaimerLabel;
        public GNE_SFA2_PFG_Interaction_Ctrl.PfgData pfgData;
        public Boolean newCallMode;
        public InteractionDetailData interactionDetailData;

        public DataWrapper() {
        }
    }

    public virtual class AccountWrapper {
        public Id id;
        public String name;
        public Boolean isPersonAccount;

        public AccountWrapper(Account acc) {
            this.id = acc.Id;
            this.name = acc.Name;
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

    public class AddressWrapper {
        public String label;
        public Id value;
        public String name;
        public String suitFloor;
        public String city;
        public String state;
        public String zip;
        public String zip4;
        public String province;
        public String postalCode;
        public String pfgBDTD;
        public String pfgBDTDFormatted;
        public Double latitude;
        public Double longitude;
        public Boolean hidden;

        public AddressWrapper(Address_vod__c address, Boolean hidden) {
            this(address);
            this.hidden = hidden;
        }

        public AddressWrapper(Address_vod__c address) {
            this(GNE_SFA2_Util.getAddressAsString(address), address.Id);
            this.name = address.Name;
            this.suitFloor = address.Address_line_2_vod__c;
            this.city = address.City_vod__c;
            this.state = address.State_vod__c;
            this.zip = address.Zip_vod__c;
            this.zip4 = address.Zip_4_vod__c;
            this.province = address.Province_can_gne__c;
            this.postalCode = address.Postal_Code_can_gne__c;
            this.pfgBDTD = address.PFG_BDTD_gne__c;
            this.pfgBDTDFormatted = address.PFG_BDTD_calc_gne__c;
            this.latitude = address.Location_gne__Latitude__s;
            this.longitude = address.Location_gne__Longitude__s;
        }

        public AddressWrapper(String label, Id value) {
            this.label = label;
            this.value = value;
        }

        public Address_vod__c getAddressRecord() {
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

    private class ReferralWrapper {
        private Id id;
        private Id accountId;
        private Id mcId;
        private String status;
        private String history;
        private String assignedToName;
        private String assignedToProfileName;

        private ReferralWrapper(Referral_Assignment_gne__c ra) {
            this.id = ra.Id;
            this.accountId = ra.Medical_Request_gne__r.Account_gne__c;
            this.mcId = ra.Medical_Request_gne__c;
            this.status = ra.Status_Referral_gne__c;
            this.history = ra.Medical_Request_gne__r.Referral_History_gne__c;
            this.assignedToName = ra.Assigned_To_gne__r.Name;
            this.assignedToProfileName = ra.Assigned_To_gne__r.Profile_Name_gne__c;
        }
    }

    public class AttendeeData {
        public List<AttendeeOptionWrapper> options;
        public List<GNE_SFA2_Base_Ctrl.Field> columns;
        public List<GNE_SFA2_Base_Ctrl.Field> searchColumns;
        public List<AttendeeWrapper> rows;
        public Map<String, List<HcpWrapper>> hcps;
        public Boolean onlyContactAttendees;

        public AttendeeData(List<AttendeeOptionWrapper> options, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns, List<AttendeeWrapper> rows) {
            this.options = options;
            this.columns = columns;
            this.searchColumns = searchColumns;
            this.rows = rows;
            this.onlyContactAttendees = false;
        }

        public AttendeeData(List<AttendeeOptionWrapper> options, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns, List<AttendeeWrapper> rows, Boolean onlyContactAttendees) {
            this.options = options;
            this.columns = columns;
            this.searchColumns = searchColumns;
            this.rows = rows;
            this.onlyContactAttendees = onlyContactAttendees;
        }

        public AttendeeData(Map<String, List<HcpWrapper>> hcps) {
            this.hcps = hcps;
        }
    }

    public virtual class HcpWrapper implements Comparable {
        public String id;
        public String lastName;
        public String firstName;
        protected Integer rank;

        public HcpWrapper(Account hcp) {
            this.id = hcp.Id;
            this.lastName = hcp.LastName;
            this.firstName = hcp.FirstName;
        }

        protected Integer getRank() {
            return this.rank == null ? 0 : this.rank;
        }

        protected void increaseRank() {
            this.increaseRank(1);
        }

        protected void increaseRank(Integer val) {
            this.rank = getRank() + val;
        }

        public Integer compareTo(Object otherHcpWrapperObj) {
            HcpWrapper otherHcpWrapper = (HcpWrapper) otherHcpWrapperObj;
            Integer rank = this.getRank();
            Integer otherRank = otherHcpWrapper.getRank();
            Integer result = rank - otherRank;
            return result == 0 ? this.lastName.compareTo(otherHcpWrapper.lastName) : result > 0 ? -1 : 1;
        }
    }

    public virtual class AttendeeWrapper extends TableRowWrapper {

        public AttendeeWrapper() {
        }

        public AttendeeWrapper(Call2_vod__c attendee, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            this(attendee, null, columns);
        }

        public AttendeeWrapper(Call2_vod__c attendee, String attendeeTypeFPM, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            this.fields = new List<GNE_SFA2_Base_Ctrl.Field>();
            String defaultAttendeeType;
            if (attendee.Contact_vod__c != null) {
                GNE_CRM_Default_Attendee_Type__c defaultAttendeeSetting = GNE_CRM_Default_Attendee_Type__c.getInstance(attendee.Contact_vod__c);
                if (defaultAttendeeSetting != null) {
                    defaultAttendeeType = defaultAttendeeSetting.Attendee_Type_gne__c;
                }
            }

            for (GNE_SFA2_Base_Ctrl.Field column : columns) {
                GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(column);
                Object fieldValue;

                if (field.name == 'attendeeName') {
                    if (attendee.Contact_vod__c != null) {
                        field.describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.Contact_vod__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.Contact_vod__c;
                        field.displayValue = attendee.Contact_vod__r.Name;
                    } else if (attendee.User_vod__c != null) {
                        field.describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.User_vod__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.User_vod__c;
                        field.displayValue = attendee.User_vod__r.Name;
                    } else if (attendee.EMS_International_Speaker_gne__c != null) {
                        field.describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.EMS_International_Speaker_gne__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.EMS_International_Speaker_gne__c;
                        field.displayValue = attendee.EMS_International_Speaker_gne__r.Name;
                    } else {
                        field.describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.Account_vod__c.getDescribe(), 'Call2_vod__c');
                        fieldValue = attendee.Account_vod__c;
                        field.displayValue = attendee.Account_vod__r.Name;
                    }
                    this.rowId = String.valueOf(fieldValue);
                } else if (field.name == 'lastName') {
                    this.rowId = String.valueOf(attendee.Account_vod__c);
                    fieldValue = attendee.Account_vod__r.LastName;
                } else if (field.name == 'firstName') {
                    fieldValue = attendee.Account_vod__r.FirstName;
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

        protected override SObject getRecord(System.Type sObjectType) {
            Call2_vod__c result = (Call2_vod__c) super.getRecord(sObjectType);

            GNE_SFA2_Base_Ctrl.Field lastNameField = getField('lastName');
            if (lastNameField != null) {
                result.Account_vod__c = (Id) rowId;
                result.Attendee_Type_vod__c = 'Person_Account_vod';
            }

            GNE_SFA2_Base_Ctrl.Field attTypeField = getField('attendeeType');
            if (attTypeField != null) {
                result.Attendee_Type_vod__c = attTypeField.value;
            }

            return result;
        }
    }

    private class AttendeeOptionWrapper extends AttendeeWrapper implements Comparable {
        private String label;
        private String addressDescription;
        private String accountType;
        private List<GNE_SFA2_Base_Ctrl.Field> searchResultFields;

        private AttendeeOptionWrapper(User u, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(User_vod__c = u.Id, User_vod__r = u, Attendee_Type_vod__c = 'User_vod'),
                    columns, searchColumns, u.LastName + (String.isNotBlank(u.FirstName) ? ', ' + u.FirstName : ''));
        }

        private AttendeeOptionWrapper(Account acc, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(Account_vod__c = acc.Id, Account_vod__r = acc, Attendee_Type_vod__c = 'Person_Account_vod'),
                    columns, searchColumns, acc.LastName + (String.isNotBlank(acc.FirstName) ? ', ' + acc.FirstName : ''));
            this.accountType = acc.Account_Type_gne__c;
        }

        private AttendeeOptionWrapper(Contact con, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(Contact_vod__c = con.Id, Contact_vod__r = con, Attendee_Type_vod__c = con.IsPersonAccount ? 'Person_Account_vod' : 'Contact_vod'),
                    getIsFPMProfile() ? con.Type_gne__c : null,
                    columns, searchColumns, con.LastName + (String.isNotBlank(con.FirstName) ? ', ' + con.FirstName : ''));
        }

        private AttendeeOptionWrapper(EMS_International_Speaker_gne__c ihcp, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns) {
            this(new Call2_vod__c(EMS_International_Speaker_gne__c = ihcp.Id, EMS_International_Speaker_gne__r = ihcp, Attendee_Type_vod__c = 'iHCP_Account_vod'),
                    columns, searchColumns, ihcp.Last_Name_gne__c + (String.isNotBlank(ihcp.First_Name_gne__c) ? ', ' + ihcp.First_Name_gne__c : ''));
        }

        private AttendeeOptionWrapper(Call2_vod__c attendeeCall, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns, String label) {
            this(attendeeCall, null, columns, searchColumns, label);
        }

        private AttendeeOptionWrapper(Call2_vod__c attendeeCall, String attendeeTypeFPM, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns, String label) {
            super(attendeeCall, attendeeTypeFPM, columns);
            this.label = label;

            if (searchColumns != null) {
                setSearchFields(searchColumns);
            }
        }

        private AttendeeOptionWrapper(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper saw, List<GNE_SFA2_Base_Ctrl.Field> columns, List<GNE_SFA2_Base_Ctrl.Field> searchColumns) {
            if (saw.isUser) {
                this((User) saw.record, columns, null);
            } else if (saw.isContact) {
                this((Contact) saw.record, columns, null);
            } else if (saw.recordType == 'iHCP') {
                this((EMS_International_Speaker_gne__c) saw.record, columns, null);
            } else {
                this((Account) saw.record, columns, null);
            }

            this.setAddressDescription(saw.addressDescription);
            this.setSearchFields(searchColumns);
        }

        private void setAddressDescription(String addressDescription) {
            this.addressDescription = addressDescription;
        }

        private void setSearchFields(List<GNE_SFA2_Base_Ctrl.Field> searchColumns) {
            Map<String, GNE_SFA2_Base_Ctrl.Field> fieldMap = new Map<String, GNE_SFA2_Base_Ctrl.Field>();

            for (GNE_SFA2_Base_Ctrl.Field field : this.fields) {
                fieldMap.put(field.name, field);
            }

            this.searchResultFields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (GNE_SFA2_Base_Ctrl.Field searchColumn : searchColumns) {
                GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(searchColumn);
                Object fieldValue;

                if (field.name == 'name') {
                    fieldValue = this.label;
                } else if (field.name == 'address') {
                    fieldValue = this.addressDescription;
                } else if (field.name == 'accountType') {
                    fieldValue = this.accountType;
                } else {
                    fieldValue = fieldMap.get(field.name).value;
                    field.displayValue = fieldMap.get(field.name).displayValue;
                }

                field.setValue(fieldValue);
                searchResultFields.add(field);
            }
        }

        public Integer compareTo(Object obj) {
            AttendeeOptionWrapper comparingTo = (AttendeeOptionWrapper) obj;
            if (this.label.toUpperCase() > comparingTo.label.toUpperCase()) {
                return 1;
            }

            if (this.label.toUpperCase() < comparingTo.label.toUpperCase()) {
                return -1;
            }

            return 0;
        }
    }

    private class MultipleAttendeeWrapper extends AttendeeWrapper {
        private Id id;
        private String name;

        public MultipleAttendeeWrapper(Contact con) {
            super(
                    new Call2_vod__c(Contact_vod__c = con.Id, Contact_vod__r = con, Attendee_Type_vod__c = con.IsPersonAccount ? 'Person_Account_vod' : 'Contact_vod'),
                    new List<GNE_SFA2_Base_Ctrl.Field>{
                            new GNE_SFA2_Base_Ctrl.Field('attendeeName', 'Attendee'),
                            new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
                    });

            this.id = this.rowId;
            this.name = getField('attendeeName').displayValue;
        }
    }

    public class ProductData {
        public List<ProductOptionWrapper> options;
        public List<GNE_SFA2_Base_Ctrl.Field> columns;
        public ProductWrapper objectiveTemplate;
        public List<ProductWrapper> rows;
        public List<DependentPicklistItem> productStrategyTacticItems;
        public List<DependentPicklistItem> productContents;
        public Boolean objectiveOrProductMode;

        public ProductData(List<ProductOptionWrapper> options, List<GNE_SFA2_Base_Ctrl.Field> columns, ProductWrapper objectiveTemplate, List<ProductWrapper> rows,
                List<DependentPicklistItem> productStrategyTacticItems, List<DependentPicklistItem> productContents) {
            this.options = options;
            this.columns = columns;
            this.objectiveTemplate = objectiveTemplate;
            this.rows = rows;
            this.productStrategyTacticItems = productStrategyTacticItems;
            this.productContents = productContents;
            this.objectiveOrProductMode = objectiveTemplate != null;
        }
    }

    public class InteractionDetailData {
        public List<GNE_SFA2_Base_Ctrl.Field> columns;
        public InteractionDetailWrapper rowTemplate;
        public List<InteractionDetailWrapper> rows;

        public InteractionDetailData(List<GNE_SFA2_Base_Ctrl.Field> columns, InteractionDetailWrapper rowTemplate, List<InteractionDetailWrapper> rows) {
            this.columns = columns;
            this.rowTemplate = rowTemplate;
            this.rows = rows;
        }
    }

    public virtual class InteractionDetailWrapper extends TableRowWrapper {
        public InteractionDetailWrapper() {
        }

        public InteractionDetailWrapper(String rowId, Call2_Interaction_Detail_vod__c cdRec, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            this.rowId = rowId;
            this.fields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (GNE_SFA2_Base_Ctrl.Field column : columns) {
                GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(column);
                if (column.describe.type == 'reference' && cdRec.getSObject(column.describe.relationshipName) != null) {
                    field.displayValue = (String) cdRec.getSObject(column.describe.relationshipName).get('Name');
                }

                field.setValue(cdRec.get(field.name));
                this.fields.add(field);
            }
        }
    }

    private class DependentPicklistItem {
        private String value;
        private String label;
        private String groups;
        private List<DependentPicklistItem> items;

        private DependentPicklistItem(String value, String label) {
            this.value = value;
            this.label = label;
        }

        private DependentPicklistItem(String value, String label, String groups) {
            this.value = value;
            this.label = label;
            this.groups = groups;
        }

        private void addItem(DependentPicklistItem item) {
            if (items == null) {
                items = new List<DependentPicklistItem>();
            }

            items.add(item);
        }

        private void addItems(List<DependentPicklistItem> items) {
            if (items == null) {
                items = new List<DependentPicklistItem>();
            }

            items.addAll(items);
        }
    }

    public virtual class ProductWrapper extends TableRowWrapper {
        public Id recordTypeId;

        public ProductWrapper() {
        }

        public ProductWrapper(String rowId, SObject cd, Id recordTypeId, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            this.rowId = rowId;
            this.recordTypeId = recordTypeId;
            this.fields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (GNE_SFA2_Base_Ctrl.Field column : columns) {
                GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(column);
                Object fieldValue;
                if (column.name == 'productName') {
                    fieldValue = ((Call2_Discussion_vod__c) cd).Product_vod__r.Name;
                    this.rowId = ((Call2_Discussion_vod__c) cd).Product_vod__c;
                } else if (column.name == 'FRM_Team_gne__c') {
                    fieldValue = getFrmTeam();
                } else {
                    fieldValue = cd.get(field.name);
                }

                if (column.describe != null && column.describe.type == 'reference' && cd.getSObject(column.describe.relationshipName) != null) {
                    String displayFieldName = column.name == String.valueOf(Call2_Discussion_vod__c.Event_Curriculum_gne__c) ? String.valueOf(Event_Curriculum_gne__c.Aprimo_ID_gne__c) : 'Name';
                    field.displayValue = (String) cd.getSObject(column.describe.relationshipName).get(displayFieldName);
                }

                field.setValue(fieldValue);
                this.fields.add(field);
            }
        }

        private String getFrmTeam() {
            String result = null;
            String profileName = staticGetCurrentUserProfileName().toUpperCase();
            Pattern frmPattern = Pattern.compile('GNE-MCCO-FRM-(\\w+FRM)-{0,1}\\w*');
            Matcher frmMatcher = frmPattern.matcher(profileName);

            if (frmMatcher.find()) {
                result = frmMatcher.group(1);
            } else if(staticGetCurrentUserProfileName().toUpperCase().contains('GNE-CRM')) {
                result = 'CRM';
            }

            return result;
        }

        protected override SObject getRecord(System.Type sObjectType) {
            Call2_Discussion_vod__c result = (Call2_Discussion_vod__c) super.getRecord(sObjectType);

            if (String.isNotBlank(recordTypeId)) {
                result.RecordTypeId = recordTypeId;
            }

            GNE_SFA2_Base_Ctrl.Field productNameField = getField('productName');
            if (productNameField != null) {
                result.Product_vod__c = (Id) rowId;
            }

            return result;
        }

        private Id getProductId() {
            Id result = null;
            GNE_SFA2_Base_Ctrl.Field prodfldName = getField('productName');
            GNE_SFA2_Base_Ctrl.Field prodfldId = getField('Product_vod__c');

            if (prodfldName != null) {
                result = (Id) rowId;
            } else if (prodfldId != null) {
                result = (Id) prodfldId.value;
            }

            return result;
        }

        private String getProductName() {
            String result = null;
            GNE_SFA2_Base_Ctrl.Field prodfld1 = getField('Product_vod__c');
            GNE_SFA2_Base_Ctrl.Field prodfld2 = getField('productName');

            if (prodfld1 != null && String.isNotBlank(prodfld1.displayValue)) {
                result = prodfld1.displayValue;
            } else if (prodfld2 != null && String.isNotBlank(prodfld2.value)) {
                result = prodfld2.value;
            }

            return result;
        }
    }

    private virtual class ProductOptionWrapper extends ProductWrapper {
        private String label;
        private String therapeuticArea;
        private Boolean isTherapeuticArea;
        private Boolean isPromo;
        private Boolean isNonPromo;

        private ProductOptionWrapper(String rowId, Product_vod__c prod, Id recordTypeId, List<GNE_SFA2_Base_Ctrl.Field> columns, Boolean isObjective) {
            super(rowId,
                    isObjective
                            ? (SObject) new Call2_Discussion_vod__c(Product_vod__c = prod.Id, Product_vod__r = prod, RecordTypeId = recordTypeId)
                            : (SObject) new Call2_Detail_vod__c(Product_vod__c = prod.Id, Product_vod__r = prod, Type_vod__c = 'Paper_Detail_vod'),
                    isObjective ? recordTypeId : null,
                    columns);
            this.label = prod.Name;
            this.therapeuticArea = prod.Therapeutic_Area_Reference__c;
            this.isTherapeuticArea = prod.Product_Type_vod__c == 'Therapeutic Area';
            this.isPromo = prod.Promotional__c;
            this.isNonPromo = prod.Non_Promotional__c;

        }
    }

    public class PreCallData {
        public List<GNE_SFA2_Base_Ctrl.Field> columns;
        public List<PreCallWrapper> rows;
        public PreCallWrapper rowTemplate;
        public List<DependentPicklistItem> objectiveItems;
        public List<QuestionItem> questionsItems;
        public String preCallLastModifiedDate;
        public Map<Id, String>productToSegmentMap;

        public PreCallData(List<GNE_SFA2_Base_Ctrl.Field> columns, PreCallWrapper rowTemplate, List<PreCallWrapper> rows, List<DependentPicklistItem> objectiveItems, List<QuestionItem> questionsItems, Map<Id, String>productToSegmentMap, String preCallLastModifiedDate) {
            this.columns = columns;
            this.rowTemplate = rowTemplate;
            this.rows = rows;
            this.objectiveItems = objectiveItems;
            this.questionsItems = questionsItems;
            this.productToSegmentMap = productToSegmentMap;
            this.preCallLastModifiedDate = preCallLastModifiedDate;
        }
    }

    public virtual class PreCallWrapper extends TableRowWrapper {
        public PreCallWrapper() {
        }

        public PreCallWrapper(Call_Pre_Call_gne__c pcRec, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            this.rowId = pcRec.Product_gne__c + '_' + pcRec.Id;
            this.fields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (GNE_SFA2_Base_Ctrl.Field column : columns) {
                GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(column);
                if (column.describe.type == 'reference' && pcRec.getSObject(column.describe.relationshipName) != null) {
                    field.displayValue = (String) pcRec.getSObject(column.describe.relationshipName).get('Name');
                }

                field.setValue(pcRec.get(field.name));
                this.fields.add(field);
            }
        }

        protected override SObject getRecord(System.Type sObjectType) {
            Call_Pre_Call_gne__c result = (Call_Pre_Call_gne__c) super.getRecord(sObjectType);
            return result;
        }
    }

    public class KeyMessageData {
        public List<KeyMessageOptionWrapper> options;
        public List<GNE_SFA2_Base_Ctrl.Field> columns;
        public List<KeyMessageWrapper> rows;

        public KeyMessageData(List<KeyMessageOptionWrapper> options, List<GNE_SFA2_Base_Ctrl.Field> columns, List<KeyMessageWrapper> rows) {
            this.options = options;
            this.columns = columns;
            this.rows = rows;
        }
    }

    public virtual class KeyMessageWrapper extends TableRowWrapper {
        public KeyMessageWrapper() {
        }

        public KeyMessageWrapper(Call2_Key_Message_vod__c kmRec, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            this.rowId = kmRec.Product_vod__c + '_' + kmRec.Key_Message_vod__c;
            this.fields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (GNE_SFA2_Base_Ctrl.Field column : columns) {
                GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(column);
                Object fieldValue;

                if (field.name == 'productName') {
                    fieldValue = kmRec.Product_vod__r.Name;
                } else if (field.name == 'description') {
                    fieldValue = kmRec.Key_Message_vod__r.Description_vod__c;
                } else {
                    fieldValue = kmRec.get(field.name);
                }

                field.setValue(fieldValue);
                this.fields.add(field);
            }
        }

        protected override SObject getRecord(System.Type sObjectType) {
            Call2_Key_Message_vod__c result = (Call2_Key_Message_vod__c) super.getRecord(sObjectType);
            String[] rowIdData = rowId.split('_');
            result.Product_vod__c = rowIdData[0];
            result.Key_Message_vod__c = rowIdData[1];
            return result;
        }
    }

    private virtual class KeyMessageOptionWrapper extends KeyMessageWrapper {
        private String label;
        private String productId;
        private String productName;

        private KeyMessageOptionWrapper(Key_Message_vod__c km, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            super(new Call2_Key_Message_vod__c(Key_Message_vod__c = km.Id, Key_Message_vod__r = km,
                    Product_vod__c = km.Product_vod__c, Product_vod__r = km.Product_vod__r), columns);
            this.label = km.Name;
            this.productId = km.Product_vod__r.Id;
            this.productName = km.Product_vod__r.Name;
        }
    }

    public class MaterialData {
        public List<GNE_SFA2_Base_Ctrl.Field> columns;
        public MaterialWrapper rowTemplate;
        public List<MaterialWrapper> rows;
        public List<MaterialProductItem> materialProducts;

        public MaterialData(List<GNE_SFA2_Base_Ctrl.Field> columns, MaterialWrapper rowTemplate, List<MaterialWrapper> rows, List<MaterialProductItem> materialProducts) {
            this.columns = columns;
            this.rowTemplate = rowTemplate;
            this.rows = rows;
            this.materialProducts = materialProducts;
        }
    }

    public virtual class MaterialWrapper extends TableRowWrapper {
        public MaterialWrapper() {
        }

        public MaterialWrapper(String rowId, Call2_Sample_vod__c csRec, List<GNE_SFA2_Base_Ctrl.Field> columns) {
            this.rowId = rowId;
            this.fields = new List<GNE_SFA2_Base_Ctrl.Field>();

            for (GNE_SFA2_Base_Ctrl.Field column : columns) {
                GNE_SFA2_Base_Ctrl.Field field = new GNE_SFA2_Base_Ctrl.Field(column);
                if (column.describe.type == 'reference' && csRec.getSObject(column.describe.relationshipName) != null) {
                    field.displayValue = (String) csRec.getSObject(column.describe.relationshipName).get('Name');
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
        private Boolean promo;
        private Boolean nonPromo;

        private MaterialProductItem(Product_vod__c mProduct, Boolean isDependend) {
            this.value = mProduct.Id;
            this.label = mProduct.Name;
            this.type = mProduct.Product_Type_vod__c;
            this.isActive = mProduct.active__c;
            this.controllingProductId = isDependend ? mProduct.Parent_Product_vod__c : null;
            this.promo = contentSectionCanadaProfilesSet.contains(GNE_SFA2_Util.getCurrentUserProfileName()) ? mProduct.Promotional__c : false;
            this.nonPromo = contentSectionCanadaProfilesSet.contains(GNE_SFA2_Util.getCurrentUserProfileName()) ? mProduct.Non_Promotional__c : false;
        }

        public Integer compareTo(Object compareTo) {
            MaterialProductItem otherObj = (MaterialProductItem) compareTo;
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

    private class QuestionItem {
        private String value;
        private String label;
        private String category;

        private QuestionItem(String value, String label, String category) {
            this.value = value;
            this.label = label;
            this.category = category;
        }
    }

    private class PreCallItem {
        private String customerSegment;
        private String interactionObjective;
        private String decisionCycle;
        private String insightful;

        private PreCallItem(Call_Pre_Call_gne__c preCall) {
            this.customerSegment = preCall.Customer_Segment_gne__c;
            this.interactionObjective = preCall.Interaction_Objectives_gne__c;
            this.decisionCycle = preCall.Decision_Cycle_gne__c;
            this.insightful = preCall.Questions_gne__c;
        }
    }

    private class AttachmentWrapper {
        private String id;
        private String name;
        private Boolean isTemp;
        private Boolean forDelete;
        private String parentId;
        private String tempId;

        private AttachmentWrapper(String id, String name, Boolean isTemp, Boolean forDelete, String parentId, String tempId) {
            this.id = id;
            this.name = name;
            this.isTemp = isTemp;
            this.forDelete = forDelete;
            this.parentId = parentId;
            this.tempId = tempId;
        }
    }

    public virtual class TableRowWrapper {
        public String rowId;
        public List<GNE_SFA2_Base_Ctrl.Field> fields;

        public TableRowWrapper() {
        }

        public GNE_SFA2_Base_Ctrl.Field getField(String fieldName) {
            GNE_SFA2_Base_Ctrl.Field result = null;
            if (fields != null) {
                for (GNE_SFA2_Base_Ctrl.Field fld : fields) {
                    if (fld.name == fieldName) {
                        result = fld;
                        break;
                    }
                }
            }

            return result;
        }

        protected virtual SObject getRecord(System.Type sObjectType) {
            SObject result = (SObject) sObjectType.newInstance();

            if (fields != null) {
                for (GNE_SFA2_Base_Ctrl.Field fld : fields) {
                    if (fld.describe != null && (!fld.describe.calculated && fld.describe.updateable && fld.describe.createable)) {
                        result.put(fld.describe.name, fld.getValue());
                    }
                }
            }

            return result;
        }

        protected virtual Set<String> getFieldNames() {
            Set<String> result = new Set<String>();

            if (fields != null) {
                for (GNE_SFA2_Base_Ctrl.Field fld : fields) {
                    if (fld.describe != null && String.isNotBlank(fld.describe.name)) {
                        result.add(fld.describe.name.toLowerCase());
                    }
                }
            }

            return result;
        }
    }

    private class MealOptOutEventNotCompletedException extends GNE_SFA2_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'MealOptOutEventNotCompleted';
            label = System.Label.GNE_SFA2_Meal_Opt_Out_Meal_Event_Not_Completed;
        }
    }

    private class MealOptOutActualMealRecipientException extends GNE_SFA2_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'MealOptOutActualMealRecipient';
            label = System.Label.GNE_SFA2_Meal_Opt_Out_Actual_Meal_Recipient_Validation;
        }
    }

    private class CannotEditCompletedInteractionInfoException extends GNE_SFA2_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Info.name();
            subType = 'CannotEditCompletedInteraction';
            label = System.Label.GNE_SFA2_Cannot_Edit_Completed_Interaction;
        }
    }

    // static methods

    @RemoteAction @ReadOnly
    global static DataWrapper initViewModuleData(Map<String, String> params) {
        return (DataWrapper) (new GNE_SFA2_Interaction_Ctrl()).init(params);
    }

    @RemoteAction
    global static DataWrapper saveRecord(String inputDataInJSON) {
        return (DataWrapper) (new GNE_SFA2_Interaction_Ctrl()).saveRecord(inputDataInJSON, GNE_SFA2_Interaction_Ctrl.DataWrapper.class);
    }

    @RemoteAction
    global static DataWrapper deleteRecord(String inputDataInJSON) {
        return (DataWrapper) (new GNE_SFA2_Interaction_Ctrl()).deleteRecord(inputDataInJSON, GNE_SFA2_Interaction_Ctrl.DataWrapper.class);
    }

    @RemoteAction @ReadOnly
    global static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchAccounts(Map<String, String> params) {
        if (GNE_SFA2_Util.isPactUser()) {
            return GNE_SFA2_SearchAccounts_Controller.searchOrganizationAccounts(params.get('searchValue'), Integer.valueOf(params.get('recordLimit')), params.get('ignoredIds').split(','), Id.valueOf(params.get('userId')), 'Art_Account_frm_gne__c = true');
        }
        return GNE_SFA2_SearchAccounts_Controller.searchOrganizationAccounts(params.get('searchValue'), Integer.valueOf(params.get('recordLimit')), params.get('ignoredIds').split(','), Id.valueOf(params.get('userId')));
    }

    @RemoteAction @ReadOnly
    global static DataWrapper searchAttendeesWithPhrase(Map<String, Object> params) {
        return (new GNE_SFA2_Interaction_Ctrl()).searchAttendees(params);
    }

    @RemoteAction @ReadOnly
    global static DataWrapper getMultipleAccountsData(Map<String, String> params) {
        return new GNE_SFA2_Interaction_Ctrl(params).getDataWrapperWithMultipleAccountsData();
    }

    @RemoteAction
    global static DataWrapper getAttendees(Map<String, Object> params) {
        return (new GNE_SFA2_Interaction_Ctrl()).getAttendeesMinList(params);
    }

    @RemoteAction
    global static String attachBlob(String parentId, String attachmentId, String fileName, String contentType, String base64BlobValue) {

        //If recordId is blank this is the first part of a multi piece upload
        if (attachmentId == '' || attachmentId == null) {
            Attachment att = new Attachment(
                    ParentId = parentId,
                    Body = EncodingUtil.base64Decode(base64BlobValue),
                    Name = fileName,
                    ContentType = contentType
            );
            insert att;

            //Return the new attachment Id
            return att.Id;

        } else {
            for (Attachment atm : [SELECT Id, Body FROM Attachment WHERE Id = :attachmentId]) {
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.base64Decode(EncodingUtil.base64Encode(atm.Body) + base64BlobValue));
            }

            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }

    @RemoteAction
    global static Boolean removeTempAttachment(Map<String, String> params) {
        return (new GNE_SFA2_Interaction_Ctrl()).deleteAttachments(params.get('id'));
    }

    @RemoteAction
    global static void removeAllTempAttachments(Map<String, String> params) {
        List<String> attachIds = params.get('attachIds').split(',');
        if (!attachIds.isEmpty()) {
            List<Attachment> attachmentsList = [SELECT Id FROM Attachment WHERE Id IN :attachIds];
            if (!attachmentsList.isEmpty()) {
                delete attachmentsList;
                //executeDML(GNE_SFA2_Base_Ctrl.DmlOperations.DEL, attachmentsList);
            }
        }
    }

    private static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchInternationalSpeakers(String searchString, Integer recordLimit) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
        for (EMS_International_Speaker_gne__c ihcp : [SELECT Id, Name, First_Name_gne__c, Last_Name_gne__c, Address_gne__c, Country_gne__c FROM EMS_International_Speaker_gne__c WHERE First_Name_gne__c LIKE :searchString OR Last_Name_gne__c LIKE :searchString OR Name LIKE :searchString LIMIT :recordLimit]) {
            GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper = new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(new Account(Name = ihcp.Name), null);
            wrapper.record = ihcp;
            wrapper.accountId = ihcp.Id;
            wrapper.accountDescription = ihcp.Last_Name_gne__c + ', ' + ihcp.First_Name_gne__c;
            wrapper.recordType = 'iHCP';
            if (ihcp.Country_gne__c != null && ihcp.Address_gne__c != null) {
                wrapper.addressDescription = ihcp.Address_gne__c + ', ' + ihcp.Country_gne__c;
            } else if (ihcp.Country_gne__c != null) {
                wrapper.addressDescription = ihcp.Country_gne__c;
            } else {
                wrapper.addressDescription = '';
            }
            wrapper.isContact = false;
            wrapper.isUser = false;

            result.add(wrapper);
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

    private static Boolean getIsBAMProfile() {
        return staticGetCurrentUserProfileName().toUpperCase().contains('BAM');
    }

    private static String staticGetCurrentUserProfileName() {
        return staticCurrentUserProfileName == null ? '' : staticCurrentUserProfileName;
    }

    @RemoteAction
    public static UpdateDataWrapper updateDataAfterChangeAccount(Id recordId) {
        Account callAccount = [
                SELECT Id, Name, IsPersonAccount, (
                        SELECT Id, Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c, PFG_BDTD_gne__c, PFG_BDTD_calc_gne__c, Location_gne__Latitude__s, Location_gne__Longitude__s
                        FROM Address_vod__r
                        WHERE Inactive_vod__c = FALSE
                        ORDER BY Name
                )
                FROM Account
                WHERE Id = :recordId
        ];

        List<AddressWrapper> addresses = new List<AddressWrapper>();

        for (Address_vod__c address : callAccount.Address_vod__r) {
            addresses.add(new AddressWrapper(address));
        }

        List<GNE_SFA2_Base_Ctrl.Field> attendeeColumns = getAttendeeColumns(false, getIsFPMProfile(), getIsBAMProfile(), true, new List<GNE_SFA2_Base_Ctrl.Field>());

        List<GNE_SFA2_Base_Ctrl.Field> attendeeSearchColumns = new List<GNE_SFA2_Base_Ctrl.Field>{
                new GNE_SFA2_Base_Ctrl.Field('name', 'Name'),
                new GNE_SFA2_Base_Ctrl.Field('address', 'Address'),
                new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
        };

        List<AttendeeOptionWrapper> attendeeOptions = getAttedeeOptions(recordId, attendeeColumns, attendeeSearchColumns, false);

        return new UpdateDataWrapper(addresses, new AccountWrapper(callAccount), new AttendeeData(attendeeOptions, attendeeColumns, attendeeSearchColumns, new List<AttendeeWrapper>()));
    }

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

    public AttendeeWrapper fetchNewHCP(Map<String, String> params) {
        String acctId = params.get('accId');
        String addrId = null;
        if (params.containsKey('addrId')) {
            addrId = params.get('addrId');
        }

        Address_vod__c addr = fetchAddress(acctId, addrId);
        List<GNE_SFA2_Base_Ctrl.Field> result = new List<GNE_SFA2_Base_Ctrl.Field>{
                new GNE_SFA2_Base_Ctrl.Field('name', 'Name'),
                new GNE_SFA2_Base_Ctrl.Field('address', 'Address'),
                new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
        };
        List<GNE_SFA2_Base_Ctrl.Field> result1 = new List<GNE_SFA2_Base_Ctrl.Field>{
                new GNE_SFA2_Base_Ctrl.Field('attendeeName', 'Attendee'),
                new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
        };
        result1.add(
                new GNE_SFA2_Base_Ctrl.Field(
                        'HCP_Attendee_Meal_Opt_Out_gne__c', 'Meal Opt Out', null, null, null, null, false, false, null, new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.HCP_Attendee_Meal_Opt_Out_gne__c.getDescribe(), 'Call2_vod__c')
                )
        );

        Account acc = new Account(Id = acctId, LastName = addr.Account_vod__r.LastName, FirstName = addr.Account_vod__r.FirstName);
        GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper saw = new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(acc, addr);

        AttendeeOptionWrapper attWraper = new AttendeeOptionWrapper(saw, result1, result);

        for (GNE_SFA2_Base_Ctrl.Field column : attWraper.fields) {

            if (column.name == 'attendeeName') {
                column.describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.Account_vod__c.getDescribe(), 'Call2_vod__c');
                column.displayValue = addr.Account_vod__r.Name;
            }
        }
        return attWraper;
    }

    public AttendeeWrapper fetchNewContact(Map<String, String> params) {
        String contactId = params.get('contactId');
        Contact myNewContact = [SELECT Full_Name_gne__c, AccountId FROM Contact WHERE Id = :contactId];
        String acctId = myNewContact.AccountId;
        String addrId = null;
        if (params.containsKey('addrId')) {
            addrId = params.get('addrId');
        }

        Address_vod__c addr = fetchAddress(acctId, addrId);
        List<GNE_SFA2_Base_Ctrl.Field> result = new List<GNE_SFA2_Base_Ctrl.Field>{
                new GNE_SFA2_Base_Ctrl.Field('name', 'Name'),
                new GNE_SFA2_Base_Ctrl.Field('address', 'Address'),
                new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
        };
        List<GNE_SFA2_Base_Ctrl.Field> result1 = new List<GNE_SFA2_Base_Ctrl.Field>{
                new GNE_SFA2_Base_Ctrl.Field('attendeeName', 'Attendee'),
                new GNE_SFA2_Base_Ctrl.Field('attendeeType', 'Type')
        };
        result1.add(
                new GNE_SFA2_Base_Ctrl.Field(
                        'HCP_Attendee_Meal_Opt_Out_gne__c', 'Meal Opt Out', null, null, null, null, false, false, null, new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.HCP_Attendee_Meal_Opt_Out_gne__c.getDescribe(), 'Call2_vod__c')
                )
        );

        Account acc = new Account(Id = acctId, LastName = addr.Account_vod__r.LastName, FirstName = addr.Account_vod__r.FirstName);

        GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper saw = new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(acc, addr);

        AttendeeOptionWrapper attWraper = new AttendeeOptionWrapper(saw, result1, result);

        for (GNE_SFA2_Base_Ctrl.Field column : attWraper.fields) {
            if (column.name == 'attendeeName') {
                column.describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Call2_vod__c.Contact_vod__c.getDescribe(), 'Call2_vod__c');
                column.displayValue = myNewContact.Full_Name_gne__c;
                column.value = contactId;
            } else if (column.name == 'attendeeType') {
                column.displayValue = 'Contact';
                column.value = 'Contact_vod';
            }
        }

        for (GNE_SFA2_Base_Ctrl.Field column : attWraper.searchResultFields) {
            if (column.name == 'name') {
                column.displayValue = myNewContact.Full_Name_gne__c;
            } else if (column.name == 'attendeeType') {
                column.displayValue = 'Contact';
                column.value = 'Contact_vod';
            }
        }
        attWraper.rowId = contactId;

        return attWraper;
    }

    private static Address_vod__c fetchAddress(String acctId, String addrId) {
        return Database.query(String.format('SELECT {0} FROM Address_vod__c WHERE {1} LIMIT 1', new String[]{
                'Id, Account_vod__c, Account_vod__r.FirstName, Account_vod__r.LastName, Account_vod__r.Formatted_Name_vod__c, Account_vod__r.Name,' +
                        'Account_vod__r.Phone, Account_vod__r.MDMID_Status_gne__c, Address_Line_2_vod__c, Name, City_vod__c, State_vod__c, Zip_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s',
                'Account_vod__c =: acctId' + (String.isNotBlank(addrId) ? ' AND Id =: addrId' : '')
        }));
    }

    public static GNE_MCCO_CRM_Base_Ctrl.DataWrapper saveContactRecord(GNE_MCCO_CRM_Contact_Controller.DataWrapper inputData) {
        String firstName;
        String lastName;
        String contactId;
        String accountId;
        Map<String, String> params = new Map<String, String>();
        for (GNE_MCCO_CRM_Base_Ctrl.Field f : inputData.inputFields) {
            if (f.name.equalsIgnoreCase('firstname')) {
                firstName = (String) f.getValue();
            } else if (f.name.equalsIgnoreCase('lastname')) {
                lastName = (String) f.getValue();
            } else if (f.name.equalsIgnoreCase('contactId')) {
                contactId = (String) f.getValue();
            } else if (f.name.equalsIgnoreCase('accountId')) {
                accountId = (String) f.getValue();
            }
        }
        if (String.isEmpty(contactId)) {
            Contact existingContact = iPhone_DAO.getContactByFirstAndLastName(firstName, lastName, accountId);
            if (existingContact != null) {
                inputData.contactId = existingContact.Id;
                inputData.recordDescribe.recordId = existingContact.Id;
            }
        }
        GNE_MCCO_CRM_Base_Ctrl.DataWrapper resultData = (new GNE_MCCO_CRM_Contact_Controller()).saveRecord(inputData, params);
        resultData.retUrl = null;
        return resultData;
    }

    @RemoteAction
    public static GNE_SFA2_Base_Ctrl.DataWrapper getSBCConfig(Map<String, String> params) {
        return (new GNE_SFA2_Interaction_Ctrl()).getSBCConfig();
    }

    @RemoteAction
    public static GNE_SFA2_Base_Ctrl.DataWrapper sbcSearchAccounts(String searchDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).searchAccounts(searchDataWrapperInJSON, false);
    }

    @RemoteAction
    public static GNE_SFA2_Base_Ctrl.DataWrapper searchMore(String searchMoreDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).searchAccounts(searchMoreDataWrapperInJSON, true);
    }

    @RemoteAction
    public static GNE_SFA2_Base_Ctrl.DataWrapper createAccount(String inputDataWrapperInJSON) {
        GNE_SFA2_Base_Ctrl.DataWrapper resultData = (new GNE_SFA2_SBC_Ctrl()).insertAccount(inputDataWrapperInJSON);
        resultData.retUrl = null;
        return resultData;
    }

    @RemoteAction
    public static GNE_SFA2_Base_Ctrl.DataWrapper upsertAccountFromMdm(String inputDataWrapperInJSON) {
        return (new GNE_SFA2_SBC_Ctrl()).upsertAccount(inputDataWrapperInJSON);
    }

    @RemoteAction
    public static GNE_MCCO_CRM_Base_Ctrl.DataWrapper saveContactRecord(String inputDataWrapperInJSON) {
        GNE_MCCO_CRM_Contact_Controller.DataWrapper inputData = (GNE_MCCO_CRM_Contact_Controller.DataWrapper) JSON.deserialize(inputDataWrapperInJSON, GNE_MCCO_CRM_Contact_Controller.DataWrapper.class);
        return saveContactRecord(inputData);
    }

    @RemoteAction
    public static AttendeeWrapper getNewHCP(Map<String, String> params) {
        return (new GNE_SFA2_Interaction_Ctrl()).fetchNewHCP(params);
    }

    @RemoteAction
    public static AttendeeWrapper getNewContact(Map<String, String> params) {
        return (new GNE_SFA2_Interaction_Ctrl()).fetchNewContact(params);
    }

    @RemoteAction
    public static GNE_MCCO_CRM_Base_Ctrl.DataWrapper getNewContactConfigurationPage(Map<String, String> params) {
        return (new GNE_SFA2_Interaction_Ctrl()).fetchContactConfigurationPage();
    }

    // USPS Address Validation Logic

    @RemoteAction
    global static String addressValidate(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.addressValidate(params);
    }

    @RemoteAction
    global static String cityStateLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.cityStateLookup(params);
    }

    @RemoteAction
    global static String zipCodeLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.zipCodeLookup(params);
    }
}