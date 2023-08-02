public virtual class GNE_MCCO_CRM_Base_Ctrl {
    public final static String BUTTON = 'Button';
    public final static String FIELD = 'Field';
    public final static String BLANK_SPACE = 'Blank Space';
    public final static String RELATED_LIST = 'Related List';
    public final static String LINK = 'Link';
    
    public final static String NEW_MODE = 'New';
    public final static String EDIT_MODE = 'Edit';
    public final static String VIEW_MODE = 'View';
    public final static String SF1_MODE = 'SF1';

    // App Context
    // START Deprecated
    protected transient String appType = 'MCCO';
    protected transient String brand = '';
    protected transient String role = 'AFRM';
    // END Deprecated
    
    public transient String constructorDataJSON;
    protected transient Map<String,String> params;
    protected transient SObject record;
    protected transient SObject recordAfterSave;
    protected transient DataWrapper dataWrapper;
    protected transient DataWrapper inputDataWrapper;
    protected transient UserWrapper currentUser;
    protected transient AppContext appContext;
    protected transient RecordType recordType;
    protected transient Id recordId;
    protected transient String sObjectType;
    protected transient String mode;
    protected transient Schema.DescribeSObjectResult sObjectDescribe;
    protected transient Map<String, Schema.DescribeFieldResult> sObjectFieldsDescribe;
    
    public enum ErrorTypes {Error, Warning, Info}
    public enum DmlOperations {INS, UPD, UPS, DEL}
    
    public GNE_MCCO_CRM_Base_Ctrl() {
        // Constructor mode
        if (ApexPages.currentPage() != null) {
            constructorDataJSON = JSON.serialize(getConstructorData());
        }
    }

    public String getConstructorDataJSON() {
        return constructorDataJSON;
    }

    protected virtual DataWrapper getConstructorData() {
        Map<String, String> params = ApexPages.currentPage().getParameters().clone();
        params.put('fields','CreatedDate,LastModifiedDate');
        return init(params);
        //return null;
    }
    
    protected virtual DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }

    public virtual DataWrapper init(Map<String, String> params) {
        dataWrapper = getDataWrapperInstance();
        
        try {
            dataWrapper = intInit(params);
        } catch(Exception ex) {
            handleException(ex);
        }
        
        dataWrapper.onActionFinish('Init');
        return dataWrapper;
    }
    
    protected virtual void handleException(Exception ex) {
        if(ex instanceof BaseException) {
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
    
    public virtual DataWrapper intInit(Map<String, String> params) {
        this.params = params.clone();
        this.mode = String.isNotBlank(params.get('id')) ? (String.isNotBlank(params.get('sfdc.override')) ? VIEW_MODE : EDIT_MODE) : NEW_MODE;
        this.currentUser = getCurrentUser();
        this.appContext = getAppContext();
        if(String.isNotBlank(params.get('sf1'))) {
            this.appContext.appName = this.appContext.appName + ' SF1';
        }
        return mode == NEW_MODE ?
            initNewMode() : mode == EDIT_MODE ?
            initEditMode() : initViewMode();
    }
    
    protected virtual DataWrapper initNewMode() {
        this.sObjectType = checkInputParam('sObjectType');
        this.recordType = getRecordType(true);
        return getDataWrapper(dataWrapper);
    }
    
    protected virtual DataWrapper initEditMode() {
        this.recordId = checkInputParam('id');
        this.sObjectType = String.valueOf(recordId.getSObjectType());
        this.recordType = getRecordType(false);
        return getDataWrapper(dataWrapper);
    }
    
    protected virtual DataWrapper initViewMode() {
        this.recordId = checkInputParam('id');
        this.sObjectType = String.valueOf(recordId.getSObjectType());
        this.recordType = getRecordType(false);
        return getDataWrapper(dataWrapper);
    }
    
    protected virtual String checkInputParam(String paramName) {
        String result = params.get(paramName);
        
        if(String.isBlank(result)) {
            throw createException(new MissingInputParamErrorException(), new Object[]{paramName});
        }
        
        if(paramName=='id') {
            try {
                Id.valueOf(result); 
            } catch(Exception e) {
                throw createException(new WrongInputParamTypeErrorException(), new Object[]{paramName, result,'Id'});
            }
        } else if(paramName=='sObjectType') {
            try {
                Boolean isValid = Type.forName(result).newInstance() instanceof SObject;
            } catch(Exception e) {
                throw createException(new WrongInputParamTypeErrorException(), new Object[]{paramName, result,'SObject'});  
            }
        }
        
        return result;
    }
    
    protected virtual UserWrapper getCurrentUser() {
        User result = null;
        
        if(params.containsKey('userAlias')) {
            for(User u : [SELECT Id, FirstName, LastName, ProfileId, TimeZoneSidKey FROM User WHERE Alias = :params.get('userAlias') LIMIT 1]) {
                result = u;
            }
        }
        
        if(result==null) {
            result = new User(Id = UserInfo.getUserId(), FirstName = UserInfo.getFirstName(), LastName = UserInfo.getLastName(), ProfileId = UserInfo.getProfileId(), TimeZoneSidKey = String.valueOf(UserInfo.getTimeZone()));
        }
        
        return new UserWrapper(result);
    }
    
    protected virtual String getCurrentUserProfileName() {
        if(currentUser.profileName==null) {
            currentUser.profileName = [ SELECT Name FROM Profile WHERE Id = :currentUser.profileId LIMIT 1].Name;
        }
        
        return currentUser.profileName;
    }
    
    protected virtual RecordType getRecordType(Boolean isNewMode) {
        RecordType result = null;
        Boolean hasRecordType = getSObjectFieldsDescribe().containsKey('recordtypeid');
        
        if(hasRecordType) {
            if(isNewMode) {
                String rtDeveloperName = null;
                
                for(SFA2_Configuration_Object_gne__c conf : [
                        SELECT Record_Type_gne__c
                        FROM SFA2_Configuration_Object_gne__c
                        WHERE Is_Default_Record_Type_gne__c = true AND Object_Name_gne__c = :sObjectType 
                            AND Role_gne__c = :appContext.role AND Brand_gne__c = :appContext.brand AND Application_Type__c = :appContext.appName 
                            AND Is_Active_gne__c = true AND Configuration_Type_gne__c = 'Page'
                        LIMIT 1]) {
                    rtDeveloperName = conf.Record_Type_gne__c;
                }
                
                if(String.isNotBlank(rtDeveloperName)) {
                    for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sOBjectType =: sObjectType AND DeveloperName =: rtDeveloperName LIMIT 1]) {
                        result = rt;
                    }
                }
            } else {
                for(SObject rec : Database.query('SELECT RecordType.Id, RecordType.Name, RecordType.DeveloperName FROM ' + sObjectType + ' WHERE Id =: recordId LIMIT 1')) {
                    result = (RecordType)rec.getSObject('RecordType');
                }
            }
        }
        
        return result;
    }
    
    protected virtual DataWrapper getDataWrapper(DataWrapper dataWrapper) {
        dataWrapper.appContext = appContext;
        dataWrapper.config = getConfiguration(recordType!=null ? recordType.DeveloperName : null);
        dataWrapper.recordDescribe = getRecordDescribe();
        return dataWrapper;
    }
    
    protected virtual AppContext getAppContext() {
        GNE_SFA2_User_App_Context_gne__c appContext = GNE_SFA2_User_App_Context_gne__c.getInstance(currentUser.id);
        
        if(appContext==null) {
            throw createException(new AppContextNotDefinedErrorException(), new Object[]{ currentUser.name});
        }
        return new AppContext(currentUser, appContext.App_Name_gne__c, appContext.Brand_gne__c, appContext.Role_gne__c);
    }
    

    protected virtual RecordDescribe getRecordDescribe() {
        sObjectDescribe = getSObjectDescribe();
        return new RecordDescribe(recordId, sObjectType, sObjectDescribe.getLabel(), recordType, getRecordAccess(currentUser.id));
    }

    protected virtual RecordAccess getRecordAccess(String userId) {
        RecordAccess result = null;
        
        if(String.isNotBlank(recordId)) {
            for(UserRecordAccess urAccess : [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId LIMIT 1]) {
                result = new RecordAccess(urAccess.HasReadAccess, urAccess.HasEditAccess, urAccess.HasDeleteAccess);
            }
            
            if(result==null) {
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
        if(!rAccess.readAccess) {
            throw createException(new RecordPermissionErrorException(), new Object[]{'Read', currentUser.name});
        } else if(mode!=VIEW_MODE && !rAccess.editAccess) {
            throw createException(new RecordPermissionErrorException(), new Object[]{mode==NEW_MODE ? 'Create' : 'Edit', currentUser.name});
        }
    }

    protected virtual Config getConfiguration(String recordTypeDeveloperName) {
        List<Button> buttons = new List<Button>();
        List<Section> sections = new List<Section>();
        List<RelatedList> relatedList = new List<RelatedList>();        
        
        List<SFA2_Configuration_Object_gne__c> configObjects = [
            SELECT Name, Section_Header_gne__c, Order_gne__c, Attributes_gne__c,
                (SELECT Name, API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Read_Only_gne__c, Is_Required_gne__c, Order_gne__c, Type_gne__c, Availability_Mode_gne__c 
                 FROM Configuration_Objects__r WHERE Is_Active_gne__c = true
                 ORDER BY Order_gne__c)
            FROM SFA2_Configuration_Object_gne__c
            WHERE Object_Name_gne__c = :sObjectType AND Role_gne__c = :appContext.role AND Brand_gne__c = :appContext.brand AND Application_Type__c = :appContext.appName
                AND Record_Type_gne__c = :recordTypeDeveloperName AND Is_Active_gne__c = true AND Configuration_Type_gne__c = 'Page'
            ORDER BY Order_gne__c];
        
        if(configObjects.isEmpty()) {
            dataWrapper.addWarning(createException(new MissingConfigurationWarningException(), 
                new Object[]{
                    String.isNotBlank(appContext.appName) ? appContext.appName : '-',
                    String.isNotBlank(appContext.brand) ? appContext.brand : '-',
                    String.isNotBlank(appContext.role) ? appContext.role : '-'
            }));
        }   
            
        record = getRecord(configObjects);
        for (SFA2_Configuration_Object_gne__c conf : configObjects) {
            readConfigObject(conf, buttons, sections, relatedList);
        }

        return new Config(mode, buttons, sections, relatedList);
    }
    
    protected virtual ConfigItem readConfigObject(SFA2_Configuration_Object_gne__c conf, List<Button> buttons, List<Section> sections, List<RelatedList> relatedList) {
        ConfigItem result = null;
        
        sObjectFieldsDescribe = getSObjectFieldsDescribe();
        
        if (!conf.Configuration_Objects__r.isEmpty()) {
            if (conf.Configuration_Objects__r.get(0).Type_gne__c == BUTTON) {
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                    buttons.add(new Button(confDetail));
                }
            } else if (conf.Configuration_Objects__r.get(0).Type_gne__c == FIELD || conf.Configuration_Objects__r.get(0).Type_gne__c == BLANK_SPACE || conf.Configuration_Objects__r.get(0).Type_gne__c == LINK) {
                List<Field> fields = new List<Field>();
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                    Schema.DescribeFieldResult fieldDescribe = confDetail.Type_gne__c == FIELD && String.isNotBlank(confDetail.API_Name_gne__c) ? sObjectFieldsDescribe.get(confDetail.API_Name_gne__c.toLowerCase()) : null;
                    fields.add(new Field(confDetail, getFieldValue(confDetail, fieldDescribe), getDisplayValue(confDetail, fieldDescribe), fieldDescribe, sObjectType));    
                }
                Section sec = new Section(conf, fields);
                sections.add(sec);
                result = sec;
            } else if (conf.Configuration_Objects__r.get(0).Type_gne__c == RELATED_LIST) {
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                    Map<String, String> attributes = parseKeyValue(confDetail.Attributes_gne__c);
                    RelatedList rl = new RelatedList(confDetail.Label_gne__c, confDetail.API_Name_gne__c, Integer.valueOf(confDetail.Order_gne__c), confDetail.Availability_Mode_gne__c, attributes.get('fieldsCSV').split(','), attributes.get('orderByFieldName'), attributes.get('sortDirection'), Boolean.valueOf(attributes.get('hideEditLink')), Boolean.valueOf(attributes.get('hideDeleteLink')), attributes.get('parentFieldName'));
                    relatedList.add(rl);
                    result = rl;
                }
            }
        } else {
            Section sec = new Section(conf, new List<Field>());
            sections.add(sec);
            result = sec;
        }
        
        return result;
    }
    
    protected virtual Object getFieldValue(SFA2_Configuration_Object_Detail_gne__c confDetail, Schema.DescribeFieldResult fieldDescribe) {
        return fieldDescribe!=null ? record.get(confDetail.API_Name_gne__c) : null;
    }
    
    protected virtual String getDisplayValue(SFA2_Configuration_Object_Detail_gne__c confDetail, Schema.DescribeFieldResult fieldDescribe) {
        SObject relObj = fieldDescribe!=null && String.isNotBlank(fieldDescribe.getRelationshipName()) ? record.getSObject(fieldDescribe.getRelationshipName()) : null;
        Object relObjName = relObj!=null ? relObj.get('Name') : null;
        return relObjName!=null ? String.valueOf(relObjName) : confDetail.Type_gne__c == LINK ? confDetail.Name : null;
    }

    protected virtual sObject getRecord(List<SFA2_Configuration_Object_gne__c> configObjects) {
        SObject result = null;
        
        if(String.isBlank(recordId)) {
            result = getSObjectDescribe().getSobjectType().newSObject();
        } else {
            Set<String> fieldNames = getQueryFields(configObjects);
            
            String query = String.format('SELECT {0} FROM {1} WHERE {2} LIMIT 1', new String[]{
                String.join(new List<String>(fieldNames), ','),
                sObjectType,
                getRecordQueryWhereExpression()
            });
            system.debug(query);
            query = query.replace('%2C',',');
            //result = Database.query(query);
            List<SObject> recs = Database.query(query);
            for(SObject rec : recs) {
                result = rec;
            }
        }
        
        return result;
    }
    
    protected virtual String getRecordQueryWhereExpression() {
        return 'Id =: recordId';
    }
    
    protected virtual Set<String> getQueryFields(List<SFA2_Configuration_Object_gne__c> configObjects) {
        Set<String> fieldNames = new Set<String>{'id','name'};

        if(sObjectType == 'Contact') {
            fieldNames.add('photo_gne__c');
            fieldNames.add('MailingState'.toLowerCase());
            fieldNames.add('MailingCity'.toLowerCase());
			fieldNames.add('MailingCountry'.toLowerCase());
			fieldNames.add('MailingPostalCode'.toLowerCase());
			fieldNames.add('MailingStreet'.toLowerCase());                               
        }

        if(params.get('fields') != null) {
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
        
        if (!conf.Configuration_Objects__r.isEmpty() && conf.Configuration_Objects__r.get(0).Type_gne__c == FIELD) {
            for (SFA2_Configuration_Object_Detail_gne__c confDetail : conf.Configuration_Objects__r) {
                if(confDetail.Type_gne__c == FIELD && String.isNotBlank(confDetail.API_Name_gne__c) && sObjectFieldsDescribe.containsKey(confDetail.API_Name_gne__c.toLowerCase())) {
                    String fieldName = confDetail.API_Name_gne__c.toLowerCase();
                    fieldNames.add(fieldName);
                    // Add related fields
                    if(String.isNotBlank(sObjectFieldsDescribe.get(fieldName).getRelationshipName())) {
                        fieldNames.add(sObjectFieldsDescribe.get(fieldName).getRelationshipName() + '.Name');
                    }
                }
            }
        }
        
        return fieldNames;
    }
    
    protected virtual DescribeSObjectResult getSObjectDescribe() {
        cacheSObjectDescribe();
        return sObjectDescribe;
    }
    
    protected virtual Map<String,Schema.DescribeFieldResult> getSObjectFieldsDescribe() {
        cacheSObjectDescribe();
        return sObjectFieldsDescribe;
    }
    
    protected virtual void cacheSObjectDescribe() {
        if(sObjectDescribe==null) {
            sObjectDescribe = Schema.getGlobalDescribe().get(sObjectType).getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
            sObjectFieldsDescribe = new Map<String,Schema.DescribeFieldResult>();
            for(String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                sObjectFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
        }
    }

    protected virtual Map<String, String> parseKeyValue(String data) {
        Map<String, String> result = new Map<String, String>();
        for (String d : data.split(';')) {
            result.put(d.split('=').get(0), d.split('=').get(1));
        }
        return result;
    }
    
    private static Set<String> getAttributeFlags(String attributes) {
        Set<String> result;
            
        if(String.isNotBlank(attributes)) {
            result = new Set<String>();
            Pattern flagPattern = Pattern.compile('(^|\\s|;|,)--([^\\s,;]+)');
            Matcher flagMatcher = flagPattern.matcher(attributes);
            
            while(flagMatcher.find()) {
                result.add(flagMatcher.group(2));
            }
        }
        
        return result;
    }
    
    public virtual DataWrapper saveRecord(String inputDataWrapperInJSON) {
        return saveRecord(inputDataWrapperInJSON, GNE_MCCO_CRM_Base_Ctrl.DataWrapper.class);
    }
    
    public virtual DataWrapper saveRecord(String inputDataWrapperInJSON, System.Type inputType) {
        return saveRecord((DataWrapper)JSON.deserialize(inputDataWrapperInJSON, inputType));
    }
    
    public virtual DataWrapper saveRecord(DataWrapper inputDataWrapper) {
        this.dataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;
        
        try {
            this.inputDataWrapper = inputDataWrapper;
            dataWrapper = intSaveRecord();
            isOk = true;
        } catch(Exception ex) {
            handleException(ex);
        } finally {
            if(!isOk) {
                Database.rollback(sp);
            }
        }
        
        dataWrapper.onActionFinish('SaveRecord');
        return dataWrapper; 
    }

	public virtual DataWrapper saveRecord(String inputDataWrapperInJSON, System.Type inputType, Map<String, String> extraFields) {
		return saveRecord((DataWrapper)JSON.deserialize(inputDataWrapperInJSON, inputType), extraFields);
	}
	
    public virtual DataWrapper saveRecord(DataWrapper inputDataWrapper, Map<String, String> extraFields) {
        this.dataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;
        
        try {
            this.inputDataWrapper = inputDataWrapper;
            dataWrapper = intSaveRecord(extraFields);
            isOk = true;
        } catch(Exception ex) {
            handleException(ex);
        } finally {
            if(!isOk) {
                Database.rollback(sp);
            }
        }
        
        dataWrapper.onActionFinish('SaveRecord');
        return dataWrapper;
    }
    
    protected virtual DataWrapper intSaveRecord() {
        sObjectType = inputDataWrapper.recordDescribe.sObjectType;
        record = (SObject)Type.forName(sObjectType).newInstance();
        System.debug('####### Record === ' + record);
        updateRecordFields();
        
        if(validateRecord()) {
            upsertRecord();
            recordId = record.Id;
            dataWrapper.recordDescribe = inputDataWrapper.recordDescribe;
            dataWrapper.recordDescribe.recordId = recordId;
            dataWrapper.config = inputDataWrapper.config;
            dataWrapper.config.mode = VIEW_MODE;
            dataWrapper.config.fieldsToRefresh = refreshFieldValues();
        }
        
        return dataWrapper;
    }

    protected virtual DataWrapper intSaveRecord(Map<String, String> extraFields) {
        sObjectType = inputDataWrapper.recordDescribe.sObjectType;
        record = (SObject)Type.forName(sObjectType).newInstance();
        System.debug('####### Record === ' + record);
        updateRecordFields(extraFields);
        
        if(validateRecord()) {
            upsertRecord();
            recordId = record.Id;
            dataWrapper.recordDescribe = inputDataWrapper.recordDescribe;
            dataWrapper.recordDescribe.recordId = recordId;
            dataWrapper.config = inputDataWrapper.config;
            dataWrapper.config.mode = VIEW_MODE;
            dataWrapper.config.fieldsToRefresh = refreshFieldValues();
        }
        
        return dataWrapper;
    }
    
    protected virtual void upsertRecord() {
        System.debug('####### Upsert Record === ' + record);
        executeDML(DmlOperations.UPS, record);
    }
    
    protected virtual void updateRecordFields() {
        if(String.isNotBlank(inputDataWrapper.recordDescribe.recordId)) {
            record.Id = inputDataWrapper.recordDescribe.recordId;
        }
        
        if(inputDataWrapper.recordDescribe.recordType!=null) {
            record.put('RecordTypeId', inputDataWrapper.recordDescribe.recordType.Id);
            record.putSObject('RecordType', inputDataWrapper.recordDescribe.recordType);
        }
        
        if(inputDataWrapper.appContext.currentUser.id != UserInfo.getUserId()) {
            Id userId = inputDataWrapper.appContext.currentUser.id;
            
            try {
                record.put('OwnerId', userId);
            } catch(System.SObjectException soe) {}
        }
        
        if(inputDataWrapper.inputFields!=null) {
            for(Field siField : inputDataWrapper.inputFields) {
                if(siField.hidden!=true) {
                    record.put(siField.name, siField.getValue());
                }
            }
        }
    }

    protected virtual void updateRecordFields(Map<String, String> extraFields) {
        if(String.isNotBlank(inputDataWrapper.recordDescribe.recordId)) {
            record.Id = inputDataWrapper.recordDescribe.recordId;
        }
        
        if(inputDataWrapper.recordDescribe.recordType!=null) {
            record.put('RecordTypeId', inputDataWrapper.recordDescribe.recordType.Id);
            record.putSObject('RecordType', inputDataWrapper.recordDescribe.recordType);
        }

        if(!extraFields.isEmpty()) {
            for(String k : extraFields.keySet()) {
                record.put(k, extraFields.get(k));
            }
        }
        
        if(inputDataWrapper.appContext.currentUser.id != UserInfo.getUserId()) {
            Id userId = inputDataWrapper.appContext.currentUser.id;
            
            try {
                record.put('OwnerId', userId);
            } catch(System.SObjectException soe) {}
        }
        
        if(inputDataWrapper.inputFields!=null) {
            for(Field siField : inputDataWrapper.inputFields) {
                if(siField.hidden!=true) {
                    record.put(siField.name, siField.getValue());
                }
            }
        }
    }
    
    protected virtual Boolean validateRecord() {
        return true;
    }
    
    protected virtual Map<String,Field> refreshFieldValues() {
        if(inputDataWrapper.config!=null && inputDataWrapper.config.fieldsToRefresh!=null) {
            Set<String> fieldNames = getQueryFieldsAfterSave();
            recordAfterSave = getRecordAfterSave(fieldNames);
            
            for(String fieldName : inputDataWrapper.config.fieldsToRefresh.keySet()) {
                Field fld = inputDataWrapper.config.fieldsToRefresh.get(fieldName);
                inputDataWrapper.config.fieldsToRefresh.get(fieldName).setValue(recordAfterSave.get(fieldName));
                
                if(fld.describe.type == 'reference' && recordAfterSave.getSObject(fld.describe.relationshipName)!=null) {
                    fld.displayValue = (String)recordAfterSave.getSObject(fld.describe.relationshipName).get('Name');
                }
            }
        }
        
        return inputDataWrapper.config.fieldsToRefresh;
    }
    
    // Ensure Id and Names are passed 
    protected virtual Set<String> getQueryFieldsAfterSave() {
        Set<String> fieldNames = new Set<String>{'id', 'name'};

        for(String fieldName : inputDataWrapper.config.fieldsToRefresh.keySet()) {
            Field fld = inputDataWrapper.config.fieldsToRefresh.get(fieldName);
            
            if(!fieldName.contains('::')) {
                fieldNames.add(fieldName.toLowerCase());
                
                if(fld.describe.type == 'reference') {
                    fieldNames.add((fld.describe.relationshipName + '.name').toLowerCase());
                }
            }
        }
        
        return fieldNames;
    }
    
    protected virtual SObject getRecordAfterSave(Set<String> fieldNames) {
        return Database.query(String.format('SELECT {0} FROM {1} WHERE Id = :recordId', new String[]{
            String.join(new List<String>(fieldNames),','),
            sObjectType
        }));
    }
    
    public virtual DataWrapper deleteRecord(String inputDataWrapperInJSON) {
        return deleteRecord(inputDataWrapperInJSON, GNE_MCCO_CRM_Base_Ctrl.DataWrapper.class);
    }
    
    public virtual DataWrapper deleteRecord(String inputDataWrapperInJSON, System.Type inputType) {
        this.dataWrapper = getDataWrapperInstance();
        System.Savepoint sp = Database.setSavepoint();
        Boolean isOk = false;
        
        try {
            this.inputDataWrapper = (DataWrapper)JSON.deserialize(inputDataWrapperInJSON, inputType);
            dataWrapper = intDeleteRecord();
            isOk = true;
        } catch(Exception ex) {
            handleException(ex);
        } finally {
            if(!isOk) {
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
        executeDml(operationType, new List<SObject>{rec});
    }
    
    protected virtual void executeDml(DmlOperations operationType, List<SObject> recs) {
        try {
            if(recs!=null && !recs.isEmpty()) {
                if(operationType == DmlOperations.INS) {
                    insert recs;
                } else if(operationType == DmlOperations.UPD) {
                    update recs;
                } else if(operationType == DmlOperations.UPS) {
                    if(recs.size()==1 && recs.getSObjectType()==null) {
                        upsert recs[0];
                    } else {
                        upsert recs;
                    }
                } else if(operationType == DmlOperations.DEL) {
                    delete recs;
                }
            }
        } catch(DMLException dmlEx) {
            BaseException lastException;
            Map<String,Field> fieldsMap = inputDataWrapper!=null && inputDataWrapper.config!=null ? inputDataWrapper.config.fieldsToRefresh : null;
            
            for(Integer i=0; i<dmlEx.getNumDml();i++) {
                SObject rec = recs[dmlEx.getDmlIndex(i)];
                lastException = createException(new DmlErrorException(dmlEx, rec, i, fieldsMap));
                
                if(i<dmlEx.getNumDml()-1) {
                    dataWrapper.addError(lastException);
                }
            }
            
            throw lastException;            
        }
    }
    
    public static Object convertFieldValue(String value, String type) {
        Object result = String.isNotBlank(value) ? value : (type=='boolean' ? 'false' : null);
            
        if(result!=null) {
            if(type=='date' || type=='datetime' || type=='time') {
                result = DateTime.newInstance(Long.valueOf((String)result));
                
                if(type=='date') {
                    result = ((DateTime)result).date();
                } else if(type=='time') {
                    result = ((DateTime)result).time();
                }
            } else if(type=='double') {
                result = Double.valueOf(result);
            } else if(type=='integer') {
                result = Integer.valueOf(result);
            } else if(type=='boolean') {
                result = Boolean.valueOf(result);
            }
        }
        
        return result;
    }
    
    public static BaseException staticCreateException(BaseException ex) {
        return staticCreateException(ex,null);
    }
    
    public static BaseException staticCreateException(BaseException ex, List<Object> a_labelParams) {
        List<String> labelParams = new List<String>();
        
        if(a_labelParams!=null) {
            for(Object param : a_labelParams) {
                labelParams.add(param!=null ? String.valueOf(param) : '');
            }
        }
        
        ex.init(labelParams);
        return ex;
    }

    public virtual class DataWrapper {
        public AppContext appContext;
        public RecordDescribe recordDescribe;
        public Config config;
        public List<ExceptionWrapper> errors;
        public List<ExceptionWrapper> warnings;
        public List<ExceptionWrapper> infos;
        public String retUrl;
        public Boolean success;
        public List<String> debugInfos;
        public Boolean isDebugMode;
        public transient DateTime startTimeStamp;
        public List<Field> inputFields;

        public DataWrapper() {
            this.success = true;
            this.startTimeStamp = System.now();
        }
        
        public virtual void onActionFinish(String actionName) {
            Long execTimeMilis = this.startTimeStamp!= null ? (System.now().getTime()  - this.startTimeStamp.getTime()) : null;
            
            if(debugInfos==null) {
                debugInfos = new List<String>();
            }
            
            debugInfos.add(String.format(
                'Action: {0}\nExec Time : {1} ms | CPU Time:  {2}/{3} ms\n' + 
                'Query Statements:  {4}/{5} | Query Rows:  {6}/{7}\n' +
                'DML Statements:  {8}/{9} | DML Rows:  {10}/{11}\n'/* + 'Script Statements : {12}/{13}'*/, new String[]{
                    actionName, execTimeMilis.format(),
                    Limits.getCpuTime().format(), Limits.getLimitCpuTime().format(),
                    Limits.getQueries().format(), Limits.getLimitQueries().format(),
                    Limits.getQueryRows().format(), Limits.getLimitQueryRows().format(),
                    Limits.getDmlStatements().format(), Limits.getLimitDmlStatements().format(),
                    Limits.getDmlRows().format(), Limits.getLimitDmlRows().format()
                    //Limits.getScriptStatements().format(), Limits.getLimitScriptStatements().format()
            }));
        }
        
        public void addError(BaseException ex) {
            if(errors==null) {
                errors = new List<ExceptionWrapper>();
            }
            
            errors.add(new ExceptionWrapper(ex));
            this.success = false;
        }
        
        public void addWarning(BaseException ex) {
            if(warnings==null) {
                warnings = new List<ExceptionWrapper>();
            }
            
            warnings.add(new ExceptionWrapper(ex));
        }
        
        public void addInfo(BaseException ex) {
            if(infos==null) {
                infos = new List<ExceptionWrapper>();
            }
            
            infos.add(new ExceptionWrapper(ex));
        }
    }

    public class AppContext {
        public String appName;
        public String brand;
        public String role;
        public UserWrapper currentUser;

        public AppContext(UserWrapper currentUser, String appName, String brand, String role) {
            this.appName = appName;
            this.brand = brand;
            this.role = role;
            this.currentUser = currentUser;
        }
    }
    
    public class UserWrapper {
        public Id id;
        public String name;
        public Id profileId;
        public String profileName;
        public String timeZone;
        public Boolean isCanada;

        public UserWrapper(User user) {
            this.id = user.Id;
            this.name = user.FirstName + ' ' + user.LastName;
            this.profileId = user.ProfileId;
            this.timeZone = user.TimeZoneSidKey;
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

        public Boolean isCanada() {
            if(isCanada==null) {
                isCanada = GNE_SFA2_Util.isCanadaUser(getProfileName());
            }

            return isCanada;
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
        public String sObjectType;
        public String sObjectLabel;
        public RecordType recordType;
        public RecordAccess recordAccess;

        public RecordDescribe(Id recordId, String sObjectType, String sObjectLabel, RecordType recordType, RecordAccess recordAccess) {
            this.recordId = recordId;
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
        public Map<String,Field> fieldsToRefresh;

        public Config(String mode, List<Button> buttons, List<Section> sections, List<RelatedList> relatedlists) {
            this.mode = mode;
            this.buttons = buttons;
            this.sections = sections;
            this.relatedlists = relatedlists;
        }
    }

    public class Button extends ConfigItem {
        public Integer order;
        
        public Button(SFA2_Configuration_Object_Detail_gne__c confDetail) {
            this(confDetail.Label_gne__c, Integer.valueOf(confDetail.Order_gne__c), confDetail.Attributes_gne__c);
        }
        
        public Button(String label, Integer order, String attributes) {
            super(null,label,attributes);
            this.order = order;
        }
    }

    public class Section extends ConfigItem {
        public Integer order;
        public List<Field> fields;

        public Section(SFA2_Configuration_Object_gne__c conf, List<Field> fields) {
            this(conf.Name, conf.Section_Header_gne__c, Integer.valueOf(conf.Order_gne__c), conf.Attributes_gne__c, fields);
        }
        
        public Section(String name, String label, Integer order, String attributes, List<Field> fields) {
            super(name, label, attributes);
            this.order = order;
            this.fields = fields;
        } 
    }

    public virtual class Field extends ConfigItem {
        public String value;
        public String displayValue;
        public Integer order;
        public List<String> mode {get;set;}
        public Boolean readOnly;
        public Boolean required;
        public Boolean hidden;
        public String helpText;
        public FieldDescribe describe;
        
        public Field() {}
        
        public Field(SFA2_Configuration_Object_Detail_gne__c confDetail, Object value, String displayValue, Schema.DescribeFieldResult describe, String sObjectType) {
            this(confDetail.API_Name_gne__c, confDetail.Label_gne__c, value, displayValue, Integer.valueOf(confDetail.Order_gne__c), String.isNotBlank(confDetail.Availability_Mode_gne__c) ? confDetail.Availability_Mode_gne__c.split(';') : null, confDetail.Is_Read_Only_gne__c, confDetail.Is_Required_gne__c, confDetail.Attributes_gne__c, describe!=null ? new FieldDescribe(describe, sObjectType) : null);
        }
        
        public Field(Field otherField) {
            this(otherField.name, otherField.label, otherField.value, otherField.displayValue, otherField.order, otherField.mode, otherField.readOnly, otherField.required, otherField.attributes, otherField.describe);
        }

        public Field(String label, Object value, Boolean readOnly, Boolean required, Schema.DescribeFieldResult describe, String sObjectType) {
            this(describe.getName(), label, value, null, null, null, readOnly, required, null, new FieldDescribe(describe, sObjectType));
        }
        
        public Field(String name, String label) {
            this(name, label, null, null, null, null, true, false, null, null);
        }

        public Field(String name, String label, Boolean isReadOnly, String sObjectType) {
            super(name, label, '');
            Map<String, Schema.DescribeFieldResult> sObjectFieldsDescr = getSObjectFieldsDescr(sObjectType);
            Schema.DescribeFieldResult fieldDescribe = String.isNotBlank(name) ? sObjectFieldsDescr.get(name.toLowerCase()) : null;
            this.readOnly = isReadOnly;
            this.required = false;
            this.describe = new FieldDescribe(fieldDescribe, sObjectType);
        }

        private Map<String,Schema.DescribeFieldResult> getSObjectFieldsDescr(String sObjectType) {
            Map<String,Schema.DescribeFieldResult> result = new Map<String,Schema.DescribeFieldResult>();
            Schema.DescribeSObjectResult sObjectDescr = Schema.getGlobalDescribe().get(sObjectType).getDescribe();
            Map<String, Schema.SObjectField> objectFields = sObjectDescr.fields.getMap();
            for(String fName : objectFields.keySet()) {
                Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
                result.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
            }
            return result;
        }
        
        // Deprecated
        public Field(String name, String label, List<String> mode) {
            this(name, label, null, null, null, mode, true, false, null, null);
        }
        
        public Field(String name, String label, Object value, String displayValue, Integer order, List<String> mode, Boolean readOnly, Boolean required, String attributes, FieldDescribe describe) {
            super(name, label, attributes);
            this.value = value!=null ? String.valueOf(value) : null;
            this.displayValue = displayValue;
            this.order = order;
            this.mode = mode!=null && !mode.isEmpty() ? mode : new List<String>{NEW_MODE,EDIT_MODE,VIEW_MODE};
            this.readOnly = readOnly;
            this.required = required;
            this.describe = describe;
            this.helpText = describe!=null ? describe.inlineHelpText : null;
        }
        
        public void setValue(Object value) {
            this.value = value!=null ? String.valueOf(value) : null;
        }
        
        public Object getValue() {
            Object result = null;
            
            try {
                result = convertFieldValue(value, describe!=null ? describe.type : 'string');
            } catch(System.TypeException ste) {
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
        public List<Schema.PicklistEntry> picklistValues;
        public Boolean dependentPicklist;
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

        public FieldDescribe(Schema.DescribeFieldResult schemaDescribe, String sObjectType) {
            this.name = schemaDescribe.getName();
            this.label = schemaDescribe.getLabel();
            this.type = schemaDescribe.getType().name().toLowerCase();
            this.sObjectType = sObjectType;
            this.inlineHelpText = schemaDescribe.getInlineHelpText();
            this.length = type=='integer' ? schemaDescribe.getDigits() : type=='double' ? schemaDescribe.getPrecision() : schemaDescribe.getLength();
            this.length = this.length==0 ? null : this.length;
            this.picklistValues = schemaDescribe.getPicklistValues();
            this.dependentPicklist = schemaDescribe.isDependentPicklist();
            this.restrictedPicklist = schemaDescribe.isRestrictedPicklist();
            this.referenceTo = new List<String>();
            for(SObjectType sobjType : schemaDescribe.getReferenceTo()) {
                this.referenceTo.add(String.valueOf(sobjType));
            }
            this.relationshipName = schemaDescribe.getRelationshipName();
            this.type = schemaDescribe.getType().name().toLowerCase();
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
        public Integer order;
        public String mode;
        public List<String> fields;
        public String sortBy;
        public String sortDirection;
        public Boolean hideEdit;
        public Boolean hideDelete;
        public String parentFieldName;

        public RelatedList(String name, String sObjectType, Integer order, String mode, List<String> fields, String sortBy, String sortDirection, Boolean hideEdit, Boolean hideDelete, String parentFieldName) {
            super(name, null, null);
            this.name = name;
            this.sObjectType = sObjectType;
            this.order = order;
            this.mode = mode;
            this.fields = fields;
            this.sortBy = sortBy;
            this.sortDirection = sortDirection;
            this.hideEdit = hideEdit;
            this.hideDelete = hideDelete;
            this.parentFieldName = parentFieldName;
        }

    }
    
    public abstract class ConfigItem {
        public String name;
        public String label;
        public String attributes;
        public Set<String> attributeFlags;
        
        public ConfigItem() {}
        
        public ConfigItem(String name, String label, String attributes) {
            this.name = name;
            this.label = label;
            this.attributes = attributes;
            this.attributeFlags = getAttributeFlags(attributes);
        }
    }
    
    public class ExceptionWrapper {
        protected String type;
        protected String subType;
        protected String message;
        protected String sObjectType;
        protected String fieldName;
        protected String fieldMessage;
        
        public ExceptionWrapper(BaseException ex) {
            this.type = ex.type;
            this.subType = ex.subType;
            this.message = ex.message;
            this.sObjectType = ex.sObjectType;
            this.fieldName = ex.fieldName;
            this.fieldMessage = ex.fieldMessage;
        }
    }
    
    public abstract class BaseException extends Exception {
        protected transient String type;
        protected transient String subType;
        protected transient String label;
        protected transient String message;
        protected transient String sObjectType;
        protected transient String fieldName;
        protected transient String fieldMessage;
        
        protected void init(List<String> labelParams) {
            init();
            if(labelParams.isEmpty()) {
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
            this.label = String.format('{0}\n{1}', new String[]{ex.getMessage(), ex.getStackTraceString()});
        }
        
        protected override void init() {}
    }
    
    public class DmlErrorException extends BaseException {
        public DmlErrorException(DmlException dmlEx, SObject rec, Integer rowIdx, Map<String,Field> fieldsMap) {
            System.StatusCode dmlType = dmlEx.getDmlType(rowIdx);
            String dmlMessage = dmlEx.getDmlMessage(rowIdx);
            Schema.sObjectField[] fieldTypes = dmlEx.getDmlFields(rowIdx);
            
            this.type = ErrorTypes.Error.name();
            this.subType = dmlType!=null ? dmlType.name() : 'DML';
            this.label = dmlMessage;
            
            if(fieldTypes!=null && !fieldTypes.isEmpty()) {
                Schema.sObjectField fldType = fieldTypes[0];
                Schema.DescribeFieldResult fldDescribe = fldType.getDescribe();
                this.fieldName = fldDescribe.getName();
                this.fieldMessage = this.label.replaceAll('^' + fldDescribe.getLabel() + ': (.+)','$1');
                
                if(fieldsMap!=null && fieldsMap.containsKey(this.fieldName)) {
                    Field fld = fieldsMap.get(this.fieldName);
                    this.label = this.label.replaceAll('^' + fldDescribe.getLabel() + ': (.+)', fld.label + ': $1');
                }
            }
            
            if(rec!=null) {
                this.sObjectType = rec.getSObjectType().getDescribe().getName();
            }
        }
        
        protected override void init() {}
    }
    
    public class WrongFieldValueTypeException extends BaseException {
        public WrongFieldValueTypeException(Field fld) {
            this.type = ErrorTypes.Error.name();
            this.subType = 'WrongFieldValueType';
            this.fieldMessage = String.format('Invalid value: {0}', new String[]{fld.value});
            this.label = String.format('{0}: {1}', new String[]{fld.label, this.fieldMessage});
            this.fieldName = fld.describe!=null ? fld.describe.name : fld.name;
            this.sObjectType = fld.describe!=null ? fld.describe.sObjectType : null;
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
    
    public class MissingConfigurationWarningException extends BaseException {
        protected override void init() {
            type = ErrorTypes.Warning.name();
            subType = 'MissingConfiguration';
            label = 'Missing Configuration for Context (Application/Brand/Role: {0}/{1}/{2}).'; 
        }
    }
    
    
}