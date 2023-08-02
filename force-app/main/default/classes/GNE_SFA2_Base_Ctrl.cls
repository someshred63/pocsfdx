global virtual class GNE_SFA2_Base_Ctrl {


    public GNE_SFA2_Base_Ctrl thisController {get { return this; }}
    public String uiType {get; protected set;}
    public Boolean isStandardUI {get { return uiType == 'standard'; }}
    public Boolean includeCommonStyles {get; protected set;}
    public Boolean isSfaBrandUser {get; protected set;}
    public Boolean isINFUUser {get; protected set;}
    public Boolean isRedirectMode {get; protected set;}
    public String activeMenuItem {get; set;}
    public String apiStaticResource {get; protected set;}
    public String uiStaticResource {get; protected set;}
    public String pageStaticResource {get; protected set;}
    public Boolean isPopupMode {get; protected set;}

    public final static String BUTTON = 'Button';
    public final static String FIELD = 'Field';
    public final static String BLANK_SPACE = 'Blank Space';
    public final static String RELATED_LIST = 'Related List';
    public final static String VF_PAGE = 'VF Page';

    public final static String NEW_MODE = 'New';
    public final static String EDIT_MODE = 'Edit';
    public final static String VIEW_MODE = 'View';

    public transient String pageExtId;
    public transient String constructorDataJSON;
    public transient Map<String, String> params;
    public transient SObject record;
    public transient SObject recordAfterSave;
    global transient DataWrapper dataWrapper;
    public transient DataWrapper inputDataWrapper;
    public transient UserWrapper currentUser;
    public transient AppContext appContext;
    public transient RecordType recordType;
    public transient Id recordId;
    public transient String sObjectType;
    public transient String mode;
    public transient Boolean initMore;
    public transient Schema.DescribeSObjectResult sObjectDescribe;
    public transient Map<String, Schema.DescribeFieldResult> sObjectFieldsDescribe;
    public transient Map<String, Schema.ChildRelationship> childRelationshipsMap;
    public transient Map<String, Field> fieldsMap;
    public transient List<Territory2> userTerritoriesCache;
    public transient Territory2 currentTerritory;
    public transient Boolean isDebugMode;
    public transient String popupReturnAction;

    public enum ErrorTypes {Error, Warning, Info}
    public enum DmlOperations {INS, UPD, UPS, DEL}

    public GNE_SFA2_Base_Ctrl() {
    // Constructor mode
        if (ApexPages.currentPage() != null) {
            constructorDataJSON = JSON.serialize(getConstructorData());
            try {
            System.debug('##### constructorDataJSON === ' + constructorDataJSON);
        }
            catch(Exception e) {
                system.debug(e);
            }
        }
    }

    public String getConstructorDataJSON() {
        return constructorDataJSON;
    }

    protected virtual DataWrapper getConstructorData() {
        Map<String, String> params = ApexPages.currentPage().getParameters().clone();
        return init(params);
    }

    protected virtual DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }

    public virtual DataWrapper init(Map<String, String> params) {
        dataWrapper = getDataWrapperInstance();

        try {
            dataWrapper = intInit(params);
        } catch (Exception ex) {
            handleException(ex);
        }

        dataWrapper.onActionFinish('Init');
        return dataWrapper;
    }

    public virtual void handleException(Exception ex) {
        if (ex instanceof BaseException) {
            dataWrapper.addError((BaseException)ex);
        } else {
            dataWrapper.addError(createException(new UnknownException(ex, true)));
        }
    }

    public BaseException createException(BaseException ex) {
        return staticCreateException(ex, null);
    }

    public BaseException createException(BaseException ex, List<Object> a_labelParams) {
        return staticCreateException(ex, a_labelParams);
    }

    protected virtual DataWrapper intInit(Map<String, String> params) {
        System.debug('##### intInit #####');
        this.params = params.clone();
        this.mode = getMode();
        this.initMore = Boolean.valueOf(String.isNotBlank(params.get('initMore')) ? params.get('initMore') : 'false');
        this.currentUser = getCurrentUser();
        this.isSfaBrandUser = this.currentUser.isSfaBrand();
        // Check if it's canada just to make sure that it will be calculated
        this.currentUser.isCanada();
        this.appContext = getAppContext();
        this.uiType = getUiType();
        this.includeCommonStyles = true;
        this.isDebugMode = dataWrapper.isDebugMode = new Set<String> {'TRUE', '1', 'YES'} .contains(params.get('debugMode') != null ? params.get('debugMode').toUpperCase() : '');
        this.apiStaticResource = String.isNotBlank(params.get('apiStaticResource')) ? params.get('apiStaticResource') : 'GNE_SFA2_Framework';
        this.uiStaticResource = String.isNotBlank(params.get('uiStaticResource')) ? params.get('uiStaticResource') : 'GNE_SFA2_Framework_UI';
        this.pageStaticResource = String.isNotBlank(params.get('pageStaticResource')) ? params.get('pageStaticResource') : ('GNE_SFA2_Framework' + (String.isNotBlank(this.pageExtId) ? ('_' + this.pageExtId.toUpperCase()) : ''));
        this.isPopupMode = params.get('isPopup') == 'true';
        this.popupReturnAction = params.get('popupReturnAction');
        this.isINFUUser = GNE_SFA2_Util.isCanadaINFUUser();
        dataWrapper.urlParameters = params.clone();
		
        if (pageDispatcher()) {
            isRedirectMode = false;
            dataWrapper = mode == NEW_MODE ?
                          initNewMode() : mode == EDIT_MODE ?
                          initEditMode() : initViewMode();
        } else {
            isRedirectMode = true;
            dataWrapper.retUrl = redirectToOtherPage();
        }

        System.debug('##### DataWrapper === ' + dataWrapper);

        return dataWrapper;
    }

    protected virtual String getMode() {
    	if(this.mode==null) {
    		this.mode = String.isNotBlank(this.params.get('id')) ? (String.isNotBlank(this.params.get('sfdc.override')) ? VIEW_MODE : EDIT_MODE) : NEW_MODE;
    	}

    	return this.mode;
    }

    protected virtual Boolean pageDispatcher() {
        return (uiType == 'sfa2' && appContext.appName == 'SFA-US');
    }

    protected virtual String redirectToOtherPage() {
        String url = null;
        PageReference pRef = getDispatcherOtherPage();

        if (pRef != null) {
            for (String paramKey : params.keySet()) {
                if (!new Set<String> {'debugMode', 'sObjectType', 'userAlias', 'save_new'} .contains(paramKey)) {
                    pRef.getParameters().put(paramKey, params.get(paramKey));
                }
            }

            url = pRef.getURL();
        }

        return url;
    }

    protected virtual PageReference getDispatcherOtherPage() {
        return null;
    }

    protected virtual DataWrapper initNewMode() {
        this.sObjectType = checkInputParam('sObjectType');
        this.recordType = getRecordType(true);
        return getDataWrapper(dataWrapper);
    }

    protected virtual DataWrapper initEditMode() {
        return initViewMode();
    }

    protected virtual DataWrapper initViewMode() {
        this.recordId = String.valueOf(checkInputParam('id')).substring(0,15);
        this.sObjectType = String.valueOf(recordId.getSObjectType());
        this.recordType = getRecordType(false);
        return getDataWrapper(dataWrapper);
    }

    protected virtual String checkInputParam(String paramName) {
        String result = params.get(paramName);

        if (String.isBlank(result)) {
            throw createException(new MissingInputParamErrorException(), new Object[] {paramName});
        }

        if (paramName == 'id') {
            try {
                Id.valueOf(result);
            } catch (Exception e) {
                throw createException(new WrongInputParamTypeErrorException(), new Object[] {paramName, result, 'Id'});
            }
        } else if (paramName == 'sObjectType') {
            try {
                Boolean isValid = Type.forName(result).newInstance() instanceof SObject;
            } catch (Exception e) {
                throw createException(new WrongInputParamTypeErrorException(), new Object[] {paramName, result, 'SObject'});
            }
        }

        return result;
    }

    protected virtual UserWrapper getCurrentUser() {
        currentUser = currentUser != null ? currentUser : inputDataWrapper != null && inputDataWrapper.appContext != null ? inputDataWrapper.appContext.currentUser : dataWrapper != null && dataWrapper.appContext != null ? dataWrapper.appContext.currentUser : null;

        if (currentUser == null) {
            User result = null;

            if (params!=null && params.containsKey('userAlias')) {
                for (User u : [SELECT Id, FirstName, LastName, ProfileId, TimeZoneSidKey FROM User WHERE Alias = :params.get('userAlias') LIMIT 1]) {
                    result = u;
                }
            }

            if (result == null) {
                result = new User(Id = UserInfo.getUserId(), FirstName = UserInfo.getFirstName(), LastName = UserInfo.getLastName(), ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = String.valueOf(UserInfo.getTimeZone()));
            }

            currentUser = new UserWrapper(result);
        }

        return currentUser;
    }

    protected virtual String getCurrentUserProfileName() {
        currentUser = currentUser != null ? currentUser : getCurrentUser();
        return currentUser.getProfileName();
    }

    protected virtual RecordType getRecordType(Boolean isNewMode) {
        RecordType result = null;
        Boolean hasRecordType = getSObjectFieldsDescribe().containsKey('recordtypeid');

        if (hasRecordType) {
            if (isNewMode) {
                String rtDeveloperName = null;

                for (SFA2_Configuration_Object_gne__c conf : [
                            SELECT Record_Type_gne__c
                            FROM SFA2_Configuration_Object_gne__c
                            WHERE Is_Default_Record_Type_gne__c = true AND Object_Name_gne__c = :sObjectType
                                    AND Role_gne__c = :appContext.role AND Brand_gne__c = :appContext.brand AND Application_Type__c = :appContext.appName
                                                      AND Is_Active_gne__c = true AND Configuration_Type_gne__c = 'Page'
                                                              LIMIT 1]) {
                    rtDeveloperName = conf.Record_Type_gne__c;
                }

                if (String.isNotBlank(rtDeveloperName)) {
                    for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sOBjectType = : sObjectType AND DeveloperName = : rtDeveloperName LIMIT 1]) {
                        result = rt;
                    }
                }
            } else {
                for (SObject rec : Database.query('SELECT RecordType.Id, RecordType.Name, RecordType.DeveloperName FROM ' + sObjectType + ' WHERE Id =: recordId LIMIT 1')) {
                    result = (RecordType)rec.getSObject('RecordType');
                }
            }
        }

        return result;
    }

    protected virtual String getUiType() {
        if (uiType == null) {
            uiType = params.get('uiType');
            uiType = String.isNotBlank(uiType) ? uiType : getAppContext().isSfa2Mode == true ? 'sfa2' : 'standard';
        }

        return uiType;
    }

    protected virtual DataWrapper getDataWrapper(DataWrapper dataWrapper) {
        dataWrapper.uiType = uiType;
        dataWrapper.isStandardUI = isStandardUI;
        dataWrapper.appContext = appContext;
        dataWrapper.isSfaBrandUser = isSfaBrandUser;
        dataWrapper.config = getConfiguration(recordType != null ? recordType.DeveloperName : null);
        dataWrapper.recordDescribe = getRecordDescribe();
        dataWrapper.userObjectPrefix = User.sObjectType.getDescribe().getKeyPrefix();
        dataWrapper.translationsMap = getTranslationsMap();
        dataWrapper.isPopupMode = this.isPopupMode;
        dataWrapper.popupReturnAction = this.popupReturnAction;
        return dataWrapper;
    }

    protected virtual AppContext getAppContext() {
        if (appContext == null) {
            GNE_SFA2_User_App_Context_gne__c aContext = GNE_SFA2_User_App_Context_gne__c.getInstance(currentUser.id);
            appContext = GNE_SFA2_Util.isCanadaINFUUser()
              ? new AppContext(currentUser, 'SFA-Canada', null, 'INFU', true)
              : aContext != null
              ? new AppContext(currentUser, aContext.App_Name_gne__c, aContext.Brand_gne__c, aContext.Role_gne__c, aContext.SFA2_Mode_gne__c && aContext.Run_in_SFA2_UI_gne__c)
              : new AppContext(currentUser, 'NoApp', null, null, false);
        }

        return appContext;
    }

    protected virtual Map<String,String> getTranslationsMap() {
        return new Map<String,String>();
    }

    protected virtual RecordDescribe getRecordDescribe() {
        sObjectDescribe = getSObjectDescribe();
        return new RecordDescribe(recordId, (String)record.get('Name'), sObjectType, sObjectDescribe.getLabel(), recordType, getRecordAccess(getCurrentUser().id));
    }

    protected virtual RecordAccess getRecordAccess(String userId) {
        RecordAccess result = null;

        if (String.isNotBlank(recordId)) {
            for (UserRecordAccess urAccess : [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId LIMIT 1]) {
                result = new RecordAccess(urAccess.HasReadAccess, urAccess.HasEditAccess, urAccess.HasDeleteAccess);
            }

            if (result == null) {
                result = new RecordAccess(false, false, false);
            }
        } else {
            sObjectDescribe = getSObjectDescribe();
            result = new RecordAccess(sObjectDescribe.isAccessible(), sObjectDescribe.isCreateable(), sObjectDescribe.isDeletable());
        }

        checkRecordAccess(result);
        return result;
    }

    protected virtual void checkRecordAccess(RecordAccess rAccess) {
        if (!rAccess.readAccess) {
            throw createException(new RecordPermissionErrorException(), new Object[] {'Read', currentUser.name});
        } else if (mode != VIEW_MODE && !rAccess.editAccess) {
            throw createException(new RecordPermissionErrorException(), new Object[] {mode == NEW_MODE ? 'Create' : 'Edit', currentUser.name});
        }
    }

    protected virtual Config getConfiguration(String recordTypeDeveloperName) {
        List<Button> buttons = new List<Button>();
        List<Section> sections = new List<Section>();
        List<RelatedList> relatedList = new List<RelatedList>();
        fieldsMap = new Map<String, Field>();

        List<SFA2_Configuration_Object_gne__c> configObjects = getConfigObjects(recordTypeDeveloperName);

        if (configObjects.isEmpty()) {
            //try with default record type
            String defaultRecType = GNE_SFA2_Util.getDefaultRecordType(sObjectType, appContext.appName, appContext.brand, appContext.role);
            if (String.isNotBlank(defaultRecType)) {
                configObjects = getConfigObjects(defaultRecType);
            }
        }

        if (configObjects.isEmpty()) {
            dataWrapper.addWarning(createException(new MissingConfigurationWarningException(),
                                                   new Object[] {
                                                       String.isNotBlank(appContext.appName) ? appContext.appName : '-',
                                                       String.isNotBlank(appContext.brand) ? appContext.brand : '-',
                                                       String.isNotBlank(appContext.role) ? appContext.role : '-'
                                                   }));
        }

        record = getRecord(configObjects);
        for (SFA2_Configuration_Object_gne__c conf : configObjects) {
            readConfigObject(conf, buttons, sections, relatedList);
        }

        prepareRelatedListRecords(relatedList);

        return new Config(mode, buttons, sections, relatedList);
    }

    private List<SFA2_Configuration_Object_gne__c> getConfigObjects(String recordTypeDeveloperName) {
        return [SELECT Name, Section_Header_gne__c, Order_gne__c, Attributes_gne__c,
                    (SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Read_Only_gne__c, Is_Required_gne__c, Order_gne__c, Type_gne__c, Availability_Mode_gne__c, Icon_Url_gne__c, Help_Text_gne__c
                     FROM Configuration_Objects__r WHERE Is_Active_gne__c = true
                             ORDER BY Order_gne__c)
                    FROM SFA2_Configuration_Object_gne__c
                    WHERE Object_Name_gne__c = :sObjectType AND Role_gne__c = :appContext.role AND Brand_gne__c = :appContext.brand AND Application_Type__c = :appContext.appName
                                               AND Record_Type_gne__c = :recordTypeDeveloperName AND Is_Active_gne__c = true AND Configuration_Type_gne__c = 'Page'
                                                       ORDER BY Order_gne__c];
    }

    protected virtual ConfigItem readConfigObject(SFA2_Configuration_Object_gne__c conf, List<Button> buttons, List<Section> sections, List<RelatedList> relatedList) {
        ConfigItem result = null;

        sObjectFieldsDescribe = getSObjectFieldsDescribe();

        if (!conf.Configuration_Objects__r.isEmpty()) {
            String firstElType = conf.Configuration_Objects__r.get(0).Type_gne__c;

            if (firstElType == BUTTON) {
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                    Button btn = getButton(confDetail);

                    if(btn!=null) {
                        buttons.add(btn);
                    }
                }
            } else if (firstElType == FIELD || firstElType == BLANK_SPACE) {
                Section sec = getSection(conf);
                sections.add(sec);
                result = sec;
            } else {
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                    if (confDetail.Type_gne__c == RELATED_LIST) {
                        result = getRelatedList(confDetail, relatedList);
                    } else if(confDetail.Type_gne__c == VF_PAGE) {
                        result = getIncludedPage(conf, confDetail, sections, relatedList);
                    }
                }
            }
        } else {
            Section sec = new Section(conf, new List<Field>());
            sections.add(sec);
            result = sec;
        }

        return result;
    }

    protected virtual Button getButton(SFA2_Configuration_Object_Detail_gne__c confDetail) {
        return new Button(confDetail);
    }

    protected virtual Section getSection(SFA2_Configuration_Object_gne__c conf) {
        System.debug('#### getSection');
        List<Field> fields = new List<Field>();

        for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
            if(confDetail.Type_gne__c!=VF_PAGE) {
	            Field fld = getField(confDetail);
	            if(fld!=null) {
	                fields.add(fld);

	                if (String.isNotBlank(fld.name)) {
	                    fieldsMap.put(fld.name.toUpperCase(), fld);
	                }
	            }
            }
        }
        return new Section(conf, fields);
    }

    protected virtual Field getField(SFA2_Configuration_Object_Detail_gne__c confDetail) {
        Schema.DescribeFieldResult fieldDescribe = confDetail.Type_gne__c == FIELD && String.isNotBlank(confDetail.API_Name_gne__c) ? sObjectFieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase()) : null;
        System.debug('##### Field Describe === ' + fieldDescribe);
        Field fld = new Field(confDetail, getFieldValue(confDetail, fieldDescribe), getDisplayValue(confDetail, fieldDescribe), fieldDescribe, sObjectType);

        if(fld.name=='CreatedById') {
            fld.setProperty('datetime', record.get('CreatedDate')!=null ? ((DateTime)record.get('CreatedDate')).format() : null);
        } else if(fld.name=='LastModifiedById') {
            fld.setProperty('datetime', record.get('LastModifiedDate')!=null ? ((DateTime)record.get('LastModifiedDate')).format() : null);
        }

        return fld;
    }

    protected virtual RelatedList getRelatedList(SFA2_Configuration_Object_Detail_gne__c confDetail, List<RelatedList> relatedList) {
        RelatedList rl = new RelatedList(confDetail, getChildRelationshipsMap());
        relatedList.add(rl);
        return rl;
    }

    protected virtual ConfigItem getIncludedPage(SFA2_Configuration_Object_gne__c conf, SFA2_Configuration_Object_Detail_gne__c confDetail, List<Section> sections, List<RelatedList> relatedList) {
        Section result = new Section(confDetail.API_Name_gne__c, confDetail.Label_gne__c, (Double)confDetail.Order_gne__c, String.isNotBlank(confDetail.Attributes_gne__c) ? confDetail.Attributes_gne__c : conf.Attributes_gne__c, new List<Field>());
        sections.add(result);
        return result;
    }

    protected virtual Map<String, Schema.ChildRelationship> getChildRelationshipsMap() {
        if (childRelationshipsMap == null) {
            childRelationshipsMap = new Map<String, Schema.ChildRelationship>();
            List<Schema.ChildRelationship> childRelationship =  getSObjectDescribe().getChildRelationships();

            for (Schema.ChildRelationship cRel : childRelationship) {
                if (cRel.getField() != null) {
                    String key = (String.valueOf(cRel.getChildSObject()) + '.' + String.valueOf(cRel.getField())).toLowerCase();
                    childRelationshipsMap.put(key, cRel);
                }
            }
        }

        return childRelationshipsMap;
    }

    protected virtual void prepareRelatedListRecords(List<RelatedList> relatedLists) {
        if(!relatedLists.isEmpty()) {
            List<RelatedList> thisRelatedLists = new List<RelatedList>();
            List<RelatedList> moreRelatedLists = new List<RelatedList>();
            List<String> childQueries = new List<String>();
		    Set<String> rlNames = new Set<String>();

		    for(RelatedList rl : relatedLists) {
                if(rl.relationshipName==null || rlNames.add(rl.relationshipName.toUpperCase())) {
                    thisRelatedLists.add(rl);
                    String rlQuery = getRelatedListQuery(rl);

			        if(String.isNotBlank(rlQuery)) {
                        childQueries.add('(' + rlQuery + ')');
                    }

                } else if(rl.relationshipName!=null) {
                    moreRelatedLists.add(rl);
                }
		    }

		    if(!childQueries.isEmpty()) {
    			String query = String.format('SELECT {0} FROM {1} WHERE Id = {2} LIMIT 1', new String[] {
			                                         String.join(childQueries, ','),
			                                         sObjectType,
			                                         ':recordId'
                });

			    List<SObject> recs = queryRelatedListRecords(query);

                if (!recs.isEmpty()) {
                    SObject rec = recs[0];
                    for (RelatedList rl : thisRelatedLists) {
                        setRelatedListRecords(rl, rec);
                    }
                }
            }

            if(!moreRelatedLists.isEmpty()) {
                prepareRelatedListRecords(moreRelatedLists);
            }
        }
    }

    protected virtual String getRelatedListQuery(RelatedList rl) {
        Set<String> fldNames = new Set<String>();

        for (RelatedListField rlFld : rl.fields) {
            fldNames.add(rlFld.name.toLowerCase());

            if (rlFld.type == 'reference') {
                fldNames.add(getRalationshipNameFieldForQuery(rlFld.relationshipName, rlFld.referenceSObjectName));

                if (rlFld.name == 'CreatedById') {
                    fldNames.add('createddate');
                } else if (rlFld.name == 'LastModifiedById') {
                    fldNames.add('lastmodifieddate');
                }
            }
        }

        fldNames.add(rl.parentFieldName.toLowerCase());

        String filter = getRelatedListFilter(rl);
        Integer childrenLimit = 100;
        return String.format('SELECT {0} FROM {1}{2} ORDER BY {3} {4} LIMIT {5}', new String[] {
                                 String.join(new List<String>(fldNames), ','),
                                 rl.relationshipName,
                                 String.isNotBlank(filter) ? (' WHERE ' + filter) : '',
                                 String.isNotBlank(rl.sortBy) ? rl.sortBy : rl.fields[0].name,
                                 String.isNotBlank(rl.sortDirection) ? rl.sortDirection : 'ASC',
                                 String.valueOf(childrenLimit + 1)
                             });
    }


    protected virtual List<SObject> queryRelatedListRecords(String query) {
        return Database.query(query);
    }


    protected virtual void setRelatedListRecords(RelatedList rl, SObject rec) {
    	rl.addRows(rec.getSObjects(rl.relationshipName));
    }

    protected virtual String getRelatedListFilter(RelatedList rl) {
        return String.isNotBlank(rl.filter) ? rl.filter.replaceAll('#', '=') : null;
    }

    protected virtual Field getFieldByName(String fieldName) {
        return fieldsMap != null ? fieldsMap.get(fieldName.toUpperCase()) : null;
    }

    protected virtual Object getFieldValue(SFA2_Configuration_Object_Detail_gne__c confDetail, Schema.DescribeFieldResult fieldDescribe) {
        return fieldDescribe != null ? record.get(confDetail.API_Name_gne__c) : null;
    }

    protected virtual String getDisplayValue(SFA2_Configuration_Object_Detail_gne__c confDetail, Schema.DescribeFieldResult fieldDescribe) {
        SObject relObj = fieldDescribe != null && String.isNotBlank(fieldDescribe.getRelationshipName()) ? record.getSObject(fieldDescribe.getRelationshipName()) : null;
        Object relObjName = relObj != null ? relObj.get('Name') : null;
        return relObjName != null ? String.valueOf(relObjName) : null;
    }

    protected virtual sObject getRecord(List<SFA2_Configuration_Object_gne__c> configObjects) {
        SObject result = null;

        if (String.isBlank(recordId)) {
            result = getSObjectDescribe().getSobjectType().newSObject();
        } else {
            Set<String> fieldNames = getQueryFields(configObjects);
            String query = String.format('SELECT {0} FROM {1} WHERE {2} LIMIT 1', new String[] {
                                             String.join(new List<String>(fieldNames), ','),
                                             sObjectType,
                                             getRecordQueryWhereExpression()
                                         });
            List<SObject> recs = Database.query(query);
            for(SObject rec : recs) {
                result = rec;
            }

            if(result==null) {
                throw createException(new DeletedRecordErrorException());
            }
        }

        return result;
    }

    protected virtual String getRecordQueryWhereExpression() {
        return 'Id =: recordId';
    }

    protected virtual Set<String> getQueryFields(List<SFA2_Configuration_Object_gne__c> configObjects) {
        Set<String> fieldNames = new Set<String> {'id', 'name'};

        if (params.get('fields') != null) {
            fieldNames.addAll(params.get('fields').split(','));
        }

        for (SFA2_Configuration_Object_gne__c conf : configObjects) {
            fieldNames.addAll(getQueryFieldsFromConfigObject(conf));
        }

        return fieldNames;
    }

    protected virtual Set<String> getQueryFieldsFromConfigObject(SFA2_Configuration_Object_gne__c conf) {
        Set<String> fieldNames = new Set<String>();
        sObjectFieldsDescribe = getSObjectFieldsDescribe();

        if (!conf.Configuration_Objects__r.isEmpty()) {
            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if (confDetail.Type_gne__c == FIELD && String.isNotBlank(confDetail.API_Name_gne__c) && sObjectFieldsDescribe.containsKey(confDetail.API_Name_gne__c.toLowerCase())) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();

                    fieldNames.add(fieldName);
                    // Add related fields
                    if (String.isNotBlank(sObjectFieldsDescribe.get(fieldName).getRelationshipName())) {
                        fieldNames.add(getRalationshipNameFieldForQuery(sObjectFieldsDescribe.get(fieldName).getRelationshipName(), null));
                    }

                    if (fieldName == 'CreatedById') {
                        fieldNames.add('createddate');
                    } else if (fieldName == 'LastModifiedById') {
                        fieldNames.add('lastmodifieddate');
                    }
                }
            }
        }
        return fieldNames;
    }

    protected virtual String getRalationshipNameFieldForQuery(String relationshipName, String referenceSObjectName) {
        return (relationshipName=='recordtype' ? 'toLabel(' + relationshipName + '.name)' : (String.isNotBlank(referenceSObjectName) && referenceSObjectName == 'Account') ? relationshipName + '.formatted_name_vod__c' : relationshipName + '.name').toLowerCase();
    }

    protected virtual DescribeSObjectResult getSObjectDescribe() {
        cacheSObjectDescribe();
        return sObjectDescribe;
    }

    protected virtual Map<String, Schema.DescribeFieldResult> getSObjectFieldsDescribe() {
        cacheSObjectDescribe();
        return sObjectFieldsDescribe;
    }

    protected virtual void cacheSObjectDescribe() {
        if (sObjectDescribe == null) {
            sObjectDescribe = Schema.getGlobalDescribe().get(sObjectType).getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            sObjectFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();
            for (String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                sObjectFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
        }
    }



    private static Set<String> getAttributeFlags(String attributes) {
        Set<String> result;

        if (String.isNotBlank(attributes)) {
            result = new Set<String>();
            Pattern flagPattern = Pattern.compile('(^|\\s|;|,)--([^\\s,;]+)');
            Matcher flagMatcher = flagPattern.matcher(attributes);

            while (flagMatcher.find()) {
                result.add(flagMatcher.group(2));
            }
        }

        return result;
    }

    public virtual DataWrapper performRemoteAction(String actionName, String inputDataWrapperInJSON, System.Type inputType) {
        this.dataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;

        try {
            this.inputDataWrapper = (DataWrapper)JSON.deserialize(inputDataWrapperInJSON, inputType);
            sObjectType = this.inputDataWrapper!=null && this.inputDataWrapper.recordDescribe!=null ? this.inputDataWrapper.recordDescribe.sObjectType : null;
            recordId = this.inputDataWrapper!=null && this.inputDataWrapper.recordDescribe!=null ? this.inputDataWrapper.recordDescribe.recordId : null;
            mode = this.inputDataWrapper!=null && this.inputDataWrapper.config!=null ? this.inputDataWrapper.config.mode : null;
            dataWrapper = intPerformRemoteAction(actionName);
            isOk = true;
        } catch (Exception ex) {
            handleException(ex);
        } finally {
            if (!isOk || this.dataWrapper.success!=true) {
                Database.rollback(sp);
            }
        }

        dataWrapper.onActionFinish(actionName);
        return dataWrapper;
    }

    protected virtual DataWrapper intPerformRemoteAction(String actionName) {
        DataWrapper result = null;

        if(actionName=='SaveRecord') {
            result = intSaveRecord();
        }

        return result;
    }

    public virtual DataWrapper saveRecord(String inputDataWrapperInJSON) {
        return saveRecord(inputDataWrapperInJSON, GNE_SFA2_Base_Ctrl.DataWrapper.class);
    }

    public virtual DataWrapper saveRecord(String inputDataWrapperInJSON, System.Type inputType) {
        return performRemoteAction('SaveRecord', inputDataWrapperInJSON, inputType);
    }

    protected virtual DataWrapper intSaveRecord() {
        sObjectType = inputDataWrapper.recordDescribe.sObjectType;
        record = (SObject)Type.forName(sObjectType).newInstance();
        updateRecordFields();

        if (validateRecord()) {
            upsertRecord();
            recordId = record.Id;
            dataWrapper.recordDescribe = inputDataWrapper.recordDescribe;
            dataWrapper.recordDescribe.recordId = recordId;
            dataWrapper.config = inputDataWrapper.config;
            dataWrapper.config.mode = VIEW_MODE;
            dataWrapper.config.fieldsToRefresh = refreshFieldValues();
            dataWrapper.recordDescribe.recordName = (String)recordAfterSave.get('Name');
            if(inputDataWrapper.urlParameters != null){
                dataWrapper.urlParameters = inputDataWrapper.urlParameters;
            }

        }

        return dataWrapper;
    }

    protected virtual void upsertRecord() {
        executeDML(DmlOperations.UPS, record);
    }

    protected virtual void updateRecordFields() {
    	if (String.isNotBlank(inputDataWrapper.recordDescribe.recordId)) {
            record.Id = inputDataWrapper.recordDescribe.recordId;
        }

        if (inputDataWrapper.recordDescribe.recordType != null) {
            record.put('RecordTypeId', inputDataWrapper.recordDescribe.recordType.Id);
            record.putSObject('RecordType', inputDataWrapper.recordDescribe.recordType);
        }

        if (inputDataWrapper.appContext.currentUser.id != UserInfo.getUserId()) {
            Id userId = inputDataWrapper.appContext.currentUser.id;
            setRecordOwner(record, userId);
        }

        if (inputDataWrapper.inputFields != null) {
            for (Field siField : inputDataWrapper.inputFields) {
            	if (siField.hidden != true) {
                    record.put(siField.name, siField.getValue());
                }
            }
        }
    }

    protected virtual Boolean validateRecord() {
        return true;
    }

    protected virtual void setRecordOwner(SObject rec, Id userId) {
        try {
            rec.put('OwnerId', userId);
        } catch (System.SObjectException soe) {}
    }

    protected virtual Map<String, Field> refreshFieldValues() {
        if (inputDataWrapper.config != null && inputDataWrapper.config.fieldsToRefresh != null) {
            Set<String> fieldNames = getQueryFieldsAfterSave();
            recordAfterSave = getRecordAfterSave(fieldNames);

            for (String fieldName : inputDataWrapper.config.fieldsToRefresh.keySet()) {
                Field fld = inputDataWrapper.config.fieldsToRefresh.get(fieldName);
                inputDataWrapper.config.fieldsToRefresh.get(fieldName).setValue(recordAfterSave.get(fieldName));

                if (fld.describe.type == 'reference' && recordAfterSave.getSObject(fld.describe.relationshipName) != null) {
                    fld.displayValue = (String)recordAfterSave.getSObject(fld.describe.relationshipName).get('Name');
                }
            }
        }

        return inputDataWrapper.config.fieldsToRefresh;
    }

    protected virtual Set<String> getQueryFieldsAfterSave() {
        Set<String> fieldNames = new Set<String> {'id', 'name'};

        for (String fieldName : inputDataWrapper.config.fieldsToRefresh.keySet()) {
            Field fld = inputDataWrapper.config.fieldsToRefresh.get(fieldName);

            if (!fieldName.contains('::')) {
                fieldNames.add(fieldName.toLowerCase());

                if (fld.describe.type == 'reference') {
                    fieldNames.add(getRalationshipNameFieldForQuery(fld.describe.relationshipName, null));
                }
            }
        }

        return fieldNames;
    }

    protected virtual SObject getRecordAfterSave(Set<String> fieldNames) {
        return Database.query(String.format('SELECT {0} FROM {1} WHERE Id = :recordId', new String[] {
                                                String.join(new List<String>(fieldNames), ','),
                                                sObjectType
                                            }));
    }

    public virtual DataWrapper deleteRecord(String inputDataWrapperInJSON) {
        return deleteRecord(inputDataWrapperInJSON, GNE_SFA2_Base_Ctrl.DataWrapper.class);
    }

    public virtual DataWrapper deleteRecord(String inputDataWrapperInJSON, System.Type inputType) {
        this.dataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;

        try {
            this.inputDataWrapper = (DataWrapper)JSON.deserialize(inputDataWrapperInJSON, inputType);
            dataWrapper = intDeleteRecord();
            isOk = true;
        } catch (Exception ex) {
            handleException(ex);
        } finally {
            if (!isOk || this.dataWrapper.success!=true) {
                Database.rollback(sp);
            }
        }

        dataWrapper.onActionFinish('DeleteRecord');
        return dataWrapper;
    }

    protected virtual DataWrapper intDeleteRecord() {
        sObjectType = inputDataWrapper.recordDescribe.sObjectType;
        record = (SObject)Type.forName(sObjectType).newInstance();
        record.Id = inputDataWrapper.recordDescribe.recordId;
        executeDml(DmlOperations.DEL, record);
        dataWrapper.retUrl = inputDataWrapper.retUrl;
        return dataWrapper;
    }

    protected virtual void executeDml(DmlOperations operationType, SObject rec) {
        executeDml(operationType, new List<SObject> {rec}, null);
    }

    protected virtual void executeDml(DmlOperations operationType, SObject rec, Boolean sharingMode) {
        executeDml(operationType, new List<SObject> {rec}, sharingMode);
    }

    protected virtual void executeDml(DmlOperations operationType, List<SObject> recs) {
        executeDml(operationType, recs, null);
    }

    protected virtual void executeDml(DmlOperations operationType, List<SObject> recs, Boolean sharingMode) {
        try {
            DmlExecutor dmlExec = sharingMode == true ? new DmlExecutorWithSharing() : (sharingMode == false ? new DmlExecutorWithoutSharing() : new DmlExecutor());
            dmlExec.executeDml(operationType, recs);
        } catch (DMLException dmlEx) {
            BaseException lastException;
            Map<String, Field> fieldsMap = inputDataWrapper != null && inputDataWrapper.config != null ? inputDataWrapper.config.fieldsToRefresh : null;

            for (Integer i = 0; i < dmlEx.getNumDml(); i++) {
                SObject rec = recs[dmlEx.getDmlIndex(i)];
                lastException = createException(new DmlErrorException(dmlEx, rec, i, fieldsMap));

                if (i < dmlEx.getNumDml() - 1) {
                    dataWrapper.addError(lastException);
                }
            }

            throw lastException;
        }
    }

    protected virtual List<SObject> query(String query) {
        return query(query, null);
    }

    protected virtual List<SObject> query(String query, Boolean sharingMode) {
        QueryExecutor queryExec = sharingMode == true ? new QueryExecutorWithSharing() : (sharingMode == false ? new QueryExecutorWithoutSharing() : new QueryExecutor());
        return queryExec.query(query);
    }

    protected virtual Id getCurrentTerritoryId() {
        cacheCurrentTerritory();
        return currentTerritory != null ? currentTerritory.Id : null;
    }

    protected virtual Territory2 getCurrentTerritory() {
        cacheCurrentTerritory();
        return currentTerritory;
    }

    private virtual void cacheCurrentTerritory() {
        if (userTerritoriesCache == null) {
            Id currentTerritoryId = null;
            currentTerritory = null;
            Id userId = getCurrentUser().id;

            userTerritoriesCache = GNE_SFA2_Util.getUserTerritories(userId);
            Set<Id> userTerritoriesIds = new Set<Id>(new Map<Id, Territory2>(userTerritoriesCache).keySet());

            List<SFA2_User_Preferences_gne__c> userPreferences = [
              SELECT Last_Territory_Used_gne__c
              FROM  SFA2_User_Preferences_gne__c
              WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts'
                AND OwnerId = :userId
                AND Last_Territory_Used_gne__c IN :userTerritoriesIds
              LIMIT 1
            ];

            if (!userPreferences.isEmpty()) {
                currentTerritoryId = (Id)userPreferences[0].Last_Territory_Used_gne__c;
            } else if (!userTerritoriesCache.isEmpty()) {
                currentTerritoryId = userTerritoriesCache[0].Id;
            }

            if (currentTerritoryId != null) {
                currentTerritory = new Map<Id, Territory2>(userTerritoriesCache).get(currentTerritoryId);
            }
        }
    }

    public static Object convertFieldValue(String value, String type) {
        Object result = String.isNotBlank(value) ? value : (type == 'boolean' ? 'false' : null);

        if (result != null) {
            if (type == 'date' || type == 'datetime' || type == 'time') {
                result = DateTime.newInstance(Long.valueOf((String)result));

                if (type == 'date') {
                    result = ((DateTime)result).date();
                } else if (type == 'time') {
                    result = ((DateTime)result).time();
                }
            } else if (type == 'double') {
                result = Double.valueOf(result);
            } else if (type == 'integer') {
                result = Integer.valueOf(result);
            } else if (type == 'boolean') {
                result = Boolean.valueOf(result);
            }
        }

        return result;
    }

    public static BaseException staticCreateException(BaseException ex) {
        return staticCreateException(ex, null);
    }

    public static BaseException staticCreateException(BaseException ex, List<Object> a_labelParams) {
        List<String> labelParams = new List<String>();

        if (a_labelParams != null) {
            for (Object param : a_labelParams) {
                labelParams.add(param != null ? String.valueOf(param) : '');
            }
        }

        ex.init(labelParams);
        return ex;
    }

    global virtual class DataWrapper {
        public AppContext appContext;
        public Boolean isSfaBrandUser;
        public RecordDescribe recordDescribe;
        public Config config;
        public Boolean initMore;
        public String uiType;
        public Boolean isStandardUI;
        public List<ExceptionWrapper> errors;
        public List<ExceptionWrapper> warnings;
        public List<ExceptionWrapper> infos;
        public String retUrl;
        public Boolean success;
        public List<String> debugInfos;
        public Boolean isDebugMode;
        public transient DateTime startTimeStamp;
        public List<Field> inputFields;
        public String iconBase64;
        public String userObjectPrefix;
        public Map<String,String> translationsMap;
        public Boolean isPopupMode;
        public String popupReturnAction;
        public Map<String, String> urlParameters;

        global DataWrapper() {
            this.success = true;
            this.startTimeStamp = System.now();
        }

        public virtual void onActionFinish(String actionName) {
            Long execTimeMilis = this.startTimeStamp != null ? (System.now().getTime()  - this.startTimeStamp.getTime()) : null;

            if (debugInfos == null) {
                debugInfos = new List<String>();
            }

            debugInfos.add(String.format(
                               'Action: {0}\nExec Time : {1} ms | CPU Time:  {2}/{3} ms\n' +
                               'Query Statements:  {4}/{5} | Query Rows:  {6}/{7}\n' +
                               'DML Statements:  {8}/{9} | DML Rows:  {10}/{11}\n'/* + 'Script Statements : {12}/{13}'*/, new String[] {
                                   actionName, execTimeMilis.format(),
                                   Limits.getCpuTime().format(), Limits.getLimitCpuTime().format(),
                                   Limits.getQueries().format(), Limits.getLimitQueries().format(),
                                   Limits.getQueryRows().format(), Limits.getLimitQueryRows().format(),
                                   Limits.getDmlStatements().format(), Limits.getLimitDmlStatements().format(),
                                   Limits.getDmlRows().format(), Limits.getLimitDmlRows().format()
                                   //Limits.getScriptStatements().format(), Limits.getLimitScriptStatements().format()
                               }));
        }

        public List<ExceptionWrapper> getErrors() {
            if (errors == null) {
                errors = new List<ExceptionWrapper>();
            }

            return errors;
        }

        public List<ExceptionWrapper> getWarnings() {
            if (warnings == null) {
                warnings = new List<ExceptionWrapper>();
            }

            return warnings;
        }

        public List<ExceptionWrapper> getInfos() {
            if (infos == null) {
                infos = new List<ExceptionWrapper>();
            }

            return infos;
        }

        public void addError(BaseException ex) {
            addError(new ExceptionWrapper(ex), true);
        }

        public void addError(BaseException ex, Boolean failTransaction) {
            addError(new ExceptionWrapper(ex), failTransaction);
        }

        public void addError(String message) {
            addError(new ExceptionWrapper(message), true);
        }

        public void addError(String message, Boolean failTransaction) {
            addError(new ExceptionWrapper(message), failTransaction);
        }

        public void addError(ExceptionWrapper ex) {
            addError(ex,true);
        }

        public void addError(ExceptionWrapper ex, Boolean failTransaction) {
            addMessage(ex, getErrors());

            if(failTransaction!=false) {
                this.success = false;
            }
        }

        public void addWarning(BaseException ex) {
            addWarning(new ExceptionWrapper(ex));
        }

        public void addWarning(String message) {
            addWarning(new ExceptionWrapper(message));
        }

        public void addWarning(ExceptionWrapper ex) {
            addMessage(ex, getWarnings());
        }

        public void addInfo(BaseException ex) {
            addInfo(new ExceptionWrapper(ex));
        }

        public void addInfo(String message) {
            addInfo(new ExceptionWrapper(message));
        }

        public void addInfo(ExceptionWrapper ex) {
            addMessage(ex, getInfos());
        }

        private void addMessage(ExceptionWrapper exWrapper, List<ExceptionWrapper> messages) {
            messages.add(exWrapper);
        }

    }

    public class AppContext {
        public String appName;
        public String brand;
        public String role;
        public Boolean isSfa2Mode;
        public UserWrapper currentUser;

        public AppContext(UserWrapper currentUser, String appName, String brand, String role, Boolean isSfa2Mode) {
            this.appName = appName;
            this.brand = brand;
            this.role = role;
            this.isSfa2Mode = isSfa2Mode;
            this.currentUser = currentUser;
        }
    }

    public class UserWrapper {
        public Id id;
        public String name;
        public Id profileId;
        public String profileName;
        public String timeZone;
        public Boolean isSfaBrand;
        public Boolean isCanada;
        public Boolean isFrm;
        public Boolean isBam;
        public Boolean isCrm;
        public Boolean isSbm;
        public Boolean isTls;
        public Boolean isCCEsbriet;
        public Boolean isCCCrm;


        public UserWrapper(User user) {
            this.id = user.Id;
            this.name = user.FirstName + ' ' + user.LastName;
            this.profileId = user.ProfileId;
            this.timeZone = user.TimeZoneSidKey;
        }

        public void setProfileName(String profileName) {
            this.profileName = profileName;
        }

        public String getProfileName() {
            if(profileName==null) {
                profileName='';

                for(Profile p : [SELECT Name FROM Profile WHERE Id = :this.profileId LIMIT 1]) {
                    profileName = p.Name;
                }
            }

            return profileName;
        }

        public Boolean isSfaBrand() {
            if(isSfaBrand==null) {
                isSfaBrand = GNE_SFA2_Util.isBrandUser(getProfileName());
            }

            return isSfaBrand;
        }
        
        public Boolean isEMSCanadaUser() {
	        if (EMS_Util.getUserApplication() == 'EMS-Canada') {
	            return true;
	        }
	        return false;
	    }

        public Boolean isCanada() {
            if(isCanada==null) {
                isCanada = GNE_SFA2_Util.isCanadaUser(getProfileName());
            }

            return isCanada;
        }

        public Boolean isFrm() {
            if(isFrm==null) {
                isFrm = Pattern.matches('GNE-MCCO-FRM-.*', getProfileName().toUpperCase()) || getProfileName().toUpperCase().contains('GNE-CRM');
            }

            return isFrm;
        }

        public Boolean isBam() {
            if(isBam==null) {
                isBam = GNE_SFA2_Util.isBamCrmUser(getProfileName());
            }

            return isBam;
        }

        public Boolean isCrm() {
            if(isCrm==null) {
                isCrm = GNE_SFA2_Util.isCrmUser(getProfileName());
            }

            return isCrm;
        }

        public Boolean isSbm() {
            if (isSbm == null) {
                isSbm = GNE_SFA2_Util.isSBMUser();
            }

            return isSbm;
        }

        public Boolean isTls() {
            if (isTls == null) {
                isTls = GNE_SFA2_Util.isTLSUser();
            }

            return isTls;
        }

        public Boolean isCCEsbriet() {
            if (isCCEsbriet == null) {
                isCCEsbriet = GNE_SFA2_Util.isEsbrietCrmUser();
            }

            return isCCEsbriet;
        }
        
        public Boolean isCCCrm() {
            if (isCCCrm == null) {
                isCCCrm = GNE_SFA2_Util.isCCCrmUser();
            }

            return isCCCrm;
        }
    }

    public class RecordAccess {
        public Boolean readAccess;
        public Boolean editAccess;
        public Boolean deleteAccess;

        public RecordAccess(Boolean readAccess, Boolean editAccess, Boolean deleteAccess) {
            this.readAccess = readAccess;
            this.editAccess = editAccess;
            this.deleteAccess = deleteAccess;
        }
    }

    public class RecordDescribe {
        public Id recordId;
        public String recId; //15 characters Id to support standard related lists
        public String recordName;
        public String sObjectType;
        public String sObjectLabel;
        public RecordType recordType;
        public RecordAccess recordAccess;

        public RecordDescribe(Id recordId, String recordName, String sObjectType, String sObjectLabel, RecordType recordType, RecordAccess recordAccess) {
            this.recordId = recordId;
            this.recId = recordId == null ? null : String.valueOf(recordId).substring(0, 15);
            this.recordName = recordName;
            this.sObjectType = sObjectType;
            this.sObjectLabel = sObjectLabel;
            this.recordType = recordType;
            this.recordAccess = recordAccess;
        }
    }

    public class Config {
        public String mode;
        public List<Button> buttons;
        public List<Section> sections;
        public List<RelatedList> relatedlists;
        public Map<String, Field> fieldsToRefresh;

        public Config(String mode, List<Button> buttons, List<Section> sections, List<RelatedList> relatedlists) {
            this.mode = mode;
            this.buttons = buttons;
            this.sections = sections;
            this.relatedlists = relatedlists;
        }
    }

    public class Button extends ConfigItem {
        public Integer order;
        public String action;
        public String retUrl;
        public Boolean isActionButton;
        public Boolean isMoreButton;
        public String image;
        private transient Map<String,String> attributesCache;

        public Button(SFA2_Configuration_Object_Detail_gne__c confDetail) {
            this(confDetail.Label_gne__c, Integer.valueOf(confDetail.Order_gne__c), confDetail.Attributes_gne__c);
        }

        public Button(String label, Integer order, String attributes) {
            super(null, label, attributes);
            this.order = order;
            this.action = getAttribute('action');
            this.retUrl = getAttribute('retUrl');
            this.isActionButton = getBooleanAttribute('isActionButton');
            this.isMoreButton = getBooleanAttribute('isMoreButton');
            this.image = getAttribute('image');
        }

        private Map<String,String> getAttributesCache() {
            if(this.attributesCache==null) {
                this.attributesCache = new Map<String,String>();

                if(String.isNotBlank(this.attributes)) {
                    for(String a : this.attributes.split(';')) {
                        if(a.contains('=')) {
                            this.attributesCache.put(a.substringBefore('=').toLowerCase().trim(), a.substringAfter('=').trim());
                        }
                    }
                }
            }

            return this.attributesCache;
        }

        private String getAttribute(String name) {
            return getAttributesCache().get(name.toLowerCase());
        }

        private Boolean getBooleanAttribute(String name) {
            String val = getAttribute(name);
            return val!=null && new Set<String>{'1','true', 'yes'}.contains(val.toLowerCase());
        }
    }

    public class Section extends ConfigItem {
        public Double order;
        public List<Field> fields;
        public Boolean isCollapsed;

        public Section(SFA2_Configuration_Object_gne__c conf, List<Field> fields) {
            this(conf.Name, conf.Section_Header_gne__c, (Double)conf.Order_gne__c, conf.Attributes_gne__c, fields);
        }

        public Section(String name, String label, Integer order, String attributes, List<Field> fields) {
            this(name, label, (Double)order, attributes, fields);
        }

        public Section(String name, String label, Double order, String attributes, List<Field> fields) {
            super(name, label, attributes);
            this.order = order;
            this.fields = fields;
            this.isCollapsed = attributes!=null && attributes.containsIgnoreCase('initiallyCollapsed=true');
        }
    }

    public virtual class Field extends ConfigItem {
        public String value;
        public String displayValue;
        public Integer order;
        public List<String> mode {get; set;}
        public Boolean readOnly;
        public Boolean required;
        public Boolean hidden;
        public String helpText;
        public String placeholder;
        public FieldDescribe describe;

        public Field() {}

        public Field(SFA2_Configuration_Object_Detail_gne__c confDetail, Object value, String displayValue, Schema.DescribeFieldResult describe, String sObjectType) {
            this(confDetail.API_Name_gne__c, confDetail.Label_gne__c, value, displayValue, Integer.valueOf(confDetail.Order_gne__c), String.isNotBlank(confDetail.Availability_Mode_gne__c) ? confDetail.Availability_Mode_gne__c.split(';') : null, confDetail.Is_Read_Only_gne__c, confDetail.Is_Required_gne__c, confDetail.Attributes_gne__c, describe != null ? new FieldDescribe(describe, sObjectType) : null);
        }

        public Field(SFA2_Configuration_Object_Detail_gne__c confDetail, Schema.DescribeFieldResult describe, String sObjectType) {
            this(confDetail, confDetail.API_Name_gne__c, confDetail.Label_gne__c, null, null, Integer.valueOf(confDetail.Order_gne__c), String.isNotBlank(confDetail.Availability_Mode_gne__c) ? confDetail.Availability_Mode_gne__c.split(';') : null, confDetail.Is_Read_Only_gne__c, confDetail.Is_Required_gne__c, confDetail.Attributes_gne__c, describe != null ? new FieldDescribe(describe, sObjectType) : null);
        }

        public Field(Field otherField) {
            this(otherField.name, otherField.label, otherField.value, otherField.displayValue, otherField.order, otherField.mode, otherField.readOnly, otherField.required, otherField.attributes, otherField.describe);
        }

        public Field(String name, String label) {
            this(name, label, null, null, null, null, true, false, null, null);
        }

        public Field(String label, Object value, Boolean readOnly, Boolean required, Schema.DescribeFieldResult describe, String sObjectType) {
            this(describe.getName(), label, value, null, null, null, readOnly, required, null, new FieldDescribe(describe, sObjectType));
        }

        public Field(String label, Object value, Boolean readOnly, Boolean required) {
            this(null, label, value, null, null, null, readOnly, required, null, null);
        }

        public Field(String label, Object value, Boolean readOnly, Boolean required, FieldDescribe describe) {
            this(describe.name, label, value, null, null, null, readOnly, required, null, describe);
        }

        public Field(Object value, Boolean readOnly, Boolean required, Schema.DescribeFieldResult describe, String sObjectType) {
            this(describe.getName(), describe.getLabel(), value, null, null, null, readOnly, required, null, new FieldDescribe(describe, sObjectType));
        }

        public Field(Object value, Boolean readOnly, Boolean required, FieldDescribe describe) {
            this(describe.name, describe.label, value, null, null, null, readOnly, required, null, describe);
        }

        // Deprecated
        public Field(String name, String label, List<String> mode) {
            this(name, label, null, null, null, mode, true, false, null, null);
        }

        public Field(String name, String label, Object value, String displayValue, Integer order, List<String> mode, Boolean readOnly, Boolean required, String attributes, FieldDescribe describe) {
            super(name, label, attributes);
            this.value = value != null ? String.valueOf(value) : null;
            this.displayValue = displayValue;
            this.order = order;
            this.mode = mode != null && !mode.isEmpty() ? mode : new List<String> {NEW_MODE, EDIT_MODE, VIEW_MODE};
            this.readOnly = describe == null ? readOnly : readOnly || !describe.updateable;
            this.required = required;
            this.describe = describe;
            this.helpText = describe != null ? describe.inlineHelpText : null;
        }

        public Field(SFA2_Configuration_Object_Detail_gne__c confDetail, String name, String label, Object value, String displayValue, Integer order, List<String> mode, Boolean readOnly, Boolean required, String attributes, FieldDescribe describe) {
            super(name, label, attributes);
            this.value = value != null ? String.valueOf(value) : null;
            this.displayValue = displayValue;
            this.order = order;
            this.mode = mode != null && !mode.isEmpty() ? mode : new List<String> {NEW_MODE, EDIT_MODE, VIEW_MODE};
            this.readOnly = describe == null ? readOnly : readOnly || !describe.updateable;
            this.required = required;
            this.describe = describe;
            this.helpText = confDetail.Help_Text_gne__c  != null ? confDetail.Help_Text_gne__c : describe != null ? describe.inlineHelpText : null;
        }

        public void setValue(Object value) {
            this.value = value != null ? String.valueOf(value) : null;
        }

        public Object getValue() {
            Object result = null;

            try {
                result = convertFieldValue(value, describe != null ? describe.type : 'string');
            } catch (System.TypeException ste) {
                throw staticCreateException(new WrongFieldValueTypeException(this));
            }

            return result;
        }

        public void changeToBlankSpace() {
            this.name = BLANK_SPACE;
            this.label = this.value = this.displayValue = null;
            this.describe = null;
        }
    }

    public class FieldDescribe {
        public String name;
        public String label;
        public String sObjectType;
        public String inlineHelpText;
        public Integer length;
        public List<PicklistValue> picklistValues;
        public Boolean dependentPicklist;
        public String controllingField;
        public Boolean restrictedPicklist;
        public List<String> referenceTo;
        public String relationshipName;
        public String type;
        public Boolean createable;
        public Boolean updateable;
        public Boolean calculated;
        public Boolean permissionable;
        public Boolean nillable;
        public Boolean htmlFormatted;
        public Boolean caseSensitive;
        public CustomLookupData lookupData;
        public Boolean showNone;

        public FieldDescribe() {
            this.createable = this.updateable = this.permissionable = this.nillable = true;
            this.dependentPicklist = this.restrictedPicklist = this.htmlFormatted = this.caseSensitive = false;
        }

        public FieldDescribe(Schema.DescribeFieldResult schemaDescribe, String sObjectType) {
            this.name = schemaDescribe.getName();
            this.label = schemaDescribe.getLabel();
            this.type = schemaDescribe.getType().name().toLowerCase();
            this.sObjectType = sObjectType;
            this.inlineHelpText = schemaDescribe.getInlineHelpText();
            this.length = type == 'integer' ? schemaDescribe.getDigits() : type == 'double' ? schemaDescribe.getPrecision() : schemaDescribe.getLength();
            this.length = this.length == 0 ? null : this.length;
            this.picklistValues = convertPicklistValues(schemaDescribe.getPicklistValues());
            this.dependentPicklist = schemaDescribe.isDependentPicklist();
            this.controllingField = schemaDescribe.getController() != null ? String.valueOf(schemaDescribe.getController()) : null;
            this.restrictedPicklist = schemaDescribe.isRestrictedPicklist();
            this.referenceTo = new List<String>();
            for (SObjectType sobjType : schemaDescribe.getReferenceTo()) {
                this.referenceTo.add(String.valueOf(sobjType));
            }
            this.relationshipName = schemaDescribe.getRelationshipName();
            this.createable = schemaDescribe.isCreateable();
            this.updateable = schemaDescribe.isUpdateable();
            this.calculated = schemaDescribe.isCalculated();
            this.permissionable = schemaDescribe.isPermissionable();
            this.nillable = schemaDescribe.isNillable();
            this.htmlFormatted = schemaDescribe.isHtmlFormatted();
            this.caseSensitive = schemaDescribe.isCaseSensitive();

            if(type=='reference') {
                this.lookupData = new CustomLookupData();
            }
        }

        private List<PicklistValue> convertPicklistValues(List<Schema.PicklistEntry> picklistValues) {
            List<PicklistValue> result = null;

            if (picklistValues != null) {
                result = new List<PicklistValue>();

                for (Schema.PicklistEntry ple : picklistValues) {
                    result.add(new PicklistValue(ple));
                }
            }

            return result;
        }
    }

    public class PicklistValue {
        public String value;
        public String label;
        public Boolean active;
        public Boolean defaultValue;

        public PicklistValue(String value, String label, Boolean active, Boolean defaultValue) {
            this.value = value;
            this.label = label;
            this.active = active;
            this.defaultValue = defaultValue;
        }

        public PicklistValue(String value, String label) {
            this(value, label, true, false);
        }

        public PicklistValue(String value) {
            this(value, value, true, false);
        }

        public PicklistValue(Schema.PicklistEntry ple) {
            this(ple.getValue(), ple.getLabel(), ple.isActive(), ple.isDefaultValue());
        }
    }

    public class CustomLookupData {
        public String lookupPage;
        public List<String> columns;
        public List<String> columnLabels;
        public CustomLookupFilter filter;
        public String displayField;
        public List<String> orderBy;

        public CustomLookupData() {
            this(null, null, null, null, null, null);
        }

        public CustomLookupData(String lookupPage) {
            this(lookupPage, null, null, null, null, null);
        }

        public CustomLookupData(String lookupPage, List<String> columns, List<String> columnLabels, CustomLookupFilter filter, String displayField, List<String> orderBy) {
            this.lookupPage = lookupPage!=null ? lookupPage : 'GNE_SFA2_Lookup';
            this.columns = columns!=null ? columns : new List<String>{'Name'};
            this.columnLabels = columnLabels!=null ? columnLabels : new List<String>{'Name'};
            this.filter = filter;
            this.displayField = displayField!=null ? displayField : 'Name';
            this.orderBy = orderBy!=null ? orderBy : new List<String>{'Name'};
        }
    }

    public class CustomLookupFilter {
        public String queryWhere;
        public List<String> queryRecIds;
        public List<String> searchFields;

        public CustomLookupFilter() {
            this(null, null, null);
        }

        public CustomLookupFilter(String queryWhere) {
            this(queryWhere, null, null);
        }

        public CustomLookupFilter(List<String> queryRecIds) {
            this(null, queryRecIds, null);
        }

        public CustomLookupFilter(String queryWhere, List<String> queryRecIds, List<String> searchFields) {
            this.queryWhere = queryWhere;
            this.queryRecIds = queryRecIds;
            this.searchFields = searchFields;
        }
    }

    public class RelatedList extends ConfigItem {
        public String sObjectType;
        public String parentFieldName;
        public String relationshipName;
        public Double order;
        public String mode;
        public List<RelatedListField> fields;
        public String sortBy;
        public String sortDirection;
        public String editUrl;
        public Integer pageSize;
        public Integer rowsMaxSize;
        public String customButtons;
        public List<RelatedListRowAction> rowActions;
        public List<RelatedListRecordWrapper> rows;
        public Boolean isMore;
        public Boolean isCollapsed;
        public Boolean alwaysDisplayViewAll;
        public String iconUrl;
        public String filter;
        public Boolean hideButtons;

        public RelatedList() {}

        public RelatedList(String name, String label, List<RelatedListField> fields) {
            super(name, label, null);
            this.order = 0.0;
            this.mode = VIEW_MODE;
            this.isMore = false;
            this.alwaysDisplayViewAll = false;
            this.pageSize = 5;
            this.rowsMaxSize = 100;
            this.fields = fields;
            this.hideButtons = false;
        }

        public RelatedList(SFA2_Configuration_Object_Detail_gne__c confDetail, List<RelatedListField> fields) {
            this(confDetail.API_Name_gne__c, confDetail.Label_gne__c, fields);
            this.order = confDetail.Order_gne__c;
            this.mode = confDetail.Availability_Mode_gne__c;
            this.iconUrl = confDetail.Icon_Url_gne__c;
        }

        public RelatedList(SFA2_Configuration_Object_Detail_gne__c confDetail, Map<String, Schema.ChildRelationship> childRels) {
        	this(confDetail, new List<RelatedListField>());
            Map<String, String> attributes = parseAttributes(confDetail.Attributes_gne__c);
            this.sObjectType = this.name.substringBefore('(');
            this.parentFieldName = attributes.get('parentFieldName');

            Schema.DescribeSObjectResult sObjectDescribe = GNE_SFA2_Util.getGlobalDescribe().get(this.sObjectType).getDescribe();
            Schema.ChildRelationship childRel = childRels.get((this.sObjectType + '.' + this.parentFieldName).toLowerCase());
            System.debug('##### String === ' + this.sObjectType + '.' + this.parentFieldName);
            System.debug('##### childRel === ' + childRel);

            List<String> fieldNames = attributes.containsKey('fieldsCSV') ? attributes.get('fieldsCSV').split(',') : null;
            List<String> fieldLabels = attributes.containsKey('fieldLabels') ? attributes.get('fieldLabels').split(',') : null;

            this.relationshipName = childRel != null ? childRel.getRelationshipName() : null;
            this.sortBy = attributes.get('orderByFieldName');
            this.sortDirection = attributes.get('sortDirection');
            this.editUrl = attributes.containsKey('urlForNewRecord') ? attributes.get('urlForNewRecord') : null;
            this.pageSize = attributes.containsKey('pageSize') ? Integer.valueOf(attributes.get('pageSize')) : 5;
            this.rowsMaxSize = attributes.containsKey('rowsMaxSize') ? Integer.valueOf(attributes.get('rowsMaxSize')) : 100;
            this.customButtons = attributes.containsKey('customButtons') ? attributes.get('customButtons') : null;
            this.isCollapsed = attributes.get('initiallyCollapsed')=='true';
            this.alwaysDisplayViewAll = attributes.get('alwaysDisplayViewAll') == 'true';
            this.filter = attributes.containsKey('filter') ? attributes.get('filter') : null;
            this.hideButtons = attributes.get('hideButtons') == 'true';
            String paramName = attributes.containsKey('paramName') ? attributes.get('paramName') : 'objectId';

            Boolean showNewButton = attributes.get('hideButtons') == 'false' && sObjectDescribe.isCreateable();

            if(showNewButton) {
            	if(this.sObjectType=='Task'){
            		this.customButtons = String.format('New {0}#url>{1}?who_id={2}&what_id={3}{4}', new String[]{
	                    sObjectDescribe.getLabel(),
	                    String.isNotBlank(this.editUrl) ? this.editUrl : ('/' + sObjectDescribe.getKeyPrefix() + '/e'),
	                    UserInfo.getUserId(),
	                    '{{recordDescribe.recId}}',
	                    String.isNotBlank(this.customButtons) ? (',' + this.customButtons) : ''
	                });
            	}else{
            		this.customButtons = String.format('New {1}#url>{2}?{0}={3}{4}', new String[]{
            			paramName,
	                    sObjectDescribe.getLabel(),
	                    String.isNotBlank(this.editUrl) ? this.editUrl : ('/' + sObjectDescribe.getKeyPrefix() + '/e'),
	                    '{{recordDescribe.recId}}',
	                    String.isNotBlank(this.customButtons) ? (',' + this.customButtons) : ''
	                });
            	}
            }

            this.rowActions = new List<RelatedListRowAction>();
            Boolean hideEdit = attributes.get('hideEditLink') == 'true';
            Boolean hideDelete = attributes.get('hideDeleteLink') == 'true';

            if(!hideEdit) {
                this.rowActions.add(new RelatedListRowAction('edit', 'Edit'));
            }

            if(!hideDelete) {
                this.rowActions.add(new RelatedListRowAction('delete', 'Del'));
            }

            String rowActionAsString = attributes.containsKey('rowActions') ? attributes.get('rowActions') : null;
            this.rowActions.addAll(String.isNotBlank(rowActionAsString) ? (List<RelatedListRowAction>)JSON.deserialize(rowActionAsString, List<RelatedListRowAction>.class) : new List<RelatedListRowAction>());

            this.fields = getRelatedListFields(sObjectDescribe, fieldNames != null ? fieldNames : new List<String>(), fieldLabels);
        }

        public List<RelatedListField> getRelatedListFields(Schema.DescribeSObjectResult sObjectDescribe, List<String> queryFields, List<String> fieldLabels) {
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            List<RelatedListField> result = new List<RelatedListField>();
            System.debug('##### queryFields === ' + queryFields);
            Integer idx = 0;
            for (String fldName : queryFields) {
                Boolean isLink = false;
                Boolean noLink = false;

                if (fldName.endsWith('#/')) {
                    fldName = fldName.substringBefore('#/');
                    isLink = true;
                }
                if (fldName.endsWith('#-')) {
                    fldName = fldName.substringBefore('#-');
                    noLink = true;
                }

                if (fldName.endsWith('.Name')) {
                    fldName = fldName.substringBefore('.Name').replace('__r', '__c');
                }

                if (objectFields.containsKey(fldName)) {
                    Schema.DescribeFieldResult fldDescribe = objectFields.get(fldName).getDescribe();
                    RelatedListField rlFld = new RelatedListField(fldName, fldDescribe, isLink);

                    if (fieldLabels != null && !fieldLabels.isEmpty()) {
                        rlFld.label = fieldLabels[idx];
                    }
                    if(noLink){
                        rlFld.type = 'nolink';
                    }
                    result.add(rlFld);
                }
                else if (fldName.contains('.') && fldName.split('\\.').size() == 2) {
                    String rlObjectFieldName = fldName.split('\\.').get(0).replace('__r', '__c');
                    String parentFieldName = fldName.split('\\.').get(1);

                    Schema.DescribeFieldResult fldDescribe = objectFields.get(rlObjectFieldName).getDescribe();
                    String parentObjectName = getParentObjectName(fldDescribe);

                    Schema.DescribeFieldResult parentFldDescribe = getParentFieldDescribe(parentObjectName, parentFieldName);

                    RelatedListField rlFld = new RelatedListField(fldName, fldDescribe, parentFldDescribe, isLink, parentFieldName);
                    if(noLink){
                        rlFld.type = 'nolink';
                    }
                    result.add(rlFld);
                }

                idx++;
            }
            return result;
        }

        private String getParentObjectName(Schema.DescribeFieldResult fldDescribe) {
            return fldDescribe.getReferenceTo()[0].getDescribe().getName();
        }

        private Schema.DescribeFieldResult getParentFieldDescribe(String parentObjectName, String parentFieldName) {
            Schema.DescribeSObjectResult parentObjectDescribe = GNE_SFA2_Util.getGlobalDescribe().get(parentObjectName).getDescribe();
            Map<String, Schema.SObjectField> parentObjectFields = parentObjectDescribe.fields.getMap();
            return parentObjectFields.get(parentFieldName).getDescribe();
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

        public void addRows(List<SObject> recs) {
        	  List<RelatedListRecordWrapper> newRows = new List<RelatedListRecordWrapper>();

        	  if(recs!=null) {
        	  	  for (SObject rec : recs) {
        	  	  	 newRows.add(new RelatedListRecordWrapper(rec, fields));
        	  	  }
        	  }

        	  addRows(newRows);
        }

        public void addRows(List<RelatedListRecordWrapper> rowWrapppers) {
	        	if (rows == null) {
	              rows = new List<RelatedListRecordWrapper>();
	          }

	          Integer currentSize = rows.size();

	          if (rowWrapppers != null) {
	              for (RelatedListRecordWrapper row : rowWrapppers) {
	                  if (currentSize == rowsMaxSize) {
	                      isMore = true;
	                      break;
	                  } else {
	                      rows.add(row);
	                      currentSize++;
	                  }
	              }
	          }
        }
    }

    public class RelatedListRowAction extends ConfigItem {
        public RelatedListRowAction(String name, String label) {
            super(name, label, null);
        }
    }

    @RemoteAction
    global static Map<String, String> editRelatedRecord(Map<String, String> params) {
        Map<String, String> result = params.clone();
        String recordId = result.get('recordId');
        String userId = result.get('userId');

        // Check if user has access to edit record
        result.put('isEditable', String.valueOf([SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId LIMIT 1].HasEditAccess));
        if(GNE_SFA2_Util.isCCCrmUser()){
            String keyPrefix = Call2_vod__c.sObjectType.getDescribe().getKeyPrefix();
            String recordPrefix = recordId.substring(0,3);
            System.debug('prefix'+recordPrefix);
            if(keyPrefix == recordPrefix) {
                List<Call2_vod__c> calls = [SELECT Interaction_Status_gne__c FROM Call2_vod__c WHERE Id = :recordId ];
                if(!calls.isEmpty() && calls[0].Interaction_Status_gne__c == 'Completed') {
                   result.put('isEditable', 'false');
                }
            }           
        }

        return result;
    }

    @RemoteAction
    global static Map<String,String> deleteRelatedRecord(Map<String, String> params) {
        Map<String, String> result = params.clone();
        String recordId = result.get('recordId');
        String sObjectName = result.get('sobject');

        SObject record = Database.query('SELECT Id FROM ' + sObjectName + ' WHERE Id =: recordId LIMIT 1');

        try {
            delete record;
            result.put('isDeleted', 'true');
            result.put('message', System.Label.GNE_SFA2_Record_Deleted);
        } catch (System.DmlException e) {
            result.put('isDeleted', 'false');
            result.put('exception', e.getDmlMessage(0));
        }

        return result;
    }

    public virtual class RelatedListField extends ConfigItem {
        public String type;
        public Boolean isLink;
        public String relationshipName;
        public String referenceSObjectName;
        public Boolean isParentRelationship;
        public String parentObjectFieldName;

        public RelatedListField(String fieldName, Schema.DescribeFieldResult fldDescribe, Schema.DescribeFieldResult parentFieldDescribe, Boolean isLink, String parentObjectFieldName) {
            this(fieldName, parentFieldDescribe.getLabel(), parentFieldDescribe.getType().name().toLowerCase(), isLink);
            this.relationshipName = fldDescribe.getRelationshipName();
            this.referenceSObjectName = !fldDescribe.getReferenceTo().isEmpty() ?  fldDescribe.getReferenceTo().get(0).getDescribe().getName() : null;
            this.isParentRelationship = true;
            this.parentObjectFieldName = parentObjectFieldName;
        }

        public RelatedListField(String fieldName, Schema.DescribeFieldResult fldDescribe, Boolean isLink) {
            this(fieldName, fldDescribe.getLabel(), fldDescribe.getType().name().toLowerCase(), isLink);
            this.relationshipName = fldDescribe.getRelationshipName();
            this.referenceSObjectName = !fldDescribe.getReferenceTo().isEmpty() ?  fldDescribe.getReferenceTo().get(0).getDescribe().getName() : null;
        }

        public RelatedListField(String fieldName, String label, String type, Boolean isLink) {
            super(fieldName, label, null);
            this.type = type;
            this.isLink = isLink;
            this.isParentRelationship = false;
        }
    }

    public abstract class ConfigItem {
        public String name;
        public String label;
        public String attributes;
        public Set<String> attributeFlags;
        public Map<String,String> properties;

        public ConfigItem() {}

        public ConfigItem(String name, String label, String attributes) {
            this.name = name;
            this.label = label;
            this.attributes = attributes;
            this.attributeFlags = getAttributeFlags(attributes);
        }

        public void setProperty(String prop, String value) {
            getProperties().put(prop,value);
        }

        public Map<String,String> getProperties() {
            if(properties==null) {
                properties = new Map<String,String>();
            }

            return properties;
        }
    }

    public virtual class RelatedListRecordWrapper {
        public String id;
        public Map<String, Object> values;
        public Map<String, String> displayValues;

        public RelatedListRecordWrapper(String id, Map<String, String> values) {
        	this(id, values, new Map<String,String>());
        }

        public RelatedListRecordWrapper(String id, Map<String, String> values, Map<String, String> displayValues) {
          this.id = id;
          this.values = values;
          this.displayValues = displayValues;
        }

        public RelatedListRecordWrapper(SObject rec, List<RelatedListField> fields) {

            id = rec.Id;
            values = new Map<String, Object>();
            displayValues = new Map<String, String>();

            for (RelatedListField fld : fields) {
                String fldName = fld.name.toLowerCase();
                String fldType = fld.type.toLowerCase();
                Object val = getRelatedListFieldValue(rec, fld);

                if(val!=null) {
                	if (fldType == 'date') {
                		Date d = Date.valueOf(val);
                    	val = DateTime.newInstanceGmt(d.year(), d.month(), d.day(), 12, 0, 0);
                	} else if(fld.type == 'reference' && String.isNotEmpty(fld.relationshipName) && rec.getSObject(fld.relationshipName)!=null) {
	                	String displayVal = null;
                        if(String.isNotEmpty(fld.referenceSObjectName) && fld.referenceSObjectName == 'Account') {
                            displayVal = (String)rec.getSObject(fld.relationshipName).get('Formatted_Name_vod__c');
                        } else {
                            displayVal = (String)rec.getSObject(fld.relationshipName).get('Name');
                        }

	                	if (fld.name == 'CreatedById') {
	                        DateTime dt = (DateTime)rec.get('CreatedDate');
                            values.put('createddate', String.valueOfGmt(dt));
	                        displayValues.put('createddate', dt.format());
	                    } else if (fld.name == 'LastModifiedById') {
	                        DateTime dt = (DateTime)rec.get('LastModifiedDate');
	                        values.put('lastmodifieddate', String.valueOfGmt(dt));
	                        displayValues.put('lastmodifieddate', dt.format());
	                    }
	                    displayValues.put(fldName, displayVal);
	                } else if (fld.isLink && fld.type != 'reference' && fldName.toLowerCase() != 'name'){
                    	values.put(fldName, id);
                    	displayValues.put(fldName, (String)val);
	                }
                }
                if(!values.containsKey(fldName)){
                	values.put(fldName, val);
                }
            }
        }

        private Object getRelatedListFieldValue(SObject rec, RelatedListField fld) {
            Object val;
            if (fld.isParentRelationship) {
                val = rec.getSObject(fld.relationshipName).get(fld.parentObjectFieldName);
            }
            else {
                val = rec.get(fld.name.toLowerCase());
            }
            return val;
        }
    }

    public virtual class DmlExecutor {
        protected virtual void executeDml(DmlOperations operationType, List<SObject> recs) {
            if (recs != null && !recs.isEmpty()) {
                if (operationType == DmlOperations.INS) {
                    insert recs;
                } else if (operationType == DmlOperations.UPD) {
                    update recs;
                } else if (operationType == DmlOperations.UPS) {
                    if (recs.size() == 1 && recs.getSObjectType() == null) {
                        upsert recs[0];
                    } else {
                        upsert recs;
                    }
                } else if (operationType == DmlOperations.DEL) {
                    delete recs;
                }
            }
        }
    }

    public with sharing class DmlExecutorWithSharing extends DmlExecutor {
        protected override void executeDml(DmlOperations operationType, List<SObject> recs) {
            super.executeDml(operationType, recs);
        }
    }

    public without sharing class DmlExecutorWithoutSharing extends DmlExecutor {
        protected override void executeDml(DmlOperations operationType, List<SObject> recs) {
            super.executeDml(operationType, recs);
        }
    }

    public virtual class QueryExecutor {
        protected virtual List<SObject> query(String query) {
            return Database.query(query);
        }
    }

    public with sharing class QueryExecutorWithSharing extends QueryExecutor {
        protected override List<SObject> query(String query) {
            return super.query(query);
        }
    }

    public without sharing class QueryExecutorWithoutSharing extends QueryExecutor {
        protected override List<SObject> query(String query) {
            return super.query(query);
        }
    }

    public class ExceptionWrapper {
        protected String type;
        protected String subType;
        protected String message;
        protected String sObjectType;
        protected String fieldId;
        protected String fieldName;
        protected String fieldMessage;

        public ExceptionWrapper(BaseException ex) {
            this.type = ex.type;
            this.subType = ex.subType;
            this.message = ex.message;
            this.sObjectType = ex.sObjectType;
            this.fieldId = ex.fieldId;
            this.fieldName = ex.fieldName;
            this.fieldMessage = ex.fieldMessage;
        }

        public ExceptionWrapper(String message) {
            this.message = message;
        }
    }

    public abstract class BaseException extends Exception {
        protected transient String type;
        protected transient String subType;
        protected transient String label;
        protected transient String message;
        protected transient String sObjectType;
        protected transient String fieldId;
        protected transient String fieldName;
        protected transient String fieldMessage;

        protected virtual void init(List<String> labelParams) {
            init();
            if (labelParams.isEmpty()) {
                this.message = this.getLabel();
            } else {
                this.message = String.format(this.getLabel(), labelParams);
            }
            this.setMessage(this.message);
        }

        protected virtual void init() {}

        public String getLabel() {
            return this.label;
        }

        public String getType() {
            return this.type;
        }

        public String getSubType() {
            return this.subType;
        }
    }

    public class UnknownException extends BaseException {
        public UnknownException(Exception ex, Boolean isCustom) {
            this.type = ErrorTypes.Error.name();
            this.subType = 'Unknown';
            this.label = String.format('{0}\n{1}', new String[] {ex.getMessage(), ex.getStackTraceString()});
        }

        protected override void init() {}
    }

    public class DmlErrorException extends BaseException {
        public DmlErrorException(DmlException dmlEx, SObject rec, Integer rowIdx, Map<String, Field> fieldsMap) {
            System.StatusCode dmlType = dmlEx.getDmlType(rowIdx);
            String dmlMessage = dmlEx.getDmlMessage(rowIdx);
            Schema.sObjectField[] fieldTypes = dmlEx.getDmlFields(rowIdx);

            this.type = ErrorTypes.Error.name();
            this.subType = dmlType != null ? dmlType.name() : 'DML';
            this.label = dmlMessage;

            if (fieldTypes != null && !fieldTypes.isEmpty()) {
                Schema.sObjectField fldType = fieldTypes[0];
                Schema.DescribeFieldResult fldDescribe = fldType.getDescribe();
                this.fieldName = fldDescribe.getName();
                this.fieldMessage = this.label.replaceAll('^' + fldDescribe.getLabel() + ': (.+)', '$1');

                if (fieldsMap != null && fieldsMap.containsKey(this.fieldName)) {
                    Field fld = fieldsMap.get(this.fieldName);
                    this.label = this.label.replaceAll('^' + fldDescribe.getLabel() + ': (.+)', fld.label + ': $1');
                }
            }

            if (rec != null) {
                this.sObjectType = rec.getSObjectType().getDescribe().getName();
            }
        }

        protected override void init() {}
    }

    public class WrongFieldValueTypeException extends BaseException {
        public WrongFieldValueTypeException(Field fld) {
            this.type = ErrorTypes.Error.name();
            this.subType = 'WrongFieldValueType';
            this.fieldMessage = String.format('Invalid value: {0}', new String[] {fld.value});
            this.label = String.format('{0}: {1}', new String[] {fld.label, this.fieldMessage});
            this.fieldName = fld.describe != null ? fld.describe.name : fld.name;
            this.sObjectType = fld.describe != null ? fld.describe.sObjectType : null;
        }

        protected override void init() {}
    }

    public class MissingInputParamErrorException extends BaseException {
        protected override void init() {
            type = ErrorTypes.Error.name();
            subType = 'MissingInputParam';
            label = 'Input parameter {0} is mandatory.';
        }
    }

    public class WrongInputParamTypeErrorException extends BaseException {
        protected override void init() {
            type = ErrorTypes.Error.name();
            subType = 'WrongInputParamType';
            label = 'Input parameter {0} ({1}) should be {2} type.';
        }
    }

    public class AppContextNotDefinedErrorException extends BaseException {
        protected override void init() {
            type = ErrorTypes.Error.name();
            subType = 'AppContextNotDefined';
            label = 'Application Context for user {0} is not defined.';
        }
    }

    public class RecordPermissionErrorException extends BaseException {
        protected override void init() {
            type = ErrorTypes.Error.name();
            subType = 'RecordPermission';
            label = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
        }
    }

    public class DeletedRecordErrorException extends BaseException {
        protected override void init() {
            type = ErrorTypes.Error.name();
            subType = 'DeletedRecord';
            label = 'The data you were trying to access could not be found. It may be due to another user deleting the data or a system error. If you know the data is not deleted but cannot access it, please contact your administrator.';
        }
    }



    public class MissingConfigurationWarningException extends BaseException {
        protected override void init() {
            type = ErrorTypes.Warning.name();
            subType = 'MissingConfiguration';
            label = 'Missing Configuration for Context (Application/Brand/Role: {0}/{1}/{2}).';
        }
    }


}