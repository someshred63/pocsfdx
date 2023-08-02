/**
* @author GFRS Dev Team
* @date 31/10/2013    
* @description gFRS_ProgramController class - controller for GFRS_Program page. Class is responsible for handling request from page and communication with webservices and database. 
*/
public with sharing class gFRS_ProgramController {
    
    public static final String FIELD_NAME_REQUIRED = ' is required, please specify a value';
    public static final String PARAM_CONFIRMATION = 'confirm';
    public static final String PARAM_MESSAGE = 'message';
    public static final String PARAM_MESSAGEMULTI = 'multiple';
    public static final String PATH_CONFIRM = '' + PARAM_CONFIRMATION + '=' + PARAM_MESSAGE;
    public static final String PATH_CONFIRMMULTI = '' + PARAM_CONFIRMATION + '=' + PARAM_MESSAGEMULTI;
    
    public static final String TYPE_WEB = 'Web';
    public static final String TYPE_ENDURING = 'Enduring';
    public static final String TYPE_LIVE = 'Live';
    public static final String SUB_TYPE_GRAND_ROUNDS = 'Grand Rounds: Live';
    public static final String SUB_TYPE_MEETING_SERIES = 'Meeting Series: Live';
    public static final String FIELD_EXHIB_PROGRAM_TITLE = 'Exhibit Details';
    public static final String CORP_MEM_PROGRAM_TITLE = 'Corporate Membership Details';
    public static final String CORP_MEM_CMEO_PROGRAM_TITLE = 'Event Details';
    public static final String PROGRAM_TITLE = 'Program Details';
    

        private static final String MEETING_AGENDA_API_NAME = 'Meeting_Agenda__c';
        public String getMEETING_AGENDA_API_NAME() {
      return MEETING_AGENDA_API_NAME;
    }
        private static final String PROMOTIONAL_ADVERTISING_API_NAME = 'Promotional_Event_Advertising__c';
        public String getPROMOTIONAL_ADVERTISING_API_NAME() {
      return PROMOTIONAL_ADVERTISING_API_NAME;
    }
        private static final String ADDITIONAL_DOCUMENT_UPLOAD1_API_NAME = 'Additional_Document_Uploads__c';
        public String getADDITIONAL_DOCUMENT_UPLOAD1_API_NAME() {
      return ADDITIONAL_DOCUMENT_UPLOAD1_API_NAME;
    }
        private static final String ADDITIONAL_DOCUMENT_UPLOAD2_API_NAME = 'Additional_Document_Uploads_2__c';
        public String getADDITIONAL_DOCUMENT_UPLOAD2_API_NAME() {
      return ADDITIONAL_DOCUMENT_UPLOAD2_API_NAME;
    }
        private static final String ADDITIONAL_DOCUMENT_UPLOAD3_API_NAME = 'Additional_Document_Uploads_3__c';
        public String getADDITIONAL_DOCUMENT_UPLOAD3_API_NAME() {
      return ADDITIONAL_DOCUMENT_UPLOAD3_API_NAME;
    }
        private static final String ADDITIONAL_DOCUMENT_UPLOAD4_API_NAME = 'Additional_Document_Uploads_4__c';
        public String getADDITIONAL_DOCUMENT_UPLOAD4_API_NAME() {
      return ADDITIONAL_DOCUMENT_UPLOAD4_API_NAME;
    }
        private static final String ADDITIONAL_DOCUMENT_UPLOAD5_API_NAME = 'Additional_Document_Uploads_5__c';
        public String getADDITIONAL_DOCUMENT_UPLOAD5_API_NAME() {
      return ADDITIONAL_DOCUMENT_UPLOAD5_API_NAME;
    }
    
    private List<String> apiNamesList = new List<String> {
    MEETING_AGENDA_API_NAME, PROMOTIONAL_ADVERTISING_API_NAME, ADDITIONAL_DOCUMENT_UPLOAD1_API_NAME, 
    ADDITIONAL_DOCUMENT_UPLOAD2_API_NAME, ADDITIONAL_DOCUMENT_UPLOAD3_API_NAME, 
    ADDITIONAL_DOCUMENT_UPLOAD4_API_NAME, ADDITIONAL_DOCUMENT_UPLOAD5_API_NAME
  };
    public Map<String,Attachment> apiNameToAttachmentMap {get;set;} 
  public String apiName {get;set;}
    
    private static final String PROGRAM_API_NAME = 'GFRS_Program__c';
    
    public static final String TASK_ACTION_TYPE_RFI = 'RFI';
    
    //public Attachment testAttachment { get; set; }
    
    public static final String CONTENT_TYPE = 'Program';
    
    /** List of translations **/
    public Map<String,String> contentItems { get; set; }
    public String progDetail{get;set;}
    
    /** path to the confirmation page **/
    public static final String PATH_CONFIRMATION = '/apex/GFRS_Confirmation';
    
    
    /** Collection of programs for the funding request **/
    public GFRS_Program__c[] programs { get; set; }
    public Map<id,GFRS_Program__c> programsMap{get;set;}
    
    public String hcCharProgType{get;set;}
    public String fSubType{get;set;}
    public String startDateResp{get;set;}
    public String AlertResponse{get;set;}
    public Id ProgmId{get;set;}
    
    /** current funding Request **/
    public GFRS_Funding_Request__c request { get; set; }
    
    /** The record type of the object
     *  <p>separated out from the object to allow better handlign in case there is an error
     **/
    public String recordTypeName { get; set; }
    /** all related attendees**/
    //public GFRS_Program_Audience_Group__c[] allAttendees {get; set;}
    
    /** Whether multiple programs are allowed **/
    public Boolean areMultipleAllowed { get; set; }
    public Boolean areMultipleAllowedSciExhi { get; set; }
    
    
    public Boolean moreeventassociated { get; set; }
    
    /** id of the selected program **/
    public Id currentProgramId { get; set; }
    
    public Boolean isEditable { get; set; }
    
    public Attachment oldAttachment;
    public String fieldApiName { get; set; }
        public String fieldLabel { get; set; }
        
        GFRS_AttachmentCollector attachmentCollector;
        Map<String,String> apiNameToLabelMapProgram;
        

    
    /**
    *@author: ADMD Team
    *@date: 06/05/2013
    *@description: SFDC-3371 - flag needed for specify whether 'Delete Program' button should be displayed or not.
    */
    public Boolean isRequestSubmitted { get; set; }
    
    /** Which bugdets should be displayed **/
    public String hasLive { get; set; }
    public String hasWebinar { get; set; }
    public String hasEnduring { get; set; }
    
    public String intendedAudienceOptions {get; set;}
    public String categoryOfCreditOptions {get; set;}
    public String specialtyOptions { get; set; }
    public String programType {get;set;}
    public String getProgramType() {
            return programType;
    }        
    public void setProgramType(String programType) {
            this.programType = programType;
    }
    
    public String selectedPgmId { get; set; }
    public String selectedProgramId { get; set; }
    public String lastSelectedProgramId{get;set;}
    public String indexOfPreviousAccordion { get; set; }
        
    public Boolean scrollToProgram {get;set;}
    public Boolean scrollToInputField{get;set;} 
    
    public Boolean isLastProgramSelected { get; set; }
    public Boolean showPleaseNoteMessage { get; set; }
    public Boolean isInternalUser { get; set; }
    public Integer getProgramSize{
        get{
            if(programs!=null){
                return programs.size();
            }else{
                return 1;
            }
        }
        set;
    }
    
    /** index of the program to show in the list **/
    public Integer lastSelectedIndex { get; set; }
    public Boolean shouldConfirmBussDaysDiffSingle { get; set; }
    public Boolean shouldConfirmBussDaysDiffMulti { get; set; }
    
    /** determines whether the page currently has messages **/
    public Boolean hasMessages {
        get { return( ApexPages.hasMessages() ); }
    }
    
    public String attendeeMessage { get { return( this.contentItems.get('Attendee')); }}
    
    public String programDetailsTitle{ get { 
            if ( gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(this.recordTypeName)){
                return FIELD_EXHIB_PROGRAM_TITLE;
            } else if (gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals(this.recordTypeName)){
                    return CORP_MEM_PROGRAM_TITLE;        
            } else {
                return PROGRAM_TITLE;
            }
        }
    }
    
    /** whether the 'Corporate Memberships with Exhibit Opportunities' field set shoul be shown **/
    public Boolean isCMEOShown {
        get {
            //system.debug(this.fundReq.Benefits_Exchanged_for_Funding__c);
            if( this.request.Benefits_Exchanged_for_Funding__c != null && (gFRS_Util.multiSelectHasItem( this.request.Benefits_Exchanged_for_Funding__c, gFRS_Util.EXHIBIT_SPACE ) || gFRS_Util.multiSelectHasItem( this.request.Benefits_Exchanged_for_Funding__c, gFRS_Util.EXHIBIT_SPACE_PREF_LOCATION )) ){
                return (true);
            } else {
                return (false);
            }
            
            return (false);
        }
    }
    
    public gFRS_ProgramController( ApexPages.Standardcontroller std ){
        
        system.debug('controller was executed');
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );
        this.progDetail = '<div style="text-align: left;"><p style="font-family: Arial, FreeSans, Helvetica, sans-serif; font-size: 13px;"> </p><p style="font-family: Arial, FreeSans, Helvetica, sans-serif; font-size: 13px;"><b>Entering Program(s) Information</b></p><ul style="font-family: Arial, FreeSans, Helvetica, sans-serif; font-size: 13px;"><li><span style="font-family: arial, sans, sans-serif; background-color: rgb(255, 255, 255);">This section allows you to enter information for a program that is occurring on a single date and/or location, as well as a program that is occurring on multiple dates and/or multiple locations.</span></li><li>After all information is complete for the first component of the program, click on the <b>“Add Program”</b> button at the bottom of the page to add additional program components.</li><li>When done, click on “Save and Continue” to enter one Total Overall Detailed Budget for the entire program.</li></ul></div><br>';
        
        
        //-- find the list of programs for the Funding Request
        this.request = (GFRS_Funding_Request__c)std.getRecord();
        
        try {
            this.request = [ select id,Funding_Sub_Type__c, foundation_classified__c, Record_Type_name__c, Status__c, Information_Needed__c, Issue_type__c, Exhibits_or_Displays_Allowed__c, Benefits_Exchanged_for_Funding__c, Location__c, Organization__c, Requested_Amount__c, Total_Program_Budget__c, Signing_Authority_Email__c, Authorized_Signer__c,Event_Project_type__c,Event_Project_sub_type__c, Date_Submitted__c,Is_there_more_than_one_event_associated__c,Number_of_Programs__c
                from GFRS_Funding_Request__c
                where id = :this.request.id limit 1];
                
        } catch( Exception err ){
            System.debug( 'unable to find finding request[' + this.request.id + ']' );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find funding request' ));
            
            //-- stub out the record type so the page can load normally
            this.recordTypeName = '';
            return;
        }
        this.recordTypeName = this.request.Record_Type_Name__c;
        this.fSubType=this.request.Funding_Sub_Type__c;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        this.shouldConfirmBussDaysDiffSingle = (params.containsKey(PARAM_CONFIRMATION) && PARAM_MESSAGE.equals(params.get(PARAM_CONFIRMATION)));        
        this.shouldConfirmBussDaysDiffMulti = (params.containsKey(PARAM_CONFIRMATION) && PARAM_MESSAGEMULTI.equals(params.get(PARAM_CONFIRMATION)));        
            params.remove(PARAM_CONFIRMATION);    
        this.startDateResp = '';
        if(params.containsKey('pgmId')){
            this.ProgmId = Id.valueOf( params.get('pgmId') );
        }
         

        /* Needed to expand the logic of editable because of GFRS-675 added Program Design */
        //this.isEditable = gFRS_Util.multiSelectHasItem( this.request.Information_Needed__c, 'Program' );
        if(gFRS_Util.multiSelectHasItem( this.request.Information_Needed__c, 'Program' ) == true 
            && gFRS_Util.multiSelectHasItem( this.request.Information_Needed__c, 'Program Design' ) != true){
            this.isEditable = true;
        } else if (gFRS_Util.multiSelectHasItem( this.request.Information_Needed__c, 'Program;' ) == true ){
            this.isEditable = true;
        } else {
            this.isEditable = false;
        }



        system.debug('KK: ' + gFRS_Util.multiSelectHasItem( this.request.Information_Needed__c, 'Program' ));
        system.debug('KK: ' + gFRS_Util.multiSelectHasItem( this.request.Information_Needed__c, 'Program Design' ));

        this.isRequestSubmitted = this.request.Date_Submitted__c!=null?true:false;
        
        if( !this.getPrograms() ){
            //-- error occured while fetching programs
            return;
        }
        
        //-- determine the options available for intended audience
        Schema.DescribeFieldResult audienceField = GFRS_Program_Audience_Group__c.Intended_Audience__c.getDescribe();
        List<Schema.PicklistEntry> audiencePicklistValues = audienceField.getPicklistValues();
        this.intendedAudienceOptions = '';
        for (Integer i = 0; i < audiencePicklistValues.size(); i++) {
            this.intendedAudienceOptions += audiencePicklistValues[i].getValue();
            if(i+1 < audiencePicklistValues.size()){
                this.intendedAudienceOptions += ',';
            }
        }
        
        Schema.DescribeFieldResult categoryField = GFRS_Program_Audience_Group__c.Category_of_Credit__c.getDescribe();
        List<Schema.PicklistEntry> categoryPicklistValues = categoryField.getPicklistValues();
        this.categoryOfCreditOptions = '';
        for (Integer i = 0; i < categoryPicklistValues.size(); i++) {
            this.categoryOfCreditOptions += categoryPicklistValues[i].getValue();
            if(i+1 < categoryPicklistValues.size()){
                this.categoryOfCreditOptions += ',';
            }
        }
        
        Schema.DescribeFieldResult specialtyField = GFRS_Program_Audience_Group__c.Specialty__c.getDescribe();
        List<Schema.PicklistEntry> specialtyPicklistValues = specialtyField.getPicklistValues();
        this.specialtyOptions = '';
        for (Integer i = 0; i < specialtyPicklistValues.size(); i++) {
            this.specialtyOptions += specialtyPicklistValues[i].getValue();
            if(i+1 < specialtyPicklistValues.size()){
                this.specialtyOptions += ',';
            }
        }
            
        this.areMultipleAllowed = checkMultipleAllowed();
        this.areMultipleAllowedSciExhi = checkMultipleAllowedSciExhi();
        
        
        if(this.request.Is_there_more_than_one_event_associated__c=='Yes'){
            
            moreeventassociated=true;
            
        }
        else{
            moreeventassociated=false;
        }
        
        //this.testAttachment = new Attachment();
        this.showPleaseNoteMessage = !( gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c) );
        this.lastSelectedIndex = 0;
        
        Contact userContact = gFRS_Util_NoShare.getUserContact( UserInfo.getUserId() );
        this.isInternalUser = userContact == null;
        
        
        if(this.recordTypeName == 'IMED'){
                if(programs.size()>0){
                        this.currentProgramId=programs[0].id;
                }       
        }
        
        if(this.recordTypeName == 'HC Char'){
            this.selectedProgramId=Apexpages.currentPage().getParameters().get('selectedProg');
            this.hcCharProgType=Apexpages.currentPage().getParameters().get('selectedProgType');
            if(this.programs.size() >0 && selectedProgramId==null && (this.programs[0].Type__c == null || (this.programs[0].Type__c != null && !checkIfValidHCType(this.programs[0].Type__c)))){
                    List<SelectOption> items= getAvalableProgramTypes();
                    if(items.size()>0){
                        this.programs[0].Type__c=items[0].getValue();
                    }

            }
            GFRS_Program__c selectedProgram=null;
            if(selectedProgramId!=null){
                selectedProgram=programsMap.get(Id.valueOf(selectedProgramId));
            }else {
                selectedProgram=this.programs[0];
            }
            system.debug('check for what program gets attachment');
            system.debug(selectedProgram);
            this.apiNameToAttachmentMap = new Map<String,Attachment>();
            setAttachmentsForProgram(selectedProgram);
            this.scrollToProgram=false;
            this.scrollToInputField=false;    
        }
        
        apiNameToLabelMapProgram = gFRS_Util_NoShare.getFieldLabelsMapForGivenObject(PROGRAM_API_NAME);
        
    }
    
    /**
     *  Fetches the program for the current funding request.
     *  <p>post-condition: the list of programs (along with their accompanied attachments) for the current funding request.</p>
     *  @return Boolean - whether the programs were returned as expected
     **/
    private Boolean getPrograms(){
        
        //-- get attachments (must be explicitly requested)
        try {
            this.programs = [ select 
                Program_Title__c,Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Activities__c, Actual_Time_at_Display_Table_Hours__c, Audience_Non_US_Based__c, Audience_US_Based__c, Criteria_for_Fellow_Selection__c, End_Date__c, Enduring_Materials_Opt_Out_Description__c, Enduring_Materials_Opt_Out__c, Funding_Request__c, Geographic_Region__c, Is_CMEO__c, NCI_Designated_Cancer_Center__c, Number_of_Tables__c, Outstanding_Accounts_Payable__c, Product_being_Promoted__c, Program_Subtype__c, Publicity_Plan__c, Size_of_Exhibit__c, Speakers_Faculty__c, Start_Date__c, Status__c, Type__c, Venue_City__c, Venue_Country__c, Venue_Name__c, Venue_State__c, Venue_Type__c, Venue_Zip_Code__c, Verified__c, Web_URL__c, Expected_Number_of_Attendees__c,Expected_number_of_students_engaged__c, Expected_number_of_teachers_engaged__c,Expected_number_of_patients_engaged__c,Expected_of_attendees_that_are_HCPs__c, Expected_of_Attendees_US_Based_HCPs__c, Event_Program_Type__c, Funding_Type__c, Support_Purpose_Program_Description__c, Booth_Type__c, Number_of_Activities__c, Alternate_Program_Title__c, Number_of_Learners_del__c, Number_of_Learners_Receiving_CME_Credits__c, Average_Years_in_Practice__c, Total_Number_of_Participants__c, Average_Number_of_Patients__c, Total_Visits__c, Number_of_Pages_Viewed__c, Total_Number_of_Pages__c, Results_were_Achieved__c, If_Results_Not_Achieved_State_Why__c, Letter_of_Request__c, Meeting_Agenda__c, Needs_Assessment_Document__c, Implementation_Plan__c, Fellowship_Project_Description__c, Educational_Objectives_Intended_Outcome__c, Program_Status__c, Did_Total_Budget_Amount_for_this_Program__c, If_Yes_New_Total_Budget_for_Program__c, Change_in_Number_of_Commercial_Supporter__c, If_Yes_How_Many_Commercial_Supporters__c, Did_Educational_Objectives_Change__c, If_Yes_New_Educational_Objectives__c, Other_Companies_Supporting_Meeting__c, Intended_Audience__c, Method_for_Measuring_Program_Success__c, Event_Meeting_Membership_Public__c, Does_Event_Have_Volunteering_Opportunity__c, Is_Volunteering_Opportunity_Public__c, ACGME_Program_Number__c, Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_this_Process__c, Outcomes_Review_Comments__c, Were_Learning_Objectives_Achieved_LOA__c, Number_of_Respondents_LOA__c, Percent_Responding_LOA__c, Did_Activity_Achieve_Objectives_ASA__c, Number_of_Respondents_ASA__c, Percent_Responding_ASA__c, Was_Material_Organized_Clearly_MOC__c, Number_of_Respondents_MOC__c, Percent_Responding_MOC__c, Format_Helpful_in_Achieving_Objective_FH__c, Number_of_Respondents_FH__c, Percent_Responding_FH__c, Did_Activity_Provide_Interactivity_APO__c, Number_of_Respondents_APO__c, Percent_Responding_APO__c, Did_You_Find_the_Format_to_be_Useful_AFU__c, Number_of_Respondents_AFU__c, Percent_Responding_AFU__c, Is_the_Content_Relevant_to_Practice_CR__c, Number_of_Respondents_CR__c, Promotional_Event_Advertising_URL__c, Percent_Responding_CR__c, Activity_Address_Overcoming_Barrier_AAS__c, Number_of_Respondents_AAS__c, Letter_of_Request_URL__c, Percent_Responding_AAS__c, Does_Content_Translate_Evidence_CTE__c, Number_of_Respondents_CTE__c, Meeting_Agenda_URL__c, Percent_Responding_CTE__c, Program_Reinforce_Current_Patterns_CPP__c, Number_of_Respondents_CPP__c, Needs_Assessment_Document_URL__c, Percent_Responding_CPP__c, Will_Content_Impact_Your_Practice_CIP__c, Number_of_Respondents_CIP__c, Implementation_Plan_URL__c, Percent_Responding_CIP__c, Did_Content_Contribute_Valuable_Info_CVI__c, Number_of_Respondents_CVI__c, Percent_Responding_CVI__c, Would_You_Recommend_to_Colleagues_RAC__c, Number_of_Respondents_RAC__c, Percent_Responding_RAC__c, Rating_Against_Other_CME_Activities_AR__c, Number_of_Respondents_AR__c, Percent_Responding_AR__c, Was_the_Activity_Fair_and_Balanced_FAB__c, Number_of_Respondents_FAB__c, Percent_Responding_FAB__c, Fellowship_Project_Description_URL__c, Venue_Province_Region__c,Benefits_Exchanged_for_Funding__c,Other_Commercial_Supporters__c,If_Known_List_Other_Supporters__c,
                Promotional_Event_Advertising__c,Additional_Document_Uploads__c,Additional_Document_Uploads_2__c,Additional_Document_Uploads_3__c,Additional_Document_Uploads_4__c,Additional_Document_Uploads_5__c,Exhibits_or_Displays_Allowed__c,Payment_registration_due_date__c,Genentech_is_not_supporting_more_than_75__c,Are_there_any_other_commercial_sponsors__c,Short_Start_Date_Resp__c,
                
                (select id,name,CreatedDate,Description from Attachments)
                 //-- all fields off the program object for now
                //-- Promotional_Event_Advertising__c,Letter_of_Request__c,Meeting_Agenda__c,Needs_Assessment_Document__c,Implementation_Plan__c,Fellowship_Project_Description__c, //-- fields needed for attachments
                from GFRS_Program__c
                where Funding_Request__c = :this.request.id
                order by Is_CMEO__c asc, createdDate asc
            ];
            programsMap=new Map<ID,GFRS_Program__c>(programs);
        } catch( Exception err ){
            System.debug( 'unable to find programs for funding request[' + this.request.id + ']' );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to find Programs' ));
            return( false );
        }
        
        return( true );
    }
    public Apexpages.Pagereference refreshSection(){
        return (null);
    }

    
    public ApexPages.PageReference addProgramYes(){
        this.AlertResponse = 'Yes';
        this.shouldConfirmBussDaysDiffMulti = false;
        ApexPages.PageReference saveResult = this.savePage();
        
        if( ApexPages.hasMessages() ){
            //-- there was a failure
            return(null);
        }   

        this.AlertResponse = '';
        ApexPages.PageReference retPage = this.addPgm();
        return null;        
    }
    
    public ApexPages.PageReference addProgramNo(){
        this.AlertResponse = 'No';
        this.shouldConfirmBussDaysDiffMulti = false;
        this.shouldConfirmBussDaysDiffSingle = false;
        ApexPages.PageReference saveResult = this.savePage();
        this.AlertResponse = '';
        this.selectedProgramId = Apexpages.currentPage().getParameters().get('PgmId');
        return null;        
        
        if( ApexPages.hasMessages() ){
            //-- there was a failure
            return(null);
        }   
        
        this.AlertResponse = '';
        ApexPages.PageReference retPage = this.addPgm();
        return null;        

    }

    /**
    * @author GFRS Dev Team
        * @date 20/02/2014
        * @description addProgram method - Creates a new program to add to the funding request. 
        */
    public ApexPages.PageReference addProgram(){
        //-- to avoid loosing everything before a re-render, we must issue a save-all...
        Id idSelectedProgram = null;
        if(gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c)){
            idSelectedProgram = Id.valueOf( selectedProgramId );
        }
        ApexPages.PageReference saveResult = this.savePage();
        
        if( ApexPages.hasMessages() ){
            //-- there was a failure
            return(null);
        }
        
        if(this.request.Record_Type_name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME  || this.request.Record_Type_name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME ){
            
            Integer programToDisplay = (getSelectedProgramById(idSelectedProgram));
            //integer pgmSize = this.programs.size();
            GFRS_Program__c currPgm = this.programs[programToDisplay];
            
            Date startDate = Date.today();
            Date endDate   = currPgm.Start_Date__c;

            Integer workingDays = 0;  

            for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
            {  
                Date dt = startDate + i;  
                DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
                String todayDay = currDate.format('EEEE');  
                if(todayDay != 'Saturday' && todayDay !='Sunday')  
                {  
                    workingDays = workingDays + 1;  
                }     
                
            }
            if(workingDays < 21){
                //return (new ApexPages.PageReference( gFRS_Util.PATH_PROGRAM +'?id=' + this.request.id).setRedirect(true));
                //return (new PageReference(gFRS_Util.initializeLink(gFRS_Util.PATH_PROGRAM, this.request, PATH_CONFIRMMULTI)).setRedirect(true));
                string path = gFRS_Util.initializeLink(gFRS_Util.PATH_PROGRAM, this.request, PATH_CONFIRMMULTI);
                path +=  '&pgmId=' + idSelectedProgram;
                return (new PageReference(path).setRedirect(true));
            }   
        }
        
        ApexPages.PageReference retPage = this.addPgm();
        return retPage;
        
    }
    
    public ApexPages.Pagereference addPgm() {
        //System.debug( 'creating a new program' );
        GFRS_Program__c newProgram = gFRS_Util.createFundingRequestProgram( this.request );
        if(this.request.Record_Type_name__c != gFRS_Util.TYPE_IMED){
            newProgram.Type__c = 'Live';
        }if(this.request.Record_Type_name__c=='HC Char'){
            List<SelectOption> items= getAvalableProgramTypes();
            if(items.size()>0){
                newProgram.Type__c=items[0].getValue();
            }
        }
        
        try {
            Id recordTypeId = [select Id from RecordType where Name = :this.request.Record_Type_Name__c+' - Program'].Id;
            newProgram.RecordTypeId = recordTypeId;
            gFRS_Util_NoShare.saveLockedPrograms( new gFRS_Program__c[]{ newProgram } );
            
            this.programs.add( newProgram );
            if(this.request.Record_Type_name__c=='IMED'){
                this.currentProgramId=newProgram.id;
            }
            this.getPrograms();
            System.debug('PN: this.programs.size() - 1: ' + (this.programs.size() - 1));
            this.lastSelectedIndex = this.programs.size() - 1;
            
            if(this.request.Record_Type_name__c=='HC Char' || this.request.Record_Type_name__c=='Sci/Pipeline Exhibits & Other Non-Promo' || this.request.Record_Type_name__c=='Exhibits & Other Promos' ){
                this.selectedProgramId=newProgram.id; 
                this.scrollToProgram=true;
                this.scrollToInputField=false;
                setAttachmentsForProgram(newProgram);
            }
            if(this.request.Record_Type_name__c=='Sci/Pipeline Exhibits & Other Non-Promo' || this.request.Record_Type_name__c=='Exhibits & Other Promos' ){
                this.request = [ select id,Funding_Sub_Type__c, foundation_classified__c, Record_Type_name__c, Status__c, Information_Needed__c, Issue_type__c, Exhibits_or_Displays_Allowed__c, Benefits_Exchanged_for_Funding__c, Location__c, Organization__c, Requested_Amount__c, Total_Program_Budget__c, Signing_Authority_Email__c, Authorized_Signer__c,Event_Project_type__c,Event_Project_sub_type__c, Date_Submitted__c,Is_there_more_than_one_event_associated__c,Number_of_Programs__c
                from GFRS_Funding_Request__c
                where id = :this.request.id limit 1];
            }
            
        } catch( Exception err ){
            System.debug( 'Error occurred while adding in a new program:' + err );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err)));
        }
        
        
        return( null );     
    }
    
    
    /**
    * @author GFRS Dev Team
        * @date 20/02/2014
        * @description removeProgram method - removes program. 
        */
    public Apexpages.Pagereference removeProgram(){
        if(this.programs!=null && programs.size()>1){
                GFRS_Program__c progToDelete=null;
                try{
                        if(this.selectedProgramId != null && this.selectedProgramId !=''){
                                system.debug('check if selectedProgramId');
                                system.debug(this.selectedProgramId);
                        progToDelete=programs[getSelectedProgramById(Id.valueOf(this.selectedProgramId))];
                    }else if(this.currentProgramId != null){
                        system.debug('check if currentProgramId');
                        system.debug(this.currentProgramId);
                        progToDelete=programs[getSelectedProgramById(this.currentProgramId)];
                    }
                }catch(Exception ex){
                        system.debug('check values');
                        system.debug(this.selectedProgramId);
                        system.debug(this.currentProgramId);
                        system.debug(this.isLastProgramSelected);
                        system.debug('selected program id is null');
                        return null;
                }
                
            System.Savepoint sp=Database.setSavepoint();
                
            try{
                if(progToDelete!=null){delete progToDelete;}
            }catch(Exception ex){
                Database.rollback(sp);
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex)));
            }
            
           
            
            this.getPrograms();
            try{
                deleteRequestBudgetIfExist(this.request.id,progToDelete.Type__c);
            }catch(Exception ex){
                Database.rollback(sp);
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(ex)));
            }
            if(this.lastSelectedIndex>0){
                this.lastSelectedIndex-=1;
            }
            
            
            if(this.request.Record_Type_name__c=='HC Char' || this.request.Record_Type_name__c=='Exhibits & Other Promos' || this.request.Record_Type_name__c=='Sci/Pipeline Exhibits & Other Non-Promo'){
                this.selectedProgramId=(String)this.programs[this.programs.size()-1].id;
                setAttachmentsForProgram(this.programs[this.programs.size()-1]);
                this.scrollToProgram=true;
                this.scrollToInputField=false;
            }
             
            if(this.request.Record_Type_name__c=='IMED'){
                this.currentProgramId=this.programs[this.programs.size()-1].id;
            }      
        }
        return( new ApexPages.PageReference( gFRS_Util.PATH_PROGRAM +'?id=' + this.request.id).setRedirect(true));
    }
    
    /**
     *  Determines whether multiple programs are allowed
     **/
    private Boolean checkMultipleAllowed(){
        return request.Record_Type_name__c == gFRS_Util.TYPE_IMED || request.Record_Type_name__c == 'HC Char' && (
            request.Event_Project_type__c == 'Patient and General Disease Education' ||
            request.Event_Project_type__c == 'Fundraiser' ||
            (request.Event_Project_type__c == 'Patient Support' && (
                request.Event_Project_sub_type__c == 'Patient Services (e.g., nutrition support, transportation)' ||
                request.Event_Project_sub_type__c == 'Health Screenings' || 
                request.Event_Project_sub_type__c == 'Counseling Assistance (includes peer-to-peer, camps, etc.)' ||
                request.Event_Project_sub_type__c == 'Patient Navigation' ||
                request.Event_Project_sub_type__c == 'Survivorship' 
            )) ||
            (request.Event_Project_type__c == 'Policy and Advocacy' && (
             request.Event_Project_sub_type__c == 'Federal and state legislative advocacy programming (e.g., Hill Days)' ||
             request.Event_Project_sub_type__c == 'Grassroots mobilization (e.g., advocate education)'))
        );
    }
    
    /**
     *  Determines whether multiple programs are allowed - For Scintific pipeline & Exhibites
     **/
    private Boolean checkMultipleAllowedSciExhi(){
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        Boolean allowMultiPgm = customSettings.Allow_Exhi_SciPipeline_MultiProgram__c;      
        string pgmType = customSettings.Exhi_SciPipeline_MultiProgram__c;
        
        if(allowMultiPgm == true){
            list<string> pgmTypes = new list<string>();
            map<string,string> pgmTypeMap = new map<string,string>();
            pgmTypes = pgmType.split(';');
            
            for(string str : pgmTypes){
                pgmTypeMap.put(str, str);
            }
            
            if(pgmTypeMap.containsKey(request.Event_Project_type__c)){
                return true;
            } else {
                return false;
            }
            
        } else {
            return false;
        }
       /* return (request.Record_Type_name__c == 'Exhibits & Other Promos' || request.Record_Type_name__c == 'Sci/Pipeline Exhibits & Other Non-Promo') && (
            request.Event_Project_type__c == 'Patient education' ||
            request.Event_Project_type__c == 'Fundraiser' ||
            request.Event_Project_type__c == 'Healthcare provider education' ||
            request.Event_Project_type__c == 'Health Screening' ||
            request.Event_Project_type__c == 'Managed Care education' ||
            request.Event_Project_type__c == 'Scientific/medical meeting' ||
            request.Event_Project_type__c == 'Vendor fair'
        );   */
    }   
    
    /**
     *  Method called that returns to the 'previous' page
     **/
    public ApexPages.PageReference back(){
        PageReference demographicPage = new PageReference( gFRS_Util.PATH_DEMOGRAPHIC );
        demographicPage.getParameters().put('request_id', this.request.id);
        if (this.request.Record_Type_name__c == gFRS_Util.TYPE_IMED) {
            createProgramDesignIfNotExists();
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAMDESIGN, this.request, null ) ));
        } else {
            // if (this.request.foundation_classified__c == 'FALSE' && gFRS_Util.isExternalRequest(this.request.Record_Type_Name__c)){
            if (gFRS_Util.isExternalRequest(this.request.Record_Type_Name__c)){    
                return demographicPage;
            } else if(chechIfThirdPartyVisible(this.request)){
                return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_THIRDPARTY, this.request, null ) ));
            } else {
                return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_APPLICATION, this.request, null ) ));
            }
        } 



        
    }
    /* @author GFRS Dev Team
    * @date 20/02/2014
    * @description chechIfThirdPartyVisible method -  Method check if third party should be displayed. 
    */
    public Boolean chechIfThirdPartyVisible(GFRS_Funding_Request__c fundingRequest){
        if(fundingRequest != null){
            return [select id, Record_Type_Name__c, Will_You_be_Working_With_a_3rd_Party__c from GFRS_Funding_Request__c 
                               where id =: fundingRequest.Id and (Record_Type_Name__c =:gFRS_Util.TYPE_IMED_NAME OR Record_Type_Name__c =:gFRS_Util.TYPE_HC_CHAR_NAME) 
                               and Will_You_be_Working_With_a_3rd_Party__c =:gFRS_Util.YES].size()>0;
        }
        return false;
    }
    
    public ApexPages.PageReference next(){  
        return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) ));
    }
    

     /**
    * @author GFRS Dev Team
        * @date 20/02/2014
        * @description saveProgram method -  Method that saves a program. 
        */
    public ApexPages.PageReference saveProgram(){
        String myVal = '' + this.request.id;
        System.debug( 'selectedProgramId:' + this.selectedProgramId );
        Id idSelectedProgram = null;
        this.startDateResp = Apexpages.currentPage().getParameters().get('startDateResp');
        
        system.debug('Response : '+this.startDateResp);
        if(this.startDateResp != '' && this.startDateResp != null){
            this.ProgmId = Apexpages.currentPage().getParameters().get('pgmId');
            Map<id,GFRS_Program__c> pgmMap = new Map<id,GFRS_Program__c>( this.programs );
            idSelectedProgram = Id.valueOf( ProgmId );
            this.selectedProgramId = Apexpages.currentPage().getParameters().get('PgmId');
            if(this.startDateResp == 'No'){
                return null ;
            }
            GFRS_Program__c pgm = pgmMap.get( idSelectedProgram );
            pgm.Short_Start_Date_Resp__c = this.startDateResp;
            gFRS_Util_NoShare.saveLockedPrograms(new gFRS_Program__c[]{pgm});
            this.getPrograms();
            //this.selectedProgramId = idSelectedProgram;
            if( !validateSave( this.programs ) ){
                return( null );
            }
            return new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) );
        }
        
        
        try {
            idSelectedProgram = Id.valueOf( selectedProgramId );
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'System Error: invalid program id' ));
            System.debug( 'could not convert[' + selectedProgramId + '] to id:' + err.getMessage() );
            return(null);
        }
       
        Map<id,GFRS_Program__c> programMap = new Map<id,GFRS_Program__c>( this.programs );
        if( !programMap.containsKey( idSelectedProgram )){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'System Error: unable to find program to update' ));
            System.debug( 'do not currently have program[' + idSelectedProgram + ']:' + this.programs );
            return(null);
        }
        
        GFRS_Program__c program = programMap.get( idSelectedProgram );
        gFRS_Program__c[] programsToSave = new gFRS_Program__c[]{ program };

        if(!validateUSPS(programsToSave)){
            return( null );
        }
        if( !validateSave( programsToSave )){
            return( null );
        }

        
        
        //-- not sure why but programs or program don't seem to be updated for the submit
        if(this.request.Record_Type_name__c != gFRS_Util.TYPE_HC_CHAR_NAME){
            try {
                if(this.startDateResp != ''){
                    program.Short_Start_Date_Resp__c = this.startDateResp;
                } else {
                    program.Short_Start_Date_Resp__c = '';
                }
                gFRS_Util_NoShare.saveLockedPrograms(new gFRS_Program__c[]{program});
                this.getPrograms();
                gFRS_Util_NoShare.saveLockedPrograms(  this.programs );
    
            } catch( Exception err ){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ));
                System.debug( 'could not convert[' + selectedProgramId + '] to id:' + err.getMessage() );
                return(null);
            }
        }
        //SFDC-1585 bug fixing for Corporate Memberschip
        if(this.request.Record_Type_name__c == gFRS_Util.TYPE_IMED){
            if( !validateSave( this.programs ) ){
                return( null );
            }
            removeBudgetIfProgramTypeWasChanged();
            return new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) );  
        }else if(this.request.Record_Type_name__c == gFRS_Util.TYPE_HC_CHAR_NAME){
                
            if( !validateSave( this.programs ) ){
                return( null );
            }
            
            try{
                for(GFRS_Program__c programToCheck : this.programs){
                        if(programToCheck.Type__c == 'Online Resources' || programToCheck.Type__c == 'Ongoing'){
                                        if(this.request.Status__c == 'Intake' && programToCheck.Meeting_Agenda__c != null && programToCheck.Meeting_Agenda__c != ''){
                                                deleteAttachments( programToCheck.Meeting_Agenda__c );
                                        }
                                        programToCheck.Meeting_Agenda__c = null;
                                        this.apiNameToAttachmentMap.get(MEETING_AGENDA_API_NAME).Name = null;
                                    this.apiNameToAttachmentMap.get(MEETING_AGENDA_API_NAME).Id = null;
                        }       
                }
                
                gFRS_Util_NoShare.saveLockedPrograms(  this.programs );
            }catch(Exception err){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ));
                System.debug( 'could not convert[' + selectedProgramId + '] to id:' + err.getMessage() );
                return(null);
            }   
            return new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) );
            
        }else if(this.request.Record_Type_name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || this.request.Record_Type_name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME){
            if( !validateSave( this.programs ) ){
                return( null );
            } 
            
            if(this.startDateResp == '' || this.startDateResp == null){
                GFRS_Program__c pgm = [select id,name, Start_Date__c from GFRS_Program__c where id =: idSelectedProgram];
                Date startDate = Date.today();
                Date endDate   = pgm.Start_Date__c;

                Integer workingDays = 0;  

                for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
                {  
                    Date dt = startDate + i;  
                    DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
                    String todayDay = currDate.format('EEEE');  
                    if(todayDay != 'Saturday' && todayDay !='Sunday')  
                    {  
                        workingDays = workingDays + 1;  
                    }     
                    
                } 
                
                if(workingDays < 21){
                    //return (new ApexPages.PageReference( gFRS_Util.PATH_PROGRAM +'?id=' + this.request.id).setRedirect(true));
                    //return (new PageReference(gFRS_Util.initializeLink(gFRS_Util.PATH_PROGRAM, this.request, PATH_CONFIRM)).setRedirect(true));
                    string path = gFRS_Util.initializeLink(gFRS_Util.PATH_PROGRAM, this.request, PATH_CONFIRM);
                    path +=  '&pgmId=' + idSelectedProgram;
                    return (new PageReference(path).setRedirect(true));
                }
            }
            this.startDateResp = '';
            
            return new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) );
        }else{  
                if((this.request.Record_Type_name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME   || this.request.Record_Type_name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME ) && (this.startDateResp == '' || this.startDateResp == null)){
                    GFRS_Program__c pgm = [select id,name, Start_Date__c from GFRS_Program__c where id =: idSelectedProgram];
                    Date startDate = Date.today();
                    Date endDate   = pgm.Start_Date__c;

                    Integer workingDays = 0;  

                    for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
                    {  
                        Date dt = startDate + i;  
                        DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
                        String todayDay = currDate.format('EEEE');  
                        if(todayDay != 'Saturday' && todayDay !='Sunday')  
                        {  
                            workingDays = workingDays + 1;  
                        }     
                        
                    } 

                    if(workingDays < 21){
                        //return (new ApexPages.PageReference( gFRS_Util.PATH_PROGRAM +'?id=' + this.request.id).setRedirect(true));
                        //return (new PageReference(gFRS_Util.initializeLink(gFRS_Util.PATH_PROGRAM, this.request, PATH_CONFIRM)).setRedirect(true));
                        string path = gFRS_Util.initializeLink(gFRS_Util.PATH_PROGRAM, this.request, PATH_CONFIRM);
                        path +=  '&pgmId=' + idSelectedProgram;
                        return (new PageReference(path).setRedirect(true));
                    }                   
                }
                
                this.startDateResp = '';
                if(!isLastProgramSelected){
                        if( !validateSave( new GFRS_Program__c[] {program} ) ){
                        return( null );
                }
                if(this.request.Record_Type_name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME){
                    return( isLastProgramSelected != null && true == isLastProgramSelected ? new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) ) : null );                   
                }
                }else if(isLastProgramSelected){
                    if(this.request.Record_Type_name__c != gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME   && this.request.Record_Type_name__c != gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME ){
                        if( !validateSave( this.programs )){
                            return( null );
                        }
                    }
                }
            
          //  return( isLastProgramSelected != null && true == isLastProgramSelected ? new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) ) : null );
            return new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) );
        }
        
        
        //return( isLastProgramSelected != null && true == isLastProgramSelected ? new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_COMPLETE, this.request, '' ) ) : null );
        //return new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_COMPLETE, this.request, '' ) );
    }
    
    /**
     *  Method called to perform final submission
     **/
    public ApexPages.PageReference savePage(){
        
        id idSelectedProgram = null;
        if(this.AlertResponse == '' || this.AlertResponse == null){
            if(this.request.Record_Type_name__c != 'IMED'){
                idSelectedProgram = Id.valueOf( selectedProgramId );
            } else {
                idSelectedProgram = this.currentProgramId;
            }
            if( !validateSave( this.programs ) ){
                return (null);
            }
        }
        
        if(this.AlertResponse != '' && this.AlertResponse != null){
            this.ProgmId = Apexpages.currentPage().getParameters().get('PgmId');
            Integer programToDisplay = (getSelectedProgramById(this.ProgmId));

            //GFRS_Program__c partial = this.programs.get(programToDisplay);
            //integer pgmSize = this.programs.size();
            this.programs[programToDisplay].Short_Start_Date_Resp__c = this.AlertResponse;           
        } else {
            Integer programToDisplay = (getSelectedProgramById(idSelectedProgram));
            this.programs[programToDisplay].Short_Start_Date_Resp__c = '';   
        }
        
        try{
            //System.debug( 'programs to Save:' + this.programs );
            gFRS_Util_NoShare.saveLockedPrograms( this.programs);
            
        } catch(Exception e){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(e) ) );
            return(null);
        }
        
        return( isLastProgramSelected != null && isLastProgramSelected == true ? new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_BUDGET, this.request, '' ) ) : null );
    }

    public boolean validateUSPS(gFRS_Program__c[] programsToValidate){
        Boolean isValid = true;
        for(GFRS_Program__c p : programsToValidate){
            if (p.Venue_Country__c == 'United States' && p.Venue_City__c != null && p.Venue_Zip_Code__c != null) {
                String uspsValidation = Test.isRunningTest() ? null : isZipCodeValid(p);
                if (String.isNotBlank(uspsValidation)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, uspsValidation));
                    isValid = false;
                }
            }
        }
        return isValid;
    }

    /**
     *  Validates the page before submission
     *  @return (Boolean) - whether validation passed (True) or failed (false)
     *  @param programs (gFRS_Funding_Request__c[]) - list of programs to validate against
     **/
    public Boolean validateSave( gFRS_Program__c[] programsToValidate ){
        Boolean isValid = true;
        //system.debug('----------------');
        //SFDC- 1442
        Set<Id> programIds=new Set<Id>();
        for(gFRS_Program__c progItem: programsToValidate)
        {   
            programIds.add(progItem.id);
        }
        //List<AggregateResult>  attendesPerProgram=[select Program__r.Id programId,count(Program__r.Name) attendeSize from GFRS_Program_Audience_Group__c where Program__r.Id in: programIds group by Program__r.Id];
        Map<Id,List<GFRS_Program_Audience_Group__c>> mapProgramAttende =new Map<Id,List<GFRS_Program_Audience_Group__c>>();
        List<GFRS_Program_Audience_Group__c> programAudienceGroups = new List<GFRS_Program_Audience_Group__c>([select program__c,Intended_Audience__c, Specialty__c, Category_of_Credit__c, Credit_Hours__c,Number_of_Participants__c,Expected_Learners__c,Expected_Learners_Credit__c  from GFRS_Program_Audience_Group__c where Program__c in : programIds]);
        for(Id progId : programIds)
        {
            List<GFRS_Program_Audience_Group__c> programAudienceGroupsItem=new List<GFRS_Program_Audience_Group__c>();
            for(GFRS_Program_Audience_Group__c progAud : programAudienceGroups)
            {
                if(progAud.Program__c==progId)
                {
                    programAudienceGroupsItem.add(progAud);
                }
            }
            mapProgramAttende.put(progId,programAudienceGroupsItem);
        }
        system.debug('end checking');
        //List<Integer> tmpList=mapProgramAttende.values();
        Integer iter=0;
        //end changes to SFDC-1442
        
        //changne in description problems with limit
        Map<String,String> labelAudienceGroupDescription=new Map<String,String>();
        Map<String,String> labelProgramDescription=new Map<String,String>();
        Map<String, Schema.SObjectField> schemaProgramDescribe=Schema.sObjectType.GFRS_Program__c.fields.getMap();
        for(Schema.SObjectField item:schemaProgramDescribe.values()){
            Schema.DescribeFieldResult field =item.getDescribe();
            labelProgramDescription.put(field.getName(),field.getInlineHelpText());
        }
        
        Map<String, Schema.SObjectField> schemaAudienceDescribe=Schema.sObjectType.GFRS_Program_Audience_Group__c.fields.getMap();
        for(Schema.SObjectField item:schemaAudienceDescribe.values()){
            Schema.DescribeFieldResult field =item.getDescribe();
            labelAudienceGroupDescription.put(field.getName(),field.getLabel());
        }
        //end changes
        /* id pgmId2 = null;
        if(gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c)){
            pgmId2 = Id.valueOf(this.selectedProgramId);
        } */
        
        for(GFRS_Program__c p : programsToValidate){
            //system.debug(p.Type__c);
            //System.debug( 'program:' + p );
            if(p.Type__c == null && this.request.Record_Type_name__c !='HC Char'){
                isValid = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_PROG_TYPE_REQ));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                return false;
            }
            if( p.Start_Date__c == null ){
                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_MISSING_START_DATE ));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                system.debug('Check validation: '+selectedProgramId);
                setAttachmentsForProgram(p);
                return false;
            }
            if( p.End_Date__c == null ){
                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_MISSING_END_DATE ));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                setAttachmentsForProgram(p);
                return false;
            }
            if(gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c) && !gFRS_Util.isValidCalenderDaysBetweenDates(Date.today(), p.Start_Date__c, 0)){
                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Minimum_Program_Start_Date_Error));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                setAttachmentsForProgram(p);
                return false;
            } 
           /* if(gFRS_Util.isExternalRequest(this.request.Record_Type_Name__c) && !gFRS_Util.isValidBusinessDaysBetweenDates(Date.today(), p.Start_Date__c, 20)){
                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Program_20_Days_Start_Date_Error_External));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                setAttachmentsForProgram(p);
                return false;
            } */
            if((this.request.Record_Type_name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || this.request.Record_Type_name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) && (p.Genentech_is_not_supporting_more_than_75__c == null || p.Genentech_is_not_supporting_more_than_75__c == '') && this.request.Is_there_more_than_one_event_associated__c == 'Yes'){
                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Genentech is not supporting more than seventy-five percent (75%) of the event activity? is required, please specify a value'));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                setAttachmentsForProgram(p);
                return false;
            }
            if((this.request.Record_Type_name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || this.request.Record_Type_name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) && (p.Are_there_any_other_commercial_sponsors__c == null || p.Are_there_any_other_commercial_sponsors__c == '') && this.request.Is_there_more_than_one_event_associated__c == 'Yes'){
                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, 'Are there any other commercial sponsors for the event? is required, please specify a value'));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                setAttachmentsForProgram(p);
                return false;
            }           
            //SFDC-3779 moved logic from following validation rules: 
            //Non_US_Province
                        //US_State
                        //Non_US_Province validation
                        
                        if(p.Venue_Country__c != null && p.Venue_Country__c !='United States' && 
                              (p.Venue_Province_Region__c == null || p.Venue_Province_Region__c.trim() == '')
                              && p.Start_Date__c != null){
                                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SpecifyProvinceRegion ));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                setAttachmentsForProgram(p);
                return false;
                        }
                        
                        //US_State
                        if(p.Venue_Country__c != null && p.Venue_Country__c =='United States' && 
                              (p.Venue_State__c == null || p.Venue_State__c =='')
                              && p.Start_Date__c != null){
                                isValid = false;
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SpecifyVenueState ));
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                setAttachmentsForProgram(p);
                return false;
                        }
                        
            //SFDC -1442
            if(this.request.Record_Type_name__c == gFRS_Util.TYPE_IMED){
                system.debug('in imed type');
                List<GFRS_Program_Audience_Group__c> groupAttendeeList=mapProgramAttende.get(p.Id);
                system.debug(groupAttendeeList.size());
                if(p.Program_Subtype__c==null){
                    currentProgramId=p.id;
                    selectedProgramId=(String)p.id;
                    isValid = false;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_PROG_SUBTYPE_REQ ));
                    return false;
                }
                if(groupAttendeeList.size()<1)
                {
                    system.debug('IMED record TYPE');
                    currentProgramId=p.id;
                    selectedProgramId=(String)p.id;
                    isValid = false;
                    ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_PROG_ATT_GROUP_REQ ));
                    return false;
                }
                else if(groupAttendeeList.size()>=1){
                    for(GFRS_Program_Audience_Group__c pag :groupAttendeeList){
                        if(pag.Intended_Audience__c==null)
                        {
                            
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+getFieldLabel(labelAudienceGroupDescription, 'Intended_Audience__c')+ System.Label.gFRS_PROG_ENTER_VAL ));
                            isValid= false;
                        }
                        if(pag.Specialty__c==null)
                        {
                                
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+getFieldLabel(labelAudienceGroupDescription, 'Specialty__c')+ System.Label.gFRS_PROG_ENTER_VAL ));
                            isValid= false;
                        }
                        if(pag.Category_of_Credit__c==null)
                        {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+getFieldLabel(labelAudienceGroupDescription, 'Category_of_Credit__c') + System.Label.gFRS_PROG_ENTER_VAL));
                            isValid= false;
                        }
                        if(pag.Credit_Hours__c==null)
                        {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+getFieldLabel(labelAudienceGroupDescription, 'Credit_Hours__c')+ System.Label.gFRS_PROG_ENTER_VAL ));
                            isValid= false;
                        }
                        /* with Release 3.3.0.3 fields removed from program page so validation need to be removed
                        if(pag.Number_of_Participants__c==null)
                        {   
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+getFieldLabel(labelAudienceGroupDescription, 'Number_of_Participants__c')+ System.Label.gFRS_PROG_ENTER_VAL ));
                            isValid= false;
                        }
                        */
                        if(pag.Expected_Learners__c==null)
                        {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+getFieldLabel(labelAudienceGroupDescription, 'Expected_Learners__c') + System.Label.gFRS_PROG_ENTER_VAL));
                            isValid= false;
                        }
                        /* with Release 3.3.0.3 fields removed from program page so validation need to be removed
                        if(pag.Expected_Learners_Credit__c==null)
                        {                           
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+getFieldLabel(labelAudienceGroupDescription, 'Expected_Learners_Credit__c')+ System.Label.gFRS_PROG_ENTER_VAL ));
                            isValid=false;
                        }
                        */
                        if(!isValid){
                            currentProgramId=p.id;
                            selectedProgramId=(String)p.id;
                            return false;
                        }
                    }
                }
            }
            //end changes to SFDC- 1442
            isValid &= gFRS_ProgramController.checkRequired( request.Record_Type_Name__c, p,labelProgramDescription );
            if(!isValid){
                currentProgramId=p.id;
                selectedProgramId=(String)p.id;
                system.debug('Check validation: '+selectedProgramId);
                setAttachmentsForProgram(p);
                return false;
            }else
            {
                //if(gFRS_Util.isInternalRequest(this.request.Record_Type_Name__c)){
                //  Integer programToDisplay = (getSelectedProgramById(pgmId2));
                //  this.programs[programToDisplay].Short_Start_Date_Resp__c = '';
                //}
                selectedProgramId = '';
            }
            
        }
        
        //-- validate page
        return( isValid );
    }  

    private String isZipCodeValid(GFRS_Program__c program) {
        gFRS_USPSUtils.USPSAddress uspsAddress = new gFRS_USPSUtils.USPSAddress();
        String request = gFRS_USPSUtils.buildCityStateLookupRequest(gFRS_USPSUtils.defaultUspsUsername, program.Venue_Zip_Code__c);
        String response = gFRS_USPSUtils.callUSPSApi(String.valueOf(gFRS_USPSUtils.uspsApiType.CityStateLookup), request);
        uspsAddress = gFRS_USPSUtils.parseUSPSApiCallResponse(response);

        if (String.isNotBlank(uspsAddress.errorDescription)) {
            return uspsAddress.errorDescription;
        } else if (program.Venue_City__c.toUpperCase() != uspsAddress.city.toUpperCase()) {
            return Label.gFRS_ERROR_VENUE_ZIP_OR_CITY_IS_INVALID;
        } else if (program.Venue_State__c.toUpperCase() != uspsAddress.state.toUpperCase()) {
            return Label.gFRS_ERROR_VENUE_ZIP_OR_STATE_IS_INVALID;
        }
        return null;
    }

    public static Boolean checkRequired( String recordTypeName, gFRS_Program__c p,Map<String,String> labelMap ){
        /*--
        We must allow the user to save an individual program or all programs at a time. Due to the latter,
        the form must include all programs, which SalesForce does not handle as elegantly. As the fields
        are marked as required, the validation created from salesforce is ALL checked at the same time
        instead of simply the current program (even if actionRegions are used). As the javascript validation
        cannot be temporarily enabled/disabled to work only for the current program, then the only remaining
        option is to remove all javascript validation and validate exclusively through apex.
        
        s/prog_([a-zA-Z0-9_]+)/isValid &= addRequiredMessage( p.$1 == null, Schema.sObjectType.gFRS_Program__c.fields.$1.getLabel() );/gi
        --*/
        Boolean isValid = true;
        
        if( gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals( recordTypeName ) ){
            if( p.Is_CMEO__c ){
                isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
                isValid &= addRequiredMessage( p.Product_being_Promoted__c == null, getFieldLabel(labelMap, 'Product_being_Promoted__c'));
                isValid &= addRequiredMessage( p.Booth_Type__c == null,  getFieldLabel(labelMap, 'Booth_Type__c'));
                isValid &= addRequiredMessage( p.Size_of_Exhibit__c == null, getFieldLabel(labelMap, 'Size_of_Exhibit__c'));
                isValid &= addRequiredMessage( p.Actual_Time_at_Display_Table_Hours__c == null, getFieldLabel(labelMap, 'Actual_Time_at_Display_Table_Hours__c'));
                isValid &= addRequiredMessage( p.Venue_Name__c == null,  getFieldLabel(labelMap, 'Venue_Name__c'));
                isValid &= addRequiredMessage( p.Venue_City__c == null,  getFieldLabel(labelMap, 'Venue_City__c'));
                isValid &= addRequiredMessage( p.Venue_Zip_Code__c == null, getFieldLabel(labelMap, 'Venue_Zip_Code__c') );
                isValid &= addRequiredMessage( p.Venue_Country__c == null, getFieldLabel(labelMap, 'Venue_Country__c') );
            } else {
                
            }
        } else if( gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME.equals( recordTypeName ) ){
            isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
            isValid &= addRequiredMessage( p.Expected_of_Attendees_US_Based_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_Attendees_US_Based_HCPs__c') );
            isValid &= addRequiredMessage( p.Product_being_Promoted__c == null, getFieldLabel(labelMap, 'Product_being_Promoted__c') );
            isValid &= addRequiredMessage( p.Booth_Type__c == null, getFieldLabel(labelMap, 'Booth_Type__c') );
            if(p.Booth_Type__c != 'Not Applicable'){
                    isValid &= addRequiredMessage( p.Size_of_Exhibit__c == null, getFieldLabel(labelMap, 'Size_of_Exhibit__c') );
                    isValid &= addRequiredMessage( p.Actual_Time_at_Display_Table_Hours__c == null, getFieldLabel(labelMap, 'Actual_Time_at_Display_Table_Hours__c') );
            }
            isValid &= addRequiredMessage( p.Venue_Name__c == null, getFieldLabel(labelMap, 'Venue_Name__c') );
            isValid &= addRequiredMessage( p.Venue_City__c == null, getFieldLabel(labelMap, 'Venue_City__c') );
            isValid &= addRequiredMessage( p.Venue_Zip_Code__c == null, getFieldLabel(labelMap, 'Venue_Zip_Code__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c == null, getFieldLabel(labelMap, 'Venue_Country__c') );
           // isValid &= addRequiredMessage( p.Genentech_is_not_supporting_more_than_75__c == null, getFieldLabel(labelMap, 'Genentech_is_not_supporting_more_than_75__c') );
           // isValid &= addRequiredMessage( p.Are_there_any_other_commercial_sponsors__c == null, getFieldLabel(labelMap, 'Are_there_any_other_commercial_sponsors__c') );                        
        } else if( gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME.equals( recordTypeName ) ){
            isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
            isValid &= addRequiredMessage( p.Expected_of_Attendees_US_Based_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_Attendees_US_Based_HCPs__c') );
            isValid &= addRequiredMessage( p.Booth_Type__c == null, getFieldLabel(labelMap, 'Booth_Type__c') );
            isValid &= addRequiredMessage( p.Booth_Type__c == null, getFieldLabel(labelMap, 'Booth_Type__c') );
            if(p.Booth_Type__c != 'Not Applicable'){
                /*    isValid &= addRequiredMessage( p.Size_of_Exhibit__c == null, getFieldLabel(labelMap, 'Size_of_Exhibit__c') ); */
                    isValid &= addRequiredMessage( p.Actual_Time_at_Display_Table_Hours__c == null, getFieldLabel(labelMap, 'Actual_Time_at_Display_Table_Hours__c') );
            }
            isValid &= addRequiredMessage( p.Venue_Name__c == null, getFieldLabel(labelMap, 'Venue_Name__c') );
            isValid &= addRequiredMessage( p.Venue_City__c == null, getFieldLabel(labelMap, 'Venue_City__c') );
            isValid &= addRequiredMessage( p.Venue_Zip_Code__c == null, getFieldLabel(labelMap, 'Venue_Zip_Code__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c == null, getFieldLabel(labelMap, 'Venue_Country__c') );
         //   isValid &= addRequiredMessage( p.Genentech_is_not_supporting_more_than_75__c == null, getFieldLabel(labelMap, 'Genentech_is_not_supporting_more_than_75__c') );
         //   isValid &= addRequiredMessage( p.Are_there_any_other_commercial_sponsors__c == null, getFieldLabel(labelMap, 'Are_there_any_other_commercial_sponsors__c') );                        
        }  else if( gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals( recordTypeName ) ){
            //-- start and end date
        } else if( gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals( recordTypeName ) ){
            isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
            isValid &= addRequiredMessage( p.Expected_of_Attendees_US_Based_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_Attendees_US_Based_HCPs__c') );
            isValid &= addRequiredMessage( p.Product_being_Promoted__c == null, getFieldLabel(labelMap, 'Product_being_Promoted__c') );
          /*  isValid &= addRequiredMessage( p.Size_of_Exhibit__c == null, getFieldLabel(labelMap, 'Size_of_Exhibit__c') ); */
            isValid &= addRequiredMessage( p.Number_of_Tables__c == null, getFieldLabel(labelMap, 'Number_of_Tables__c') );
            isValid &= addRequiredMessage( p.Actual_Time_at_Display_Table_Hours__c == null, getFieldLabel(labelMap, 'Actual_Time_at_Display_Table_Hours__c') );
            isValid &= addRequiredMessage( p.Venue_Name__c == null, getFieldLabel(labelMap, 'Venue_Name__c') );
            isValid &= addRequiredMessage( p.Venue_City__c == null, getFieldLabel(labelMap, 'Venue_City__c') );
            isValid &= addRequiredMessage( p.Venue_Zip_Code__c == null, getFieldLabel(labelMap, 'Venue_Zip_Code__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c == null, getFieldLabel(labelMap, 'Venue_Country__c') );
        } else if( gFRS_Util.TYPE_HC_CHAR_NAME.equals( recordTypeName ) && p.Type__c == 'Ongoing' ){
            isValid &= addRequiredMessage( p.Type__c == null, getFieldLabel(labelMap, 'Type__c') );
            isValid &= addRequiredMessage( p.Program_Title__c == null, getFieldLabel(labelMap, 'Program_Title__c') );
            isValid &= addRequiredMessage( p.Venue_Name__c == null, getFieldLabel(labelMap, 'Venue_Name__c') );
            isValid &= addRequiredMessage( p.Venue_City__c == null, getFieldLabel(labelMap, 'Venue_City__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c != null && p.Venue_Country__c == 'United States' && p.Venue_State__c == null, getFieldLabel(labelMap, 'Venue_State__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c != null && p.Venue_Country__c != 'United States' && p.Venue_Province_Region__c == null, getFieldLabel(labelMap, 'Venue_Province_Region__c') );
            isValid &= addRequiredMessage( p.Venue_Zip_Code__c == null, getFieldLabel(labelMap, 'Venue_Zip_Code__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c == null, getFieldLabel(labelMap, 'Venue_Country__c') );
            isValid &= addRequiredMessage( p.Benefits_Exchanged_for_Funding__c == null, getFieldLabel(labelMap, 'Benefits_Exchanged_for_Funding__c') );
            isValid &= addRequiredMessage( p.Other_Commercial_Supporters__c == null, getFieldLabel(labelMap, 'Other_Commercial_Supporters__c') );
            isValid &= addRequiredMessage( p.Promotional_Event_Advertising__c == null, getFieldLabel(labelMap, 'Promotional_Event_Advertising__c') );
            isValid &= addRequiredMessage( p.Other_Commercial_Supporters__c == 'Yes' && p.If_Known_List_Other_Supporters__c == null, getFieldLabel(labelMap, 'If_Known_List_Other_Supporters__c') );
            isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
            isValid &= addRequiredMessage( p.Expected_number_of_patients_engaged__c == null, getFieldLabel(labelMap, 'Expected_number_of_patients_engaged__c') );
            isValid &= addRequiredMessage( p.Expected_of_attendees_that_are_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_attendees_that_are_HCPs__c') );
            
        }else if( gFRS_Util.TYPE_HC_CHAR_NAME.equals( recordTypeName ) && p.Type__c == 'Live Activity' ){
            isValid &= addRequiredMessage( p.Type__c == null, getFieldLabel(labelMap, 'Type__c') );
            isValid &= addRequiredMessage( p.Program_Title__c == null, getFieldLabel(labelMap, 'Program_Title__c') );
            isValid &= addRequiredMessage( p.Venue_Name__c == null, getFieldLabel(labelMap, 'Venue_Name__c') );
            isValid &= addRequiredMessage( p.Venue_City__c == null, getFieldLabel(labelMap, 'Venue_City__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c != null && p.Venue_Country__c == 'United States' && p.Venue_State__c == null, getFieldLabel(labelMap, 'Venue_State__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c != null && p.Venue_Country__c != 'United States' && p.Venue_Province_Region__c == null, getFieldLabel(labelMap, 'Venue_Province_Region__c') );
            isValid &= addRequiredMessage( p.Venue_Zip_Code__c == null, getFieldLabel(labelMap, 'Venue_Zip_Code__c') );
            isValid &= addRequiredMessage( p.Venue_Country__c == null, getFieldLabel(labelMap, 'Venue_Country__c') );
            isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
            isValid &= addRequiredMessage( p.Expected_number_of_patients_engaged__c == null, getFieldLabel(labelMap, 'Expected_number_of_patients_engaged__c') );
            isValid &= addRequiredMessage( p.Expected_of_attendees_that_are_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_attendees_that_are_HCPs__c') );
            isValid &= addRequiredMessage( p.Promotional_Event_Advertising__c == null, getFieldLabel(labelMap, 'Promotional_Event_Advertising__c') );
            isValid &= addRequiredMessage( p.Benefits_Exchanged_for_Funding__c == null, getFieldLabel(labelMap, 'Benefits_Exchanged_for_Funding__c') );
            isValid &= addRequiredMessage( p.Exhibits_or_Displays_Allowed__c == null, getFieldLabel(labelMap, 'Exhibits_or_Displays_Allowed__c') );
            isValid &= addRequiredMessage( p.Other_Commercial_Supporters__c == null, getFieldLabel(labelMap, 'Other_Commercial_Supporters__c') );
            isValid &= addRequiredMessage( p.Meeting_Agenda__c == null, getFieldLabel(labelMap, 'Meeting_Agenda__c') );
            isValid &= addRequiredMessage( p.Other_Commercial_Supporters__c == 'Yes' && p.If_Known_List_Other_Supporters__c == null, getFieldLabel(labelMap, 'If_Known_List_Other_Supporters__c') );
            
            
        }else if( gFRS_Util.TYPE_HC_CHAR_NAME.equals( recordTypeName ) && p.Type__c == 'Online Resources' ){
            isValid &= addRequiredMessage( p.Type__c == null, getFieldLabel(labelMap, 'Type__c') );
            isValid &= addRequiredMessage( p.Program_Title__c == null, getFieldLabel(labelMap, 'Program_Title__c') );
            isValid &= addRequiredMessage( p.Promotional_Event_Advertising__c == null, getFieldLabel(labelMap, 'Promotional_Event_Advertising__c') );
            isValid &= addRequiredMessage( p.Benefits_Exchanged_for_Funding__c == null, getFieldLabel(labelMap, 'Benefits_Exchanged_for_Funding__c') );
            isValid &= addRequiredMessage( p.Other_Commercial_Supporters__c == null, getFieldLabel(labelMap, 'Other_Commercial_Supporters__c') );
            isValid &= addRequiredMessage( p.Other_Commercial_Supporters__c == 'Yes' && p.If_Known_List_Other_Supporters__c == null, getFieldLabel(labelMap, 'If_Known_List_Other_Supporters__c') );
            isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
            isValid &= addRequiredMessage( p.Expected_number_of_patients_engaged__c == null, getFieldLabel(labelMap, 'Expected_number_of_patients_engaged__c') );
            isValid &= addRequiredMessage( p.Expected_of_attendees_that_are_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_attendees_that_are_HCPs__c') );
            
        } else if( gFRS_Util.TYPE_IMED_NAME.equals( recordTypeName ) ){
            isValid &= addRequiredMessage( p.Expected_of_attendees_that_are_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_attendees_that_are_HCPs__c') );
            isValid &= addRequiredMessage( p.Expected_of_Attendees_US_Based_HCPs__c == null, getFieldLabel(labelMap, 'Expected_of_Attendees_US_Based_HCPs__c') );
            isValid &= addRequiredMessage( p.Speakers_Faculty__c == null, getFieldLabel(labelMap, 'Speakers_Faculty__c') );
            
            if( TYPE_WEB.equals( p.TYPE__c )){
                isValid &= addRequiredMessage( p.Web_URL__c == null, getFieldLabel(labelMap, 'Web_URL__c') );
            } else if( TYPE_ENDURING.equals( p.TYPE__c )){
                
            } else if( TYPE_LIVE.equals( p.TYPE__c )){
                if( SUB_TYPE_GRAND_ROUNDS.equals( p.Program_Subtype__c ) || SUB_TYPE_MEETING_SERIES.equals( p.Program_Subtype__c )){
                    //-- live1
                    isValid &= addRequiredMessage( p.Venue_Type__c == null, getFieldLabel(labelMap, 'Venue_Type__c') );
                    isValid &= addRequiredMessage( p.Number_of_Activities__c == null, getFieldLabel(labelMap, 'Number_of_Activities__c') );
                } else {
                    //-- live2
                    isValid &= addRequiredMessage( p.Venue_Name__c == null, getFieldLabel(labelMap, 'Venue_Name__c') );
                    isValid &= addRequiredMessage( p.Venue_City__c == null, getFieldLabel(labelMap, 'Venue_City__c') );
                    isValid &= addRequiredMessage( p.Venue_Zip_Code__c == null, getFieldLabel(labelMap, 'Venue_Zip_Code__c') );
                    isValid &= addRequiredMessage( p.Venue_Country__c == null, getFieldLabel(labelMap, 'Venue_Country__c') );
                }
            }
        } else if( gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals( recordTypeName ) ){
            isValid &= addRequiredMessage( p.Expected_Number_of_Attendees__c == null, getFieldLabel(labelMap, 'Expected_Number_of_Attendees__c') );
        } else if( gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME.equals( recordTypeName ) ){
            //-- start date, end date
        }
        return( isValid );
    }
    
    /**
     *  Method to add a message if shouldAddMessage = false
     *  <p>The reason for shouldAddMessage is to avoid having if() statements before calling it each time
     *  and reduce the burden to get better test coverage</p>
     *  @param shouldAddMessage (Boolean) whether an apex pagemessage should be added
     *  @param fieldName (String) - Client visible name of the field that is required and had no value
     *  @return Boolean - returns shouldAddMessage
     **/
    public static Boolean addRequiredMessage( Boolean shouldAddMessage, String fieldName ){
        if( shouldAddMessage ) ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, '' + fieldName +' '+ System.Label.gFRS_FIELD_NAME_REQUIRED ));
        return( !shouldAddMessage );
    }
    
    /** Check if user should be redirected to confirmation page **/
    public ApexPages.PageReference checkValidPage(){ 
        return (null);
    }
    public static string getFieldLabel(Map<String,String> item,string field){
        if(item.containsKey(field)){
            return item.get(field);
        }else{
            return '';
        }   
    }
    
    /**
    * @author ADMD Team
    * @date 20/03/2013
    * @description getAvalableProgramTypes method -  get Available program types for HC Char 
    */
    public List<SelectOption> getAvalableProgramTypes() {
        final List<SelectOption> options = new List<SelectOption>();
        if (request.Event_Project_type__c == 'Patient Support' &&
            request.Event_Project_sub_type__c == 'Patient Services (e.g., nutrition support, transportation)' ||
            request.Event_Project_type__c == 'Patient and General Disease Education'
        ) {
            options.add(new SelectOption('Live Activity', 'Live Activity'));
            options.add(new SelectOption('Ongoing', 'Ongoing'));
            options.add(new SelectOption('Online Resources', 'Online Resources'));
        } else
        if (request.Event_Project_type__c == 'Patient Support' &&
            request.Event_Project_sub_type__c == 'Financial Assistance' ||
            request.Event_Project_type__c == 'General organizational support'
        ) {
            options.add(new SelectOption('Ongoing', 'Ongoing'));
        } else
        if (request.Event_Project_type__c == 'Patient Support' &&
            (request.Event_Project_sub_type__c == 'Patient Navigation' || request.Event_Project_sub_type__c == 'Survivorship' || request.Event_Project_sub_type__c == 'Counseling Assistance (includes peer-to-peer, camps, etc.)')
        ) {
            options.add(new SelectOption('Live Activity', 'Live Activity'));        
            options.add(new SelectOption('Ongoing', 'Ongoing'));
            options.add(new SelectOption('Online Resources', 'Online Resources'));            
        } else
        if (request.Event_Project_type__c == 'Policy and Advocacy' &&
            (request.Event_Project_sub_type__c == 'Grassroots mobilization (e.g., advocate education)' || request.Event_Project_sub_type__c == 'Federal and state legislative advocacy programming (e.g., Hill Days)')
        ) {
            options.add(new SelectOption('Live Activity', 'Live Activity'));        
            options.add(new SelectOption('Ongoing', 'Ongoing'));
            options.add(new SelectOption('Online Resources', 'Online Resources'));            
        } else
        if (request.Event_Project_type__c == 'Policy and Advocacy' &&
            request.Event_Project_sub_type__c == 'Evidence generation in policy (e.g., issue briefs, info graphics)'
        ) {        
            options.add(new SelectOption('Ongoing', 'Ongoing'));
            options.add(new SelectOption('Online Resources', 'Online Resources'));            
        } else {
            options.add(new SelectOption('Live Activity', 'Live Activity')); 
        }
        return options;
    }
    
     /**
    * @author ADMD Team
    * @date 20/03/2013
    * @description changeProgramType method -  executed when program type for HC Char was changed
    *       
    */
    
    public ApexPages.PageReference changeProgramType()
    {   
        Pagereference pageRef = Apexpages.currentPage();
        pageRef.getParameters().put('selectedProg', this.selectedProgramId);
        
        gFRS_Program__c partialProgram = programsMap.get(Id.valueOf(selectedProgramId));
        resetUnusedFieldForHCChar(partialProgram);
        this.scrollToProgram = true;
        this.scrollToInputField = false;
        system.debug('check values');
        system.debug(this.selectedProgramId);
        system.debug(this.hcCharProgType);
        
        gFRS_Util_NoShare.saveLockedPrograms(new List<gFRS_Program__c>{partialProgram});
        return pageRef;
    }
    
    /**
    * @author ADMD Team
    * @date 20/03/2013
    * @description goToNextIMEDProgram method -  expands nex accortion with program
    *       
    */
    
    public ApexPages.PageReference goToNextIMEDProgram(){
        this.currentProgramId=null;
        return null;
    }
    
    
    /**
    * @author ADMD Team
    * @date 20/03/2013
    * @description goToNextHCCharProgram method -  expands nex accordion with program    
    */  
    public ApexPages.PageReference goToNextHCCharProgram(){
        if(this.selectedProgramId != null){
    
            GFRS_Program__c partial = programsMap.get(Id.valueOf(this.selectedProgramId));

            setAttachmentsForProgram(partial);
            
            Pagereference pageRef = Apexpages.currentPage();
            pageRef.getParameters().put('selectedProg', this.selectedProgramId);
            pageRef.getParameters().put('selectedProgType', partial.Type__c);
            this.scrollToProgram=true;
            this.scrollToInputField=false;
             
            return pageRef;
        }
        return  Apexpages.currentPage();
    }
    
    /**
    * @author ADMD Team
    * @date 04/11/2013
    * @description goToNextHCCharProgram method -  expands nex accordion with program  while Viewing Funding Request  
    */  
    public ApexPages.PageReference continueToNextHCCharProgram(){

        if(this.selectedProgramId != null){
                        Integer programToDisplay = (getSelectedProgramById(this.selectedProgramId)+1);

            GFRS_Program__c partial = this.programs.get(programToDisplay);
            
            setAttachmentsForProgram(partial);
            
            this.selectedProgramId = partial.Id;
            
            Pagereference pageRef = Apexpages.currentPage();
                pageRef.getParameters().put('selectedProg', this.selectedProgramId);
            pageRef.getParameters().put('selectedProgType', partial.Type__c);
            this.scrollToProgram = true;
            this.scrollToInputField = false;
            
            
             
            return pageRef;
        }
        return  Apexpages.currentPage();
    }
  
    
    /**
    * @author ADMD Team
    * @date 31/10/2013
    * @description goToPreviousHCCharProgram method -  expands previous accordion with program   
    */
    public ApexPages.PageReference goToPreviousHCCharProgram(){
        
        system.debug('PN:IndexOfPrev: ' + this.selectedProgramId);
        if(this.selectedProgramId != null){
                        Integer programToDisplay = (getSelectedProgramById(this.selectedProgramId)-1);

            GFRS_Program__c partial = this.programs.get(programToDisplay);
            
            setAttachmentsForProgram(partial);
            
            this.selectedProgramId = partial.Id;
            
            Pagereference pageRef = Apexpages.currentPage();
                pageRef.getParameters().put('selectedProg', this.selectedProgramId);
            pageRef.getParameters().put('selectedProgType', partial.Type__c);
            this.scrollToProgram = true;
            this.scrollToInputField = false;
            
            
             
            return pageRef;
        }
        return  Apexpages.currentPage();
    }
    
    /**
    * @author ADMD Team
    * @date 20/03/2013
    * @description getSelectedProgramById method - returns index of corresponding accordion
    * where  program is placed.      
    */
    
    public Integer getSelectedProgramById(Id progId){
        Integer i=0;
        for(GFRS_Program__c item: this.programs){
                if(item.id==progId){
                        return i;
                }
                i++;    
        }
        return i;
    }
    
    /**
    * @author ADMD Team
    * @date 20/03/2013
    * @description setAttachmentsForProgram method - set attachment for passed program    
    */
    
    public void setAttachmentsForProgram(GFRS_Program__c partial){
        if(this.request !=null && this.request.Record_Type_name__c == gFRS_Util.TYPE_HC_CHAR_NAME){
            GFRS_Program__c selectedProgram=null;
            if(partial == null){
                partial=this.programs[0];
            }
            GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( [select id,ParentID,name, Description, CreatedDate from Attachment where ParentId=:partial.id ] );
      for (String apiName : this.apiNamesList) {
        apiNameToAttachmentMap.put(apiName,attachmentCollector.getFoundAttachmentByKeyOrMakeOne( (String)partial.get(apiName), partial.id ));
      }
        }
        
        //System.debug('PN:DEBUG:attachmentPromoEvent' + attachmentPromoEvent);
    }
    
    /**
    * @author ADMD Team
    * @date 21/03/2013
    * @description checkIfValidHCType method - checks if program type is vailid with HC Char program   
    */
    
    public Boolean checkIfValidHCType(string progType){
        
        if(progType == 'Live' || progType == 'Web' || progType == 'Enduring' ){
                return false;
        } 
        return true;
    }
    
    /**
    * @author ADMD Team
    * @date 20/03/2013
    * @description resetUnusedFieldForHCChar method - reset fields for HC Char programs if field Type__c will be changed  
    */    
    public void resetUnusedFieldForHCChar(GFRS_Program__c partial){
        if(partial.Type__c == 'Live Activity' || partial.Type__c == 'Ongoing'){
            partial.Web_URL__c = null;            
        }else if(partial.Type__c == 'Online Resources'){
            partial.Venue_Name__c = null;
            partial.Venue_City__c = null;
            partial.Venue_State__c = null;
            partial.Venue_Province_Region__c = null;
            partial.Venue_Zip_Code__c = null;
            partial.Venue_Country__c = null;
        }
        
        if(partial.Type__c == 'Online Resources' || partial.Type__c == 'Ongoing'){
            partial.Exhibits_or_Displays_Allowed__c = null;          
        }            
    }
    
    
    /**
    * @author ADMD Team
    * @date 15/10/2013
    * @description deleteAttachments method - deletes unneeded attachments after changing Program Type for HC
    */  
    private void deleteAttachments(Id attachmentId){
        Attachment attachmentToDelete = [SELECT Id FROM Attachment WHERE Id =:attachmentId];
        gFRS_Util_NoShare.deleteLockedAttachment(attachmentToDelete);
    }
    
    public void deleteRequestBudgetIfExist(Id requestId,String deletedProgramType){
        List<GFRS_RequestBudget__c> potentialBudgetToDelete=new List<GFRS_RequestBudget__c>();
        for(GFRS_RequestBudget__c budget:[select Id, Type__c from GFRS_RequestBudget__c where Grant_Request__c = : requestId]){
                if(budget.Type__c == deletedProgramType ){
                        potentialBudgetToDelete.add(budget);
                }
        }
        
        if(getExistingProgramsByType(deletedProgramType) == 0 && potentialBudgetToDelete.size()>0){
                gFRS_Util_NoShare.removeLockedBudget(potentialBudgetToDelete);
        }
    }
    
    public Integer getExistingProgramsByType(String deletedProgramType){
        Integer programCountByType=0;
        for(GFRS_Program__c prog: this.programs){
                if(prog.Type__c==deletedProgramType){
                        programCountByType++;
                }
        }
        return programCountByType;
    }
    
    public void removeBudgetIfProgramTypeWasChanged(){
        List<GFRS_RequestBudget__c> potentialBudgetToDelete=new List<GFRS_RequestBudget__c>();
        Map<String,Integer> programTypeCounter = new Map<String,Integer>();
        for(GFRS_Program__c prog : this.programs){
                if(!programTypeCounter.containsKey(prog.Type__c)){
                        programTypeCounter.put(prog.Type__c,1);
                }
        }
        
        for(GFRS_RequestBudget__c budget:[select Id, Type__c from GFRS_RequestBudget__c where Grant_Request__c = : this.request.id]){
                if(!programTypeCounter.containsKey(budget.Type__c)){
                        potentialBudgetToDelete.add(budget);
                }
        }
        if(potentialBudgetToDelete.size()>0){
                try{
                        gFRS_Util_NoShare.removeLockedBudget(potentialBudgetToDelete);  
                }catch(Exception ex){
                        system.debug('there was problem with deleting budgets');
                }
                
        }
    } 
    
    

    
    public void uploadAttachment() {
      Attachment newAttachment = gFRS_AttachmentUploadUtil.uploadAttachment(this.selectedProgramId,this.request.Id,apiName,this.apiNameToAttachmentMap.get(apiName), gFRS_Util_NoShare.checkIsRFI(this.request.Id));
    if (newAttachment != null) {
      this.apiNameToAttachmentMap.put(apiName,newAttachment);
      this.programsMap.get(this.selectedProgramId).put(apiName, newAttachment.Id);
    }
  }
    
   

        public void createProgramDesignIfNotExists(){
            try{
                List<gFRS_Program_Design_and_Implementation__c> requestProgramDesigns = 
                new List<gFRS_Program_Design_and_Implementation__c>([SELECT id
                                            FROM  gFRS_Program_Design_and_Implementation__c
                                            WHERE gFRS_Funding_Request__c =: this.request.id                     
                                     ]);
                if(requestProgramDesigns.size() == 0){
                    gFRS_Program_Design_and_Implementation__c programDesign = new gFRS_Program_Design_and_Implementation__c(gFRS_Funding_Request__c=request.id);
                    insert programDesign;
                }            
            } catch(Exception e) {
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot create program design record!'));
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }
}