public class gFRS_Ltng_PrintAllRequestController {
   public gFRS_Ltng_Application__c fundReq { get; set; }
    public gFRS_Ltng_CAF_Application__c CAFReq { get; set; }
    public gFRS_Ltng_Program__c[] programs { get; set; }
    public gFRS_Ltng_Third_Party__c[] thirdPartyRecords { get; set; }
    public gFRS_Ltng_Request_Budget__c[] budgets { get; set; }
    public gFRS_Ltng_Demographic_Data__c[] demographics { get; set; }
    public gFRS_Ltng_Vendor_Detail__c[] paymentDtls { get; set; }
    public String recordTypeName { get; set; }
    public Map<Id, gFRS_Ltng_Program_Audience_Group__c[]> audience { get; set; }
   // public Map<Id, GFRS_Request_Budget_Line_Item__c[]> budgetLines { get; set; }
    //public GFRS_Funding_Allocation_Line_Item__c allocationLI { get; set; }
    public Boolean showBudget { get; set; }
    public Boolean showDemographic { get; set; }
    public string attachmentid {get; set;}

   // public List<gFRS_Program_Design_and_Implementation__c> lprogramDesignImplementationRecords { get; set; }

    public Boolean isInternalRequest {
        get {
            return gFRS_Util.isInternalRequest(this.fundReq.Record_Type_Name__c);
        }
    }

    public Boolean isFoundationShown {
        get {
            //Condition for Philantropic was changed for fix QC-23643 in jira SFDC-1693
            if (gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals(this.fundReq.Record_Type_Name__c)) {
                //if (gFRS_Util.YES.equals(this.fundReq.Students_of_Color_Scholarships__c) ||
                //        gFRS_Util.YES.equals(this.fundReq.Hunger__c)) {
               //     return true;} else 
               if (this.fundReq.Requested_Amount__c > 25000) {
                    return true;
                } else
                        return false;

            } else if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(this.fundReq.Record_Type_Name__c)) {
                return(
                        gFRS_Util.YES.equals(this.fundReq.Requested_Amount__c)
                );
            } else if (gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals(this.fundReq.Record_Type_Name__c)) {
                return(
                        gFRS_Util.YES.equals(this.fundReq.Requested_Amount__c)
                );
            } else {
                return(false);
            }
        }
    }
    public String[] FoundationFieldSet {
        get {
            String[] results = new String[]{
                    'Outstanding_Accounts_Payable__c', 'Salary_of_the_Highest_Paid_Executive__c', 'Pending_Litigation__c'
            };
            return(results);
        }
    }
     public Integer getBudgetSize() {
        if (this.budgets != null) {
            return this.budgets.size();
        }
        return 0;
    }
    //-- inline fieldsets
    public String[] confirmationFieldSet {
        get {
            return(new String[]{
                    'Signing_Authority_First_Name__c',
                    'Signing_Authority_Last_Name__c',
                    'Signing_Authority_Email__c'
            });
        }
    }

    /** whether the 'Corporate Memberships with Exhibit Opportunities' section can be shown **/
    public Boolean isCMEOShown {
        get {
            return(gFRS_Ltng_Util.isCMEOShown(this.fundReq));
        }
    }
   /* public Integer getProgramSize() {
        if (programs != null) {
            return programs.size();
        }
        return 0;
    }*/

    /*public Integer getBudgetSize() {
        if (this.budgets != null) {
            return this.budgets.size();
        }
        return 0;
    }*/
    public String getPaymentDeliveryLabel {
        get {
            String s = '<span>Enter your name <br />  1) if you\'ve selected Field Sales or Orange Pouch payment delivery and/or <br />   2) to receive an email when payment is made</span>';
            return s;
        }
    }
   /* public String getPaymentDeliveryUser {
        get {
            if (this.fundReq != null && this.fundReq.Payment_Delivery_Notifications__c != null) {
                return [SELECT Name FROM User WHERE Id = :THIS.fundReq.Payment_Delivery_Notifications__c].Name;
            } else {
                return '';
            }

        }
    }*/

    public String[] FS_ThirdParty {
        get {
            return(new String[]{
                    'Will_You_be_Working_With_a_3rd_Party__c'
            });
        }
    }
    public String[] FS_ThirdPartyFields {
        get {
            return(new String[]{
                    'Company_Name__c', 'Third_Party_Contact_First_Name__c',
                    'Third_Party_Contact_Last_Name__c', 'Third_Party_Company_Function__c',
                    'Third_Party_Contact_Email__c'
            });
        }
    }
    public String[] FS_AllocationReadOnly {
        get {
            return(new String[]{
                    'Cost_Center__c'
            });
        }
    }
	
    public String str {get;set;}
    public gFRS_Ltng_PrintAllRequestController(ApexPages.StandardController std) {
        std.addFields(new list<string>{'Summary__c'});
        this.fundReq = (gFRS_Ltng_Application__c) std.getRecord();
        try {
            this.fundReq = [
                    SELECT id,Name,Sister_Parent_Org_Strategic_Promo_Mktg__c,Firewall_for_Strategic_Promo_Mktg__c,Is_this_program_accredited__c,
                            Org_the_Accreditor__c,Content_Development__c,Outcome_levels_to_be_achieved__c,Other_Commercial_Supporters__c,
                            If_known_List_Other_Supporters__c,Resubmission_of_Previous_Request__c,Resubmission_Request_Name__c,Opt_In_Process_for_Enduring_Materials__c,
                            If_Yes_Please_Describe_Opt_In_Process__c,Secondary_Invitations_BRC_s_Help_Request__c,Is_there_an_exhibit_opportunity_for_this__c,
                            Approved_Amount__c,Record_Type__c,Vendor_Detail__c,Vendor_Detail__r.id,Organization__c,Organization__r.id,Organization__r.Country__c,Organization__r.Organization_Name__c,Organization__r.Tax_Id__c,
                            Organization_Name__c,Evaluation_Methodology__c,Partners_or_Collaborators__c,Sustainability__c,Funding_Publicized__c,Decision_making__c,
                            Selection_Decisions__c,Lead_or_co_led_by_a_Person_of_Color__c,Clinical_Practice_Guideline_Development__c,Associated_clinical_practice_guidelines__c,
                            gFRS_Summary__c,Print_Deadline__c,Thank_You_Benifits__c,Focus_on_equity__c,Primary_Audience_Description__c,Primary_Audience__c,Primary_Audience_Other__c,
                            Addressed_by_this_Program_Initiative__c,Purpose_and_Goals__c,Focus_Area__c,Summary__c,Program_Objectives__c,
                            Needs_Assessment_and_Rationale__c,Please_Specify_If_Disease_State_Other__c,Requested_Amount__c,
                            Therapeutic_Area__c,Disease_State__c,Criteria_for_Fellow_Selection__c,Capacity_Building_Support__c,Date_Submitted__c,Dissemination__c,Print_Deadline_Date__c,
                            Event_Program_Title__c,Will_You_be_Working_With_a_third_Party__c,Total_Overall_Budget__c,
                            Opportunity_Open_to_Other_Companies__c,Support_Purpose_Program_Description__c,Event_program_sub_type__c,
                            Are_you_the_accountable_employee__c,OwnerId,Accountable_Employee_Internal__c,Benefits_Exchanged_for_Funding__c,
                            Refundable_Deposit_Amount_if_any__c,Event_Program_Type__c,List_of_Other_Companies__c,Payment_Cost_Center__c,
                            Contact_Name__c,Contact_Email__c,Program_beyond_the_length__c,Student_impact_people_of_color__c,DraftLOA_href__c,
                            Organization_or_team_facilitated__c,organization_team_past_experience__c,Accountable_Employee_Cost_Center__c,
                			Attention_To__c,Person_To_Whom_Payment_should_addressed__c,Confirm_Payment_Contact_Email_Address__c,Capacity_Building_Support_Other__c,
                			Payment_from_accountable_emp_cost_center__c,Organization_requests_payment_by_date__c,Genentech_Employee_Email__c,
                            Student_impact_people_first_generation__c,Evaluate_the_program__c,Post_program_evaluation__c,Grant_geographic_location__c,
                            Patient_demographics__c,Pending_litigation_or_claims__c,Percentage_breakdown_of_students_by_race__c,ACH_Details_Rec_ID__c,
                            Organization__r.Tax_Status__c,Organization__r.Street__c,Organization__r.City__c,Organization__r.State__c,Organization__r.Zip_Code__c,
                            Organization__r.Operational_Budget__c,Organization__r.Website_Address__c,Organization__r.Number_of_Employees__c,Organization__r.Mission_Statement__c,
                            Organization__r.Type__c,Organization__r.Parent_Org_Name__c,Organization__r.Parent_Organization_Tax_ID__c,Organization__r.gFRS_Organization_Purchase__c,
                            Organization__r.gFRS_Organization_Prescribe__c,Organization__r.gFRS_Organization_Develop__c,Organization__r.gFRS_Organization_Owned__c,
                            Organization__r.gFRS_Do_you_have_W_8BEN_Status__c,Unrestricted_Support_Request__c,
                            Organization__r.Org_Diversity1__c,Organization__r.Org_Diversity7__c,Organization__r.Org_Diversity2__c,Organization__r.Org_Diversity3__c,Organization__r.Org_Diversity4__c,
                            Organization__r.Org_Diversity6__c,Organization__r.OrgRadio15__c,Organization__r.OrgRadio17__c,Organization__r.OrgRadio18__c,
                            Organization__r.OrgRadio19__c,Organization__r.OrgRadio20__c,Organization__r.OrgRadio21__c,Organization__r.OrgRadio22__c,
                            Organization__r.OrgRadio23__c,Organization__r.OrgRadio24__c,Organization__r.OrgRadio25__c,Organization__r.OrgRadio26__c,
                            Organization__r.OrgRadio27__c,Organization__r.OrgRadio28__c,Organization__r.OrgRadio30__c,Organization__r.OrgRadio45__c,
                            Organization__r.OrgRadio41__c,Organization__r.OrgRadio43__c,Organization__r.OrgRadio44__c,Organization__r.OrgRadio29__c,	
                            Organization__r.OrgRadio32__c,Organization__r.OrgRadio33__c,Organization__r.OrgRadio34__c,Organization__r.OrgRadio35__c,
                            Organization__r.OrgRadio36__c,Organization__r.OrgRadio37__c,Organization__r.OrgRadio31__c
                            
                            FROM gFRS_Ltng_Application__c
                            WHERE Id = :THIS.fundReq.Id
            ];
			this.programs = [
                            SELECT (SELECT Id, Name,gFRS_Degree__c,gFRS_Specialty__c,gFRS_Credit_Type__c,gFRS_Credit_Hours__c,gFRS_Exp_Learners__c,
                            gFRS_Expected_Learners_With_Credit__c FROM FRS_Program_Audience_Group__r),gFRS_Expected_of_Attendees_US_Based_HCPs__c,
                            Id,gFRS_Application__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Expected_number_of_attendees__c,gFRS_Number_of_speakers_faculty__c,
                            Event_program_geographic_location__c,gFRS_Venue_Name__c,gFRS_Venue_Country__c,gFRS_Program_Live_Subtype__c,Scientific_Meeting_Broad_Audience__c,
                            gFRS_Venue_City__c,gFRS_Venue_Province_Region_Territory__c,gFRS_Venue_State__c,gFRS_Expected_number_of_patients_served__c,
                            gFRS_Venue_Type__c,gFRS_Venue_Zip_Code__c,gFRS_Secondary_program_title__c,Health_Screening_Broad_Audience__c,gFRS_Program_Type__c,
                            Is_there_an_exhibit_opportunity_price__c,gFRS_Sub_Focus_Area__c,Financial_Assistance_Processes__c,gFRS_Web_URL__c,
                            How_many_attendees_do_you_expect__c,gFRS_Expected_number_of_students_engaged__c,gFRS_Expected_number_of_teachers_engaged__c,
                            Title_1_school__c,gFRS_Focus_on_STEM_education__c,PoC_youth_students__c,Poc_teachers__c,gFRS_Free_and_Reduced_Lunch__c,
                            gFRS_Payment_to_a_Licensed_Physician__c,Product_being_Promoted__c,Are_any_students_impacted_by_Program__c,SubFocusArea__c,
                			gFRS_Nbr_of_Grand_Round_Mtg_Series_Activ__c,gFRS_Live_Real_time__c,gFRS_On_demand_Archived__c,gFRS_Program_Subtype__c,
                            Student_impact_by_program__c,Main_product_exhibited__c,Number_of_exhibit_tables_purchasing__c,Are_there_any_other_commercial_sponsors__c
                            FROM gFRS_Ltng_Program__c
                            WHERE gFRS_Application__c = :THIS.fundReq.Id
            ];
            this.paymentDtls = [
                            SELECT id,Organization_Name__c,Organization_Tax_ID__c,createddate,gFRS_Organization__c,gFRS_Application__c,Name,
                			Address__c,Address2__c,City__c,State__c,Zip__c,Department_Chapter_Country__c,
                			(select id,name,Intermediary_Bank_Routing_ID__c,Intermediary_Bank_Swift_Code__c,Title__c,
                            Intermediary_Bank_Country__c,Intermediary_Bank_Account_Number__c,Intermediary_Bank_Name__c,Bank_Routing_ID__c,
                            Bank_Name__c,Bank_Account_Number__c,IBAN__c,Account_Holder_Name__c
                            FROM gFRS_ACH_Details__r) 
                			FROM gFRS_Ltng_Vendor_Detail__c WHERE id = :THIS.fundReq.Vendor_Detail__r.id
            ];
             this.thirdPartyRecords = [
                            SELECT Id,gFRS_Application__c,Third_Party_Contact_First_Name__c,Third_Party_Contact_Last_Name__c,
                            Third_Party_Contact_Email__c,Third_party_Organization_Name__c,Third_Party_Company_Function__c,
                            Third_Party_Tax_ID__c,Third_party_Organization_type__c,Third_Party_Organization_s_website__c,
                            Is_the_Third_Party_org_accredited__c,whole_or_in_part_by_a_practicing_physic__c,whole_or_in_part_by_a_group_practice__c,
                            family_member_of_a_practicing_physician__c,sole_propiertor_or_single_member_LLC__c
                            FROM gFRS_Ltng_Third_Party__c
                            WHERE gFRS_Application__c = :THIS.fundReq.Id
            ];
            if(fundReq.Record_Type__c == 'Non-Commercial Sponsorship' || fundReq.Record_Type__c == 'Corporate Memberships'||fundReq.Record_Type__c == 'Commercial Sponsorship'||fundReq.Record_Type__c == 'Field Exhibits'){
            this.showBudget = false;
            this.showDemographic = false;
            }else{
              this.showBudget = true;
            this.showDemographic = true;  
            }            
            
            this.budgets = [SELECT (SELECT Id, Name,Category__c,Subcategory__c,Amount__c,Count__c,Explanation__c,gFRS_Request_Budget__c
                           FROM FRS_Request_Budget_Line_Items__r),
                           Id, Name,gFRS_Application__c,Multi_year_budget_attachment_view__c,Budget_Summary_Description__c,Multi_year_budget_attachment__c,Budget_Attachment_File_Name__c,
                           Budget_Attachment_File_Type__c FROM gFRS_Ltng_Request_Budget__c
                           WHERE gFRS_Application__c = :THIS.fundReq.Id
                ];
            
           //this.attachmentid ='';

            this.demographics = [
                        SELECT id, Name,gFRS_Application__c,Age__c,Employment_Status__c,Sexual_orientation__c,Event_Program_leadership_Screen_reader_s__c,Gender_Identity_and_Sexual_Orientation__c,
                        Health_and_Insurance_Status__c,Non_English_speaking_populations__c,Race_and_Ethnicity__c,Social_and_Economic_Status__c,Support_ESL_Non_English__c,
                        Teachers_served__c,Underrepresented_communities__c,Youth_served__c,Age_other__c,Employment_Status_other__c,Gender_Identity_other__c,
                        Health_and_Insurance_other__c,Race_and_Ethnicity_other__c,Sexual_Orientation_other__c,Social_and_Economic_other__c,Age_actual__c,
                        Gender_Identity_Sexual_Orientation_Autl__c,Sexual_orientation_Actual__c,Race_and_Ethnicity_Actual__c,Social_and_Economic_Status_Actual__c,
                        Health_and_Insurance_Status_Actual__c,Employment_Status_Actual__c,Changes_from_Orginal_Submission__c,Employment_Status_other_Actual__c,
                        Health_and_Insurance_other_Actual__c,Race_and_Ethnicity_other_Actual__c,Social_and_Economic_other_Actual__c,Sexual_Orientation_other_Actual__c,
                        Gender_Identity_other_Actual__c,Age_other_Actual__c,Work_Status__c
                        FROM gFRS_Ltng_Demographic_Data__c
                        WHERE gFRS_Application__c  = :THIS.fundReq.Id
                ];

        } catch (Exception err) {
            System.debug('unable to load funding request:' + this.fundReq.Id);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to load funding request'));
            return;
        }
    }
    /*public PageReference process(){
        str = this.fundReq.Summary__c;
        str = str.replaceAll('\n','<br />');
        return null;
    }*/
}