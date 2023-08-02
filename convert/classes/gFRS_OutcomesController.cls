/**
* @author GFRS Dev Team
* @date 25/09/2013
* @description gFRS_OutcomesController class - controller for GFRS_Outcomes page. Class is responsible for handling request from page and communication with webservices and database. 
*/
public with sharing class gFRS_OutcomesController {
    
    private static final String FUNDING_REQUEST_API_NAME = 'GFRS_Funding_Request__c';
    
    // request outcomes section
    private static final String LEARNING_LEVEL_3_API_NAME = 'Learning_Level_3__c';  
    private static final String COMPETENCE_LEVEL_4_API_NAME = 'Competence_Level_4__c';
    private static final String PERFORMANCE_LEVEL_5_API_NAME = 'Performance_Level_5__c';
    private static final String PATIENT_HEALTH_LEVEL_6_API_NAME = 'Patient_Health_Level_6__c';
    private static final String COMMUNITY_HEALTH_LEVEL_7_API_NAME = 'Community_Health_Level_7__c';
    private static final String Outcomce_Report_API_NAME = 'Outcomes_Report__c';
    private static final String Quality_of_Care_Report_API_NAME = 'Quality_of_Care_Report__c';
    private static final String Competencies_Report_Report_API_NAME = 'Competencies_Report__c';
    
    // competencies section
    private static final String PATIENT_CARE_API_NAME = 'Patient_Care__c';
    private static final String MEDICAL_KNOWLEDGE_API_NAME = 'Medical_Knowledge__c';
    private static final String PRACTICE_BASED_LEARNING_AND_MANAGEMENT_API_NAME = 'Practice_based_Learning_and_Management__c';
    private static final String INTERPERSONAL_AND_COMMUNICATION_SKILLS_API_NAME = 'Interpersonal_and_Communication_Skills__c';
    private static final String PROFESSIONALISM_API_NAME = 'Professionalism__c';
    private static final String SUMMARY_OF_RESEARCH_RESULTS_API_NAME = 'Summary_of_Research_Results__c';
    
    //Funding Request attachments API Names GFRS-751
    private static final String SUMMARY_OF_RESULTS_API_NAME      = 'Evaluation_Summary_of_results_file__c';
    private static final String OTHER_OUTPUTS_API_NAME           = 'Evaluation_Other_outputs_file__c';
    private static final String ADDITIONAL_ATTACHMENT1_API_NAME  = 'Evaluation_Additional_attachment_1__c';
    private static final String ADDITIONAL_ATTACHMENT2_API_NAME  = 'Evaluation_Additional_attachment_2__c';
    private static final Set<String> FILETYPES = new Set<String>{'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'pdf', 'png', 'jpg', 'jpeg', 'txt'};
        
  /** current funding Request **/
  public GFRS_Funding_Request__c request { get; set; }
  
  /** current Program **/
  public GFRS_Program__c[] programs { get; set; }
  
  /** audience to be displayed**/
  public GFRS_Program_Audience_Group__c[] audience { get; set; }
  
  /** final page to move to after completing the page **/
  public static final String PATH_COMPLETE = '/apex/GFRS_Home';
      
  /** for current program **/
  public Id selectedProgramId { get; set; }
  public Boolean isLastProgramSelected { get; set; }
  //variables needed to SFDC-1396
  public Boolean scrollToSection1{get;set;}
  public Boolean scrollToSection2{get;set;}
  //end SFDC-1396
  
  public Boolean showPrograms{ get;set; } 
  public Boolean showAttachments{ get;set; }
  public string pathHome {get; set; }
  
  //-- attachments
  
  // request evaluation summary, outputs etc GFRS-751
  public Boolean saveAndContinue {get; set; }
  public Attachment attachmentSummaryOfResults { get; set; }
  public Attachment attachmentOtherOutputs { get; set; }
  public Attachment attachmentAdditional1 { get; set; }
  public Attachment attachmentAdditional2 { get; set; }
  public Map<String,Attachment> apiNameToAttachmentMap = new Map<String,Attachment>();
  public Map<String,Boolean> apiNameToChangedFlagMap = new Map<String,Boolean>{
            SUMMARY_OF_RESULTS_API_NAME => false, 
            OTHER_OUTPUTS_API_NAME => false, 
            ADDITIONAL_ATTACHMENT1_API_NAME => false,
            ADDITIONAL_ATTACHMENT2_API_NAME => false};
    
  public Attachment outcomesreportid { get; set; }
  
  public Attachment qualitycareid { get; set; }
  public Attachment competenciesid { get; set; }
  
  public Attachment attachmentPractice { get; set; }

  
  public Attachment attachmentSummaryOfResearchResult { get; set; }
  
  public Boolean meetingPresentationsRequired {set; get;}
  public String foundation {get;set;}
  public decimal amountUsed {get;set;}
  public decimal refundDue {get;set;}
  public String usedAmt {get;set;}
  public String refundDueAmt {get;set;}
  public String meetingPresentations {get;set;}
  public String refundAccountInfo {get;set;}
  
  Map<String,String> apiNameToLabelMapRequest;

  /** determines whether the page currently has messages **/
  public Boolean hasMessages {
      get { return( ApexPages.hasMessages() ); }
  }

  public gFRS_OutcomesController( ApexPages.StandardController std ){
      this.scrollToSection1=false;
      this.scrollToSection2=false;
      this.saveAndContinue = false;
      this.request = (GFRS_Funding_Request__c)std.getRecord();
      
        if (this.request.id == null ) {
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Funding request was not sent' ));
          return;
      }       
          
        this.showPrograms = true;
        this.showAttachments = false;
        this.pathHome = gFRS_Util.initializeLink( PATH_COMPLETE, null, null );

        try {
          //-- add in all fields since unknown which fields are used in field sets ...
          this.request = refreshFundingRequest(this.request.Id);

        }
        catch ( Exception err ) {
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding request' ));
          return;
      }
      if(this.request.Foundation_Classified__c == 'FALSE'){
          this.foundation = 'Genentech Inc.';
      } else {
          this.foundation = 'Genentech Foundation';
      }
  
      try {
            this.programs = [ SELECT
                              Name, Activity_Address_Overcoming_Barrier_AAS__c, MOC_Competencies_Patient_Care__c, Number_of_Respondents_CVI__c,
                              Average_Number_of_Patients__c,  MOC_Competencies_Practice_based__c, Number_of_Respondents_LOA__c,
                              Average_Years_in_Practice__c, MOC_Competencies_Professionalism__c,  PCC_Care_Management__c,
                              Barriers_PC_Access_to_equipment__c, MOC_Competencies_Systems_based__c,  PCC_Expectations__c,
                              Barriers_PC_Access_to_treatment_or_clini__c,  NQS_Affordability__c, PCC_Family_Engagement__c,
                              Barriers_PC_Conflicting_evidence__c,  NQS_Best_Practices_Healthy_Living__c, PCC_Palliative_and_EOL_Care__c,
                              Barriers_PC_Cost_of_therapy__c, NQS_Comm_and_Care_Coordination__c,  PCC_Patient_Education__c,
                              Barriers_PC_Lack_of_training__c,  NQS_Comm_Coor_Care_Transitions__c,  PCC_Shared_Decision_Making__c,
                              Barriers_PC_None_were_identified__c,  NQS_Comm_Coor_Communication__c, Percent_Responding_CIP__c,
                              Barriers_PC_Patient_adhearance__c,  NQS_Comm_Coor_Cross_provider_Coor__c, Percent_Responding_CR__c,
                              Barriers_PC_Patient_knowledge__c, NQS_Comm_Coor_Other__c, Percent_Responding_CVI__c,
                              Barriers_PC_Staffing__c,  NQS_Patient_and_Family_Engagement__c, Percent_Responding_LOA__c,
                              Did_Content_Contribute_Valuable_Info_CVI__c,  NQS_Patient_Safety__c,  Program_Subtype__c,
                              End_Date__c,  NQS_Prevention_Treatment_Practices__c,
                              Id, NQS_Safety_Hospital_Admissions__c,  Start_Date__c,
                              Is_the_Content_Relevant_to_Practice_CR__c,  NQS_Safety_Other__c,  Total_Number_of_Participants__c,
                              MOC_Competencies_Communication_Skills__c, NQS_Safety_Unnecessary_Care__c, Total_Visits__c,
                              MOC_Competencies_Medical_Knowledge__c,  Number_of_Learners_Receiving_CME_Credits__c,  Type__c,
                              MOC_Competencies_Other__c,  Number_of_Pages_Viewed__c,  Venue_City__c,
                              Were_Learning_Objectives_Achieved_LOA__c, Number_of_Respondents_CIP__c, Venue_State__c,
                              Will_Content_Impact_Your_Practice_CIP__c, Number_of_Respondents_CR__c,  Web_URL__c
                              FROM GFRS_Program__c
                              WHERE
                              Funding_Request__c = :this.request.id
                                                   // AND ((Type__c =: 'Live' AND  Program_Status__c =: 'Completed') OR (Type__c !=: 'Live' AND Program_Status__c =: 'Confirmed'))
          ];
          
          gFRS_Configuration__mdt refundAccountInfoMdt = [select DeveloperName, Long_Text_Field__c from gFRS_Configuration__mdt where DeveloperName = 'gFRS_Evaluation_Account_Info'];
          this.refundAccountInfo = refundAccountInfoMdt.Long_Text_Field__c;
        }
        catch ( Exception err ) {
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the programs' ));
          return;
      }
      
      try {
          //TODO - select to be corrected when more details will be known....         
            this.audience = [SELECT Specialty__c, Program__c, Other__c, Number_of_Speaking__c, Number_of_Participants__c, Actual_Learners__c,
                             Name, Invitations_Distributed__c, Intended_Audience__c, Id, Expected_Learners__c, Expected_Learners_Credit__c,
                             Credit_Hours__c, Category_of_Credit__c, Actual_Number_Participants__c, Actual_Learners_with_Credit__c
                             FROM GFRS_Program_Audience_Group__c
                             WHERE Program__r.Funding_Request__c = :this.request.Id
                                     LIMIT 10];
        }
        catch ( Exception err ) {
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the audience' ));
          return;
      }
      
        List<Attachment> listOfRequestAttachments = [SELECT Id, ParentID, Name FROM Attachment WHERE Id IN :getAttachmentIds()];
      //-- organize attachments
      GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( listOfRequestAttachments );
      
      // request evaluation summary, outputs etc GFRS-751
      this.attachmentSummaryOfResults = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Evaluation_Summary_of_results_file__c, this.request.id );
      this.attachmentOtherOutputs = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Evaluation_Other_outputs_file__c, this.request.id );
      this.attachmentAdditional1 = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Evaluation_Additional_attachment_1__c, this.request.id );
      this.attachmentAdditional2 = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Evaluation_Additional_attachment_2__c, this.request.id );
      
      // request outcomes section
     
      this.outcomesreportid = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Outcomes_Report__c, this.request.id );
      this.qualitycareid = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Quality_of_Care_Report__c, this.request.id );
      this.competenciesid = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Competencies_Report__c, this.request.id );
      
      this.attachmentSummaryOfResearchResult = attachmentCollector.getFoundAttachmentByKeyOrMakeOne( this.request.Summary_of_Research_Results__c, this.request.id );
      
      apiNameToLabelMapRequest = gFRS_Util_NoShare.getFieldLabelsMapForGivenObject(FUNDING_REQUEST_API_NAME);
      
      if( this.request.Meeting_Presentations__c == 'Yes' ){
        meetingPresentationsRequired = true;    
      }
      
  }
  
    private Set<Id> getAttachmentIds() {
    
        Set<Id> setAttachmentIds = new Set<Id> {
            this.request.Learning_Level_3__c,
            this.request.Competence_Level_4__c,
            this.request.Performance_Level_5__c,
            this.request.Patient_Health_Level_6__c,
            this.request.Community_Health_Level_7__c,
            this.request.Outcomes_Report__c,
            this.request.Quality_of_Care_Report__c,
            this.request.Competencies_Report__c,
            this.request.Patient_Care__c,
            this.request.Medical_Knowledge__c,
            this.request.Practice_based_Learning_and_Management__c,
            this.request.Interpersonal_and_Communication_Skills__c,
            this.request.Professionalism__c,
            this.request.Summary_of_Research_Results__c,
            this.request.Evaluation_Summary_of_results_file__c,
            this.request.Evaluation_Other_outputs_file__c,
            this.request.Evaluation_Additional_attachment_1__c,
            this.request.Evaluation_Additional_attachment_2__c
        };
        
        return setAttachmentIds;
  }
  
  private GFRS_Funding_Request__c refreshFundingRequest(Id fundingRequestId){
    
    final List<String> fields = new List<String> {
        'Name',
        'Outcomes__c',
        'Sub_Status__c',
        'Issue_type__c',
        'Patient_Care__c',
        'Best_practices__c',
        'Were_Goals_Met__c',
        'Outcomes_Report__c',
        'Outcomes_Levels__c',
        'Professionalism__c',
        'Learning_Level_3__c',
        'Record_Type_Name__c',
        'Specific_Meetings__c',
        'Medical_Knowledge__c',
        'Is_Outcomes_In_RFI__c',
        'Competence_Level_4__c',        
        'Competencies_Report__c',
        'External_Sub_status__c',
        'Event_Program_Title__c',
        'Performance_Level_5__c',
        'Evaluation_Completed__c',
        'Upcoming_Publications__c',
        'Meeting_Presentations__c',
        'Patient_Health_Level_6__c',
        'Quality_of_Care_Report__c',
        'IsValidationExternalOnly__c',
        'Community_Health_Level_7__c',
        'Outcomes_Submission_Status__c',
        'Education_Capacity_Building__c',
        'Summary_of_Research_Results__c',
        'Free_or_reduced_lunch_actual__c',
        'Were_Outcome_Levels_Achieved__c',
        'Evaluation_Other_outputs_file__c',
        'Program_scale_and_replication__c',
        'Highest_Outcome_Level_Achieved__c',
        'Genentechs_unique_contribution__c',
        'Actual_number_of_teachers_served__c',
        'Actual_number_of_students_served__c',
        'Capacity_building_support_actual__c',
        'State_Why_Level_3_7_Not_Achieved__c',
        'Actual_number_of_patients_served__c',
        'Evaluation_Additional_attachment_2__c',
        'Evaluation_Additional_attachment_1__c',
        'Briefly_Describe_Goals_Met_to_Date__c',
        'Evaluation_Summary_of_results_file__c',
        'Briefly_Describe_Lessons_Goals_Unmet__c',
        'Interpersonal_and_Communication_Skills__c',
        'Practice_based_Learning_and_Management__c',
        'Actual_number_of_attendees_people_served__c',
        'Evaluation_submitted_date__c',
        'Expected_number_of_attendees_people__c',
        'Expected_number_of_patients__c',
        'Expected_number_of_students__c',
        'Expected_number_of_teachers__c',
        'Were_Total_Funds_Used__c',
        'Total_Amount_Used__c',
        'Total_Amount_Funded__c',
        'Refund_Due__c',
        'Approved_Amount__c',
        'Foundation_Classified__c'
    };

    String queryString = 'Select ' + String.join(fields, ', ') + ' from GFRS_Funding_Request__c where Id = :fundingRequestId LIMIT 1';

    return Database.query(queryString);
  }
  

  
  // GFRS-751
  public Attachment validateAttachment(String apiName) {
    String[] name = apiNameToAttachmentMap.get(apiName).name.split('\\.'); 
    try {
        if (FILETYPES.contains(name[name.size()-1])) {  //check type by suffix in the name
            apiNameToAttachmentMap.get(apiName).Description = apiNameToLabelMapRequest.get(apiName.toLowerCase());
            upsert apiNameToAttachmentMap.get(apiName);
            apiNameToAttachmentMap.get(apiName).body = null;
            
            GFRS_Funding_Request__c partialRequest = [ select id from GFRS_Funding_Request__c where id = :this.request.id ];
            partialRequest.put(apiName, apiNameToAttachmentMap.get(apiName).id);
            partialRequest.IsValidationExternalOnly__c='Yes';
            update partialRequest;
        } else {
            GFRS_AttachmentCollector attachmentCollector = new GFRS_AttachmentCollector( [SELECT Id, ParentID, Name FROM Attachment WHERE Id = :(Id)this.request.get(apiName)]);
            apiNameToAttachmentMap.put(apiName, attachmentCollector.getFoundAttachmentByKeyOrMakeOne( (Id)this.request.get(apiName), this.request.id ));    //set the last correct attachment
            ApexPages.addMessage(  new ApexPages.Message( ApexPages.Severity.ERROR, apiNameToLabelMapRequest.get(apiName.toLowerCase())+': filetype not accepted' ) ) ;
        }
    } catch ( Exception err ) {
        ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
    } finally {
        if (apiNameToAttachmentMap.get(apiName)!=null && apiNameToAttachmentMap.get(apiName).body!=null)apiNameToAttachmentMap.get(apiName).body = null;
    }
    return apiNameToAttachmentMap.get(apiName);
  }
  
  
  public void validateSummaryOfResults(){
    apiNameToAttachmentMap.put(SUMMARY_OF_RESULTS_API_NAME, attachmentSummaryOfResults);
    attachmentSummaryOfResults = validateAttachment(SUMMARY_OF_RESULTS_API_NAME);
  }
  
  public void validateOtherOutputs(){
    apiNameToAttachmentMap.put(OTHER_OUTPUTS_API_NAME, attachmentOtherOutputs);
    attachmentOtherOutputs = validateAttachment(OTHER_OUTPUTS_API_NAME);
  }
  
  public void validateAdditional1(){
    apiNameToAttachmentMap.put(ADDITIONAL_ATTACHMENT1_API_NAME, attachmentAdditional1);
    attachmentAdditional1 = validateAttachment(ADDITIONAL_ATTACHMENT1_API_NAME);
  }
  
  public void validateAdditional2(){
    apiNameToAttachmentMap.put(ADDITIONAL_ATTACHMENT2_API_NAME, attachmentAdditional2);
    attachmentAdditional2 = validateAttachment(ADDITIONAL_ATTACHMENT2_API_NAME);
  }
  //GFRS-751 END

  
  /**
    * @author ADMD Team
    * @date 03/02/2014
    * @description uploadPatientCare method - upload patient care attachment
    */
  public void uploadOutcomesReport(){
      this.scrollToSection2=true;
      try{
        this.outcomesreportid.Description = apiNameToLabelMapRequest.get(Outcomce_Report_API_NAME.toLowerCase()); 
          upsert this.outcomesreportid;
          this.outcomesreportid.body = null;
          
          GFRS_Funding_Request__c partialRequest = [ select id from GFRS_Funding_Request__c where id = :this.request.id ];
          partialRequest.Outcomes_Report__c = this.outcomesreportid.id;
          update partialRequest;
        }
        catch ( Exception err ) {
          ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
      } finally {
        if (this.outcomesreportid != null && this.outcomesreportid.body != null) this.outcomesreportid.body = null;
      }
  }
  
  
   /**
    * @author ADMD Team
    * @date 03/02/2014
    * @description uploadPatientCare method - upload patient care attachment
    */
  public void uploadQualityCareReort(){
      this.scrollToSection2=true;
      try{
        this.qualitycareid.Description = apiNameToLabelMapRequest.get(Quality_of_Care_Report_API_NAME.toLowerCase()); 
          upsert this.qualitycareid;
          this.qualitycareid.body = null;
          
          GFRS_Funding_Request__c partialRequest = [ select id from GFRS_Funding_Request__c where id = :this.request.id ];
          partialRequest.Quality_of_Care_Report__c = this.qualitycareid.id;
          partialRequest.IsValidationExternalOnly__c='Yes';
          update partialRequest;
        }
        catch ( Exception err ) {
          ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
      } finally {
        if (this.qualitycareid != null && this.qualitycareid.body != null) this.qualitycareid.body = null;
      }
  }
  
   
   /**
    * @author ADMD Team
    * @date 03/02/2014
    * @description uploadPatientCare method - upload patient care attachment
    */
  public void uploadCompetenciesReport(){
      this.scrollToSection2=true;
      try{
        this.competenciesid.Description = apiNameToLabelMapRequest.get(Competencies_Report_Report_API_NAME.toLowerCase()); 
          upsert this.competenciesid;
          this.competenciesid.body = null;
          
          GFRS_Funding_Request__c partialRequest = [ select id from GFRS_Funding_Request__c where id = :this.request.id ];
          partialRequest.Competencies_Report__c = this.competenciesid.id;
          partialRequest.IsValidationExternalOnly__c='Yes';
          update partialRequest;
        }
        catch ( Exception err ) {
          ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
      } finally {
        if (this.competenciesid != null && this.competenciesid.body != null) this.competenciesid.body = null;
      }
  }
  
    /**
    * @author ADMD Team
    * @date 24/02/2014
    * @description uploadProfesionalism method - upload professionalism attachment
  */ 
  public void uploadSummaryOfResearchResult(){
      this.scrollToSection2 = true;
      try{
            
        this.attachmentSummaryOfResearchResult.Description = apiNameToLabelMapRequest.get(SUMMARY_OF_RESEARCH_RESULTS_API_NAME.toLowerCase());
        
        
        System.debug('PN********* UPLOAD 1111: ' + attachmentSummaryOfResearchResult);
        
        
          upsert this.attachmentSummaryOfResearchResult;
          this.attachmentSummaryOfResearchResult.body = null;
          
           System.debug('PN********* UPLOAD 2222: ' + this.attachmentSummaryOfResearchResult);
          
          GFRS_Funding_Request__c partialRequest = [ SELECT Id FROM GFRS_Funding_Request__c WHERE Id = :this.request.Id ];
          partialRequest.Summary_of_Research_Results__c = this.attachmentSummaryOfResearchResult.Id;
          partialRequest.IsValidationExternalOnly__c='Yes';
          update partialRequest;
          
          System.debug('PN********* UPLOAD 3333: ' + partialRequest);
        }
        catch ( Exception err ) {
          ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
      } finally {
        if (this.attachmentSummaryOfResearchResult!=null && this.attachmentSummaryOfResearchResult.body != null) this.attachmentSummaryOfResearchResult.body = null;
      }
  }
  
  

  /**
    * @author ADMD Team
    * @date 12/08/2013
    * @description saveProgram method - saves a program
  */ 
  public ApexPages.PageReference saveProgram(){

     String myVal = '' + this.request.id;
      Id idSelectedProgram = null;
      try {
          idSelectedProgram = Id.valueOf( selectedProgramId );
        }
        catch ( Exception err ) {
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'System Error: invalid program id' ));
          System.debug( 'could not convert[' + selectedProgramId + '] to id:' + err.getMessage() );
          return(null);
      }
      
      Map<id,GFRS_Program__c> programMap = new Map<id,GFRS_Program__c>( this.programs );
      if( !programMap.containsKey( idSelectedProgram )){
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'System Error: unable to find program to update' ));
          return(null);
      }
      
      GFRS_Program__c program = programMap.get( idSelectedProgram );
      
      //-- not sure why but programs or program don't seem to be updated for the submit
      try {
          program.IsValidationExternalOnly__c='Yes';
          update program;
        }
        catch ( Exception err ) {
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ));
          System.debug( 'could not convert[' + selectedProgramId + '] to id:' + err.getMessage() );
          return(null);
      }
     
       
      return( null );
  }
  public ApexPages.PageReference saveSubmissionStatus(){
        if ( String.isBlank( request.Outcomes_Submission_Status__c ) ) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Funding_Request__c.fields.Outcomes_Submission_Status__c.getInlineHelpText()+': You must enter a value' )); 
        }
        return null;
  }
  
  public ApexPages.PageReference saveRequestPhilHCChar() {
        this.saveAndContinue = true;
        return(saveRequest()); 
  }
  /**
    * @author ADMD Team
    * @date 12/08/2013
    * @description saveRequest method - saves request
   */
  public ApexPages.PageReference saveRequest(){
    try {
        if (  this.request.Sub_Status__c != null
            && this.request.Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS
            && this.request.Record_Type_Name__c != gFRS_Util.TYPE_IMED_NAME && !this.saveAndContinue) {
                this.request.Evaluation_Completed__c = 'Yes';
                if((this.request.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME 
                    || this.request.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) 
                    && this.request.Foundation_Classified__c == 'FALSE') {
                        this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_MANAGER_REVIEW;
                    }
                this.request.External_Sub_status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
            }
        this.request.Outcomes__c=this.request.Outcomes_Levels__c;
        this.request.Is_Outcomes_In_RFI__c = false;
        this.request.IsValidationExternalOnly__c='Yes';
        if(this.request.Record_Type_Name__c != gFRS_Util.TYPE_IMED_NAME){
            if(this.request.Were_Total_Funds_Used__c == 'Yes'){
                this.request.Total_Amount_Used__c = this.request.Approved_Amount__c;
            } else {
                if(this.request.Total_Amount_Used__c == null || string.valueOf(this.request.Total_Amount_Used__c) == ''){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please input the Total Amount Used value.' ));
                    return( null );
                }
                if(this.request.Total_Amount_Used__c >= this.request.Approved_Amount__c){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please input the Total Amount Used value lesser than Approved Amount.' ));
                    return( null );
                }   
                if(this.request.Total_Amount_Used__c < 0){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Please input a valid Total Amount Used.' ));
                    return( null );
                }           
            }
        }
          if (gFRS_Util.isExternalRequest(this.request.Record_Type_Name__c) && !this.saveAndContinue ){
          this.request.Evaluation_submitted_date__c = Datetime.now();
          }
          update this.request;
        }
        catch ( Exception err ) {
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'error:'+ err.getMessage() );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            return( null );
        }
        if ((this.request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME || this.request.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME) && this.saveAndContinue == true) {
            this.saveAndContinue = false;
            this.showAttachments = true;
            return(null);
        } else {
            return(close());
        }
  }
  
  
  /**
    * @author ADMD Team
    * @date 12/08/2013
    * @description back method - back to prev step
  */ 
    public pagereference back() {
    if(submissionStatusChosen){
      showPrograms=false;
      showAttachments=true;
    }
    else{
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Funding_Request__c.fields.Outcomes_Submission_Status__c.getInlineHelpText()+': You must enter a value' ));        
    }
    return null;
  }
  
    public pagereference backProgram() {
      showPrograms=true;
      showAttachments=false;  
      return null;
  }
  /**
    * @author ADMD Team
    * @date 12/08/2013
    * @description close method - back to extenral home page
  */ 
  public ApexPages.PageReference close(){
      return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_COMPLETE, null, null ) ));
  }
  
   /**
    * @author GFRS Dev Team 
    * @date 24/02/2014
    * @description meetingPresentationSelected method - SFDC-3769 - method indicates whether 'Specific Meetings' field is required.
    */
    public PageReference meetingPresentationSelected(){

        if(meetingPresentations != '' && meetingPresentations == 'Yes'){
            meetingPresentationsRequired = true;   
        }
        else {
            meetingPresentationsRequired = false;
            this.request.Specific_Meetings__c = null;
        }   

        return null;
    }   

    public boolean submissionStatusChosen{
        get{
            return String.isNotEmpty(request.Outcomes_Submission_Status__c);
    }
    }

    public void calculateRefund(){
        this.refundDue = request.Approved_Amount__c - this.amountUsed;
        this.usedAmt = (this.amountUsed.format().contains('.')?this.amountUsed.format():(this.amountUsed.format()+'.00'));
        this.refundDueAmt = (this.refundDue.format().contains('.')?this.refundDue.format():(this.refundDue.format()+'.00'));
    }    
}