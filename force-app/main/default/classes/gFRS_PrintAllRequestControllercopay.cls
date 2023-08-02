/**
 *  Controller to print everything regarding a funding request.
 **/
public with sharing class gFRS_PrintAllRequestControllercopay {
       
    public GFRS_copay_Funding_Request__c fundReq                                               { get; set; }
    public GFRS_Program__c[] programs                                                          { get; set; }
    public GFRS_Demographic_Group__c[] demographics                                            { get; set; }
    public GFRS_RequestBudget__c[] budgets                                                     { get; set; }
    public GFRS_Third_Party__c[] thirdPartyRecords                                             { get; set; }
    public string recordTypeName                                                               { get; set; }
    public Map<ID, GFRS_Program_Audience_Group__c[]> audience                                  { get; set; }
    public Map<ID, GFRS_Request_Budget_Line_Item__c[]> budgetLines                             { get; set; }
    public GFRS_Funding_Allocation_Line_Item__c allocationLI                                   { get; set; }
    public Boolean showBudget                                                                  { get; set; }
    public Boolean showDemographic                                                             { get; set; }
    public List<gFRS_Program_Design_and_Implementation__c> lprogramDesignImplementationRecords { get; set; }
    public string text {get{return 'Your organization\'s disease fund(s) definition(s) is consistent with OIG guidance, in that they:';}}
    public string text2 {get{return '';}}

    public Boolean isInternalRequest{
        get{
            return gFRS_Util.isInternalRequest(this.fundReq.Record_Type_Name__c);
        }   
    }
     
    public Boolean isFoundationShown {
        get {
            //Condition for Philantropic was changed for fix QC-23643 in jira SFDC-1693
            if( gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals( this.fundReq.Record_Type_Name__c )){
                if( gFRS_Util.YES.equals( this.fundReq.Students_of_Color_Scholarships__c) ||
                    gFRS_Util.YES.equals( this.fundReq.Hunger__c )){
                    return true;
                }else if(!gFRS_Util.YES.equals( this.fundReq.Students_of_Color_Scholarships__c) && !gFRS_Util.YES.equals( this.fundReq.Hunger__c ) && this.fundReq.Requested_Amount__c>25000){
                    return true;    
                }else
                    return false;
                
            } else if( gFRS_Util.TYPE_HC_CHAR_NAME.equals( this.fundReq.Record_Type_Name__c )){
                return(
                    gFRS_Util.YES.equals( this.fundReq.Pediatric_Cancer_Assistance__c )
                );
            } else if( gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals( this.fundReq.Record_Type_Name__c )){
                return(
                    gFRS_Util.YES.equals( this.fundReq.Basic_Research_Fellow__c )
                );
            } else {
                return( false );
            }
        }
    }
    public String[] FoundationFieldSet{
        get {
            String[] results = new String[]{ 'Outstanding_Accounts_Payable__c', 'Salary_of_the_Highest_Paid_Executive__c', 'Pending_Litigation__c' };
            return( results );
        }
    }

    //-- inline fieldsets
    public String[] confirmationFieldSet {
        get {
            return( new String[]{
            'Signing_Authority_First_Name__c',
            'Signing_Authority_Last_Name__c',
            'Signing_Authority_Email__c'
            });
        }
    }
    
    /** whether the 'Corporate Memberships with Exhibit Opportunities' section can be shown **/
    public Boolean isCMEOShown { 
        get {
            return( gFRS_Utilcopay.isCMEOShowncopay( this.fundReq ));
        }
    }
    public Integer getProgramSize(){
        if(programs != null){
            return programs.size(); 
        }
        return 0;
    }
    
    public Integer getBudgetSize(){
        if(this.budgets != null ){
            return this.budgets.size();
        }
        return 0;
    }
    public String getPaymentDeliveryLabel{
        get{
            String s='<span>Enter your name <br />  1) if you\'ve selected Field Sales or Orange Pouch payment delivery and/or <br />   2) to receive an email when payment is made</span>';
            return s;
        }
    }
    public String getPaymentDeliveryUser{
        get{
            if(this.fundReq!=null && this.fundReq.Payment_Delivery_Notifications__c!=null){
                return [select Name from User where id=:this.fundReq.Payment_Delivery_Notifications__c].Name;
            }else{
                return '';
            }   
            
        }
    }
    
    public String[] FS_ThirdParty { get{ return( new String[]{ 'Will_You_be_Working_With_a_3rd_Party__c' } ); } }
    public String[] FS_ThirdPartyFields{get{ 
                                            return( new String[]{'Company_Name__c','Third_Party_Contact_First_Name__c',
                                                    'Third_Party_Contact_Last_Name__c','Third_Party_Company_Function__c',
                                                    'Third_Party_Contact_Email__c'});
                                            }
    }
    public String[] FS_AllocationReadOnly { get{ return( new String[]{ 'Cost_Center__c' } ); } }
    
    public gFRS_PrintAllRequestControllercopay( ApexPages.StandardController std ){
        
        this.fundReq = (GFRS_copay_Funding_Request__c)std.getRecord();
        
        
        
        try {
            this.fundReq = [ SELECT Organization__r.Fiscal_Year_Ending__c, Donation_requested_for_quarter__c, Organization__r.Is_this_a_religious_organization__c , Organization__r.How_many_physicians_are_in_the_group_pra__c , IsReviewedbyExternalUser__c, Organization__r.Is_your_organization_a_Sole_Proprietorsh__c , Organization__r.TypeCopay__c , Record_Type_Name__c, Id, Name, Organization__r.Organization_Name__c, Organization__r.Tax_Id__c,Organization__r.Country__c,Organization__r.Tax_Status__c,Organization__r.Type__c,Please_enter_the_co_pay_donation_request__c,Do_you_have_a_donation_agreement__c,Are_you_requesting_a_co_pay_donation__c,Donation_Requested_for_YY_quarter__c,Fiscal_Year_Ending__c,Organization__r.Projected_Annual_Revenue_for_Fiscal_Year__c, Organization__r.Actual_YeartoDate_Annual_Revenue_for_Fis__c,
            Organization__r.Website_Address__c,Organization__r.Parent_Org_Name__c,Organization__r.Parent_Organization_Tax_ID__c,Organization__r.Is_your_organization_an_individual_grou__c,Organization__r.Is_your_organization_a_charitable_founda__c,Organization__r.Is_this_support_for_a_religious_purpose__c,Organization__r.Is_this_a_political_or_sectarian_organiz__c,Organization__r.Is_this_organization_owned_in_whole_or_i__c,Organization__r.W9_Form__c, 
             Organization__r.Actual_Annual_Revenue_for_Prior_Fiscal_Y__c,Funding_Type__c,Are_designed_in_accordance_with_widely_r__c,Are_not_defined_by_reference_to_specific__c,Cover_a_wide_spectrum_of_FDA_approved_pr__c,Will_the_funding_from_this_request_be_us__c,W_9__c,OIG_Opinion__c,Donation__c,Year_1_Form990__c,Year_2_Form990__c,Year_3_Form990__c,Year_1_Annual_Report__c,Year_2_Annual_Report__c,Year_3_Annual_Report__c,Year_1_Audit__c,Year_2_Audit__c,Year_3_Audit__c,Locationcopay__r.Address__c,
             Locationcopay__r.Name,Locationcopay__r.City__c,Locationcopay__r.State__c,Locationcopay__r.Province_Region_Territory__c,Locationcopay__r.Zip__c,Locationcopay__r.Department_Chapter_Country__c
             ,Signing_Authority_First_Name__c,Does_your_organization_have_an_unfavorab__c,Signing_Authority_Last_Name__c,Signing_Authority_Email__c,(Select Disease_State_Fund_Name__c,Requested_Donation_Amount__c from gFRS_CoPay_Disease_State__r )
                 from GFRS_copay_Funding_Request__c
                where id = :this.fundReq.id
                ];
            recordTypeName = this.fundReq.Record_Type_Name__c;
            //FS_ProgramPage_AttendeesGrid_Common
            this.programs = [select
                (select id, Name, Program__c, Actual_Learners__c, Actual_Learners_with_Credit__c, Actual_Number_Participants__c, Category_of_Credit__c, Credit_Hours__c, Expected_Learners_Credit__c, Expected_Learners__c, Intended_Audience__c, Invitations_Distributed__c, Number_of_Participants__c, Number_of_Speaking__c, Other__c, Specialty__c from Audience_Groups__r),
                Program_Title__c,Id, IsDeleted, Name, Is_CMEO__c ,Size_of_Exhibit__c, Number_of_Tables__c, Actual_Time_at_Display_Table_Hours__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Activities__c, Audience_Non_US_Based__c, Audience_US_Based__c, Criteria_for_Fellow_Selection__c, End_Date__c, Enduring_Materials_Opt_Out_Description__c, Enduring_Materials_Opt_Out__c, Funding_Request__c, Geographic_Region__c, NCI_Designated_Cancer_Center__c, Outstanding_Accounts_Payable__c, Product_being_Promoted__c, Program_Subtype__c, Publicity_Plan__c, Expected_number_of_students_engaged__c, Expected_number_of_teachers_engaged__c,Expected_number_of_patients_engaged__c,
                Speakers_Faculty__c, Start_Date__c, Status__c, Type__c, Venue_City__c, Venue_Country__c, Venue_Name__c, Venue_State__c, Venue_Type__c, Venue_Zip_Code__c, Verified__c, Web_URL__c, Expected_Number_of_Attendees__c, Expected_of_attendees_that_are_HCPs__c, Expected_of_Attendees_US_Based_HCPs__c, Event_Program_Type__c, Funding_Type__c, Support_Purpose_Program_Description__c, Booth_Type__c, Number_of_Activities__c, Alternate_Program_Title__c, Number_of_Learners_del__c, Number_of_Learners_Receiving_CME_Credits__c, Average_Years_in_Practice__c, Total_Number_of_Participants__c, Average_Number_of_Patients__c, Total_Visits__c, Number_of_Pages_Viewed__c, Total_Number_of_Pages__c, Results_were_Achieved__c, If_Results_Not_Achieved_State_Why__c, Promotional_Event_Advertising__c, Letter_of_Request__c, Meeting_Agenda__c, Needs_Assessment_Document__c, Implementation_Plan__c, Fellowship_Project_Description__c, Educational_Objectives_Intended_Outcome__c, Program_Status__c, Did_Total_Budget_Amount_for_this_Program__c, If_Yes_New_Total_Budget_for_Program__c, Change_in_Number_of_Commercial_Supporter__c, If_Yes_How_Many_Commercial_Supporters__c, Did_Educational_Objectives_Change__c, If_Yes_New_Educational_Objectives__c, Other_Companies_Supporting_Meeting__c, If_Known_List_Other_Supporters__c, Intended_Audience__c, Method_for_Measuring_Program_Success__c, Event_Meeting_Membership_Public__c, Does_Event_Have_Volunteering_Opportunity__c, Is_Volunteering_Opportunity_Public__c, ACGME_Program_Number__c, Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_this_Process__c, Outcomes_Review_Comments__c, Were_Learning_Objectives_Achieved_LOA__c, Number_of_Respondents_LOA__c, Percent_Responding_LOA__c, Did_Activity_Achieve_Objectives_ASA__c, Number_of_Respondents_ASA__c, Percent_Responding_ASA__c, Was_Material_Organized_Clearly_MOC__c, Number_of_Respondents_MOC__c, Percent_Responding_MOC__c, Format_Helpful_in_Achieving_Objective_FH__c, Number_of_Respondents_FH__c, Percent_Responding_FH__c, Did_Activity_Provide_Interactivity_APO__c, Number_of_Respondents_APO__c, Percent_Responding_APO__c, Did_You_Find_the_Format_to_be_Useful_AFU__c, Number_of_Respondents_AFU__c, Percent_Responding_AFU__c, Is_the_Content_Relevant_to_Practice_CR__c, Number_of_Respondents_CR__c, Promotional_Event_Advertising_URL__c, Percent_Responding_CR__c, Activity_Address_Overcoming_Barrier_AAS__c, Number_of_Respondents_AAS__c, Letter_of_Request_URL__c, Percent_Responding_AAS__c, Does_Content_Translate_Evidence_CTE__c, Number_of_Respondents_CTE__c, Meeting_Agenda_URL__c, Percent_Responding_CTE__c, Program_Reinforce_Current_Patterns_CPP__c, Number_of_Respondents_CPP__c, Needs_Assessment_Document_URL__c, Percent_Responding_CPP__c, Will_Content_Impact_Your_Practice_CIP__c, Number_of_Respondents_CIP__c, Implementation_Plan_URL__c, Percent_Responding_CIP__c, Did_Content_Contribute_Valuable_Info_CVI__c, Number_of_Respondents_CVI__c, Percent_Responding_CVI__c, Would_You_Recommend_to_Colleagues_RAC__c, Number_of_Respondents_RAC__c, Percent_Responding_RAC__c, Rating_Against_Other_CME_Activities_AR__c, Number_of_Respondents_AR__c, Percent_Responding_AR__c, Was_the_Activity_Fair_and_Balanced_FAB__c, Number_of_Respondents_FAB__c, Percent_Responding_FAB__c, Fellowship_Project_Description_URL__c, Venue_Province_Region__c,Benefits_Exchanged_for_Funding__c,Exhibits_or_Displays_Allowed__c,Other_Commercial_Supporters__c,Payment_registration_due_date__c   //-- all fields off the program object for now
                 from GFRS_Program__c where Funding_Request__c = :this.fundReq.Id
            ];

            this.showDemographic = false;
            if (recordTypeName.equals(gFRS_Util.TYPE_PHILANTHROPIC_NAME) || recordTypeName.equals(gFRS_Util.TYPE_HC_CHAR_NAME) || recordTypeName.equals(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) || recordTypeName.equals(gFRS_Util.TYPE_FELLOWSHIPS_NAME)){
                this.showDemographic = true;
            }
            if (this.showDemographic){
                this.demographics = [select id, Name, gFRS_Funding_Request__c, Age__c, Sexual_Identity__c, Race_and_Ethnicity__c, Social_and_Economic_Status__c, Health_and_Insurance_Status__c, Work_Status__c, Support_ESL_NonEnglish__c
                                        from GFRS_Demographic_Group__c where gFRS_Funding_Request__c = :this.fundReq.Id ];
            }

            this.thirdPartyRecords=[select Company_Name__c,Third_Party_Contact_First_Name__c,
                                    Third_Party_Contact_Last_Name__c,Third_Party_Company_Function__c,
                                    Third_Party_Contact_Email__c,
                                    Is_the_Third_Party_org_accredited__c,
                                    Is_Third_Party_org_owned_by_physicians__c
                                    From GFRS_Third_Party__c 
                                    where Funding_Request__c= :this.fundReq.Id order by CreatedDate asc
            ];
            
            lprogramDesignImplementationRecords = [SELECT Id,
                                                    Not_applicable_for_this_education_1__c, 
                                                    Learner_inform_about_evidence_based_ca_1__c,
                                                    Learner_inform_about_problem_to_the_ga_1__c,  
                                                    Not_applicable_for_this_education_2__c,
                                                    Learners_demonstrate_improvements_2__c, 
                                                    Learners_help_system_adopt_information_2__c,
                                                    Demonstrate_improvements_can_reproduce_2__c,  
                                                    Demonstrate_practice_improvements_3__c,
                                                    Example_certification_change_in_proces_3__c,
                                                    Pair_barriers_with_future_intervention_3__c,  
                                                    Not_applicable_for_this_education_3__c,
                                                    Not_applicable_for_this_education_4__c, 
                                                    Improve_communication_about_care_plans_4__c,
                                                    Increase_satisfaction_of_care_4__c, 
                                                    Better_health_living_decisions_adheren_4__c,
                                                    Tools_integrated_to_sustain_change_4__c
                                                FROM gFRS_Program_Design_and_Implementation__c 
                                                WHERE gFRS_Funding_Request__c=:fundReq.id];
       
            this.showBudget = true;
            if(recordTypeName.equals(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME ) || recordTypeName.equals(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) || recordTypeName.equals(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME ) || recordTypeName.equals(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)) { 
                this.showBudget = false;
            }
            if(this.showBudget){
                this.budgets = [select
                    (select id, Name, Amount__c, Budget_Category__c, Budget_Subcategory__c, Comments_Clarification__c, Count__c from Budget_Lines__r),
                    Id, Name, Amount__c, Budget_Summary_Description__c
                     from GFRS_RequestBudget__c where Grant_Request__c = :this.fundReq.Id
                ];  
       
            }
            if(isInternalRequest){
                GFRS_Funding_Allocation__c[] allocations = [select Id from GFRS_Funding_Allocation__c where Grant_Request__c =: this.fundReq.Id];
                if(allocations.size()>0){
                
                    gFRS_Funding_Allocation_Line_Item__c[] allocationLIs = [select Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Funding_Allocation__c, Amount__c, Cost_Center_Description__c, Cost_Center_Lookup__c, Accountable_Employee__c, Cost_Center__c, Grant_Request__c, Line_Item_Total__c, Percent__c, Request_Name__c, WBS_Code_Lookup__c, WBS_Description__c, WBS__c, GL_Account_Code__c,Commercial_Activity_ID__c
                        from GFRS_Funding_Allocation_Line_Item__c
                        where Funding_Allocation__c = : allocations[0].Id ];
                    
                    if( allocationLIs != null && allocationLIs.size() > 0 ){
                        this.allocationLI = allocationLIs[0];
                    }
                }
            }
           
            
        } catch( Exception err ){
            System.debug( 'unable to load funding request:' + this.fundReq.id );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Unable to load funding request' ));
            return;
        }
        
        
        
    }
    
    public void init(){
    string str = ApexPages.currentPage().getParameters().get('Id');
    GFRS_copay_Funding_Request__c fundreq1 = [select IsReviewedbyExternalUser__c from GFRS_copay_Funding_Request__c where id =: str ];
    if(fundreq1.IsReviewedbyExternalUser__c != true){
    fundreq1.IsReviewedbyExternalUser__c = true;
    system.debug('IsReviewedbyExternalUser__c');
    gFRS_Util_NoSharecopay.saveLockedFundingRequestInternalPagecopay(fundreq1);
    }
    }
}