public with sharing class gFRS_LinkAttachmentFieldCntrlrCoPay {
    
    public List<SelectOption> objectsList { get; set; }
    public String selectedObject { get; set; }
    public Boolean needConfirmation { get; set; }
    public Boolean isRequestCorrect { get; set; }
    public String queryObjectSectionsFields { get; set; }
    public List<SelectOption> attachmentFieldsList { get; set; }
    public String selectedObjectLabel { get; set; }
    public final static Map<String,String> objectNameAndLabel = new Map<String, String>();
    public Id objectId { get; set; }
    public String objectName { get; set; }
    public Set<Id> attachmentIds { get; set; }
    public gFRS_CoPay_Funding_Request__c request { get; set; }
    public SObject currentObject { get; set; }
    public Integer queryLimit { get; set; }
    public Integer offsetSize = 0;
    public Integer countTotalRecords { get; set; }
    public List<Attachment> attachments { get; set; }
    public String selectedRelatedRecord { get; set; }
    public List<SelectOption> sectionsList { get; set; }
    public String selectedSection { get; set; }
    public String selectedAttachment { get; set; }
    public String selectedAttachmentField { get; set; }
    public String currentFieldValue { get; set; }
    
    static {
        objectNameAndLabel.put(gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME ,SObjectType.gFRS_CoPay_Funding_Request__c.getLabel());
        objectNameAndLabel.put(gFRS_Util.ORGANIZATION_API_NAME, SObjectType.GFRS_Organization__c.getLabel());
    }

    public gFRS_LinkAttachmentFieldCntrlrCoPay(){
        objectId = ApexPages.currentPage().getParameters().get('id');
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();   
        queryLimit = Integer.valueOf(customSettings.gFRS_LinkAttachmentQueryLimit__c) != null ? Integer.valueOf(customSettings.gFRS_LinkAttachmentQueryLimit__c) : 5;
        objectsList = new List<SelectOption>();
        countTotalRecords = 0;
        isRequestCorrect = true;
        objectsList = new List<SelectOption>();
        try {
            
            Schema.SObjectType sObjType = objectId.getSObjectType();
            objectName = sObjType.getDescribe().getName();
            currentObject = getObjectUsingId(objectId);
            request = objectName == gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME ? (gFRS_CoPay_Funding_Request__c) currentObject : null ;
            needConfirmation = false;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            selectedObject = ApexPages.currentpage().getparameters().get('selectedObjectVal') != null ? ApexPages.currentpage().getparameters().get('selectedObjectVal') : gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME;
            populateAttachmentIds();  
            selectedSection = ApexPages.currentpage().getparameters().get('selectedSectionVal') != null ? ApexPages.currentpage().getparameters().get('selectedSectionVal') : 'None';
            selectedAttachmentField = ApexPages.currentpage().getparameters().get('selectedFieldVal') != null ? ApexPages.currentpage().getparameters().get('selectedFieldVal') : 'None';
            selectedObjectLabel = schemaMap.get(selectedObject).getDescribe().getLabel();
            populateSectionValues(selectedObject);
            populateAttachmentFieldNames(selectedObject);
            onChangeAttachmentFieldName();
            objectsList.add(new SelectOption(gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME ,SObjectType.gFRS_CoPay_Funding_Request__c.getLabel()));
            objectsList.add(new SelectOption(gFRS_Util.ORGANIZATION_API_NAME, SObjectType.GFRS_Organization__c.getLabel()));
            }
        catch ( Exception ex ) {
            System.debug(ex.getMessage() + ', Line number: ' + ex.getLineNumber());
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find funding request.' ));
            return;
        }
    }

    public void onChangeObjectValue(){
        
        needConfirmation = false;
        queryObjectSectionsFields = '';
        attachmentFieldsList = new List<SelectOption>();
        attachmentFieldsList.add(new SelectOption('None','--Choose--'));
        selectedObjectLabel = objectNameAndLabel.get(selectedObject);
        populateAttachmentIds(); 
        populateSectionValues(selectedObject);
    
    }
    
    public void populateAttachmentIds(){
        if (objectName == gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME){
            if (selectedObject == gFRS_Util.ORGANIZATION_API_NAME){
                attachmentIds = new Set<Id>{request.Organization__c};
                loadAttachmentsList();
                selectedRelatedRecord = request.Organization__c;
                currentObject = getObjectUsingId(selectedRelatedRecord);
            }else {
                attachmentIds = new Set<Id>{objectId};
                loadAttachmentsList();
                currentObject = getObjectUsingId(objectId);
            }                   
        }
    }
    
    public void populateSectionValues(String selObj){
 
        Map<String,String> contentItemsFields = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( 'Link_Att_Sections', UserInfo.getLanguage() ); 
        
        sectionsList = new List<SelectOption>();
        sectionsList.add(new SelectOption('None','--Choose--'));
        String section;
        List<String> sections = new List<String>();
        
        if (selObj == gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME){
            section = gFRS_Settings__c.getValues('Sect_FundReq_Copay').Value__c;
        } else if (selObj == gFRS_Util.ORGANIZATION_API_NAME) {
            section = gFRS_Settings__c.getValues('Sect_gFRS_Organization__c').Value__c;
        } 
        
        sections = section.split(';');
        for (String s : sections){
               sectionsList.add(new SelectOption(s,contentItemsFields.get(s)));  
        }       
    }
    
    public void loadAttachmentsList(){
        countTotalRecords = [ SELECT count() FROM Attachment WHERE ParentId IN :attachmentIds ]; 
        offsetSize = offsetSize + queryLimit < 1000 ? offsetSize : 999 - queryLimit;
        attachments = [ SELECT Id, Name, ParentId, LastModifiedDate, CreatedBy.Name
                            FROM Attachment 
                            WHERE ParentId IN :attachmentIds ORDER BY LastModifiedDate DESC limit :queryLimit offset :offsetSize ];
    }
    
    public SObject getObjectUsingId (Id objId){
        Schema.SObjectType sObjType = objId.getSObjectType();
        Schema.DescribeSObjectResult dr = sObjType.getDescribe();
        String tempObjectName = dr.getName();
        String commonFields = 'Id, Name';
        Map<String,String> objectSpecificFields = new Map<String, String>();
        objectSpecificFields.put(gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME.toUpperCase(), ',Funding_Type__c ,Organization__c');
        objectSpecificFields.put(gFRS_Util.ORGANIZATION_API_NAME.toUpperCase(), '');

        queryObjectSectionsFields = queryObjectSectionsFields != null && queryObjectSectionsFields != '' ? queryObjectSectionsFields : '';
        String queryString = 'Select ' + commonFields + objectSpecificFields.get(tempObjectName.toUpperCase()) + queryObjectSectionsFields;
        queryString += ' FROM ' + dr.getName() + ' WHERE Id = \'' + objId + '\' LIMIT 1';
        
        if (tempObjectName == gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME){
            request = (gFRS_Copay_Funding_Request__c) Database.query(queryString);
            return (gFRS_Copay_Funding_Request__c) request;
        } else if (tempObjectName == gFRS_Util.ORGANIZATION_API_NAME) {
            return (GFRS_Organization__c) Database.query(queryString);            
        }
        
        return null;
    }
    
    public void onChangeSectionValue(){
        selectedAttachment = '';
        needConfirmation = false;
        populateAttachmentFieldNames(selectedObject);        
    }
    
    public void populateAttachmentFieldNames(String selObj){
        if (selectedSection != 'None'){
            List<String> objectAttachmentsFields = new List<String>();
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType gfrsSchema = schemaMap.get(selObj);
            Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
            String customSettingFields = gFRS_Settings__c.getValues(selectedSection).Value__c;
            attachmentFieldsList = new List<SelectOption>();
            attachmentFieldsList.add(new SelectOption('None','--Choose--'));
            
            if(String.isNotBlank(customSettingFields)){
                objectAttachmentsFields = customSettingFields.split(';');  
                queryObjectSectionsFields = ',' + customSettingFields.replace(';', ',');
                for (String apiName : objectAttachmentsFields){
                    attachmentFieldsList.add(new SelectOption(apiName, fieldMap.get(apiName).getDescribe().getLabel()));
                }
            }

        } else {
            attachmentFieldsList = new List<SelectOption>();
            attachmentFieldsList.add(new SelectOption('None','--Choose--'));
        }
    }
    
    public void onChangeAttachmentFieldName(){
        if (selectedAttachmentField != 'None' && objectName == selectedObject){
            currentObject = getObjectUsingId(objectId);
            selectedAttachment = String.valueOf(currentObject.get(selectedAttachmentField));

        }else if (selectedAttachmentField != 'None' && objectName != selectedObject && selectedRelatedRecord != 'None' && attachments.size() > 0) {
            currentObject = getObjectUsingId(selectedRelatedRecord);
            selectedAttachment = String.valueOf(currentObject.get(selectedAttachmentField));
        }else {
            selectedAttachment = '';
            needConfirmation = false;
        }        
    }
    
    public void updateAfterConfirmation(){
        if (needConfirmation){
            try {
                    currentObject.put( currentFieldValue, null );
                    currentObject.put( selectedAttachmentField, selectedAttachment );    
                    update currentObject; 
            }catch (Exception e){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }   
        }
    }
    
    public PageReference uploadAttachment(){
     String retUrlValue = '/apex/GFRS_LinkAttachmentFieldCoPay?id='+objectId+'%26selectedObjectVal='+selectedObject+'%26selectedSectionVal='+selectedSection+'%26selectedFieldVal='+selectedAttachmentField+'%26selectedRelatedRecordVal='+selectedRelatedRecord;
        PageReference pageRef;
        if (selectedObject == gFRS_Utilcopay.COPAY_FUNDING_REQUEST_API_NAME || selectedObject == gFRS_Util.ORGANIZATION_API_NAME){            
            pageRef = new PageReference('/p/attach/NoteAttach?pid='+currentObject.get('Id')+'&retURL='+retUrlValue);
            pageRef.setRedirect(true);
            return pageRef;    
        } 
        return null;
    }
    
    public ApexPages.PageReference linkAttachment(){
        try {
            if (selectedAttachmentField != 'None') {
                if (checkAttachmentAvailability()){
                    currentObject.put( selectedAttachmentField, selectedAttachment );
                    update currentObject;                      
                }else {
                    needConfirmation = true;  
                }                            
            } else {
                selectedRelatedRecord = '';
                selectedAttachment = '';
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please select all picklist values.' ));    
            }  
        } catch (Exception e){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
        return null;
    }

    public Boolean checkAttachmentAvailability(){
        List<String> tempAttachmentsFields = new List<String>();
        String tempCustomSettingItem = '';
        List<String> sections = new List<String>();
        for(SelectOption so: sectionsList){
            sections.add(so.getValue());
        }
        sections.remove(0);
        String tempQueryPart = '';
        for (String section : sections){
            tempCustomSettingItem = gFRS_Settings__c.getValues(section).Value__c;
            if(String.isNotBlank(tempCustomSettingItem)){
                tempQueryPart += tempCustomSettingItem.replace(';', ',') + ',';
                for(String key : tempCustomSettingItem.split(';')){
                tempAttachmentsFields.add(key);
                }
            }
        }  
        queryObjectSectionsFields = ','+tempQueryPart.removeEnd(',');
        if (selectedAttachmentField != 'None' && objectName == selectedObject){
            currentObject = getObjectUsingId(objectId);
            
        } else if (selectedAttachmentField != 'None' && objectName != selectedObject && selectedRelatedRecord != 'None' && attachments.size() > 0) {
            currentObject = getObjectUsingId(selectedRelatedRecord);
        } 
        for (String s : tempAttachmentsFields){
            if (selectedAttachment == String.valueOf(currentObject.get(s))){
                currentFieldValue = s;
                return false;
            }
            
        }

        return true;
    }
    
    public Boolean getDisablePrevious(){
        if(offsetSize>0){
            return false;
        }
        else return true;
    }

    public Boolean getDisableNext() {
        if (offsetSize + queryLimit < countTotalRecords){
            return false;
        }
        else return true;
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
    
    public PageReference back(){
        PageReference pageRef = new PageReference('/'+objectId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}