public abstract with sharing class EMS_DynamicVFLoader {

    public final static String FIELD = 'Field';
    public final static String BLANK_SPACE = 'Blank Space';
    public final static String RELATED_LIST = 'Related List';
    public final static String VF_PAGE = 'VF Page';
    public final static String BUTTON = 'Button';

    public EMS_DynamicVFLoader currentController { get; set; }
    public List<String> fieldSetList { get; set; }
    public List<String> relatedFieldSetList { get; set; }
    public sObject myObject { get; set; }
    public Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> fieldSetMap { get; set; }
    public Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> relatedFieldSetMap { get; set; }
    public Map<String, GNE_SFA2_RL_Component_AttributesWrapper> relatedListAttributes { get; set; }
    public Map<String, Boolean> visualforceIncludesMap { get; set; }
    public Map<String, String> fieldSetHeadings { get; set; }
    public Boolean listRendered { get; set; }
    private SFA2_Configuration_Object_gne__c pageConfiguration;
    public String myObjectType { get; set; }
    public String recordTypeName { get; set; }
    private String viewPage;
    private String retURL;
    public String sObjectName;
    public Boolean recordIsEditable { get; set; }
    // User Link Override 
    public Map<String, String> fieldOfUserReferenceMap { get; set; }
    public Map<String, String> fieldOfGroupReferenceMap { get; set; }
    public Map<String, Boolean> userReferenceHasExist { get; set; }
    public Map<String, Boolean> groupReferenceHasExist { get; set; }
    public String pagePositiveMessage { get; set; }

    // Help Text For Field
    public Map<String, Boolean> helpTextExistsMap { get; set; }
    public Map<String, String> helpTextValueMap { get; set; }

    //temp
    public String userIdToViewLink { get; set; }

    public EMS_DynamicVFLoader(ApexPages.StandardController controller, String viewPage) {
        this(controller);
        this.viewPage = viewPage;
        currentController = this;

        UserRecordAccess recordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :((Id) myObject.get('id')) LIMIT 1];
        if (recordAccess != null) {
            recordIsEditable = recordAccess.HasEditAccess;
        } else {
            recordIsEditable = false;
        }

        if (System.currentPageReference().getParameters().containsKey('msg')) {
            pagePositiveMessage = System.currentPageReference().getParameters().get('msg');
        } else {
            pagePositiveMessage = null;
        }
    }

    public EMS_DynamicVFLoader(ApexPages.StandardController controller) {
        List<Schema.RecordTypeInfo> sobjectRecordTypes = GNE_SFA2_Application_Cache.describeObject(String.valueOf(controller.getRecord().getSObjectType())).getRecordTypeInfos();
        myObject = controller.getRecord();
        visualforceIncludesMap = new Map<String, Boolean>();

        myObjectType = String.valueOf(controller.getRecord().getSObjectType());
        if (sobjectRecordTypes.size() == 1 || myObject.get('RecordTypeId') == null) {
            recordTypeName = '';

        } else {
            recordTypeName = [Select DeveloperName from RecordType where id = :(String) myObject.get('RecordTypeId')].DeveloperName;
        }
    }

    public PageReference init() {
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
        if (userApplicationContext != null) {
            fieldSetMap = new Map<String, List<SFA2_Configuration_Object_Detail_gne__c>>();
            relatedFieldSetMap = new Map<String, List<SFA2_Configuration_Object_Detail_gne__c>>();
            relatedListAttributes = new Map<String, GNE_SFA2_RL_Component_AttributesWrapper>();
            Boolean listRendered = false;

            fieldSetList = new List<String>();
            relatedFieldSetList = new List<String>();
            fieldSetHeadings = new Map<String, String>();
            fieldOfUserReferenceMap = new Map<String, String>();
            fieldOfGroupReferenceMap = new Map<String, String>();
            userReferenceHasExist = new Map<String, Boolean>();
            groupReferenceHasExist = new Map<String, Boolean>();
            helpTextExistsMap = new Map<String, Boolean>();
            helpTextValueMap = new Map<String, String>();

            retURL = System.currentPageReference().getParameters().get('retURL');
            if (retURL != null) {
                retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
            }
            // set to control query fields
            List<SFA2_Configuration_Object_gne__c> layouts = getUIConfigurationObjects(userApplicationContext, myObjectType, recordTypeName);
            List<GNE_SFA2_RL_Component_AttributesWrapper> componentsForSecondPass = new List<GNE_SFA2_RL_Component_AttributesWrapper>();
            pageConfiguration = GNE_SFA2_Util.getListPageConfiguration(myObjectType);
            // Get All Fields Descriptions From MyObjectType - Michal H.
            Map<String, Schema.SObjectField> sObjectFieldMap = prepareObjectTypeFieldsMap(myObjectType);
            // Get User Object Prefix
            final String userPrefix = GNE_SFA2_Application_Cache.describeObject('User').getKeyPrefix();
            System.debug('myObjectType: ' + myObjectType);
            System.debug('recordTypeName: ' + recordTypeName);

            if (layouts.size() > 0) {
                String theQuery = 'SELECT ';
                Set<String> queryFields = new Set<String>{};

                if (myObjectType == 'Account') {
                    queryFields.add('isPersonAccount');
                }
                for (SFA2_Configuration_Object_gne__c layout : layouts) {
                    fieldSetHeadings.put(layout.id, layout.Section_Header_gne__c);
                    for (SFA2_Configuration_Object_Detail_gne__c layoutDetails : layout.Configuration_Objects__r) {
                        if ((layoutDetails.Type_gne__c == FIELD && layoutDetails.Availability_Mode_gne__c != null && layoutDetails.Availability_Mode_gne__c.contains('View')) || layoutDetails.Type_gne__c == BLANK_SPACE) {
                            if (!fieldSetMap.containsKey(layout.id)) {
                                fieldSetMap.put(layout.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                                fieldSetList.add(layout.id);
                            }
                            fieldSetMap.get(layout.id).add(layoutDetails);
                            prepareHelpTextExistsMap(sObjectFieldMap, layoutDetails.API_Name_gne__c, layoutDetails.id);

                            // Check If Field Has User Reference 
                            if (layoutDetails.API_Name_gne__c != null && layoutDetails.API_Name_gne__c.contains('.')) {
                                userReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                            } else {
                                try {
                                    System.debug('layoutDetails: ' + layoutDetails);
                                    Schema.SObjectField sObjectField = sObjectFieldMap.get(layoutDetails.API_Name_gne__c);
                                    List<Schema.sObjectType> fieldReference = sObjectField.getDescribe().getReferenceTo();
                                    if (fieldReference.size() > 0) {
                                        Set<String> referenceSet = new Set<String>();
                                        for (Integer i = 0; i < fieldReference.size(); i++) {
                                            referenceSet.add(String.valueOf(fieldReference[i]));
                                        }
                                        if (referenceSet.contains('User') && !referenceSet.contains('Group')) {
                                            String relationName = sObjectField.getDescribe().getRelationshipName();
                                            fieldOfUserReferenceMap.put(layoutDetails.API_Name_gne__c, relationName + '.Name');
                                            userReferenceHasExist.put(layoutDetails.API_Name_gne__c, true);
                                            groupReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                            queryfields.add(relationName + '.Name');
                                        } else if (referenceSet.contains('User') && referenceSet.contains('Group')) {
                                            String query = 'SELECT ' + layoutDetails.API_Name_gne__c + ' FROM ' + myObjectType + ' WHERE id = \'' + myObject.Id + '\' LIMIT 1';
                                            sObject reference = Database.query(query);
                                            String referenceId = String.valueOf(reference.get(layoutDetails.API_Name_gne__c));
                                            if (referenceId.startsWith(userPrefix)) {
                                                String relationName = sObjectField.getDescribe().getRelationshipName();
                                                fieldOfUserReferenceMap.put(layoutDetails.API_Name_gne__c, relationName + '.Name');
                                                userReferenceHasExist.put(layoutDetails.API_Name_gne__c, true);
                                                groupReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                                queryfields.add(relationName + '.Name');
                                            } else {
                                                String relationName = sObjectField.getDescribe().getRelationshipName();
                                                fieldOfGroupReferenceMap.put(layoutDetails.API_Name_gne__c, relationName + '.Name');
                                                userReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                                groupReferenceHasExist.put(layoutDetails.API_Name_gne__c, true);
                                                queryfields.add(relationName + '.Name');
                                            }
                                        } else {
                                            userReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                            groupReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                        }
                                    } else {
                                        userReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                        groupReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                    }
                                } catch (Exception ex) {
                                    userReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                    groupReferenceHasExist.put(layoutDetails.API_Name_gne__c, false);
                                }
                            }

                            if (layoutDetails.Type_gne__c == FIELD) {
                                if (!queryFields.contains(layoutDetails.API_Name_gne__c)) {
                                    if (layoutDetails.API_Name_gne__c.equalsIgnoreCase('RecordType.Name')) {
                                        queryfields.add( 'toLabel(' + layoutDetails.API_Name_gne__c + ')');
                                    } else {
                                        queryfields.add(layoutDetails.API_Name_gne__c);
                                    }
                                    queryFields.add(layoutDetails.API_Name_gne__c);
                                }
                            }
                        } else if (layoutDetails.Type_gne__c == RELATED_LIST) {
                            if (!relatedFieldSetMap.containsKey(layout.id)) {
                                relatedFieldSetList.add(layout.id);
                                relatedFieldSetMap.put(layout.id, new List<SFA2_Configuration_Object_Detail_gne__c>());
                            }
                            relatedFieldSetMap.get(layout.id).add(layoutDetails);

                            GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(layoutDetails.Attributes_gne__c);
                            relatedListAttributes.put(layoutDetails.API_Name_gne__c, attributesWrapper);
                            if (attributesWrapper.shouldUpdateURL()) {
                                componentsForSecondPass.add(attributesWrapper);
                            }
                            //relatedListAttributes.put(layoutDetails.Id, attributesWrapper);
                        } else if (layoutDetails.Type_gne__c == VF_PAGE) {
                            visualforceIncludesMap.put(layoutDetails.API_Name_gne__c, true);
                        }
                    }
                }

                for (GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper: componentsForSecondPass) {
                    for (String key : attributesWrapper.urlParametersMap.keySet()) {
                        if (!queryFields.contains(attributesWrapper.urlParametersMap.get(key) + ', ')) {
                            queryFields.add(attributesWrapper.urlParametersMap.get(key));
                        }
                    }
                }

                if (!queryfields.contains('CreatedDate')) {
                    queryfields.add('CreatedDate');
                }

                if (!queryfields.contains('LastModifiedDate')) {
                    queryFields.add('LastModifiedDate');
                }

                if ((myObjectType == 'Contact' || myObjectType == 'Account') && !queryfields.contains('Salutation')) {
                    queryFields.add('Salutation');
                }

                theQuery += String.join(new List<String>(queryFields), ', ');
                theQuery += ' FROM ' + myObjectType + ' WHERE id = \'' + myObject.Id + '\'';
                System.debug('theQuery: ' + theQuery);

                try {
                    myObject = Database.query(theQuery);
                    for (GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper: componentsForSecondPass) {
                        if (String.isNotBlank(attributesWrapper.urlForNewRecord)) {
                            String updatedUrl = attributesWrapper.urlForNewRecord + '?';
                            for (String key : attributesWrapper.urlParametersMap.keySet()) {
                                updatedUrl += key + '=' + myObject.get(attributesWrapper.urlParametersMap.get(key)) + '&';
                            }
                            attributesWrapper.urlForNewRecord = updatedUrl;
                        }
                    }
                } catch (System.QueryException e) {
                    System.debug('query Exception: ' + e);
                    PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
                    pageref.setredirect(true);
                    pageref.getParameters().put('exMessage', 'Record not found or Id parameter missing.');
                    pageref.getParameters().put('exUrl', Apexpages.currentPage().getUrl());
                    pageref.getParameters().put('developerMessage', e.getMessage());
                    return pageref;
                }
            } else {
                PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
                pageref.setredirect(true);
                pageref.getParameters().put('exMessage', 'Layout configuration records not found.');
                pageref.getParameters().put('exUrl', Apexpages.currentPage().getUrl());
                return pageref;
            }

        } else {
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
            pageref.setredirect(true);
            pageref.getParameters().put('exMessage', 'Roster configuration not found.');
            pageref.getParameters().put('exUrl', Apexpages.currentPage().getUrl());
            return pageref;
        }
        return null;
    }

    public Component.Apex.Outputpanel getCustomButtons() {
        return getActiveCustomButtons(GNE_SFA2_Util.getUserApplicationContext(), myObjectType, recordTypeName, myObject.id);
    }

    public PageReference refreshCustomButtons() {

        getCustomButtons();
        return null;
    }

    public virtual PageReference callMethod(String methodName) {
        return null;
    }
    public static List<SFA2_Configuration_Object_gne__c> getUIConfigurationObjects(GNE_SFA2_User_App_Context_gne__c userApplicationContext, String objectApiName, String recordTypeName) {
        return [
                SELECT Id, Name, Role_gne__c, Object_Name_gne__c, Section_Header_gne__c,
                        Record_Type_gne__c, Brand_gne__c, Order_gne__c, Style_gne__c, Attributes_gne__c, (
                        SELECT Name, API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Read_Only_gne__c, Help_Text_gne__c,
                                Is_Required_gne__c, Order_gne__c, Style_gne__c, Type_gne__c, Availability_Mode_gne__c
                        FROM Configuration_Objects__r
                        WHERE Is_Active_gne__c = true
                        ORDER BY Order_gne__c, API_Name_gne__c
                )
                FROM SFA2_Configuration_Object_gne__c
                WHERE Object_Name_gne__c = :objectApiName
                AND Role_gne__c = :userApplicationContext.Role_gne__c
                AND Brand_gne__c = :userApplicationContext.Brand_gne__c
                AND Record_Type_gne__c = :recordTypeName
                AND Application_Type__c = :userApplicationContext.App_Name_gne__c
                AND Is_Active_gne__c = true
                AND Configuration_Type_gne__c = 'Page'
                ORDER BY Order_gne__c, Section_Header_gne__c
        ];
    }

    public static List<SFA2_Configuration_Object_Detail_gne__c> getUIConfigurationObjectDetails(GNE_SFA2_User_App_Context_gne__c userApplicationContext, String objectApiName, String recordTypeName, String elementType) {
        return [
                SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Required_gne__c, Help_Text_gne__c,
                        Is_Read_Only_gne__c, Order_gne__c, Type_gne__c, Style_gne__c, Availability_Mode_gne__c
                FROM SFA2_Configuration_Object_Detail_gne__c
                WHERE Type_gne__c = :elementType
                AND Configuration_Object_ref_gne__r.Object_Name_gne__c = :objectApiName
                AND Configuration_Object_ref_gne__r.Role_gne__c = :userApplicationContext.Role_gne__c
                AND Configuration_Object_ref_gne__r.Brand_gne__c = :userApplicationContext.Brand_gne__c
                AND Configuration_Object_ref_gne__r.Application_Type__c = :userApplicationContext.App_Name_gne__c
                AND Configuration_Object_ref_gne__r.Record_Type_gne__c = :recordTypeName
                AND Configuration_Object_ref_gne__r.Is_Active_gne__c = true
                AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c = 'Page'
                AND Is_Active_gne__c = true
                ORDER BY Order_gne__c, API_Name_gne__c
        ];
    }

    // User Link Override And Help Text For Field - Michal Hrycenko - 03/01/2013
    public Map<String, Schema.SObjectField> prepareObjectTypeFieldsMap(String objectType) {
        Schema.DescribeSObjectResult result = GNE_SFA2_Application_Cache.describeObject(objectType);
        Map<String, Schema.SObjectField> sObjectFieldMap = result.fields.getMap();
        return sObjectFieldMap;
    }

    public void prepareHelpTextExistsMap(Map<String, Schema.SObjectField> sObjectFieldMap, String viewField, String layoutDetailsId) {
        try {
            Schema.SObjectField sObjectField = sObjectFieldMap.get(viewField);
            String helpText = sObjectField.getDescribe().getInlineHelpText();
            if (helpText != null) {
                helpTextExistsMap.put(layoutDetailsId, true);
                helpTextValueMap.put(layoutDetailsId, helpText);
            } else {
                helpTextExistsMap.put(layoutDetailsId, false);
            }
        } catch (Exception ex) {

        }
    }


    public String getActiveMenuItem() {
        String result = '';
        if (pageConfiguration != null && pageConfiguration.Attributes_gne__c != null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')) {
            result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=', ';');
        }
        return result;
    }

    public static Component.Apex.Outputpanel getActiveCustomButtons(GNE_SFA2_User_App_Context_gne__c userApplicationContext, String objectName, String recordTypeName, Id objectId) {

        if (userApplicationContext != null && objectName != null && recordTypeName != null) {
            List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = getUIConfigurationObjectDetails(userApplicationContext, objectName, recordTypeName, BUTTON);
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), objectId);

            Component.Apex.Outputpanel dynamicOutputpanel = new Component.Apex.Outputpanel();
            dynamicOutputpanel.layout = 'none';
            for (SFA2_Configuration_Object_Detail_gne__c buttonConfiguration : buttonConfigurations) {
                if (buttonConfiguration.API_Name_gne__c.equalsIgnoreCase('Edit') && !userRecordAccess.HasEditAccess) {
                    continue;
                }
                if (buttonConfiguration.API_Name_gne__c.equalsIgnoreCase('Delete') && !userRecordAccess.HasDeleteAccess) {
                    continue;
                }
                if (buttonConfiguration.API_Name_gne__c.equalsIgnoreCase('Share') && !userRecordAccess.HasTransferAccess) {
                    continue;
                }

                Component.Apex.CommandLink dynamicButton = new Component.Apex.CommandLink();
                dynamicButton.value = buttonConfiguration.Label_gne__c;
                dynamicButton.style = buttonConfiguration.Style_gne__c;
                dynamicButton.title = buttonConfiguration.Label_gne__c;
                if (buttonConfiguration.Label_gne__c == 'View Attachments') {
                    dynamicButton.id = 'view-Attachments';
                }
                if (buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('action')) {
                    dynamicButton.expressions.action = '{!' + buttonConfiguration.Attributes_gne__c.substringBetween('action=', ';') + '}';
                }
                if (buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('styleClass')) {
                    dynamicButton.styleClass = buttonConfiguration.Attributes_gne__c.substringBetween('styleClass=', ';');
                }
                if (buttonConfiguration.Is_Read_Only_gne__c) {
                    // works only with Bootstrap
                    dynamicButton.styleClass += ' disabled';
                }
                if (buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('dir')) {
                    dynamicButton.dir = buttonConfiguration.Attributes_gne__c.substringBetween('dir=', ';');
                }
                if (buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('onclick')) {
                    if (!buttonConfiguration.Attributes_gne__c.substringBetween('onclick=', ';').containsAny('{!$Profile.Name}')) {
                        dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=', ';');
                    } else {
                        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
                        dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=', ';').replace('{!$Profile.Name}', profileName);
                    }
                    dynamicButton.onclick += '; return false;';
                }
                if (buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('rerender')) {
                    dynamicButton.rerender = new Set<String>(buttonConfiguration.Attributes_gne__c.substringBetween('rerender=', ';').split(','));
                }
                if (buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('immediate')) {
                    if (buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.substringBetween('immediate=', ';') == 'true') {
                        dynamicButton.immediate = true;
                    } else {
                        dynamicButton.immediate = false;
                    }
                }
                dynamicOutputpanel.childComponents.add(dynamicButton);
            }
            return dynamicOutputpanel;
        } else {
            return new Component.Apex.Outputpanel();
        }
    }

    public Pagereference showRelatedList() {
        listRendered = true;
        return null;
    }

    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/EMS_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference deleteClick() {
        try {
            delete(myObject);

            String viewURL = '';
            String retURL = System.currentPageReference().getParameters().get('retURL');
            if (retURL != null) {
                retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
            }

            if (String.isNotEmpty(retURL)) {
                viewURL = retURL;
            } else {
                viewURL = '/apex/EMS_Home';
            }
            PageReference pageref = new PageReference(viewURL);
            pageref.setredirect(true);
            return pageref;
        } catch (DMLException e) {
            if (e.getMessage().contains('DUPLICATE_VALUE')) {
                String strId = e.getMessage().substring(e.getMessage().indexof('id:'), e.getMessage().length() - 4);
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Invalid Data: Duplicate Value On Record ' + strId));
                return null;
            } else if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                Apexpages.addMessages(e);
                return null;
            } else if (e.getMessage().contains('FIELD_FILTER_VALIDATION_EXCEPTION')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Value does not exist or does not match filter criteria.'));
                return null;
            } else if (e.getMessage().contains('TRANSFER_REQUIRES_READ')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'User you selected can not be owner of the record. New owner must have object read permission.'));
                return null;
            } else if (e.getMessage().contains('CIRCULAR_DEPENDENCY')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, ''));
                return null;
            } else if (e.getMessage().contains('INVALID_CROSS_REFERENCE_KEY')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, ''));
                return null;
            } else if (e.getMessage().contains('INSUFFICIENT')) {
                return Page.GNE_SFA2_Access_Denied;
            } else if (e.getMessage().contains('ENTITY_IS_LOCKED')) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Error: This item is currently pending approval and cannot be deleted at this time.'));
                return null;
            } else {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, e.getMessage()));
                return null;
            }
        }
    }

    public virtual PageReference shareClick() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Record_Sharing?parentId=' + myObject.id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference editClick(ID recordId, String editURL) {
        PageReference pageref;
        UserRecordAccess recordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId LIMIT 1];
        if (recordAccess != null && recordAccess.HasEditAccess) {
            pageref = new PageReference(editURL + '?id=' + recordId);
        } else {
            pageref = Page.GNE_SFA2_Access_Denied;
        }

        pageref.setredirect(true);
        return pageref;
    }
}