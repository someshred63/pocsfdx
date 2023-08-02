/**
* @author GFRS Dev Team
* @date 02/07/2013
* @description gFRS_ReconciliationController class - controller for GFRS_Reconciliation page. Class is responsible for handling request from page and communication with database. 
*/
public with sharing class gFRS_ReconciliationController {
    
    /** The type of page this is **/
    public static final String CONTENT_TYPE                           = 'Reconciliation';
    
    private static final String FINAL_AGENDA_API_NAME                 = 'Final_Agenda__c';
    public String getFINAL_AGENDA_API_NAME() {
		return FINAL_AGENDA_API_NAME;
	}
    private static final String FINAL_HANDOUT_WEB_SCREENSHOT_API_NAME = 'Final_Handout_Web_Screenshot__c';
    public String getFINAL_HANDOUT_WEB_SCREENSHOT_API_NAME() {
		return FINAL_HANDOUT_WEB_SCREENSHOT_API_NAME;
	}
    private static final String OTHER_PROGRAM_MATERIALS_API_NAME      = 'Other_Program_Materials__c';
    public String getOTHER_PROGRAM_MATERIALS_API_NAME() {
		return OTHER_PROGRAM_MATERIALS_API_NAME;
	}
    
    public Map<String,Attachment> apiNameToAttachmentMap {get;set;} 
	public String apiName {get;set;}
    
    private static final String FUNDING_REQUEST_API_NAME              = 'gFRS_Funding_Request__c';
    private static final String RECONCILIATION_PAGE_NAME              = 'Reconciliation';
    
    /** Page to move to when close **/  
    public static final String PATH_HOME                              = '/apex/gFRS_Home';

    public Map<String,String> contentItems { get; set; }    
    public GFRS_Funding_Request__c request { get; set; }
    public GFRS_Program__c lastProgram     { get; set; }
    
    public static final String ERROR_FINAL_AGENDA_REQUIRED            = 'Final Agenda is required';
    public static final String ERROR_FINAL_HANDOUT_REQUIRED           = 'Final Handout/WEb Screenshot is required';
    public static final String ERROR_OTHER_PROGRAM_MATERIALS_REQUIRED = 'Other Program Materials is required';
       
    /** Is form should be editable or not  **/  
    public Boolean isEditable { get; set; }    
    
    public Boolean isSrollDown                 { get; set; }
    public Boolean isSubmited                  { get; set; }
    public Boolean isValidationError           { get; set; }
    public Boolean displayReminderPopup			{ get; set; }
    public String reconciliationInstructions   { get{ return( this.contentItems.get('Reconciliation instructions')); }}
    public String reconciliationMailingAddress { get{ return( this.contentItems.get('Reconciliation mailing address')); }}

    public String fieldApiName { get; set; }
    public String fieldLabel   { get; set; }
    
    GFRS_AttachmentCollector attachmentCollector;
    Map<String,String> apiNameToLabelMapFundingRequest;
    Map<String,String> apiNameToLabelMapOrganization;

    public String  refundDate { get; set; }
    
    public String[] topFieldSet {
        get {
            return( new String[]{ 'Grant_Only_Used_for_Activity_Detailed__c',
                'Reason_Funds_Not_Used_as_Intended__c',
                'Total_Amount_Used__c',
                'Program_Changes_if_any__c',
                'Description_of_How_the_Funds_were_Used__c' } );
        }
    }

    public gFRS_ReconciliationController( ApexPages.StandardController std ){
        isSrollDown       = false;
        isValidationError = false;
        displayReminderPopup =false;
        request           = (GFRS_Funding_Request__c)std.getRecord();
        contentItems      = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );
        refreshRequest();
        
        
        if( this.request.Refund_Due__c > 0 || !(this.request.Total_Amount_Used__c != null && this.request.Total_Amount_Used__c > 0 )){
            this.isEditable = true;
        } else {
            this.isEditable = false;
        }
         //-- organize attachments
        this.apiNameToAttachmentMap = new Map<String,Attachment>();
        GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( this.request.Attachments );
    	apiNameToAttachmentMap.put(FINAL_AGENDA_API_NAME,attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Final_Agenda__c, this.request.id ));
    	apiNameToAttachmentMap.put(FINAL_HANDOUT_WEB_SCREENSHOT_API_NAME,attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Final_Handout_Web_Screenshot__c, this.request.id ));
    	apiNameToAttachmentMap.put(OTHER_PROGRAM_MATERIALS_API_NAME,attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Other_Program_Materials__c, this.request.id ));
    	
        apiNameToLabelMapFundingRequest = gFRS_Util_NoShare.getFieldLabelsMapForGivenObject(FUNDING_REQUEST_API_NAME);
    }
    
    /**
     *  Refresh the request (to update formula field values)
     *  <p>POST-CONDITION: this.request is refreshed</p>
     **/
    private void refreshRequest(){
        try {
            this.request = [SELECT 
                    Id,
                    Name, Event_Program_Title__c,
                    Is_Reconciliation_In_RFI__c,
                    Approved_Amount__c,
                    Total_Amount_Used__c,
                    Refund_Due__c,
                    Refund_Request_Date__c,
                    Description_of_How_the_Funds_were_Used__c,
                    Refunded_Amount__c ,
                    Grant_Only_Used_for_Activity_Detailed__c,
                    Reason_Funds_Not_Used_as_Intended__c,
                    Program_Changes_if_any__c,
                    Record_Type_Name__c,
                    Final_Agenda__c,
                    Final_Agenda_URL__c,
                    Final_Handout_Web_Screenshot__c,
                    Final_Handout_Web_Screenshot_URL__c,
                    Other_Program_Materials__c,
                    Other_Program_Materials_URL__c,
                    Reconciliation_Completed__c,
                    (SELECT Id, ParentId, Name, CreatedDate, Description FROM Attachments)
                    
                FROM GFRS_Funding_Request__c
                WHERE Id = :this.request.id
                LIMIT 1
               ];
            this.refundDate = '';
            if(request != null && request.Refund_Request_Date__c != null){
                 this.refundDate = request.Refund_Request_Date__c.format();
            }
            if( this.request.Approved_Amount__c == null){
                ApexPages.addMessage(new ApexPages.message( ApexPages.severity.ERROR, System.Label.gFRS_ApprovedAmountNotFound ));
                return;
            }
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_UnadbleToFindFR ));
            return;
        }

        try {
            this.lastProgram = [
                SELECT End_Date__c
                FROM GFRS_Program__c
                WHERE Funding_Request__c = :this.request.id
                ORDER BY End_Date__c DESC
                LIMIT 1
               ];
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_UnableToFindProgram ));
            return;
        }
    }
    
    //-- attachment methods
	public void uploadAttachment() {
		this.isSrollDown            = true; 
        this.isValidationError      = false;
		Boolean createNewAttachment = false;
		if(gFRS_Util_NoShare.checkIsReconciliationPageInRFI(this.request.Id)){
			//Funding Request is in RFI state
			if(this.apiNameToAttachmentMap.get(apiName).Id == null){
				//File does not exists
				createNewAttachment = true;
			}else{
				createNewAttachment = (this.apiNameToAttachmentMap.get(apiName).CreatedDate < gFRS_Util_NoShare.getRfiDateByActionType(this.request.Id, RECONCILIATION_PAGE_NAME))?true:false;	
			}	
		}else{
			//Funding Request is not in RFI
			if(this.apiNameToAttachmentMap.get(apiName).Id == null){
				createNewAttachment = true;	
			}else{
				createNewAttachment = false;
			}
		}
		uploadFundingRequestAttachment(apiName, apiNameToLabelMapFundingRequest.get(apiName.toLowerCase()), createNewAttachment);
	}
	
	
    

  
    /**
    * @author GFRS Dev Team 
    * @date 04/07/2013
    * @description Save method for Reconciliation page. 
    */
    public ApexPages.Pagereference savePage() {

        this.isSrollDown       = true;
        this.isValidationError = false;
        
        if (this.request.Approved_Amount__c == null) {
            this.isValidationError = true;
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, System.Label.gFRS_AmountFundedNotFound) );
            return ( null );
        }
        if (this.request.Total_Amount_Used__c > this.request.Approved_Amount__c) {
            this.isValidationError = true;
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, System.Label.gfrs_totalAmountUsedGTApprovedAmount) );
            return ( null );
        }
        if (this.request.Total_Amount_Used__c < 0) {
            this.isValidationError = true;
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, System.Label.gfrs_totalAmountUsedLTZero) );
            return ( null );
        }
        if(this.request.Grant_Only_Used_for_Activity_Detailed__c == null || this.request.Grant_Only_Used_for_Activity_Detailed__c == ''){
             ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, Schema.sObjectType.gFRS_Funding_Request__c.fields.Grant_Only_Used_for_Activity_Detailed__c.getLabel() + '?' + System.Label.gFRS_YouMustEnterValue));
             this.isValidationError = true;
        }
        if(this.request.Total_Amount_Used__c == null)
        {
             ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, Schema.sObjectType.gFRS_Funding_Request__c.fields.Total_Amount_Used__c.getLabel() + '?' + System.Label.gFRS_YouMustEnterValue));
             this.isValidationError = true;
        }
        if(this.request.Description_of_How_the_Funds_were_Used__c == null || this.request.Description_of_How_the_Funds_were_Used__c == '')
        {
             ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, Schema.sObjectType.gFRS_Funding_Request__c.fields.Description_of_How_the_Funds_were_Used__c.getLabel() + '?' + System.Label.gFRS_YouMustEnterValue));
             this.isValidationError = true;
        }
        
        
        if(this.isValidationError)
        {
            return null;
        }
        if(gFRS_Util.TYPE_IMED_NAME.equals( this.request.Record_Type_Name__c ) && isSubmited)
        {
            if(this.apiNameToAttachmentMap.get(FINAL_AGENDA_API_NAME).name == null){
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, ERROR_FINAL_AGENDA_REQUIRED ));
                this.isValidationError = true;
                return (null);
            }
            if(this.apiNameToAttachmentMap.get(FINAL_HANDOUT_WEB_SCREENSHOT_API_NAME).name == null){
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR,ERROR_FINAL_HANDOUT_REQUIRED ));
                this.isValidationError = true;
                return (null);
            }
        }
        try {
            request.IsValidationExternalOnly__c = gFRS_Util.YES;
            update this.request;
            this.refreshRequest();
        } catch (DMLException e) {
            this.isValidationError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, gFRS_Util.getPrettyMessage(e)));
        }

        return (null);
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 04/07/2013
    * @description  closePage method - handler of 'Submit' button click.
    */    
    public ApexPages.Pagereference closePage(){

        this.isSubmited        = true;
        this.isValidationError = false;
 
         this.request.Other_Program_Materials__c      = this.apiNameToAttachmentMap.get(OTHER_PROGRAM_MATERIALS_API_NAME).Id;
         this.request.Final_Handout_Web_Screenshot__c = this.apiNameToAttachmentMap.get(FINAL_HANDOUT_WEB_SCREENSHOT_API_NAME).Id;
         this.request.Final_Agenda__c                 = this.apiNameToAttachmentMap.get(FINAL_AGENDA_API_NAME).Id;
         this.request.Is_Reconciliation_In_RFI__c     = false;
         
         this.request.Reconciliation_Completed__c     = gFRS_Util.YES;
        
        ApexPages.PageReference pageRef = savePage();
        if( !ApexPages.hasMessages() ){
            //return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_HOME, null, null ) ));
            this.displayReminderPopup = true;
            return( null );
        } else {
            return( null );
        }
    }

    
    /**
    * @author GFRS Dev Team 
    * @date 22/08/2013
    * @description  checkIfRedirect method - check if user should be redirected to Status Report page
    */ 
    //GFRS-900 -> will not be used - logic moved to JS in GFRS_Home  
    /*public ApexPages.Pagereference checkIfRedirect(){
        if(this.request != null && this.request.id != null && new List<GFRS_Program__c>([select Id from gFRS_Program__c where Funding_Request__r.id =: this.request.id and (Program_Status__c = 'Planned' or Program_Status__c = 'Confirmed') and End_Date__c<TODAY]).size()>0){
            return( new ApexPages.PageReference(gFRS_Util.initializeLink( '/apex/GFRS_Status_Report', this.request, 'showSecondSection=true' ) ));
         }
         return null;
    }*/
    
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description uploadFundingRequestAttachment method - generic method for uploads of attachments for gFRS Funding Request object. 
    */
    
    public void uploadFundingRequestAttachment(String fieldApiName, String fieldLabel, Boolean createNewAttachment){
		Attachment newAttachment;
		try{
			if(createNewAttachment){
				newAttachment = new Attachment( ParentId = this.request.id, Name = this.apiNameToAttachmentMap.get(fieldApiName).Name, Description = fieldLabel );
				newAttachment.Body = this.apiNameToAttachmentMap.get(fieldApiName).Body;
				gFRS_Util_NoShare.saveLockedAttachment( newAttachment );

				newAttachment.body = null;
			}else{
				newAttachment = upsertFundingRequestAttachment(fieldApiName, fieldLabel);		
				newAttachment.Body = null;
			}
			GFRS_Funding_Request__c partial = [ select Id from GFRS_Funding_Request__c where id = :this.request.Id ];
			partial.put(fieldApiName,newAttachment.id);
			gFRS_Util_NoShare.saveLockedFundingRequest(partial);
			
			refreshFundingRequestAttachment(fieldApiName, newAttachment.Id);
		}catch( Exception err ){
			ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
		} finally {
			if (newAttachment != null) newAttachment.body = null;
		}
	}
    
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description refreshAttachment method - refreshes data of currently uploaded file
    */
    private void refreshFundingRequestAttachment(String fieldApiName, Id attachmentId){
        Attachment attachmentToRefresh = [ select Id, ParentId, Name, Description, CreatedDate from Attachment where Id = :attachmentId];
		attachmentToRefresh.Body = null;
		this.apiNameToAttachmentMap.put(fieldApiName,attachmentToRefresh);
		
		this.request.put(fieldApiName, attachmentToRefresh.Id);
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description upsertFundingRequestAttachment method - Upserts appropriate attachments used when we don't want to keep previous attachment in history. 
    */
    private Attachment upsertFundingRequestAttachment(String fieldApiName, String fieldLabel){
    	Attachment tempAtt = this.apiNameToAttachmentMap.get(fieldApiName);
		tempAtt.Description = fieldLabel;
		this.apiNameToAttachmentMap.put(fieldApiName,tempAtt);
		upsert this.apiNameToAttachmentMap.get(fieldApiName);	
		return this.apiNameToAttachmentMap.get(fieldApiName);
    }
    

}