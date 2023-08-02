/**
* @author GFRS Dev Team
* @date 02/06/2015
* @description gFRS_SunshineDataController class - controller for gFRS_SunshineData page. Class is responsible for handling request from page and communication with database. 
*/
public with sharing class gFRS_SunshineDataController {
  
    public Attachment sunshineReport                          { get; set; }
    public GFRS_Funding_Request__c request                    { get; set; }
    public boolean hideSunshineReportPanel                    {get; set;}
    
    private static final String SUNSHINE_REPORT_API_NAME      = 'Sunshine_Report__c';
    private static final String FUNDING_REQUEST_API_NAME      = 'gFRS_Funding_Request__c';
    public static final String ERROR_SUNSHINE_REPORT_REQUIRED = 'Physician Meals Report is required';
    public static final String PATH_HOME                      = '/apex/gFRS_Home';
    

    public Attachment oldAttachment;
    Map<String,String> apiNameToLabelMapFundingRequest;
    
    public String[] sunshineFieldSet {
        get {
            return( new String[]{ 'Funds_Used_To_Provide_Meals__c'} );
        }
    }
    public String[] sunshineFieldSetSciFellow {
        get {
            return( new String[]{ 'Funds_to_Teaching_Hospital_or_Physician__c'} );
        }
    }   
    
    
    /**
    * @author GFRS Dev Team 
    * @date 02/06/2015
    * @description Public constructor
    */ 
    public gFRS_SunshineDataController(ApexPages.StandardController std){
      
        this.request = (GFRS_Funding_Request__c)std.getRecord();
        this.refreshRequest();
        
        GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( this.request.Attachments );
        this.sunshineReport                          = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Sunshine_Report__c, this.request.Id );
        apiNameToLabelMapFundingRequest              = gFRS_Util_NoShare.getFieldLabelsMapForGivenObject(FUNDING_REQUEST_API_NAME);
                
        this.hideSunshineReportPanel = False;
        if( (this.request.Funding_Type__c == 'Scientific Project Support' || this.request.Funding_Type__c == 'Fellowships')
                && (String.isBlank(this.request.Funds_to_Teaching_Hospital_or_Physician__c) || this.request.Funds_to_Teaching_Hospital_or_Physician__c != gFRS_Util.YES)){
            hideSunshineReportPanel = True;
        }else{
            hideSunshineReportPanel = False;
        }
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 02/06/2015
    * @description  refreshRequest method - retives current Funding Request
    */   
    private void refreshRequest(){
        this.request = [SELECT 
                    Id,
                    Name, Record_Type_Name__c,
                    Funds_to_Teaching_Hospital_or_Physician__c,
                    Funds_Used_To_Provide_Meals__c, 
                    Sunshine_Report__c, 
                    Event_Program_Title__c,
                    Reconciliation_Completed__c,
                    Sunshine_Communication_Sent__c,
                    Closed_Date__c, Funding_Type__c,
                    (SELECT Id, ParentId, Name, CreatedDate, Description FROM Attachments)
                    
                FROM GFRS_Funding_Request__c
                WHERE Id = :this.request.id
                LIMIT 1
               ];
    }
    
     /**
    * @author GFRS Dev Team 
    * @date 04/07/2013
    * @description savePage method - handler of 'Submit' button click.
    */    
    public ApexPages.Pagereference savePage(){

        this.request.Sunshine_Report__c                   = this.sunshineReport.Id;
        this.request.Sunshine_Act_Disclosure_Submitted__c = gFRS_Util.YES;
        
        //TODO: gFRS-900: check if Reconciliation Task has been triggered
        if ([select id from gFRS_Tasks__c where gFRS_Funding_Request__c=:this.request.Id and Action_Type__c='Reconciliation'].size()>0) {
          //  YES:check if Reconciliation has been submitted
          if (this.request.Reconciliation_Completed__c=='Yes') {
            //    YES:  sub-status = Manager review
            this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_MANAGER_REVIEW;
          } else {
            //    NO:   sub-status = Reconciliation !!!careful not to trigger the task again!!!
            this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ; //modified the condition in trigger to check Reconciliation_Required_Status_Date__c -> task should not be created again
            this.request.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ;
          }
        } else {
          //  NO:  if sunshine has been reopened and reconciliation completed
          if (this.request.Reconciliation_Completed__c=='Yes' && this.request.Sunshine_Communication_Sent__c==true) {
            if (this.request.Closed_Date__c != null) { //sunshine reopened after the request has been closed
              this.request.Status__c = gFRS_Util.REQUEST_STATUS_CLOSED;
              this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_APPROVED;
              this.request.External_Sub_status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
            } else {
            this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_MANAGER_REVIEW;
            this.request.External_Sub_status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
            }
          } else {
                if(this.request.Record_Type_Name__c == 'IMED'){
                    //sub-status = Approved Status Updates/Outcomes
                    System.debug('setting to approved stat outcomes');
                    this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES;
                    this.request.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES;
                } else {
                    this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                    this.request.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
                }
        }
        }
        
        this.request.Sunshine_Communication_Sent__c       = false;
        
        if( this.request.Funds_Used_To_Provide_Meals__c == gFRS_Util.YES && this.sunshineReport.name == null){
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, ERROR_SUNSHINE_REPORT_REQUIRED ));
            return null;
        }
        
        if( this.request.Funds_to_Teaching_Hospital_or_Physician__c == gFRS_Util.YES && this.sunshineReport.name == null){
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, 'Please upload the completed report' ));
            return null;
        }       
        
        if( !ApexPages.hasMessages() ){
          
          try {
                if( (this.request.Funding_Type__c == 'Scientific Project Support' || this.request.Funding_Type__c == 'Fellowships')
                    && this.request.Funds_to_Teaching_Hospital_or_Physician__c == gFRS_Util.NO){
                    this.request.Sunshine_Report__c                   = '';
                    list<Attachment> attachmentToRefresh = new list<Attachment>();
                    attachmentToRefresh = [ SELECT Id, ParentId, Name, Description, CreatedDate FROM Attachment WHERE Id = :this.sunshineReport.Id];
                    if(attachmentToRefresh.size() > 0){
                        gFRS_Util_NoShare.deleteLockedAttachments(attachmentToRefresh);
                    }
                }
                update this.request;
                if(this.request.Record_Type_Name__c != 'IMED'){
                    gFRS_Tasks__c task = [Select Id FROM gFRS_Tasks__c WHERE gFRS_Funding_Request__c =:this.request.Id and Action_Type__c =: gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE];
                    gFRS_Util_NoShare.removeTask(task);
                }
          } catch (DMLException e) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, gFRS_Util.getPrettyMessage(e)));
          }
        
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_HOME, null, null ) ));
        }

        return null;
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description uploadSunshineReport method - upload handler for Sunshine Report
    */
    public void uploadSunshineReport(){
      
        Boolean createNewAttachment = false;

        if(gFRS_Util_NoShare.checkIsSunshineCommunicationSent(this.request.Id)){
            //Communication was send
            if(this.sunshineReport.Id == null){
                //File does not exists
                createNewAttachment = true;
            }else{
              
                createNewAttachment = (this.sunshineReport.CreatedDate < gFRS_Util_NoShare.getRfiDateByActionType(this.request.Id, gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE))?true:false;   
            }   
        }else{
            //Communication was not send
            if(this.sunshineReport.Id == null){
                createNewAttachment = true; 
            }else{
                createNewAttachment = false;
            }
        }

        uploadFundingRequestAttachment(SUNSHINE_REPORT_API_NAME, apiNameToLabelMapFundingRequest.get(SUNSHINE_REPORT_API_NAME.toLowerCase()), createNewAttachment); 
    }
    
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description uploadFundingRequestAttachment method - generic method for uploads of attachments for gFRS Funding Request object. 
    */
    public void uploadFundingRequestAttachment(String fieldApiName, String fieldLabel, Boolean createNewAttachment){
      
        Attachment newAttachment;
        try{
            if(createNewAttachment){
                assignFundingRequestAttachmentForProcessing(fieldApiName);
                newAttachment      = new Attachment( ParentId = this.request.Id, Name = this.oldAttachment.Name, Description = fieldLabel );
                newAttachment.Body = oldAttachment.Body;
                gFRS_Util_NoShare.saveLockedAttachment( newAttachment );

                newAttachment.body = null;
                oldAttachment.body = null;
            }else{
                newAttachment = upsertFundingRequestAttachment(fieldApiName, fieldLabel);       
                newAttachment.Body = null;
            }
            
            GFRS_Funding_Request__c partial = [ SELECT Id FROM GFRS_Funding_Request__c WHERE Id = :this.request.Id ];
            partial.put(fieldApiName, newAttachment.id);
            gFRS_Util_NoShare.saveLockedFundingRequest(partial);

            refreshFundingRequestAttachment(fieldApiName, newAttachment.Id);
        }catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
        } finally {
          if (newAttachment != null && newAttachment.body!=null) newAttachment.body = null;
          if (oldAttachment != null && oldAttachment.body!=null) oldAttachment.body = null;
          if (this.sunshineReport != null && this.sunshineReport.Body!=null) this.sunshineReport.Body = null;
        }
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 11/03/2014
    * @description  clearSunshineReportName method - we have to clear SunshineReport Name when attachment extension is incorrect - bug SFDC-3775
    */ 
    public void clearSunshineReportName(){
        this.sunshineReport.Name = null;
        this.sunshineReport.Body = null;      
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description refreshAttachment method - refreshes data of currently uploaded file
    */
    private void refreshFundingRequestAttachment(String fieldApiName, Id attachmentId){
        Attachment attachmentToRefresh = [ SELECT Id, ParentId, Name, Description, CreatedDate FROM Attachment WHERE Id = :attachmentId];
        if(fieldApiName == SUNSHINE_REPORT_API_NAME){
            this.sunshineReport      = attachmentToRefresh;
            this.sunshineReport.Body = null;    
        }
        
        this.request.put(fieldApiName, attachmentToRefresh.Id);
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description upsertFundingRequestAttachment method - Upserts appropriate attachments used when we don't want to keep previous attachment in history. 
    */
    private Attachment upsertFundingRequestAttachment(String fieldApiName, String fieldLabel){
        if(fieldApiName == SUNSHINE_REPORT_API_NAME){
            this.sunshineReport.Description = fieldLabel;
            upsert this.sunshineReport; 
            return this.sunshineReport; 
        }
        
        return null;
    }
    
    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description assignFundingRequestAttachmentForProcessing method - assign appropriate attachment for processing during file upload
    */
    private void assignFundingRequestAttachmentForProcessing(String fieldApiName){
        if(fieldApiName == SUNSHINE_REPORT_API_NAME){
            this.oldAttachment = this.sunshineReport;   
        }
    }

    /**
    * @author GFRS Dev Team
    * @date 27/08/2019
    * @description manageSunshineReportPanel method - Hide or Shows SunshineReportPanel based on Funds_to_Teaching_Hospital_or_Physician__c value.
    */
    public void manageSunshineReportPanel(){
        if( (this.request.Funding_Type__c == 'Scientific Project Support' || this.request.Funding_Type__c == 'Fellowships')
                    && (String.isBlank(this.request.Funds_to_Teaching_Hospital_or_Physician__c) || this.request.Funds_to_Teaching_Hospital_or_Physician__c != gFRS_Util.YES)){
            hideSunshineReportPanel = True;
        }else{
            hideSunshineReportPanel = False;
        }
    }
}