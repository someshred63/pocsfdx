/**
* @author GFRS Dev Team
* @date 20/08/2013
* @description controller for gFRS_FileAttachments VF page
*/
public with sharing class gFRS_FileAttachmentsController {
    
    public static final String MEET_AGENDA_FLD = 'Meeting_Agenda__c';
    
    public static final String LETTER_REQ_FLD = 'Letter_of_Request__c';
    
    public static final String IMPL_PLAN_FLD = 'Implementation_Plan__c';
    
    public static final String NEED_ASSES_FLD = 'Needs_Assessment_Document__c';
    
    public static final String PROMO_ADVERT_FLD = 'Promotional_Event_Advertising__c';
    
    public static final String FEL_PROJ_DESC_FLD = 'Fellowship_Project_Description__c';
    
    public static final String QUERY = 'SELECT {0} FROM GFRS_Funding_Request__c WHERE Id = {1} LIMIT 1';
    
    public static final Map<String, Set<String>> REQ_FLDS = new Map<String, Set<String>>{
        MEET_AGENDA_FLD => new Set<String>{
            gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO,
            gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS,
            gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS,
            gFRS_Util.TYPE_IMED
        },
        PROMO_ADVERT_FLD => new Set<String>{ 'true' },
        LETTER_REQ_FLD => new Set<String>{ 'true' },
        FEL_PROJ_DESC_FLD => new Set<String>{
            gFRS_Util.TYPE_SCIENTIFIC_PROJECTS,
            gFRS_Util.TYPE_FELLOWSHIPS
        },
        NEED_ASSES_FLD => new Set<String>{
            gFRS_Util.TYPE_IMED
        },
        IMPL_PLAN_FLD => new Set<String>{
            gFRS_Util.TYPE_IMED
        }
    };
    
    public static final Map<String, String> REQ_FLD_ERRS = new Map<String, String>{
        IMPL_PLAN_FLD => System.Label.gFRS_ERROR_IMPLEMENTATION_PLAN_REQUIRED,
        MEET_AGENDA_FLD => System.Label.gFRS_ERROR_MEETING_AGENDA_REQUIRED,
        NEED_ASSES_FLD => System.Label.gFRS_ERROR_NEEDS_ASSESMENT_REQUIRED,
        FEL_PROJ_DESC_FLD => System.Label.gFRS_ERROR_FELLOWSHIP_REQUIRED,
        PROMO_ADVERT_FLD => System.Label.gFRS_ERROR_PROMO_REQUIRED,
        LETTER_REQ_FLD => System.Label.gFRS_ERROR_LOA_REQUIRED
    };
    
    public static final Set<String> QUERY_FLDS = new Set<String>{
        '(SELECT CreatedDate, Name FROM Attachments)',
        'Benefits_Exchanged_for_Funding__c',
        'RecordType.DeveloperName',
        'Information_Needed__c',
        'Record_Type_Name__c',
        'External_Sub_status__c',
        'Location__c',
        'Foundation_Classified__c',
        'Sub_Status__c'
    };
    
    public final GFRS_Funding_Request__c fundingRequest { get; private set; }
    
    public final Map<String, Attachment> attachments { get; private set; }
    
    public final Boolean isInternalRequest { get; private set; }
    
    public final Boolean isEditable { get; private set; }
    
    public Boolean isInitialized { get; private set; }
    
    /**
     * Indicates whether the 'Corporate Memberships with Exhibit Opportunities' section can be shown
     **/
    public Boolean isCMEOShown {
        private set; get {
            return gFRS_Util.isCMEOShown(fundingRequest);
        }
    }
    
    public String title {
        private set; get {
            return Schema.SObjectType.GFRS_Funding_Request__c.fieldSets.FS_AllFileAttachments.label;
        }
    }
    /**
    * @author GFRS Dev Team
    * @date 20/08/2013
    * @description Public constructor
    */
    public gFRS_FileAttachmentsController(final ApexPages.StandardController stdCtrl) {
        try {
            attachments = new Map<String, Attachment>();
            fundingRequest = Database.query(String.format(QUERY, new String[]{
                String.join(new String[]{
                    String.join(new List<String>(QUERY_FLDS), ', '), String.join(getAttachmentFields(), ', ')
                }, ', '),
                '\'' + stdCtrl.getId() + '\''
            }));
            isInternalRequest = gFRS_Util.isInternalRequest(fundingRequest.Record_Type_Name__c);
            isEditable = gFRS_Util.multiSelectHasItem(
                fundingRequest.Information_Needed__c,
                gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS
            );
            if (isEditable == null && fundingRequest.Sub_Status__c.equals('RFI') && fundingRequest.External_Sub_status__c.equals('RFI')) isEditable = true;
            final GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector(fundingRequest.Attachments);
            for (String fldName : getAttachmentFields()) {
                attachments.put(fldName, attachmentCollector.getFoundAttachmentByKeyOrMakeOne(
                    '' + fundingRequest.get(fldName), fundingRequest.Id
                ));
            }
        } catch (QueryException e) {
            fundingRequest = (GFRS_Funding_Request__c) stdCtrl.getRecord();
            isInternalRequest = isEditable = false;
            ApexPages.addMessages(e);
            System.debug(LoggingLevel.ERROR, 'Query exception ' + e.getMessage());
        } finally {
            isInitialized = false;
        }
    }
    
    private String[] getAttachmentFields() {
        final String[] result = new String[]{ };
        final Schema.DescribeSObjectResult fundReqDesc = Schema.SObjectType.GFRS_Funding_Request__c;
        for (Schema.FieldSetMember fld : fundReqDesc.fieldSets.getMap().get('FS_AllFileAttachments').getFields()) {
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
                    fundingRequest.put(fldName, gFRS_AttachmentUploadUtil.uploadAttachment(
                        fundingRequest.Id, fundingRequest.Id, fldName, attachments.get(fldName),
                        gFRS_Util_NoShare.checkIsRFI(fundingRequest.Id)
                    ).Id);
                } catch (Exception e) {
                    System.debug(LoggingLevel.ERROR, 'Upload error : '+e.getMessage());
                } finally {
                    attachments.get(fldName).Body = null;
                }
            }
        }
        isInitialized = true;
    }
    
    /**
    * @author GFRS Dev Team
    * @date 26/08/2013
    * @description back method - moves back a page
    */
    public ApexPages.PageReference back() {
        return new ApexPages.PageReference(gFRS_Util.initializeLink(gFRS_Util.canAccessPage(
            fundingRequest.Record_Type_Name__c, gFRS_Util.PATH_BUDGET
        ) ? gFRS_Util.PATH_BUDGET : gFRS_Util.PATH_PROGRAM, fundingRequest, null));
    }
    
    /**
    * @author GFRS Dev Team
    * @date 20/08/2013
    * @description saveFileAttachments method - save method for File Attachments page
    */
    public ApexPages.PageReference saveFileAttachments() {
        if (isCMEOShown && String.isBlank(attachments.get(MEET_AGENDA_FLD).Name)) {
            ApexPages.addMessages(new StringException(System.Label.gFRS_ERROR_MEETING_AGENDA_REQUIRED));
        }
        if(gFRS_Util.isInternalRequest(fundingRequest.Record_Type_name__c)){
            return ApexPages.hasMessages() || validateSave() ? null : new ApexPages.PageReference(gFRS_Util.initializeLink(
                gFRS_Util.PATH_CONFIRMATION, fundingRequest, null
            )); 
        }
        else{
            if(this.fundingRequest.Foundation_Classified__c == 'FALSE'){
                return ApexPages.hasMessages() || validateSave() ? null : new ApexPages.PageReference('/apex/gFRS_ACHData?id=' + fundingRequest.Location__c + '&fundingreq=' + fundingRequest.id);
            }
            else{
                return ApexPages.hasMessages() || validateSave() ? null : new ApexPages.PageReference(gFRS_Util.initializeLink(
                gFRS_Util.PATH_CONFIRMATION, fundingRequest, null
                ));
            }
        }
    }
    
    /**
    * @author GFRS Dev Team
    * @date 21/08/2013
    * @description validateSave method - validates 'File Attachments' section before submission
    */
    private Boolean validateSave() {
        if (fundingRequest == null || fundingRequest.Id == null) {
            ApexPages.addMessages(new StringException(System.Label.gFRS_ERROR_INVALID_FUND_REQ));
        } else {
            for (String fldName : REQ_FLDS.keySet()) {
                if (attachments.containsKey(fldName) &&
                    REQ_FLD_ERRS.containsKey(fldName) &&
                    String.isBlank(attachments.get(fldName).Name) && (
                    REQ_FLDS.get(fldName).contains(String.valueOf(isInternalRequest)) ||
                    REQ_FLDS.get(fldName).contains(fundingRequest.RecordType.DeveloperName)
                )) {
                    ApexPages.addMessages(new StringException(REQ_FLD_ERRS.get(fldName)));
                }
            }
        }
        return ApexPages.hasMessages();
    }
}