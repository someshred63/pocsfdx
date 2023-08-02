/**
* @author GFRS Dev Team
* @date 28/06/2013
* @description GFRS_ApplicationController class - controller for GFRS_Application page. Class is responsible for handling request from page and communication with webservices and database. 
*/
public with sharing class GFRS_ApplicationController
{
    public static final String ERROR_TIMEOUT = 'WebService timed out'; 
    
    //list of pending actions for GCOI
    public static final String ACTION_PAYMENT_FAILED = 'Payment to SAP Failed';   
    public static final String ACTION_EMPLOYEE_WS_FAIL = 'Web Service does not respond';
    public static final String ACTION_WS_MISSING_COST_CENTER = 'Unix Id does not exist in AGS WS';
    public static final String ACTION_GFRS_MISSING_COST_CENTER = 'Cost Center not within gFRS';
    public static final String ACTION_GFRS_MISSING_MANAGER = 'Finance Manager does not exist in gFRS';  
    public static final String ACTION_APPROVER_WS_FAIL = 'SAP Web Service does not respond';
    public static final String ACTION_WS_MISSING_UNIX = 'Cost Center does not exist in SAP';
    public static final String ACTION_GFRS_MISSING_APPROVER = 'SAP Financial Approver not within gFRS';
    
    //Organization attachments API Names    
    private static final String AUDITED_FINANCIALS_PREV_YEAR_API_NAME = 'Audited_financials_for_the_previous_year__c';
    public String getAUDITED_FINANCIALS_PREV_YEAR_API_NAME() {
        return AUDITED_FINANCIALS_PREV_YEAR_API_NAME;
    }
    private static final String AUDITED_FINANCIALS_PREV_TWO_YEARS_API_NAME = 'Audited_Financials_for_the_previous_two__c';
    public String getAUDITED_FINANCIALS_PREV_TWO_YEARS_API_NAME() {
        return AUDITED_FINANCIALS_PREV_TWO_YEARS_API_NAME;
    }
    private static final String AUDITED_FINANCIALS_PREV_THREE_YEARS_API_NAME = 'Audited_Financials_for_the_previous_thre__c';
    public String getAUDITED_FINANCIALS_PREV_THREE_YEARS_API_NAME() {
        return AUDITED_FINANCIALS_PREV_THREE_YEARS_API_NAME;
    }
    private static final String FORM990_THREE_YEARS_API_NAME = 'Form_990_for_the_previous_three_year__c';
    public String getFORM990_THREE_YEARS_API_NAME() {
        return FORM990_THREE_YEARS_API_NAME;
    }
    private static final String FORM990_TWO_YEARS_API_NAME = 'Form_990_for_the_previous_two_year__c';
    public String getFORM990_TWO_YEARS_API_NAME() {
        return FORM990_TWO_YEARS_API_NAME;
    }
    private static final String FORM990_ONE_YEARS_API_NAME = 'Form_990_for_the_previous_year__c';
    public String getFORM990_ONE_YEARS_API_NAME() {
        return FORM990_ONE_YEARS_API_NAME;
    }
    private List<String> apiNamesList = new List<String> {
        AUDITED_FINANCIALS_PREV_YEAR_API_NAME, AUDITED_FINANCIALS_PREV_TWO_YEARS_API_NAME, AUDITED_FINANCIALS_PREV_THREE_YEARS_API_NAME,
            FORM990_THREE_YEARS_API_NAME, FORM990_TWO_YEARS_API_NAME, FORM990_ONE_YEARS_API_NAME
            }; 
                
                public Map<String,Attachment> apiNameToAttachmentMap {get;set;} 
    public String apiName {get;set;}
    
    private static final String ORGANIZATION_API_NAME = 'GFRS_Organization__c';
    
    
    public static final String TASK_ACTION_TYPE_RFI = 'RFI';
    
    /** String returned from Web service to specify that there are no cost centers found **/
    public static final String WS_NO_APPROVERS = 'NO_APPROVERS_FOR_COST_CENTER';
    /** String returned from Web service to specify that the web service timed out **/
    public static final String WS_TIMEOUT = 'Read timed out';
    /** Message type returned from server saying there was an error **/
    public static final String WS_RESPONSE_ERROR = 'Error';
    public static final Integer WS_TIMEOUT_COUNT = 60000;
    public static final String WS_SOAP_FAULT = 'WebService returned a SOAP Fault';
    
    /** Test case type to ignore the WS and to use testing data instead **/
    public static final String CASE_IGNORE_WS = 'IGNOREWS';   
    /** The type of page this is **/
    public static final String CONTENT_TYPE = 'Funding Request';   
    /** The firewall content filter **/
    public static final String FIREWALL_CONTENT_TYPE = 'Firewall';   
    /** content key for firewall FAQ **/
    public static final String CONTENT_KEY_FIREWALLFAQ = 'FirewallFAQ';
    /** Page to move to when moving 'back' **/
    public static final String PATH_BACK = '/apex/gFRS_Org_Info';//-- CANNOT GO BACK
    /** Path to the blacklist **/
    public static final String PATH_FIREWALL_ERR = '/apex/gFRS_Error?code=' + gFRS_ErrorController.CODE_FIREWALL;
    /** GET orgId parameter **/
    public static final String PARAM_ORG_ID = 'org';
    /** current test case **/
    public static final String testCase = null;
    
    public static final String EMAIL_REG_EX = '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}';
    
    private static Boolean saveInProgress = false;
    
    public String programSubStatus {get;set;}
    public GFRS_Funding_Request__c fundReq {get; set;}
    public GFRS_Funding_Allocation_Line_Item__c allocationLI { get; set; }
    public GFRS_Third_Party__c[] thirdPartyRecords { get; set; }
    public List<ThirdPartyWrapper> thirdPartyRecordsWrapperList { get; set; }
    public Integer thirdPartyRowId { get; set; }
    public GFRS_Organization__c organization { get; set; }    
    public gFRS_Demographic_Group__c demographicGroup { get; set; }
    public String organizationId { get; set; }
    public Integer thirdPartyToDelete { get; set; }
    public Integer thirdPartyToSave { get; set; }
    public String thirdPartyField { get; set; }
    
    public Map<String,String> contentItems { get; set; }
    public Map<String,String> firewallContent { get; set; }  
    public Integer currentIndex { get; set; }
    public User currentUser;
    
    public String requestTypeDescription { get; set; }  
    public Boolean isEditable { get; set; }
    public Boolean isProfileCheck { get; set; }
    public Boolean isThirdPartyEditable { get; set; }
    public Boolean canAccountableEmployeeSelfFund { get; set; }   
    public Boolean showFundingAllocations { get; set; }
    public Boolean showAllocationGrid { get; set; }
    public Boolean showBackButton{ get; set; }
    public Boolean isInternalRequest{ get; set; }
    public String recordType {get;set;}
    public Boolean webServiceHasErrors{ get; set; }
    public Boolean otherSupportersRequired {set; get;}
    public String otherSupporters {get;set;}
    public Boolean showPaymentNoteSection { get; set; }
    
    public String nqsCriteriaSelected {get;set;}
    public Boolean nqsSummaryRendered {set; get;}
    
    public String barrierSelected {get;set;}
    public Boolean barrierSummaryRendered {set; get;}
    
    public String qualityOfCareComponentSelected {get;set;}
    public Boolean qualityOfCareComponentsSummaryRendered {set; get;}
    /** Value returned from the web service which will be applied as Financial Approver 1 for Field Ex **/
    public String managerUnixId{ get; set; }
    
    public Map<String, CostCenterApprover_element> costCenterApproversMap { get; set; }
    public CostCenterApprover_element[] costCenterApprovers { get; set; }
    public Map<String, Boolean> levelVisibilityMap { get; set; }
    public String selectedCostCenterUnixId { get; set; }
    
    
    
    //-- name of the current cost center. since the cost center__c field is a lookup and would require the record to be requiried;
    public String currentCostCenterName { get; set; }
    public Boolean clinicalTrialFlag {set; get;}
    public Boolean promoMaterialsFlag{set;get;}
    public String projectType {get;set;}
    
    public Integer programSize{get;set;}
    
    /*public Attachment auditFin2010 { get; set; }
public Attachment auditFin2009 { get; set; }
public Attachment auditFin2008 { get; set; }
public Attachment form2008 { get; set; }
public Attachment form2009 { get; set; }
public Attachment form2010 { get; set; }


below is not used as of gFRS 5.2
public GFRS_Content_Translation__c firewallQuestion1 { get; set; }
public GFRS_Content_Translation__c firewallQuestion2 { get; set; }
public GFRS_Content_Translation__c firewallQuestion3 { get; set; }
public GFRS_Content_Translation__c firewallQuestion4 { get; set; }
public GFRS_Content_Translation__c firewallQuestion5 { get; set; }
public GFRS_Content_Translation__c firewallQuestion6 { get; set; }
public GFRS_Content_Translation__c firewallQuestion7 { get; set; }
public GFRS_Content_Translation__c firewallQuestion8 { get; set; }
public GFRS_Content_Translation__c firewallQuestion9 { get; set; }
public GFRS_Content_Translation__c firewallQuestion10 { get; set; }
public GFRS_Content_Translation__c firewallQuestion11 { get; set; }
*/   
    public String firewallFAQ_Label { get; set; }
    
    public String thirdPartyMessage { get { return( this.contentItems.get('ThirdParty')); }}
    public String IMEDFootnote { get { return( this.contentItems.get('IMEDFootnote')); }}
    
    public String[] FS_ThirdParty { get{ return( new String[]{ 'Will_You_be_Working_With_a_3rd_Party__c' } ); } }
    public String[] FS_AllocationReadOnly { get{ return( new String[]{ 'Cost_Center__c' } ); } }
    
    public Boolean scrollDownPage { get; set; }   
    
    public Boolean issueTypeEducationSelectedFlag { get; set; }  //GFRS-738 - falg used to determine if K12 Education specific fields need to be required. 
    
    public void issueTypeEducationSelected() {
        issueTypeEducationSelectedFlag = (Apexpages.currentPage().getParameters().get('issueTypeEducationSelectedParam')=='true') ? true : false;
    }
    
    public Boolean showProgramDesign{
        get {
            return(gFRS_Util.TYPE_IMED_NAME.equals( this.fundReq.Record_Type_Name__c )
                  );
        }
    }
    
    public Boolean showThirdParty {
        get {
            return(
                (gFRS_Util.TYPE_IMED_NAME.equals( this.fundReq.Record_Type_Name__c ) || 
                 gFRS_Util.TYPE_HC_CHAR_NAME.equals( this.fundReq.Record_Type_Name__c ) ) &&
                gFRS_Util.YES.equals( this.fundReq.Will_You_be_Working_With_a_3rd_Party__c )
            );
        }
    }
    public Boolean isFoundationShown {
        get {
            if( gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals( this.fundReq.Record_Type_Name__c )){
                if((this.fundReq.Issue_type__c == 'Community and Economic Development' && (this.fundReq.Issue_subtype__c == 'Food Banks, Food Pantries, and Food Distribution' || this.fundReq.Issue_subtype__c == 'Homeless Services' || this.fundReq.Issue_subtype__c == 'Job Training / Support')) || this.fundReq.Issue_type__c == 'Post Secondary Education') {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 28/06/2013
* @description isCMEOShown - whether the 'Corporate Memberships with Exhibit Opportunities' section can be shown. 
*/
    public Boolean isCMEOShown { 
        get {
            return( gFRS_Util.isCMEOShown( this.fundReq ));
        }
    } 
    public String[] simpleFieldSet{
        get {
            String[] results = new String[]{ 'Outstanding_Accounts_Payable__c', 'Salary_of_the_Highest_Paid_Executive__c', 'Pending_Litigation__c' };
                return( results );
        }
    }
    
    GFRS_AttachmentCollector attachmentCollector;
    Map<String,String> apiNameToLabelMapOrganization;
    public Attachment oldAttachment;
    
    /**
* @author GFRS Dev Team
* @date 28/06/2013
* @description Constructor of the class. 
*/
    public GFRS_ApplicationController( ApexPages.StandardController std )
    {
        
        this.scrollDownPage = false;
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );       
        this.firewallContent = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( FIREWALL_CONTENT_TYPE, UserInfo.getLanguage() );
        this.firewallFAQ_Label = null;
        
        if( this.firewallContent.containsKey( CONTENT_KEY_FIREWALLFAQ )){
            this.firewallFAQ_Label = '<p>' + this.firewallContent.get( CONTENT_KEY_FIREWALLFAQ ) + '</p><br />';
        }
        
        
        
        
        this.currentUser = gFRS_Util_NoShare.getUserById(UserInfo.getUserId());
        this.fundReq = (GFRS_Funding_Request__c)std.getRecord();    
        AggregateResult res=[select count(id) result from GFRS_Program__c where Funding_Request__c=:fundReq.id and Start_Date__c != null ][0]; 
        this.programSize=Integer.valueOf(res.get('result'));
        
        if( this.fundReq == null || this.fundReq.id == null ){
            ApexPages.addMessages( new CustomException( System.Label.gFRS_ERROR_REQUEST_NOT_SET ));
            return;
        }
        
        try {
            //-- NOTE: these fields are mostly logic for this method, and are not all the fields used for the page (which is below)
            
            this.fundReq = [ select Id, Name,Funding_Sub_Type__c, Licensed_to_conduct_health_screenings__c, Funds_Used_To_Pay_Licensed_Physician__c,Funding_not_used_for_attendee_expenses__c , Clinical_Trial_Include_GNE_Roche_Product__c, Therapeutic_Area_Parent__c, Missing_in_gFRS_Approver__c, Organization__c, Requested_Amount__c,  In_Post_Approval_State__c, Entering_on_Behalf_of_Another__c , Finance_Managers__c, Requestor_subject_to_Firewall_Questions__c, Will_You_be_Working_With_a_3rd_Party__c, Exhibits_or_Displays_Allowed__c,
                            Promotional_Event_Advertising__c,Anticipated_Launch_Within_6_Months__c,Letter_of_Request__c, Meeting_Agenda__c, Needs_Assessment_Document__c, Implementation_Plan__c, Fellowship_Project_Description__c, Accountable_Employee_Approval__c, Accountable_Employee_Approval__r.External_Id_gne__c, Payment_registration_due_date__c, Payment_registration_due_date_notes__c,Is_there_more_than_one_event_associated__c,
                            Patient_Care__c, Evaluation_Form_Survey__c, gCOI_Pending_Actions__c, Financial_Approver_2__r.External_Id_gne__c,Information_Needed__c, Record_Type_Name__c, Additional_Document_Uploads__c, Additional_Document_Uploads_2__c, Additional_Document_Uploads_3__c, Additional_Document_Uploads_4__c, Additional_Document_Uploads_5__c, Learning_Level_3__c, Competence_Level_4__c, Performance_Level_5__c, Patient_Health_Level_6__c, Community_Health_Level_7__c, Practice_based_Learning_and_Management__c, Professionalism__c,Foundation_Eligible__c,
                            Organization__r.Type__c,Medical_Knowledge__c, Interpersonal_and_Communication_Skills__c,Payment_Delivery_Notifications__c,Business_Unit_2__c,Event_Project_sub_type__c,Event_Project_sub_type_other__c,Funds_not_used_to_support_doctor_nurse__c,Promo_material_displayed_in_edu_area__c,Is_the_Third_Party_org_accredited__c,Is_the_Third_Party_org_owned_physician__c, //-- needs to include each field that references an attachment
                            (select id,ParentID,name from Attachments)
                            from GFRS_Funding_Request__c where id = :this.fundReq.id limit 1];
            this.canAccountableEmployeeSelfFund = false;
            
            //Total_Requested__c - removed as Roll-Up Summary, to be reinstated shortly
            this.organization = [ select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, ACCME_Accreditations__c, Account__c, Authorized_Signer_Name__c, Description__c, Do_you_have_Legal_Authority_to_Sign__c, Email_Address_Person_with_Authority__c, Strategic_Promo_Mkt_Related_Services__c, Sister_Parent_Org_Strategic_Promo_Mktg__c, Firewall_for_Strategic_Promo_Mktg__c, Grant_Requestor_Subject_to_Firewall__c, Medicare_Guideline_Development__c, Mission_Statement__c, Number_of_Employees_Working_in_Complianc__c, Number_of_Employees__c, Number_of_Employees_with_Advanced_Degree__c, Operational_Budget__c, Other_Accredidations__c, Outstanding_Accounts_Payable__c, Is_Part_of_Parent_Org__c, Parent_Organization_Tax_ID__c, Pending_Litigation__c, Physician_Ownership__c, Roche_Prescriber__c, Roche_Purchaser__c, Salary_of_the_Highest_Paid_Executive__c, State_Affiliation__c, Tax_Id__c, Tax_Status__c, Type__c, US_Organization__c, W8BEN_Status__c, Website_Address__c, of_Physicians_in__c, NCI_Designated_Cancer_Center__c, Accreditation_s_Received__c, Audited_financials_for_the_previous_year__c, Form_990_for_the_previous_year__c, Form_990_for_the_previous_two_year__c, Form_990_for_the_previous_three_year__c,Audited_Financials_for_the_previous_two__c, Audited_Financials_for_the_previous_thre__c,Exclusion_Blacklist_Reasons__c,
                                 (select Id,ParentId,Name, Description, CreatedDate from Attachments)
                                 from GFRS_Organization__c
                                 where Id = :this.fundReq.Organization__c ];
        } catch( Exception err ){
            System.debug( 'unable to load organization and funding request info:' + err.getMessage() );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding request' ));
            return;
        }
        this.recordType=this.fundReq.Record_Type_Name__c;
        this.isEditable = gFRS_Util.multiSelectHasItem( this.fundReq.Information_Needed__c, 'Application' );
        this.isThirdPartyEditable = gFRS_Util.multiSelectHasItem( this.fundReq.Information_Needed__c, 'Third Party' );
        this.showBackButton = this.fundReq.Requested_Amount__c != null ? true : false;
        this.requestTypeDescription = gFRS_Util.getRecordTypeDescription(this.fundReq.Record_Type_Name__c);
        //determine the current index in the accordion to use
        this.currentIndex = gFRS_Util.getCurrentIndex();
        
        Contact userContact = gFRS_Util_NoShare.getUserContact(UserInfo.getUserId());
        Boolean isUserInternal = userContact != null;
        
        this.showAllocationGrid = userContact == null &&
            ( 
                gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME.equals(this.fundReq.Record_Type_Name__c) ||
                gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals(this.fundReq.Record_Type_Name__c) ||
                gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME.equals( this.fundReq.Record_Type_Name__c)
            );
        this.showFundingAllocations = userContact == null &&
            (
                gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(this.fundReq.Record_Type_Name__c)
            );
        
        this.isInternalRequest = gFRS_Util.isInternalRequest(this.fundReq.Record_Type_Name__c);
        
        this.apiNameToAttachmentMap = new Map<String,Attachment>();
        //-- find the attachments
        //-- attachment collector takes the attachments and allow us to find the matching attachments
        //-- organization files
        attachmentCollector = new GFRS_AttachmentCollector( this.organization.Attachments );
        for (String apiName : this.apiNamesList) {
            apiNameToAttachmentMap.put(apiName,this.attachmentCollector.getFoundAttachmentByKeyOrMakeOne( (String)this.organization.get(apiName), this.organization.id ));
        }
        /*
below is not used as of gFRS 5.2

GFRS_Content_Translation__c[] firewallTranslations = [ select id, GFRS_Content__r.Name, TextBlock__c from GFRS_Content_Translation__c where GFRS_Content__r.Filter__c = 'Firewall' order by GFRS_Content__r.Name ];
this.firewallQuestion1 = firewallTranslations[0];
this.firewallQuestion2 = firewallTranslations[1];
this.firewallQuestion3 = firewallTranslations[2];
this.firewallQuestion4 = firewallTranslations[3];
this.firewallQuestion5 = firewallTranslations[4];
this.firewallQuestion6 = firewallTranslations[5];
this.firewallQuestion7 = firewallTranslations[6];
this.firewallQuestion8 = firewallTranslations[7];
this.firewallQuestion9 = firewallTranslations[8];
this.firewallQuestion10 = firewallTranslations[9];
this.firewallQuestion11 = firewallTranslations[10];

*/
        //-- this is the query for all fields used in the rest of the page (as opposed to the above which are mostly for logic and attachments)
        if(this.fundReq.Id != null){
            //select all fields from the object, usefull in case when FieldSet is expanded by new columns
            
            //-- can no longer retrieve all fields, as this will bring us over the 10,000 character limit;
            String query = 'SELECT Received_approval_from_AR__c, Payment_registration_due_date__c, Payment_registration_due_date_notes__c, Organization__r.Type__c, Prime_Audience__c, Is_this_a_clinical_study__c, Patients_treated_annually__c, Healthcare_Audience__c,Healthcare_Audience_other__c, Program_Outcomes__c, NQS_Criteria__c, NQS_Summary__c, Barriers_to_Optimal_Patient_Care__c, Barriers_to_Optimal_Patient_Care_Summary__c, Quality_of_Care_Components__c, Quality_of_Care_Components_Summary__c, Anticipated_Launch_Within_6_Months__c,Funding_Sub_Type__c,Onsite_facilities_expertise__c , Statement_of_relevance_gaps_in_knowledge__c, Overall_goal_of_the_proposal__c, Licensed_to_conduct_health_screenings__c , Funds_Used_To_Pay_Licensed_Physician__c, Funding_not_used_for_attendee_expenses__c,  Clinical_Trial_Include_GNE_Roche_Product__c, Therapeutic_Area_Parent__c, Missing_in_gFRS_Approver__c, gCOI_Pending_Actions__c, accept_outcomes__c, Entering_on_Behalf_of_Another__c, Finance_Managers__c, accme__c, accme_status_confirmed__c, Accountable_Employee_Approval__c, Accountable_Employee_Approval__r.External_Id_gne__c, accredited_program__c, acgme__c, acgme_program_number__c, actual_time_at_display_table_hours__c, additional_document_uploads__c, Additional_Document_Uploads_2__c, Additional_Document_Uploads_3__c, Additional_Document_Uploads_4__c, Additional_Document_Uploads_5__c, additional_document_uploads_url__c, additional_funding_name__c, amount_expense_split__c, approved_amount__c, Approval_Comments__c, attendence_distrib__c, attention_to__c, audience_generation_program_dist__c, authorized_signer__c, Basic_Research_Fellow__c, benefits_determination__c, benefits_exchanged_for_funding__c, booth_type__c, briefly_describe_goals_met_to_date__c, briefly_describe_lessons_goals_unmet__c, building__c, business_approver__c, business_review_1_amount__c, Cancellation_Reasons__c, certification_check__c, change_in_number_of_commercial__c, charitable_event_has_tangible_benefits__c, city__c, clinical_practice_guideline_development__c, close_grant_write_off_refund_due_reason__c, comments__c, community_health_level_7__c, community_health_level_7_url__c, competence_level_4__c, competence_level_4_url__c, competencies_to_be_achieved__c, contact__c, corporate_membership__c, cost_center__c, count_on_number_of_requests__c, createdbyid, createddate, criteria_to_select_a_fellow__c, delivery_method__c, deny_reason__c, describe_how_you_will_measure_of_success__c, description_of_how_the_funds_were_used__c, did_educational_objectives_change__c, did_total_budget_amount_for_this_program__c, display_hours__c, does_event_have_volunteering_opportunity__c, does_funding_request_include_followng__c, educational_objectives_1__c, educational_objectives_1_to_10_fields__c, educational_objectives_2__c, educational_objectives_3__c, educational_objectives_4__c, educational_objectives_5__c, educational_objectives_6__c, educational_objectives_7__c, educational_objectives_8__c, educational_objectives_9__c, educational_objectives_10__c, educational_objectives__c, educational_objectives_n_to_z__c, educational_outcome__c, enter_pin__c, evaluation_form_survey__c, event_program_s_overall_budget_ru__c, event_program_title__c, event_project_type__c, event_type_not_field_sales__c, ever_group_committee__c, exhibits_or_displays_allowed__c, expected_attendees__c, expected_evaluations_at_time_of_request__c, expected_hcp_attendees__c, expected_us_hcp_attendees__c, external_sub_status__c, external_tracking_code_optional__c, fellowship_opportunity_publication__c, fellowship_project_description__c, fellowship_project_description_url__c, financial_approver_1__c, financial_approver_1_notes__c, financial_approver_1_split_amount__c, financial_approver_2__c, Financial_Approver_2__r.External_Id_gne__c, financial_approver_3__c, financial_approver_3_notes__c, financial_approver_4__c, financial_approver_4_notes__c, financial_approver_5__c, financial_approver_5_notes__c, financial_approver__c, foundation_classified__c, funding_for_developing_cpg__c, funding_type__c, funding_type_f__c, genentech_assistance__c, genentech_invitation_distribution__c, general_org_support_to_purchaser__c, general_org_support_to_society__c, gl_account__c, gl_account_code__c, grant_only_used_for_activity_detailed__c, grc_status__c, how_were_these_achieved__c, hunger__c, id, if_known_list_other_supporters__c, if_no_please_describe__c, if_no_please_describe_changes__c, if_outcomes_3_to_7_not_achieved__c, if_yes_how_many_commercial__c, if_yes_new_educational_objectives__c, if_yes_new_total_budget_for_program__c, if_yes_please_describe_opt_in_process__c, implementation_plan__c, implementation_plan_url__c, in_post_approval_state__c, information_needed__c, intake_submitted_date__c, intended_audience__c, interpersonal_and_communication_skills__c, interpersonal_communication_skills_url__c, ip_address__c, is_application_complete__c, is_this_program_accredited__c, is_volunteering_opportunity_public__c, is_your_organization_hcp_accredited__c, Prime_Audience_other__c, last_status_report_completion_date__c, lastmodifiedbyid, lastmodifieddate, learning_level_3__c, learning_level_3_url__c, learning_objectives_acheived__c, letter_of_request__c, letter_of_request_url__c, loa_signed__c, loa_signed_date__c, loa_signer_name__c, location__c, medical_knowledge__c, medical_knowledge_url__c, meeting_agenda__c, meeting_agenda_url__c, meeting_being_held_at_a_lavish_venue__c, method_for_measuring_program_success__c, name, needs_assessment__c, needs_assessment_document__c, needs_assessment_document_url__c, net_payment_total__c, non_charitable__c, not_open_to_similar_entities__c, number_of_tables__c, objectives__c, oig_check__c, open_to_public__c, opt_in_process_for_enduring_materials__c, org_type__c, organization__c, organization_state__c, organization_tax_id__c, organization_type__c, other_commercial_supporters__c, outcomes_levels__c, outcomes_review_comments__c, ownerid, parent_org_name__c, patient_care__c, patient_care_url__c, patient_focused_support__c, patient_health_level_6__c, patient_health_level_6_url__c, payment_call_counter__c, payment_compliance__c, payment_email_notification__c, pediatric_cancer_assistance__c, performance_level_5__c, performance_level_5_url__c, please_describe__c, please_specify__c, practice_based_learning_and_management__c, practice_based_learning_management_url__c, process_disposition_date__c, product_being_promoted__c, professionalism__c, professionalism_url__c, program_changes_if_any__c, program_description__c, program_end_date_max__c, program_not_open_to_the_public__c, program_specifications__c, program_start_date_min__c, project_status__c, promotion_event_has_no_tangible_benefits__c, promotional_event_advertising__c, promotional_event_advertising_url__c, reason_for_lower_approval_amount__c, reason_funds_not_used_as_intended__c, record_type_name__c, recordtypeid, refund_due__c, refund_instructions__c, refund_request_date__c, refundable_deposit_amount_if_any__c, refunded_amount__c, remittance_type__c, request_autonumber__c, request_for_additional_funding__c, request_not_field_initiated__c, request_not_submitted_by_accredited_ep__c, request_submitted_by_individual_or_group__c, request_time_period__c, requested_amount__c, requestor_subject_to_firewall_questions__c, resubmission__c, resubmission_request_name__c, rfi__c, roche_observer__c, sap_vendor_id__c, secondary_invitations_brc_s_help_request__c, send_by_fedex_cost_center_will_be_charg__c, signing_authority__c, signing_authority_email__c, signing_authority_first_name__c, signing_authority_last_name__c, split_number__c, state__c, state_why_level_3_7_not_achieved__c, status__c, status_last_modified_date__c, students_of_color_scholarships__c, sub_status__c, succeess_measurement_method__c, support_purpose_program_description__c, tangible_benefits__c, therapeutic_area__c, total_activity_cost_per_attendee__c, total_amount_funded__c, total_amount_used__c, total_of_expected_learners__c, Total_Program_Budget__c, unix_id__c, unreasonable_exhibit_fees__c, unsupported_theraputic_area__c, used_this_year__c, vendor_id__c, volunteering_opp_not_avail_to_community__c, wbs_code__c, what_are_you_seeking_funding_for__c, where_are_the_attendees_for_this_event_e__c, who_is_the_target_audience_for_your_even__c,Foundation_Eligible__c, Will_You_be_Working_With_a_3rd_Party__c,Payment_Delivery_Notifications__c,Business_Unit_2__c,Event_Project_sub_type__c,Event_Project_sub_type_other__c,Funds_not_used_to_support_doctor_nurse__c,Promo_material_displayed_in_edu_area__c,Is_the_Third_Party_org_accredited__c,Is_the_Third_Party_org_owned_physician__c,Issue_type__c,Issue_type_other__c,Issue_subtype__c,Focus_education__c,Focus_education_other__c,Education_Capacity_Building__c,Primary_Audience__c,Primary_audience_other__c,Free_and_Reduced_Lunch__c,Primary_Objectives__c,Is_there_more_than_one_event_associated__c from gFRS_Funding_Request__c';
            query += ' where Id =\''+this.fundReq.Id+'\' limit 1';
            
            this.fundReq = database.query(query);
            this.clinicalTrialFlag = (this.fundReq.Event_Project_type__c == gFRS_Util.REQUEST_PROGRAM_TYPE_CLINICAL_TRIAL)?true:false;
            this.promoMaterialsFlag = (this.fundReq.Event_Project_type__c == 'Healthcare provider education' || this.fundReq.Event_Project_type__c == 'Grand Round' || this.fundReq.Event_Project_type__c == 'Tumor Board') ? true:false;
            this.nqsSummaryRendered = (this.fundReq.NQS_Criteria__c == '' || this.fundReq.NQS_Criteria__c == null || this.fundReq.NQS_Criteria__c == gFRS_Util.NOT_APPLICABLE_STRING)?false:true;
            this.barrierSummaryRendered = (this.fundReq.Barriers_to_Optimal_Patient_Care__c == '' || this.fundReq.Barriers_to_Optimal_Patient_Care__c == null || this.fundReq.Barriers_to_Optimal_Patient_Care__c == gFRS_Util.NON_OF_THE_ABOVE_STRING)?false:true;
            this.qualityOfCareComponentsSummaryRendered = (this.fundReq.Quality_of_Care_Components__c == '' || this.fundReq.Quality_of_Care_Components__c == null || this.fundReq.Quality_of_Care_Components__c == gFRS_Util.NON_OF_THE_ABOVE_STRING)?false:true;
            
        }
        
        //-- default the approval user
        if( gFRS_Util.isInternalRequest( this.fundReq.Record_Type_Name__c ) && this.fundReq.Accountable_Employee_Approval__c == null ){
            //this.fundReq.Accountable_Employee_Approval__c = UserInfo.getUserId();
        }
        //-- default the payment delivery notification user for SFDC-1457
        if( (this.fundReq.Record_Type_Name__c == 'Field Initiated Exhibits' ||  this.fundReq.Record_Type_Name__c == 'Corporate Memberships' || ( this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos' &&  this.fundReq.Funding_Sub_Type__c == gFRS_Util.Sub_Type_Exhibit_Booth) || ( this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos' &&   this.fundReq.Funding_Sub_Type__c == gFRS_Util.Sub_Type_Sponsorship) ||  gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME.equals( this.fundReq.Record_Type_Name__c) ) && this.fundReq.Payment_Delivery_Notifications__c ==null )
        {
            //this.fundReq.Payment_Delivery_Notifications__c=UserInfo.getUserId();
        }
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if( params != null ){
            if( params.containsKey( PARAM_ORG_ID ) ) this.organizationId = String.valueOf( params.get( PARAM_ORG_ID ));
        }
        
        //get default fiancial approver
        this.selectedCostCenterUnixId = null;
        if( this.fundReq.Financial_Approver_2__r != null ) this.selectedCostCenterUnixId = this.fundReq.Financial_Approver_2__r.External_Id_gne__c;
        
        this.refreshAllocations();
        //getting data for cost center approvers grid
        this.costCenterApprovers = new CostCenterApprover_element[]{};
            this.costCenterApproversMap = new Map<String, CostCenterApprover_element>();
        
        this.thirdPartyRecords = gFRS_DAO.getThirdPartiesListForGivenRequest(this.fundReq);
        if(this.fundReq.Payment_registration_due_date__c != null && !gFRS_Util.isExternalRequest(this.fundReq.Record_Type_Name__c)){
            this.showPaymentNoteSection = true;
        }
        
        
        //if there aren't any third party records, then create them
        if( this.thirdPartyRecords == null || this.thirdPartyRecords.size() < 1 ){
            this.thirdPartyRecords = new GFRS_Third_Party__c[]{};
                }
        
        apiNameToLabelMapOrganization = gFRS_Util_NoShare.getFieldLabelsMapForGivenObject(ORGANIZATION_API_NAME);
        
        /* if(this.fundReq.Entering_on_Behalf_of_Another__c == null){
this.fundReq.Accountable_Employee_Approval__c = null;
} */
        
        //this.fundreq.Entering_on_Behalf_of_Another__c='Yes';
        
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String MyProflieName = PROFILE[0].Name;
        
        If(MyProflieName=='GNE-GFRS-Backoffice'){
            isProfileCheck=true;
            this.fundReq.Payment_Delivery_Notifications__c=userinfo.getUserId();
            this.fundreq.Entering_on_Behalf_of_Another__c='Yes';
            If(this.fundReq.Accountable_Employee_Approval__c==null){
                this.fundReq.Accountable_Employee_Approval__c = null;
            }
        }
        else{
            isProfileCheck=false;
        }
        
    }
    
    /**
* @author GFRS Dev Team
* @date 03/04/2019
* @description saveConfirmationInfo method - saves 'onChange' changes from the form
*/
    public void savePaymentDate() {
        if (this.fundReq.Payment_registration_due_date__c != null && !gFRS_Util.isExternalRequest(this.fundReq.Record_Type_Name__c)) {
            showPaymentNoteSection = true;
        } else {
            showPaymentNoteSection = false;
            this.fundReq.Payment_registration_due_date_notes__c = '';
        }
    }    
    
    /*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/
    /**
* @author GFRS Dev Team 
* @date 12/07/2013
* @description Method calls webservices for cost centers for given accountable employee.. 
*/
    public void callWebServices(){
        this.webServiceHasErrors = false;
        String excludedList=System.Label.gFRS_Exclude_User_Id;
        if(this.fundReq.Accountable_Employee_Approval__c!=null){
            String accountString=(String)this.fundReq.Accountable_Employee_Approval__c;
            if(excludedList.contains(accountString)){
                return;
            }
        }
        
        if(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(this.fundReq.Record_Type_Name__c)){
            this.getDefaultCostCenter();
        } else if( gFRS_Util.isInternalRequest( this.fundReq.Record_Type_Name__c )){
            this.getCostCenterApprovers();
        }
        
        if(this.webServiceHasErrors == true){
            try{
                gFRS_Util_NoShare.saveLockedFundingRequest( this.fundReq );
            }catch(DmlException e){
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyDMLMessage(e)) );
            }
        }
        
        
        //SFDC-3508 - we cannot run this method in constructor since there cannot be any DMLs in constructor
        getThirdPartyWrapperList();
        
    }
    
    //- -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    //-- methods to save attachments (must be duplicated for each attachment)
    public void uploadAttachment() {
        
        Attachment newAttachment = gFRS_AttachmentUploadUtil.uploadAttachment(this.organization.Id,this.fundReq.Id,apiName,this.apiNameToAttachmentMap.get(apiName),gFRS_Util_NoShare.checkIsPageInRFIStatus(this.fundReq.Id, gFRS_Util.INFO_NEEDED_APPLICATION));
        if (newAttachment != null) {
            this.apiNameToAttachmentMap.put(apiName,newAttachment);
            this.organization.put(apiName, newAttachment.Id);
        }
    }
    
    
    public void uploadOrganizationAttachment(String fieldApiName, String fieldLabel, Boolean createNewAttachment){
        Attachment newAttachment;
        try{
            if(createNewAttachment){
                newAttachment = new Attachment( ParentId = this.organization.id, Name = this.apiNameToAttachmentMap.get(fieldApiName).Name, Description = fieldLabel );
                newAttachment.Body = this.apiNameToAttachmentMap.get(fieldApiName).Body;
                gFRS_Util_NoShare.saveLockedAttachment( newAttachment );
                newAttachment.body = null;
            }else{
                newAttachment = upsertOrganizationAttachment(fieldApiName, fieldLabel);     
                newAttachment.Body = null;
            }
            GFRS_Organization__c partial = [ select Id from GFRS_Organization__c where id = :this.fundReq.Organization__c ];
            partial.put(fieldApiName,newAttachment.id);
            gFRS_Util_NoShare.saveLockedOrganization(partial);
            refreshOrganizationAttachment(fieldApiName, newAttachment.Id);
            this.scrollDownPage = true;
        }catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
        } finally {
            if (newAttachment != null) newAttachment.body = null;
            if (this.apiNameToAttachmentMap.get(fieldApiName)!=null && this.apiNameToAttachmentMap.get(fieldApiName).body != null) this.apiNameToAttachmentMap.get(fieldApiName).body = null;
        }
    }
    
    private Attachment upsertOrganizationAttachment(String fieldApiName, String fieldLabel){
        Attachment tempAtt = this.apiNameToAttachmentMap.get(fieldApiName);
        tempAtt.Description = fieldLabel;
        this.apiNameToAttachmentMap.put(fieldApiName,tempAtt);
        upsert this.apiNameToAttachmentMap.get(fieldApiName);
        System.debug(this.apiNameToAttachmentMap.get(fieldApiName));
        return this.apiNameToAttachmentMap.get(fieldApiName);   
    }
    
    private void refreshOrganizationAttachment(String fieldApiName, Id attachmentId){
        Attachment attachmentToRefresh = [ select Id, ParentId, Name, Description, CreatedDate from Attachment where Id = :attachmentId];
        attachmentToRefresh.Body = null;
        this.apiNameToAttachmentMap.put(fieldApiName,attachmentToRefresh);
        
        this.organization.put(fieldApiName, attachmentToRefresh.Id);
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description refreshAllocations method - Refresh the Allocations for the funding request
*/
    private void refreshAllocations(){
        
        GFRS_Funding_Allocation__c[] allocations = [select Id from GFRS_Funding_Allocation__c where Grant_Request__c =: this.fundReq.Id];
        GFRS_Funding_Allocation__c allocation = (allocations.size() > 0) ? allocations[0] : null;
        
        if( (showFundingAllocations || showAllocationGrid)  && allocation != null ){
            gFRS_Funding_Allocation_Line_Item__c[] allocationLIs = [select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Funding_Allocation__c, Amount__c, Cost_Center_Description__c, Cost_Center_Lookup__c, Accountable_Employee__c, Cost_Center__c, Grant_Request__c, Line_Item_Total__c, Percent__c, Request_Name__c, WBS_Code_Lookup__c, WBS_Description__c, WBS__c, GL_Account_Code__c
                                                                    from GFRS_Funding_Allocation_Line_Item__c
                                                                    where Funding_Allocation__c = : allocation.Id ];
            
            if( allocationLIs != null && allocationLIs.size() > 0 ){
                this.allocationLI = allocationLIs[0];
            }
        } else {
            this.allocationLI = null;
        }
        
        if( this.allocationLI != null && currentCostCenterName == null ){
            currentCostCenterName = this.allocationLI.Cost_Center__c;
        }
    }
    
    //-- method needed for each content string retrieved
    //public String finalDisclaimer { get { return( this.contentItems.get( FINAL_DISCLAIMER_KEY )); }}
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description saveFirewall method - Saves the Firewall section
*/
    public ApexPages.PageReference saveFirewall(){        
        //-- validate
        if(
            (gFRS_Util.YES.equals( this.organization.Strategic_Promo_Mkt_Related_Services__c) || gFRS_Util.YES.equals( this.organization.Sister_Parent_Org_Strategic_Promo_Mktg__c )) &&
            !gFRS_Util.YES.equals( this.organization.Firewall_for_Strategic_Promo_Mktg__c )
        ){
            //-- blacklisted
            return( new ApexPages.PageReference( PATH_FIREWALL_ERR ));
        }
        
        try {
            this.fundReq.Requestor_subject_to_Firewall_Questions__c = false;
            gFRS_Util_NoShare.saveLockedOrganization( this.organization );
            gFRS_Util_NoShare.saveLockedFundingRequestInternalPage( this.fundReq );
        } catch( Exception err ){
            this.fundReq.Requestor_subject_to_Firewall_Questions__c = true;
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            return( null );
        }
        
        return( new ApexPages.PageReference( gFRS_Util.PATH_APPLICATION + '?id=' + this.fundReq.id ).setRedirect(true) );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description back method - Method called to return to the 'previous' page
*/
    public ApexPages.PageReference back(){
        String params = '';
        if( this.currentIndex > 0 ){
            params = params + gFRS_Util.PARAM_CURRENT_INDEX + '=' + (this.currentIndex-1);
            return( new ApexPages.Pagereference( gFRS_Util.initializeLink( gFRS_Util.PATH_APPLICATION, this.fundReq, params )).setRedirect(true));
        } else {
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_BACK, this.fundReq, params )));
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 13/08/2013
* @description Validates Third Party rows before going back. 
*/
    public ApexPages.PageReference backFromThirdParty(){
        
        if(this.thirdPartyRecordsWrapperList != null && this.thirdPartyRecordsWrapperList.size()==1 && !thirdPartyRowHasFilledFields(this.thirdPartyRecordsWrapperList.get(0))){
            return back();  
        }
        
        if(!validateThirdParty()){
            return null;
        }
        
        GFRS_Third_Party__c[] thirdPartiesToSave = new GFRS_Third_Party__c[]{};
            
            //gather gFRS Third Parties to save
            for( ThirdPartyWrapper partyWrapper : this.thirdPartyRecordsWrapperList ){
                
                thirdPartiesToSave.add(partyWrapper.thirdPartyObject);
                
            }
        
        if( thirdPartiesToSave.size() < 1 ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_THIRD_PARTY_REQUIRED ));
            return( null );
        }
        
        try {
            gFRS_Util_NoShare.saveLockedThirdParties(thirdPartiesToSave);
        } catch( Exception err ){
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'exception thrown during saving third party:' + errMsg );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            return( null );
        }
        
        return back();
        
    }
    
    
    /**
* @author GFRS Dev Team 
* @date 02/09/2013
* @description thirdPartyRowHasFilledFields method - check whether Third party has filled at leas one field 
*/
    private Boolean thirdPartyRowHasFilledFields(ThirdPartyWrapper partyWrapper){
        
        Boolean hasFilledField = false; 
        
        if(partyWrapper.thirdPartyObject.get('Company_Name__c') != null && partyWrapper.thirdPartyObject.get('Company_Name__c') != ''){
            hasFilledField = true;
        }else if(partyWrapper.thirdPartyObject.get('Third_Party_Contact_First_Name__c') != null && partyWrapper.thirdPartyObject.get('Third_Party_Contact_First_Name__c') != ''){   
            hasFilledField = true;
        }else if(partyWrapper.thirdPartyObject.get('Third_Party_Contact_Last_Name__c') != null && partyWrapper.thirdPartyObject.get('Third_Party_Contact_Last_Name__c') != ''){
            hasFilledField = true;
        }else if(partyWrapper.thirdPartyObject.get('Third_Party_Company_Function__c') != null && partyWrapper.thirdPartyObject.get('Third_Party_Company_Function__c') != ''){
            hasFilledField = true;  
        }else if(partyWrapper.thirdPartyObject.get('Third_Party_Contact_Email__c') != null && partyWrapper.thirdPartyObject.get('Third_Party_Contact_Email__c') != ''){
            hasFilledField = true;
        }
        
        return hasFilledField;
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description next method - Method called that returns to the 'next' page
*/
    public ApexPages.PageReference next(){
        /*--
Unfortunately, since we cannot use oncomplete in conjunction with inputFiles
this means that we will have to reload the page to a specific index
--*/
        
        Integer totalPanels = 1 + (this.isFoundationShown?1:0) + (this.isCMEOShown?1:0)  + (this.showFundingAllocations?1:0) + (this.showAllocationGrid?2:0);
        Integer nextIndex = this.currentIndex + 1;
        System.debug( 'nextIndex:' + nextIndex + ',totalPanels:' + totalPanels );
        String params = '';
        if( nextIndex < totalPanels ){
            params = params + gFRS_Util.PARAM_CURRENT_INDEX + '=' + nextIndex;
            return( new ApexPages.Pagereference( gFRS_Util.initializeLink( gFRS_Util.PATH_APPLICATION, this.fundReq, params )).setRedirect(true));
        } else {
            PageReference demographicPage = new PageReference(gFRS_Util.PATH_DEMOGRAPHIC);
            demographicPage.getParameters().put('request_id', this.fundReq.id);
            
            //PATH_THIRDPARTY
            if(showThirdParty){
                return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_THIRDPARTY, this.fundReq, params ) ));
            }else if(showProgramDesign){
                createProgramDesignIfNotExists();
                return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAMDESIGN, this.fundReq, params ) ));
            }else {
                if (gFRS_Util.isExternalRequest(this.fundReq.Record_Type_Name__c)){
                    return demographicPage;
                } else {
                    return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAM, this.fundReq, params ) ));   
                }
                
            }
            
        }
    }
    
    public void createProgramDesignIfNotExists(){
        try{
            List<gFRS_Program_Design_and_Implementation__c> requestProgramDesigns = 
                new List<gFRS_Program_Design_and_Implementation__c>([SELECT id
                                                                     FROM  gFRS_Program_Design_and_Implementation__c
                                                                     WHERE gFRS_Funding_Request__c =: this.fundReq.id                     
                                                                    ]);
            if(requestProgramDesigns.size() == 0){
                gFRS_Program_Design_and_Implementation__c programDesign = new gFRS_Program_Design_and_Implementation__c(gFRS_Funding_Request__c=fundReq.id);
                insert programDesign;
            }            
        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Cannot create program design record!'));
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description saveAllocationItems method - Method saves gFRS Funding Allocation Line Items
*/
    public ApexPages.PageReference saveAllocationItems(){
        
        List<GFRS_Cost_Center_Code__c> costCentersList;
        
        if (this.isInternalRequest && this.fundReq.Payment_registration_due_date__c != null && !gFRS_Util.isValidBusinessDaysBetweenDates(Date.today(), this.fundReq.Payment_registration_due_date__c, 25)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Funding_Payment_Request_20_Business_Days_Error));
            return( null );
        }
        
        if (this.isInternalRequest && this.fundReq.Payment_registration_due_date__c != null && string.isBlank(this.fundReq.Payment_registration_due_date_notes__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please enter the business rationale for your requested payment date.'));
            return( null );
        }               
        
        //-- validate
        if( gFRS_Util.YES.equals( this.fundReq.Entering_on_Behalf_of_Another__c) && this.fundReq.Accountable_Employee_Approval__c == null ){
            ApexPages.addMessage( new ApexPages.Message( Apexpages.Severity.ERROR, System.Label.gFRS_ERR_ACCOUNTABLE_REQUIRED ));
            return( null );
        }
        
        
        //--JIRA 159
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        
        User accountEmpUser ;
        String accountEmpProName;
        
        if(this.fundReq.Accountable_Employee_Approval__c !=null)
        {
            accountEmpUser = [SELECT id, Profile.Name, Profile.Id FROM User WHERE ID=:this.fundReq.Accountable_Employee_Approval__c];
        }
        
        if(accountEmpUser!=null){
            accountEmpProName = accountEmpUser.Profile.Name;
        }
        //System.Label.gFRS_Accountable_Employee_Error
        
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            
            if(userProfile.Name==accountEmpProName){
                ApexPages.addMessage( new ApexPages.Message( Apexpages.Severity.ERROR, System.Label.gFRS_Accountable_Employee_Error ));
                return( null );
            }
            
            if(this.fundReq.Entering_on_Behalf_of_Another__c!='Yes'){
                
                ApexPages.addMessage( new ApexPages.Message( Apexpages.Severity.ERROR,System.Label.gFRS_Accountable_Employee_Error));
                return( null );
            }
            
            //this.fundReq.Payment_Delivery_Notifications__c=this.fundReq.Accountable_Employee_Approval__c; 
        }
        
        if(accountEmpProName=='GNE-GFRS-Backoffice'){
            
            ApexPages.addMessage( new ApexPages.Message( Apexpages.Severity.ERROR,System.Label.gFRS_Accountable_Employee_Error));
            return( null );
            
        }
        
        User paymentDelUser;
        
        if(this.fundReq.Payment_Delivery_Notifications__c !=null)
        {
            paymentDelUser = [SELECT id, Profile.Name, Profile.Id FROM User WHERE ID=:this.fundReq.Payment_Delivery_Notifications__c];
        }
        
        String paymentDeliveryName = paymentDelUser.Profile.Name;
        
        if(userProfile.Name!='GNE-GFRS-Backoffice'){
            if(paymentDeliveryName=='GNE-GFRS-Backoffice'){
                ApexPages.addMessage( new ApexPages.Message( Apexpages.Severity.ERROR, System.Label.gFRS_Payment_Notification_Error ));
                return( null );
            }    
        }
        
        if(userProfile.Name=='GNE-GFRS-Backoffice'){
            this.fundReq.Payment_Delivery_Notifications__c=this.fundReq.Accountable_Employee_Approval__c;
        }              
        
        // Ending JIRA -159 
        
        String excludedList=System.Label.gFRS_Exclude_User_Id;
        if(this.fundReq.Accountable_Employee_Approval__c!=null && gFRS_Util.YES.equals( this.fundReq.Entering_on_Behalf_of_Another__c)){
            String accountString=(String)this.fundReq.Accountable_Employee_Approval__c;
            if(excludedList.contains(accountString)){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_Exclude_User_Error));
                return (null);
            }
        }
        
        if(gFRS_Util.NO.equals(this.fundReq.Entering_on_Behalf_of_Another__c)){
            this.fundReq.Accountable_Employee_Approval__c = UserInfo.getUserId();
        }
        
        
        if( gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals( this.fundReq.Record_Type_Name__c ) ){
            
            String wbsCodeName = '';
            GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
            
            //-- get the default cost center again if they changed the accountable Employee.
            this.getDefaultCostCenter();      
            
            costCentersList = gFRS_Util.getCostCentersByName(currentCostCenterName);
            
            if(costCentersList.size()>0 && costCentersList[0].SAP_Company_Code__c == System.Label.gFRS_Company_Code_1000){
                wbsCodeName = customSettings.Field_Initiated_Exhibits_WBS_1000__c;      
            }else if(costCentersList.size()>0 && costCentersList[0].SAP_Company_Code__c == System.Label.gFRS_Company_Code_1010){
                wbsCodeName = customSettings.Field_Initiated_Exhibits_WBS_1010__c;      
            }    
            
            List<GFRS_WBS_Codes__c> selectedWbs = gFRS_DAO.getWBSCodeByName(wbsCodeName);
            
            if( selectedWbs.size()>0 && selectedWbs.get(0) != null && this.allocationLi != null){
                
                //Success we have default WBS code for Field Initiated Exhibits.
                this.allocationLi.WBS_Code_Lookup__c = selectedWbs.get(0).Id;
            }else{
                //Exception handling
                this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( fundReq.gCOI_Pending_Actions__c, System.Label.GFRS_FieldExhibitsWBSErrorMsg);
                fundReq.IsValidationExternalOnly__c='Yes';
                update fundReq;
            }
            
        }else if( gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals( this.fundReq.Record_Type_Name__c ) || gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME.equals( this.fundReq.Record_Type_Name__c ) || gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME.equals( this.fundReq.Record_Type_Name__c) ){
            if(this.allocationLI!=null){
                costCentersList = gFRS_Util.getCostCentersByIds(new Set<String>{this.allocationLI.Cost_Center_Lookup__c});
                List<GFRS_WBS_Codes__c> wbsCodesList = gFRS_Util.getWbsCodesByIds(new Set<String>{this.allocationLI.WBS_Code_Lookup__c});
                if(costCentersList.size()<1 || wbsCodesList.size()<1 || costCentersList.get(0).SAP_Company_Code__c != wbsCodesList.get(0).SAP_Company_Code__c){
                    ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REF_SAP_CC));    
                    return (null);  
                }
                
            }
        }
        
        try{
            
            //-- if there was an error we still want the user to continue
            if( this.allocationLI != null ) gFRS_Util_NoShare.saveLockedAllocationLI( this.allocationLI );
            if(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(this.fundReq.Record_Type_Name__c)){
                this.setFinancialApprovers();
            }
            
            //this allows validation rules to function properly after the applicati has been completed by the user.
            this.fundReq.Is_Application_Complete__c = true;
            
            gFRS_Util_NoShare.saveLockedFundingRequest( this.fundReq );
            
            return( next() );
        } catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            return( null );
        }
    }
    
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description saveFinancialApprovers method - Method saves Financial Approvers
*/
    public ApexPages.PageReference saveFinancialApprovers(){
        //-- default if there is only one value.
        if( this.costCenterApprovers.size() == 1 ) this.selectedCostCenterUnixId = this.costCenterApprovers[0].unixId;
        System.debug( 'selectedCostCenterUnixId:' + this.selectedCostCenterUnixId );
        
        if( !validateFinancialApprovers() ){
            System.debug( 'failed validation' );
            return( null );
        }
        
        try{
            //system.debug('selectedRadio '+selectedCostCenterForLevels);
            if(!gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(this.fundReq.Record_Type_Name__c)){
                if( !this.setFinancialApprovers() ){
                    return( null );
                }
            }
            gFRS_Util_NoShare.saveLockedFundingRequest( this.fundReq );
            
            if(this.isInternalRequest){
                this.allocationLI.Accountable_Employee__c = this.fundReq.Financial_Approver_1__c;
                gFRS_Util_NoShare.saveLockedAllocationLI( this.allocationLI );
            }
            
            return( next() );
        } catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            return( null );
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description validateFinancialApprovers method - Method validates the foundation section
*/
    public Boolean validateFinancialApprovers(){
        Boolean isValid = true;
        //check if user selected the radion button if needed
        if( this.costCenterApprovers.size() < 1 ){
            //-- do nothing for now
        } else if( this.canAccountableEmployeeSelfFund ){
            System.debug( 'current accountableEmployee can fund this request, so leaving alone' );
        } else if( this.costCenterApprovers.size() == 1 ){
            //-- use this as the default, so leave it alone
            System.debug( 'using the single cost center approver:' + this.costCenterApprovers );
            System.debug( 'using the single cost center approver:' + this.costCenterApprovers[0].unixId );
            
        } else if(this.costCenterApprovers.size() > 0 && (this.selectedCostCenterUnixId == null || this.selectedCostCenterUnixId == '')){
            ApexPages.addMessages( new CustomException( System.Label.gFRS_ERROR_FINANCIAL_APPROVER2_REQ ));
            isValid = false;
        }
        
        return( isValid );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description saveFoundation method - Method called to save the foundation
*/
    public ApexPages.PageReference saveFoundation(){
        //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'TEST: BIG ERROR' ));
        //return( null );
        
        if( !validateFoundation() ){
            System.debug( 'failed validation' );
            return( null );
        }
        
        try {
            System.debug( 'before fundreq update');
            
            //-- save the values at the time of the page to avoid the controller
            //-- indicating the object is out of synch and clearing the changes
            this.organization.Audited_Financials_for_the_previous_thre__c=this.apiNameToAttachmentMap.get(AUDITED_FINANCIALS_PREV_THREE_YEARS_API_NAME).id;
            this.organization.Audited_Financials_for_the_previous_two__c=this.apiNameToAttachmentMap.get(AUDITED_FINANCIALS_PREV_TWO_YEARS_API_NAME).id;
            this.organization.Audited_financials_for_the_previous_year__c=this.apiNameToAttachmentMap.get(AUDITED_FINANCIALS_PREV_YEAR_API_NAME).id;
            this.organization.Form_990_for_the_previous_three_year__c=this.apiNameToAttachmentMap.get(FORM990_THREE_YEARS_API_NAME).id;
            this.organization.Form_990_for_the_previous_two_year__c=this.apiNameToAttachmentMap.get(FORM990_TWO_YEARS_API_NAME).id;
            this.organization.Form_990_for_the_previous_year__c=this.apiNameToAttachmentMap.get(FORM990_ONE_YEARS_API_NAME).id;
            
            gFRS_Util_NoShare.saveLockedFundingRequest( this.fundReq );
            gFRS_Util_NoShare.saveLockedOrganization( this.organization );
            
            System.debug( 'before next' );
            ApexPages.PageReference result = next();
            return( result );
        } catch( Exception err ){
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'Exception occurred while saving foundation: ' + err );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
        }
        
        return( null );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description validateFoundation method - Validates the foundation section
*/
    public Boolean validateFoundation(){
        Boolean isValid = true;
        
        if(this.apiNameToAttachmentMap.get(AUDITED_FINANCIALS_PREV_THREE_YEARS_API_NAME).name == null || this.apiNameToAttachmentMap.get(AUDITED_FINANCIALS_PREV_TWO_YEARS_API_NAME).name == null || this.apiNameToAttachmentMap.get(AUDITED_FINANCIALS_PREV_YEAR_API_NAME).name == null){
            ApexPages.addMessages( new CustomException( System.Label.gFRS_ERROR_AUDITED_FINANCIALS_REQUIRED ));
            isValid = false;
        }
        if(this.apiNameToAttachmentMap.get(FORM990_THREE_YEARS_API_NAME).name == null || this.apiNameToAttachmentMap.get(FORM990_TWO_YEARS_API_NAME).name == null || this.apiNameToAttachmentMap.get(FORM990_ONE_YEARS_API_NAME).name == null){
            ApexPages.addMessages( new CustomException( System.Label.gFRS_ERROR_FORMS_REQUIRED ));
            isValid = false;
        }
        
        return( isValid );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description clearFoundation method - Clears the information from the foundation if it is no longer needed
*/
    public void clearFoundation(){
        this.organization.Outstanding_Accounts_Payable__c = null;
        this.organization.Salary_of_the_Highest_Paid_Executive__c = null;
        this.organization.Pending_Litigation__c = null;
        
        this.organization.Form_990_for_the_previous_year__c = this.organization.Form_990_for_the_previous_two_year__c = this.organization.Form_990_for_the_previous_three_year__c = null;
        
        this.organization.Audited_financials_for_the_previous_year__c =
            this.organization.Audited_Financials_for_the_previous_two__c =
            this.organization.Audited_Financials_for_the_previous_thre__c = null;
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description saveCMEO method - Method called to save the CMEO
*/
    public ApexPages.PageReference saveCMEO(){
        
        try {
            System.debug( 'before fundreq update');
            
            //-- save the values at the time of the page to avoid the controller
            //-- indicating the object is out of synch and clearing the changes
            //this.fundReq.Meeting_Agenda__c=this.attachmentMeetingAgenda.id;
            
            gFRS_Util_NoShare.saveLockedFundingRequest( this.fundReq );
            gFRS_Util_NoShare.saveLockedOrganization( this.organization );
            
            System.debug( 'before next' );
            ApexPages.PageReference result = next();
            return( result );
        } catch( Exception err ){
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'Exception occurred while saving CMEO: ' + err );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
        }
        
        return( null );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description clearThirdParty method - Removes all third party records for the funding request
*/
    public void clearThirdParty(){
        try{
            gFRS_Third_Party__c[] thirdParties = [ select Id from gFRS_Third_Party__c where Funding_Request__c = :this.fundReq.Id ];
            if( thirdParties != null && thirdParties.size() > 0 ) 
                gFRS_Util_NoShare.removeLockedThirdParties( thirdParties );
        }catch(Exception ex){
            System.debug('gFRS: Error occured while deleting Third Parties.');
            System.debug(ex.getMessage());  
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description savePage method - Method called to perform final submission
*/
    public ApexPages.PageReference savePage(){
        
        if( !validateSave() ){
            //-- display error message if needed
            return(null);
        }
        
        //System.debug('PN:THIRD PARTIES1: ' + [select Id from gFRS_Third_Party__c where Funding_Request__c = :this.fundReq.Id]);
        //Commented line below for SFDC-1682 production issue fundatation shouldn't be clear
        //if( !this.isFoundationShown ) this.clearFoundation();
        if( !this.showThirdParty ){
            System.debug('Clear Third Party rows.');
            this.clearThirdParty();
        }
        
        if( gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals( this.fundReq.Record_Type_Name__c )){
            //-- we need to ensure either a CMEO is present or not present.
            gFRS_Util.createOrDestroyCMEO_Program( isCMEOShown, this.fundReq );
        }
        
        if (gFRS_Util.TYPE_PHILANTHROPIC_NAME == fundReq.Record_Type_Name__c && fundReq.Issue_type__c != 'K-12 Education') {
            final gFRS_Program__c[] programs = new gFRS_Program__c[]{ };
                // GFRS-844: clear number of students and teachers only for programs where those statistics are already set
                for (gFRS_Program__c program : [
                    SELECT Expected_number_of_students_engaged__c, Expected_number_of_teachers_engaged__c
                    FROM gFRS_Program__c WHERE Funding_Request__c = :fundReq.Id AND (
                        Expected_number_of_students_engaged__c != null OR Expected_number_of_teachers_engaged__c != null
                    )
                ]) {
                    program.Expected_number_of_students_engaged__c = null;
                    program.Expected_number_of_teachers_engaged__c = null;
                    programs.add(program);
                }
            // GFRS-844: persist programs using safe utility method to bypass entity is locked error
            if (programs.size() > 0) {
                gFRS_Util_NoShare.saveLockedPrograms(programs);
            }
        }
        
        try {
            System.debug('Var content: ' + this.fundReq);
            //TO_REMOVE: attempt of insert new element without organization id fails; line added to do not block the tests
            
            //The funding request is created before this page,
            
            
            //SFDC-2618 - remove progrmas if exist and should be removed
            if(this.fundReq.Event_Project_type__c != null && (this.fundReq.Event_Project_type__c == 'General organizational support' ||  this.fundReq.Event_Project_type__c == 'International scientific/medical meeting' || this.fundReq.Event_Project_type__c == 'Local scientific/medical meeting' || this.fundReq.Event_Project_type__c == 'National scientific/medical meeting' || this.fundReq.Event_Project_type__c == 'Regional scientific/medical meeting' || this.fundReq.Event_Project_type__c == 'Scientific/medical meeting')){
                if(!this.recordType.equals(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) && !this.recordType.equals(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) && !this.recordType.equals(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)){
                    this.fundReq.Event_Project_sub_type__c='N/A';
                }
            }
            
            GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();    
            string pgmType = customSettings.Exhi_SciPipeline_MultiProgram__c;
            
            list<string> pgmTypes = new list<string>();
            map<string,string> pgmTypeMap = new map<string,string>();
            pgmTypes = pgmType.split(';');
            
            for(string str : pgmTypes){
                pgmTypeMap.put(str, str);
            }
            
            if(pgmTypeMap.containsKey(this.fundReq.Event_Project_type__c)){
                // no action required
            } else {
                this.fundReq.Is_there_more_than_one_event_associated__c = '';
            }       
            
            if(this.fundReq.Event_Project_sub_type__c != 'Other'){
                this.fundReq.Event_Project_sub_type_other__c='';
            }
            
            if(this.fundReq.Resubmission__c != 'Yes'){
                this.fundReq.Resubmission_Request_Name__c = '';
            }
            
            if(this.fundReq.Is_this_a_clinical_study__c != 'Yes'){
                this.fundReq.Patients_treated_annually__c = null;
            }
            
            if( !this.nqsSummaryRendered ){
                this.fundReq.NQS_Summary__c = '';
            }
            
            if( !this.barrierSummaryRendered){
                this.fundReq.Barriers_to_Optimal_Patient_Care_Summary__c = '';
            }
            
            if( !this.qualityOfCareComponentsSummaryRendered ){
                this.fundReq.Quality_of_Care_Components_Summary__c = '';
            }
            
            if (gFRS_Util.TYPE_PHILANTHROPIC_NAME == fundReq.Record_Type_Name__c && ((fundReq.Issue_type__c == 'Community and Economic Development' && (fundReq.Issue_subtype__c == 'Food Banks, Food Pantries, and Food Distribution' || fundReq.Issue_subtype__c == 'Homeless Services' || fundReq.Issue_subtype__c == 'Job Training / Support')) || fundReq.Issue_type__c == 'Post Secondary Education')) {
                this.fundReq.Foundation_Eligible__c = 'Yes';
            } else {
                this.fundReq.Foundation_Eligible__c = 'No';
            }
            
            gFRS_Util_NoShare.saveLockedFundingRequest( this.fundReq );
            gFRS_Util_NoShare.saveLockedOrganization( this.organization );
            
            this.refreshAllocations();
            
            //SFDC-2618 method removes programs if exists when sub program type changed
            if( recordType == 'HC Char'){
                gFRS_Util_NoShare.deleteAppropriateHCProgramsIfExists(this.fundReq.Id);
                //deleteAppropriateHCProgramsIfExists();
            }
            if( recordType == 'Sci/Pipeline Exhibits & Other Non-Promo' || recordType == 'Exhibits & Other Promos'){
                gFRS_Util_NoShare.deleteAppropriateSciPipeandExhibitsProgramsIfExists(this.fundReq.Id);
                //deleteAppropriateHCProgramsIfExists();
            }   
        } catch( Exception err ){
            System.debug( 'exception thrown during save:' + err );
            System.debug(err.getMessage());
            DMLException dErr = (DMLException) err;
            System.debug(dErr.getDmlFieldNames(0));
            
            //messages for custom validation are already added, so there is no need to add it
            if(dErr.getDmlFieldNames(0).size() == 0){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            }
            return( null );
        }
        // System.debug('PN:THIRD PARTIES3: ' + [select Id from gFRS_Third_Party__c where Funding_Request__c = :this.fundReq.Id]);
        return( next() );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description validateSave method - Validates the page before submission
*/
    public Boolean validateSave(){
        Boolean isValid = true;
        if( this.fundReq == null || this.fundReq.id == null ){
            ApexPages.addMessages( new CustomException( System.Label.gFRS_ERROR_INVALID_FUND_REQ ));
            isValid = false;
            
            //Prevent from continuation for fundReq == null
            return isValid;
        }
        if(!this.fundReq.Record_Type_Name__c.equals(gFRS_Util.TYPE_PHILANTHROPIC_NAME)){
            if( this.fundReq.Therapeutic_Area__c != null && this.fundReq.Therapeutic_Area__c.equals('Other') && this.fundReq.Please_Specify__c == null){
                ApexPages.addMessages( new CustomException( System.Label.gFRS_ERROR_SPECIFY_THERAPEUTIC_AREA ));
                isValid = false;
            }
        }
        if (gFRS_Util.isExternalRequest((this.fundReq.Record_Type_Name__c)) && this.fundReq.Payment_registration_due_date__c != null && (Date.today().daysBetween(this.fundReq.Payment_registration_due_date__c)< 60)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Requested payment date must be at least 60 calendar days after the submission date.'));
            isValid = false;
        }
        if(this.fundReq.Record_Type_Name__c.equals(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME) || this.fundReq.Record_Type_Name__c.equals(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) || this.fundReq.Record_Type_Name__c.equals(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) || this.fundReq.Record_Type_Name__c.equals(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME)){
            if( this.fundReq.Prime_Audience__c != null && this.fundReq.Prime_Audience__c.contains('Others') && this.fundReq.Prime_Audience_other__c == null){
                ApexPages.addMessages( new CustomException( 'Please Specify If Primary Audience Others: You must enter a value' ));
                isValid = false;
            }
        }
        
        if(this.fundReq.Record_Type_Name__c.equals(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) || this.fundReq.Record_Type_Name__c.equals(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)){
            
            GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
            string pgmType = customSettings.Exhi_SciPipeline_MultiProgram__c;           
            list<string> pgmTypes = new list<string>();
            map<string,string> pgmTypeMap = new map<string,string>();
            pgmTypes = pgmType.split(';');
            
            for(string str : pgmTypes){
                pgmTypeMap.put(str, str);
            }
            
            if(pgmTypeMap.containsKey(this.fundReq.Event_Project_type__c) && (this.fundReq.Is_there_more_than_one_event_associated__c == null || this.fundReq.Is_there_more_than_one_event_associated__c == '')){
                ApexPages.addMessages( new CustomException( 'Is there more than one event associated with this request?: You must enter a value' ));
                isValid = false;
            }
            
        }       
        if(this.fundReq.Non_Charitable__c != null && this.fundReq.Requested_Amount__c != null && this.fundReq.Non_Charitable__c>this.fundReq.Requested_Amount__c){
            ApexPages.addMessages( new CustomException( System.Label.gFRS_ERROR_NON_CHARITABLE_AMOUNT ));
            isValid = false;
        }
        
        if(this.fundReq.Resubmission__c == 'Yes' && this.fundReq.Resubmission_Request_Name__c == null){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, GFRS_Funding_Request__c.Resubmission_Request_Name__c.getDescribe().getInlineHelpText() + ' ' + System.Label.gFRS_Is_Required ));
            isValid = false;
        }
        
        return( isValid );
    }
    
    /**
* @author GFRS Dev Team 
* @date 08/08/2013
* @description Saves the Third Party items. 
*/
    public ApexPages.PageReference saveThirdParty(){
        
        if( !validateThirdParty() ){
            return (null);
        }
        
        GFRS_Third_Party__c[] thirdPartiesToSave = new GFRS_Third_Party__c[]{};
            
            //gather gFRS Third Parties to save
            for( ThirdPartyWrapper partyWrapper : this.thirdPartyRecordsWrapperList ){
                
                thirdPartiesToSave.add(partyWrapper.thirdPartyObject);
                
            }
        
        if( thirdPartiesToSave.size() < 1 ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_THIRD_PARTY_REQUIRED ));
            return( null );
        }
        
        try {
            gFRS_Util_NoShare.saveLockedThirdParties(thirdPartiesToSave);
        } catch( Exception err ){
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'exception thrown during saving third party:' + errMsg );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            return( null );
        }
        
        
        return( next() );
    }
    
    
    /**
* @author GFRS Dev Team 
* @date 08/08/2013
* @description Subbmits third party row to the table. 
*/
    public ApexPages.PageReference addThirdParty(){
        if(!saveInProgress){
            saveInProgress = true;
            System.debug('PN:DEBUG:addThirdParty: START');
            if(!validateThirdParty()){
                return null;    
            }
            
            //Add record to wrappers list
            ThirdPartyWrapper thirdPartyWrap = new ThirdPartyWrapper(new GFRS_Third_Party__c( Funding_Request__c = this.fundReq.Id ));
            thirdPartyWrap.rowNumber = this.thirdPartyRowId;
            this.thirdPartyRecordsWrapperList.add(thirdPartyWrap);
            this.thirdPartyRowId++;
            
            //Add record to database
            saveNewThirdParty(thirdPartyWrap.thirdPartyObject); 
            
            //Retrieve third parties from database and put them in wrapper list
            getThirdPartyWrapperList();
            System.debug('PN:DEBUG:addThirdParty: END');
            
        }
        saveInProgress = false; 
        return null;
    }
    
    /**
* @author GFRS Dev Team 
* @date 08/08/2013
* @description Saves the Third Party items. 
*/
    public ApexPages.PageReference saveNewThirdParty(GFRS_Third_Party__c thirdParty){
        List<GFRS_Third_Party__c> thirdPartiesToSave = new List<GFRS_Third_Party__c>();
        thirdPartiesToSave.add(thirdParty);
        try {
            gFRS_Util_NoShare.saveLockedThirdParties(thirdPartiesToSave);
        } catch( Exception err ){
            String errMsg = gFRS_Util.getPrettyMessage(err);
            System.debug( 'exception thrown during saving third party:' + errMsg );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            return( null );
        }
        
        return null;
    }
    
    /**
* @author GFRS Dev Team 
* @date 08/08/2013
* @description Validates the Third Party items. 
*/
    public Boolean validateThirdParty(){
        Boolean isValid = true;
        if( this.thirdPartyRecordsWrapperList == null || this.thirdPartyRecordsWrapperList.size() < 1 ){
            System.debug('PN:DEBUG:validateThirdParty: IF');
            ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  System.Label.gFRS_ERROR_NO_THIRD_PARTY));
            isValid = false;
        }else{
            System.debug('PN:DEBUG:validateThirdParty: ELSE IF: listSize: ' + this.thirdPartyRecordsWrapperList.size());
            for( ThirdPartyWrapper partyWrapper : this.thirdPartyRecordsWrapperList ){
                if(partyWrapper.thirdPartyObject.get('Company_Name__c') == null || partyWrapper.thirdPartyObject.get('Company_Name__c') == ''){
                    ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  Label.gFRS_ThirdParty_Company_Name_Error));     
                    isValid = false;
                }
                if(partyWrapper.thirdPartyObject.get('Third_Party_Contact_First_Name__c') == null || partyWrapper.thirdPartyObject.get('Third_Party_Contact_First_Name__c') == ''){
                    ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  Label.gFRS_ThirdParty_Contact_FirstName_Error));    
                    isValid = false;
                }
                if(partyWrapper.thirdPartyObject.get('Third_Party_Contact_Last_Name__c') == null || partyWrapper.thirdPartyObject.get('Third_Party_Contact_Last_Name__c') == ''){
                    ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  Label.gFRS_ThirdParty_Contact_LastName_Error)); 
                    isValid = false;
                }
                if(partyWrapper.thirdPartyObject.get('Third_Party_Company_Function__c') == null || partyWrapper.thirdPartyObject.get('Third_Party_Company_Function__c') == ''){
                    ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  Label.gFRS_ThirdParty_Company_Function_Error)); 
                    isValid = false;    
                }   
                
                
                if(partyWrapper.thirdPartyObject.get('Third_Party_Contact_Email__c') == null || partyWrapper.thirdPartyObject.get('Third_Party_Contact_Email__c') == ''){
                    ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  Label.gFRS_ThirdParty_Contact_Email_Error));    
                    isValid = false;
                }else if(!Pattern.matches(EMAIL_REG_EX, String.valueOf(partyWrapper.thirdPartyObject.get('Third_Party_Contact_Email__c')))){
                    ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  Label.gFRS_ThirdParty_Contact_Email_Format_Error));
                    isValid = false;
                }
                
                if(isValid == false){
                    break;
                }
            }
            
        }
        
        return( isValid );
    }
    
    /**
* @author GFRS Dev Team 
* @date 12/08/2013
* @description Validates the Third Party items. 
*/
    public void validateAndSaveThirdPartyField(){
        
        ThirdPartyWrapper thirdPartyWrapperToSave = null;
        for(ThirdPartyWrapper item : this.thirdPartyRecordsWrapperList){
            if(item.rowNumber == thirdPartyToSave){
                thirdPartyWrapperToSave = item;
                if('Third_Party_Contact_Email__c' == thirdPartyField){
                    if(thirdPartyWrapperToSave.thirdPartyObject.get('Third_Party_Contact_Email__c') == null || !Pattern.matches(EMAIL_REG_EX, String.valueOf(thirdPartyWrapperToSave.thirdPartyObject.get('Third_Party_Contact_Email__c')))){
                        ApexPages.AddMessage( new ApexPages.Message( ApexPages.Severity.Error,  'Contact Email is incorrect'));
                    }
                }
                break;
            }           
        }
        
        List<GFRS_Third_Party__c> thirdPartiesToSave = new List<GFRS_Third_Party__c>();
        if(thirdPartyWrapperToSave != null && thirdPartyWrapperToSave.thirdPartyObject != null){
            thirdPartiesToSave.add(thirdPartyWrapperToSave.thirdPartyObject);   
        }
        
        try{
            gFRS_Util_NoShare.saveLockedThirdParties(thirdPartiesToSave);   
        }catch( Exception err ){
            System.debug('Save failed. Probably entity was deleted before.');
        }
        
        
    }
    
    /**
* @author GFRS Dev Team 
* @date 08/08/2013
* @description Deletes third party row to the table. 
*/
    public void deleteThirdPartyRow(){
        ThirdPartyWrapper thirdPartyWrapperToDelete = null;
        for(ThirdPartyWrapper item : this.thirdPartyRecordsWrapperList){
            if(item.rowNumber == thirdPartyToDelete){
                thirdPartyWrapperToDelete = item;
                this.thirdPartyRecordsWrapperList.remove(thirdPartyToDelete);
                
                break;
            }           
        }
        if(thirdPartyWrapperToDelete.thirdPartyObject != null && thirdPartyWrapperToDelete.thirdPartyObject.Id != null){
            try{
                gFRS_Util_NoShare.removeLockedThirdParties( new List<gFRS_Third_Party__c>{thirdPartyWrapperToDelete.thirdPartyObject} );
            }catch( Exception err ){
                System.debug('Deletion of Third-Party failed.');
            }
        }
        
        getThirdPartyWrapperList();
    }
    
    /**
* @author GFRS Dev Team 
* @date 08/08/2013
* @description Method gathers Third party objects into wrapper list. 
*/
    public void getThirdPartyWrapperList(){
        List<GFRS_Third_Party__c> thirdPartiesToSave = new List<GFRS_Third_Party__c>();
        
        this.thirdPartyRowId = 0;
        thirdPartyRecordsWrapperList = new List<ThirdPartyWrapper>();
        this.thirdPartyRecords = gFRS_DAO.getThirdPartiesListForGivenRequest(this.fundReq);
        
        if(this.thirdPartyRecords.size()>0){
            for(GFRS_Third_Party__c item : this.thirdPartyRecords){
                ThirdPartyWrapper thirdPartyWrap = new ThirdPartyWrapper(item);
                thirdPartyWrap.rowNumber = this.thirdPartyRowId;
                this.thirdPartyRecordsWrapperList.add(thirdPartyWrap);
                this.thirdPartyRowId++;
            }   
        }else{
            ThirdPartyWrapper thirdPartyWrap = new ThirdPartyWrapper(new GFRS_Third_Party__c(Funding_Request__c = this.fundReq.id));
            this.thirdPartyRecordsWrapperList.add(thirdPartyWrap);
            this.thirdPartyRowId++;
            
            thirdPartiesToSave.add(thirdPartyWrap.thirdPartyObject);
            
            gFRS_Util_NoShare.saveLockedThirdParties(thirdPartiesToSave);
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description setFinancialApprovers method - Setter for cost center approvers
*/
    public Boolean setFinancialApprovers(){
        
        //1st approver
        this.fundReq.Financial_Approver_1__c = this.getFirstApprover();
        
        if(!gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(this.fundReq.Record_Type_Name__c)){
            //2nd approver
            this.fundReq.Financial_Approver_2__c = getSecondApprover();
            
            //3rd approver
            try {
                this.fundReq.Financial_Approver_3__c = getThirdApprover();
            } catch( Exception err ){
                System.debug( err.getMessage() );
                
                //-- alow the user to continue, but make a note that it couldn't be found.
                this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_GFRS_MISSING_MANAGER );
            }
        }
        
        system.debug('fa1:'+this.fundReq.Financial_Approver_1__c);
        system.debug('fa2:'+this.fundReq.Financial_Approver_2__c);
        system.debug('fa3:'+this.fundReq.Financial_Approver_3__c);
        
        return true;
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description getFirstApprover method - returns first approver
*/
    public id getFirstApprover(){
        if(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(this.fundReq.Record_Type_Name__c)){
            //-- handled from web service results
            return( this.fundReq.Financial_Approver_1__c );
        } else {
            return this.fundReq.Accountable_Employee_Approval__c;
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description getFirstApprover method - returns the second financial approver.
* @return Id - the id of the cost center that matches the requested amount, or the selected level if there were multiple cost centers
*/
    public id getSecondApprover(){
        String fa2_unixId = this.selectedCostCenterUnixId;
        
        //-- if the accountable employee can self fund the request, then second approver is not necessary
        if( this.canAccountableEmployeeSelfFund == true ){
            return( null );
        }
        
        if( this.costCenterApprovers == null || this.costCenterApprovers.size() < 1 ){
            this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_UNIX );
            System.debug( 'NO COST CENTER APPROVERS FOUND' );
            return( null );
        } else if( fa2_unixId == null ){
            this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_UNIX );
            System.debug( 'No unix id found from web service' );
            return( null );
        }
        
        if( fa2_unixId != null ){
            Id result = gFRS_Util_NoShare.getUserByUnixId( fa2_unixId );
            if( result != null ){
                this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.removeMultiSelectitem( this.fundReq.gCOI_Pending_Actions__c, ACTION_GFRS_MISSING_APPROVER );
                this.fundReq.Missing_in_gFRS_Approver__c = null;
                
                return( result );
            } else {
                //-- allow the program to continue but add in the pending action
                this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_GFRS_MISSING_APPROVER );
                this.fundReq.Missing_in_gFRS_Approver__c = fa2_unixId;
            }
        }
        
        return( null );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description getThirdApprover method - returns the third financial approver
*  @return Id - the id of the user for the third financial approver
*  @throws CustomException if the manager is not found - to be caught by caller to add in the gCOI pending action
*/
    public Id getThirdApprover(){
        System.debug( 'finding third approver from:' + fundReq.Finance_Managers__c );
        
        Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( fundReq.Finance_Managers__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
            throw( new CustomException( 'unix id not found on financial manager, so leaving alone' ));
        }
        
        Id targetId = gFRS_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
            throw( new CustomException( 'No user found matching unix id[' + unixId + ']'));
        }
        
        return( targetId );
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description callCostCenterApprover method - calls webservice
*/
    public gFRS_CostCenterApprovalWS.costCenterApproverResponse_element callCostCenterApprover(String amount,String expenseType,String maxCostCenter,String minCostCenter){
        gFRS_CostCenterApprovalWS.GneCOMM_CostCenter_GFRS_O_1_SAP_I_1_ServicesPort0 ws = new gFRS_CostCenterApprovalWS.GneCOMM_CostCenter_GFRS_O_1_SAP_I_1_ServicesPort0();
        ws.inputHttpHeaders_x = gFRS_util.createAuthenticationHeaderMap();
        ws.timeout_x = WS_TIMEOUT_COUNT;
        //-- do not pass the amount
        return ws.costCenterApprover( null, expenseType, maxCostCenter, minCostCenter);
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description getCostCenterApprovers method - Method to call the costCenterApprovers web service and handle the results
* @POSTCONDITION: nothing is done if the allocation grid is not shown or the alloctionLI is not found
* @POSTCONDITION: web service is called for the current cost center and amount with the results compiled by handleWSResponse()
* @see #handleWSResponse
*/
    public void getCostCenterApprovers(){
        if( this.showAllocationGrid && this.fundReq != null && this.fundReq.Requested_Amount__c != null &&
           this.allocationLI != null && this.allocationLI.Cost_Center__c != null
          ){
              //-- always initially assume the value is no unless proven otherwise.
              this.canAccountableEmployeeSelfFund = false;
              
              //-- remove that it has failed if trying again
              this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.removeMultiSelectitem( this.fundReq.gCOI_Pending_Actions__c, ACTION_APPROVER_WS_FAIL );
              
              gFRS_CostCenterApprovalWS.costCenterApproverResponse_element result = null;
              try{
                  String costCenter = this.allocationLI.Cost_Center__c;
                  result = this.callCostCenterApprover( String.valueOf( this.fundReq.Requested_Amount__c ), 'CC', costCenter, costCenter );
                  
                  if( WS_RESPONSE_ERROR.equals( result.MessageType ) ){
                      if( result.MessageText != null && result.MessageText.contains( WS_NO_APPROVERS )){
                          throw( new CustomException( System.Label.gFRS_ERROR_NO_APPROVERS ));
                      } else {
                          System.debug( 'Error Message from CostCenterApprover web service:' + result.MessageText );
                          throw( new CustomException( System.Label.gFRS_ERROR_UNKNOWN ));
                      }
                  } else {
                      this.handleWSResponse(result);
                  }
              } catch(Exception e){
                  String errMsg = gFRS_Util.getPrettyMessage(e);
                  if( result != null && !(e instanceof CustomException) ) this.fundReq.Web_Service_Error_Message_Detail__c = result.MessageText;
                  
                  System.debug( 'exception occurred while lookign for cost center approvers:' + errMsg );
                  
                  if( errMsg.contains( WS_SOAP_FAULT )){
                      //-- assume the unix id is missing for now
                      this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_UNIX );
                      errMsg = System.Label.gFRS_ERROR_SOAP_FAULT;
                  } else if(errMsg.contains( WS_TIMEOUT )){
                      this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_APPROVER_WS_FAIL );
                      errMsg = ERROR_TIMEOUT;
                  }else{
                      this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_UNIX );
                  }
                  this.webServiceHasErrors = true;
                  
                  ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
              }
          }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description handleWSResponse method - Handles the response from the getCostCenterApprovers web service.
*/
    public void handleWSResponse(gFRS_CostCenterApprovalWS.costCenterApproverResponse_element response) {
        if(
            ( response.MessageText != null && response.MessageText.contains( WS_NO_APPROVERS )) ||
            ( response.costCenterApprvers == null || response.costCenterApprvers.size() == 0 )
        ){
            //-- service worked successfully, but no responses returned
            this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_UNIX );
            this.webServiceHasErrors = true;
        } else {
            this.costCenterApprovers = new CostCenterApprover_element[]{};
                this.costCenterApproversMap = new Map<String, CostCenterApprover_element>();
            
            for (gFRS_CostCenterApprovalWS.costCenterApprvers_element  c : response.costCenterApprvers) {
                System.debug('PN::COST CENTER : ' + c);
                //System.debug( 'looking at element c[' + c + '] level[' + c.level + '][' + c.unixId + ']');
                CostCenterApprover_element center = new CostCenterApprover_element(
                    c.costCenter, c.level, c.firstName, c.lastName, c.unixId, c.amount
                );
                //system.debug('center '+center);
                
                this.costCenterApprovers.add(center);
                this.costCenterApproversMap.put(center.unixId, center);
            }
            
            this.checkCanApprove();
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description checkCanApprove method - Determines if any of the authorized signers can approve the funding request.
*/
    public void checkCanApprove(){
        Boolean canRequestBeApproved = false;
        Decimal highestApprovalAmount = 0;
        
        //-- needs to be the accountable employee.External_id
        system.debug('accountable employee: '+this.fundReq.Accountable_Employee_Approval__c);
        String accountableId = (this.fundReq.Accountable_Employee_Approval__r != null ? this.fundReq.Accountable_Employee_Approval__r.External_Id_gne__c : null );
        system.debug('accountableId '+accountableId);
        
        System.debug( 'costCenterApprovers:' + this.costCenterApprovers );
        
        //-- first, check if the accountable employee is found in the list - if so use that as the only available option
        for( CostCenterApprover_element center : this.costCenterApprovers ){
            if( center.matchUnixIdCaseInsensitive( accountableId )){
                if( center.amount >= this.fundReq.Requested_Amount__c ){
                    this.canAccountableEmployeeSelfFund = true;
                    center.isChecked = true;
                    return;
                }
            }
        }
        
        String centerUnixId = null;
        for(CostCenterApprover_element center : this.costCenterApprovers ){
            center.canApproveRequest = center.amount >= this.fundReq.Requested_Amount__c;
            System.debug( 'fundReq.Financial_Approver_2__r[' + fundReq.Financial_Approver_2__r + ']' );
            System.debug( 'fundReq.Missing_in_gFRS_Approver__c[' + fundReq.Missing_in_gFRS_Approver__c + ']');
            
            centerUnixId = ( center.unixId != null ) ? center.unixId.toUpperCase() : null;
            
            if( centerUnixId != null && fundReq.Financial_Approver_2__r != null ){
                System.debug( 'COMPARING IS CHECKED: [' + centerUnixId + ':' + fundReq.Financial_Approver_2__r.External_ID_gne__c + ']' );
                if( centerUnixId.equalsIgnoreCase( fundReq.Financial_Approver_2__r.External_ID_gne__c ) ){
                    center.isChecked = true;
                    this.selectedCostCenterUnixId = fundReq.Financial_Approver_2__r.External_ID_gne__c;
                }
            }
            
            if( centerUnixId != null && fundReq.Missing_in_gFRS_Approver__c != null ){
                System.debug( 'COMPARING IS CHECKED: [' + centerUnixId + ':' + fundReq.Missing_in_gFRS_Approver__c + ']' );
                if( centerUnixId.equalsIgnoreCase( fundReq.Missing_in_gFRS_Approver__c ) ){
                    center.isChecked = true;
                    this.selectedCostCenterUnixId = fundReq.Missing_in_gFRS_Approver__c;
                }
            }
            
            if( center.amount > highestApprovalAmount ) highestApprovalAmount = center.amount;
            if( center.canApproveRequest ) canRequestBeApproved = true;
            
        }
        
        if(canRequestBeApproved == false){
            ApexPages.addMessage( new ApexPages.message( ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_REQUEST_GREATER +' '+ highestApprovalAmount ));
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description CostCenterApprover_element class - Internal class to stub around the cost center approvers web service results.
*/
    class CostCenterApprover_element {
        public CostCenterApprover_element(String costCenter, String level, String firstName, String lastName, String unixId, String amount){
            this.costCenter = costCenter;
            this.level = level;
            this.firstName = firstName;
            this.lastName = lastName;
            this.unixId = unixId;
            try {
                this.amount = Decimal.valueOf(amount);
            } catch( Exception err ){
                System.debug( 'amount is not a decimal[' + amount + ']');
                this.amount = 0;
            }
            this.canApproveRequest = false;
            this.isChecked = false;
        }
        public String costCenter  {get; set;}
        public String level  {get; set;}
        public String firstName  {get; set;}
        public String lastName  {get; set;}
        public String unixId  {get; set;}
        public Decimal amount {get; set;}
        public Boolean canApproveRequest { get; set; }
        public Boolean isChecked { get; set; }
        
        /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description matchUnixIdCaseInsensitive method - Matches a unix id against this value in a case-insentive manner
*/
        public Boolean matchUnixIdCaseInsensitive( String targetUnixId ){
            if( targetUnixId == null || this.unixId == null ){
                return( false );
            } else {
                return( targetUnixId.toLowerCase().equals( this.unixId.toLowerCase()) );
            }
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description getDefaultCostCenter method - Calls the EmployeeCostCenter web service, and handles the results
*  @POSTCONDITION: if the allocationLI is not set or if the cost center has already been assigned, then nothing is done
*  @POSTCONDITION: determines the cost center and approver for the funding request based on the current user
*/
    public void getDefaultCostCenter(){
        //-- only continue if the allocation has been found AND the Cost Center has NOT been already assigned.
        if( this.allocationLI != null ){           
            //-- remove that it has failed if trying again
            this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.removeMultiSelectitem( this.fundReq.gCOI_Pending_Actions__c, ACTION_EMPLOYEE_WS_FAIL );
            
            gFRS_EmployeeCostCenterWS.employeeCostCenterResponse_element response = null;
            try{
                //-- needs to be the accountable employee.External_id. But defaults to the current user on initial load.
                String accountableId = this.currentUser.External_Id_gne__c;
                if( this.fundReq.Accountable_Employee_Approval__c != null ){
                    try {
                        User[] accountableUsers = [ select External_Id_gne__c from User where id = :this.fundReq.Accountable_Employee_Approval__c limit 1 ];
                        if( accountableUsers != null && accountableUsers.size() > 0 ){
                            accountableId = accountableUsers[0].External_Id_gne__c;
                        }
                    } catch( Exception err ){
                        System.debug( 'accountableId[' + this.fundReq.Accountable_Employee_Approval__c + '] could not be found - usind current user');
                    }
                }
                
                gFRS_EmployeeCostCenterWS.GneCOMM_CostCenter_GFRS_O_1_LDAP_I_1_ServicesPort0 ws = new gFRS_EmployeeCostCenterWS.GneCOMM_CostCenter_GFRS_O_1_LDAP_I_1_ServicesPort0();
                ws.inputHttpHeaders_x = gFRS_util.createAuthenticationHeaderMap();
                ws.timeout_x = WS_TIMEOUT_COUNT;
                response = ws.employeeCostCenter(null, null, null, accountableId, '1' );
                
                if( WS_RESPONSE_ERROR.equals( response.MessageType ) ){
                    throw( new CustomException( response.MessageText ));
                } else {
                    this.handleGetDefaultCostCenterResponse(response);
                }
            } catch(Exception e){
                String errMsg = gFRS_Util.getPrettyMessage(e);
                if( response != null && !(e instanceof CustomException) ) this.fundReq.Web_Service_Error_Message_Detail__c = response.MessageText;
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
                
                if( errMsg.contains( WS_SOAP_FAULT )){
                    //-- treat as missing cost center for now
                    this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_COST_CENTER );
                    errMsg = System.Label.gFRS_ERROR_SOAP_FAULT;
                } else if( errMsg.contains( WS_TIMEOUT )){
                    this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_EMPLOYEE_WS_FAIL );
                    errMsg = ERROR_TIMEOUT;
                }else{
                    this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_COST_CENTER );
                }
                this.webServiceHasErrors = true;
            }
            
            if(this.webServiceHasErrors == true && this.allocationLI.Cost_Center__c != null){
                //cleaning cost center value
                this.allocationLI.Cost_Center_Lookup__c = null;
            }
            
            try {
                gFRS_Util_NoShare.saveLockedFundingRequest( this.fundReq );
                gFRS_Util_NoShare.saveLockedAllocationLI(this.allocationLI);
            } catch( Exception err ){
                String errMsg = gFRS_Util.getPrettyMessage(err);
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, errMsg ));
            }
            
            this.refreshAllocations();
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description handleGetDefaultCostCenterResponse method - handles webservice response
*/
    public void handleGetDefaultCostCenterResponse(gFRS_EmployeeCostCenterWS.employeeCostCenterResponse_element response){
        if(
            (response.MessageText != null && response.MessageText.contains( System.Label.gFRS_ERROR_NO_USERS )) ||
            ( response.employeeDetails == null || response.employeeDetails.size() < 1 )
        ){
            //-- web service went through but there were no responses.
            this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_WS_MISSING_COST_CENTER );
            this.webServiceHasErrors = true;
        } else {
            
            //-- determine the manager
            String managerUnixId = response.employeeDetails[0].managerUnixId;
            Id targetId = gFRS_Util_NoShare.getUserByUnixId(managerUnixId);
            if( targetId != null ){
                this.fundReq.Financial_Approver_1__c = targetId;
            } else {
                //-- web service went through but there were errors
                this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_GFRS_MISSING_MANAGER );
                this.webServiceHasErrors = true;
            }
            
            String responseCostCenter = null;
            try {
                
                responseCostCenter = response.employeeDetails[0].costCenter; // here we have only Cost Center code - e.x. '1160'
                gFRS_Cost_Center_Code__c[] costCenters = [select Id from gFRS_Cost_Center_Code__c where Name =: responseCostCenter and IsActive__c = true limit 1 ];
                
                this.allocationLI.Cost_Center_Lookup__c = costCenters[0].Id;
                this.currentCostCenterName = responseCostCenter;
                
                
            } catch( Exception err ){
                
                this.fundReq.gCOI_Pending_Actions__c = gFRS_Util.addMultiSelectItem( this.fundReq.gCOI_Pending_Actions__c, ACTION_GFRS_MISSING_COST_CENTER );
                this.fundReq.Missing_in_gFRS_Cost_Center__c = responseCostCenter;
                this.webServiceHasErrors = true;
                this.currentCostCenterName = responseCostCenter;
            }
        }
        
        if(this.webServiceHasErrors){
            this.currentCostCenterName = null;  
        }
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description projectTypeSelected method - Checks type of 'scientific project' and 'Field Initiated Exhibits' event/program type.  Needed for SFDC-3072 and SFDC-3546
*/
    public PageReference projectTypeSelected(){
        
        if(projectType!='' && projectType == gFRS_Util.REQUEST_PROGRAM_TYPE_CLINICAL_TRIAL){
            clinicalTrialFlag = true;   
        }else{
            clinicalTrialFlag = false;
            this.fundReq.Clinical_Trial_Include_GNE_Roche_Product__c=null;
        }
        
        if(projectType == 'Healthcare provider education' || projectType == 'Grand Round' || projectType == 'Tumor Board'){
            promoMaterialsFlag=true;
        }else{
            promoMaterialsFlag=false;
            this.fundReq.Promo_material_displayed_in_edu_area__c=null;
        }
        
        return null;
    }
    
    private void setupProjectTypeDynaFields(){
        projectType = this.fundReq.Event_Project_type__c;
    }
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description otherSupportersSelected method - For 'Philantrophic' request type. If 'Other_Commercial_Supporters__c' is set to 'Yes' 'If_known_List_Other_Supporters__c' should be required. Needed for SFDC-2868
*/
    public PageReference otherSupportersSelected(){
        
        if(otherSupporters!='' && otherSupporters == 'Yes'){
            otherSupportersRequired = true;   
        }else{
            otherSupportersRequired = false;
        }   
        
        return null;
    }   
    
    /**
* @author GFRS Dev Team 
* @date 16/02/2016
* @description nqsSelected method - For 'IMED' request type. GFRS-273
*/
    public PageReference nqsSelected(){
        
        if(nqsCriteriaSelected == null || nqsCriteriaSelected == '' || nqsCriteriaSelected == gFRS_Util.NOT_APPLICABLE_STRING){
            nqsSummaryRendered = false;   
        }else{
            nqsSummaryRendered = true;
        }   
        
        return null;
    }   
    
    
    /**
* @author GFRS Dev Team 
* @date 16/02/2016
* @description barriersSelected method - For 'IMED' request type. GFRS-273
*/
    public PageReference barriersSelected(){
        
        if(barrierSelected == null || barrierSelected == '' || barrierSelected == gFRS_Util.NON_OF_THE_ABOVE_STRING){
            barrierSummaryRendered = false;   
        }else{
            barrierSummaryRendered = true;
        }   
        
        return null;
    }
    
    
    
    /**
* @author GFRS Dev Team 
* @date 16/02/2016
* @description qualityOfCareComponentsSelected method - For 'IMED' request type. GFRS-273
*/
    public PageReference qualityOfCareComponentsSelected(){
        
        if(qualityOfCareComponentSelected == null || qualityOfCareComponentSelected == '' || qualityOfCareComponentSelected == gFRS_Util.NON_OF_THE_ABOVE_STRING){
            qualityOfCareComponentsSummaryRendered = false;   
        }else{
            qualityOfCareComponentsSummaryRendered = true;
        }   
        
        return null;
    }
    
    
    /**
* @author GFRS Dev Team 
* @date 12/03/2014
* @description resetThirdPartyOrgAccreditedToNUll method - For 'IMED' request type. If select Will_You_be_Working_With_a_3rd_Party__c field Is_the_Third_Party_org_accredited will be reset to null
*/
    public PageReference resetThirdPartyOrgAccreditedToNUll(){
        
        fundReq.Is_the_Third_Party_org_accredited__c='';
        fundReq.Is_the_Third_Party_org_owned_physician__c='';
        
        return null;
    }
    
    /**
* @author GFRS Dev Team 
* @date 12/03/2014
* @description resetThirdPartyOrgOwnedPhysicianToNull method - For 'IMED' request type. If select Is_the_Third_Party_org_accredited__c field Is_the_Third_Party_org_owned_physician__c will be reset to null
*/
    public PageReference resetThirdPartyOrgOwnedPhysicianToNull(){
        
        fundReq.Is_the_Third_Party_org_owned_physician__c='';
        return null;
    }
    
    
    /**
* @author GFRS Dev Team
* @date 08/08/2013
* @description ThirdPartyWrapper class - wrapper for ThirdParty. 
*/
    public class ThirdPartyWrapper{
        public Integer rowNumber {get; set;}    
        public GFRS_Third_Party__c thirdPartyObject {get; set;} 
        
        public ThirdPartyWrapper(){
            thirdPartyObject = new GFRS_Third_Party__c();
            rowNumber = 0;
        }
        
        public ThirdPartyWrapper(GFRS_Third_Party__c thirdParty){
            thirdPartyObject = thirdParty;
            rowNumber = 0;
        }
        
    }
    
    
    
    /**
* @author GFRS Dev Team 
* @date 27/08/2013
* @description CustomException class - internal exception class
*/
    class CustomException extends Exception {}
}