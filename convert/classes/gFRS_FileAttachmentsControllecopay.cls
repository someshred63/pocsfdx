/**
* @author GFRS Dev Team
* @date 20/08/2013
* @description controller for gFRS_FileAttachments VF page
*/
public with sharing class gFRS_FileAttachmentsControllecopay {
    
    public static final String PATH_PREVIOUS_PAGE = '/apex/GFRS_Applicationcopay';  /*to be updated*/  
    public static final String PATH_CONFIRMATION_PAGE = '/apex/GFRS_ConfirmationCoPay';
    
    public final gFRS_Copay_Funding_Request__c fundingRequest { get; private set; }
    public GFRS_Funding_Request__c fundingrequest1{get;set;}
    
    public final Map<String, Attachment> attachments { get; private set; }
    
    public Boolean isInitialized { get; private set; }
    public Boolean isInternalRequest { get; set; }
    public Boolean isEditable { get; set; }
    public boolean enabled{get; set;}
    public string w9AttachmentID = null;
    
    public static final Set<String> QUERY_FLDS = new Set<String>{
        '(SELECT Id,  CreatedDate, Name, Description FROM Attachments)',
            'Organization__c',
            'Organization_W_9__c',
            'Record_Type_Name__c',
            'Organization_Name__c',
            'Information_Needed__c',
            'Request_Creation_Progress__c',
            'Status__c'};
                
                public static final String QUERY = 'SELECT {0} FROM gFRS_Copay_Funding_Request__c WHERE Id = {1} LIMIT 1';
    
    public String title {
        private set; get {
            return Schema.SObjectType.gFRS_Copay_Funding_Request__c.fieldSets.Required_Documents.label;
        }
    }
    
    public gFRS_FileAttachmentsControllecopay(final ApexPages.StandardController stdCtrl) {
        try {
            attachments = new Map<String, Attachment>();
            this.fundingRequest = Database.query(String.format(QUERY, new String[]{
                String.join(new String[]{
                    String.join(new List<String>(QUERY_FLDS), ', '), String.join(getAttachmentFields(), ', ')
                        }, ', '),
                    '\'' + stdCtrl.getId() + '\''
                    }));
            
            final GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector(fundingRequest.Attachments);
            
            for (String fldName : getAttachmentFields()) {
                attachments.put(fldName, attachmentCollector.getFoundAttachmentByKeyOrMakeOne(
                    '' + fundingRequest.get(fldName), fundingRequest.Id
                ));
                
            }
            
            enabled = false;
            this.isInternalRequest = gFRS_Utilcopay.isInternalRequest(this.fundingRequest.Record_Type_Name__c);
            this.iseditable = true;
            if(this.fundingRequest.Status__c == null || this.fundingRequest.Status__c == 'Intake' ){
                enabled = true;
            }
            else
            {
                enabled = gFRS_Util.multiSelectHasItem(fundingRequest.Information_Needed__c,gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS);    
            }
        } catch (QueryException e) {
            fundingRequest = (gFRS_Copay_Funding_Request__c) stdCtrl.getRecord();
            ApexPages.addMessages(e);
        } finally {
            this.isInitialized = true;
            
        }
        
        
    }
    
    private String[] getAttachmentFields() {    
        final String[] result = new String[]{ };
            final Schema.DescribeSObjectResult fundReqDesc = Schema.SObjectType.gFRS_Copay_Funding_Request__c;
        for (Schema.FieldSetMember fld : fundReqDesc.fieldSets.getMap().get('Required_Documents').getFields()) {
            result.add(fld.getFieldPath());
        }
        return result;
    }
    
    public void uploadAttachment() {
        for (String fldName : ApexPages.hasMessages() ? new Set<String>() : attachments.keySet()) {
            if (String.isNotBlank(attachments.get(fldName).Name)) {
                System.debug(LoggingLevel.ERROR, 'NAME: ' + attachments.get(fldName).Name);
            }
            if (attachments.get(fldName).Body != null &&
                String.isNotBlank(attachments.get(fldName).Name)
               ) {
                   System.debug(LoggingLevel.ERROR, 'BODY: ' + fldName + ': ' + attachments.get(fldName).Name);
                   try {
                       fundingRequest.put(fldName, gFRS_AttachmentUploadUtilcopay.uploadAttachment(
                           fundingRequest.Id, fundingRequest.Id, fldName, attachments.get(fldName),false).Id);//isRFI set to false
                   } catch (Exception e) {
                       System.debug(LoggingLevel.ERROR, 'Upload error : '+e.getMessage());
                   } finally {
                       attachments.get(fldName).Body = null;
                   }
               }
        }
        isInitialized = true;
    }
    
    public ApexPages.PageReference back() {
        return new ApexPages.PageReference(gFRS_Utilcopay.initializeLinkcopay('/apex/gFRS_AddDiseaseStateCopay', fundingRequest, null));
    }
    
    public ApexPages.PageReference saveFileAttachments() {
        
        uploadAttachment();
        if(this.fundingRequest.Request_Creation_Progress__c == 'Donation' && !(ApexPages.hasMessages() || validateSave())){
            this.fundingRequest.Request_Creation_Progress__c = 'Attachments';
            gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(this.fundingRequest);
        }
        return  ApexPages.hasMessages() || validateSave() ? null : new ApexPages.PageReference(gFRS_Utilcopay.initializeLinkcopay(PATH_CONFIRMATION_PAGE, fundingRequest, null));
        
    }
    
    public ApexPages.PageReference saveFileAttachmentsnext() {
        
        if(this.fundingRequest.Request_Creation_Progress__c == 'Donation'){
            this.fundingRequest.Request_Creation_Progress__c = 'Attachments';
            gFRS_Util_NoSharecopay.saveLockedFundingRequestcopay(this.fundingRequest);
        }
        return new ApexPages.PageReference(gFRS_Utilcopay.initializeLinkcopay(PATH_CONFIRMATION_PAGE, fundingRequest, null)); 
    }
    
    private Boolean validateSave() {
        if (fundingRequest == null || fundingRequest.Id == null) {
            ApexPages.addMessages(new StringException(System.Label.gFRS_ERROR_INVALID_FUND_REQ));
        }
        final Schema.DescribeSObjectResult fundReqDesc = Schema.SObjectType.gFRS_Copay_Funding_Request__c;
        for (Schema.FieldSetMember fldName : fundReqDesc.fieldSets.getMap().get('Required_Documents').getFields()) {
            if(String.isBlank(attachments.get(fldName.getFieldPath()).Name)){
                ApexPages.addMessages(new StringException(fldName.getLabel() + ' is required.'));
            }
        }
        return ApexPages.hasMessages();
        
    }
    
    public PageReference manageW9Attachment(){
        
        String AttchId = gFRS_Utilcopay.cloneOrgW9toCopay(this.fundingRequest);
        
        if(!String.isBlank(AttchId)){
            this.fundingRequest.W_9__c = AttchId;
          //  update this.fundingRequest;
            gFRS_Util_NoSharecopay.saveLockedFundingRequestInternalPagecopay(this.fundingRequest);
            
            //refreshing the page, changes uploaded are reflected
            PageReference tempPage = ApexPages.currentPage();            
            tempPage.setRedirect(true);
            return tempPage;
        }else{  
            return null;
        }
        
    }
}