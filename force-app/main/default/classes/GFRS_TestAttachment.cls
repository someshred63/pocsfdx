/**
 *  Test page to validate loading attachments
 **/
public with sharing class GFRS_TestAttachment {
    
    //-- lookup constants
    public static final String ATT_PATIENT_CARE = 'Patient_Care__c';
    
    public static final String EVALUATION_FORM_SURVEY = 'Evaluation_Form_Survey__c';
    
    //-- local variables
    /** funding request being used **/
    public GFRS_Funding_Request__c fundingRequest { get; set; }
    
    /** attachment to load **/
    public Attachment attPatientAttachment { get; set; }
    public Attachment evaluationAttachment { get; set; }
    
    public GFRS_TestAttachment( ApexPages.StandardController std ){
        this.fundingRequest = (GFRS_Funding_Request__c)std.getRecord();
        if( !isValidPage() ) return; //-- page should not be used if no funding request was used
        
        //-- ALWAYS select the individual fields (all of type Text(18)) and the attachments
        this.fundingRequest = [ select id, Patient_Care__c, Evaluation_Form_Survey__c,
            (select id,ParentID,name from Attachments)
            from GFRS_Funding_Request__c where id = :this.fundingRequest.id ];
        
        //-- attachment collector takes the attachments and allow us to find the matching attachments
        GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( this.fundingRequest.Attachments );
        //-- find the attachment that matches OR create a new attachment
        this.attPatientAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.fundingRequest.Patient_Care__c, this.fundingRequest.id );
        this.evaluationAttachment = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.fundingRequest.Evaluation_Form_Survey__c, this.fundingRequest.id );
    }
    
    /**
     *  Needs to be copied for each type of attachment since
     *  we cannot use field types, and there will be limits on the sizes of files to load.
     *  <p>Ugh</p>
     **/
    public void uploadPatientAttachment(){
        if( !isValidPage() ) return;
        
        upsert this.attPatientAttachment;
        this.attPatientAttachment.body = null;
        
        //-- update attachment field
        GFRS_Funding_Request__c tempFundingRequest = [ select id from GFRS_Funding_Request__c where id = :this.fundingRequest.id ];
        tempFundingRequest.Patient_Care__c = this.attPatientAttachment.id;
        update tempFundingRequest;
    }
    
    public void uploadEvaluationForm(){
        if( !isValidPage() ) return;
        
        upsert this.evaluationAttachment;
        this.evaluationAttachment.body = null;
        
        //-- update attachment field
        GFRS_Funding_Request__c tempFundingRequest = [ select id from GFRS_Funding_Request__c where id = :this.fundingRequest.id ];
        tempFundingRequest.Evaluation_Form_Survey__c = this.evaluationAttachment.id;
        update tempFundingRequest;
    }
    
    /** Method that saves everything **/
    public void uploadAll(){
        Attachment[] changedAttachments = new Attachment[]{
            this.attPatientAttachment,
            this.evaluationAttachment
        };
        upsert changedAttachments;
        
        //-- clear out the body otherwise the state will become too large
        for( Attachment a:changedAttachments ){
            a.body = null;
        }
        
        //-- update attachment field
        GFRS_Funding_Request__c tempFundingRequest = [ select id from GFRS_Funding_Request__c where id = :this.fundingRequest.id ];
        tempFundingRequest.Patient_Care__c = this.attPatientAttachment.id;
        tempFundingRequest.Evaluation_Form_Survey__c = this.evaluationAttachment.id;
        update tempFundingRequest;
    }
    
    /**
     *  Determines whether the page is valid to submit or not
     **/
    private Boolean isValidPage(){
        if( this.fundingRequest == null || this.fundingRequest.id == null ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Funding Request was not provided' ));
            return( false );
        } else {
            return( true );
        }
    }
}