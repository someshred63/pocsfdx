public with sharing class gFRS_LinkAttachmentToFieldController {

    public Boolean showRelatedRecordPicklist { get; set; }
    public Boolean needConfirmation { get; set; }
    public Boolean isRequestCorrect { get; set; }
    public List<SelectOption> attachmentFieldsList { get; set; }
    public List<SelectOption> objectsList { get; set; }
    public List<SelectOption> sectionsList { get; set; }
    public List<SelectOption> relatedRecordsList { get; set; }
    public List<GFRS_Program__c> relatedPrograms { get; set; }
    public List<Attachment> attachments { get; set; }
    public GFRS_Funding_Request__c request { get; set; }
    public SObject currentObject { get; set; }
    public String selectedAttachment { get; set; }
    public String currentFieldValue { get; set; }
    public String selectedAttachmentField { get; set; }
    public String selectedRelatedRecord { get; set; }
    public String selectedObject { get; set; }
    public String selectedObjectLabel { get; set; }
    public String selectedSection { get; set; }
    public String objectName { get; set; }
    public String queryObjectSectionsFields { get; set; }
    public Integer countTotalRecords { get; set; }
    public Integer offsetSize = 0;
    public Integer queryLimit { get; set; }
    public Id objectId { get; set; }
    public Set<Id> attachmentIds { get; set; }
    public final static Map<String, String> objectNameAndLabel = new Map<String, String>();
    public final static Map<String, String> recordTypeMapping = new Map<String, String>();
    public final static String FINANCIAL_REPORT_FIELD = 'Financial_Report__c';
    static {
        objectNameAndLabel.put(gFRS_Util.FUNDING_REQUEST_API_NAME, SObjectType.GFRS_Funding_Request__c.getLabel());
        objectNameAndLabel.put(gFRS_Util.ORGANIZATION_API_NAME, SObjectType.GFRS_Organization__c.getLabel());
        objectNameAndLabel.put(gFRS_Util.PROGRAM_API_NAME, SObjectType.GFRS_Program__c.getLabel());
    }
    static {
        recordTypeMapping.put(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME, 'CorpMem');
        recordTypeMapping.put(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME, 'ExOthProm');
        recordTypeMapping.put(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME, 'SciPipe');
        recordTypeMapping.put(gFRS_Util.TYPE_FELLOWSHIPS_NAME, 'Fell');
        recordTypeMapping.put(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME, 'FIE');
        recordTypeMapping.put(gFRS_Util.TYPE_HC_CHAR_NAME, 'HcChar');
        recordTypeMapping.put(gFRS_Util.TYPE_IMED_NAME, 'IMED');
        recordTypeMapping.put(gFRS_Util.TYPE_PHILANTHROPIC_NAME, 'Phil');
        recordTypeMapping.put(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME, 'SciProj');
    }

    public gFRS_LinkAttachmentToFieldController() {
        objectId = ApexPages.currentPage().getParameters().get('id');
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        queryLimit = Integer.valueOf(customSettings.gFRS_LinkAttachmentQueryLimit__c) != null ? Integer.valueOf(customSettings.gFRS_LinkAttachmentQueryLimit__c) : 5;
        countTotalRecords = 0;
        showRelatedRecordPicklist = false;
        isRequestCorrect = true;
        objectsList = new List<SelectOption>();

        try {
            Schema.SObjectType sObjType = objectId.getSobjectType();
            objectName = sObjType.getDescribe().getName();
            currentObject = getObjectUsingId(objectId);
            request = objectName == gFRS_Util.FUNDING_REQUEST_API_NAME ? (GFRS_Funding_Request__c) currentObject : null ;
            needConfirmation = false;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            selectedObject = ApexPages.currentPage().getParameters().get('selectedObjectVal') != null ? ApexPages.currentPage().getParameters().get('selectedObjectVal') : gFRS_Util.FUNDING_REQUEST_API_NAME;
            populateAttachmentIds();
            selectedSection = ApexPages.currentPage().getParameters().get('selectedSectionVal') != null ? ApexPages.currentPage().getParameters().get('selectedSectionVal') : 'None';
            selectedAttachmentField = ApexPages.currentPage().getParameters().get('selectedFieldVal') != null ? ApexPages.currentPage().getParameters().get('selectedFieldVal') : 'None';
            selectedRelatedRecord = ApexPages.currentPage().getParameters().get('selectedRelatedRecordVal') != null ? ApexPages.currentPage().getParameters().get('selectedRelatedRecordVal') : 'None';
            selectedObjectLabel = schemaMap.get(selectedObject).getDescribe().getLabel();
            populateSectionValues(selectedObject);
            populateAttachmentFieldNames(selectedObject);
            onChangeAttachmentFieldName();
            objectsList.add(new SelectOption(gFRS_Util.FUNDING_REQUEST_API_NAME, SObjectType.GFRS_Funding_Request__c.getLabel()));
            objectsList.add(new SelectOption(gFRS_Util.ORGANIZATION_API_NAME, SObjectType.GFRS_Organization__c.getLabel()));
            if (request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME) {
                objectsList.add(new SelectOption(gFRS_Util.PROGRAM_API_NAME, SObjectType.GFRS_Program__c.getLabel()));
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ', Line number: ' + ex.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find funding request.'));
            return;
        }
    }

    public PageReference linkAttachment() {
        try {
            if (selectedAttachmentField != 'None' && (!showRelatedRecordPicklist || (showRelatedRecordPicklist && selectedRelatedRecord != 'None'))) {
                if (checkAttachmentAvailability()) {
                    if (isFellowshipsFoundation() && selectedSection == 'Evaluation_page') {
                        List<gFRS_Annual_Evaluation__c> annualEvaluation = getAnnualEvaluationForRequest();
                        if (annualEvaluation.size() > 0) {
                            annualEvaluation.get(0).put(selectedAttachmentField, selectedAttachment);
                            update annualEvaluation.get(0);
                        } else {
                            selectedAttachment = '';
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Funding request does not have Annual Evaluation'));
                        }
                    } else {
                        currentObject.put(selectedAttachmentField, selectedAttachment);
                        update currentObject;
                    }
                } else {
                    needConfirmation = true;
                }
            } else {
                selectedRelatedRecord = '';
                selectedAttachment = '';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select all picklist values.'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        return null;
    }

    public PageReference uploadAttachment() {
        String retUrlValue = '/apex/gFRS_LinkAttachmentToField?id=' + objectId + '%26selectedObjectVal=' + selectedObject + '%26selectedSectionVal=' + selectedSection + '%26selectedFieldVal=' + selectedAttachmentField + '%26selectedRelatedRecordVal=' + selectedRelatedRecord;
        PageReference pageRef;
        if (selectedObject == gFRS_Util.PROGRAM_API_NAME && request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME) {
            if (relatedPrograms.size() == 0) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There are no programs related to this funding request.'));
                return null;
            } else if (relatedPrograms.size() == 1) {
                pageRef = new PageReference('/p/attach/NoteAttach?pid=' + currentObject.get('Id') + '&retURL=' + retUrlValue);
                pageRef.setRedirect(true);
                return pageRef;
            } else {
                if (selectedRelatedRecord != 'None' && selectedRelatedRecord != '') {
                    pageRef = new PageReference('/p/attach/NoteAttach?pid=' + selectedRelatedRecord + '&retURL=' + retUrlValue);
                    pageRef.setRedirect(true);
                    return pageRef;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select related program.'));
                    return null;
                }
            }
        } else if (selectedObject == gFRS_Util.FUNDING_REQUEST_API_NAME || selectedObject == gFRS_Util.ORGANIZATION_API_NAME) {
            pageRef = new PageReference('/p/attach/NoteAttach?pid=' + currentObject.get('Id') + '&retURL=' + retUrlValue);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }

    public PageReference back() {
        PageReference pageRef = new PageReference('/' + objectId);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void onChangeAttachmentFieldName() {
        if (selectedAttachmentField != 'None' && objectName == selectedObject) {
            currentObject = getObjectUsingId(objectId);
            if (isFellowshipsFoundation() && selectedSection == 'Evaluation_page') {
                List<gFRS_Annual_Evaluation__c> annualEvaluation = getAnnualEvaluationForRequest();
                selectedAttachment = annualEvaluation.size() > 0 ? String.valueOf(annualEvaluation.get(0).get(FINANCIAL_REPORT_FIELD)) : '';
            } else {
                selectedAttachment = String.valueOf(currentObject.get(selectedAttachmentField));
            }
        } else if (selectedAttachmentField != 'None' && objectName != selectedObject && selectedRelatedRecord != 'None' && attachments.size() > 0) {
            currentObject = getObjectUsingId(selectedRelatedRecord);
            selectedAttachment = String.valueOf(currentObject.get(selectedAttachmentField));
        } else {
            selectedAttachment = '';
            needConfirmation = false;
        }
    }

    public void populateAttachmentIds() {
        if (objectName == gFRS_Util.FUNDING_REQUEST_API_NAME) {
            if (selectedObject == gFRS_Util.ORGANIZATION_API_NAME) {
                attachmentIds = new Set<Id>{
                        request.Organization__c
                };
                loadAttachmentsList();
                selectedRelatedRecord = request.Organization__c;
                currentObject = getObjectUsingId(selectedRelatedRecord);
            } else if (selectedObject == gFRS_Util.PROGRAM_API_NAME) {
                relatedRecordsList = new List<SelectOption>();
                Set<Id> requestRelatedPrograms = new Set<Id>(new Map<Id, GFRS_Program__c>([SELECT Id FROM GFRS_Program__c WHERE Funding_Request__c = :objectId LIMIT 100]).keySet());
                attachmentIds = requestRelatedPrograms;
                loadAttachmentsList();
                relatedPrograms = [SELECT Id, Name FROM GFRS_Program__c WHERE Funding_Request__c = :objectId LIMIT 100];
                relatedRecordsList.add(new SelectOption('None', '--Choose--'));
                for (GFRS_Program__c prog : relatedPrograms) {
                    relatedRecordsList.add(new SelectOption(prog.Id, prog.Name));
                }
                showRelatedRecordPicklist = relatedRecordsList.size() > 1 && request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME ? true : false;
                if (relatedPrograms.size() == 1) {
                    currentObject = getObjectUsingId(relatedPrograms.get(0).Id);
                }
            } else {
                attachmentIds = new Set<Id>{
                        objectId
                };
                loadAttachmentsList();
                currentObject = getObjectUsingId(objectId);
            }
        }
    }

    public void onChangeObjectValue() {
        showRelatedRecordPicklist = false;
        needConfirmation = false;
        queryObjectSectionsFields = '';
        attachmentFieldsList = new List<SelectOption>();
        attachmentFieldsList.add(new SelectOption('None', '--Choose--'));
        populateAttachmentIds();
        selectedObjectLabel = objectNameAndLabel.get(selectedObject);
        populateSectionValues(selectedObject);
    }

    public void loadAttachmentsList() {
        countTotalRecords = [SELECT COUNT() FROM Attachment WHERE ParentId IN :attachmentIds];
        offsetSize = offsetSize + queryLimit < 1000 ? offsetSize : 999 - queryLimit;
        attachments = [
                SELECT Id, Name, ParentId, LastModifiedDate, CreatedBy.Name
                FROM Attachment
                WHERE ParentId IN :attachmentIds
                ORDER BY LastModifiedDate DESC
                LIMIT :queryLimit
                OFFSET :offsetSize
        ];
    }

    public void populateSectionValues(String selObj) {
        Map<String, String> contentItemsFields = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter('Link_Att_Sections', UserInfo.getLanguage());
        sectionsList = new List<SelectOption>();
        sectionsList.add(new SelectOption('None', '--Choose--'));
        String section;
        List<String> sections = new List<String>();

        if (selObj == gFRS_Util.FUNDING_REQUEST_API_NAME) {
            section = gFRS_Settings__c.getValues('Sect_FundReq_' + recordTypeMapping.get(String.valueOf(currentObject.get('Record_Type_Name__c')))).Value__c;
        } else if (selObj == gFRS_Util.ORGANIZATION_API_NAME) {
            section = request.Foundation_Classified__c == 'TRUE' ? gFRS_Settings__c.getValues('Sect_' + selObj + '_Fund').Value__c : gFRS_Settings__c.getValues('Sect_' + selObj).Value__c;
        } else if (selObj == gFRS_Util.PROGRAM_API_NAME) {
            section = gFRS_Settings__c.getValues('Sect_' + selObj).Value__c;
        }
        sections = section.split(';');
        for (String s : sections) {
            sectionsList.add(new SelectOption(s, contentItemsFields.get(s)));
        }
    }

    public void populateAttachmentFieldNames(String selObj) {
        if (selectedSection != 'None') {
            List<String> objectAttachmentsFields = new List<String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType gfrsSchema = schemaMap.get(selObj);
            Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
            String customSettingFields = gFRS_Settings__c.getValues(selectedSection).Value__c;
            objectAttachmentsFields = customSettingFields.split(';');
            queryObjectSectionsFields = ',' + customSettingFields.replace(';', ',');
            attachmentFieldsList = new List<SelectOption>();
            attachmentFieldsList.add(new SelectOption('None', '--Choose--'));
            for (String apiName : objectAttachmentsFields) {
                attachmentFieldsList.add(new SelectOption(apiName, fieldMap.get(apiName).getDescribe().getLabel()));
            }
            if (isFellowshipsFoundation() && selectedSection == 'Evaluation_page') {
                attachmentFieldsList = new List<SelectOption>();
                attachmentFieldsList.add(new SelectOption('None', '--Choose--'));
                attachmentFieldsList.add(new SelectOption(FINANCIAL_REPORT_FIELD, 'Financial Report'));
            }
        } else {
            attachmentFieldsList = new List<SelectOption>();
            attachmentFieldsList.add(new SelectOption('None', '--Choose--'));
        }
    }

    public SObject getObjectUsingId(Id objId) {
        Schema.SObjectType sObjType = objId.getSobjectType();
        Schema.DescribeSObjectResult dr = sObjType.getDescribe();
        String tempObjectName = dr.getName();
        String commonFields = 'Id, Name';
        Map<String, String> objectSpecificFields = new Map<String, String>();
        objectSpecificFields.put(gFRS_Util.FUNDING_REQUEST_API_NAME.toUpperCase(), ',Foundation_Classified__c,Organization__c,Record_Type_Name__c,LOA_Signed__c,LOA_Signed_Date__c,LOA_Signer_Name__c');
        objectSpecificFields.put(gFRS_Util.ORGANIZATION_API_NAME.toUpperCase(), '');
        objectSpecificFields.put(gFRS_Util.PROGRAM_API_NAME.toUpperCase(), ',Funding_Request__c, Funding_Request__r.Organization__c');


        queryObjectSectionsFields = queryObjectSectionsFields != null && queryObjectSectionsFields != '' ? queryObjectSectionsFields : '';
        String queryString = 'Select ' + commonFields + objectSpecificFields.get(tempObjectName.toUpperCase()) + queryObjectSectionsFields;
        queryString += ' FROM ' + dr.getName() + ' WHERE Id = \'' + objId + '\' LIMIT 1';
        if (tempObjectName == gFRS_Util.FUNDING_REQUEST_API_NAME) {
            request = (GFRS_Funding_Request__c) Database.query(queryString);
            return (GFRS_Funding_Request__c) request;
        } else if (tempObjectName == gFRS_Util.ORGANIZATION_API_NAME) {
            return (GFRS_Organization__c) Database.query(queryString);
        } else if (tempObjectName == gFRS_Util.PROGRAM_API_NAME) {
            return (GFRS_Program__c) Database.query(queryString);
        }
        return null;
    }

    public void onChangeRelatedRecord() {
        needConfirmation = false;
        if (objectName == gFRS_Util.FUNDING_REQUEST_API_NAME) {
            if (selectedObject == gFRS_Util.ORGANIZATION_API_NAME) {
                attachmentIds = new Set<Id>{
                        request.Organization__c
                };
                loadAttachmentsList();
                selectedRelatedRecord = request.Organization__c;
            } else if (selectedObject == gFRS_Util.PROGRAM_API_NAME) {
                if (selectedRelatedRecord != 'None') {
                    attachmentIds = new Set<Id>{
                            selectedRelatedRecord
                    };
                    loadAttachmentsList();
                } else {
                    attachments = null;
                }
            } else {
                attachmentIds = new Set<Id>{
                        objectId
                };
                loadAttachmentsList();
            }
        }
        onChangeAttachmentFieldName();
    }

    public void onChangeSectionValue() {
        selectedAttachment = '';
        needConfirmation = false;
        populateAttachmentFieldNames(selectedObject);
    }

    public Boolean checkAttachmentAvailability() {
        List<String> tempAttachmentsFields = new List<String>();
        String tempCustomSettingItem = '';
        List<String> sections = new List<String>();
        for (SelectOption so : sectionsList) {
            sections.add(so.getValue());
        }
        sections.remove(0);
        String tempQueryPart = '';
        for (String section : sections) {
            tempCustomSettingItem = gFRS_Settings__c.getValues(section).Value__c;
            tempQueryPart += tempCustomSettingItem.replace(';', ',') + ',';
            for (String key : tempCustomSettingItem.split(';')) {
                tempAttachmentsFields.add(key);
            }
        }
        queryObjectSectionsFields = ',' + tempQueryPart.removeEnd(',');
        if (selectedAttachmentField != 'None' && objectName == selectedObject) {
            currentObject = getObjectUsingId(objectId);

        } else if (selectedAttachmentField != 'None' && objectName != selectedObject && selectedRelatedRecord != 'None' && attachments.size() > 0) {
            currentObject = getObjectUsingId(selectedRelatedRecord);
        }
        for (String s : tempAttachmentsFields) {
            if (selectedAttachment == String.valueOf(currentObject.get(s))) {
                currentFieldValue = s;
                return false;
            }

        }
        if (isFellowshipsFoundation()) {
            List<gFRS_Annual_Evaluation__c> annualEvaluation = getAnnualEvaluationForRequest();
            if (annualEvaluation.size() > 0 && selectedAttachment == String.valueOf(annualEvaluation.get(0).get(FINANCIAL_REPORT_FIELD))) {
                currentFieldValue = FINANCIAL_REPORT_FIELD;
                return false;
            }
        }
        return true;
    }
    public List<gFRS_Annual_Evaluation__c> getAnnualEvaluationForRequest() {
        return [SELECT Financial_Report__c FROM gFRS_Annual_Evaluation__c WHERE Funding_Request__c = :objectId ORDER BY CreatedDate DESC LIMIT 1];
    }
    public void updateAfterConfirmation() {
        if (needConfirmation) {
            try {
                if (currentFieldValue == FINANCIAL_REPORT_FIELD) {
                    List<gFRS_Annual_Evaluation__c> annualEvaluation = getAnnualEvaluationForRequest();
                    annualEvaluation.get(0).Financial_Report__c = null;
                    update annualEvaluation.get(0);
                    currentObject.put(selectedAttachmentField, selectedAttachment);
                } else if (currentFieldValue != FINANCIAL_REPORT_FIELD && selectedAttachmentField == FINANCIAL_REPORT_FIELD) {
                    List<gFRS_Annual_Evaluation__c> annualEvaluation = getAnnualEvaluationForRequest();
                    annualEvaluation.get(0).Financial_Report__c = selectedAttachment;
                    update annualEvaluation.get(0);
                    currentObject.put(currentFieldValue, null);
                } else {
                    currentObject.put(currentFieldValue, null);
                    currentObject.put(selectedAttachmentField, selectedAttachment);
                }
                update currentObject;
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }
    }
    public Boolean isFellowshipsFoundation() {
        return request != null && request.Foundation_Classified__c == 'TRUE' && request.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME;
    }
    public Boolean getDisablePrevious() {
        if (offsetSize > 0) {
            return false;
        } else {
            return true;
        }
    }

    public Boolean getDisableNext() {
        if (offsetSize + queryLimit < countTotalRecords) {
            return false;
        } else {
            return true;
        }
    }

    public PageReference next() {
        offsetSize += queryLimit;
        loadAttachmentsList();
        return null;
    }

    public PageReference previous() {
        offsetSize -= queryLimit;
        loadAttachmentsList();
        return null;
    }

    public Boolean getIsLoaSectionEnabled() {
        return selectedSection == 'Loa_page' && selectedAttachmentField == 'LOA_PDF__c';
    }

    public PageReference save() {
        if (!isLoaInformationProvided()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_ERROR_LOA_EMPTY));
        } else {
            request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
            request.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_APPROVED;
            update request;
        }
        return null;
    }

    public PageReference cancel() {
        request.LOA_Signed__c = null;
        request.LOA_Signed_Date__c = null;
        request.LOA_Signer_Name__c = null;
        return null;
    }

    public Boolean getIsLoaUploadButtonDisabled() {
        return getIsLoaSectionEnabled() && !isLoaInformationProvided();
    }

    private Boolean isLoaInformationProvided() {
        return !(request.LOA_Signed__c == null || request.LOA_Signed_Date__c == null|| request.LOA_Signer_Name__c == null);
    }
}