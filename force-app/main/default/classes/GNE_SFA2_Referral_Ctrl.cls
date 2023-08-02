global without sharing class GNE_SFA2_Referral_Ctrl extends GNE_SFA2_Base_Ctrl {
    private transient GNE_SFA2_ReferralUtil.AutoAssignmentFailedException aaException;
    private transient GNE_SFA2_ReferralUtil.ReferralWrapper referral;
    
    public GNE_SFA2_Referral_Ctrl(ApexPages.StandardController sctrl) {
        this();
    }

    public GNE_SFA2_Referral_Ctrl() {
        super();
    }
    
    protected override GNE_SFA2_Base_Ctrl.DataWrapper intInit(Map<String, String> params) {
        this.params = params.clone();
        this.params.put('sObjectType', 'Medical_Communication_gne__c');
        this.activeMenuItem = 'My Accounts';
        this.pageExtId = 'referral';

        return super.intInit(this.params);
    }
    
    protected override String getMode() {
        this.mode = super.getMode();
        if (!GNE_SFA2_Util.isCanadaUser()){
        	this.mode = this.mode==GNE_SFA2_Base_Ctrl.EDIT_MODE ? GNE_SFA2_Base_Ctrl.VIEW_MODE : this.mode;
        }
        return this.mode;
    }
    
    protected override Boolean pageDispatcher() {
        return (uiType=='sfa2' && !isRedirectMAFromEmailMode() && !isRedirectMAToCreatePage() && !isRedirectMAToViewPage())
                || (uiType == 'standard' && (GNE_SFA2_Util.isBamCrmUser() || GNE_SFA2_Util.isMccoCrmUser() || GNE_SFA2_Util.isSfaCCUser()));
    }

    protected override void checkRecordAccess(RecordAccess rAccess) {
        if (GNE_SFA2_Util.isCanadaUser() && (this.mode == GNE_SFA2_Base_Ctrl.EDIT_MODE || this.mode == GNE_SFA2_Base_Ctrl.VIEW_MODE)){
            String ownerId = getMedComm().Referral_Assignment_gne__r.OwnerId;
            String assigneId = getMedComm().Referral_Assignment_gne__r.Assigned_To_gne__c;
            Boolean isCanadaDirectorUser = GNE_SFA2_Util.isCanadaDirectorUser();
            Boolean isCanadaRMLUser = GNE_SFA2_Util.isCanadaRMLUser();
            Boolean isCanadaOpsUser = GNE_SFA2_Util.isCanadaOPSUser();
            String refStatus = getMedComm().Referral_Assignment_gne__r.Status_Referral_gne__c;
                                    
            if (this.mode == GNE_SFA2_Base_Ctrl.EDIT_MODE){
                if (getClosedStatusesForCanada().contains(refStatus) && !isCanadaOpsUser){
                    throw createException(new RecordPermissionErrorException(), new Object[] {'Edit', currentUser.name});
                } else if (isCanadaOpsUser || ((UserInfo.getUserId() == assigneId || isCanadaDirectorUser || isCanadaRMLUser) && !getClosedStatusesForCanada().contains(refStatus))){
                    // Assignee is able to edit referral
                } else if (UserInfo.getUserId() != assigneId && !isCanadaDirectorUser && !isCanadaRMLUser && !isCanadaOpsUser){
                    throw createException(new RecordPermissionErrorException(), new Object[] {'Edit', currentUser.name});
                } else {
                    super.checkRecordAccess(rAccess);
                }
            } else if (this.mode == GNE_SFA2_Base_Ctrl.VIEW_MODE){
                super.checkRecordAccess(rAccess);
            }
        } else {
            super.checkRecordAccess(rAccess);
        }        
    }

    private Medical_Communication_gne__c getMedComm(){
        return (Medical_Communication_gne__c)record;
    }

    private Set<String> getClosedStatusesForCanada(){
        return new Set<String>{
            GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_HCPU_CANADA,
            GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_NOTV_CANADA,
            GNE_SFA2_ReferralUtil.REFERRAL_STATUS_FULFILLED_CANADA
        };
    }
    
    private Boolean isRedirectMAFromEmailMode() {
        return isMAUser() && params.get('email')=='1' && GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_EMAIL_REDIRECT);
    }
    
    private Boolean isRedirectMAToCreatePage() {
        return isMAUser() && getMode()==GNE_SFA2_Base_Ctrl.NEW_MODE && !GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE);
    }
    
    private Boolean isRedirectMAToViewPage() {
        return isMAUser() && getMode()==GNE_SFA2_Base_Ctrl.VIEW_MODE && !GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE);
    }
    
    private Boolean isMAUser() {
        return getCurrentUser().getProfileName().startsWithIgnoreCase(GNE_SFA2_ReferralUtil.MA_PROFILE_PREFIX);
    }
    
    protected override PageReference getDispatcherOtherPage() {
        PageReference createPagePrevVersion = Page.GNE_SFA2_CreateReferralPage;
        PageReference result = isRedirectMAFromEmailMode() ? getMARedirectErrorPage()
            : isRedirectMAToCreatePage() ? createPagePrevVersion
            : isRedirectMAToViewPage() ? Page.GNE_SFA2_Referral_Layout
            : Page.GNE_ViewReferralPage;
            
        if(result==createPagePrevVersion) {
            result.getParameters().put('AccId', params.get('accountId'));
        }
        
        return result;
    }
    
    private PageReference getMARedirectErrorPage() {
        String redirectPageUrl = GNE_SFA2_S2S_Config.getConfigItemValue(GNE_SFA2_ReferralUtil.S2S_CONFIG_ITEM_REFERRAL_REDIRECT_URL);
        redirectPageUrl = String.isNotBlank(redirectPageUrl) && redirectPageUrl.startsWith('/') ? (GNE_SFA2_S2S_Config.getConfigItemValue(GNE_SFA2_ReferralUtil.S2S_CONFIG_ITEM_EXT_SYSTEM_BASE_URL) + redirectPageUrl) : redirectPageUrl;
        return String.isNotBlank(redirectPageUrl) ? new PageReference(redirectPageUrl) : null;
    }
    
    protected override virtual GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }
    
    protected virtual override Map<String,String> getTranslationsMap() {
        return new Map<String,String>{
            'pageTitleNew' => 'Submit New Medical Referral',
            'pageTitleEdit' => 'Edit Medical Referral',
            'pageTitleView' => 'Referral View',
            'buttonCancel' => 'Cancel',
            'buttonSubmit' => 'Submit',
            'buttonEdit' => 'Edit',
            'buttonSave' => 'Save',
            'manualAssigneePopupTitle' => 'Lookup',
            'manualAssigneeColumnUser' => 'User',
            'manualAssigneeColumnTitle' => 'Title',
            'manualAssigneeColumnPhone' => 'Phone',
            'manualAssigneeColumnEmail' => 'Email',
            'manualAssigneeColumnTherapeuticArea' => 'Therapeutic Area',
            'manualAssigneeColumnState' => 'State',
            'manualAssigneeColumnProfile' => 'Profile',
            'taAutoAssignmentNotSupported' => String.format(System.Label.GNE_SFA2_Referral_Error_AutoAssignmentNotSupported, new String[]{getTaLabel()}),
            'assigneeNameIsNotValid' => System.Label.GNE_SFA2_Referral_Error_NoMatchingUser
        };
    }
    
    protected override RecordType getRecordType(Boolean isNewMode) {
        RecordType result = null;
        
        if(isNewMode) {
            for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE Id = :GNE_SFA2_ReferralUtil.getReferralRecordType()]) {
                result = rt;
            }
        } else {
            result = super.getRecordType(isNewMode);
        }
        
        return result;
    }
    
    protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapper(GNE_SFA2_Base_Ctrl.DataWrapper dataWrapper) {
        sObjectType = 'Medical_Communication_gne__c';
        DataWrapper result = (DataWrapper)dataWrapper;
        
        if(getMode()==GNE_SFA2_Base_Ctrl.NEW_MODE) {
	        result.account = getAccount();
	        result.assigneeUsers = getAssigneeUsers();
	        List<GNE_SFA2_ReferralUtil.ReferralProduct> rProds = getProductRecords();
	        result.products = getProducts(rProds);
	        result.tas = getTAs(rProds);
	        result.molecules = getMolecules(rProds);
        } else if(getMode()==GNE_SFA2_Base_Ctrl.EDIT_MODE) {
	        result.assigneeUsers = getAssigneeUsers();
        }
        
        result = (DataWrapper)super.getDataWrapper(result);
        result.showEditButton = (currentUser.isCanada() && 
        	(getMode() == GNE_SFA2_Base_Ctrl.VIEW_MODE || getMode() == GNE_SFA2_Base_Ctrl.EDIT_MODE) && 
        	(GNE_SFA2_Util.isCanadaOpsUser() ||
        	((UserInfo.getUserId() == getMedComm().Referral_Assignment_gne__r.Assigned_To_gne__c || GNE_SFA2_Util.isCanadaDirectorUser() || GNE_SFA2_Util.isCanadaRMLUser()) &&
        	!getClosedStatusesForCanada().contains(getMedComm().Referral_Assignment_gne__r.Status_Referral_gne__c)))
        );
        return result;
    }
    
    private AccountWrapper getAccount() {
        AccountWrapper result = null;
        Id accId = (Id)checkInputParam('accountId');
        Set<Id> hiddenAddrIds = getHiddenAddressIds(accId);
        
        List<Account> accs = GNE_SFA2_S2S_Util.getAccountRecords(new Set<Id>{accId}, null, null, null, null, null, true, false);
        
        result = !accs.isEmpty() ? new AccountWrapper(accs[0], hiddenAddrIds) : null;
        
        if(result==null) {
            throw createException(new NoAccountFoundException());
        } else if(result.addresses.isEmpty()) {
            dataWrapper.addError(createException(new NoAddressesFoundException(), new List<Object>{'Medical Referral'}), false);
        }
        
        return result;
    }
    
    private Set<Id> getHiddenAddressIds(Id accId) {
        return (new GNE_SFA2_UserPreference_Ctrl()).getHiddenAddressIds(getCurrentUser().id, accId);
    }
    
    private List<GNE_SFA2_ReferralUtil.AssigneeUser> getAssigneeUsers() {
        return GNE_SFA2_ReferralUtil.getManualAssigneeUsers();
    }
    
    private List<GNE_SFA2_ReferralUtil.ReferralProduct> getProductRecords() {
        return GNE_SFA2_ReferralUtil.getProducts();
    }
    
    private List<BrandProduct> getProducts(List<GNE_SFA2_ReferralUtil.ReferralProduct> rProds) {
        List<BrandProduct> result = new List<BrandProduct>();
        
        for(GNE_SFA2_ReferralUtil.ReferralProduct rProd : rProds) {
            if(rProd.isBrand()) {
	            BrandProduct prod = new BrandProduct(rProd);
	            result.add(prod);
            }
        }
        
        return result;
    }
    
    private List<TA> getTAs(List<GNE_SFA2_ReferralUtil.ReferralProduct> rProds) {
        List<TA> result = new List<TA>();
        
        for(GNE_SFA2_ReferralUtil.ReferralProduct rProd : rProds) {
            if(rProd.isTA()) {
                TA prod = new TA(rProd);
                result.add(prod);
            }
        }
        
        return result;
    }
    
    private List<Molecule> getMolecules(List<GNE_SFA2_ReferralUtil.ReferralProduct> rProds) {
        List<Molecule> result = new List<Molecule>();
        
        for(GNE_SFA2_ReferralUtil.ReferralProduct rProd : rProds) {
            if(rProd.isMolecule()) {
                Molecule prod = new Molecule(rProd);
                result.add(prod);
            }
        }
        
        return result;
    }
    
    protected override Set<String> getQueryFields(List<SFA2_Configuration_Object_gne__c> configObjects) {
        String refAssignmentPrefix = 'Referral_Assignment_gne__r.';
        String refAssignedToPrefix = 'Assigned_To_gne__r.';
        return new Set<String>{
            refAssignmentPrefix + String.valueOf(Referral_Assignment_gne__c.Id),
            refAssignmentPrefix + String.valueOf(Referral_Assignment_gne__c.OwnerId),
            refAssignmentPrefix + String.valueOf(Referral_Assignment_gne__c.Name),
            refAssignmentPrefix + String.valueOf(Referral_Assignment_gne__c.Revised_Requested_Completion_Date_gne__c),
            refAssignmentPrefix + String.valueOf(Referral_Assignment_gne__c.Assigned_To_gne__c),
            refAssignmentPrefix + refAssignedToPrefix + 'Name',
            refAssignmentPrefix + refAssignedToPrefix + 'ManagerId',
            refAssignmentPrefix + String.valueOf(Referral_Assignment_gne__c.Status_Referral_gne__c),
            String.valueOf(Medical_Communication_gne__c.Name),
            String.valueOf(Medical_Communication_gne__c.Referral_Assignment_gne__c),
            String.valueOf(Medical_Communication_gne__c.RecordTypeId), 
            String.valueOf(Medical_Communication_gne__c.Account_gne__c), 'Account_gne__r.Name',
            String.valueOf(Medical_Communication_gne__c.Address_Line_1_gne__c),
            String.valueOf(Medical_Communication_gne__c.Phone_gne__c),
            String.valueOf(Medical_Communication_gne__c.Phone_1_gne__c),
            String.valueOf(Medical_Communication_gne__c.Email_gne__c),
            String.valueOf(Medical_Communication_gne__c.Fax_gne__c),
            String.valueOf(Medical_Communication_gne__c.Product_Name_gne__c),
            String.valueOf(Medical_Communication_gne__c.TA_SubTA_Name_gne__c),
            String.valueOf(Medical_Communication_gne__c.Molecule_Name_gne__c),
            String.valueOf(Medical_Communication_gne__c.Medical_Question_gne__c),
            String.valueOf(Medical_Communication_gne__c.Follow_up_Method_gne__c),
            String.valueOf(Medical_Communication_gne__c.Priority_gne__c),
            String.valueOf(Medical_Communication_gne__c.Language_of_Preference_can_gne__c),
            String.valueOf(Medical_Communication_gne__c.Requested_Completion_Date_gne__c),
            String.valueOf(Medical_Communication_gne__c.Unsolicited_Request_Verified_gne__c),
            String.valueOf(Medical_Communication_gne__c.Unsolicited_Request_Verified_Date_gne__c),
            String.valueOf(Medical_Communication_gne__c.Unsolicited_Request_Verified_By_gne__c), 'Unsolicited_Request_Verified_By_gne__r.Name',
            String.valueOf(Medical_Communication_gne__c.Requested_By_gne__c), 'Requested_By_gne__r.Name',
            String.valueOf(Medical_Communication_gne__c.Referral_Source_gne__c),
            String.valueOf(Medical_Communication_gne__c.Is_MedComm_gne__c),
            String.valueOf(Medical_Communication_gne__c.Comments_Referral_gne__c),
            String.valueOf(Medical_Communication_gne__c.Referral_History_gne__c),
            String.valueOf(Medical_Communication_gne__c.City_gne__c),
            String.valueOf(Medical_Communication_gne__c.Province_can_gne__c)            
        };
    }
    
    protected override String getRecordQueryWhereExpression() {
        return 'Referral_Assignment_gne__c =: recordId';
    }
    
    protected override GNE_SFA2_Base_Ctrl.Config getConfiguration(String recordTypeDeveloperName) {
        record = getRecord(null);
	    DataWrapper resultData = (DataWrapper)dataWrapper;
	    AccountWrapper acc = resultData.account;
	    fieldsMap = new Map<String,GNE_SFA2_Base_Ctrl.Field> {
	        'mcName' => new GNE_SFA2_Base_Ctrl.Field('View Referral - ID', null, true, false),
	        'refName' => new GNE_SFA2_Base_Ctrl.Field('Medical Referral Name', null, true, false),
	        
	        'account' => new GNE_SFA2_Base_Ctrl.Field('HCP Name', null, true, false),
	        'address' => new GNE_SFA2_Base_Ctrl.Field('Address', null, false, true),
	        'phone' => new GNE_SFA2_Base_Ctrl.Field('Phone', null, false, false),
	        'mobilePhone' => new GNE_SFA2_Base_Ctrl.Field(currentUser.isCanada() ? 'Cell Phone' : 'Mobile Phone', null, true, false),
	        'email' => new GNE_SFA2_Base_Ctrl.Field('Email', null, true, false),
	        'fax' => new GNE_SFA2_Base_Ctrl.Field('Fax', null, true, false),
	        
	        'assignmentType' => new GNE_SFA2_Base_Ctrl.Field('Assignment Type', null, false, true),
	        'assignee' => new GNE_SFA2_Base_Ctrl.Field('Assigned To', null, false, true),
	        
	        'product' => new GNE_SFA2_Base_Ctrl.Field(currentUser.isCanada() ? 'Product/Therapeutic Area' : 'Brands/Products', null, false, false),
	        'ta' => new GNE_SFA2_Base_Ctrl.Field(getTaLabel(), null, false, true),
	        'molecule' => new GNE_SFA2_Base_Ctrl.Field('Molecules', null, false, false),
	        
	        'question' => new GNE_SFA2_Base_Ctrl.Field('Question/Request', null, false, true),
	        'followUpMethod' => new GNE_SFA2_Base_Ctrl.Field('Follow-up Method', null, false, true),
	        'priority' => new GNE_SFA2_Base_Ctrl.Field('Priority', null, false, true),
	        'language' => new GNE_SFA2_Base_Ctrl.Field('Language', null, false, true),
	        'reqCompletionDate' => new GNE_SFA2_Base_Ctrl.Field('Requested Completion Date', null, false, false),
	        'revCompletionDate' => new GNE_SFA2_Base_Ctrl.Field('Revised Completion Date', null, true, false),
	        'reqVerified' => new GNE_SFA2_Base_Ctrl.Field('Unsolicited Request Verified', null, true, false),
	        'reqVerifiedDate' => new GNE_SFA2_Base_Ctrl.Field('Unsolicited Request Verified Date', null, true, false),
	        'reqVerifiedBy' => new GNE_SFA2_Base_Ctrl.Field('Unsolicited Request Verified By', null, true, false),
	        
	        'requestor' => new GNE_SFA2_Base_Ctrl.Field('Requested By', null, true, false),
	        'source' => new GNE_SFA2_Base_Ctrl.Field(currentUser.isCanada() ? 'Referral Title' : 'Referral Source', null, true, false),
	        
	        'assignedTo' => new GNE_SFA2_Base_Ctrl.Field('Assigned To', null, true, false),
	        'status' => new GNE_SFA2_Base_Ctrl.Field('Status', null, true, false),
	        'comment' => new GNE_SFA2_Base_Ctrl.Field('Comments', null, false, false),
	        'city' => new GNE_SFA2_Base_Ctrl.Field('City', null, true, false),
	        'provinceCan' => new GNE_SFA2_Base_Ctrl.Field('Province', null, true, false)
	    };
	    
	    for(String fieldKey : fieldsMap.keySet()) {
	        GNE_SFA2_Base_Ctrl.Field fld = fieldsMap.get(fieldKey);
	        setFieldProperties(fieldKey, fld);
	    }
	    
	    Integer sectionOrder = 0;
	    List<GNE_SFA2_Base_Ctrl.Section> sections = new List<GNE_SFA2_Base_Ctrl.Section>();
	    
	    List<GNE_SFA2_Base_Ctrl.Field> sFields = new List<GNE_SFA2_Base_Ctrl.Field>();
        if (!currentUser.isCanada()){
        	sFields.add(fieldsMap.get('mcName'));
        }
        sFields.add(fieldsMap.get('refName'));
        sections.add(new GNE_SFA2_Base_Ctrl.Section('referralInformation', 'Referral Information', sectionOrder++, null, sFields));
        
        sFields = new List<GNE_SFA2_Base_Ctrl.Field>();
        sFields.add(fieldsMap.get('account'));
		sFields.add(fieldsMap.get('address'));
		sFields.add(fieldsMap.get('phone'));
		sFields.add(fieldsMap.get('mobilePhone'));
		sFields.add(fieldsMap.get('email'));
		sFields.add(fieldsMap.get('fax'));
		if (currentUser.isCanada() && (getMode() == GNE_SFA2_Base_Ctrl.VIEW_MODE || getMode() == GNE_SFA2_Base_Ctrl.EDIT_MODE)){
			sFields.add(fieldsMap.get('city'));	
			sFields.add(fieldsMap.get('provinceCan'));
		}
        sections.add(new GNE_SFA2_Base_Ctrl.Section('hcpInformation', 'HCP Information', sectionOrder++, null, sFields));

		if (!currentUser.isCanada() || getMode() != GNE_SFA2_Base_Ctrl.EDIT_MODE) {
		    sFields = new List<GNE_SFA2_Base_Ctrl.Field>();
		    if (!currentUser.isCanada()){
		    	sFields.add(fieldsMap.get('assignmentType'));
		    }
		    sFields.add(fieldsMap.get('assignee'));
		    sections.add(new GNE_SFA2_Base_Ctrl.Section('referralAssignment', 'Referral Assignment', sectionOrder++, null, sFields));
		}
		
	    sFields = new List<GNE_SFA2_Base_Ctrl.Field>();
	    sFields.add(fieldsMap.get('product'));
	    if (!currentUser.isCanada()){
	    	sFields.add(fieldsMap.get('ta'));
	    	sFields.add(fieldsMap.get('molecule'));
	    }
	    sFields.add(fieldsMap.get('question'));
	    sFields.add(fieldsMap.get('followUpMethod'));
	    sFields.add(fieldsMap.get('priority'));
	    if (currentUser.isCanada()){
	    	sFields.add(fieldsMap.get('language'));
	    }
	    sFields.add(fieldsMap.get('reqCompletionDate'));
        sFields.add(fieldsMap.get('revCompletionDate'));
	    if (!currentUser.isCanada()){
	    	sFields.add(fieldsMap.get('reqVerified'));
		    sFields.add(fieldsMap.get('reqVerifiedDate'));
		    sFields.add(fieldsMap.get('reqVerifiedBy'));
	    }
	    sections.add(new GNE_SFA2_Base_Ctrl.Section('referralInfo', (!currentUser.isCanada() ? 'Brand/Molecule Information' : 'Product/Therapeutic Area Information'), sectionOrder++, null, sFields));

		if (!(currentUser.isCanada() && getMode() == GNE_SFA2_Base_Ctrl.VIEW_MODE)) {
	    	sections.add(
	    		new GNE_SFA2_Base_Ctrl.Section('requestorInfo', 'Referral Submitted By', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
	            	fieldsMap.get('requestor'),
	            	fieldsMap.get('source')
	        	})
	    	);
		}
		
		if (!(currentUser.isCanada() && getMode() == GNE_SFA2_Base_Ctrl.VIEW_MODE)) {
	    	sFields = new List<GNE_SFA2_Base_Ctrl.Field>();
	    	sFields.add(fieldsMap.get('assignedTo'));
	    	if (!currentUser.isCanada()){
	    		sFields.add(fieldsMap.get('status'));
	    	}	    	
	    	sections.add(new GNE_SFA2_Base_Ctrl.Section('assignmentStatusInfo', currentUser.isCanada() ? 'Referral Assignment' : 'Referral Assignment and Status', sectionOrder++, null, sFields));
		}
	    	    
		if (currentUser.isCanada() && getMode() == GNE_SFA2_Base_Ctrl.EDIT_MODE) {
		    sFields = new List<GNE_SFA2_Base_Ctrl.Field>();
		    sFields.add(fieldsMap.get('assignmentType'));
		    sFields.add(fieldsMap.get('assignee'));
		    sections.add(new GNE_SFA2_Base_Ctrl.Section('referralAssignment', 'Referral Assignment', sectionOrder++, null, sFields));
		    
		    sections.add(
	        	new GNE_SFA2_Base_Ctrl.Section('actionStatusInformation', 'Action and Status', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
		            fieldsMap.get('status'),
		            fieldsMap.get('comment')
		        })
		    );
		}
		
	    if(getMode()==GNE_SFA2_Base_Ctrl.NEW_MODE) {
	        String columnsArg = 'cols[1]';
	        
            for(GNE_SFA2_Base_Ctrl.Section sec : sections) {
                sec.attributeFlags = new Set<String>{columnsArg};
                sec.attributes = ' --' + columnsArg;    
            }
	    }
	    
	    List<GNE_SFA2_Base_Ctrl.RelatedList> relatedLists = new List<GNE_SFA2_Base_Ctrl.RelatedList>();
	    prepareHistoryRelatedLists(relatedLists);
        prepareCommentsRelatedLists(relatedLists);
        
        return new GNE_SFA2_Base_Ctrl.Config(mode, new List<GNE_SFA2_Base_Ctrl.Button>(), sections, relatedLists);
    }
    
    private String getTaLabel() {
        return GNE_SFA2_S2S_Util.isFeatureEnabled(GNE_SFA2_ReferralUtil.FEATURE_REFERRAL_CREATE) ? 'TA' : 'TA-SubTA';
    }

    private void setFieldProperties(String fieldKey, GNE_SFA2_Base_Ctrl.Field fld) {
        DataWrapper resultData = (DataWrapper)dataWrapper;
        Medical_Communication_gne__c medComm = (Medical_Communication_gne__c)record;
        GNE_SFA2_Base_Ctrl.FieldDescribe describe = new GNE_SFA2_Base_Ctrl.FieldDescribe();
        describe.name = fieldKey;
        
        String mode = getMode();
        Boolean isNewMode = mode==GNE_SFA2_Base_Ctrl.NEW_MODE;
        Boolean isEditMode = mode==GNE_SFA2_Base_Ctrl.EDIT_MODE;
                
        Boolean isCanadaOPSUser = false;
        
        if (currentUser.isCanada()){
        	isCanadaOPSUser = GNE_SFA2_Util.isCanadaOPSUser();
        }
        
        if(fieldKey=='mcName') {
            fld.mode = new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.value = isNewMode ? null : medComm.Name;
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Name.getDescribe(), sObjectType);
        } else if(fieldKey=='refName') {
            fld.mode = new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.value = isNewMode ? null : medComm.Referral_Assignment_gne__r.Name;
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Referral_Assignment_gne__c.Name.getDescribe(), 'Referral_Assignment_gne__c');
        } else if(fieldKey=='account') {
            fld.value = isNewMode ? resultData.account.getLocalId() : medComm.Account_gne__c;
            fld.displayValue = isNewMode ? resultData.account.getName() : medComm.Account_gne__r.Name;
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Account_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='address') {
            fld.value = isNewMode ? null : medComm.Address_Line_1_gne__c;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);

            if(isNewMode) {
                describe.type = 'picklist';
                describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
            
                for(Address addr : resultData.account.addresses) {
                    describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(addr.id, addr.label));
                }
            } else {
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Address_Line_1_gne__c.getDescribe(), sObjectType);
            } 
        } else if(fieldKey=='phone') {
            fld.value = isNewMode ? resultData.account.getPhone() : medComm.Phone_gne__c;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
        } else if(fieldKey=='mobilePhone') {
            fld.value = isNewMode ? resultData.account.getMobilePhone() : medComm.Phone_1_gne__c;
        } else if(fieldKey=='email') {
            fld.value = isNewMode ? resultData.account.getEmail() : medComm.Email_gne__c;
        } else if(fieldKey=='fax') {
            fld.value = isNewMode ? resultData.account.getFax() : medComm.Fax_gne__c;
        } else if(fieldKey=='assignmentType') {
            fld.mode = new List<String>{GNE_SFA2_Base_Ctrl.NEW_MODE};
            describe.type = 'picklist';
            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>{
                new GNE_SFA2_Base_Ctrl.PicklistValue('manual','Manual Assignment'),
                new GNE_SFA2_Base_Ctrl.PicklistValue('auto','Auto Assignment')
            };
        } else if(fieldKey=='assignee') {
           	fld.mode = new List<String>{GNE_SFA2_Base_Ctrl.NEW_MODE};
            describe.type = 'string';
      		if (currentUser.isCanada()){
            	fld.mode.add(GNE_SFA2_Base_Ctrl.EDIT_MODE);
    	        fld.value = medComm.Referral_Assignment_gne__r.Assigned_To_gne__c;
	            fld.displayValue = medComm.Referral_Assignment_gne__r.Assigned_To_gne__r.Name;
        	}
        } else if(fieldKey=='product') {
            fld.value = isNewMode ? null : medComm.Product_Name_gne__c;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            
            if(isNewMode) {
	            describe.type = 'picklist';
	            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
	            
	            for(Product prod : resultData.products) {
	                describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(prod.id, prod.name));
	            }
            } else {
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Product_Name_gne__c.getDescribe(), sObjectType);
            } 
        } else if(fieldKey=='ta') {
            fld.value = isNewMode ? null : medComm.TA_SubTA_Name_gne__c;
            
            if(isNewMode) {
	            describe.type = 'picklist';
	            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
	            
	            for(TA prod : resultData.tas) {
	                describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(prod.id, prod.name));
	            }
            } else {
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.TA_SubTA_Name_gne__c.getDescribe(), sObjectType);
            }
        } else if(fieldKey=='molecule') {
            fld.value = isNewMode ? null : medComm.Molecule_Name_gne__c;
            
            if(isNewMode) {
	            describe.type = 'picklist';
	            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
	            
	            for(Molecule prod : resultData.molecules) {
	                describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue(prod.id, prod.name));
	            }
            } else {
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Molecule_Name_gne__c.getDescribe(), sObjectType);
            }
        } else if(fieldKey=='question') {
            fld.value = isNewMode ? null : medComm.Medical_Question_gne__c;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Medical_Question_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='followUpMethod') {
            fld.value = isNewMode ? (currentUser.isCanada() ? 'Face to Face Visit' : null) : medComm.Follow_up_Method_gne__c;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            if (currentUser.isCanada()) {
            	Schema.DescribeFieldResult dsc = Medical_Communication_gne__c.Follow_up_Method_gne__c.getDescribe();
            	describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(dsc, sObjectType);
            } else {
            	describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Follow_up_Method_gne__c.getDescribe(), sObjectType);
            }
        } else if(fieldKey=='priority') {
       		fld.value = isNewMode ? null : medComm.Priority_gne__c;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Priority_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='language') {
            fld.value = isNewMode ? (currentUser.isCanada() ? 'English' : null) : medComm.Language_of_Preference_can_gne__c;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Language_of_Preference_can_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='reqCompletionDate') {
            fld.value = isNewMode ? null : String.valueOf(medComm.Requested_Completion_Date_gne__c);
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Requested_Completion_Date_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='revCompletionDate') {
           	fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
      		if (currentUser.isCanada()){
            	fld.mode.add(GNE_SFA2_Base_Ctrl.EDIT_MODE);
        	}            
            fld.value = isNewMode ? null : String.valueOf(medComm.Referral_Assignment_gne__r.Revised_Requested_Completion_Date_gne__c);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Referral_Assignment_gne__c.Revised_Requested_Completion_Date_gne__c.getDescribe(), 'Referral_Assignment_gne__c');
        } else if(fieldKey=='reqVerified') {
            fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.value = isNewMode ? null : String.valueOf(medComm.Unsolicited_Request_Verified_gne__c);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Unsolicited_Request_Verified_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='reqVerifiedDate') {
            fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.value = isNewMode ? null : String.valueOf(medComm.Unsolicited_Request_Verified_Date_gne__c);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Unsolicited_Request_Verified_Date_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='reqVerifiedBy') {
            fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.value = isNewMode ? null : medComm.Unsolicited_Request_Verified_By_gne__c;
            fld.displayValue = isNewMode ? null : medComm.Unsolicited_Request_Verified_By_gne__r.Name;
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Unsolicited_Request_Verified_By_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='requestor') {
            fld.value = isNewMode ? getCurrentUser().name : medComm.Requested_By_gne__r.Name;
        } else if(fieldKey=='source') {
            fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.value = isNewMode ? null : medComm.Referral_Source_gne__c;
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Referral_Source_gne__c.getDescribe(), sObjectType);
        } else if(fieldKey=='assignedTo') {
           	fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            fld.value = isNewMode ? null : medComm.Referral_Assignment_gne__r.Assigned_To_gne__c;
            fld.displayValue = isNewMode ? null : medComm.Referral_Assignment_gne__r.Assigned_To_gne__r.Name;
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Referral_Assignment_gne__c.Assigned_To_gne__c.getDescribe(), 'Referral_Assignment_gne__c');
        } else if(fieldKey=='status') {
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
        	if (!currentUser.isCanada()){
            	fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE};
        	} else {
            	fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.VIEW_MODE, GNE_SFA2_Base_Ctrl.EDIT_MODE};
                describe.type = 'picklist';
                
	            describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
	            if (isCanadaOpsUser){
	            	describe.picklistValues.add(
		               	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ASSIGNED, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ASSIGNED)
					);
					describe.picklistValues.add(
		               	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA)
					);
					describe.picklistValues.add(
		                new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_FULFILLED_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_FULFILLED_CANADA)
					);
					describe.picklistValues.add(
		               	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_HCPU_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_HCPU_CANADA)
					);
					describe.picklistValues.add(
		               	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_NOTV_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_NOTV_CANADA)
					);
	            } else {
	            	if (medComm.Referral_Assignment_gne__r.Status_Referral_gne__c == GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ASSIGNED) {
						describe.picklistValues.add(
		                	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ASSIGNED, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ASSIGNED)
						);
						describe.picklistValues.add(
		                	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA)
						);
	            	} else if (medComm.Referral_Assignment_gne__r.Status_Referral_gne__c == GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA) {
						describe.picklistValues.add(
		                	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA)
						);
						describe.picklistValues.add(
		                	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_FULFILLED_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_FULFILLED_CANADA)
						);
						describe.picklistValues.add(
		                	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_HCPU_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_HCPU_CANADA)
						);
						describe.picklistValues.add(
		                	new GNE_SFA2_Base_Ctrl.PicklistValue(GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_NOTV_CANADA, GNE_SFA2_ReferralUtil.REFERRAL_STATUS_CLOSED_NOTV_CANADA)
						);					
	            	} else {
						describe.picklistValues.add(
		                	new GNE_SFA2_Base_Ctrl.PicklistValue(medComm.Referral_Assignment_gne__r.Status_Referral_gne__c, medComm.Referral_Assignment_gne__r.Status_Referral_gne__c)
						);
	            	}
	            }
        	}            
            fld.value = isNewMode ? null : medComm.Referral_Assignment_gne__r.Status_Referral_gne__c;
        } else if(fieldKey=='comment') {
            fld.mode =  new List<String>{GNE_SFA2_Base_Ctrl.EDIT_MODE};
            fld.value = null;
            fld.readOnly = isFieldReadOnly(fieldKey, mode, medComm);
            describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Medical_Communication_gne__c.Comments_Referral_gne__c.getDescribe(), sObjectType);
        } else if (fieldKey=='city'){
        	fld.value = medComm.City_gne__c;
        } else if (fieldKey == 'provinceCan'){
        	fld.value = medComm.Province_can_gne__c;
        }
        
        describe.type = String.isNotBlank(describe.type) ? describe.type : 'string';
        fld.describe = describe;
        fld.name = fld.describe.name;
        fld.helpText = fld.describe.inlineHelpText;
    }

    private Boolean isFieldReadOnly(String fld, String mode, Medical_Communication_gne__c medComm) {
        if (mode == GNE_SFA2_Base_Ctrl.NEW_MODE){
            return false;
        } else if (mode == GNE_SFA2_Base_Ctrl.EDIT_MODE){
            if (GNE_SFA2_Util.isCanadaUser() && !GNE_SFA2_Util.isCanadaOpsUser() &&
                ((UserInfo.getUserId() == medComm.Referral_Assignment_gne__r.Assigned_To_gne__c || GNE_SFA2_Util.isCanadaDirectorUser() || GNE_SFA2_Util.isCanadaRMLUser()) && 
                getClosedStatusesForCanada().contains(medComm.Referral_Assignment_gne__r.Status_Referral_gne__c))) {
                return true;
            }
            Set<String> editableFields = GNE_SFA2_Util.isCanadaUser() ? new Set<String>{'revCompletionDate', 'assignedTo', 'status', 'comment'} : new Set<String>();
            return !editableFields.contains(fld);
        } else {
            return true;
        }
    }
    
    private void prepareHistoryRelatedLists(List<GNE_SFA2_Base_Ctrl.RelatedList> relatedLists) {
        if(getMode()==GNE_SFA2_Base_Ctrl.VIEW_MODE) {
            Medical_Communication_gne__c medComm = getMedComm();
            GNE_SFA2_Base_Ctrl.RelatedList historyRList = new GNE_SFA2_Base_Ctrl.RelatedList('history', 'Referral History', new List<GNE_SFA2_Base_Ctrl.RelatedListField>{
                new GNE_SFA2_Base_Ctrl.RelatedListField('createddate', 'Created Date', 'datetime', false),
                new GNE_SFA2_Base_Ctrl.RelatedListField('action', 'Action', 'string', false),
                new GNE_SFA2_Base_Ctrl.RelatedListField('actor', currentUser.isCanada() ? 'Requested By' : 'Action By', 'string', false),
                new GNE_SFA2_Base_Ctrl.RelatedListField('assignee', 'Assigned To', 'string', false),
                new GNE_SFA2_Base_Ctrl.RelatedListField('role', currentUser.isCanada() ? 'Title' : 'Role', 'string', false),
                new GNE_SFA2_Base_Ctrl.RelatedListField('status', 'Status', 'string', false)
            });
            historyRList.pageSize = 20;
            historyRList.sortBy = 'createddate';
            historyRList.sortDirection = 'ASC';
            List<GNE_SFA2_ReferralUtil.ActionWrapper> historyActions = GNE_SFA2_ReferralUtil.getReferralHistoryActions(medComm.Referral_History_gne__c);
            List<GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper> historyRows = new List<GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper>();
            
            Integer idx=0;
            for(GNE_SFA2_ReferralUtil.ActionWrapper hAction : historyActions) {
                GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper row = new GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper(
                String.valueOf(idx++),
                new Map<String,String>{
                    'createddate' => GNE_SFA2_S2S_Util.formatDateTime(hAction.getCreatedDate()),
                    'action' => hAction.getAction(),
                    'actor' => hAction.getActor()!=null ? hAction.getActor().getName() : null,
                    'assignee' => hAction.getAssignee()!=null ? hAction.getAssignee().getName() : null,
                    'role' => hAction.getAssignee()!=null ? hAction.getAssignee().getProfileName() : null,
                    'status' => hAction.getStatus()
                    }
                );
                        
                historyRows.add(row);
            }
            
            historyRList.addRows(historyRows);
            relatedLists.add(historyRList);
        }
    }

    private void prepareCommentsRelatedLists(List<GNE_SFA2_Base_Ctrl.RelatedList> relatedLists) {
        if(GNE_SFA2_Util.isCanadaUser() && getMode()==GNE_SFA2_Base_Ctrl.VIEW_MODE && GNE_SFA2_Util.getCurrentUserProfileName() == GNE_SFA2_ReferralUtil.MSLCanadaProfile) {
            Medical_Communication_gne__c medComm = getMedComm();
            GNE_SFA2_Base_Ctrl.RelatedList commentsRList = new GNE_SFA2_Base_Ctrl.RelatedList('refComments', 'Referral Comments', new List<GNE_SFA2_Base_Ctrl.RelatedListField>{
                new GNE_SFA2_Base_Ctrl.RelatedListField('createddate', 'Action Date', 'datetime', false),
                new GNE_SFA2_Base_Ctrl.RelatedListField('action', 'Comments', 'string', false),
                new GNE_SFA2_Base_Ctrl.RelatedListField('actor', 'Action By', 'string', false)                
            });
            commentsRList.pageSize = 20;
            commentsRList.sortBy = 'createddate';
            commentsRList.sortDirection = 'ASC';
            List<GNE_SFA2_ReferralUtil.ActionWrapper> commentsActions = GNE_SFA2_ReferralUtil.getReferralCommentsActions(medComm.Comments_Referral_gne__c);
            List<GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper> commentsRows = new List<GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper>();
            
            Integer idx=0;
            for(GNE_SFA2_ReferralUtil.ActionWrapper hAction : commentsActions) {
                GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper row = new GNE_SFA2_Base_Ctrl.RelatedListRecordWrapper(
                String.valueOf(idx++),
                new Map<String,String>{
                    'createddate' => GNE_SFA2_S2S_Util.formatDateTime(hAction.getCreatedDate()),
                    'action' => hAction.getAction(),
                    'actor' => hAction.getActor()!=null ? hAction.getActor().getName() : null
                    }
                );
                commentsRows.add(row);
            }
            
            commentsRList.addRows(commentsRows);
            relatedLists.add(commentsRList);
        }
    }
    
    public override GNE_SFA2_Base_Ctrl.DataWrapper saveRecord(String inputDataWrapperInJSON, System.Type inputType) {
        this.aaException = null;
        this.referral = null;
        try {
            DataWrapper saveData = (DataWrapper)JSON.deserialize(inputDataWrapperInJSON, inputType);
            this.inputDataWrapper = saveData;
            prepareSaveData();
            validateBeforeSave();
            if (!GNE_SFA2_Util.isCanadaUser()) {
           	   (new GNE_SFA2_ReferralEngine()).checkAutoAssignment(saveData.referral);
            }
            this.referral = saveData.referral;
        } catch(GNE_SFA2_ReferralUtil.AutoAssignmentFailedException aafex) {
            aaException = aafex;
        } catch (Exception ex){}
        
        return super.saveRecord(inputDataWrapperInJSON, inputType);
    }
    
    protected override GNE_SFA2_Base_Ctrl.DataWrapper intSaveRecord() {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        
        if(this.aaException!=null) {
            throw createException(new AutoAssignmentFailedException(this.aaException));
        } else if(this.referral!=null) {
            saveData.referral = this.referral;
        } else {
        	prepareSaveData();
   	        validateBeforeSave();
        }
        
        try {
        	if (getMode() == GNE_SFA2_Base_Ctrl.NEW_MODE) {
            	Medical_Communication_gne__c medComm = (new GNE_SFA2_ReferralEngine()).createReferral(saveData.referral);
            	dataWrapper.retUrl = '/' + medComm.Referral_Assignment_gne__c;
        	} else if (getMode() == GNE_SFA2_Base_Ctrl.EDIT_MODE) {
            	Medical_Communication_gne__c medComm = (new GNE_SFA2_ReferralEngine()).updateReferral(saveData.referral);
            	dataWrapper.retUrl = '/' + medComm.Referral_Assignment_gne__c;
        	}
        } catch(GNE_SFA2_ReferralUtil.InvalidReferralException irex) {
            throw createException(new InvalidReferralException(irex));
        } catch(GNE_Med_iPhone_CreateReferral.CreateReferralException oldex) {
            throw createException(new InvalidReferralException(oldex));
        }
        
        return dataWrapper;
    }
    
    private void prepareSaveData() {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        if(saveData.referral!=null && saveData.referral.getReferralData()!=null) {
        	if(String.isNotBlank(saveData.referral.getReferralData().reqCompletionDate)) {
            	saveData.referral.getReferralData().reqCompletionDate = DateTime.newInstance(Long.valueOf(saveData.referral.getReferralData().reqCompletionDate)).formatGmt('yyyy-MM-dd');
        	}
        	if(String.isNotBlank(saveData.referral.getReferralData().revCompletionDate)) {
         	   saveData.referral.getReferralData().revCompletionDate = DateTime.newInstance(Long.valueOf(saveData.referral.getReferralData().revCompletionDate)).formatGmt('yyyy-MM-dd');
        	}
        }
    }
    
    private void validateBeforeSave() {
        DataWrapper saveData = (DataWrapper)inputDataWrapper;
        Date reqComplitionDate = saveData.referral!=null && saveData.referral.getReferralData()!=null ? saveData.referral.getReferralData().getReqCompletionDate() : null;
        
        if(reqComplitionDate!=null && reqComplitionDate < DateTime.now().dateGmt()) {
            throw createException(new InvalidReqCompletionDateException());
        }
    }
    
    global class DataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
        private AccountWrapper account;
        private List<GNE_SFA2_ReferralUtil.AssigneeUser> assigneeUsers;
        private List<BrandProduct> products;
        private List<TA> tas;
        private List<Molecule> molecules;
        private GNE_SFA2_ReferralUtil.ReferralWrapper referral;
        private Boolean showEditButton;
    }
    
    private class AccountWrapper extends GNE_SFA2_ReferralUtil.AccountWrapper {
        private List<Address> addresses;
        private Map<String,GNE_SFA2_ReferralUtil.AccountWrapper> accountsMap;
        
        private AccountWrapper(Account acc, Set<Id> hiddenAddrIds) {
            super(acc, null, null);
            this.addresses = new List<Address>();
            this.accountsMap = new Map<String,GNE_SFA2_ReferralUtil.AccountWrapper>();
            
            for(Address_vod__c addr : acc.Address_vod__r) {
                if(!hiddenAddrIds.contains(addr.Id) && addr.Inactive_vod__c==false) {
	                this.addresses.add(new Address(addr));
	                this.accountsMap.put(addr.Id, new GNE_SFA2_ReferralUtil.AccountWrapper(acc, addr, null));
                }
            }
        }
    }
    
    private class Address {
        private String id;
        private String label;
        
        private Address(Address_vod__c addr) {
            this.id = addr.Id;
            this.label = GNE_SFA2_Util.getAddressAsString(addr);
        }
    }
    
    private abstract class Product {
        String id;
        String name;
        
        private Product(GNE_SFA2_ReferralUtil.ReferralProduct prod) {
            this.id = prod.getId();
            this.name = prod.getName();
        }
    }
    
    private class BrandProduct extends Product {
        private String ta;
        
        private BrandProduct(GNE_SFA2_ReferralUtil.ReferralProduct prod) {
            super(prod);
            this.ta = prod.getTA();
        }
    }
    
    private class TA extends Product {
        private Boolean autoMode;
        
        private TA(GNE_SFA2_ReferralUtil.ReferralProduct prod) {
            super(prod);
            autoMode = prod.isAutoMode();
        }
    }
    
    private class Molecule extends Product {
        private Molecule(GNE_SFA2_ReferralUtil.ReferralProduct prod) {
            super(prod);
        }
    }
    
    private class NoAccountFoundException extends GNE_SFA2_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'NoAccountFound';
            label = 'Account does not exist';  
        }
    }
    
    private class NoAddressesFoundException extends GNE_SFA2_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'NoAddressesFound';
            label = System.Label.GNE_SFA2_HideAddress_Error_AddressIsRequired;  
        }
    }
    
    private class InvalidReqCompletionDateException extends GNE_SFA2_Base_Ctrl.BaseException {
        protected override void init() {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'InvalidReqCompletionDate';
            fieldMessage = 'Date should be greater than or equal today';
            label = 'Requested Completion ' + fieldMessage;
            fieldName = 'Requested_Completion_Date_gne__c';
            sObjectType = 'Medical_Communication_gne__c';  
        }
    }
    
    private class InvalidReferralException extends GNE_SFA2_Base_Ctrl.BaseException {
        private InvalidReferralException(GNE_SFA2_ReferralUtil.InvalidReferralException irex) {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'InvalidReferral';
            label = irex.getMessage();
        }
        
        private InvalidReferralException(GNE_Med_iPhone_CreateReferral.CreateReferralException oldex) {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'InvalidReferral';
            label = oldex.getMessage();
        }
        
        protected override void init() {}
    }
    
    private class AutoAssignmentFailedException extends GNE_SFA2_Base_Ctrl.BaseException {
        private AutoAssignmentFailedException(GNE_SFA2_ReferralUtil.AutoAssignmentFailedException aafex) {
            type = GNE_SFA2_Base_Ctrl.ErrorTypes.Error.name();
            subType = 'AutoAssignmentFailed';
            label = aafex.getMessage();
        }
        
        protected override void init() {}
    }
    
    @RemoteAction
    global static DataWrapper saveRecord(String inputDataInJSON) {
        return (DataWrapper)(new GNE_SFA2_Referral_Ctrl()).saveRecord(inputDataInJSON, GNE_SFA2_Referral_Ctrl.DataWrapper.class);
    }
}