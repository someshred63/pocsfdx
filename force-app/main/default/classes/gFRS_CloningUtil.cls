/**
* @author GFRS Dev Team
* @date 26/11/2014
* @description gFRS_CloningUtil class - utility Class for cloning. 
*/
public without sharing class gFRS_CloningUtil {


    /**
    * @author GFRS Dev Team 
    * @date 26/11/2014
    * @description customCloneWithInsert method - method responsible for custom Clonning operation
    */

    public static GFRS_Funding_Request__c customCloneWithInsert(GFRS_Funding_Request__c request, Id requestOwner, String recordType, Id oganizationID, Id locationID) {
        
        RecordType fundingRequestRecordType = [ SELECT Id FROM RecordType WHERE Name = :recordType AND SobjectType = :gFRS_Util.FUNDING_REQUEST_API_NAME];
        
        String infoNeeded = gFRS_Util.INFO_NEEDED_APPLICATION + ';' + gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS+';' + gFRS_Util.INFO_NEEDED_PROGRAM;
        
        //set save point trasaction will be rollbacked if any error will occurs while cloning
        Savepoint sp = Database.setSavepoint();
        GFRS_Funding_Request__c clonedRequest = new GFRS_Funding_Request__c(   recordTypeId = fundingRequestRecordType.id,
                                                                                    Status__c = gFRS_Util.REQUEST_DEFAULT_STATUS,
                                                                                    Sub_Status__c = gFRS_Util.REQUEST_DEFAULT_SUB_STATUS,
                                                                                    External_Sub_status__c = gFRS_Util.REQUEST_DEFAULT_SUB_STATUS,
                                                                                    Organization__c = oganizationID,
                                                                                    Location__c = locationID,
                                                                                    Information_Needed__c = infoNeeded,
                Funding_Sub_Type__c = request.Funding_Sub_Type__c
                                                                                );
        try{
            insert clonedRequest;
              
              
            //add group to sharing read
            //Group mcsGroup = [ SELECT Id, Name FROM Group WHERE Name = :gFRS_Util.MCS_GROUP_NAME LIMIT 1];
              
            //Database.insert(new List<gFRS_Funding_Request__Share>{ gFRS_Util.createRequestShare( clonedRequest.Id, Userinfo.getUserId(), 'Read' ) }, false);
            //system.debug([select AccessLevel, Id, IsDeleted, LastModifiedById, LastModifiedDate, Parent.Name, ParentId, RowCause, UserOrGroupId from GFRS_Funding_Request__Share where ParentId =: clonedRequest])
            GFRS_Funding_Request__c requestToClone = [  
                SELECT 
                    Entering_on_Behalf_of_Another__c, Event_Program_Title__c, Venue_City__c, Therapeutic_Area_Parent__c, 
                    Therapeutic_Area__c, Please_Specify__c, Business_Unit_2__c, Status__c, 
                    Sub_Status__c, External_Sub_status__c, Decision_Reasons__c, 
                    Comments__c, Compliance_Checks_Messages__c, FMV_Outlier__c, Internal_Tracking_Code_optional__c, 
                    Days_to_Completion__c, Request_Priority__c, RecordTypeId, Funding_Type__c, 
                    Is_Promotional_Sponsorship__c, Requested_Amount__c, Refundable_Deposit_Amount_if_any__c, Total_Program_Budget__c, 
                    Approved_Amount__c, Approval_Reason__c, Requested_Amount_of_Event_Budget__c, Program_Start_Date_Min__c, 
                    Program_End_Date_max__c, Event_Project_type__c, Support_Purpose_Program_Description__c, Prime_Audience__c, Intended_Audience__c, 
                    Meeting_Being_Held_at_a_Lavish_Venue__c, Other_Commercial_Supporters__c, If_known_List_Other_Supporters__c, 
                    Open_to_public__c, Clinical_Practice_Guideline_Development__c, Benefits_Exchanged_for_Funding__c, 
                    Accountable_Employee_Approval__c, Finance_Managers__c, Financial_Approver_1__c, 
                    Financial_Approver_2__c, Financial_Approver_3__c, Delivery_Method__c, Payment_Method__c, 
                    Attention_To__c, Building__c, Add_Update_SAP_Vendor__c, Payment_Delivery_Notifications__c, 
                    Unix_ID__c, Payment_Email_Notification__c, Send_By_FedEx_cost_center_will_be_charg__c, 
                    OwnerId, Organization__c,Location__c, Funding_Sub_Type__c,
                    Will_You_be_Working_With_a_3rd_Party__c, Non_Charitable__c, Event_Project_sub_type__c,Event_Project_sub_type_other__c, Funding_not_used_for_attendee_expenses__c,
                    Licensed_to_conduct_health_screenings__c, Funds_not_used_to_support_doctor_nurse__c, Is_Volunteering_Opportunity_Public__c,
                    Is_this_program_accredited__c, Pediatric_Cancer_Assistance__c, Needs_Assessment__c, Method_for_Measuring_Program_Success__c,
                    External_Tracking_Code_optional__c, Does_Event_Have_Volunteering_Opportunity__c,
                    Students_of_Color_Scholarships__c, Hunger__c, Anticipated_Launch_Within_6_Months__c,
                    Promo_material_displayed_in_edu_area__c,Educational_Objectives_1__c,Competencies_to_be_Achieved__c,Outcomes_Levels__c,
                    NQS_Criteria__c,NQS_Summary__c,Barriers_to_Optimal_Patient_Care__c,Barriers_to_Optimal_Patient_Care_Summary__c,
                    Quality_of_Care_Components__c,Quality_of_Care_Components_Summary__c,Resubmission_Request_Name__c,Roche_Observer__c,
                    Additional_Funding_Name__c,Genentech_Assistance__c,Exhibits_or_Displays_Allowed__c,
                    Opt_In_Process_for_Enduring_Materials__c,If_Yes_Please_Describe_Opt_In_Process__c,Accredited_Program__c,
                    Is_Your_Organization_HCP_Accredited__c,Resubmission__c,Secondary_Invitations_BRC_s_Help_Request__c,Request_for_Additional_Funding__c,
                        Overall_goal_of_the_proposal__c, Is_this_a_clinical_study__c, Onsite_facilities_expertise__c,
                        Funds_Used_To_Pay_Licensed_Physician__c, ACGME_Program_Number__c,
                        Statement_of_relevance_gaps_in_knowledge__c, Basic_Research_Fellow__c,
                        Fellowship_Opportunity_Publication__c, Criteria_to_Select_a_Fellow__c, Patients_treated_annually__c,
                    Received_approval_from_AR__c,
                    Issue_type__c,Issue_type_other__c,Issue_subtype__c,Focus_education__c,Focus_education_other__c,Education_Capacity_Building__c,
                    Primary_Audience__c,Primary_audience_other__c,Free_and_Reduced_Lunch__c,Primary_Objectives__c,Healthcare_Audience__c,Healthcare_Audience_other__c,Program_Outcomes__c     
                    
                FROM GFRS_Funding_Request__c 
                        WHERE Id = :request.Id
            ];
                
            List<String> requestFieldsToClone = new List<String>{
                'Entering_on_Behalf_of_Another__c', 'Event_Program_Title__c', 'Venue_City__c', 'Therapeutic_Area_Parent__c', 'Therapeutic_Area__c',
                'Business_Unit_2__c', 'Status__c', 'Sub_Status__c', 'External_Sub_status__c',
                'Compliance_Checks_Messages__c', 'Days_to_Completion__c', 'Request_Priority__c',
                'RecordTypeId', 'Funding_Type__c', 'Is_Promotional_Sponsorship__c', 'Requested_Amount__c', 'Refundable_Deposit_Amount_if_any__c',
                'Requested_Amount_of_Event_Budget__c', 'Program_Start_Date_Min__c', 'Please_Specify__c',
                'Program_End_Date_max__c', 'Event_Project_type__c', 'Support_Purpose_Program_Description__c',
                'Prime_Audience__c', 'Intended_Audience__c', 'Other_Commercial_Supporters__c', 'If_known_List_Other_Supporters__c',
                'Open_to_public__c', 'Clinical_Practice_Guideline_Development__c', 'Benefits_Exchanged_for_Funding__c', 'Accountable_Employee_Approval__c',
                'Finance_Managers__c', 'Financial_Approver_1__c', 'Financial_Approver_2__c', 'Financial_Approver_3__c', 'Delivery_Method__c',
                'Payment_Method__c', 'Building__c', 'Add_Update_SAP_Vendor__c', 'Payment_Delivery_Notifications__c', 'Unix_ID__c',
                'Payment_Email_Notification__c', 'Send_By_FedEx_cost_center_will_be_charg__c', 'OwnerId', 'Organization__c', 'Location__c',
                'Will_You_be_Working_With_a_3rd_Party__c', 'Non_Charitable__c', 'Event_Project_sub_type__c', 'Event_Project_sub_type_other__c', 'Funding_not_used_for_attendee_expenses__c',
                'Licensed_to_conduct_health_screenings__c', 'Funds_not_used_to_support_doctor_nurse__c', 'Is_Volunteering_Opportunity_Public__c',
                'Is_this_program_accredited__c', 'Pediatric_Cancer_Assistance__c', 'Needs_Assessment__c', 'Method_for_Measuring_Program_Success__c',
                'External_Tracking_Code_optional__c', 'Does_Event_Have_Volunteering_Opportunity__c', 'Funding_Sub_Type__c',
                'Students_of_Color_Scholarships__c', 'Hunger__c', 'Anticipated_Launch_Within_6_Months__c',
                'Promo_material_displayed_in_edu_area__c', 'Educational_Objectives_1__c', 'Competencies_to_be_Achieved__c',
                'Outcomes_Levels__c', 'NQS_Criteria__c', 'NQS_Summary__c',
                'Barriers_to_Optimal_Patient_Care__c', 'Barriers_to_Optimal_Patient_Care_Summary__c',
                'Quality_of_Care_Components__c', 'Quality_of_Care_Components_Summary__c',
                'Resubmission_Request_Name__c','Roche_Observer__c','Additional_Funding_Name__c','Genentech_Assistance__c','Exhibits_or_Displays_Allowed__c',
                'Opt_In_Process_for_Enduring_Materials__c','If_Yes_Please_Describe_Opt_In_Process__c','Accredited_Program__c',
                'Is_Your_Organization_HCP_Accredited__c','Resubmission__c','Secondary_Invitations_BRC_s_Help_Request__c','Request_for_Additional_Funding__c',
                'Overall_goal_of_the_proposal__c', 'Is_this_a_clinical_study__c', 'Onsite_facilities_expertise__c',
                'Funds_Used_To_Pay_Licensed_Physician__c', 'ACGME_Program_Number__c',
                'Statement_of_relevance_gaps_in_knowledge__c', 'Basic_Research_Fellow__c', 'Fellowship_Opportunity_Publication__c',
                'Criteria_to_Select_a_Fellow__c', 'Patients_treated_annually__c',
                'Received_approval_from_AR__c',
                'Issue_type__c', 'Issue_type_other__c', 'Issue_subtype__c', 'Focus_education__c', 'Focus_education_other__c', 'Education_Capacity_Building__c',
                'Primary_Audience__c', 'Primary_audience_other__c', 'Free_and_Reduced_Lunch__c', 'Primary_Objectives__c','Healthcare_Audience__c','Healthcare_Audience_other__c',
                'Program_Outcomes__c'
            };

            if ( recordType == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME || recordType == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) {
                requestFieldsToClone.addAll( new List<String>{ 'Total_Program_Budget__c'} );
            }
            if(gFRS_Util.isInternalRequest(recordType)){
                requestFieldsToClone.addAll( new List<String>{ 'Attention_To__c'} );
            }
            /* GFRS-659 Add below fields only for external requests and FIE */
            if(!gFRS_Util.isInternalRequest(recordType) || recordType == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME){

                requestFieldsToClone.addAll( new List<String>{ 'FMV_Outlier__c', 'Meeting_Being_Held_at_a_Lavish_Venue__c'} );

                if(recordType != gFRS_Util.TYPE_HC_CHAR_NAME && recordType != gFRS_Util.TYPE_PHILANTHROPIC_NAME){
                    requestFieldsToClone.addAll( new List<String>{'Decision_Reasons__c'} );
                }
                
            }

            gFRS_CloningUtil.populateFieldsForObject(requestFieldsToClone, requestToClone, clonedRequest);

            clonedRequest.ParentRecord__c = requestToClone.Id;
            clonedRequest.Request_Cloned__c = 'Yes';
            clonedRequest.Status__c = gFRS_Util.REQUEST_DEFAULT_STATUS;
            clonedRequest.Sub_Status__c = gFRS_Util.REQUEST_DEFAULT_SUB_STATUS;
            clonedRequest.External_Sub_status__c = gFRS_Util.REQUEST_DEFAULT_SUB_STATUS;
            clonedRequest.OwnerId = requestOwner;
            String[] informationNeeded = new String[]{
                gFRS_Util.INFO_NEEDED_BUDGET,
                gFRS_Util.INFO_NEEDED_LOCATION,
                gFRS_Util.INFO_NEEDED_APPLICATION,
                gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS,
                gFRS_Util.INFO_NEEDED_PROGRAM,
                gFRS_Util.INFO_NEEDED_THIRD_PARTY,
                gFRS_Util.INFO_NEEDED_PROGRAM_DESIGN
            };
            if(!gFRS_Util.isInternalRequest(recordType)){
                informationNeeded.add(gFRS_Util.INFO_NEEDED_PAYMENT_METHOD);
            }
            clonedRequest.Information_Needed__c = String.join( informationNeeded, ';');

            List<String> programFieldsToClone = new List<String>{
                        'Type__c','Product_being_Promoted__c', 'Booth_Type__c', 'Size_of_Exhibit__c', 'Actual_Time_at_Display_Table_Hours__c', 
                        'Venue_Name__c', 'Venue_City__c', 'Venue_State__c', 'Venue_Province_Region__c', 'Venue_Zip_Code__c', 'Venue_Country__c',
                        'Program_Title__c','Exhibits_or_Displays_Allowed__c','Number_of_Tables__c','Program_Subtype__c','Speakers_Faculty__c'
                        };
                        
                    
            if( recordType != gFRS_Util.TYPE_HC_CHAR_NAME && recordType != gFRS_Util.TYPE_PHILANTHROPIC_NAME ){
                programFieldsToClone.addAll( new List<String>{ 'Start_Date__c', 'End_Date__c'} );
            }

            if (recordType == gFRS_Util.TYPE_HC_CHAR_NAME){
                programFieldsToClone.addAll( new List<String>{'Expected_of_attendees_that_are_HCPs__c'} );
            }
                 
            upsert clonedRequest;
            Database.insert(new List<gFRS_Funding_Request__Share> { gFRS_Util.createRequestShare( clonedRequest.Id, Userinfo.getUserId(), 'Edit' ) }, false);
            GFRS_Program__c programToUpdate = [SELECT Funding_Request__c, Type__c, Start_Date__c, End_Date__c, Expected_Number_of_Attendees__c,
                    Expected_number_of_students_engaged__c,Expected_number_of_teachers_engaged__c,Expected_number_of_patients_engaged__c,
                    Expected_of_Attendees_US_Based_HCPs__c, Product_being_Promoted__c, Booth_Type__c, Size_of_Exhibit__c, 
                    Actual_Time_at_Display_Table_Hours__c, Venue_Name__c, Venue_City__c, Venue_State__c, 
                    Venue_Province_Region__c, Venue_Zip_Code__c, Venue_Country__c, 
                    Program_Title__c, Benefits_Exchanged_for_Funding__c, Exhibits_or_Displays_Allowed__c, Other_Commercial_Supporters__c,
                    If_Known_List_Other_Supporters__c, Number_of_Tables__c, 
                    Expected_of_attendees_that_are_HCPs__c
                FROM  GFRS_Program__c 
                                               WHERE Funding_Request__c = : clonedRequest.Id ].get(0);
                                                                     
            GFRS_Program__c orginalProgram = [SELECT Funding_Request__c, Type__c, Start_Date__c, End_Date__c, Expected_Number_of_Attendees__c,
                    Expected_number_of_students_engaged__c,Expected_number_of_teachers_engaged__c,Expected_number_of_patients_engaged__c,
                    Expected_of_Attendees_US_Based_HCPs__c, Product_being_Promoted__c, Booth_Type__c, Size_of_Exhibit__c, 
                    Actual_Time_at_Display_Table_Hours__c, Venue_Name__c, Venue_City__c, Venue_State__c, 
                    Venue_Province_Region__c, Venue_Zip_Code__c, Venue_Country__c, If_Known_List_Other_Supporters__c, Other_Commercial_Supporters__c,
                    Exhibits_or_Displays_Allowed__c, Benefits_Exchanged_for_Funding__c, Program_Title__c, Number_of_Tables__c,Program_Subtype__c,Speakers_Faculty__c, 
                    Expected_of_attendees_that_are_HCPs__c
                FROM GFRS_Program__c 
                                              WHERE Funding_Request__c = : requestToClone.Id ].get(0);
                 
            gFRS_CloningUtil.populateFieldsForObject(programFieldsToClone, orginalProgram, programToUpdate);
            programToUpdate.IsCloningProcess__c = true;
            
            update programToUpdate;
                 
            List<String> fundingAllocationLineItemFieldsToClone = new List<String>{
                'Accountable_Employee__c'
            };
            /* GFRS-659 Add below fields only for external requests and FIE to avoid errors when Cost Center is inactive */
            if(!gFRS_Util.isInternalRequest(recordType) || recordType == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME){
                fundingAllocationLineItemFieldsToClone.addAll( new List<String>{'Cost_Center_Lookup__c'} );

                if(recordType != gFRS_Util.TYPE_HC_CHAR_NAME && recordType != gFRS_Util.TYPE_PHILANTHROPIC_NAME){
                    fundingAllocationLineItemFieldsToClone.addAll( new List<String>{'WBS_Code_Lookup__c'} );
                }

            }
                                                    
                 
            GFRS_Funding_Allocation__c fACloned = [SELECT Id FROM GFRS_Funding_Allocation__c WHERE Grant_Request__c = : clonedRequest.id].get(0);
            GFRS_Funding_Allocation__c fAOrginal = [SELECT Id FROM GFRS_Funding_Allocation__c WHERE Grant_Request__c = : requestToClone.Id].get(0);
                 
            List<GFRS_Funding_Allocation_Line_Item__c> fliToCloneList = [ 
                        SELECT Id, Funding_Allocation__c
                FROM GFRS_Funding_Allocation_Line_Item__c 
                WHERE Funding_Allocation__c =:fACloned.Id 
                ORDER BY createdDate ASC
            ];
                                
                                
            List<GFRS_Funding_Allocation_Line_Item__c> orginalFLI = [ 
                        SELECT Accountable_Employee__c, Cost_Center_Lookup__c,
                    Commercial_Activity_ID__c, WBS_Code_Lookup__c, 
                    Amount__c, Percent__c
                FROM  GFRS_Funding_Allocation_Line_Item__c 
                WHERE Funding_Allocation__c =: fAOrginal.Id 
                ORDER BY CreatedDate ASC LIMIT 1
            ];
                 
            GFRS_Funding_Allocation_Line_Item__c finalFLiToClone = new GFRS_Funding_Allocation_Line_Item__c();
                 
                 
            if(!orginalFLI.isEmpty()){
                
                if(fliToCloneList.isEmpty()){
                    finalFLiToClone.Funding_Allocation__c = fACloned.Id;
                }
                else {
                    finalFLiToClone=fliToCloneList.get(0);
                }
                
                gFRS_CloningUtil.populateFieldsForObject(fundingAllocationLineItemFieldsToClone, orginalFLI.get(0), finalFLiToClone);
                finalFLiToClone.Percent__c = 100;
                upsert finalFLiToClone;
            }
            
            
            //Third Party Section
            List<gFRS_Third_Party__c> originalThirdParties = [
                        SELECT Id, Name, Company_Name__c, Funding_Request__c, Is_the_Third_Party_org_accredited__c,
                        Is_Third_Party_org_owned_by_physicians__c, Third_Party_Company_Function__c,
                        Third_Party_Contact_Email__c, Third_Party_Contact_First_Name__c, Third_Party_Contact_Last_Name__c
                        FROM gFRS_Third_Party__c
                        WHERE Funding_Request__c = :requestToClone.Id];
            
            List<gFRS_Third_Party__c> clonedThirdParties = new List<gFRS_Third_Party__c>();
            
            List<String> thirdPartyFieldsToClone = new List<String>{
                'Company_Name__c', 'Is_the_Third_Party_org_accredited__c', 'Is_Third_Party_org_owned_by_physicians__c',
                'Third_Party_Company_Function__c', 'Third_Party_Contact_Email__c', 'Third_Party_Contact_First_Name__c',
                'Third_Party_Contact_Last_Name__c'
            };
            
            for(gFRS_Third_Party__c myThirdParty : originalThirdParties){
                gFRS_Third_Party__c tmpThirdParty = new gFRS_Third_Party__c();
                gFRS_CloningUtil.populateFieldsForObject(thirdPartyFieldsToClone, myThirdParty, tmpThirdParty);
                tmpThirdParty.Funding_Request__c = clonedRequest.Id;
                clonedThirdParties.add(tmpThirdParty);
            }
            
            insert clonedThirdParties;

            //Demographic Section
            if (!gFRS_Util.isInternalRequest(recordType)){
                List<GFRS_Demographic_Group__c> originalDemographic = [
                        SELECT Id, Name, gFRS_Funding_Request__c, Age__c, Sexual_Identity__c, Race_and_Ethnicity__c, 
                        Social_and_Economic_Status__c, Health_and_Insurance_Status__c, Work_Status__c, Support_ESL_NonEnglish__c
                        FROM GFRS_Demographic_Group__c
                        WHERE gFRS_Funding_Request__c = :requestToClone.Id limit 1];
                          
                if (originalDemographic.size() > 0){
                    GFRS_Demographic_Group__c clonedDemographic = new GFRS_Demographic_Group__c();                
                    List<String> demographicFieldsToClone = new List<String>{
                        'Age__c', 'Sexual_Identity__c', 'Race_and_Ethnicity__c',
                        'Social_and_Economic_Status__c', 'Health_and_Insurance_Status__c', 'Work_Status__c',
                        'Support_ESL_NonEnglish__c'
                    };
                    
                    gFRS_CloningUtil.populateFieldsForObject(demographicFieldsToClone, originalDemographic[0], clonedDemographic);
                    clonedDemographic.gFRS_Funding_Request__c = clonedRequest.Id;
                    
                    insert clonedDemographic;
                }
            }
            
        }
        catch (Exception ex) {
            System.debug('Error clonning request: ' + ex);
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
            return null;
        }
             
        return clonedRequest;
    }

    
    /**
    * @author GFRS Dev Team 
    * @date 26/11/2014
    * @description populateFieldsForObject method - method responsible for populating field values from old to new record.
    */
    public static void populateFieldsForObject(List<String> fieldsToClone, sObject orginalObject, sObject clonedObject){
        
        Map<String, Schema.SObjectField> fundingRequestFields = Schema.SObjectType.GFRS_Funding_Request__c.fields.getMap();
        
        for(String field : fieldsToClone){
            
            if ( fundingRequestFields.containsKey(field)
                    && fundingRequestFields.get(field).getDescribe().isUpdateable()
                    || !fundingRequestFields.containsKey(field)
               ) {
                clonedObject.put(field, orginalObject.get(field));
            }   
        }
    }
    
     /**
    * @author GFRS Dev Team 
    * @date 09/12/2014
    * @description getClonedRequestName method - method responsible for returning cloned request name.
    */
    public static String getClonedRequestName(GFRS_Funding_Request__c req){
        String clonedRequestName='';
        if(req != null){
            clonedRequestName = [SELECT name FROM GFRS_Funding_Request__c WHERE id = : req.id].Name;
        }
        return  clonedRequestName;
    }

}