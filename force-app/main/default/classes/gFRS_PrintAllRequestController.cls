/**
 *  Controller to print everything regarding a funding request.
 **/
public with sharing class gFRS_PrintAllRequestController {

    public GFRS_Funding_Request__c fundReq { get; set; }
    public GFRS_Program__c[] programs { get; set; }
    public GFRS_Demographic_Group__c[] demographics { get; set; }
    public GFRS_RequestBudget__c[] budgets { get; set; }
    public GFRS_Third_Party__c[] thirdPartyRecords { get; set; }
    public String recordTypeName { get; set; }
    public Map<Id, GFRS_Program_Audience_Group__c[]> audience { get; set; }
    public Map<Id, GFRS_Request_Budget_Line_Item__c[]> budgetLines { get; set; }
    public GFRS_Funding_Allocation_Line_Item__c allocationLI { get; set; }
    public Boolean showBudget { get; set; }
    public Boolean showDemographic { get; set; }
    public List<gFRS_Program_Design_and_Implementation__c> lprogramDesignImplementationRecords { get; set; }

    public Boolean isInternalRequest {
        get {
            return gFRS_Util.isInternalRequest(this.fundReq.Record_Type_Name__c);
        }
    }

    public Boolean isFoundationShown {
        get {
            //Condition for Philantropic was changed for fix QC-23643 in jira SFDC-1693
            if (gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals(this.fundReq.Record_Type_Name__c)) {
                if (gFRS_Util.YES.equals(this.fundReq.Students_of_Color_Scholarships__c) ||
                        gFRS_Util.YES.equals(this.fundReq.Hunger__c)) {
                    return true;
                } else if (!gFRS_Util.YES.equals(this.fundReq.Students_of_Color_Scholarships__c) && !gFRS_Util.YES.equals(this.fundReq.Hunger__c) && this.fundReq.Requested_Amount__c > 25000) {
                    return true;
                } else
                        return false;

            } else if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(this.fundReq.Record_Type_Name__c)) {
                return(
                        gFRS_Util.YES.equals(this.fundReq.Pediatric_Cancer_Assistance__c)
                );
            } else if (gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals(this.fundReq.Record_Type_Name__c)) {
                return(
                        gFRS_Util.YES.equals(this.fundReq.Basic_Research_Fellow__c)
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
            return(gFRS_Util.isCMEOShown(this.fundReq));
        }
    }
    public Integer getProgramSize() {
        if (programs != null) {
            return programs.size();
        }
        return 0;
    }

    public Integer getBudgetSize() {
        if (this.budgets != null) {
            return this.budgets.size();
        }
        return 0;
    }
    public String getPaymentDeliveryLabel {
        get {
            String s = '<span>Enter your name <br />  1) if you\'ve selected Field Sales or Orange Pouch payment delivery and/or <br />   2) to receive an email when payment is made</span>';
            return s;
        }
    }
    public String getPaymentDeliveryUser {
        get {
            if (this.fundReq != null && this.fundReq.Payment_Delivery_Notifications__c != null) {
                return [SELECT Name FROM User WHERE Id = :THIS.fundReq.Payment_Delivery_Notifications__c].Name;
            } else {
                return '';
            }

        }
    }

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

    public gFRS_PrintAllRequestController(ApexPages.StandardController std) {

        this.fundReq = (GFRS_Funding_Request__c) std.getRecord();

        try {
            this.fundReq = [
                    SELECT
                            Patients_treated_annually__c, Is_this_a_clinical_study__c, NQS_Criteria__c, NQS_Summary__c,
                            Barriers_to_Optimal_Patient_Care__c, Barriers_to_Optimal_Patient_Care_Summary__c,
                            Quality_of_Care_Components__c, Quality_of_Care_Components_Summary__c, Is_there_more_than_one_event_associated__c,
                            Anticipated_Launch_Within_6_Months__c,Name,Payment_Email_Notification__c,
                            Overall_goal_of_the_proposal__c, Statement_of_relevance_gaps_in_knowledge__c,
                            Onsite_facilities_expertise__c, Licensed_to_conduct_health_screenings__c,
                            Funds_Used_To_Pay_Licensed_Physician__c, Funding_not_used_for_attendee_expenses__c,
                            Clinical_Trial_Include_GNE_Roche_Product__c, Is_Volunteering_Opportunity_Public__c,
                            Does_Event_Have_Volunteering_Opportunity__c,Number_of_Tables__c,ACCME__c,Accountable_Employee__c,
                            If_Yes_Please_Describe_Opt_In_Process__c,Opt_In_Process_for_Enduring_Materials__c,
                            In_Post_Approval_State__c,Funding_Type_F__c,Accredited_Program__c,ACGME__c,ACGME_Program_Number__c,
                            Actual_Time_at_Display_Table_Hours__c,Additional_Document_Uploads__c,Additional_Document_Uploads_URL__c,
                            Additional_Funding_Name__c,Amount_Expense_Split__c,Approval_Comments__c,Approved_Amount__c,
                            Where_are_the_attendees_for_this_event_e__c,Attention_To__c,Audit_5013c__c,Audit_OIG__c,Basic_Research_Fellow__c,
                            Benefits_Determination__c,Benefits_Exchanged_for_Funding__c,Booth_Type__c,Briefly_Describe_Goals_Met_to_Date__c,
                            Briefly_Describe_Lessons_Goals_Unmet__c,Broad_Audience__c,Building__c,Business_Review_1_Amount__c,
                            Business_Review_1_Recomendation__c,Business_Reviewer_1__c,Business_Reviewer_1_Notes__c,Business_Reviewer_2__c,
                            Business_Reviewer_2_Notes__c,Business_Reviewer_3__c,Business_Reviewer_3_Notes__c,Cancellation_Reasons__c,
                            Roche_Observer__c,Certification_Check__c,Clinical_Practice_Guideline_Development__c,Closed_Date__c,
                            Close_Grant_Write_off_Refund_Due_Reason__c,Comments__c,Community_Health_Level_7__c,Community_Health_Level_7_URL__c,
                            Competence_Level_4__c,Competence_Level_4_URL__c,Competencies_to_be_Achieved__c,Contact__c,Cost_Center__c,
                            Criteria_to_Select_a_Fellow__c,Date_Submitted__c,Decision_Date__c,Decision_Reasons__c,Delivery_Format_as_of_Total_Budget__c,
                            Delivery_Method__c,Deny_Reason__c,Please_Describe__c,Describe_How_You_WIll_Measure_of_Success__c,Display_Hours__c,
                            Does_Funding_Request_Include_Followng__c,Educational_Objectives__c,Educational_Objectives_1_to_10_fields__c,
                            Educational_Objectives_1__c,Educational_Objectives_10__c,Educational_Objectives_2__c,Educational_Objectives_3__c,
                            Educational_Objectives_4__c,Educational_Objectives_5__c,Educational_Objectives_6__c,Educational_Objectives_7__c,
                            Educational_Objectives_8__c,Method_for_Measuring_Program_Success__c,Educational_Objectives_9__c,Educational_Outcome__c,
                            Enter_PIN__c,Evaluation_Form_Survey__c,Event_Program_Title__c,Event_Project_type__c,
                            Who_is_the_target_audience_for_your_even__c,Audit_Event_Type__c,Exhibits_or_Displays_Allowed__c,
                            Expected_Attendees__c,Expected_Evaluations_at_Time_of_Request__c,Expected_HCP_Attendees__c,
                            Expected_US_HCP_Attendees__c,External_Sub_status__c,External_Tracking_Code_optional__c,
                            Fellowship_Opportunity_Publication__c,Financial_Approver_1__c,Financial_Approver_1_Notes__c,
                            Financial_Approver_2__c,Financial_Approver_3__c,Financial_Approver_3_Notes__c,Financial_Approver_4__c,
                            Financial_Approver_4_Notes__c,Financial_Approver_5__c,Financial_Approver_5_Notes__c,Foundation_Classified__c,
                            Funding_Type__c,Genentech_Invitation_Distribution__c,Genentech_Assistance__c,GL_Account__c,
                            Grant_Only_Used_for_Activity_Detailed__c,HC_Compliance_Date__c,HCP_Audience_Mix__c,How_were_these_achieved__c,
                            Hunger__c,If_no_please_describe__c,If_No_Please_Describe_Changes__c,Please_Specify__c,Intake_Submitted_Date__c,Healthcare_Audience__c,Healthcare_Audience_other__c,
                            Intended_Audience__c,Prime_Audience_other__c,Interpersonal_Communication_Skills_URL__c,Interpersonal_and_Communication_Skills__c,IP_Address__c,
                            Is_this_program_accredited__c,Is_Your_Organization_HCP_Accredited__c,Learning_Level_3__c,Learning_Level_3_URL__c,
                            Legal_Review__c,Legal_Reviewer_1__c,Legal_Reviewer_1_Notes__c,Legal_Reviewer_2__c,Legal_Reviewer_2_Notes__c,
                            LOA_Signed__c,Location__c,Medical_Knowledge__c,Medical_Knowledge_URL__c,Meeting_Being_Held_at_a_Lavish_Venue__c,
                            Needs_Assessment__c,Net_Payment_Total__c,Non_Charitable__c,Non_Renewing_Support__c,No_Undue_Influence__c,
                            Objectives__c,OIG_Check__c,Organization__c,Organization__r.Organization_Name__c,Organization__r.Tax_Id__c,
                            Organization_Reputation__c,Organization_Type__c,Other_Commercial_Supporters__c,Outcomes_Levels__c,Patient_Care__c,
                            Patient_Care_URL__c,Patient_Focused_Support__c,Patient_Health_Level_6__c,Patient_Health_Level_6_URL__c,
                            Payment_Compliance__c,Pediatric_Cancer_Assistance__c,Performance_Level_5__c,Performance_Level_5_URL__c,
                            Practice_based_Learning_Management_URL__c,Practice_based_Learning_and_Management__c,Process_Disposition_Date__c,
                            Product_Being_Promoted__c,Professionalism__c,Professionalism_URL__c,Program_Changes_if_any__c,Program_Description__c,
                            Reason_for_Lower_Approval_Amount__c,Reason_Funds_Not_Used_as_Intended__c,Record_Type_Name__c,Refund_Instructions__c,
                            Remittance_Type__c,Request_Completeness__c,Requested_Amount__c,Request_for_Additional_Funding__c,Resubmission__c,
                            Resubmission_Request_Name__c,RFI__c,Secondary_Invitations_BRC_s_Help_Request__c,
                            Send_By_FedEx_cost_center_will_be_charg__c,Split_Number__c,State_Why_Level_3_7_Not_Achieved__c,
                            Status__c,Students_of_Color_Scholarships__c,Sub_Status__c,Succeess_Measurement_Method__c,
                            Tangible_Benefits__c,Test_Picklist__c,Therapeutic_Area__c,Therapeutic_Area_Parent__c,
                            Total_of_Expected_Learners__c,Total_Activity_Cost_per_Attendee__c,Total_Amount_Funded__c,Total_Amount_Used__c,
                            Unbundling__c,Unix_ID__c,Vendor_Id__c,WBS_Code__c,What_are_you_seeking_funding_for__c,
                            Will_You_be_Working_With_a_3rd_Party__c,Open_to_public__c,If_known_List_Other_Supporters__c,
                            Support_Purpose_Program_Description__c,Program_Outcomes__c,Event_Program_s_Overall_Budget_RU__c,Refundable_Deposit_Amount_if_any__c,
                            Total_Program_Budget__c, Signing_Authority__c,Signing_Authority_First_Name__c,Signing_Authority_Last_Name__c,
                            Signing_Authority_Email__c,Refund_Due__c,Payment_Delivery_Notifications__c,Event_Project_sub_type__c,
                            Event_Project_sub_type_other__c,Funds_not_used_to_support_doctor_nurse__c,Promo_material_displayed_in_edu_area__c,
                            Finance_Managers__c,Entering_on_Behalf_of_Another__c,Accountable_Employee_Approval__c,
                            Organization__r.Accreditation_s_Received__c, Organization__r.Number_of_Employees_with_Advanced_Degree__c,
                            Organization__r.Number_of_Employees_Working_in_Complianc__c,Funding_Sub_Type__c, Organization__r.Outstanding_Accounts_Payable__c,
                            Organization__r.Salary_of_the_Highest_Paid_Executive__c,Organization__r.Pending_Litigation__c,Organization__r.NCI_Designated_Cancer_Center__c,
                            Received_approval_from_AR__c,Issue_type__c,Issue_type_other__c,Issue_subtype__c,Focus_education__c,Focus_education_other__c,Education_Capacity_Building__c,
                            Free_and_Reduced_Lunch__c,Primary_Audience__c,Primary_audience_other__c,Primary_Objectives__c, Payment_registration_due_date__c, Payment_registration_due_date_notes__c,Prime_Audience__c,Organization__r.Type__c
                    FROM GFRS_Funding_Request__c
                    WHERE Id = :THIS.fundReq.Id
            ];
            recordTypeName = this.fundReq.Record_Type_Name__c;
            //FS_ProgramPage_AttendeesGrid_Common
            this.programs = [
                    SELECT
                    (SELECT Id, Name, Program__c, Actual_Learners__c, Actual_Learners_with_Credit__c, Actual_Number_Participants__c, Category_of_Credit__c, Credit_Hours__c, Expected_Learners_Credit__c, Expected_Learners__c, Intended_Audience__c, Invitations_Distributed__c, Number_of_Participants__c, Number_of_Speaking__c, Other__c, Specialty__c FROM Audience_Groups__r),
                            Program_Title__c,Id, IsDeleted, Name, Is_CMEO__c,Size_of_Exhibit__c, Number_of_Tables__c, Actual_Time_at_Display_Table_Hours__c, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Activities__c, Audience_Non_US_Based__c, Audience_US_Based__c, Criteria_for_Fellow_Selection__c, End_Date__c, Enduring_Materials_Opt_Out_Description__c, Enduring_Materials_Opt_Out__c, Funding_Request__c, Geographic_Region__c, NCI_Designated_Cancer_Center__c, Outstanding_Accounts_Payable__c, Product_being_Promoted__c, Program_Subtype__c, Publicity_Plan__c, Expected_number_of_students_engaged__c, Expected_number_of_teachers_engaged__c,Expected_number_of_patients_engaged__c,Genentech_is_not_supporting_more_than_75__c,Are_there_any_other_commercial_sponsors__c,
                            Speakers_Faculty__c, Start_Date__c, Status__c, Type__c, Venue_City__c, Venue_Country__c, Venue_Name__c, Venue_State__c, Venue_Type__c, Venue_Zip_Code__c, Verified__c, Web_URL__c, Expected_Number_of_Attendees__c, Expected_of_attendees_that_are_HCPs__c, Expected_of_Attendees_US_Based_HCPs__c, Event_Program_Type__c, Funding_Type__c, Support_Purpose_Program_Description__c, Booth_Type__c, Number_of_Activities__c, Alternate_Program_Title__c, Number_of_Learners_del__c, Number_of_Learners_Receiving_CME_Credits__c, Average_Years_in_Practice__c, Total_Number_of_Participants__c, Average_Number_of_Patients__c, Total_Visits__c, Number_of_Pages_Viewed__c, Total_Number_of_Pages__c, Results_were_Achieved__c, If_Results_Not_Achieved_State_Why__c, Promotional_Event_Advertising__c, Letter_of_Request__c, Meeting_Agenda__c, Needs_Assessment_Document__c, Implementation_Plan__c, Fellowship_Project_Description__c, Educational_Objectives_Intended_Outcome__c, Program_Status__c, Did_Total_Budget_Amount_for_this_Program__c, If_Yes_New_Total_Budget_for_Program__c, Change_in_Number_of_Commercial_Supporter__c, If_Yes_How_Many_Commercial_Supporters__c, Did_Educational_Objectives_Change__c, If_Yes_New_Educational_Objectives__c, Other_Companies_Supporting_Meeting__c, If_Known_List_Other_Supporters__c, Intended_Audience__c, Method_for_Measuring_Program_Success__c, Event_Meeting_Membership_Public__c, Does_Event_Have_Volunteering_Opportunity__c, Is_Volunteering_Opportunity_Public__c, ACGME_Program_Number__c, Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_this_Process__c, Outcomes_Review_Comments__c, Were_Learning_Objectives_Achieved_LOA__c, Number_of_Respondents_LOA__c, Percent_Responding_LOA__c, Did_Activity_Achieve_Objectives_ASA__c, Number_of_Respondents_ASA__c, Percent_Responding_ASA__c, Was_Material_Organized_Clearly_MOC__c, Number_of_Respondents_MOC__c, Percent_Responding_MOC__c, Format_Helpful_in_Achieving_Objective_FH__c, Number_of_Respondents_FH__c, Percent_Responding_FH__c, Did_Activity_Provide_Interactivity_APO__c, Number_of_Respondents_APO__c, Percent_Responding_APO__c, Did_You_Find_the_Format_to_be_Useful_AFU__c, Number_of_Respondents_AFU__c, Percent_Responding_AFU__c, Is_the_Content_Relevant_to_Practice_CR__c, Number_of_Respondents_CR__c, Promotional_Event_Advertising_URL__c, Percent_Responding_CR__c, Activity_Address_Overcoming_Barrier_AAS__c, Number_of_Respondents_AAS__c, Letter_of_Request_URL__c, Percent_Responding_AAS__c, Does_Content_Translate_Evidence_CTE__c, Number_of_Respondents_CTE__c, Meeting_Agenda_URL__c, Percent_Responding_CTE__c, Program_Reinforce_Current_Patterns_CPP__c, Number_of_Respondents_CPP__c, Needs_Assessment_Document_URL__c, Percent_Responding_CPP__c, Will_Content_Impact_Your_Practice_CIP__c, Number_of_Respondents_CIP__c, Implementation_Plan_URL__c, Percent_Responding_CIP__c, Did_Content_Contribute_Valuable_Info_CVI__c, Number_of_Respondents_CVI__c, Percent_Responding_CVI__c, Would_You_Recommend_to_Colleagues_RAC__c, Number_of_Respondents_RAC__c, Percent_Responding_RAC__c, Rating_Against_Other_CME_Activities_AR__c, Number_of_Respondents_AR__c, Percent_Responding_AR__c, Was_the_Activity_Fair_and_Balanced_FAB__c, Number_of_Respondents_FAB__c, Percent_Responding_FAB__c, Fellowship_Project_Description_URL__c, Venue_Province_Region__c,Benefits_Exchanged_for_Funding__c,Exhibits_or_Displays_Allowed__c,Other_Commercial_Supporters__c,Payment_registration_due_date__c   //-- all fields off the program object for now
                    FROM GFRS_Program__c
                    WHERE Funding_Request__c = :THIS.fundReq.Id
            ];

            this.showDemographic = false;
            if (recordTypeName.equals(gFRS_Util.TYPE_PHILANTHROPIC_NAME) || recordTypeName.equals(gFRS_Util.TYPE_HC_CHAR_NAME) || recordTypeName.equals(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) || recordTypeName.equals(gFRS_Util.TYPE_FELLOWSHIPS_NAME)) {
                this.showDemographic = true;
            }
            if (this.showDemographic) {
                this.demographics = [
                        SELECT id, Name, gFRS_Funding_Request__c, Age__c, Sexual_Identity__c, Race_and_Ethnicity__c, Social_and_Economic_Status__c, Health_and_Insurance_Status__c, Work_Status__c, Support_ESL_NonEnglish__c
                        FROM GFRS_Demographic_Group__c
                        WHERE gFRS_Funding_Request__c = :THIS.fundReq.Id
                ];
            }

            this.thirdPartyRecords = [
                    SELECT Company_Name__c,Third_Party_Contact_First_Name__c,
                            Third_Party_Contact_Last_Name__c,Third_Party_Company_Function__c,
                            Third_Party_Contact_Email__c,
                            Is_the_Third_Party_org_accredited__c,
                            Is_Third_Party_org_owned_by_physicians__c
                    FROM GFRS_Third_Party__c
                    WHERE Funding_Request__c = :THIS.fundReq.Id
                    ORDER BY CreatedDate ASC
            ];

            lprogramDesignImplementationRecords = [
                    SELECT Id,
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
                    WHERE gFRS_Funding_Request__c = :fundReq.Id
            ];
            /*
            audience = new Map<ID, GFRS_Program_Audience_Group__c[]>();
            for(GFRS_Program__c p : this.programs){
                GFRS_Program_Audience_Group__c[] audienceList = [select id, Name, Program__c, Actual_Learners__c, Actual_Learners_with_Credit__c, Actual_Number_Participants__c, Category_of_Credit__c, Credit_Hours__c, Expected_Learners_Credit__c, Expected_Learners__c, Intended_Audience__c, Invitations_Distributed__c, Number_of_Participants__c, Number_of_Speaking__c, Other__c, Specialty__c
                 from GFRS_Program_Audience_Group__c where Program__c = :p.Id];
                audience.put(p.Id,audienceList);
                
            }
            */
            this.showBudget = true;
            if (recordTypeName.equals(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) || recordTypeName.equals(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) || recordTypeName.equals(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME) || recordTypeName.equals(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)) {
                this.showBudget = false;
            }
            if (this.showBudget) {
                this.budgets = [
                        SELECT
                        (SELECT Id, Name, Amount__c, Budget_Category__c, Budget_Subcategory__c, Comments_Clarification__c, Count__c FROM Budget_Lines__r),
                                Id, Name, Amount__c, Budget_Summary_Description__c
                        FROM GFRS_RequestBudget__c
                        WHERE Grant_Request__c = :THIS.fundReq.Id
                ];
                /*
                budgetLines = new Map<ID, GFRS_Request_Budget_Line_Item__c[]>();
                for(GFRS_RequestBudget__c b : this.budgets){
                    GFRS_Request_Budget_Line_Item__c[] lineItems = [select id, Name, Amount__c, Budget_Category__c, Budget_Subcategory__c, Comments_Clarification__c, Count__c
                     from GFRS_Request_Budget_Line_Item__c where Budget__c = :b.Id];
                    budgetLines.put(b.Id, lineItems);
                    
                }
                */
            }
            if (isInternalRequest) {
                GFRS_Funding_Allocation__c[] allocations = [SELECT Id FROM GFRS_Funding_Allocation__c WHERE Grant_Request__c = :THIS.fundReq.Id];
                if (allocations.size() > 0) {

                    GFRS_Funding_Allocation_Line_Item__c[] allocationLIs = [
                            SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Funding_Allocation__c, Amount__c, Cost_Center_Description__c, Cost_Center_Lookup__c, Accountable_Employee__c, Cost_Center__c, Grant_Request__c, Line_Item_Total__c, Percent__c, Request_Name__c, WBS_Code_Lookup__c, WBS_Description__c, WBS__c, GL_Account_Code__c,Commercial_Activity_ID__c
                            FROM GFRS_Funding_Allocation_Line_Item__c
                            WHERE Funding_Allocation__c = :allocations[0].Id
                    ];

                    if (allocationLIs != null && allocationLIs.size() > 0) {
                        this.allocationLI = allocationLIs[0];
                    }
                }
            }

        } catch (Exception err) {
            System.debug('unable to load funding request:' + this.fundReq.Id);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to load funding request'));
            return;
        }
    }
}