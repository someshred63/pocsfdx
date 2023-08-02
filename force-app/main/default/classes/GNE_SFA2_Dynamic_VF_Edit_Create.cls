public with sharing abstract class GNE_SFA2_Dynamic_VF_Edit_Create {
    
    public final static String FIELD = 'Field';
    public final static String BLANK_SPACE = 'Blank Space';
    public final static String RELATED_LIST = 'Related List';
    
    public List<String> fieldSetList {get; set;}
    public sObject myObject {get; set;}
    public Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> fieldSetMap {get; set;}
    public Map<String, String> fieldSetHeadings {get; set;}
    public Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> relatedFieldSetMap {get; set;}
    public Map<String, GNE_SFA2_RL_Component_AttributesWrapper> relatedListAttributes {get; set;}
    public List<String> relatedFieldSetList {get; set;}
    public Boolean hasMultipleRecordTypes {get; set;}
    public List<SelectOption> recordTypes {get; set;}
    public String defaultRecordType {get; set;} 
    public String recordTypeName {get; set;}
    public String availabilityMode {get; set;}
    public boolean isClone {get;set;}
    public boolean isTranferable {get;set;}

    protected ApexPages.StandardController controller;
    public GNE_SFA2_Dynamic_VF_Edit_Create currentController{get; set;}    
    public Set<String>          fieldNames {get; private set;}
    public Map<String,String>   fieldTypes {get; private set;}
    public Map<String,String>   fieldStyleClasses {get; private set;}
    public Map<String,String>   referenceToMap  {get; private set;}
    public Map<String,String>   lookupAvailableRecordIds {get; private set;}
    public Map<String,String>   lookupWhereExpressions {get; private set;}
    public Map<String,String>   lookupColumns {get; private set;}
    
    protected Map<String,List<String>> recordTypeToFieldSetListMap;
    private static String defaultRecordTypeStatic;
    public String myObjectType {get;set;}    
    //private SFA2_User_Sales_Roster_gne__c selectedApplication;
    protected GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
    protected String retURL;
    protected SFA2_Configuration_Object_gne__c pageConfiguration;
    //private String preSetRecordType;
    protected Boolean isOnlyMasterRecordType = true;
    protected Set<String> additionalQueryFields = new Set<String>();
    
    // Help Text For Field
    protected Map<String,Schema.SObjectField> sObjectFieldMap {get;set;}
    public Map<String,Boolean> helpTextExistsMap {get;set;}
    public Map<String,String> helpTextValueMap {get;set;}
    
    protected String viewPage;
    
    public GNE_SFA2_Dynamic_VF_Edit_Create(ApexPages.StandardController controller, String viewPage){
        this.controller = controller;
        this.currentController = this;
        initController(controller);
        this.viewPage = viewPage;
    }
    
    protected virtual void initController(ApexPages.StandardController controller) {
            if(controller.getId() != null){
                availabilityMode  = 'Edit';
                UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), controller.getId());
                if (!userRecordAccess.HasEditAccess){
                    //myObject = controller.getRecord();
                    return;
                }
            }
        if(myObject==null) {
            myObject = controller.getRecord();
        }
        myObjectType = String.valueOf(myObject.getSObjectType());
        
        List<Schema.RecordTypeInfo> sobjectRecordTypes = Schema.getGlobalDescribe().get(String.valueOf(myObject.getSObjectType())).getDescribe().getRecordTypeInfos();
        System.debug('sobjectRecordTypes: '+sobjectRecordTypes);
        if(sobjectRecordTypes.size()>1){
            isOnlyMasterRecordType = false;
        }
        retURL = System.currentPageReference().getParameters().get('retURL');
        
        if(retURL!=null) {
            retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
        }
        
        /*List<SFA2_User_Sales_Roster_gne__c> brandRoleType = GNE_SFA2_Util.getBrandRoleAppType(UserInfo.getUserId());
        if (brandRoleType.size() > 0){
            selectedApplication = brandRoleType[0];
        }*/
        recordTypeToFieldSetListMap = new Map<String,List<String>>();
        
        availabilityMode = myObject.id != null ? 'Edit' : 'New';
        //EDIT
        if(myObject.id != null){
            if(sobjectRecordTypes.size() == 1 || myObject.get('RecordTypeId') == null){
                recordTypeName = '';
            }else{
                recordTypeName = [Select DeveloperName from RecordType where id = :(String)myObject.get('RecordTypeId')].DeveloperName;
            }
        //CREATE
        }else{
            recordTypes = getAvailableRecordTypes(userApplicationContext, myObjectType);
            hasMultipleRecordTypes = recordTypes.size() > 1;
            if(sobjectRecordTypes.size() == 1 || myObject.get('RecordTypeId')==null) {
                defaultRecordType = defaultRecordTypeStatic;
                recordTypeName = defaultRecordType !=null ? defaultRecordType : '';
            } else {
                Id recTypeId = (Id)myObject.get('RecordTypeId');
                recordTypeName = [SELECT DeveloperName FROM RecordType WHERE Id= :recTypeId limit 1].DeveloperName;
            }
        } 
        
        System.debug('***mode' +availabilityMode+'***has multipler'+ hasMultipleRecordTypes );
        

    }
    
    public virtual PageReference init(){
        //if (selectedApplication != null){
        if (userApplicationContext != null){            
            if (availabilityMode == 'Edit'){
                UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), this.controller.getId());
                if(myObjectType!=null && !GNE_SFA2_Application_Cache.describeObject(myObjectType).isUpdateable()) {
                    return Page.GNE_SFA2_Access_Denied;
                } else if (!userRecordAccess.HasEditAccess){
                    return Page.GNE_SFA2_Access_Denied;
                    /*return GNE_SFA2_Util.redirectToErrorPage('You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', Apexpages.currentPage().getUrl(), 
                        'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary');*/                                   
                }
                isTranferable = userRecordAccess.HasTransferAccess;
            } else if(availabilityMode == 'New') {
                if(!GNE_SFA2_Application_Cache.describeObject(myObjectType).isCreateable()) {
                    return Page.GNE_SFA2_Access_Denied;
                }
            }
            pageConfiguration = GNE_SFA2_Util.getListPageConfiguration(myObjectType);
             
            fieldNames = new Set<String>();
            fieldSetMap = new Map<String, List<SFA2_Configuration_Object_Detail_gne__c>>();
            fieldSetList = new List<String>();
            fieldSetHeadings = new Map<String, String>();
            relatedFieldSetMap = new Map<String, List<SFA2_Configuration_Object_Detail_gne__c>>();
            relatedFieldSetList = new List<String>();
            relatedListAttributes  = new Map<String, GNE_SFA2_RL_Component_AttributesWrapper>();
            sObjectFieldMap = prepareObjectTypeFieldsMap(myObjectType);
            helpTextExistsMap = new Map<String,Boolean>();
            helpTextValueMap = new Map<String,String>();
            List<GNE_SFA2_RL_Component_AttributesWrapper>componentsForSecondPass = new List<GNE_SFA2_RL_Component_AttributesWrapper>(); 
                       
            List<SFA2_Configuration_Object_gne__c> layouts = getUIConfigurationObjects(userApplicationContext, myObjectType, recordTypeName, availabilityMode);
            System.debug('JL layouts: '+layouts);
            if(layouts.size() == 0){
                PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
                pageref.setredirect(true);
                pageref.getParameters().put('exMessage', 'Layout configuration records not found.');
                pageref.getParameters().put('exUrl', Apexpages.currentPage().getUrl());
                return pageref;
            }
            
            
            if(myObject.id != null){
                String theQuery = '';
                if(isOnlyMasterRecordType){
                    theQuery += 'SELECT ';
                }else{
                    theQuery += 'SELECT toLabel(RecordType.Name), ';
                }
                
                if(myObjectType == 'Account') {
                    theQuery += 'isPersonAccount, ';
                }
                
                if(!additionalQueryFields.isEmpty()) {
                    theQuery += String.join(new List<String>(additionalQueryFields),', ') + ', ';
                }
                  
                boolean isFieldsAvail=false;
                String canadaAccountType = String.isNotBlank(System.currentPageReference().getParameters().get('canadaAccountType')) ? System.currentPageReference().getParameters().get('canadaAccountType') : '';
                Boolean canadaStewardedAccount = canadaAccountType == 'Physician' ? true : canadaAccountType == 'Pharmacist' ? true : canadaAccountType == 'Nurse' ? true : false;
                for(SFA2_Configuration_Object_gne__c layout : layouts){
                    fieldSetHeadings.put(layout.id, layout.Section_Header_gne__c);
                    for (SFA2_Configuration_Object_Detail_gne__c layoutDetails : layout.Configuration_Objects__r){
                        if(layoutDetails.Type_gne__c == FIELD || layoutDetails.Type_gne__c == BLANK_SPACE){
                            if(!fieldSetMap.containsKey(layout.id)){
                                fieldSetMap.put(layout.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                                fieldSetList.add(layout.id);
                            }
                            if(canadaStewardedAccount) {
                                AccountCanadaHelper accountCanadaHelper = new AccountCanadaHelper(layoutDetails, userApplicationContext);
                                layoutDetails = accountCanadaHelper.fieldConfig;
                            }
                            fieldSetMap.get(layout.id).add(layoutDetails);
                            prepareHelpTextExistsMap(sObjectFieldMap, layoutDetails.API_Name_gne__c, layoutDetails.id);
                            
                            if(layoutDetails.Type_gne__c == FIELD && !layoutDetails.API_Name_gne__c.equalsIgnoreCase('RecordType.Name')){
                                theQuery += layoutDetails.API_Name_gne__c+ ', ';
                                fieldNames.add(layoutDetails.API_Name_gne__c.toUpperCase());
                            } 
                            isFieldsAvail=true;            
                        }

                        if(layoutDetails.Type_gne__c == RELATED_LIST){
                            System.debug('layoutDetails: ' + layoutDetails );
                            if(!relatedFieldSetMap.containsKey(layout.id)){
                                relatedFieldSetList.add(layout.id);
                                relatedFieldSetMap.put(layout.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                            }
                            relatedFieldSetMap.get(layout.id).add(layoutDetails);
                            GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(layoutDetails.Attributes_gne__c);
                            relatedListAttributes.put(layoutDetails.API_Name_gne__c, attributesWrapper);
                            if(attributesWrapper.shouldUpdateURL()){                                
                                componentsForSecondPass.add(attributesWrapper);    
                            }
                        }

                        
                    }
                }
                
                for(GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper: componentsForSecondPass){
                    for(String key : attributesWrapper.urlParametersMap.keySet()){
                        if(!theQuery.contains(attributesWrapper.urlParametersMap.get(key)+', ')){
                            theQuery +=  attributesWrapper.urlParametersMap.get(key) +', ';
                        }
                    }
                }

                if(isFieldsAvail==true){
                    theQuery = theQuery.subString(0, theQuery.length() - 2);
                }else{
                    theQuery +='Id';
                }
                theQuery += ' FROM '+myObjectType+' WHERE id = \''+myObject.Id+'\'';
                
                System.debug('theQuery: '+theQuery);
            
                try{
                    myObject = Database.query(theQuery);
                } catch (System.QueryException e){
                    system.debug(e);
                    return GNE_SFA2_Util.redirectToErrorPage('Record not found or Id parameter missing.',
                        Apexpages.currentPage().getUrl(), e.getMessage());
                }
            }else{
                 for(SFA2_Configuration_Object_gne__c layout : layouts){
                    fieldSetHeadings.put(layout.id, layout.Section_Header_gne__c);
                    for (SFA2_Configuration_Object_Detail_gne__c layoutDetails : layout.Configuration_Objects__r){
                        if(layoutDetails.Type_gne__c == FIELD || layoutDetails.Type_gne__c == BLANK_SPACE){
                            if(!fieldSetMap.containsKey(layout.id)){
                                fieldSetMap.put(layout.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                                fieldSetList.add(layout.id);
                            }
                            fieldSetMap.get(layout.id).add(layoutDetails);
                            prepareHelpTextExistsMap(sObjectFieldMap, layoutDetails.API_Name_gne__c, layoutDetails.id);
                            
                            if(layoutDetails.Type_gne__c == FIELD) {
                                fieldNames.add(layoutDetails.API_Name_gne__c.ToUpperCase());
                            }
                           
                        }
                        else if(layoutDetails.Type_gne__c == RELATED_LIST){
                                System.debug('layoutDetails: ' + layoutDetails );
                                if(!relatedFieldSetMap.containsKey(layout.id)){
                                    relatedFieldSetList.add(layout.id);
                                    relatedFieldSetMap.put(layout.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                                }
                                relatedFieldSetMap.get(layout.id).add(layoutDetails);
                                GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(layoutDetails.Attributes_gne__c);
                                relatedListAttributes.put(layoutDetails.API_Name_gne__c, attributesWrapper);
                        }
                    }
                }
                recordTypeToFieldSetListMap.put(recordTypeName, fieldSetList);
            }
        }else{
            return GNE_SFA2_Util.redirectToErrorPage('Roster configuration not found.',
                Apexpages.currentPage().getUrl(), null);
        }
        System.debug('JL returning null - all fine');
        populateLookupInfos();
        
        return null;
    }
    
    protected virtual void populateLookupInfos() {
        prepareFieldTypesInfos();
        // Fill lookupAvailableRecordIds and lookupWhereExpressions in sub-classes (if needed). 
    }
    
    protected virtual void prepareFieldTypesInfos() {
        Map<String, Schema.SObjectField> fieldMap = sObjectFieldMap;
        fieldTypes = new Map<String,String>();
        fieldStyleClasses = new Map<String,String>();
        referenceToMap = new Map<String,String>();
        lookupAvailableRecordIds = new Map<String,String>(); 
        lookupWhereExpressions = new Map<String,String>();
        lookupColumns = new Map<String,String>();
        
        for(String fieldName : fieldMap.keySet()) {
            String uFieldName = fieldName.toUpperCase();
            if(!fieldNames.contains(uFieldName)) {
                continue;
            }
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
            String fieldType = fieldDesc.getType().name();
            
            fieldTypes.put(fieldName.toUpperCase(),fieldType);
            fieldStyleClasses.put(uFieldName, fieldName + '_field');
            
            if(fieldType=='DATE') {
                fieldStyleClasses.put(uFieldName, fieldStyleClasses.get(uFieldName) + ' customDatePicker');
            } else if(fieldType=='REFERENCE') {
                for(Schema.SobjectType refObjType : fieldDesc.getReferenceTo()) {
                    referenceToMap.put(uFieldName,refObjType.getDescribe().getName());
                    break;
                }
                lookupAvailableRecordIds.put(uFieldName,'');
                lookupWhereExpressions.put(uFieldName,'');
                lookupColumns.put(uFieldName,'Name[searchBy=true;display=true]');
            }
        }
    }
    
    public virtual PageReference onRecordTypeChange() {
        if(recordTypeToFieldSetListMap.containsKey(recordTypeName)) {
            fieldSetList = recordTypeToFieldSetListMap.get(recordTypeName);
            return null;
        }
        
        fieldSetList = new List<String>();
        System.debug('record type name on change: '+recordTypeName);
        
        List<SFA2_Configuration_Object_gne__c> layouts = getUIConfigurationObjects(userApplicationContext, myObjectType, recordTypeName, availabilityMode);
        
        for(SFA2_Configuration_Object_gne__c layout : layouts){
            fieldSetHeadings.put(layout.id, layout.Section_Header_gne__c);
            for (SFA2_Configuration_Object_Detail_gne__c layoutDetails : layout.Configuration_Objects__r){
                if(layoutDetails.Type_gne__c == FIELD || layoutDetails.Type_gne__c == BLANK_SPACE){
                    if(!fieldSetMap.containsKey(layout.id)){
                        fieldSetMap.put(layout.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                        fieldSetList.add(layout.id);
                    }
                    
                    fieldSetMap.get(layout.id).add(layoutDetails);  
                    prepareHelpTextExistsMap(sObjectFieldMap, layoutDetails.API_Name_gne__c, layoutDetails.id);
                }
            }
        }
        
        recordTypeToFieldSetListMap.put(recordTypeName, fieldSetList);
        
        return null;
    }
    
    public virtual String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
    
    public static List<SFA2_Configuration_Object_gne__c> getUIConfigurationObjects(GNE_SFA2_User_App_Context_gne__c userApplicationContext, String objectApiName, String recordTypeName, String availabilityMode){
          return [SELECT Id, Name, Role_gne__c, External_ID_gne__c, Object_Name_gne__c, Section_Header_gne__c,
                        Record_Type_gne__c, Brand_gne__c, Is_Active_gne__c, Order_gne__c, Style_gne__c, 
                        (SELECT Name, API_Name_gne__c, Label_gne__c, Help_Text_gne__c, Attributes_gne__c, Is_Read_Only_gne__c, 
                                Is_Required_gne__c, Order_gne__c, Style_gne__c, Type_gne__c 
                                FROM Configuration_Objects__r 
                                WHERE Is_Active_gne__c = true
                                    AND Availability_Mode_gne__c INCLUDES (:availabilityMode)
                                ORDER BY Order_gne__c, API_Name_gne__c
                                )
                    FROM SFA2_Configuration_Object_gne__c
                    WHERE Object_Name_gne__c = :objectApiName 
                        AND Role_gne__c = :userApplicationContext.Role_gne__c
                        AND Brand_gne__c = :userApplicationContext.Brand_gne__c
                        AND Record_Type_gne__c = :recordTypeName
                        AND Application_Type__c = :userApplicationContext.App_Name_gne__c                        
                        AND Is_Active_gne__c = true 
                        AND Configuration_Type_gne__c='Page' 
                        ORDER BY Order_gne__c, Section_Header_gne__c];
    }
    
    public static List<SelectOption> getAvailableRecordTypes(GNE_SFA2_User_App_Context_gne__c userApplicationContext, String objectApiName){
        List<SelectOption> rTypes = new List<SelectOption>();
        Set<String> visitedRecordTypes = new Set<String>();
        Set<String> availableRecordTypesDeveloperNames = new Set<String>();
        List<RecordType> availableRecordTypesWithLabels = new List<RecordType>();
        Map<String, String> recordTypeNamesToLabelsMap = new Map<String, String>();
        List<AggregateResult> rtConfs = [SELECT Record_Type_gne__c, Is_Default_Record_Type_gne__c
                                      FROM SFA2_Configuration_Object_gne__c
                                      WHERE Object_Name_gne__c = :objectApiName 
                                        AND Role_gne__c = :userApplicationContext.Role_gne__c
                                        AND Brand_gne__c = :userApplicationContext.Brand_gne__c
                                        AND Application_Type__c = :userApplicationContext.App_Name_gne__c  
                                        AND RT_Available_On_Create_gne__c = true
                                      GROUP BY Record_Type_gne__c, Is_Default_Record_Type_gne__c
                                      ORDER BY Record_Type_gne__c asc];
                                      
        for(AggregateResult rtConf : rtConfs){
            availableRecordTypesDeveloperNames.add((String)rtConf.get('Record_Type_gne__c'));
        }
        
        availableRecordTypesWithLabels = [select Name, DeveloperName from RecordType where DeveloperName in :availableRecordTypesDeveloperNames and SobjectType = :objectApiName];
        for(RecordType recordType : availableRecordTypesWithLabels){
            recordTypeNamesToLabelsMap.put(recordType.DeveloperName, recordType.Name);
        }
       
        for(AggregateResult rtConf : rtConfs) {
            
            String developerName = (String)rtConf.get('Record_Type_gne__c');
            
            System.debug('rtconf: '+rtconf);
            
            if(visitedRecordTypes.contains(developerName)) continue;
            
            visitedRecordTypes.add(developerName);
            String label = developerName != null ? recordTypeNamesToLabelsMap.get(developerName) : 'Master Record Type';
            developerName = developerName != null ? developerName : '';
            rTypes.add(new SelectOption(developerName,label));
            
            if((Boolean)rtConf.get('Is_Default_Record_Type_gne__c')) {
                defaultRecordTypeStatic = developerName;
            }
        }
        System.debug('****'+rTypes);
        
        return rTypes;
    }
    
    // Help Text For Field - Michal H. - 03/01/2013
    public virtual Map<String,Schema.SObjectField> prepareObjectTypeFieldsMap (String objectType) {
        Map<String,Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = globalDescribeMap.get(objectType);  
        Schema.DescribeSObjectResult result = sObjectType.getDescribe();
        Map<String,Schema.SObjectField> sObjectFieldMap = result.fields.getMap();
        
        return sObjectFieldMap;
    }
    
    public virtual void prepareHelpTextExistsMap(Map<String,Schema.SObjectField> sObjectFieldMap, String viewField, String layoutDetailsId) {   
        try {
            Schema.SObjectField sObjectField = sObjectFieldMap.get(viewField);
            String helpText = sObjectField.getDescribe().getInlineHelpText();
            if(helpText != null) {
                helpTextExistsMap.put(layoutDetailsId, true);
                helpTextValueMap.put(layoutDetailsId, helpText);    
            } else {
                helpTextExistsMap.put(layoutDetailsId, false);  
            }
        } catch (Exception ex) { 
            
        }
    }
    
    public virtual PageReference save() {
        isClone = false;
        if( System.currentPageReference().getParameters().get('isClone')!=null && System.currentPageReference().getParameters().get('isClone')=='true'){
                myObject=myObject.clone();
                isClone=true;
            }
        if(myObject.id == null && !isClone){
            if(recordTypeName != null && recordTypeName != ''){
                System.debug('recordTypeName: '+recordTypeName);
                System.debug('myObjectType: '+myObjectType);
                RecordType recordType = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName AND SobjectType = :myObjectType limit 1][0];
                myObject.put('recordTypeId', recordType.Id);
            }
        }
        pagereference pageref; 
        try{
            upsert myObject;
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), myObject.Id);                
            if (!userRecordAccess.HasReadAccess){
                    return Page.GNE_SFA2_Access_Denied;
            }            
            String viewURL = viewPage.contains('?') ?  viewPage + '&id='+myObject.Id : viewPage + '?id='+myObject.Id;
            if (retURL!=null){
                viewURL = viewURL + '&retURL='+retURL;
            }
            if(GNE_SFA2_Util.isCCCrmUser() ) {
                viewURL = '/'+myObject.Id;
                if(retURL != null) {
                    viewURL = retURL;
                }
            }
            pageref = new pagereference(viewURL);
        }catch(Exception e){
            system.debug(e);
            //return GNE_SFA2_Util.redirectToErrorPage('Update / Insert failed', 
                //Apexpages.currentPage().getUrl(), e.getMessage()); // SFDC-2480:  In case of a validation rule error user is navigated to error page which is not correct. The error message should be displayed on the page upon save allowing user to correct.
            if(e.getMessage().contains('DUPLICATE_VALUE')){  
                String strId=e.getMessage().substring(e.getMessage().indexof('id:'),e.getMessage().length()-4);  
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'Invalid Data: Duplicate Value On Record '+strId));
                return null;
            }else if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){    
                //Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
                Apexpages.addMessages(e);
                return null;
            }else if(e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')){    
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'Value does not exist or does not match filter criteria.'));
                return null;
            }else if(e.getMessage().contains('TRANSFER_REQUIRES_READ')){    
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'User you selected can not be owner of the record. New owner must have object read permission.'));
                return null;
            }else if(e.getMessage().contains('CIRCULAR_DEPENDENCY')){    
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,''));
                return null;
            }else if(e.getMessage().contains('INVALID_CROSS_REFERENCE_KEY')){    
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,''));
                return null;
            }else if(e.getMessage().contains('INSUFFICIENT')){    
                 return GNE_SFA2_Util.redirectToErrorPage('You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', Apexpages.currentPage().getUrl(), e.getMessage());           
            }else if(e.getMessage().contains('ENTITY_IS_LOCKED')){    
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'You cannot update the record, because it\'s locked for editing.'));
                return null;           
            }else{
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            }
            return null;
        }
        
        if(myObjectType.equals('Task')){
        //Removed additional condition && retURL.contains('id')
            if(retURL!=null)  {
            pageref = new pagereference(retURL);
            }
            else{
            pageref = new pagereference('/apex/GNE_SFA2_MyTasks');
             }
        }
        pageref.setredirect(true);
        return pageref;
    }
    
    public virtual PageReference cancel() {
        String viewURL = '';
        if(retURL != null && !retURL.equalsIgnoreCase('')){
            viewURL = retURL;
        }else if(myObject.Id != null){
            viewURL = viewPage + '?id='+myObject.Id;
        }

        Pagereference pageref = new pagereference(viewURL);
        pageref.setredirect(true);
        return pageref;
    }

    public class AccountCanadaHelper {
        
        public SFA2_Configuration_Object_Detail_gne__c fieldConfig { get; private set; }
        public GNE_SFA2_User_App_Context_gne__c userAppContext { get; private set; }

        public AccountCanadaHelper(SFA2_Configuration_Object_Detail_gne__c config, GNE_SFA2_User_App_Context_gne__c userAppContext) {
            this.fieldConfig = config;
            this.userAppContext = userAppContext;
            this.changeFieldConfiguration();
        }
        private void changeFieldConfiguration() {
            if(this.fieldConfig.API_Name_gne__c == 'FirstName') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'LastName') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Account_Type_gne__c') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Account_Type_RAMA_gne__c') {
                if(userAppContext.Role_gne__c == 'RAMA') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Middle_vod__c') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Specialties_can_gne__c') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Gender_vod__c') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Language_of_Preference_can_gne__c') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Active_US_License_gne__c') {
                if(userAppContext.Role_gne__c != 'OPS') {
                    this.fieldConfig.Is_Read_Only_gne__c = true;
                }
            } else if(this.fieldConfig.API_Name_gne__c == 'Roche_Id_can_gne__c') {
                this.fieldConfig.Is_Read_Only_gne__c = true;
            } else if(this.fieldConfig.API_Name_gne__c == 'Prim_IMS_Id_can__c') {
                this.fieldConfig.Is_Read_Only_gne__c = true;
            }
        }
    }
}