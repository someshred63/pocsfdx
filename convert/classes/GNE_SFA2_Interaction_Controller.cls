public with sharing class GNE_SFA2_Interaction_Controller {

    public Call2_vod__c call {get; set;}
    public Account callAccount {get; private set;}
    public Boolean isCompleted {get; private set;}
    public List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>affiliatedAccounts {get; private set;}
    public String selectedAccountsJSON {get; set;}
    public String userProfile {get; set;}

    //collections for related objects
    public List<AttendeeWrapper> attendees {get; set;}
    public List<ActivityWrapper> activities {get; set;}
    public List<DiscussionWrapper> discussions {get; set;}
    public List<ProductDetailWrapper> callProducts {get; set;}
    public List<MaterialWrapper> materials {get; set;}
    public List<AttachmentWrapper> attachments {get; set;}
    public List<KeyMessageWrapper> keyMessages {get; set;}
    public List<InteractionDetailWrapper> interactionDetails {get; set;}
    public List<InteractionCategoryWrapper> interactionCategories { get; set; }

    public List<Id> selectedProducts {get; set;}
    public List<Id> selectedAccounts {get; set;}
    public List<Id> selectedKeyMessages {get; set;}

    private List<Call2_vod__c> attendeesToRemove {get; set;}
    private List<Task> activitiesToRemove {get; set;}
    private List<Call2_Discussion_vod__c> discussionsToRemove {get; set;}
    private List<Call2_Detail_vod__c> productDetailsToRemove {get; set;}
    private List<Call2_Sample_vod__c> materialsToRemove {get; set;}
    private List<Attachment> attachmentsToRemove {get; set;}
    private List<Id> callKeyMessagesIdsToRemove {get; set;}
    private List<Call2_Interaction_Detail_vod__c> interactionDetailsToRemove {get; set;}
    private List<Call2_Category_vod__c> interactionCategoriesToRemove { get; set; }

    public List<SelectOption> addresses {get; set;}
    public List<SelectOption> availableProducts {get; set;}
    public List<SelectOption> callDiscussionProducts {get; set;}

    public List<SelectOption> availableMaterials {get; set;}
    public List<SelectOption> recipients {get; set;}
    public List<SelectOption> callFollowupTemplates {get; set;}
    public List<SelectOption> availableAccounts {get; set;}

    public List<SelectOption> timeOptions {get; set;}
    public String callDate {get; set;}
    public String callTime {get; set;}
    public Boolean isUsingDatetime {get; set;}

    private String recordTypeId;
    private String recordTypeName;

    public List<SFA2_Configuration_Object_gne__c> callSectionsList {get; private set;}
    public Map<ID, List<SFA2_Configuration_Object_Detail_gne__c>> callSectionsMap {get; private set;}
    public List<SFA2_Configuration_Object_Detail_gne__c> attendeesAdditionalFields {get; private set;}

    //helper objects used as params in apex functions
    public Integer discussionIndex {get; set;}
    public Integer callProductIndex {get; set;}
    public String productParam {get; set;}
    public String materialParam {get; set;}
    public String recipientParam {get; set;}
    public String strategyParam {get; set;}
    public String curriculumParam {get; set;}
    public String accountTacticParam {get; set;}
    public String productTacticParam {get; set;}
    public String activityParam {get; set;}
    public String moleculeParam { get; set; }
    public String visitReasonParam { get; set; }
    public String therapeuticAreaParam { get; set; }
    public String brandNameParam { get; set; }
    public String brandAndAboveBrandParam { get; set; }
    public String nocStatusParam { get; set; }
    public String groupParam { get; set; }

    public Integer materialIndex {get; set;}
    public Integer attendeeIndex {get; set;}
    public Integer activityIndex {get; set;}
    public Integer attachmentIndex {get; set;}
    public Integer keyMessagesIndex {get; set;}
    public Integer interactionDetailIndex {get; set;}
    public Integer interactionCategoryIndex { get; set; }
    public Integer therapeuticAreaIndex { get; set; }
    public Integer brandnameIndex { get; set; }
    public Integer brandAndAboveBrandIndex { get; set; }
    public Integer nocStatusIndex { get; set; }

    private List<SFA2_Configuration_Object_Detail_gne__c> discussionSectionFields;
    private List<SFA2_Configuration_Object_Detail_gne__c> materialsSectionFields;
    private List<SFA2_Configuration_Object_Detail_gne__c> activitiesSectionFields;

    public List<ProductKeyMessageWrapper>productToKeyMessagesWrappers {get; private set;}

    private String callId;
    public Boolean isCallInsert { get; set;} /*SFDC-2604 : When child object Insert fails, rollback in not removing Call ID, but rolling back the data.  If user changes data and save the call,
                                                then because of Call ID from previous error, upsert call tring to update the record and throwing error with message "first error:
                                                INVALID_CROSS_REFERENCE_KEY, invalid cross reference id: []", using this variable removing ID of error transactions in save method.*/
    public Boolean isMBcheckboxes { get; set;} /*SFA-1019 MB checkboxes */
    private GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();

    //variable for action function
    public Id productId {get; set;}
    public Id affiliatedAccountId {get; set;}
    public Id keyMessageId {get; set;}

    private String canEditRedirectReasonMsg;

    // Exceptions for MedAffairs and HcvRcc profiles
    public Boolean isVisitReasonOverriden {get; private set;}
    public Boolean isActivityOverriden {get; private set;}
    public List<SelectOption> availableActivities {get; private set;}
    public List<SelectOption> primaryInteractionReasonOptions { get; private set; }
    public List<SelectOption> visitReasonOptions { get; private set; }
    public List<SelectOption> visitReasonDescriptionOptions { get; private set; }

    private List<SelectOption> visitReasonDescriptionOptionsCache;
    private Map<String, List<Selectoption>> primaryReasonControlledFields;
    private String primaryReasonKeyAll;
    private Boolean initVisitReasonOverride = false;
    private Boolean primaryReasonFound = false;
    private Boolean visitReasonFound = false;
    private Boolean visitReasonDescriptionFound = false;
    private Boolean discussionTopicFieldExists = false;
    // End Exceptions for MedAffairs and HcvRcc profiles
    private final static List<String>requiredFields = new String[] {'Id', 'Account_vod__c', 'User_vod__c', 'Contact_vod__c', 'Name', 'Address_vod__c', 'Address_Line_1_vod__c', 'Address_Line_2_vod__c', 'Zip_4_vod__c', 'Zip_vod__c', 'City_vod__c', 'State_vod__c', 'Interaction_Status_gne__c', 'Parent_Call_vod__c', 'Detailed_Products_vod__c', 'Call_Datetime_vod__c', 'Call_Date_vod__c', 'Completed_gne__c', 'Date_Completed_gne__c', 'HCP_Attendee_Meal_Opt_Out_gne__c', 'HCP_OR_Attendee_Meal_Opt_Out_gne__c', 'Interaction_Method_gne__c', 'Referral_Assignment_gne__c'};
    private final static Set<String>mslExternalReferralFields = new Set<String> {'OTHER_REFERRAL_SOURCE_GNE__C', 'REFERRAL_REQUESTED_BY_GNE__C', 'REFERRAL_REQUESTED_DATE_GNE__C', 'REFERRAL_SOURCE_GNE__C', 'IS_REFERRAL_GNE__C'};

    private Boolean isAttendeesSectionVisible;
    private Boolean isDiscussionSectionVisible;
    private Boolean isProductDetailsSectionVisible;
    private Boolean isMaterialsSectionVisible;
    private Boolean isActivitiesSectionVisible;
    private Boolean isAttachmentsSectionVisible;
    private Boolean isMealExpensesSectionVisible;
    private Boolean isKeyMessagesSectionVisible;
    private Boolean isInteractionDetailsSectionVisible;
    private Boolean isAccessEchoSectionVisible;
    private Boolean isCategorySectionVisible;
    private Boolean isNotesSectionVisible;

    public Boolean mealOptOutEnabled {get; set;}
    public Boolean isHCPAccount {get{ return callAccount.isPersonAccount;} private set;}
    public Boolean showAttendeeDetailFields {get; private set;}
    public Boolean dependentMaterialsEnabled {get; private set;}

    // Attachments Method
    public String tempAttachmentParentId {get; set;}
    public String temporaryCallId {get; set;}

    public GNE_SFA2_PFG_Interaction_Controller pfgController { get; set; }
    public GNE_SFA2_MCCO_Interaction_Controller mccoCRMController { get; set; }
    public GNE_SFA2_Referral_Interaction_Ctrl referralInteractionController { get; set; }

    private Boolean isCreatedFromReferral;

    public Boolean disableButtons { get; set; }
    // Only this field can be edited even after interaction is completed
    private Boolean unsolicitedReqFieldExists { get; set; }

    private Boolean canEditOnComplete;
    private Boolean omitStrategyMode;

    public GNE_SFA2_PREP_Interaction_Controller prepController { get; set; }
    private transient static Map<String, String> attendeeTypeValueToLabelMap;

    private transient Map<String,List<FieldVisibilityData>> fieldVisibilityDataCache;
    private transient Map<String,Set<String>> fieldVisibilityDependendFieldsCache;

    public Set<String> validationMessagesSummary { get; private set; }
    public String activitySelectForTlsJson { get; set; }
    public String strActivityValuesJson { get; set; }

    public GNE_SFA2_Interaction_Controller() {
        disableButtons = false;
        unsolicitedReqFieldExists = false;
        pfgController = new GNE_SFA2_PFG_Interaction_Controller(this);
        prepController = new GNE_SFA2_PREP_Interaction_Controller(this);
        mccoCRMController = new GNE_SFA2_MCCO_Interaction_Controller(this, ApexPages.currentPage().getParameters().get('accountId'), ApexPages.currentPage().getParameters().get('contactId'), ApexPages.currentPage().getParameters().get('Id'));
        referralInteractionController = new GNE_SFA2_Referral_Interaction_Ctrl(this, ApexPages.currentPage().getParameters().get('referralId'));
        isCreatedFromReferral = String.isNotEmpty(ApexPages.currentPage().getParameters().get('referralId'));
        showAttendeeDetailFields = false;
        canEditOnComplete = true;
        omitStrategyMode = false;

        if (GNE_SFA2_Util.getCurrentUserProfileName() == 'GNE-SYS-DataSupport-Merge') {
            GNE_SFA2_User_App_Context_gne__c appContext = GNE_SFA2_Util.getApplicationContextByRecordOwner(ApexPages.currentPage().getParameters().get('Id'));

            if (appContext != null) {
                userApplicationContext = appContext;
            }
        }
    }

    public PageReference init() {
        try {
            callAccount = getCallAccount();
        } catch (Exception e) {
            return GNE_SFA2_Util.redirectToErrorPage('Wrong parameters.', Apexpages.currentPage().getUrl(), '');
        }

        callId = ApexPages.currentPage().getParameters().get('Id');
        timeOptions = createTimeOptions();
        availableProducts = getAvailableProducts(UserInfo.getUserId());
        availableMaterials = getAvailableMaterials(UserInfo.getUserId());
        attendeesToRemove = new List<Call2_vod__c>();
        activitiesToRemove = new List<Task>();
        discussionsToRemove = new List<Call2_Discussion_vod__c>();
        callProducts = new List<ProductDetailWrapper>();
        productDetailsToRemove = new List<Call2_Detail_vod__c>();
        materialsToRemove = new List<Call2_Sample_vod__c>();
        attachmentsToRemove = new List<Attachment>();
        interactionDetailsToRemove = new List<Call2_Interaction_Detail_vod__c>();
        interactionCategoriesToRemove = new List<Call2_Category_vod__c>();
        callKeyMessagesIdsToRemove = new List<Id>();
        isAttendeesSectionVisible = false;
        isDiscussionSectionVisible = false;
        isProductDetailsSectionVisible = false;
        isMaterialsSectionVisible = false;
        isActivitiesSectionVisible = false;
        isAttachmentsSectionVisible = false;
        isMealExpensesSectionVisible = false;
        isKeyMessagesSectionVisible = false;
        isInteractionDetailsSectionVisible = false;
        isAccessEchoSectionVisible = false;
        isCategorySectionVisible = false;
        isNotesSectionVisible = false;
        mealOptOutEnabled = false;
        userProfile = GNE_SFA2_Util.getCurrentUserProfileName();

        callDiscussionProducts = new List<SelectOption>();
        callDiscussionProducts.add(new SelectOption('', '--None--'));
        selectedProducts = new List<Id>();
        selectedAccounts = new List<Id>();
        selectedKeyMessages = new List<Id>();
        productToKeyMessagesWrappers = new List<ProductKeyMessageWrapper>();
        validationMessagesSummary = new Set<String>();

        if(userProfile.contains('GNE-TLS')) {
            activitySelectForTlsJson = JSON.serialize(new List<String> {
                                            '--None--',
                                            'Data Update',
                                            'Disease Education',
                                            'Key Concept Communicated',
                                            'Moderator Training',
                                            'Observation',
                                            'Thought Leader Connect',
                                            'TL Profile or Survey'});
            strActivityValuesJson = JSON.serialize(new List<String> {
                    '1:1 Training/Deck Update'});

        }
        tempAttachmentParentId = getTempParentIdToNewAttachment();
        temporaryCallId = String.valueOf(System.now()).remove(':').remove(' ').remove('-') + Math.random();
        temporaryCallId = temporaryCallId.remove('0.');

        isUsingDatetime = true;

        List<SFA2_Configuration_Object_gne__c> configuration;
        try {
            recordTypeId = getRecordTypeId(userApplicationContext);
            recordTypeName = [Select DeveloperName from RecordType where id = :recordTypeId].DeveloperName;
            if (mccoCRMController.isMultipleInteraction) {
                configuration = mccoCRMController.getConfigForMultipleAccounts(userApplicationContext.Role_gne__c, userApplicationContext.Brand_gne__c, recordTypeName, userApplicationContext.App_Name_gne__c);
                for (SFA2_Configuration_Object_gne__c co : configuration) {
                    for (SFA2_Configuration_Object_Detail_gne__c cod : co.Configuration_Objects__r) {
                        if (cod.API_Name_gne__c == 'Subject_vod__c' || cod.API_Name_gne__c == 'Interaction_Method_gne__c') {
                            cod.Is_Required_gne__c = false;
                        }
                    }
                }

            } else {
                configuration = GNE_SFA2_DynamicVFLoader.getUIConfigurationObjects(userApplicationContext, 'Call2_vod__c', recordTypeName);
            }
        } catch (System.QueryException e) {
            String developerMsg = 'Brand: ' + userApplicationContext.Brand_gne__c + '; role: ' + userApplicationContext.Role_gne__c + '; application: ' + userApplicationContext.App_Name_gne__c + '; object: Call2_vod__c; recortType: ' + recordTypeName + '; recortTypeId: ' + recordTypeId;
            return GNE_SFA2_Util.redirectToErrorPage('Roster configuration not found.', Apexpages.currentPage().getUrl(), developerMsg);
        }

        try {
            readConfiguration(configuration);
        } catch (System.QueryException e) {
            return GNE_SFA2_Util.redirectToErrorPage('Record not found or Id parameter missing.', Apexpages.currentPage().getUrl(), e.getMessage());
        }

        //SFA-793
        if (!isCreatedFromReferral && call != null) {
            isCreatedFromReferral = String.isNotEmpty(call.Referral_Assignment_gne__c);
        }

        if (getIsMslProfile()) {
            if (isCreatedFromReferral || !isHCPAccount) {
                hideFields(configuration, mslExternalReferralFields);
            } else if (!isCreatedFromReferral) {
                hideFields(configuration, new Set<String> {'REFERRAL_ASSIGNMENT_GNE__C'});
            }
        }


        isCompleted = call != null && call.Interaction_Status_gne__c == 'Completed';
        // Check if edit mode and user can edit, if not redirect to view page
        Pagereference canEditResult = checkOnEdit();
        if (canEditResult != null) {
            return canEditResult;
        }

        // Exception for Canada users
        if (isCompleted && getHasUnsolicitedFieldEditAvailibleCanada) {
            disableButtons = true;
            Set<String> fieldsAvailableForEditing = new Set<String> {
                String.valueOf(Call2_vod__c.Unsolicited_Request_gne__c).toUpperCase()
            };
            lockFields(configuration, fieldsAvailableForEditing);
        }
        dependentMaterialsEnabled = isMaterialsSectionVisible == true && GNE_SFA2_Util.isCanadaUser();

        if (callId != null) {
            isCallInsert = false;
            addresses = getAddresses(call.Account_vod__c);
            attendees = getAttendees(call);
            activities = getActivities(call);
            materials = getMaterials(call, attendees);
            attachments = getAttachments(call);
            callProducts = getCallProducts(call);
            discussions = getDiscussions(call);
            keyMessages = getKeyMessages(call);
            callDiscussionProducts = getProductOptions(callProducts);
            interactionDetails = getInteractionDetails(call);
            interactionCategories = getInteractionCategories(call);
        } else {
            isCallInsert = true;
            String accountId = ApexPages.currentPage().getParameters().get('accountId');
            String contactId = ApexPages.currentPage().getParameters().get('contactId');
            Datetime callDate = Datetime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0);
            if (isCreatedFromReferral) {
                call = referralInteractionController.createCall();
                call.Call_Datetime_vod__c = callDate;
            } else {
                call = new Call2_vod__c(Account_vod__c = accountId, Call_Datetime_vod__c = callDate, RecordTypeId = recordTypeId, Interaction_Status_gne__c = 'Planned');
            }
            if(GNE_SFA2_Util.isCanadaRAMA()) {
                call.Interaction_Type_RAMA_gne__c = 'Face to Face';
            }

            addresses = getAddresses(call.Account_vod__c);
            call.Parent_Address_vod__c = addresses.isEmpty() ? null : addresses.get(0).getValue();
            attendees = new List<AttendeeWrapper>();
            if (String.isNotEmpty(contactId)) {
                attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Contact_vod__c = contactId, Attendee_Type_vod__c = 'Contact_vod')));
            }
            activities = new List<ActivityWrapper>();
            callProducts = new List<ProductDetailWrapper>();
            discussions = new List<DiscussionWrapper>();
            keyMessages = new List<KeyMessageWrapper>();
            materials = new List<MaterialWrapper>();
            attachments = new List<AttachmentWrapper>();
            interactionDetails = new List<InteractionDetailWrapper>();
            interactionCategories = new List<InteractionCategoryWrapper>();
        }

        availableMaterials = getAvailableMaterials(UserInfo.getUserId());

        if (!mccoCRMController.isMultipleInteraction) {
            affiliatedAccounts = getAffiliatedAccounts(call.Account_vod__c);
            availableAccounts = getAffiliatedAccountsOptions(affiliatedAccounts);
            selectedAccounts =  getAttendesFromAffiliatedAccounts(attendees, affiliatedAccounts);
        }

        try {
            //SFDC-2730 : if User open child call for Details or Edit, should take to Parent Call Details or Edit
            if (String.isNotEmpty(call.Parent_Call_vod__c)) {
                PageReference refPage;
                if (Apexpages.currentPage().getUrl().containsIgnoreCase('GNE_SFA2_Interaction_Edit_Create')) {
                    refPage = new PageReference('/apex/GNE_SFA2_Interaction_Edit_Create?id=' + call.Parent_Call_vod__c);
                } else {
                    refPage = new PageReference('/apex/GNE_SFA2_Interaction_Layout?id=' + call.Parent_Call_vod__c);
                }
                refPage.setRedirect(true);
                return refPage;
            }
        } catch (Exception e) {
            return GNE_SFA2_Util.redirectToErrorPage('Account record not found. Wrong params.', Apexpages.currentPage().getUrl(), e.getMessage());
        }
        if (call.Call_Datetime_vod__c != null) {
            callDate = call.Call_Datetime_vod__c.format('MM/d/yyyy');
            callTime =  call.Call_Datetime_vod__c.format('hh:mm a');
        } else if (call.Call_Date_vod__c != null) {
            isUsingDatetime = false;
            callDate = call.Call_Date_vod__c.format();
        }
        callFollowupTemplates = getCallFollowupTemplates();
        recipients = getRecipients(attendees);

        // Check redirect message, i.e if user has been redirected from edit page because he can't edit record
        String redirectMsg = ApexPages.currentPage().getParameters().get('RedirectMsg');
        if (redirectMsg != null) {
            validationMessagesSummary.add(redirectMsg);
        }

        prepareOverrideOptions();

        PageReference result = pfgController.initController();

        if (result == null) {
            result = prepController.initController();
        }

        return result;
    }

    //completed interaction cannot be deleted
    public Boolean getCanDelete() {
        Boolean result = true;
        if (!String.isBlank(callId)) {
            UserRecordAccess userAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), callId);
            if (userAccess != null && !userAccess.HasDeleteAccess) {
                result = false;
            }
            if (result && isCompleted) {
                result = false;
            }
        }
        return result;
    }

    public Boolean getHasEdit() {
        Boolean result = true;
        if (!String.isBlank(callId)) {
            UserRecordAccess userAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), callId);
            if (userAccess != null && !userAccess.HasEditAccess) {
                result = false;
            }

            // Canada users can't edit completed records
            if (result && isCompleted &&
                    (((GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase().contains('CANADA') && !GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase().equals('RCANADA-SFA-SAM')) && !getHasUnsolicitedFieldEditAvailibleCanada && !GNE_SFA2_Util.isCanadaRAMA())
                     || !canEditOnComplete)) {
                result = false;
                canEditRedirectReasonMsg = 'The Interaction is complete and cannot be edited.';
            }
        }
        return result;
    }

    public Boolean getHasSAMProfile() {
        Boolean result = false;
        return GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase().equals('RCANADA-SFA-SAM');
    }

    public Boolean getHasRAMAProfile() {
        return GNE_SFA2_Util.isCanadaRAMA();
    }

    public Boolean isRAMAUser {
        get { return getHasRAMAProfile(); } 
    }

    private Boolean getHasUnsolicitedFieldEditAvailibleCanada {
        get {
            return unsolicitedReqFieldExists && GNE_SFA2_Interaction_Util.getHasUnsolicitedFieldEditAvailibleCanada();
        }
    }

    // Custom Lookup methods
    public String getAccountPlanFilter {
        get {
            String accountId = null;
            try{
                accountId = call.Account_vod__c;
            } catch (Exception ex) {
                System.debug('getAccountPlanFilter: ' + ex);
            }

            if (String.IsNotBlank(accountId)) {
                return 'Active_vod__c = true AND Account_vod__c = \'' + accountId + '\'';
            } else {
                return 'Id = null'; // nothing to show
            }
        }
    }

    public String getAccountTacticDiscussionFilter {
        get {
            String accountPlan = null;
            try{ // Check Account Plan on layout
                accountPlan = call.Account_Plan_vod__c;
            } catch (Exception ex) {
                System.debug('getAccountTacticDiscussionFilter: ' + ex);
            }

            if (String.IsNotBlank(accountPlan)) {
                return 'Account_Plan_vod__c = \'' + accountPlan + '\'';
            } else {
                return 'Id = null'; // nothing to show
            }
        }
    }

    public void postMaterialValue() {
        MaterialWrapper wrapper = materials.get(materialIndex);
        wrapper.callSample.Product_vod__c = String.isNotBlank(materialParam) ? materialParam : null;
    }

    public void postRecipientValue() {
        MaterialWrapper wrapper = materials.get(materialIndex);
        wrapper.callSample.Account_vod__c = String.isNotBlank(recipientParam) ? recipientParam : null;
    }

    public void postActivityValue() {
        DiscussionWrapper wrapper = discussions.get(discussionIndex);
        wrapper.callDiscussion.Activity_gne__c = String.isNotBlank(activityParam) ? activityParam : null;
    }

    public void postCurriculumValue() {
        DiscussionWrapper wrapper = discussions.get(discussionIndex);
        wrapper.callDiscussion.Event_Curriculum_gne__c = String.isNotBlank(curriculumParam) ? curriculumParam : null;
    }

    public void postAccountTacticValue() {
        DiscussionWrapper wrapper = discussions.get(discussionIndex);
        wrapper.callDiscussion.Account_Tactic_vod__c = String.isNotBlank(accountTacticParam) ? accountTacticParam : null;
    }

    public void postProductTacticValue() {
        DiscussionWrapper wrapper = discussions.get(discussionIndex);
        wrapper.callDiscussion.Product_Tactic_vod__c = String.isNotBlank(productTacticParam) ? productTacticParam : null;
    }

    public void postMoleculeValue(){
        DiscussionWrapper wrapper = discussions.get(discussionIndex);
        wrapper.callDiscussion.Molecule_gne__c = String.isNotBlank(moleculeParam) ? moleculeParam : null;
    }

    public void postVisitReasonValue() {
        InteractionDetailWrapper wrapper = interactionDetails.get(interactionDetailIndex);
        wrapper.interactionDetail.Visit_Reason_vod__c = String.isNotBlank(visitReasonParam) ? visitReasonParam : null;
    }

    public void postVisitReasonsValue() {
        InteractionDetailWrapper wrapper;
        if(visitReasonParam == 'Strategic Objective' || visitReasonParam == 'Event/Conference') {
            wrapper = new InteractionDetailWrapper(interactionDetails.size(), visitReasonParam);
        }
        if(wrapper != null) {
            interactionDetails.add(wrapper);
        }
    }

    public void postBrandNameValue() {
        InteractionCategoryWrapper wrapper = interactionCategories.get(brandNameIndex);
        wrapper.interactionCategory.Brand_Name_gne__c = String.isNotBlank(brandNameParam) ? brandNameParam : null;
    }

    public void postTherapeuticAreaValue() {
        InteractionCategoryWrapper wrapper = interactionCategories.get(therapeuticAreaIndex);
        wrapper.interactionCategory.Therapeutic_Area_gne__c = String.isNotBlank(therapeuticAreaParam) ? therapeuticAreaParam : null;
    }

    public void postBrandAndAboveBrandValue() {
        InteractionCategoryWrapper wrapper = interactionCategories.get(brandAndAboveBrandIndex);
        if(brandAndAboveBrandParam == 'Above Brand') {
            wrapper.interactionCategory.Brand_Name_gne__c = null;
            wrapper.interactionCategory.NOC_Status_gne__c = null;
        } else if(brandAndAboveBrandParam == 'Brand') {
            wrapper.interactionCategory.Therapeutic_Area_gne__c = null;
        } else {
            wrapper.interactionCategory.Brand_Name_gne__c = null;
            wrapper.interactionCategory.Therapeutic_Area_gne__c = null;
        }
        wrapper.interactionCategory.Brand_Above_Brand_gne__c = String.isNotBlank(brandAndAboveBrandParam) ? brandAndAboveBrandParam : null;
    }

    public void postNocStatusValue() {
        InteractionCategoryWrapper wrapper = interactionCategories.get(nocStatusIndex);
        if(nocStatusParam == 'Post-NOC' ) {
            wrapper.interactionCategory.Therapeutic_Area_gne__c = null;
        } else if(nocStatusParam == 'Pre-NOC') {
            wrapper.interactionCategory.Brand_Name_gne__c = null;
            wrapper.interactionCategory.Therapeutic_Area_gne__c = null;
        } else if(brandAndAboveBrandParam == 'Above Brand') {
            wrapper.interactionCategory.Brand_Name_gne__c = null;
        }
        wrapper.interactionCategory.NOC_Status_gne__c = String.isNotBlank(nocStatusParam) ? nocStatusParam : null;
    }

    public void refreshDetailsStrategyPicklists() {
        for(InteractionDetailWrapper wrapper : interactionDetails) {
            wrapper.interactionDetail.Group_RAMA_vod__c = groupParam;
        }
    }

    public void setAccountTactics() {
        try {
            if (String.isBlank(call.Account_Plan_vod__c) && discussions != null && discussions.size() > 0) {
                for (DiscussionWrapper discussionWrapper : discussions) {
                    discussionWrapper.callDiscussion.Account_Tactic_vod__c = null;
                }
            }
        } catch (Exception ex) {
            System.debug('setAccountTactics: ' + ex);
        }
    }
    //End of Custom Lookup methods

    // If edit mode and user can't edit record, redirect to view page with proper message
    private PageReference checkOnEdit() {
        Pagereference pr = null;
        if (!getHasEdit() && Apexpages.currentPage().getUrl().containsIgnoreCase('GNE_SFA2_Interaction_Edit_Create')) {
            pr = Page.GNE_SFA2_Interaction_Layout;
            pr.getParameters().put('id', callId);
            if (!String.isBlank(canEditRedirectReasonMsg)) {
                pr.getParameters().put('RedirectMsg', canEditRedirectReasonMsg);
            }
            pr.setRedirect(true);
        }
        return pr;
    }

    private void prepareOverrideOptions() {
        prepareMCLOverrides();
        prepareHcvRccOverrides();
    }

    private void prepareMCLOverrides() {
        isVisitReasonOverriden = false;
        Set<String> profiles = new Set<String> { 'GNE-MEDAFFAIRS-MCL', 'GNE-MEDAFFAIRS-MCL-MANAGER' };
        String userProfileUpperCase = GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase();
        Boolean isMCLUser = profiles.contains(userProfileUpperCase);

        if (isMCLUser) {
            String visitReasonDS = 'Visit_Reason_gne__c#GNE-MedAffairs-MCL';
            GNE_SFA2_Interaction_Overrides__c isettings = GNE_SFA2_Interaction_Overrides__c.getInstance(visitReasonDS);
            if (isettings.Profiles__c != null && isettings.Profiles__c.toUpperCase().contains(userProfileUpperCase)) {
                isVisitReasonOverriden = true;
                primaryReasonControlledFields = new Map<String, List<Selectoption>>();
                primaryReasonControlledFields.put(isettings.Controlled_Field_Value1__c, stringToSelectList(isettings.Field_Value1__c));
                primaryReasonControlledFields.put(isettings.Controlled_Field_Value2__c, stringToSelectList(isettings.Field_Value2__c));
                primaryReasonKeyAll = isettings.Controlled_Field_Value1__c + isettings.Controlled_Field_Value2__c;
                primaryReasonControlledFields.put(primaryReasonKeyAll, stringToSelectList(isettings.Field_Value1__c + ',' + isettings.Field_Value2__c));

                if (callSectionsList != null && callSectionsList.size() > 0) {
                    for (SFA2_Configuration_Object_gne__c section : callSectionsList) {
                        if (section.Name == 'CallDetail') {
                            for (SFA2_Configuration_Object_Detail_gne__c callSection : section.Configuration_Objects__r) {
                                if (!primaryReasonFound && callSection.API_Name_gne__c == 'Primary_Interaction_Reason_gne__c') {
                                    primaryReasonFound = true;
                                }
                                if (!visitReasonFound && callSection.API_Name_gne__c == 'Visit_Reason_gne__c') {
                                    visitReasonFound = true;
                                }
                                if (!visitReasonDescriptionFound && callSection.API_Name_gne__c == 'Visit_Reason_Description_gne__c') {
                                    visitReasonDescriptionFound = true;
                                }
                                if (primaryReasonFound && visitReasonFound && visitReasonDescriptionFound) {
                                    break;
                                }
                            }
                            break;
                        }
                    }
                }
                initVisitReasonOverride = true;
                setPrimaryInteractionReasonOptions();
                setVisitReasonOptions();
                setVisitReasonDescriptionOptions();
                initVisitReasonOverride = false;
            }
        }
    }

    private List<Selectoption> stringToSelectList(String stringValue) {
        List<Selectoption> result = new List<Selectoption>();
        if (String.isNotBlank(stringValue)) {
            List<String> values = stringValue.Split(',');
            for (String value : values) {
                result.add(new Selectoption(value.trim(), value.trim()));
            }
            result.sort();
        }
        return result;
    }

    private void setPrimaryInteractionReasonOptions() {
        List<Selectoption> result = new List<Selectoption>();
        if (!primaryReasonControlledFields.containsKey('--None--')) {
            result.add(new Selectoption('', '--None--'));
        }
        for (String primaryReasonOption : primaryReasonControlledFields.keySet()) {
            if (primaryReasonOption != primaryReasonKeyAll) {
                result.add(new Selectoption(primaryReasonOption, primaryReasonOption));
            }
        }
        primaryInteractionReasonOptions = result;
    }

    public void setVisitReasonOptions() {
        List<Selectoption> result = getNoneValueList();
        visitReasonDescriptionOptions = getNoneValueList();

        if (!initVisitReasonOverride) {
            if (visitReasonFound) {
                call.Visit_Reason_gne__c = null;
            }
            if (visitReasonDescriptionFound) {
                call.Visit_Reason_Description_gne__c = null;
            }
        }

        if (primaryReasonFound) {
            // Get by dependent field (if dependent field is placed at the layout)
            String primaryReasonValue = call.Primary_Interaction_Reason_gne__c;
            if (String.isNotBlank(primaryReasonValue)) {
                result = primaryReasonControlledFields.get(primaryReasonValue);
            }
        } else {
            // Get all values
            result = primaryReasonControlledFields.get(primaryReasonKeyAll);
        }
        visitReasonOptions = result;
    }

    public void setVisitReasonDescriptionOptions() {
        List<Selectoption> result = getNoneValueList();
        if (!initVisitReasonOverride && visitReasonDescriptionFound) {
            call.Visit_Reason_Description_gne__c = null;
        }
        if (visitReasonFound) {
            // Get by dependent field (if dependent field is placed at the layout)
            String visitReasonValue = call.Visit_Reason_gne__c;
            if (visitReasonValue == 'Advice Seeking Meeting') {
                if (visitReasonDescriptionOptionsCache != null) {
                    result = visitReasonDescriptionOptionsCache;
                } else {
                    result.addAll(getVisitReasonDescriptionPickValues());
                    visitReasonDescriptionOptionsCache = result;
                }
            }
        } else {
            // Get all values
            result.addAll(getVisitReasonDescriptionPickValues());
        }
        visitReasonDescriptionOptions = result;
    }

    private List<Selectoption> getVisitReasonDescriptionPickValues() {
        List<Selectoption> result = new List<Selectoption>();
        Schema.DescribeFieldResult fieldResult = Call2_vod__c.Visit_Reason_Description_gne__c.getDescribe();
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.Picklistentry entry : values) {
            if (!entry.getLabel().containsIgnoreCase('--None--')) {
                result.add(new SelectOption(entry.getLabel(), entry.getValue()));
            }
        }
        result.sort();
        return result;
    }

    private List<Selectoption> getNoneValueList() {
        return new List<Selectoption> { new Selectoption('', '--None--') };
    }

    private void prepareHcvRccOverrides() {
        String profile = 'GNE-SFA-HCV-RCC';
        String recordTypeDevName = 'Meeting_Brief_SFA_Pegasys';

        String userProfileUpperCase = GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase();
        isActivityOverriden = (profile == userProfileUpperCase && recordTypeDevName == recordTypeName);

        if (isActivityOverriden) {
            setAvailableActivities();
        }
    }

    private void setAvailableActivities() {
        List<Selectoption> result = new List<Selectoption>();
        String hcvRccActivityValues = '1:1 Training/Deck Update';
        result.add(new Selectoption('', '--None--'));
        result.add(new Selectoption(hcvRccActivityValues, hcvRccActivityValues));
        availableActivities = result;
    }

    // Moved from GlobalUtils.isUserInTerr
    private static Boolean isUserInImmunologyTerr() {
        Boolean result = false;
        String rootTerrName = System.Label.GNE_MedAffairs_Immunology_Terr;
        Map<Id, Territory2> root = new Map<Id, Territory2>([select Id from Territory2 where Name = :rootTerrName]);

        Set<Id> tmpIds = new Set<Id>(root.keySet());
        Set<Id> finalIds = new Set<Id>(root.keySet());

        Map<Id, Territory2> tempMap = new Map<Id, Territory2>([select Id from Territory2 where ParentTerritory2Id IN :tmpIds]);
        while (tempMap != null && tempMap.size() > 0) {
            finalIds.addAll(tempMap.keySet());
            tmpIds.clear();
            tmpIds.addAll(tempMap.keySet());
            tempMap = new Map<Id, Territory2>([select Id from Territory2 where ParentTerritory2Id IN :tmpIds]);
        }

        List<UserTerritory2Association> userAssignment = [select Id, Territory2Id, UserId from UserTerritory2Association where UserId = :UserInfo.getUserId() AND Territory2Id IN : finalIds];
        result = userAssignment != null && userAssignment.size() > 0;

        return result;
    }

    private Boolean getIsMedAffairsProfile() {
        Set<String> profilesMedAffairs = new Set<String> {'GNE-MEDAFFAIRS-MCL', 'GNE-MEDAFFAIRS-MCL-MANAGER',
                'GNE-MEDAFFAIRS-MSL', 'GNE-MEDAFFAIRS-MSL-MANAGER', 'GNE-MEDAFFAIRS-SP', 'GNE-MEDAFFAIRS-SP-MANAGER'
                                                         };
        return profilesMedAffairs.contains(GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase());
    }

    private Boolean getIsMslProfile() {
        Set<String> profilesMSLs = new Set<String> {'GNE-MEDAFFAIRS-MSL', 'GNE-MEDAFFAIRS-MSL-MANAGER'};
        return profilesMSLs.contains(GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase());
    }

    public Boolean getIsFPMProfile(){
        return GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase().contains('FPM');
    }

    public static Boolean getIsBAMProfile(){
        return GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase().contains('GNE-SFA-BAM');
    }

    private static Boolean getIsCCorOCCProfile() {
        String currentUserProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
        return currentUserProfileName.startsWithIgnoreCase('GNE-SFA-CC') || currentUserProfileName.startsWithIgnoreCase('GNE-SFA-OCC');
    }

    public static Boolean getIsCCProfile() {
        return GNE_SFA2_Util.getCurrentUserProfileName().startsWithIgnoreCase('GNE-SFA-CC');
    }

    public Boolean getIsMSLORMCLUser{
        get{ return GNE_SFA2_Interaction_Util.getIsMSLORMCLUser(); }
    }

    public Boolean getCanCloneDiscussions{
        get { return getIsMSLORMCLUser; }
    }

    private void readConfiguration(List<SFA2_Configuration_Object_gne__c> sections) {
        // Exception for MedAffairs users
        Boolean isMedAffairProfile = getIsMedAffairsProfile();
        String apiUnwillingToMeetField = 'Attempted_Visit_HCP_UnwillingToMeet_gne__c';
        Boolean hideUnwillingToMeetField = isMedAffairProfile && !isUserInImmunologyTerr();
        String discussionTopicFieldApiName = String.valueOf(Call2_Discussion_vod__c.Topic_gne__c);
        //End of Exception for MedAffairs users

        // Exception for RCanada MSL and OPS users
        String unsolicitedReqField = String.valueOf(Call2_vod__c.Unsolicited_Request_gne__c);

        callSectionsList = new List<SFA2_Configuration_Object_gne__c>();
        callSectionsMap = new Map<ID, List<SFA2_Configuration_Object_Detail_gne__c>>();
        attendeesAdditionalFields = new List<SFA2_Configuration_Object_Detail_gne__c>();

        for (SFA2_Configuration_Object_gne__c section : sections) {

            if (!callSectionsMap.containsKey(section.id)) {
                callSectionsMap.put(section.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                callSectionsList.add(section);
            }

            if (section.Name == 'CallDetail') {
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                        // Exception for MedAffairs users
                        if (hideUnwillingToMeetField && sectionDetails.API_Name_gne__c.equalsIgnoreCase(apiUnwillingToMeetField)) {
                            sectionDetails.Type_gne__c = GNE_SFA2_DynamicVFLoader.BLANK_SPACE;
                        }
                        if( sectionDetails.API_Name_gne__c.equalsIgnoreCase('HCP_Follow_Up_Opt_In_gne__c') && !callAccount.IsPersonAccount ) {  // hide 'HCP Follow Up' checkbox for HCOs
                            sectionDetails.Type_gne__c = GNE_SFA2_DynamicVFLoader.BLANK_SPACE;
                        }
                        //End of Exception for MedAffairs users

                        if (!mccoCRMController.isMultipleInteraction) {
                            if (sectionDetails.API_Name_gne__c.equalsIgnoreCase('HCP_Account_Meal_Opt_Out_gne__c') && !callAccount.IsPersonAccount) {
                                sectionDetails.Type_gne__c = GNE_SFA2_DynamicVFLoader.BLANK_SPACE;
                            }
                        }
                        if ((sectionDetails.API_Name_gne__c.equalsIgnoreCase('Patient_Education_Materials_gne__c') ||
                                sectionDetails.API_Name_gne__c.equalsIgnoreCase('Protection_Strategy_gne__c')) &&
                                GNE_SFA2_Util.getCurrentUserProfileName().startsWithIgnoreCase('GNE-SFA-Nutropin') &&
                                callAccount.RecordType.DeveloperName != 'Hospital_vod') {
                            sectionDetails.Type_gne__c = 'Field Hidden';
                        }
                        if (sectionDetails.API_Name_gne__c.equalsIgnoreCase(unsolicitedReqField)) {
                            unsolicitedReqFieldExists = true;
                        }
                    }
                }

                canEditOnComplete = String.isBlank(section.Attributes_gne__c) || !section.Attributes_gne__c.containsIgnoreCase('--notEditableOnComplete');
            } else if (section.Name == 'CallDetailInformation') {
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            } else if (section.Name == 'CallObjectives') {
                isDiscussionSectionVisible = true;
                discussionSectionFields = new List<SFA2_Configuration_Object_Detail_gne__c>();
                omitStrategyMode = String.isNotBlank(section.Attributes_gne__c) && section.Attributes_gne__c.contains('--omitStrategy');
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                  if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD && String.isNotBlank(sectionDetails.Attributes_gne__c)){
                    if (sectionDetails.Attributes_gne__c.contains('--hcpOnly') && isHCPAccount == false){
                      continue;
                    }
                  }
                    if ( (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD && !( String.isNotEmpty(sectionDetails.Attributes_gne__c) && sectionDetails.Attributes_gne__c.contains('--callField') ) ) || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                        discussionSectionFields.add(sectionDetails);
                        if (String.isNotBlank(sectionDetails.API_Name_gne__c) && sectionDetails.API_Name_gne__c.equalsIgnoreCase(discussionTopicFieldApiName)){
                            discussionTopicFieldExists = true;
                        }
                    } else if( sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD && String.isNotEmpty(sectionDetails.Attributes_gne__c) && sectionDetails.Attributes_gne__c.contains('--callField') ) {
                        callSectionsMap.get( section.id ).add( sectionDetails );
                        isMBcheckboxes = true;
                    }
                }
            } else if (section.Name == 'CallProducts') {
                isProductDetailsSectionVisible = true;
                //discussionSectionFields = new List<SFA2_Configuration_Object_Detail_gne__c>();
                //for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r){
                //if(sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE){
                // discussionSectionFields.add(sectionDetails);
                //}
            } else if (section.Name == 'CallMaterials') {
                isMaterialsSectionVisible = true;
                materialsSectionFields = new List<SFA2_Configuration_Object_Detail_gne__c>();
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                        materialsSectionFields.add(sectionDetails);
                    }
                }
            } else if (section.Name == 'CallActivities') {
                isActivitiesSectionVisible = true;
                activitiesSectionFields = new List<SFA2_Configuration_Object_Detail_gne__c>();
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                        activitiesSectionFields.add(sectionDetails);
                    }
                }
            } else if (section.Name == 'CallAttachments') {
                isAttachmentsSectionVisible = true;
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            } else if (section.Name == 'CallMealExpense') {
                if (String.isNotEmpty(section.Attributes_gne__c) && section.Attributes_gne__c.contains('--mealOptOut')) {
                    mealOptOutEnabled = true;
                }

                isMealExpensesSectionVisible = true;
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            } else if (section.Name == 'CallAttendees') {
                isAttendeesSectionVisible = true;
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        if (sectionDetails.Attributes_gne__c != null && sectionDetails.Attributes_gne__c.contains('--columnField')) {
                            attendeesAdditionalFields.add(sectionDetails);
                        } else {
                            callSectionsMap.get(section.id).add(sectionDetails);
                            showAttendeeDetailFields = true;
                        }
                    }
                }
            } else if (section.Name == 'CallDetailInformation') {

            } else if (section.Name == 'CallKeyMessages') {
                isKeyMessagesSectionVisible = true;
            } else if (section.Name == 'CallVisitReason') {
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            } else if (section.Name == 'CallInteractionDetail') {
                isInteractionDetailsSectionVisible = true;
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            } else if(section.Name == 'CallAccessEcho') {
                isAccessEchoSectionVisible = true;
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            } else if(section.Name == 'CallCategory') {
                isCategorySectionVisible = true;
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            } else if(section.Name == 'CallNotes') {
                isNotesSectionVisible = true;
                for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                    if (sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BLANK_SPACE) {
                        callSectionsMap.get(section.id).add(sectionDetails);
                    }
                }
            }
        }

        if (callId != null) {
            call = queryCall(callId);
        }
    }

    private void hideFields(List<SFA2_Configuration_Object_gne__c> sections, Set<String> fieldsToHide) {
        for (SFA2_Configuration_Object_gne__c section : sections) {
            for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                if ((sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BUTTON)
                        && (String.isNotBlank(sectionDetails.API_Name_gne__c) && fieldsToHide.contains(sectionDetails.API_Name_gne__c.toUpperCase()))) {
                    sectionDetails.Type_gne__c = 'Field Hidden';
                }
            }
        }
    }

    private void lockFields(List<SFA2_Configuration_Object_gne__c> sections, Set<String> fieldsAvailableForEditing) {
        for (SFA2_Configuration_Object_gne__c section : sections) {
            for (SFA2_Configuration_Object_Detail_gne__c sectionDetails : section.Configuration_Objects__r) {
                if ((sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD || sectionDetails.Type_gne__c == GNE_SFA2_DynamicVFLoader.BUTTON)
                        && (String.isNotBlank(sectionDetails.API_Name_gne__c) && !fieldsAvailableForEditing.contains(sectionDetails.API_Name_gne__c.toUpperCase()))) {
                    sectionDetails.Is_Read_Only_gne__c = true;
                }
            }
        }
    }

    private String getRecordTypeId(GNE_SFA2_User_App_Context_gne__c userApplicationContext) {
        if (callId != null) {
            return [Select recordTypeId from Call2_vod__c where id = :callId].recordTypeId;
        } else {
            List<RecordType> recordTypes = [SELECT id FROM RecordType WHERE DeveloperName = :GNE_SFA2_Util.getDefaultRecordType('Call2_vod__c', userApplicationContext.App_Name_gne__c, userApplicationContext.Brand_gne__c, userApplicationContext.Role_gne__c) AND SobjectType = 'Call2_vod__c'];
            if (!recordTypes.isEmpty()) {
                return recordTypes.get(0).id;
            }
        }
        return '';
    }

    private String getRecordTypeName(GNE_SFA2_User_App_Context_gne__c userApplicationContext, Id callId) {
        return [Select recordType.DeveloperName from Call2_vod__c where id = :callId].recordType.DeveloperName;
    }


    public static List<SelectOption>createTimeOptions() {
        List<SelectOption>timeOptions = new List<SelectOption>();
        for (Integer i = 0; i < 48; i++) {
            Integer minutesToAdd = i * 30;
            Integer hourToAdd = Math.mod(minutesToAdd / 60, 24);
            /* string representation if a Time value with formating */
            Datetime temp = Datetime.newInstance(1970, 1, 1, 7 + hourToAdd, Math.mod(minutesToAdd, 60), 0);
            String sTime = temp.format('hh:mm a');
            timeOptions.add(new SelectOption(sTime, sTime));
        }
        return timeOptions;
    }

    public static List<SelectOption> getAvailableProducts(Id userId) {
        List<SelectOption>availableProducts = new List<SelectOption>();
        for (My_Setup_Products_vod__c prod : [SELECT Product_vod__c, Product_vod__r.Name, Product_vod__r.Product_Type_vod__c FROM My_Setup_Products_vod__c WHERE ownerId = :userId order by Product_vod__r.Name]) {
            if (prod.Product_vod__c != null && String.isNotEmpty(prod.Product_vod__r.Name)) {
                availableProducts.add(new SelectOption(prod.Product_vod__c, prod.Product_vod__r.Name));
            }
        }
        return availableProducts;
    }

    private String getProductName(String productId) {
        for (SelectOption option : availableProducts) {
            if (option.getValue() == productId) {
                return option.getLabel();
            }
        }
        return '';
    }

    public void removeAttendee() {
        if (call.Completed_gne__c && isFrmUser()) {
            AttendeeWrapper wrapper = attendees.get(attendeeIndex);
            if (String.isNotEmpty(wrapper.attendee.Id)) {
                validationMessagesSummary.add(Label.GNE_SFA2_ErrMsg_Cannot_Delete_Completed_Child_Interaction);
                return;
            }
        }

        AttendeeWrapper selectedAttendee = attendees.get(attendeeIndex);

        Id selectedId;
        if (selectedAttendee.attendee.Account_vod__c != null) {
            selectedId = selectedAttendee.attendee.Account_vod__c;
        } else if (selectedAttendee.attendee.Contact_vod__c != null) {
            selectedId = selectedAttendee.attendee.Contact_vod__c;
        } else if (selectedAttendee.attendee.User_vod__c != null) {
            selectedId = selectedAttendee.attendee.User_vod__c;
        } else if (selectedAttendee.attendee.EMS_International_Speaker_gne__c != null) {
            selectedId = selectedAttendee.attendee.EMS_International_Speaker_gne__c;
        }
        AttendeeWrapper wrapper = attendees.remove(attendeeIndex);
        //fix indexes for wrappers
        for (Integer i = attendeeIndex; i < attendees.size(); i++) {
            attendees.get(i).index = i;
        }
        //selectedAccounts.clear();
        //clear selection for checkboxes
        Integer selectIndexToRemove = -1;
        for (Integer i = 0; i < selectedAccounts.size(); i++) {
            if (selectedAccounts.get(i) == wrapper.attendee.Account_vod__c || selectedAccounts.get(i) == wrapper.attendee.Contact_vod__c || selectedAccounts.get(i) == wrapper.attendee.User_vod__c) {
                selectIndexToRemove = i;
            }
        }
        if (selectIndexToRemove > -1) {
            selectedAccounts.remove(selectIndexToRemove);
        }
        //remove attendes from call
        if (wrapper.attendee.Id != null) {
            attendeesToRemove.add(wrapper.attendee);
        }
        recipients = getRecipients(attendees);
    }

    public void moveDiscussionHigher() {
        DiscussionWrapper wrapper = discussions.remove(discussionIndex);
        discussions.add(discussionIndex - 1, wrapper);
        for (Integer i = 0; i < discussions.size(); i++) {
            discussions.get(i).index = i;
        }
        system.debug('discussions: ' + discussions);
    }

    public void removeDiscussion() {
        system.debug('removeDiscussion discussionIndex: ' + discussionIndex);
        DiscussionWrapper wrapper = discussions.remove(discussionIndex);
        system.debug('removeDiscussion wrapper: ' + wrapper);
        if (wrapper.callDiscussion.Id != null) {
            discussionsToRemove.add(wrapper.callDiscussion);
        }
        for (Integer i = discussionIndex; i < discussions.size(); i++) {
            discussions.get(i).index = i;
        }
    }

    public void cloneDiscussion() {
        DiscussionWrapper wrapper = discussions.get(discussionIndex).cloneWrapper();
        discussions.add(wrapper);
        for (Integer i = discussionIndex; i < discussions.size(); i++) {
            discussions.get(i).index = i;
        }
    }

    public void moveCallProductHigher() {
        ProductDetailWrapper wrapper = callProducts.remove(callProductIndex);
        callProducts.add(callProductIndex - 1, wrapper);
        for (Integer i = 0; i < callProducts.size(); i++) {
            callProducts.get(i).index = i;
        }
        system.debug(callProducts);
    }

    public void removeMaterial() {
        MaterialWrapper wrapper = materials.remove(materialIndex);
        if (wrapper.callSample.Id != null) {
            materialsToRemove.add(wrapper.callSample);
        }
        for (Integer i = materialIndex; i < materials.size(); i++) {
            materials.get(i).index = i;
        }
    }

    public void removeActivity() {
        ActivityWrapper wrapper = activities.remove(activityIndex);
        if (wrapper.task.Id != null) {
            activitiesToRemove.add(wrapper.task);
        }
        for (Integer i = activityIndex; i < activities.size(); i++) {
            activities.get(i).index = i;
        }
    }

    public void removeAttachment() {
        AttachmentWrapper wrapper = attachments.remove(attachmentIndex);
        if (wrapper.attachment.Id != null) {
            attachmentsToRemove.add(wrapper.attachment);
        }
        for (Integer i = attachmentIndex; i < attachments.size(); i++) {
            attachments.get(i).index = i;
        }
    }

    public void removeInteractionDetail() {
        InteractionDetailWrapper wrapper = interactionDetails.remove(interactionDetailIndex);
        if (wrapper.interactionDetail.Id != null) {
            interactionDetailsToRemove.add(wrapper.interactionDetail);
        }
        for (Integer i = interactionDetailIndex; i < interactionDetails.size(); i++) {
            interactionDetails.get(i).index = i;
        }
    }

    public void removeInteractionCategory() {
        InteractionCategoryWrapper wrapper = interactionCategories.remove(interactionCategoryIndex);
        if(wrapper.interactionCategory.Id != null) {
            interactionCategoriesToRemove.add(wrapper.interactionCategory);
        }
        for(Integer i = interactionCategoryIndex; i < interactionCategories.size(); i++) {
            interactionCategories.get(i).index = i;
        }
    }

    private List<SelectOption>getCallFollowupTemplates() {
        List<SelectOption> result = new List<SelectOption>();
        for (Call_Followup_Template_vod__c template : [SELECT id, Name FROM Call_Followup_Template_vod__c]) {
            result.add(new SelectOption(template.Name, template.Name));
        }
        return result;
    }

    public List<SelectOption> getAvailableMaterials(Id userId) {
        List<SelectOption> availableProducts = new List<SelectOption>();
        availableProducts.add(new SelectOption('', '--None--'));

        if (dependentMaterialsEnabled == true && (selectedProducts == null || selectedProducts.isEmpty())){
          return availableProducts;
        }

        String productType = '';
        //materials should be unique they are compared by name - SFA-438
        Set<String> materialsName = new Set<String>();

        List<Product_vod__c> userProducts = GNE_SFA2_Util.getUserSetupProducts(userId, dependentMaterialsEnabled == true ? 'Id In :selectedProducts' : '');
        for (Product_vod__c prod : [SELECT Id, Name, Product_Type_vod__c, Parent_Product_vod__c FROM Product_vod__c WHERE active__c = true and Parent_Product_vod__c in :userProducts AND Product_Type_vod__c NOT IN ('Detail', 'Market', 'Sample', 'PFG') ORDER BY Product_Type_vod__c, Name]){
          String materialKey = ((dependentMaterialsEnabled == true && String.isNotBlank(prod.Parent_Product_vod__c) ? String.valueOf(prod.Parent_Product_vod__c) : '') + prod.Product_Type_vod__c + '_' + prod.Name).toUpperCase();
            if (materialsName.add(materialKey)){
            if (productType != prod.Product_Type_vod__c) {
                  availableProducts.add(new SelectOption('', '--' + prod.Product_Type_vod__c + '--', true));
                    productType = prod.Product_Type_vod__c;
                }
                availableProducts.add(new SelectOption(prod.Id, prod.Name));
            }
        }
        return availableProducts;
    }

    public void refreshAvailableMaterials() {
        if (isMaterialsSectionVisible == true && dependentMaterialsEnabled == true) {
            availableMaterials = getAvailableMaterials(UserInfo.getUserId());
        }
    }

    public void initStrategies() {
        if (discussionIndex != null && discussionIndex >= 0 && discussionIndex < discussions.size()) {
            DiscussionWrapper wrapper = discussions.get(discussionIndex);
            if (String.isNotEmpty(productParam)) {
                wrapper.callDiscussion.Product_vod__c = productParam;
                wrapper.callDiscussion.zvod_Product_Map_vod__c = getProductName(productParam);
            } else {
                wrapper.callDiscussion.Product_vod__c = null;
                wrapper.callDiscussion.zvod_Product_Map_vod__c = '';
            }
            wrapper.setDefaultTopicValue(discussionTopicFieldExists);

            if(omitStrategyMode==true) {
                wrapper.tactics = getTactics(wrapper.callDiscussion);
            } else {
                wrapper.strategies = getStrategies(wrapper.callDiscussion);
                wrapper.tactics = new List<SelectOption> {new SelectOption('', '--None--')};
            }
        }
    }

    public void initTactics() {
        if (discussionIndex != null && discussionIndex >= 0 && discussionIndex < discussions.size()) {
            DiscussionWrapper wrapper = discussions.get(discussionIndex);
            if (String.isNotEmpty(strategyParam)) {
                wrapper.callDiscussion.Product_Strategy_vod__c = strategyParam;
            } else {
                wrapper.callDiscussion.Product_Strategy_vod__c = null;
            }
            wrapper.tactics = getTactics(wrapper.callDiscussion);
            system.debug('discussionIndex: ' + discussionIndex + '; wrapper.callDiscussion: ' + wrapper.callDiscussion + '; wrapper.tactics: ' + wrapper.tactics + '; call.Product_Strategy_vod__c: ' + wrapper.callDiscussion.Product_Strategy_vod__c);
        }
    }

    public Pagereference saveInProgress() {
        SavePoint savePoint = Database.setSavepoint();
        if (!mccoCRMController.isMultipleInteraction) {
            try {
                PageReference savePR = save();
                if (call.Completed_gne__c) { //edited completed interaction
                    FRM_ASMI_Integration_Manager frmAsmiIntegration = new FRM_ASMI_Integration_Manager(call, discussions);
                    if (frmAsmiIntegration.shouldCreateMarketInsigts()) {
                        frmAsmiIntegration.createMarketInsigts();
                        savePR.getParameters().put('asmiCreated', 'true');
                    }
                }
                return savePR;
            } catch (GNE_SFA2_Exception e1) {
                Database.rollback ( savePoint );
                return null;
            } catch (Exception e) {
                validationMessagesSummary.add(e.getMessage());
                Database.rollback ( savePoint );
                return null;
            }
        } else {
            try {
                return saveMulitpleAccounts();
            } catch (Exception e) {
                validationMessagesSummary.add(e.getMessage());
                return null;
            }
        }
    }

    public PageReference saveAndComplete() {
        call.Completed_gne__c = true;
        call.Date_Completed_gne__c = Date.today();
        SavePoint savePoint = Database.setSavepoint();
        if (!mccoCRMController.isMultipleInteraction) {
            try {
                PageReference savePR = save();
                FRM_ASMI_Integration_Manager frmAsmiIntegration = new FRM_ASMI_Integration_Manager(call, discussions);
                if (frmAsmiIntegration.shouldCreateMarketInsigts()) {
                    frmAsmiIntegration.createMarketInsigts();
                    savePR.getParameters().put('asmiCreated', 'true');
                }
                return savePR;
            } catch (GNE_SFA2_Exception e1) {
                call.Completed_gne__c = false;
                call.Date_Completed_gne__c = null;
                Database.rollback ( savePoint );
                return null;
            } catch (Exception e) {
                call.Completed_gne__c = false;
                call.Date_Completed_gne__c = null;

                validationMessagesSummary.add(formatErrorMessage(e.getMessage()));
                Database.rollback ( savePoint );
                return null;
            }
        } else {
            try {
                return saveMulitpleAccounts();
            } catch (Exception e) {
                call.Completed_gne__c = false;
                call.Date_Completed_gne__c = null;
                validationMessagesSummary.add(e.getMessage());
                return null;
            }
        }
    }

    private PageReference save() {
        GNE_SFA2_Interaction_Trigger_Helper.setIsSfdcUiRequest(true);
        Map<Id, Call2_vod__c> accountToCall = new Map<Id, Call2_vod__c>();
        Map<Id, Call2_vod__c> ihcpToCall = new Map<Id, Call2_vod__c>();

        call.HCP_OR_Attendee_Meal_Opt_Out_gne__c = false;

        if (call.HCP_Account_Meal_Opt_Out_gne__c) {
            call.HCP_OR_Attendee_Meal_Opt_Out_gne__c = true;
        } else {
            for (AttendeeWrapper wrapper : attendees) {
                if (wrapper.attendee.HCP_Attendee_Meal_Opt_Out_gne__c) {
                    call.HCP_OR_Attendee_Meal_Opt_Out_gne__c = true;
                }
            }
        }

        validationMessagesSummary.clear();
        List<ApexPages.Message> validationMessages = validate();
        if (!validationMessages.isEmpty()) {
            for (ApexPages.Message m : validationMessages) {
                this.validationMessagesSummary.add(m.getSummary());
            }
            throw new GNE_SFA2_Exception('Validation exception');
        } else {
            if (isUsingDatetime) {
                call.Call_Datetime_vod__c = DateTime.parse(callDate + ' ' + callTime);
            } else {
                call.Call_Date_vod__c = Date.parse(callDate);
            }

            if (isCallInsert) {
                call.id = null;
            }

            accountToCall.put(call.Account_vod__c, call);
            // SFDC-2924: Interaction create and update Attendee count is set 0.00 instead of real count
            call.Attendees_vod__c = attendees != null ?  attendees.size() : 0;
            //if account is person account or ihcp, count it as attendee
            if (call.Account_vod__c != null && [select isPersonAccount from Account where id = :call.Account_vod__c].isPersonAccount) {
                call.Attendee_Type_vod__c = 'Person_Account_vod';
                call.Attendees_vod__c += 1;
            } else if(call.EMS_International_Speaker_gne__c != null) {
                call.Attendee_Type_vod__c = 'iHCP_Account_vod';
                call.Attendees_vod__c += 1;
            } else {
                call.Attendee_Type_vod__c = 'Group_Account_vod';
            }

            call.Detailed_Products_vod__c = '';
            if (isDiscussionSectionVisible) {
                for (DiscussionWrapper wrapper : discussions) {
                    call.Detailed_Products_vod__c += getProductName(wrapper.callDiscussion.Product_vod__c) + '  ';
                }
            } else if (isProductDetailsSectionVisible) {
                for (ProductDetailWrapper wrapper : callProducts) {
                    call.Detailed_Products_vod__c += getProductName(wrapper.callDetail.Product_vod__c) + '  ';
                }
            }
            call.Detailed_Products_vod__c.trim();
            Integer sizeLimit = Math.min(call.Detailed_Products_vod__c.length(), 253);
            call.Detailed_Products_vod__c = call.Detailed_Products_vod__c.substring(0, sizeLimit);

            Address_vod__c callAddress = getAddress(call.Parent_Address_vod__c);
            if (callAddress != null) {
                call.Address_vod__c =  GNE_SFA2_Util.getAddressAsString(callAddress);
                call.Address_Line_1_vod__c = callAddress.Name;
                call.Address_line_2_vod__c = callAddress.Address_line_2_vod__c;
                call.Zip_4_vod__c = callAddress.Zip_4_vod__c;
                call.Zip_vod__c = callAddress.Zip_vod__c;
                call.City_vod__c = callAddress.City_vod__c;
                call.State_vod__c = callAddress.State_vod__c;

                if (!isCompleted) {
                    call.PFG_BDTD_gne__c = callAddress.PFG_BDTD_gne__c;
                }
            }

            upsert call;
            system.debug(call);

            //update discussions
            List<Call2_Discussion_vod__c>callDiscussions = new List<Call2_Discussion_vod__c>();
            List<Call2_Detail_vod__c>callDetails = new List<Call2_Detail_vod__c>();

            if (isDiscussionSectionVisible) {
                Map<Id, Call2_Detail_vod__c>productToCallDetailMap = new Map<Id, Call2_Detail_vod__c>();

                List<Id>productIds = new List<Id>();
                for (DiscussionWrapper wrapper : discussions) {
                    if (isCallInsert) {
                        wrapper.callDiscussion.id = null;
                    }
                    wrapper.callDiscussion.Detail_Priority_gne__c = wrapper.index;
                    callDiscussions.add(wrapper.callDiscussion);

                    if (wrapper.callDiscussion.id == null) {
                        wrapper.callDiscussion.Call2_vod__c = call.id;
                    }
                    //call details
                    if (String.isNotEmpty(wrapper.callDiscussion.Product_vod__c)) {
                        Boolean contains = false;
                        for (Integer i = 0; i < productIds.size(); i++) {
                            if (productIds.get(i) == wrapper.callDiscussion.Product_vod__c) {
                                contains = true;
                            }
                        }
                        if (!contains) {
                            productIds.add(wrapper.callDiscussion.Product_vod__c);
                        }
                    }

                    if(userProfile != null && userProfile.contains('GNE-TLS') && (wrapper.callDiscussion.Event_gne__c ||
                        (!wrapper.callDiscussion.Event_gne__c && !wrapper.callDiscussion.Speaker_Training_gne__c))) {
                        wrapper.callDiscussion.Event_Curriculum_gne__c = null;
                    }

                    if(userProfile != null && userProfile.contains('GNE-TLS') && wrapper.callDiscussion.Speaker_Training_gne__c) {
                        wrapper.callDiscussion.Observation_gne__c = null;
                    }

                    if(userProfile != null && userProfile.contains('GNE-SFA-PREP')) {
                        if (wrapper.callDiscussion.Speaker_Training_gne__c) {
                            wrapper.callDiscussion.Activity_gne__c = '1:1 Training/Deck Update';
                        } else {
                            wrapper.callDiscussion.Event_Curriculum_gne__c = null;
                            wrapper.callDiscussion.Activity_gne__c = null;
                        }
                    }

                }
                if (!productIds.isEmpty()) {
                    for (Call2_Detail_vod__c callDetail : [Select id, Product_vod__c, Detail_Priority_vod__c From Call2_Detail_vod__c where Call2_vod__c = :call.id and Product_vod__c in :productIds]) {
                        productToCallDetailMap.put(callDetail.Product_vod__c, callDetail);
                    }
                    for (Integer i = 0; i < productIds.size(); i++) {
                        Id productId = productIds.get(i);
                        Call2_Detail_vod__c callDetail = productToCallDetailMap.get(productId);
                        if (callDetail == null) {
                            callDetail = new Call2_Detail_vod__c(Call2_vod__c = call.id, Product_vod__c = productId, Type_vod__c = 'Paper_Detail_vod');
                            productToCallDetailMap.put(productId, callDetail);
                        } else  if (isCallInsert) {
                            callDetail.id = null;
                        }
                        callDetail.Detail_Priority_vod__c = i + 1;
                    }
                }
                if (!productToCallDetailMap.isEmpty()) {
                    callDetails.addAll(productToCallDetailMap.values());
                    upsert productToCallDetailMap.values();
                }
                if (!callDiscussions.isEmpty()) {
                    upsert callDiscussions;
                }

                //only call details with call discussion should exists
                for (Call2_Detail_vod__c detail : [Select id, Product_vod__c, Detail_Priority_vod__c From Call2_Detail_vod__c where Call2_vod__c = :call.id and Product_vod__c NOT IN :productIds]) {
                    boolean contains = false;
                    for (Call2_Detail_vod__c d : productDetailsToRemove) {
                        if (detail.id == d.id) {
                            contains = true;
                        }
                    }
                    if (!contains) {
                        productDetailsToRemove.add(detail);
                    }
                }
            }

            //update keyMessages
            List<Call2_Key_Message_vod__c>callKeyMessages = new List<Call2_Key_Message_vod__c>();
            for (KeyMessageWrapper wrapper : keyMessages) {
                if (String.isNotEmpty(wrapper.keyMessageId)) {
                    callKeyMessages.add(new Call2_Key_Message_vod__c(Id = wrapper.callKeyMessageId, Call2_vod__c = call.id, Reaction_vod__c = wrapper.reaction, Product_vod__c = wrapper.productId, Key_Message_vod__c = wrapper.keyMessageId));
                }
            }
            if (!callKeyMessages.isEmpty()) {
                upsert callKeyMessages;
            }


            //update details
            if (isProductDetailsSectionVisible) {
                Integer i = 0;
                for (ProductDetailWrapper wrapper : callProducts) {
                    wrapper.callDetail.Detail_Priority_vod__c = ++i;
                    if (wrapper.callDetail.id == null) {
                        wrapper.callDetail.Call2_vod__c = call.id;
                    }
                    callDetails.add(wrapper.callDetail);
                }
                if (!callDetails.isEmpty()) {
                    upsert callDetails;
                }
            }

            //update attachments
            List<Attachment>attachmentsTmp = new List<Attachment>();
            for (AttachmentWrapper wrapper : attachments) {
                if (wrapper.attachment != null && wrapper.attachment.Id == null && wrapper.attachment.Body != null) {
                    attachmentsTmp.add(wrapper.attachment);
                    wrapper.attachment.ParentId = call.id;
                    wrapper.attachment.ownerId = UserInfo.getUserId();
                }
            }

            //update attendees
            Call2_vod__c parent = queryCall(call.id);
            List<Call2_vod__c>attendeesCalls = createAttendeeCallsObjects(parent, callDetails, callDiscussions, callKeyMessages);
            for (Call2_vod__c c : attendeesCalls) {
                    accountToCall.put(c.Account_vod__c, c);
            }

            //update materials
            List<Call2_Sample_vod__c>callMaterials = new List<Call2_Sample_vod__c>();
            for (MaterialWrapper wrapper : materials) {
                if (wrapper.callSample.id == null) {
                        wrapper.callSample.Call2_vod__c = accountToCall.get(wrapper.callSample.Account_vod__c).Id;
                    //if recipient has changed we need to create new sample
                } else if (wrapper.callSample.Call2_vod__c != accountToCall.get(wrapper.callSample.Account_vod__c).Id) {
                    materialsToRemove.add(wrapper.callSample);
                        wrapper.callSample = new Call2_Sample_vod__c(Call2_vod__c = accountToCall.get(wrapper.callSample.Account_vod__c).Id, Quantity_vod__c = wrapper.callSample.Quantity_vod__c, Product_vod__c = wrapper.callSample.Product_vod__c, Account_vod__c = wrapper.callSample.Account_vod__c);
                    }
                callMaterials.add(wrapper.callSample);
            }
            if (!callMaterials.isEmpty()) {
                upsert callMaterials;
            }

            //update activities
            List<Task>tasksTmp = new List<Task>();
            for (ActivityWrapper wrapper : activities) {
                tasksTmp.add(wrapper.task);
                List<Contact>contacts = [Select id from Contact where accountId = :wrapper.task.AccountId];
                if (contacts.size() > 0) {
                    wrapper.task.WhoId = contacts.get(0).id;
                }
                wrapper.task.Account_ID_gne__c = wrapper.task.AccountId;
                if (wrapper.task.Id == null) {
                    wrapper.task.WhatId = call.id;
                }
                wrapper.task.activityDate = Date.parse(wrapper.activityDate);
            }

            //update interaction details
            if (isInteractionDetailsSectionVisible) {
                List<Call2_Interaction_Detail_vod__c> callInteractionDetails = new List<Call2_Interaction_Detail_vod__c>();
                Integer i = 0;
                for (InteractionDetailWrapper wrapper : interactionDetails) {

                    if (wrapper.interactionDetail.id == null) {
                        wrapper.interactionDetail.Call2_vod__c = call.id;
                    }
                    callInteractionDetails.add(wrapper.interactionDetail);
                }
                if (!callInteractionDetails.isEmpty()) {
                    upsert callInteractionDetails;
                }
            }

            //upsert interaction categories
            if(isCategorySectionVisible) {
                List<Call2_Category_vod__c> callCategories = new List<Call2_Category_vod__c>();
                Integer i = 0;
                for(InteractionCategoryWrapper wrapper : interactionCategories) {
                    if(wrapper.interactionCategory.Id == null) {
                        wrapper.interactionCategory.Call2_vod__c = call.Id;
                    }
                    callCategories.add(wrapper.interactionCategory);
                }
                if(!callCategories.isEmpty()) {
                    upsert callCategories;
                }
            }

            if (!tasksTmp.isEmpty()) {
                upsert tasksTmp;
            }

            if (!attachmentsTmp.isEmpty()) {
                insert attachmentsTmp;
            }

            if (!materialsToRemove.isEmpty()) {
                delete materialsToRemove;
            }

            if (!attendeesToRemove.isEmpty()) {
                GNE_SFA2_Interaction_Trigger_Helper.setIsAllowDeleteAttendeeMode(!isFrmUser());
                delete attendeesToRemove;
            }
            if (!activitiesToRemove.isEmpty()) {
                delete activitiesToRemove;
            }
            if (!discussionsToRemove.isEmpty()) {
                delete discussionsToRemove;
            }

            if (!attachmentsToRemove.isEmpty()) {
                delete attachmentsToRemove;
            }
            if (!productDetailsToRemove.isEmpty()) {
                delete productDetailsToRemove;
            }

            if(!interactionDetailsToRemove.isEmpty()) {
                delete interactionDetailsToRemove;
            }

            if(!interactionCategoriesToRemove.isEmpty()) {
                delete interactionCategoriesToRemove;
            }

            List<Attachment> attachmentsToDelete = new List<Attachment>();
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            attachmentsToDelete = [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId = : tempAttachmentParentId AND Description = : temporaryCallId];

            if (!attachmentsToDelete.isEmpty()) {
                for (Attachment attach : attachmentsToDelete) {
                    Attachment newAttach = new Attachment();
                    newAttach.Name = attach.Name;
                    newAttach.Body = attach.Body;
                    newAttach.ContentType = attach.ContentType;
                    newAttach.ParentId = call.Id;
                    attachmentsToInsert.add(newAttach);
                }
            }

            if (!attachmentsToInsert.isEmpty()) {
                insert attachmentsToInsert;
            }
            if (!attachmentsToDelete.isEmpty()) {
                delete attachmentsToDelete;
            }

            PageReference pr = pfgController.save();
            referralInteractionController.save();

            if (pr == null) {
                pr = prepController.save();
            }

            if (pr == null) {
                String retUrl = ApexPages.currentPage().getParameters().get('retURL');
                if (String.isNotBlank(retUrl)) {
                    pr = new PageReference(retUrl);
                }
                else if (userApplicationContext.App_Name_gne__c == 'MCCO') {
                    pr = Page.GNE_SFA2_Interaction_Layout;
                    pr.getParameters().put('id', call.Id);
                }
                else {
                    pr = Page.GNE_SFA2_Account_Layout;
                    pr.getParameters().put('id', call.Account_vod__c);
                }
                pr.setRedirect(true);
            }
            return pr;
        }
    }

    private String formatErrorMessage(String errorMessage) {
        String formattedMessage = errorMessage.substringAfter('[Interaction Information]: ');
        if(!String.isBlank(formattedMessage))
            formattedMessage = formattedMessage.substringBefore(': [Completed_gne__c]');
        return formattedMessage;
    }

    private PageReference saveMulitpleAccounts() {
        Map<Id, Call2_vod__c> accountToCall = new Map<Id, Call2_vod__c>();
        List<Call2_vod__c> callsToInsert = new List<Call2_vod__c>();
        Map<Id,Id> contactsAccountMap = new Map<Id,Id>();

        for (Integer z = 0; z < mccoCRMController.multipleAccountList.size(); z++) {
            Call2_vod__c newCall = new Call2_vod__c();
            newCall = call.clone();
            callAccount = mccoCRMController.multipleAccountList.get(z).account;

            call.HCP_OR_Attendee_Meal_Opt_Out_gne__c = false;
            newCall.Account_vod__c = mccoCRMController.multipleAccountList.get(z).account.Id;
            for (Id contactId : mccoCRMController.getSelectedAttendees(newCall.Account_vod__c)) {
                attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Contact_vod__c = contactId, Attendee_Type_vod__c = 'Contact_vod')));
                contactsAccountMap.put(contactId,newCall.Account_vod__c);
            }

            if (newCall.HCP_Account_Meal_Opt_Out_gne__c) {
                newCall.HCP_OR_Attendee_Meal_Opt_Out_gne__c = true;
            } else {
                for (AttendeeWrapper wrapper : attendees) {
                    if (wrapper.attendee.HCP_Attendee_Meal_Opt_Out_gne__c) {
                        newCall.HCP_OR_Attendee_Meal_Opt_Out_gne__c = true;
                    }
                }
            }

            List<ApexPages.Message> validationMessages = new List<ApexPages.Message>();

            if (z == 0) {
                validationMessages = validate();
            }

            if (!validationMessages.isEmpty()) {
                for (ApexPages.Message m : validationMessages) {
                    this.validationMessagesSummary.add(m.getSummary());
                }
                throw new GNE_SFA2_Exception('Validation exception');
                break;
            } else {
                if (isUsingDatetime) {
                    newCall.Call_Datetime_vod__c = DateTime.parse(callDate + ' ' + callTime);
                } else {
                    newCall.Call_Date_vod__c = Date.parse(callDate);
                }

                if (isCallInsert) {
                    newCall.id = null;
                }

                accountToCall.put(newCall.Account_vod__c, newCall);
                newCall.Attendees_vod__c = attendees != null ?  attendees.size() : 0;
                if (newCall.Account_vod__c != null &&  [select isPersonAccount from Account where id = :newCall.Account_vod__c].isPersonAccount) {
                    newCall.Attendee_Type_vod__c = 'Person_Account_vod';
                    newCall.Attendees_vod__c += 1;
                } else {
                    newCall.Attendee_Type_vod__c = 'Group_Account_vod';
                }

                newCall.Detailed_Products_vod__c = '';
                if (isDiscussionSectionVisible) {
                    for (DiscussionWrapper wrapper : discussions) {
                        newCall.Detailed_Products_vod__c += getProductName(wrapper.callDiscussion.Product_vod__c) + '  ';
                    }
                } else if (isProductDetailsSectionVisible) {
                    for (ProductDetailWrapper wrapper : callProducts) {
                        newCall.Detailed_Products_vod__c += getProductName(wrapper.callDetail.Product_vod__c) + '  ';
                    }
                }
                newCall.Detailed_Products_vod__c.trim();
                Integer sizeLimit = Math.min(newCall.Detailed_Products_vod__c.length(), 253);
                newCall.Detailed_Products_vod__c = newCall.Detailed_Products_vod__c.substring(0, sizeLimit);
                Address_vod__c callAddress = getAddress(mccoCRMController.multipleAccountList.get(z).selectedAddress);
                if (callAddress != null) {
                    newCall.Address_vod__c =  GNE_SFA2_Util.getAddressAsString(callAddress);
                    newCall.Address_Line_1_vod__c = callAddress.Name;
                    newCall.Address_line_2_vod__c = callAddress.Address_line_2_vod__c;
                    newCall.Zip_4_vod__c = callAddress.Zip_4_vod__c;
                    newCall.Zip_vod__c = callAddress.Zip_vod__c;
                    newCall.City_vod__c = callAddress.City_vod__c;
                    newCall.State_vod__c = callAddress.State_vod__c;

                    if (!isCompleted) {
                        newCall.PFG_BDTD_gne__c = callAddress.PFG_BDTD_gne__c;
                    }
                }

                callsToInsert.add(newCall);
            }
        }

        insert callsToInsert;

        //update discussions
        List<Call2_Discussion_vod__c> callDiscussions = new List<Call2_Discussion_vod__c>();
        List<Call2_Detail_vod__c> callDetails = new List<Call2_Detail_vod__c>();

        if (isDiscussionSectionVisible) {
            Map<Id, Call2_Detail_vod__c>productToCallDetailMap = new Map<Id, Call2_Detail_vod__c>();
            List<Id>productIds = new List<Id>();
            for (Call2_vod__c insCall : callsToInsert) {
                for (DiscussionWrapper wrapper : discussions) {
                    wrapper.callDiscussion.Detail_Priority_gne__c = wrapper.index;
                    wrapper.callDiscussion.Call2_vod__c = insCall.id;
                    callDiscussions.add(wrapper.callDiscussion.clone());
                    //call details
                    if (String.isNotEmpty(wrapper.callDiscussion.Product_vod__c)) {
                        Boolean contains = false;
                        for (Integer i = 0; i < productIds.size(); i++) {
                            if (productIds.get(i) == wrapper.callDiscussion.Product_vod__c) {
                                contains = true;
                            }
                        }
                        if (!contains) {
                            productIds.add(wrapper.callDiscussion.Product_vod__c);
                        }
                    }

                }
                if (!productIds.isEmpty()) {
                    for (Integer i = 0; i < productIds.size(); i++) {
                        Id productId = productIds.get(i);
                        Call2_Detail_vod__c callDetail = new Call2_Detail_vod__c(Call2_vod__c = insCall.id, Product_vod__c = productId, Type_vod__c = 'Paper_Detail_vod');
                        productToCallDetailMap.put(productId, callDetail);
                        callDetail.Detail_Priority_vod__c = i + 1;
                    }
                }
            }
            if (!productToCallDetailMap.isEmpty()) {
                callDetails.addAll(productToCallDetailMap.values());
                insert productToCallDetailMap.values();
            }
            if (!callDiscussions.isEmpty()) {
                insert callDiscussions;
            }


        }

        //update keyMessages
        List<Call2_Key_Message_vod__c>callKeyMessages = new List<Call2_Key_Message_vod__c>();
        for (Call2_vod__c insCall : callsToInsert) {
            for (KeyMessageWrapper wrapper : keyMessages) {
                if (String.isNotEmpty(wrapper.keyMessageId)) {
                    callKeyMessages.add(new Call2_Key_Message_vod__c(Id = wrapper.callKeyMessageId, Call2_vod__c = insCall.id, Reaction_vod__c = wrapper.reaction, Product_vod__c = wrapper.productId, Key_Message_vod__c = wrapper.keyMessageId));
                }
            }
        }
        if (!callKeyMessages.isEmpty()) {
            insert callKeyMessages;
        }

        if (isProductDetailsSectionVisible) {
            Integer i = 0;
            for (Call2_vod__c insCall : callsToInsert) {
                for (ProductDetailWrapper wrapper : callProducts) {
                    wrapper.callDetail.Detail_Priority_vod__c = ++i;
                    if (wrapper.callDetail.id == null) {
                        wrapper.callDetail.Call2_vod__c = insCall.id;
                    }
                    callDetails.add(wrapper.callDetail.clone());
                }
            }
            if (!callDetails.isEmpty()) {
                insert callDetails;
            }
        }



        //update attachments
        List<Attachment>attachmentsTmp = new List<Attachment>();
        for (AttachmentWrapper wrapper : attachments) {
            if (wrapper.attachment != null && wrapper.attachment.Id == null && wrapper.attachment.Body != null) {
                attachmentsTmp.add(wrapper.attachment);
                wrapper.attachment.ParentId = call.id;
                wrapper.attachment.ownerId = UserInfo.getUserId();
            }
        }



        Map<Id,Call2_vod__c> callsMap = new Map<Id,Call2_vod__c>();
        for(Call2_vod__c ca : callsToInsert) {
            callsMap.put(ca.Account_vod__c, ca);
        }

        //update attendees
        //Call2_vod__c parent = queryCall(call.id);
        List<Call2_vod__c>attendeesCalls = createAttendeeCallsObjectsForMultiple(callsMap, contactsAccountMap, callDetails, callDiscussions, callKeyMessages);
        for (Call2_vod__c c : attendeesCalls) {
            accountToCall.put(c.Account_vod__c, c);
        }

        if (!attachmentsTmp.isEmpty()) {
            insert attachmentsTmp;
        }

        List<Attachment> attachmentsToDelete = new List<Attachment>();
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        attachmentsToDelete = [SELECT Id, Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId = : tempAttachmentParentId AND Description = : temporaryCallId];

        if (!attachmentsToDelete.isEmpty()) {
            for (Call2_vod__c insCall : callsToInsert) {
                for (Attachment attach : attachmentsToDelete) {
                    Attachment newAttach = new Attachment();
                    newAttach.Name = attach.Name;
                    newAttach.Body = attach.Body;
                    newAttach.ContentType = attach.ContentType;
                    newAttach.ParentId = insCall.Id;
                    attachmentsToInsert.add(newAttach);
                }
            }
        }

        if (!attachmentsToInsert.isEmpty()) {
            insert attachmentsToInsert;
        }
        if (!attachmentsToDelete.isEmpty()) {
            delete attachmentsToDelete;
        }

        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pr = new PageReference(retUrl);

        return pr;
    }

    private List<Call2_vod__c> createAttendeeCallsObjectsForMultiple(Map<Id, Call2_vod__c> parentCalls, Map<Id,Id> contactsAccountMap, List<Call2_Detail_vod__c>callDetails, List<Call2_Discussion_vod__c>callDiscussions, List<Call2_Key_Message_vod__c>callKeyMessages) {
        List<Call2_vod__c>attendeesCalls = new List<Call2_vod__c>();
        Map<String, Schema.SObjectField> sObjectFieldMap = GNE_SFA2_Application_Cache.describeObject('Call2_vod__c').fields.getMap();
        for (AttendeeWrapper wrapper : attendees) {
            String conId = wrapper.attendee.Contact_vod__c;
            Call2_vod__c atteCall = parentCalls.get(contactsAccountMap.get(conId)).clone();
            atteCall.Contact_vod__c = conId;
            atteCall.Account_vod__c = null;
            atteCall.Attendee_Type_vod__c = 'Contact_vod';
            atteCall.Parent_Call_vod__c = parentCalls.get(contactsAccountMap.get(conId)).id;
            attendeesCalls.add(atteCall);
        }
        if (!attendeesCalls.isEmpty()) {
            insert attendeesCalls;
        }

        List<Call2_Detail_vod__c> attendeeDetails = new List<Call2_Detail_vod__c>();
        List<Call2_Discussion_vod__c> attendeeDiscussions = new List<Call2_Discussion_vod__c>();

        for (Call2_vod__c call : attendeesCalls) {
            for (Call2_Detail_vod__c callDetail : callDetails) {
                Call2_Detail_vod__c clonedDetail = callDetail.clone(false, true);
                clonedDetail.Call2_vod__c = call.id;
                attendeeDetails.add(clonedDetail);
            }
            for (Call2_Discussion_vod__c callDiscussion : callDiscussions) {
                Call2_Discussion_vod__c clonedDiscussion = callDiscussion.clone(false, true);
                clonedDiscussion.Call2_vod__c = call.id;
                attendeeDiscussions.add(clonedDiscussion);
            }
        }

        insert attendeeDetails;
        insert attendeeDiscussions;

        return  attendeesCalls;
    }

    //child calls have to be copy of parent call and contains the same discussions, key messages and samples
    private List<Call2_vod__c> createAttendeeCallsObjects(Call2_vod__c parentCall, List<Call2_Detail_vod__c>callDetails, List<Call2_Discussion_vod__c>callDiscussions, List<Call2_Key_Message_vod__c>callKeyMessages) {
        List<Id>attendeesCallIds = new List<Id>();
        List<Call2_vod__c>attendeesCalls = new List<Call2_vod__c>();
        Map<String, Schema.SObjectField> sObjectFieldMap = GNE_SFA2_Application_Cache.describeObject('Call2_vod__c').fields.getMap();
        for (AttendeeWrapper wrapper : attendees) {
            if (wrapper.attendee.id == null) {
                wrapper.attendee.Parent_Call_vod__c = parentCall.id;
            }
            attendeesCalls.add(wrapper.attendee);
            copyFieldsValuesFromParentToChildCall(parentCall, wrapper.attendee, sObjectFieldMap);
        }

        if (!attendeesCalls.isEmpty()) {
            upsert attendeesCalls;
        }
        for (Call2_vod__c c : attendeesCalls) {
            attendeesCallIds.add(c.id);
        }

        List<Call2_Detail_vod__c>attendeeDetails = [SELECT id FROM Call2_Detail_vod__c where Call2_vod__c in :attendeesCallIds];
        if (!attendeeDetails.isEmpty()) {
            delete attendeeDetails;
        }
        attendeeDetails.clear();

        List<Call2_Discussion_vod__c>attendeeDiscussions = [SELECT id FROM Call2_Discussion_vod__c where Call2_vod__c in :attendeesCallIds];
        if (!attendeeDiscussions.isEmpty()) {
            delete attendeeDiscussions;
        }
        attendeeDiscussions.clear();

        List<Call2_Key_Message_vod__c>attendeeKeyMessages = [SELECT id FROM Call2_Key_Message_vod__c where Call2_vod__c in :attendeesCallIds];
        if (!attendeeKeyMessages.isEmpty()) {
            delete attendeeKeyMessages;
        }
        attendeeKeyMessages.clear();

        for (Call2_vod__c call : attendeesCalls) {
            for (Call2_Detail_vod__c callDetail : callDetails) {
                Call2_Detail_vod__c clonedDetail = callDetail.clone(false, true);
                clonedDetail.Call2_vod__c = call.id;
                attendeeDetails.add(clonedDetail);
            }
            for (Call2_Discussion_vod__c callDiscussion : callDiscussions) {
                Call2_Discussion_vod__c clonedDiscussion = callDiscussion.clone(false, true);
                clonedDiscussion.Call2_vod__c = call.id;
                attendeeDiscussions.add(clonedDiscussion);
            }
        }

        insert attendeeDetails;
        insert attendeeDiscussions;

        return  attendeesCalls;
    }

    private List<ApexPages.Message>validate() {
        List<ApexPages.Message> errors = new List<ApexPages.Message>();
        if (isVisitReasonOverriden) {
            if (primaryReasonFound) {
                if (String.isBlank(call.Primary_Interaction_Reason_gne__c) || call.Primary_Interaction_Reason_gne__c.containsIgnoreCase('--None--')) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Primary Interaction Reason'));
                }
            }
            if (visitReasonFound) {
                if (String.isBlank(call.Visit_Reason_gne__c) || call.Visit_Reason_gne__c.containsIgnoreCase('--None--')) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Visit Reason'));
                }
            }
        }

        if(isInteractionDetailsSectionVisible && !getHasRAMAProfile()) {
            Set<String> visitReasonInInteractionDetails = new Set<String>();
            if(String.isBlank(call.Visit_Reason_Canada_SAM_gne__c) && !getHasRAMAProfile()) {
                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Visit Reason'));
            } 

            for(InteractionDetailWrapper interactionDetailWrap : interactionDetails) {
                String visitReason = interactionDetailWrap.interactionDetail.Visit_Reason_vod__c;
                if(String.isBlank(visitReason) || visitReason.equals('--None--')) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Visit Reason in Interaction Details section'));
                } else if(visitReason == 'Strategic Objective') {
                    if(String.isBlank(interactionDetailWrap.interactionDetail.Tactic_vod__c) || interactionDetailWrap.interactionDetail.Tactic_vod__c.equals('--None--')) {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Tactic in Interaction Details section'));
                    }
                } else if(visitReason == 'Event/Conference') {
                    if(String.isBlank(interactionDetailWrap.interactionDetail.Type_vod__c) || interactionDetailWrap.interactionDetail.Type_vod__c.equals('--None--')) {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Type in Interaction Details section'));
                    }
                    if(String.isBlank(interactionDetailWrap.interactionDetail.Name_vod__c) || interactionDetailWrap.interactionDetail.Name_vod__c.equals('--None--')) {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Name in Interaction Details section'));
                    }
                }
                visitReasonInInteractionDetails.add(visitReason);
            }

            List<String> selectedVisitReasons = new List<String>();
            if(String.isNotBlank(call.Visit_Reason_Canada_SAM_gne__c)) {
                selectedVisitReasons = call.Visit_Reason_Canada_SAM_gne__c.split(';');
            }

            for(String selectedReason : selectedVisitReasons) {
                if(selectedReason == 'Strategic Objective' || selectedReason == 'Event/Conference') {
                    if(!visitReasonInInteractionDetails.contains(selectedReason)) {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must fill in Interaction Details for selected Visit Reason: ' + selectedReason));
                    }
                }
            }
        }

        if(getHasRAMAProfile()) {
            errors = validateForRAMA(errors);
        }

        String currentUserProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
        //Validation for GNE-MedAffairs-MSL and GNE-MedAffairs-MSL-Manager
        //Curriculum can be selected only if Visit Reason is Speaker Training
        if (new Set<String> {'GNE-MEDAFFAIRS-MSL', 'GNE-MEDAFFAIRS-MSL-MANAGER'} .contains(currentUserProfileName.toUpperCase())) {
            if (callSectionsList != null && callSectionsList.size() > 0) {
                for (SFA2_Configuration_Object_gne__c section : callSectionsList) {
                    if (section.Name == 'CallDetail') {
                        for (SFA2_Configuration_Object_Detail_gne__c callSection : section.Configuration_Objects__r) {
                            // Check visit reason on the layout
                            if (callSection.API_Name_gne__c == 'Visit_Reason_gne__c') {
                                if (call.Visit_Reason_gne__c != 'Speaker Training' && discussionSectionFields != null && discussionSectionFields.size() > 0
                                        && discussions != null && discussions.size() > 0) {
                                    for (SFA2_Configuration_Object_Detail_gne__c conf : discussionSectionFields) {
                                        // Check Event Curriculum on the layout
                                        if (conf.API_Name_gne__c == 'Event_Curriculum_gne__c') {
                                            for (DiscussionWrapper discussion : discussions) {
                                                if (!String.isBlank(discussion.callDiscussion.Event_Curriculum_gne__c)) {
                                                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Curriculum can be selected only if Visit Reason is Speaker Training'));
                                                    break;
                                                }
                                            }
                                            break;
                                        }
                                    }
                                }
                                break;
                            }
                        }
                        break;
                    }
                }
            }

            if (call.Is_Referral_gne__c) {
                if (call.Referral_Requested_Date_gne__c == null) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Referral Requested Date: You must enter a value.'));
                }
                if (String.isEmpty(call.Referral_Source_gne__c)) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Referral Source: You must enter a value.'));
                }
                if (String.isEmpty(call.Referral_Requested_By_gne__c) && String.isNotEmpty(call.Referral_Source_gne__c) && (call.Referral_Source_gne__c.equalsIgnoreCase('TLL') || call.Referral_Source_gne__c.equalsIgnoreCase('MSL') || call.Referral_Source_gne__c.equalsIgnoreCase('Field Sales'))) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Referral Requested By: You must enter a value.'));
                }
                if (String.isNotEmpty(call.Referral_Source_gne__c) && call.Referral_Source_gne__c.equalsIgnoreCase('Other') && String.isEmpty(call.Other_Referral_Source_gne__c)) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Other Referral Source: You must enter a value.'));
                }
            }
        }

        //Validation to complete call for GNE-TLS, GNE-TLS-Maintenance, GNE-TLS-Manager
        if (new Set<String> {'GNE-TLS', 'GNE-TLS-MAINTENANCE', 'GNE-TLS-MANAGER', 'GNE-TLS-SPEAKERBUREAULEAD'} .contains(currentUserProfileName.toUpperCase()) ) {
            if (discussionSectionFields != null && discussionSectionFields.size() > 0
                    && discussions != null && discussions.size() > 0) {
                Boolean productFound = false;
                Boolean activityFound = false;
                Boolean observationFound = false;

                for (SFA2_Configuration_Object_Detail_gne__c conf : discussionSectionFields) {
                    // Check Product on the layout
                    if (!productFound && conf.API_Name_gne__c == 'Product_vod__c' && call.Completed_gne__c == True && currentUserProfileName.toUpperCase() != 'GNE-TLS-SPEAKERBUREAULEAD') {
                        for (DiscussionWrapper discussion : discussions) {
                            if (String.isBlank(discussion.callDiscussion.Product_vod__c)) {
                                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Product'));
                                productFound = true;
                                break;
                            }
                        }
                    }
                    // Check Activity on the layout
                    if (!activityFound && conf.API_Name_gne__c == 'Activity_gne__c' && call.Completed_gne__c == True && currentUserProfileName.toUpperCase() != 'GNE-TLS-SPEAKERBUREAULEAD') {
                        for (DiscussionWrapper discussion : discussions) {
                            if (String.isBlank(discussion.callDiscussion.Activity_gne__c)) {
                                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Activity'));
                                activityFound = true;
                                break;
                            }
                        }
                    }
                    // Check Activity on the layout
          if(!observationFound && conf.API_Name_gne__c == 'Observation_gne__c'){
              for(DiscussionWrapper discussion : discussions){
                  if(discussion.callDiscussion.Observation_gne__c == '__' || discussion.callDiscussion.Observation_gne__c == 'null'){
                      discussion.callDiscussion.Observation_gne__c = '';
                      observationFound = true;
                      break;
                  }
              }
          }
          if (productFound && activityFound && observationFound) {
                        break;
                    }
                }
            }
        }

        if(currentUserProfileName == 'GNE-SFA-CC-Ocrevus' && call.Group_Call_with_gne__c == null) {
            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Group Call With.'));
        }

        for (SFA2_Configuration_Object_gne__c confObjects : callSectionsList) {
            if (confObjects.Name == 'CallAttendees') {
                //ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'An error occurred calling the Master Data Service.  Only SFDC has been searched.');
                //--ao - attendees not required
                if (!getIsBAMProfile() && String.isNotEmpty(confObjects.Attributes_gne__c) && !confObjects.Attributes_gne__c.contains('--attendeesNotRequired') && attendees.size() == 0) {
                    /*SFDC-2865 : If Account is "person account", the account is an attendee.*/
                    if (callAccount.isPersonAccount != true) {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'At least one attendee is required.'));
                    } else {
                        call.Attendees_vod__c = 1;
                    }
                }
            }

            if (confObjects.Name == 'CallMealExpense' || confObjects.Name == 'CallDetailInformation' || confObjects.Name == 'CallDetail') {
                for (SFA2_Configuration_Object_Detail_gne__c conf : callSectionsMap.get(confObjects.Id)) {
                    if (conf.Is_Required_gne__c && call.get(conf.API_Name_gne__c) == null) {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for ' + conf.Label_gne__c));
                    }
                }
            }

            if (confObjects.Name == 'CallObjectives') {
                if (String.isNotEmpty(confObjects.Attributes_gne__c) && confObjects.Attributes_gne__c.contains('--rd') && discussions.size() == 0) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'A detailed product must be selected in order to submit the call.'));
                }

                for (DiscussionWrapper wrapper : discussions) {
                    for (SFA2_Configuration_Object_Detail_gne__c conf : callSectionsMap.get(confObjects.Id)) {
                        if (conf.Is_Required_gne__c && (wrapper.callDiscussion.get(conf.API_Name_gne__c) == null || wrapper.callDiscussion.get(conf.API_Name_gne__c)=='')) {
                            if(!isFrmUser() || isDependendFieldVisible(confObjects, wrapper.callDiscussion, conf.API_Name_gne__c)) {
                                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for ' + conf.Label_gne__c));
                            }
                        }

                        if(isFrmUser() && conf.API_Name_gne__c == 'Event_Curriculum_gne__c' && call.Interaction_Type_gne__c != '1:1 Training/Deck Update' && String.isNotBlank((String)wrapper.callDiscussion.get(conf.API_Name_gne__c))) {
                            errors.add(new ApexPages.Message(ApexPages.severity.ERROR,
                                String.format(System.Label.GNE_SFA2_ErrMsg_FRM_Interaction_Type_Curriculum_Validation, new String[] {
                                    conf.Label_gne__c, '1:1 Training/Deck Update'
                                }
                            )));
                        }

                        if (getIsCCorOCCProfile() && conf.API_Name_gne__c == 'Event_Curriculum_gne__c' &&
                                (call.Interaction_Type_gne__c == '1:1' || call.Interaction_Type_gne__c == '1:1 In-Service') && (wrapper.callDiscussion.Activity_gne__c == 'Training/Deck Content' || wrapper.callDiscussion.Activity_gne__c == 'Training/Annual Compliance') &&
                                String.isBlank((String)wrapper.callDiscussion.get(conf.API_Name_gne__c))) {
                            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for ' + conf.Label_gne__c));
                        }

                        if(userProfile != null && userProfile.contains('GNE-TLS') && conf.API_Name_gne__c == 'Event_Curriculum_gne__c' && wrapper.callDiscussion.Activity_gne__c == '1:1 Training/Deck Update' &&
                            String.isBlank((String)wrapper.callDiscussion.get(conf.API_Name_gne__c))) {
                            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for ' + conf.Label_gne__c));
                        }

                        if(GNE_SFA2_Util.isPREPUser() && conf.API_Name_gne__c == 'Event_Curriculum_gne__c' && wrapper.callDiscussion.Speaker_Training_gne__c &&
                            String.isBlank((String)wrapper.callDiscussion.get(conf.API_Name_gne__c))) {
                            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for ' + conf.Label_gne__c));
                        }
                    }
                }
            }

            if (confObjects.Name == 'CallMaterials') {
                for (MaterialWrapper wrapper : materials) {
                    for (SFA2_Configuration_Object_Detail_gne__c conf : callSectionsMap.get(confObjects.Id)) {
                        if (conf.Is_Required_gne__c && wrapper.callSample.get(conf.API_Name_gne__c) == null) {
                            if (GNE_SFA2_Util.isCanadaUser()) {
                                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must update the Service Oriented Item for the product selected.'));
                            } else {
                                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for ' + conf.Label_gne__c));
                            }
                        }
                    }
                }
            }
            //specific material can be assigned to specific receiver only once (cannot be duplicated)
            Map<Id, Set<Id>>receiverToMaterials = new Map<Id, Set<Id>>();
            for (MaterialWrapper wrapper : materials) {
                if (!receiverToMaterials.containsKey(wrapper.callSample.Account_vod__c)) {
                    receiverToMaterials.put(wrapper.callSample.Account_vod__c, new Set<Id>());
                }
                if (receiverToMaterials.get(wrapper.callSample.Account_vod__c).contains(wrapper.callSample.Product_vod__c)) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Specific material can be assigned to specific receiver only once'));
                    //wrapper.callSample.Account_vod__c.addError('Duplicate Recipient');
                } else {
                    receiverToMaterials.get(wrapper.callSample.Account_vod__c).add(wrapper.callSample.Product_vod__c);
                }

                if (wrapper.callSample.Quantity_vod__c <= 0) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_ErrMsg_Quantity_More_Than_Zero));
                }
            }

        }

        errors.addAll(validateMealOptOut());

        //PFG validation
        errors.addAll(pfgController.validate());

        return errors;
    }

    private List<ApexPages.Message> validateForRAMA(List<ApexPages.Message> errors) {
        if(call.Completed_gne__c) {
            if(String.isBlank(call.Access_Echo_Alignment_RAMA_gne__c)) {
                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must select at least one ACCESS ECHO value to complete the interaction'));
            } 
            if(String.isBlank(call.Group_RAMA_gne__c)) {
                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Group: You must select a value'));
            }

            for(InteractionCategoryWrapper category : interactionCategories) {
                if(category.interactionCategory.Brand_Above_Brand_gne__c == 'Above Brand') {
                    if(String.isEmpty(category.interactionCategory.Therapeutic_Area_gne__c)) {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Category: You must select a value'));
                    }
                } else if(category.interactionCategory.Brand_Above_Brand_gne__c == 'Brand') {
                    if(category.interactionCategory.NOC_Status_gne__c == 'Post-NOC') {
                        if(String.isEmpty(category.interactionCategory.Brand_Name_gne__c)) {
                            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Category: You must select a value'));
                        }
                    } else if(category.interactionCategory.NOC_Status_gne__c == 'Pre-NOC') {
                        if(!String.isEmpty(category.interactionCategory.Molecule_gne__c)) {
                            if(String.isEmpty(category.interactionCategory.Indication_gne__c)) {
                                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Category: You must select a value'));
                            }
                        } else {
                            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Category: You must select a value'));
                        }
                    } else {
                        errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Category: You must select a value'));
                    }
                } else {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'Category: You must select a value'));
                }
            }
        
            if(String.isBlank(call.Objectives_RAMA_gne__c) || String.isBlank(call.Key_Messages_RAMA_gne__c)
                || String.isBlank(call.Outcomes_RAMA_gne__c) || String.isBlank(call.Next_Steps_RAMA_gne__c)) {
                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter text in all boxes to complete the interaction'));
            }
        }

        for(InteractionDetailWrapper interactionDetailWrap : interactionDetails) {
            if(String.isBlank(interactionDetailWrap.interactionDetail.Strategy_RAMA_vod__c)) {
                errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Strategy in Interaction Details section'));
            }
            if(String.isBlank(interactionDetailWrap.interactionDetail.Tactic_RAMA_vod__c)) {
               errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Tactic in Interaction Details section'));
            } 
            if(String.isBlank(interactionDetailWrap.interactionDetail.Tools_RAMA_vod__c) || interactionDetailWrap.interactionDetail.Tools_RAMA_vod__c == '--None--') {
               errors.add(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Tools in Interaction Details section'));
            } 
        }

        return errors;
    }

    private List<ApexPages.Message> validateMealOptOut() {
        List<ApexPages.Message> errors = new List<ApexPages.Message>();
        //spec. 4.2.2
        if (call.HCP_Account_Meal_Opt_Out_gne__c && !call.Meal_Expense_gne__c) {
            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_Meal_Opt_Out_Meal_Event_Not_Completed));
        } else if (!call.Meal_Expense_gne__c && call.Actual_Attendees_gne__c > 0) {
            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.Meal_Expense_Required_Label));
        //spec. 4.2.3
        } else if (!call.Meal_Expense_gne__c) {
            for (AttendeeWrapper wrapper : attendees) {
                if (wrapper.attendee.HCP_Attendee_Meal_Opt_Out_gne__c) {
                    errors.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_Meal_Opt_Out_Meal_Event_Not_Completed));
                    break;
                }
            }
        }

        //When Meal Out Opt is selected: Actual Meal Recipients number entered must be greater than, or equal to, the number of people who were not opted out of a meal expense + the CS
        Integer mealConsumers = 1;
        for (AttendeeWrapper wrapper : attendees) {
            if (!wrapper.attendee.HCP_Attendee_Meal_Opt_Out_gne__c) {
                mealConsumers++;
            }
        }
        if (callAccount.isPersonAccount && !call.HCP_Account_Meal_Opt_Out_gne__c) {
            mealConsumers++;
        }
        if (errors.isEmpty() && call.Actual_Attendees_gne__c < mealConsumers) {
            errors.add(new ApexPages.Message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_Meal_Opt_Out_Actual_Meal_Recipient_Validation));
        }
        return errors;
    }

    public PageReference cancel() {
        PageReference pr;
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        if (retURL != null) {
            pr = new PageReference(retUrl);
        } else if (call.id != null) {
            pr = Page.GNE_SFA2_Interaction_Layout;
            pr.getParameters().put('id', call.id);
        } else {
            pr = Page.GNE_SFA2_Account_Layout;
            pr.getParameters().put('id', call.Account_vod__c);
        }
        removeTemporaryAttachments();
        return pr;
    }

    public PageReference edit() {
        PageReference pr = Page.GNE_SFA2_Interaction_Edit_Create;
        pr.getParameters().put('id', call.id);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference deleteCall() {
        String accountId = call.Account_vod__c;
        try {
            delete call;
        } catch (Exception e) {
            validationMessagesSummary.add(e.getMessage());
            return null;
        }
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        PageReference pr;
        if (retURL == null) {
            pr = new PageReference('/' + accountId);
        } else {
            pr = new PageReference(retUrl);
        }
        pr.setRedirect(true);
        return pr;
    }

    private Key_Message_vod__c getKeyMessage(Id keyMessageId) {
        return [SELECT Id, Name, Product_vod__c, Product_vod__r.Name, Description_vod__c  FROM Key_Message_vod__c WHERE  id = : keyMessageId];
    }

    private List<SelectOption>getKeyMessagesWrappers(Id productId) {
        List<SelectOption>  wrappers = new List<SelectOption>();
        Map<Id, Key_Message_vod__c>keyMessages = new Map<Id, Key_Message_vod__c>([SELECT Id, Name, Description_vod__c  FROM Key_Message_vod__c WHERE Product_vod__c = :productId AND Active_vod__c = true]);
        for (Key_Message_vod__c keyMessage : keyMessages.values()) {
            wrappers.add(new SelectOption(keyMessage.Id, keyMessage.Name));
        }
        return wrappers;
    }

    @RemoteAction
    public static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean onlyTargetAccounts, Id callAccountId) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = GNE_SFA2_SearchAccounts_Controller.searchAccountsContactsEmployees(searchString, recordLimit, allAccounts, onlyPersonAccounts, onlyTargetAccounts, new List<Id> {callAccountId});
        GNE_SFA2_PREP_Interaction_Controller.onSearchAccountsContactsEmployees(result);
        if(GNE_SFA2_Util.isCanadaUser()) {
            // iHCP is enabled for Canadian users only
            result.addAll(searchInternationalSpeakers(searchString, recordLimit));
        }
        return result;

    }

    @RemoteAction
    public static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchAccounts(String searchString, Integer recordLimit, Boolean onlyPersonAccounts) {
        return GNE_SFA2_SearchAccounts_Controller.searchAccounts(searchString, recordLimit, onlyPersonAccounts);
    }

    @RemoteAction
    public static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> getAffiliatedAccounts(Id accountId) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
        //result = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
        // Changed old MCCO profiles to new one GNE-MCCO-AM
        // Set<String> mccoProfiles = new Set<String> {'GNE-MCCO PFT', 'GNE-MCCO-PFT-Manager', 'GNE-MCCO-PFT-OPS', 'GNE-MCCO-CFT', 'GNE-MCCO-CFT-Manager', 'GNE-MCCO-CFT-OPS'};
        Set<String> mccoProfiles = new Set<String> {'GNE-MCCO-AM'};
        List<Id> accountIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        List<Id> excludedContactIds = new List<Id>();
        Integer resultSizeLimit = 100;
        Integer counter = 0;
        if (accountId != null) {
            String activeField = '';
            String brandFieldAPIName = null;
            if( GNE_Account_Affiliation_Dao.canSetActiveForMyBrand() ) {
                brandFieldAPIName = GNE_Account_Affiliation_Dao.getMyBrandFieldApiName();
                if( brandFieldAPIName != null ) {
                    activeField += ',' + brandFieldAPIName;
                }
            }
            //QC: 1226 -remove filter on affilation AND Affiliation_Type_gne__c='AFFILIATION' AND Record_Status_gne__c='Active'
            for (Affiliation_vod__c affiliation : Database.query('SELECT Id, Name, From_Account_vod__c, To_Account_Type_gne__c, To_Account_vod__c, To_Contact_vod__c' + activeField + ' FROM Affiliation_vod__c WHERE From_Account_vod__c = \'' + accountId + '\'') ) {
                if (affiliation.To_Account_vod__c != null) {
                    accountIds.add(affiliation.To_Account_vod__c);
                } else if (affiliation.To_Contact_vod__c != null) {
                    if( brandFieldAPIName == null || ( brandFieldAPIName != null && affiliation.get(brandFieldAPIName) == true ) ) {
                        contactIds.add(affiliation.To_Contact_vod__c);
                    } else {
                        excludedContactIds.add( affiliation.To_Contact_vod__c );
                    }
                }
            }

            for (Account acc : [SELECT Id, FirstName, LastName, Territory_vod__c, Name, IsPersonAccount FROM Account WHERE  Id IN :accountIds AND IsPersonAccount = true ORDER BY LastName, FirstName limit 100]) {
                if (counter++ > resultSizeLimit) {
                    break;
                }
                result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(acc, null));
            }
            for (Contact contact : [SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c FROM Contact WHERE  Id IN :contactIds ORDER BY LastName, FirstName limit 100]) {
                if (counter++ > resultSizeLimit) {
                    break;
                }
                if (!mccoProfiles.contains(GNE_SFA2_Util.getCurrentUserProfileName())) {
                    result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(contact, null));
                } else if (contact.Active_gne__c) {
                    result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(contact, null));
                }
            }
            contactIds.addAll( excludedContactIds );
        }
        for (Contact contact : [SELECT Id, Active_gne__c, FirstName, LastName, Name, IsPersonAccount, AccountId, Type_gne__c FROM Contact WHERE AccountId = :accountId AND IsPersonAccount = false AND id NOT IN :contactIds ORDER BY LastName, FirstName limit 100]) {
            if (counter++ > resultSizeLimit) {
                break;
            }
            if (!mccoProfiles.contains(GNE_SFA2_Util.getCurrentUserProfileName())) {
                result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(contact, null));
            } else if (contact.Active_gne__c) {
                result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(contact, null));
            }
        }

        GNE_SFA2_PREP_Interaction_Controller.onGetAffiliatedAccounts(result);
        return result;
    }

    private List<SelectOption> getAffiliatedAccountsOptions(List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>wrappers) {
        List<SelectOption> result = new List<SelectOption>();
        for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper : wrappers) {
            result.add(new SelectOption(wrapper.accountId, wrapper.accountDescription));
        }
        return result;
    }

    public PageReference newCallClick() {
        String newCallURL = '/apex/GNE_SFA2_Interaction_Edit_Create?accountId=' + callAccount.Id;
        pagereference pageref = new pagereference(newCallURL);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference addAttendees() {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>selectedAccountsWrappers =  (List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>) JSON.deserialize(selectedAccountsJSON, List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>.class);
        Set<Integer> attIdxs = new Set<Integer>();

        for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper : selectedAccountsWrappers) {
            if (!isAttendeeAlreadyAdded(wrapper.accountId)) {
                if (wrapper.isUser) {
                    attIdxs.add(attendees.size());
                    attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(User_vod__c = wrapper.accountId, Attendee_Type_vod__c = 'User_vod')));
                } else if (wrapper.isContact) {
                    attIdxs.add(attendees.size());
                    if(getIsFPMProfile() && wrapper.recordType != null){
                        attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Contact_vod__c = wrapper.accountId, Attendee_Type_vod__c = 'Contact_vod'), wrapper.recordType));
                    } else {
                        attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Contact_vod__c = wrapper.accountId, Attendee_Type_vod__c = 'Contact_vod')));
                    }
                } else if (wrapper.recordType == 'iHCP') {
                    // iHCP
                    attIdxs.add(attendees.size());
                    attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(EMS_International_Speaker_gne__c = wrapper.accountId, Attendee_Type_vod__c = 'iHCP_Account_vod')));
                } else {
                    attIdxs.add(attendees.size());
                    attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Account_vod__c = wrapper.accountId, Attendee_Type_vod__c = 'Person_Account_vod')));
                }
                if (isAffiliatedAccount(wrapper.accountId)) {
                    selectedAccounts.add(wrapper.accountId);
                }
            }
        }
        recipients = getRecipients(attendees);
        PageReference result = prepController.addAttendees(attIdxs);
        return result;
    }

    private Boolean isAttendeeAlreadyAdded(Id accountId) {
        for (AttendeeWrapper wrapper : attendees) {
            if (wrapper.attendee.Account_vod__c == accountId || wrapper.attendee.Contact_vod__c == accountId || wrapper.attendee.EMS_International_Speaker_gne__c == accountId) {
                return true;
            }
        }
        return false;
    }

    public void addActivity() {
        activities.add(new ActivityWrapper(activities.size(), new Task(ownerId = UserInfo.getUserId())));
    }

    public PageReference keyMessageDeselected() {
        List<Integer>indexesToRemove = new List<Integer>();
        for (Integer i = 0; i < keyMessages.size(); i++) {
            if (keyMessages.get(i).keyMessageId == keyMessageId) {
                indexesToRemove.add(i);
            }
        }
        for (Integer i = indexesToRemove.size() - 1; i >= 0; i--) {
            KeyMessageWrapper wrapper = keyMessages.remove(indexesToRemove.get(i));
            if (String.isNotEmpty(wrapper.callKeyMessageId)) {
                callKeyMessagesIdsToRemove.add(wrapper.callKeyMessageId);
            }
        }

        Integer indexToRemove = -1;
        for (Integer i = 0; i < selectedKeyMessages.size(); i++) {
            if (selectedKeyMessages.get(i) == keyMessageId) {
                indexToRemove = i;
                break;
            }
        }
        if (indexToRemove > -1) {
            selectedKeyMessages.remove(indexToRemove);
        }
        return null;
    }

    public PageReference keyMessageSelected() {
        Key_Message_vod__c keyMessage = getKeyMessage(keyMessageId);
        selectedKeyMessages.add(keyMessageId);
        keyMessages.add(new KeyMessageWrapper(keyMessages.size(), keyMessage.Product_vod__c, keyMessage.Product_vod__r.Name, null, keyMessageId, keyMessage.Product_vod__r.Name, keyMessage.Description_vod__c, ''));
        return null;
    }

    public PageReference productSelected() {
        selectedProducts.add(productId);
        callProducts.add(new ProductDetailWrapper(callProducts.size(), new Call2_Detail_vod__c(Call2_vod__c = call.id, Product_vod__c = productId, Type_vod__c = 'Paper_Detail_vod')));

        if (isDiscussionSectionVisible) {
            callDiscussionProducts.add(getProductOption(productId));
            Call2_Discussion_vod__c callDiscussion = new Call2_Discussion_vod__c(Product_vod__c = productId, zvod_Product_Map_vod__c = getProductName(productId));
            DiscussionWrapper wrapper = new DiscussionWrapper(discussions.size(), callDiscussion, getStrategies(callDiscussion), getTactics(callDiscussion), prepController);
            wrapper.setDefaultTopicValue(discussionTopicFieldExists);
            discussions.add(wrapper);
        }

        if (isKeyMessagesSectionVisible && !isKeyMessageWrappersAlreadyAdded(productId)) {
            List<SelectOption>messages = getKeyMessagesWrappers(productId);
            if (!messages.isEmpty()) {
                productToKeyMessagesWrappers.add(new ProductKeyMessageWrapper(productId, getProductName(productId), messages));
            }
        }
        return null;
    }

    public PageReference productDeselected() {
        Integer indexToRemove = -1;
        for (Integer i = 0; i < selectedProducts.size(); i++) {
            if (selectedProducts.get(i) == productId) {
                indexToRemove = i;
                break;
            }
        }
        if (indexToRemove > -1) {
            selectedProducts.remove(indexToRemove);
        }

        List<Integer>indexesToRemove = new List<Integer>();
        for (Integer i = 0; i < callProducts.size(); i++) {
            if (callProducts.get(i).callDetail.Product_vod__c == productId) {
                indexesToRemove.add(i);
            }
        }
        for (Integer i = indexesToRemove.size() - 1; i >= 0; i--) {
            ProductDetailWrapper wrapper = callProducts.remove(indexesToRemove.get(i));
            if (String.isNotEmpty(wrapper.callDetail.id)) {
                productDetailsToRemove.add(wrapper.callDetail);
            }
        }

        for (Integer i = 0; i < callProducts.size(); i++) {
            callProducts.get(i).index = i;
        }

        if (isDiscussionSectionVisible) {
            indexesToRemove = new List<Integer>();
            for (Integer i = 0; i < discussions.size(); i++) {
                if (discussions.get(i).callDiscussion.Product_vod__c == productId) {
                    indexesToRemove.add(i);
                }
            }
            for (Integer i = indexesToRemove.size() - 1; i >= 0; i--) {
                DiscussionWrapper wrapper = discussions.remove(indexesToRemove.get(i));
                if (String.isNotEmpty(wrapper.callDiscussion.id)) {
                    discussionsToRemove.add(wrapper.callDiscussion);
                }
            }
            indexToRemove = -1;
            for (Integer i = 0; i < callDiscussionProducts.size(); i++) {
                if (String.isNotEmpty(callDiscussionProducts.get(i).getValue()) && callDiscussionProducts.get(i).getValue() == productId) {
                    indexToRemove = i;
                    break;
                }
            }
            if (indexToRemove > -1) {
                callDiscussionProducts.remove(indexToRemove);
            }

            for (Integer i = 0; i < discussions.size(); i++) {
                discussions.get(i).index = i;
            }
        }

        if (isKeyMessagesSectionVisible) {
            indexToRemove = -1;
            for (Integer i = 0 ; i < productToKeyMessagesWrappers.size(); i++) {
                if (productId == productToKeyMessagesWrappers.get(i).productId) {
                    indexToRemove = i;
                    break;
                }
            }
            if (indexToRemove > -1) {
                productToKeyMessagesWrappers.remove(indexToRemove);
            }

            //todo: remove all key messages for given product
            List<Integer>keyMessagesIndexesToRemove = new List<Integer>();
            List<Id>keyMessagesIds = new List<Id>();

            for (Integer i = 0; i < keyMessages.size(); i++) {
                KeyMessageWrapper wrapper =  keyMessages.get(i);
                keyMessagesIds.add(wrapper.keyMessageId);
                if (wrapper.productId == productId) {
                    keyMessagesIndexesToRemove.add(i);
                }
            }

            for (Integer i = keyMessagesIndexesToRemove.size() - 1; i >= 0; i--) {
                KeyMessageWrapper wrapper = keyMessages.remove(keyMessagesIndexesToRemove.get(i));
                if (String.isNotEmpty(wrapper.callKeyMessageId)) {
                    callKeyMessagesIdsToRemove.add(wrapper.callKeyMessageId);
                }
            }
            List<Integer>selectedKeyMsgToRemove = new List<Integer>();
            for (Integer i = 0; i < selectedKeyMessages.size(); i++) {
                for (Id keyMsgId : keyMessagesIds) {
                    if (selectedKeyMessages.get(i) == keyMsgId) {
                        selectedKeyMsgToRemove.add(i);
                        break;
                    }
                }
            }
            for (Integer i = selectedKeyMsgToRemove.size() - 1; i >= 0; i--) {
                selectedKeyMessages.remove(i);
            }
        }
        return null;
    }

    private Boolean isAffiliatedAccount(Id accountId) {
        for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper : affiliatedAccounts) {
            if (wrapper.accountId == accountId) {
                return true;
            }
        }
        return false;
    }

    public PageReference affiliatedAccountDeselected() {
        List<Integer>indexesToRemove = new List<Integer>();
        for (Integer i = 0; i < attendees.size(); i++) {
            AttendeeWrapper wrapper = attendees.get(i);
            if (wrapper.attendee.Account_vod__c == affiliatedAccountId || wrapper.attendee.Contact_vod__c == affiliatedAccountId) {
                indexesToRemove.add(i);
                if (wrapper.attendee.Id != null) {
                    attendeesToRemove.add(wrapper.attendee);
                }
            }
        }
        for (Integer i = indexesToRemove.size() - 1; i >= 0; i--) {
            attendees.remove(indexesToRemove.get(i));
        }

        for (Integer i = 0; i < attendees.size(); i++) {
            attendees.get(i).index = i;
        }

        Integer indexToRemove = -1;
        for (Integer i = 0; i < selectedAccounts.size(); i++) {
            if (selectedAccounts.get(i) == affiliatedAccountId) {
                indexToRemove = i;
                break;
            }
        }
        if (indexToRemove > -1) {
            selectedAccounts.remove(indexToRemove);
        }
        recipients = getRecipients(attendees);
        return null;
    }

    public PageReference affiliatedAccountSelected() {
        selectedAccounts.add(affiliatedAccountId);
        GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper = null;
        for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper acc : affiliatedAccounts) {
            if (affiliatedAccountId == acc.accountId) {
                wrapper = acc;
                break;
            }
        }
        if (!wrapper.isContact) {
            attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Account_vod__c = wrapper.accountId, Attendee_Type_vod__c = 'Person_Account_vod')));
        } else {
            if(getIsFPMProfile() && wrapper.recordType != null){
                attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Contact_vod__c = wrapper.accountId, Attendee_Type_vod__c = 'Contact_vod'), wrapper.recordType));
            } else {
                attendees.add(new AttendeeWrapper(attendees.size(), new Call2_vod__c(Contact_vod__c = wrapper.accountId, Attendee_Type_vod__c = 'Contact_vod')));
            }
        }
        recipients = getRecipients(attendees);
        PageReference result = prepController.affiliatedAccountSelected(attendees.size() - 1);
        return result;
    }

    public PageReference addInteractionDiscussion() {
        discussions.add(new DiscussionWrapper(discussions.size(),prepController));
        return null;
    }

    public PageReference addMaterial() {
        materials.add(new MaterialWrapper(materials.size()));
        return null;
    }

    public PageReference addInteractionDetail() {
        interactionDetails.add(new InteractionDetailWrapper(interactionDetails.size()));
        refreshForRAMA();
        return null;
    }

    private void refreshForRAMA() {
        if(getHasRAMAProfile()) {
            refreshDetailsStrategyPicklists();
        }
    }

    public PageReference addInteractionCategory() {
        interactionCategories.add(new InteractionCategoryWrapper(interactionCategories.size()));
        return null;
    }

    public PageReference addAttachment() {
        attachments.add(new AttachmentWrapper(attachments.size()));
        return null;
    }

    public PageReference toObservationHelpPage() {
        PageReference pr = Page.GNE_SFA2_Call_Observation_Help_Info;
        pr.setRedirect(true);
        return pr;
    }

    private List<ActivityWrapper>getActivities(Call2_vod__c call) {
        List<ActivityWrapper>result = new List<ActivityWrapper>();
        if (call == null || call.Id == null || !isActivitiesSectionVisible) {
            return result;
        }
        Integer index = 0;
        String query = 'SELECT Id, Account_ID_gne__c, ';
        for (SFA2_Configuration_Object_Detail_gne__c conf : activitiesSectionFields) {
            query += conf.API_Name_gne__c;
            query += ', ';
        }
        query = query.removeEnd(', ');
        query += ' FROM Task WHERE WhatId=\'' + call.id + '\'';

        for (Task task : Database.query(query)) {
            result.add(new ActivityWrapper(index, task));
            index++;
        }
        return result;
    }

    private List<AttendeeWrapper>getAttendees(Call2_vod__c parentCall) {
        List<AttendeeWrapper>result = new List<AttendeeWrapper>();
        if (parentCall == null || parentCall.Id == null || !isAttendeesSectionVisible) {
            return result;
        }
        Integer index = 0;
        Set<String> queryFields = new Set<String> {
            'Id', 'Name', 'Account_vod__c', 'Account_vod__r.Name', 'EMS_International_Speaker_gne__c', 'EMS_International_Speaker_gne__r.Name', 'Contact_vod__c', 'Contact_vod__r.Name',
            'Attendee_Type_vod__c', 'User_vod__c', 'User_vod__r.Name',
            'HCP_Attendee_Meal_Opt_Out_gne__c', 'HCP_OR_Attendee_Meal_Opt_Out_gne__c',
            'Attendee_Type_FPM_gne__c'
        };

        for (SFA2_Configuration_Object_Detail_gne__c attendeeFieldDetail : attendeesAdditionalFields) {
            if (attendeeFieldDetail.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD) {
                queryFields.add(attendeeFieldDetail.API_Name_gne__c);
            }
        }
        Id parentCallId = parentCall.Id;
        String query = String.format('SELECT {0} FROM Call2_vod__c WHERE Parent_Call_vod__c = :parentCallId', new String[] {String.join(new List<String>(queryFields), ', ')});

        for (Call2_vod__c attCall : Database.query(query)) {
            result.add(new AttendeeWrapper(index, attCall));
            index++;
        }
        return result;
    }

    private List<ProductDetailWrapper>getCallProducts(Call2_vod__c call) {
        List<ProductDetailWrapper>result = new List<ProductDetailWrapper>();
        if (call == null || call.Id == null || (!isProductDetailsSectionVisible && !isDiscussionSectionVisible)) {
            return result;
        }
        for (Call2_Detail_vod__c callDetail : [Select id, Product_vod__c, Product_vod__r.Name, Detail_Priority_vod__c From Call2_Detail_vod__c where Call2_vod__c = :call.id order by Detail_Priority_vod__c]) {
            if (String.isNotEmpty(callDetail.Product_vod__c)) {
                selectedProducts.add(callDetail.Product_vod__c);
                result.add(new ProductDetailWrapper(result.size(), callDetail));
            }
        }
        return result;
    }

    private List<DiscussionWrapper>getDiscussions(Call2_vod__c call) {
        List<DiscussionWrapper>result = new List<DiscussionWrapper>();
        if (call == null || call.Id == null || !isDiscussionSectionVisible) {
            return result;
        }
        String query = 'SELECT Id, RecordTypeId, Product_vod__c, Product_vod__r.Name, Product_Strategy_vod__c, zvod_Product_Map_vod__c, ';
        for (SFA2_Configuration_Object_Detail_gne__c conf : discussionSectionFields) {
            if (conf.API_Name_gne__c != 'Product_vod__c' && conf.API_Name_gne__c != 'Product_Strategy_vod__c' && conf.API_Name_gne__c != 'zvod_Product_Map_vod__c' && conf.API_Name_gne__c != 'RecordTypeId') {
                query += conf.API_Name_gne__c;
                query += ', ';
            }
        }
        query = query.removeEnd(', ');
        query += ' FROM Call2_Discussion_vod__c WHERE Call2_vod__c=\'' + call.id + '\' order by Detail_Priority_gne__c';
        system.debug('getDiscussions query: ' + query);
        List<Call2_Discussion_vod__c> callDiscussions = Database.query(query);

        for (Call2_Discussion_vod__c callDiscussion : callDiscussions) {
            if (String.isEmpty(callDiscussion.zvod_Product_Map_vod__c)) {
                callDiscussion.zvod_Product_Map_vod__c = callDiscussion.Product_vod__r.Name;
            }
            result.add(new DiscussionWrapper(result.size(), callDiscussion, getStrategies(callDiscussion), getTactics(callDiscussion), prepController));
            if (String.isNotEmpty(callDiscussion.Product_vod__c) && isKeyMessagesSectionVisible && !isKeyMessageWrappersAlreadyAdded(callDiscussion.Product_vod__c)) {
                List<SelectOption>messages = getKeyMessagesWrappers(callDiscussion.Product_vod__c);
                if (!messages.isEmpty()) {
                    productToKeyMessagesWrappers.add(new ProductKeyMessageWrapper(callDiscussion.Product_vod__c, getProductName(callDiscussion.Product_vod__c), messages));
                }
            }
        }

        return result;
    }

    private List<MaterialWrapper>getMaterials(Call2_vod__c call, List<AttendeeWrapper>wrappers) {
        List<Id>allCallIds = new List<Id>();
        allCallIds.add(call.id);
        for (AttendeeWrapper wrapper : wrappers) {
            allCallIds.add(wrapper.attendee.id);
        }

        List<MaterialWrapper>result = new List<MaterialWrapper>();
        if (call == null || call.Id == null || !isMaterialsSectionVisible) {
            return result;
        }
        String query = 'SELECT Id, Call2_vod__c, ';
        for (SFA2_Configuration_Object_Detail_gne__c conf : materialsSectionFields) {
            query += conf.API_Name_gne__c;
            query += ', ';
        }
        query = query.removeEnd(', ');
        query += ' FROM Call2_Sample_vod__c WHERE Call2_vod__c in ' + GNE_SFA2_Util.createInListForQuery(allCallIds);
        System.debug(query);

        for (Call2_Sample_vod__c sample : Database.query(query)) {
            result.add(new MaterialWrapper(result.size(), sample));
        }
        return result;
    }

    List<AttachmentWrapper> getAttachments(Call2_vod__c call) {
        List<AttachmentWrapper>result = new List<AttachmentWrapper>();
        if (call == null || call.Id == null || !isAttachmentsSectionVisible) {
            return result;
        }
        String query = 'SELECT Id, Name, ';
        query = query.removeEnd(', ');
        query += ' FROM Attachment WHERE ParentId=\'' + call.id + '\'';
        System.debug(query);

        for (Attachment attachment : Database.query(query)) {
            result.add(new AttachmentWrapper(result.size(), attachment));
        }
        return result;
    }

    private List<KeyMessageWrapper> getKeyMessages(Call2_vod__c call) {
        List<KeyMessageWrapper>result = new List<KeyMessageWrapper>();
        if (call == null || call.Id == null || !isKeyMessagesSectionVisible) {
            return result;
        }
        String query = 'SELECT Id, Name, Key_Message_vod__c, Key_Message_vod__r.Name, Key_Message_vod__r.Description_vod__c, Reaction_vod__c, Product_vod__c, Product_vod__r.Name';
        query += ' FROM Call2_Key_Message_vod__c WHERE Call2_vod__c=\'' + call.id + '\'';
        System.debug(query);

        for (Call2_Key_Message_vod__c callKeyMessage : Database.query(query)) {
            selectedKeyMessages.add(callKeyMessage.Key_Message_vod__c   );
            result.add(new KeyMessageWrapper(result.size(), callKeyMessage));
        }
        return result;
    }

    private List<InteractionDetailWrapper> getInteractionDetails(Call2_vod__c call) {
        List<InteractionDetailWrapper> result = new List<InteractionDetailWrapper>();
        if (call == null || call.Id == null || !isInteractionDetailsSectionVisible) {
            return result;
        }
        String query = 'SELECT Id, Name, Visit_Reason_vod__c, Tactic_vod__c, Type_vod__c, Name_vod__c, Group_RAMA_vod__c, Strategy_RAMA_vod__c, Tactic_RAMA_vod__c, Tools_RAMA_vod__c';
        query += ' FROM Call2_Interaction_Detail_vod__c WHERE Call2_vod__c=\'' + call.id + '\'';
        System.debug(query);

        for (Call2_Interaction_Detail_vod__c interactionDetail : Database.query(query)) {
            result.add(new InteractionDetailWrapper(result.size(), interactionDetail));
        }
        return result;
    }

    private List<InteractionCategoryWrapper> getInteractionCategories(Call2_vod__c call) {
        List<InteractionCategoryWrapper> result = new List<InteractionCategoryWrapper>();
        if (call == null || call.Id == null || !isCategorySectionVisible) {
            return result;
        }
        List<Call2_Category_vod__c> callCategories = [SELECT Id, Brand_Above_Brand_gne__c, NOC_Status_gne__c, Molecule_gne__c, Indication_gne__c, Brand_Name_gne__c,
                                                     Therapeutic_Area_gne__c FROM Call2_Category_vod__c WHERE Call2_vod__c = :call.Id];
        for(Call2_Category_vod__c callCategory : callCategories) {
            result.add(new InteractionCategoryWrapper(result.size(), callCategory));
        }
        return result;
    }

    private Call2_Key_Message_vod__c getCallKeyMessage(Id callKeyMessageId) {
        return [SELECT id FROM Call2_Key_Message_vod__c where id = :callKeyMessageId];
    }

    private Address_vod__c getAddress(String addressId) {
        if (String.isNotEmpty(addressId)) {
            return [SELECT id, Name, Address_1_gne__c, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c, PFG_BDTD_gne__c FROM Address_vod__c WHERE id = :addressId];
        } else {
            return null;
        }
    }

    private List<SelectOption>getAddresses(Id accountId) {
        List<SelectOption>addresses = new List<SelectOption>();
        for (Address_vod__c address : [SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Account_vod__c = :accountId AND Inactive_vod__c = false order by Name]) {
            addresses.add(new SelectOption(address.id, GNE_SFA2_SearchAccounts_Controller.getAddressDesciption(address)));
        }
        return addresses;
    }

    private List<SelectOption>getStrategies(Call2_Discussion_vod__c call) {
        List<SelectOption>options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        if (String.isNotEmpty(call.Product_vod__c)) {
            List<Product_Strategy_vod__c> prodStrategies = [SELECT Id, Name, OwnerId FROM Product_Strategy_vod__c WHERE Product_Plan_vod__r.Product_vod__c = :call.Product_vod__c and Active_vod__c = true and Product_Plan_vod__r.Active_vod__c = true order by Name];
            for (Product_Strategy_vod__c strategy : prodStrategies) {
                options.add(new SelectOption(strategy.id, strategy.name));
            }
        }
        return options;
    }

    private List<SelectOption>getTactics(Call2_Discussion_vod__c call) {
        List<SelectOption>options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        List<Product_Tactic_vod__c> prodTactics = new List<Product_Tactic_vod__c>();

        if(omitStrategyMode==true && String.isNotEmpty(call.Product_vod__c)) {
            prodTactics = [SELECT Id, Name, OwnerId  FROM Product_Tactic_vod__c WHERE Product_Strategy_vod__r.Product_Plan_vod__r.Product_vod__c = :call.Product_vod__c and Active_vod__c = true and Product_Strategy_vod__r.Active_vod__c = true order by Name];
        } else if (omitStrategyMode!=true && String.isNotEmpty(call.Product_Strategy_vod__c)) {
            prodTactics = [SELECT Id, Name, OwnerId  FROM Product_Tactic_vod__c WHERE Product_Strategy_vod__r.Id = :call.Product_Strategy_vod__c and Active_vod__c = true and Product_Strategy_vod__r.Active_vod__c = true order by Name];
        }

        for (Product_Tactic_vod__c tactic : prodTactics) {
            options.add(new SelectOption(tactic.id, tactic.name));
        }

        return options;
    }

    private List<SelectOption>getRecipients(List<AttendeeWrapper> attendees) {
        List<SelectOption>options = new List<SelectOption>();
        List<Id>accountsIds = new List<Id>();
        if (callAccount == null) {
            return options;
        }
        if (callAccount.isPersonAccount) {
            options.add(new SelectOption(call.Account_vod__c, callAccount.Name));
        } else {
            options.add(new SelectOption('', '--None--'));
        }

        for (AttendeeWrapper wrapper : attendees) {
            if (wrapper.attendee.Account_vod__c != null) {
                accountsIds.add(wrapper.attendee.Account_vod__c);

            }/*else if(wrapper.attendee.Contact_vod__c!=null){
                contactsIds.add(wrapper.attendee.Contact_vod__c);
            } */
        }
        for (Account a : [SELECT Id, Name from Account WHERE id in :accountsIds]) {
            options.add(new SelectOption(a.Id, a.Name));
        }
        /*for(Contact c: [SELECT Id, Name from Contact WHERE id in :contactsIds]){
            options.add(new SelectOption(c.Id, c.Name));
        }*/
        return options;
    }

    private List<SelectOption>getProductOptions(List<ProductDetailWrapper>productWrappers) {
        List<SelectOption>result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));
        for (ProductDetailWrapper wrapper : productWrappers) {
            if (String.isNotEmpty(wrapper.callDetail.Product_vod__r.Name)) {
                result.add(new SelectOption(wrapper.callDetail.Product_vod__c, wrapper.callDetail.Product_vod__r.Name));
            }
        }
        return result;
    }

    public PageReference addAttachments() {
        String sbcURL = '/apex/GNE_SFA2_UploadAttachment?Id=' + call.Id + '&retURL=%2F' + call.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
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

    public List<SelectOption> getProductsCatalogs() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));
        List<Product_vod__c> availableProducts = [SELECT Id, Name FROM Product_vod__c WHERE Region_Code_gne__c = 2 AND Product_Type_vod__c = 'Detail' AND  Therapeutic_Area_vod__c = null AND active__c = true ORDER BY Name];
        for(Product_vod__c product : availableProducts) {
            result.add(new SelectOption(product.Name, product.Name));
        }
        return result;
    }

    public List<SelectOption> getTherapeuticsAreas() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', '--None--'));
        List<Product_vod__c> availableProducts = [SELECT Id, Name FROM Product_vod__c WHERE Region_Code_gne__c = 2 AND Product_Type_vod__c = 'Detail' AND  Therapeutic_Area_vod__c <> null AND active__c = true ORDER BY Name];
        for(Product_vod__c product : availableProducts) {
            result.add(new SelectOption(product.Name, product.Name));
        }
        return result;
    }

    public List<SelectOption> getTools() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('--None--','--None--'));
        List<Product_vod__c> availableTools = [SELECT Id, Name FROM Product_vod__c WHERE Parent_Product_vod__r.Name = 'Brand/Above Brand - RAMA only' AND Parent_Product_vod__r.Region_Code_gne__c = 2 and active__c = true];
        for(Product_vod__c tool : availableTools) {
            result.add(new SelectOption(tool.Name, tool.Name));
        }
        return result;
    }

    /*Wrapper Classes*/
    public class ProductDetailWrapper {
        public Integer index {get; set;}
        public Call2_Detail_vod__c callDetail {get; set;}

        public ProductDetailWrapper(Integer index, Call2_Detail_vod__c callDetail) {
            this.index = index;
            this.callDetail = callDetail;
        }
    }

    public class DiscussionWrapper {
        public Integer index {get; set;}
        public Call2_Discussion_vod__c callDiscussion {get; set;}
        public List<SelectOption>strategies {get; set;}
        public List<SelectOption>tactics {get; set;}
        private GNE_SFA2_PREP_Interaction_Controller prepCtrl;
        private Map<String, String> productToSavedMbo;

        public String defaultRecordTypeId {
            get {
                if (String.isBlank(defaultRecordTypeId)) {
                    defaultRecordTypeId = GNE_SFA2_Util.getDefaultRecordType('Call2_Discussion_vod__c');
                }
                return defaultRecordTypeId;
            }
            private set;
        }

        public Boolean multiSelectMoleculesEnabled {
            get {
                return (GNE_SFA2_Interaction_Util.getIsMSLORMCLUser() && String.isNotBlank(this.callDiscussion.zvod_Product_Map_vod__c)
                    && (this.callDiscussion.zvod_Product_Map_vod__c.containsIgnoreCase('Pipeline') || this.callDiscussion.zvod_Product_Map_vod__c.containsIgnoreCase('Portfolio')));
            }
        }

        public DiscussionWrapper(Integer index, Call2_Discussion_vod__c callDiscussion, List<SelectOption>strategies, List<SelectOption>tactics, GNE_SFA2_PREP_Interaction_Controller prepCtrl) {
            this.index = index;
            this.callDiscussion = callDiscussion;
            this.strategies = strategies;
            this.tactics = tactics;
            this.prepCtrl = prepCtrl;
            setFrmTeam();
        }

        public DiscussionWrapper(Integer index, GNE_SFA2_PREP_Interaction_Controller prepCtrl) {
            this.index = index;
            this.callDiscussion = new Call2_Discussion_vod__c();
            this.strategies = new List<SelectOption> {new SelectOption('', '--None--')};
            this.tactics = new List<SelectOption> {new SelectOption('', '--None--')};
            this.prepCtrl = prepCtrl;
            setFrmTeam();
        }

        public void setDefaultTopicValue(Boolean discussionTopicFieldExists){
            if (discussionTopicFieldExists){
                if (GNE_SFA2_Interaction_Util.getIsMSLORMCLUser()){
                    String productName = this.callDiscussion.zvod_Product_Map_vod__c;
                    if (String.isNotBlank(productName) && (productName.containsIgnoreCase('Pipeline') || productName.containsIgnoreCase('Portfolio'))){
                        this.callDiscussion.Topic_gne__c = null;
                    }
                }
            }
        }

        private void setFrmTeam() {
            GNE_SFA2_Call_Discussion_Field_Updates.FRMTeamSetName(new List<Call2_Discussion_vod__c>{this.callDiscussion});
        }

        public Boolean isPrepStrategyForProductInactive {
          get { return callDiscussion.Product_vod__c != null && prepCtrl != null && prepCtrl.inactiveProdByStratIds != null && prepCtrl.inactiveProdByStratIds.contains(callDiscussion.Product_vod__c) ? true : false; }
        }

        public List<SelectOption> getOnlySelectedProductForSelectOption {
          get { return new List<SelectOption>{ callDiscussion.Product_vod__c != null ? new SelectOption(callDiscussion.Product_vod__c, callDiscussion.zvod_Product_Map_vod__c) : new SelectOption('', '--None--') }; }
        }

        public List<SelectOption> getMbos(){
            if (productToSavedMbo == null){
              // cache already value set for product - it could be inactive mbo value
              productToSavedMbo = String.isNotBlank(callDiscussion.PREP_MBO_gne__c) ? new Map<String, String>{callDiscussion.Product_vod__c => callDiscussion.PREP_MBO_gne__c} : new Map<String, String>();
            }
            return this.prepCtrl.discussionWrapperGetMboSelectListForProduct(callDiscussion.Product_vod__c, productToSavedMbo.containsKey(callDiscussion.Product_vod__c) ? productToSavedMbo.get(callDiscussion.Product_vod__c) : null);
        }

        public DiscussionWrapper cloneWrapper(){
            DiscussionWrapper clonedWrapper = new DiscussionWrapper(this.index + 1, this.callDiscussion.clone(false, true), strategies.clone(), tactics.clone(), prepCtrl);
            return clonedWrapper;
        }
    }

    class MaterialWrapper {
        public Integer index {get; set;}
        public Call2_Sample_vod__c callSample {get; set;}

        public MaterialWrapper(Integer index, Call2_Sample_vod__c callSample) {
            this.index = index;
            this.callSample = callSample;
        }

        public MaterialWrapper(Integer index) {
            this.index = index;
            this.callSample = new Call2_Sample_vod__c();
            this.callSample.Quantity_vod__c = 1;
        }
    }

    class ActivityWrapper {
        public Integer index {get; set;}
        public String activityDate {get; set;}
        public Task task {get; set;}

        public ActivityWrapper(Integer index, Task task) {
            this.index = index;
            this.task = task;
            if (task.activityDate != null) {
                this.activityDate = task.activityDate.format();
            }
        }

        public ActivityWrapper(Integer index) {
            this.index = index;
            this.task = new Task();
            this.activityDate = Date.today().format();
        }
    }

    public class AttendeeWrapper {
        public Integer index {get; set;}
        public Call2_vod__c attendee {get; set;}
        public String attendeeType {get; set;}
        public String attendeeTypeFPM {get; set;}

        public AttendeeWrapper(Integer index, Call2_vod__c attendee) {
            this.index = index;
            this.attendee = attendee;
            this.attendeeTypeFPM = attendee.Attendee_Type_FPM_gne__c;

            Map<String, String> attTypeValueToLabelMap = getAttendeeTypeValueToLabelMap();

            String attType = attendee.Attendee_Type_vod__c != null ? attendee.Attendee_Type_vod__c.toUpperCase() : null;
            this.attendeeType = attTypeValueToLabelMap.containsKey(attType) ? attTypeValueToLabelMap.get(attType) : attType;

        }

        public AttendeeWrapper(Integer index, Call2_vod__c attendee, String attendeeTypeFPM) {
            this.index = index;
            this.attendee = attendee;
            this.attendeeTypeFPM = attendeeTypeFPM;
            Map<String, String> attTypeValueToLabelMap = getAttendeeTypeValueToLabelMap();

            String attType = attendee.Attendee_Type_vod__c != null ? attendee.Attendee_Type_vod__c.toUpperCase() : null;
            this.attendeeType = attTypeValueToLabelMap.containsKey(attType) ? attTypeValueToLabelMap.get(attType) : attType;
        }

        public AttendeeWrapper(Integer index) {
            this.index = index;
            this.attendee = new Call2_vod__c();
            this.attendeeType = null;
        }
    }

    class AttachmentWrapper {
        public Integer index {get; set;}
        public Attachment attachment {get; set;}

        public AttachmentWrapper(Integer index, Attachment attachment) {
            this.index = index;
            this.attachment = attachment;
        }

        public AttachmentWrapper(Integer index) {
            this.index = index;
            this.attachment = new Attachment();
        }
    }

    class ProductKeyMessageWrapper {
        public Id productId {get; set;}
        public String productName {get; set;}
        public List<SelectOption> keyMessages {get; set;}

        public ProductKeyMessageWrapper(Id productId, String productName, List<SelectOption> keyMessages) {
            this.productId = productId;
            this.keyMessages = keyMessages;
            this.productName = productName;
        }
    }

    class KeyMessageWrapper {
        public String productName {get; set;}
        public Id productId {get; set;}
        public Integer index {get; set;}
        public String name {get; set;}
        public String description {get; set;}
        public String reaction {get; set;}
        public Id keyMessageId {get; set;}
        public Id callKeyMessageId {get; set;}

        public KeyMessageWrapper(Integer index) {
            this.index = index;
        }

        public KeyMessageWrapper(Integer index, Id productId, String productName, Id callKeyMessageId, Id keyMessageId, String name, String description, String reaction) {
            this.index = index;
            this.productId = productId;
            this.productName = productName;
            this.callKeyMessageId = callKeyMessageId;
            this.keyMessageId = keyMessageId;
            this.name = name;
            this.description = description;
            this.reaction = reaction;
        }

        public KeyMessageWrapper(Integer index, Call2_Key_Message_vod__c callKeyMessage) {
            this.index = index;
            this.productId = callKeyMessage.Product_vod__c;
            this.productName = callKeyMessage.Product_vod__r.Name;
            this.callKeyMessageId = callKeyMessage.id;
            this.keyMessageId = callKeyMessage.Key_Message_vod__c;
            this.name = callKeyMessage.Key_Message_vod__r.Name;
            this.description = callKeyMessage.Key_Message_vod__r.Description_vod__c;
            this.reaction = callKeyMessage.Reaction_vod__c;
        }
    }

    class InteractionDetailWrapper {
        public Call2_Interaction_Detail_vod__c interactionDetail {get; set;}
        public Integer index {get; set;}

        public InteractionDetailWrapper(Integer index) {
            this.interactionDetail = new Call2_Interaction_Detail_vod__c();
            this.interactionDetail.Visit_Reason_vod__c = 'Strategic Objective';
            if(GNE_SFA2_Util.isCanadaRAMA()) {
                this.interactionDetail.Tools_RAMA_vod__c = '--None--';
            }
            this.index = index;
        }

        public InteractionDetailWrapper(Integer index, Call2_Interaction_Detail_vod__c callInteractionDetail) {
            this.index = index;
            this.interactionDetail = callInteractionDetail;
        }

        public InteractionDetailWrapper(Integer index, String visitReason) {
            this.index = index;
            this.interactionDetail = new Call2_Interaction_Detail_vod__c();
            this.interactionDetail.Visit_Reason_vod__c = visitReason;
        }
    }

    class InteractionCategoryWrapper {
        public Call2_Category_vod__c interactionCategory { get; set; }
        public Integer index { get; set; }

        public InteractionCategoryWrapper(Integer index) {
            this.interactionCategory = new Call2_Category_vod__c();
            this.index = index;
        }

        public InteractionCategoryWrapper(Integer index, Call2_Category_vod__c interactionCategory) {
            this.index = index;
            this.interactionCategory = interactionCategory;
        }

        public InteractionCategoryWrapper() {

        }
    }

    private class FieldVisibilityData {
        private String mField;
        private List<String> dFields;
        private List<FieldVisibilityRule> rules;
    }

    private class FieldVisibilityRule {
        private String pattern;
        private List<String> vFields;
    }

    private Boolean isDependendFieldVisible(SFA2_Configuration_Object_gne__c  sectionCo, SObject rec, String fieldName) {
        cacheFieldVisibilityData(sectionCo);
        Boolean isFieldVisible = !fieldVisibilityDependendFieldsCache.get(sectionCo.Name).contains(fieldName);

        if(!isFieldVisible) {
            List<FieldVisibilityData> fvDatas = fieldVisibilityDataCache.get(sectionCo.Name);

            for(FieldVisibilityData fvd : fvDatas) {
                if(new Set<String>(fvd.dFields).contains(fieldName)) {
                    isFieldVisible = false;
                    Object masterFieldValue = rec.get(fvd.mField);
                    masterFieldValue = fvd.mField == 'Product_Strategy_vod__c' ? getStrategyName((String)masterFieldValue) : masterFieldValue;
                    String masterFieldValueAsString = (masterFieldValue!=null ? String.valueOf(masterFieldValue) : '');

                    for(FieldVisibilityRule rule : fvd.rules) {
                        if(Pattern.matches(rule.pattern,masterFieldValueAsString) && new Set<String>(rule.vFields).contains(fieldName)) {
                            isFieldVisible = true;
                            break;
                        }
                    }
                }
            }
        }

        return isFieldVisible;
    }

    private String getStrategyName(String strategyId) {
        String strategyName = null;

        for (DiscussionWrapper wrapper : discussions) {
            for(SelectOption so : wrapper.strategies) {
                if(so.getValue() == strategyId) {
                    strategyName = so.getLabel();
                    break;
                }
            }

            if(strategyName!=null) {
                break;
            }
        }

        return strategyName;
    }

    private void cacheFieldVisibilityData(SFA2_Configuration_Object_gne__c  sectionCo) {
        if(fieldVisibilityDataCache==null) {
            fieldVisibilityDataCache = new Map<String,List<FieldVisibilityData>>();
            fieldVisibilityDependendFieldsCache = new Map<String,Set<String>>();
        }

        if(!fieldVisibilityDataCache.containsKey(sectionCo.Name)) {
            String dataJSON = String.isNotBlank(sectionCo.Attributes_gne__c) ? sectionCo.Attributes_gne__c.substringAfter('--visibilityDependentFields').substringBefore(' --') : null;
            Set<String> dependendFields = new Set<String>();
            List<FieldVisibilityData> fvDatas = new List<FieldVisibilityData>();

            if(String.isNotBlank(dataJSON)) {
                fvDatas = (List<FieldVisibilityData>)JSON.deserialize(dataJSON, List<FieldVisibilityData>.class);
                dependendFields = new Set<String>();

                for(FieldVisibilityData fvd : fvDatas) {
                    dependendFields.addAll(fvd.dFields);
                }
            }

            fieldVisibilityDataCache.put(sectionCo.Name, fvDatas);
            fieldVisibilityDependendFieldsCache.put(sectionCo.Name, dependendFields);
        }
    }

    //check if key messages for given products have been already added to collection
    private Boolean isKeyMessageWrappersAlreadyAdded(Id productId) {
        for (ProductKeyMessageWrapper pkWrapper : productToKeyMessagesWrappers) {
            if (productId == pkWrapper.productId) {
                return true;
            }
        }
        return false;
    }

    private SelectOption getProductOption(Id productId) {
        for (SelectOption o : availableProducts) {
            if (o.getValue() == productId) {
                return o;
            }
        }
        return null;
    }

    public Component.Apex.PageBlockButtons getCustomButtons() {
        String callId = null;
        Component.Apex.PageBlockButtons components;
        if (call != null && String.isNotEmpty(call.Id)) {
            callId = call.id;
        } else {
            callId = ApexPages.currentPage().getParameters().get('Id');
        }
        try {
            components = GNE_SFA2_DynamicVFLoader.getActiveCustomButtons(userApplicationContext, 'Call2_vod__c', getRecordTypeName(userApplicationContext, callId), callId);
        } catch (Exception e) {
            return new Component.Apex.PageBlockButtons();
        }
        return components;
    }

    private List<Id>getAttendesFromAffiliatedAccounts(List<AttendeeWrapper> attendees, List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> affiliatedAccounts) {
        List<Id> result = new List<Id>();
        for (AttendeeWrapper attendeeWrapper : attendees) {
            for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper accountWrapper : affiliatedAccounts) {
                if (String.isNotEmpty(attendeeWrapper.attendee.Account_vod__c) && attendeeWrapper.attendee.Account_vod__c == accountWrapper.accountId) {
                    result.add(attendeeWrapper.attendee.Account_vod__c);
                    break;
                } else if (String.isNotEmpty(attendeeWrapper.attendee.Contact_vod__c) && attendeeWrapper.attendee.Contact_vod__c == accountWrapper.accountId) {
                    result.add(attendeeWrapper.attendee.Contact_vod__c);
                    break;
                }
            }
        }
        return result;
    }

    private void copyFieldsValuesFromParentToChildCall(Call2_vod__c parentCall, Call2_vod__c child, Map<String, Schema.SObjectField> sObjectFieldMap) {
        Set<String>uncopiedFields = new Set<String> {'Id', 'Parent_Call_vod__c', 'Account_vod__c', 'Contact_vod__c', 'User_vod__c', 'EMS_International_Speaker_gne__c', 'Name', 'HCP_Attendee_Meal_Opt_Out_gne__c', 'HCP_Account_Meal_Opt_Out_gne__c'};
        for (SFA2_Configuration_Object_gne__c configObject : callSectionsList) {
            if (configObject.Name == 'CallDetail' || configObject.Name == 'CallDetailInformation' || configObject.Name == 'CallMealExpense' || configObject.Name == 'CallVisitReason') {
                for (SFA2_Configuration_Object_Detail_gne__c configObj : callSectionsMap.get(configObject.id)) {
                    if (configObj.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD) {
                        sObjectField field = sObjectFieldMap.get(configObj.API_Name_gne__c);
                        if (field.getDescribe().isUpdateable() && !uncopiedFields.contains(configObj.API_Name_gne__c)) {
                            child.put(configObj.API_Name_gne__c, parentCall.get(configObj.API_Name_gne__c));
                        }
                    }
                }
            }
        }

        for (String field : requiredFields) {
            if (!uncopiedFields.contains(field)) {
                child.put(field, parentCall.get(field));
            }
        }
    }

    private Call2_vod__c queryCall(String callId) {
        Set<String>queriedFields = new Set<String>();
        for (SFA2_Configuration_Object_gne__c configObject : callSectionsList) {
            if (configObject.Name == 'CallDetail' || configObject.Name == 'CallDetailInformation' || configObject.Name == 'CallMealExpense' || configObject.Name == 'CallVisitReason' || configObject.Name == 'CallAttendees' || configObject.Name == 'CallObjectives' || configObject.Name == 'CallAccessEcho' || configObject.Name == 'CallNotes') {
                for (SFA2_Configuration_Object_Detail_gne__c configObj : callSectionsMap.get(configObject.id)) {
                    if (configObj.Type_gne__c == GNE_SFA2_DynamicVFLoader.FIELD && !(configObject.Name == 'CallObjectives' && configObj.Attributes_gne__c != '--callField') ) {
                        queriedFields.add(configObj.API_Name_gne__c);
                    }
                }
            }
        }

        queriedFields.addAll(requiredFields);
        String query = String.format('SELECT {0} FROM Call2_vod__c WHERE Id = :callId', new String[] {String.join(new List<String>(queriedFields), ', ')});
        system.debug(query);
        return Database.query(query);
    }

    private Account getCallAccount() {
        String callId = ApexPages.currentPage().getParameters().get('Id');
        String accountId = ApexPages.currentPage().getParameters().get('accountId');
        String referralId = ApexPages.currentPage().getParameters().get('referralId');
        Account callAccount = null;
        if (callId != null) {
            //hack if user has no permission to account
            Call2_vod__c call = [SELECT Account_vod__c FROM Call2_vod__c where id = :callId];
            List<Account> callAccounts = [SELECT id, Name, isPersonAccount, RecordType.DeveloperName FROM Account WHERE id = :call.Account_vod__c];
            if (callAccounts != null & callAccounts.size() > 0) {
                callAccount = callAccounts[0];
            } else {
                callAccount = new Account();
            }
        } else if (accountId != null) {
            callAccount = [SELECT id, Name, isPersonAccount, RecordType.DeveloperName FROM Account WHERE ID = :accountId];
        } else if (referralId != null) {
            callAccount = referralInteractionController.getAccountFromReferral();
            isCreatedFromReferral = true;
        }
        return callAccount;
    }

    public String getTempParentIdToNewAttachment() {
        SFA2_User_Preferences_gne__c result = [SELECT Id FROM SFA2_User_Preferences_gne__c limit 1];
        return result.Id;
    }

    public void removeTemporaryAttachments() {
        List<Attachment> attachmentsToRemove = [SELECT Id, ParentId FROM Attachment WHERE ParentId = : tempAttachmentParentId AND Description = : temporaryCallId];
        delete attachmentsToRemove;
    }

    public String getBestDaysToDeliver() {
        return getBestDaysToDeliver(isCompleted, call.Id, call.Parent_Address_vod__c);
    }

    @RemoteAction @ReadOnly
    public static String getBestDaysToDeliver(Boolean isCompleted, String callId, String addrId) {
        String result = null;

        if (isCompleted) {
            result = [SELECT PFG_BDTD_calc_gne__c FROM Call2_vod__c WHERE Id = :callId].PFG_BDTD_calc_gne__c;
        } else if (String.isNotBlank(addrId)) {
            result = [SELECT PFG_BDTD_calc_gne__c FROM Address_vod__c WHERE Id = :addrId].PFG_BDTD_calc_gne__c;
        }


        return result != null ? result : '';
    }

    public static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchInternationalSpeakers(String searchString, Integer recordLimit) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
        for (EMS_International_Speaker_gne__c ihcp : [ SELECT Id, Name, First_Name_gne__c, Last_Name_gne__c, Address_gne__c, Country_gne__c FROM EMS_International_Speaker_gne__c WHERE First_Name_gne__c LIKE :searchString OR Last_Name_gne__c LIKE :searchString OR Name LIKE :searchString LIMIT :recordLimit ] ) {
            GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper = new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(new Account(), null);
            wrapper.accountId = ihcp.Id;
            wrapper.accountDescription = ihcp.Last_Name_gne__c + ', ' + ihcp.First_Name_gne__c;
            wrapper.recordType = 'iHCP';
            if (ihcp.Country_gne__c != null && ihcp.Address_gne__c != null) {
                wrapper.addressDescription = ihcp.Address_gne__c + ', ' + ihcp.Country_gne__c;
            } else if(ihcp.Country_gne__c != null) {
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

    private static Boolean isFrmUser() {
        return Pattern.matches('GNE-MCCO-FRM-\\wFRM-{0,1}\\w*', GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase());
    }

    public PageReference goToDrafts() {
        List<SFA2_View_Config_gne__c> draftView = [SELECT Id FROM SFA2_View_Config_gne__c WHERE Page_Name_gne__c = 'My Insights' AND View_Name_gne__c = 'Drafts' AND Visibility_gne__c = 'restricted' limit 1];
        if (!draftView.isEmpty()) {
            List<SFA2_User_Preferences_gne__c> userPrefs = [SELECT Last_View_Used_gne__c
                                                            FROM  SFA2_User_Preferences_gne__c
                                                            WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Insights'
                                                            AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
            if (!userPrefs.isEmpty()) {
                userPrefs[0].Last_View_Used_gne__c = draftView[0].Id;
                update userPrefs;
            }
        }

        return new PageReference('/apex/GNE_FRM_Market_Insights_MyInsights');
    }

    public boolean getHasValidationMessages() {
        return !validationMessagesSummary.isEmpty();
    }
}