public with sharing class gFRS_CompilanceController {
    public GFRS_Funding_Request__c fundReq { get; set; }
    public List<FieldUtil> ComplianceFlags { get; set; }
    public Map<String, Object> AcknowledgeCurrentRevenueFlags {get;set;}
    public List<String> ApprovalsOrder {get; set;}

    public gFRS_CompilanceController(ApexPages.StandardController std) {

        this.fundReq = (GFRS_Funding_Request__c) std.getRecord();
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        try {
            this.fundReq = [
                    SELECT Id, Record_Type_Name__c, Name, Funding_Type__c, Event_Program_Title__c,
                            Decision_Date__c, Organization_Name__c, Event_Project_type__c, HC_Compliance_Date__c,
                            Not_Open_to_Similar_Entities__c, Broad_Audience__c, Volunteering_Opp_Not_Avail_to_Community__c,
                            Inappropriate_Event_Type__c, Target_Audience_is_not_HCPs__c, HCP_Audience_Mix__c,
                            Corporate_Membership__c, Organization_Develops_Medicare__c, Unreasonable_Exhibit_Fees__c,
                            Funding_for_Developing_CPG__c, No_Undue_Influence_General_Org_Support__c,
                            Organization_Reputation_Blacklist__c, Inappropriate_Org_Type_for_Field_Exhibit__c, Request_Submitted_by_Individual_or_Group__c,
                            Inappropriate_Org_Type_for_Memberships__c, Organization_Not_a_Non_Profit__c, Organization_Owned_by_HCPs__c,
                            Organization_Type_Political_Sectarian_2__c, Inappropriate_Org_Type_for_Scientific__c, Event_Type_Not_Field_Sales__c,
                            Promotion_Event_has_no_Tangible_Benefits__c,
                            Broad_Audience_Not_Open_to_Others_Notes__c, Broad_Audience_Not_Open_To_Public_Notes__c, Broad_Audience_Volunteer_Not_Avail_Notes__c,
                            Event_Type_Inappropriate_Notes__c, Funding_Purpose_Tgt_Aud_not_HCPs_Notes__c, HCP_Aud_Mix_Learners_not_US_based_Notes__c,
                            Legal_Review_Corporate_Membership_Notes__c, Legal_Review_Develops_Medicare_Notes__c, Legal_Review_High_Amt_Org_of_HCPs_Notes__c,
                            Legal_Review_High_Amt_PEE_Notes__c, Legal_Review_High_Amt_Purchaser_Notes__c, Legal_Review_High_Exhibit_Fees_Notes__c,
                            No_Undue_Influence_Clinical_Pract_Notes__c, No_Undue_Influence_Gen_Org_Support_Notes__c, Org_Reputation_Blacklist_Notes__c,
                            Org_Type_Field_Exhibits_Notes__c, Org_Type_Individual_or_Group_Notes__c, Org_Type_Memberships_Notes__c,
                            Org_Type_Not_a_Non_Profit_Notes__c, Org_Type_Owned_by_HCPs_Notes__c, Org_Type_Political_Sectarian_Notes__c,
                            Org_Type_Sci_Proj_Notes__c, Requester_Not_Submitted_by_Field_Notes__c, Tangible_Benefits_Promotional_Notes__c,
                            Legal_Review_Anticipated_Launch__c,Legal_Review_Anticipated_Launch_Notes__c, Manual_Resolution__c,
                            Promotional_Material_Separated_from_CME__c, Promo_Material_Separated_from_CME_Notes__c,
                            Acknowledge_Current_Revenue_Flags__c, Business_Approver_Decision_Date__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision_Date__c,
                            Financial_Approver_3_Decision_Date__c
                    FROM GFRS_Funding_Request__c
                    WHERE Id = :this.fundReq.Id
                    LIMIT 1
            ];

            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType gfrsSchema = schemaMap.get('GFRS_Funding_Request__c');
            Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();

            if (this.fundReq.Record_Type_Name__c == 'Corporate Memberships') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Not_Open_to_Similar_Entities__c').getDescribe().getLabel(), this.fundReq.Not_Open_to_Similar_Entities__c, fieldMap.get('Broad_Audience_Not_Open_to_Others_Notes__c').getDescribe().getLabel(), this.fundReq.Broad_Audience_Not_Open_to_Others_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                        new FieldUtil(fieldMap.get('Inappropriate_Org_Type_for_Memberships__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Org_Type_for_Memberships__c, fieldMap.get('Org_Type_Memberships_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Memberships_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c)
                };
                if (customSettings.gFRS_Legal_Reviewer_Fields_Required__c) {
                    ComplianceFlags.add(new FieldUtil(fieldMap.get('Corporate_Membership__c').getDescribe().getLabel(), this.fundReq.Corporate_Membership__c, fieldMap.get('Legal_Review_Corporate_Membership_Notes__c').getDescribe().getLabel(), this.fundReq.Legal_Review_Corporate_Membership_Notes__c));
                }

            } else if (this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Not_Open_to_Similar_Entities__c').getDescribe().getLabel(), this.fundReq.Not_Open_to_Similar_Entities__c, fieldMap.get('Broad_Audience_Not_Open_to_Others_Notes__c').getDescribe().getLabel(), this.fundReq.Broad_Audience_Not_Open_to_Others_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c),
                        new FieldUtil(fieldMap.get('Promotion_Event_has_no_Tangible_Benefits__c').getDescribe().getLabel(), this.fundReq.Promotion_Event_has_no_Tangible_Benefits__c, fieldMap.get('Tangible_Benefits_Promotional_Notes__c').getDescribe().getLabel(), this.fundReq.Tangible_Benefits_Promotional_Notes__c)
                };
            } else if (this.fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Not_Open_to_Similar_Entities__c').getDescribe().getLabel(), this.fundReq.Not_Open_to_Similar_Entities__c, fieldMap.get('Broad_Audience_Not_Open_to_Others_Notes__c').getDescribe().getLabel(), this.fundReq.Broad_Audience_Not_Open_to_Others_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c)
                };
                if (customSettings.gFRS_Legal_Reviewer_Fields_Required__c) {
                    ComplianceFlags.add(new FieldUtil(fieldMap.get('Legal_Review_Anticipated_Launch__c').getDescribe().getLabel(), this.fundReq.Legal_Review_Anticipated_Launch__c, fieldMap.get('Legal_Review_Anticipated_Launch_Notes__c').getDescribe().getLabel(), this.fundReq.Legal_Review_Anticipated_Launch_Notes__c));
                }
            } else if (this.fundReq.Record_Type_Name__c == 'Fellowships') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c)
                };
            } else if (this.fundReq.Record_Type_Name__c == 'Field Initiated Exhibits') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Inappropriate_Event_Type__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Event_Type__c, fieldMap.get('Event_Type_Inappropriate_Notes__c').getDescribe().getLabel(), this.fundReq.Event_Type_Inappropriate_Notes__c),
                        new FieldUtil(fieldMap.get('Unreasonable_Exhibit_Fees__c').getDescribe().getLabel(), this.fundReq.Unreasonable_Exhibit_Fees__c, fieldMap.get('Legal_Review_High_Exhibit_Fees_Notes__c').getDescribe().getLabel(), this.fundReq.Legal_Review_High_Exhibit_Fees_Notes__c),
                        new FieldUtil(fieldMap.get('Inappropriate_Org_Type_for_Field_Exhibit__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Org_Type_for_Field_Exhibit__c, fieldMap.get('Org_Type_Field_Exhibits_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Field_Exhibits_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c),
                        new FieldUtil(fieldMap.get('Event_Type_Not_Field_Sales__c').getDescribe().getLabel(), this.fundReq.Event_Type_Not_Field_Sales__c, fieldMap.get('Requester_Not_Submitted_by_Field_Notes__c').getDescribe().getLabel(), this.fundReq.Requester_Not_Submitted_by_Field_Notes__c),
                        new FieldUtil(fieldMap.get('Promotional_Material_Separated_from_CME__c').getDescribe().getLabel(), this.fundReq.Promotional_Material_Separated_from_CME__c, fieldMap.get('Promo_Material_Separated_from_CME_Notes__c').getDescribe().getLabel(), this.fundReq.Promo_Material_Separated_from_CME_Notes__c)
                };
            } else if (this.fundReq.Record_Type_Name__c == 'HC Char') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Broad_Audience__c').getDescribe().getLabel(), this.fundReq.Broad_Audience__c, fieldMap.get('Broad_Audience_Not_Open_To_Public_Notes__c').getDescribe().getLabel(), this.fundReq.Broad_Audience_Not_Open_To_Public_Notes__c),
                        new FieldUtil(fieldMap.get('Volunteering_Opp_Not_Avail_to_Community__c').getDescribe().getLabel(), this.fundReq.Volunteering_Opp_Not_Avail_to_Community__c, fieldMap.get('Broad_Audience_Volunteer_Not_Avail_Notes__c').getDescribe().getLabel(), this.fundReq.Broad_Audience_Volunteer_Not_Avail_Notes__c),
                        new FieldUtil(fieldMap.get('Inappropriate_Event_Type__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Event_Type__c, fieldMap.get('Event_Type_Inappropriate_Notes__c').getDescribe().getLabel(), this.fundReq.Event_Type_Inappropriate_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                        new FieldUtil(fieldMap.get('No_Undue_Influence_General_Org_Support__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_General_Org_Support__c, fieldMap.get('No_Undue_Influence_Gen_Org_Support_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Gen_Org_Support_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Not_a_Non_Profit__c').getDescribe().getLabel(), this.fundReq.Organization_Not_a_Non_Profit__c, fieldMap.get('Org_Type_Not_a_Non_Profit_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Not_a_Non_Profit_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c)
                };
                if (customSettings.gFRS_Legal_Reviewer_Fields_Required__c) {
                    ComplianceFlags.add(new FieldUtil(fieldMap.get('Organization_Develops_Medicare__c').getDescribe().getLabel(), this.fundReq.Organization_Develops_Medicare__c, fieldMap.get('Legal_Review_Develops_Medicare_Notes__c').getDescribe().getLabel(), this.fundReq.Legal_Review_Develops_Medicare_Notes__c));
                }
            } else if (this.fundReq.Record_Type_Name__c == 'IMED') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Inappropriate_Event_Type__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Event_Type__c, fieldMap.get('Event_Type_Inappropriate_Notes__c').getDescribe().getLabel(), this.fundReq.Event_Type_Inappropriate_Notes__c),
                        new FieldUtil(fieldMap.get('Target_Audience_is_not_HCPs__c').getDescribe().getLabel(), this.fundReq.Target_Audience_is_not_HCPs__c, fieldMap.get('Funding_Purpose_Tgt_Aud_not_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Funding_Purpose_Tgt_Aud_not_HCPs_Notes__c),
                        new FieldUtil(fieldMap.get('HCP_Audience_Mix__c').getDescribe().getLabel(), this.fundReq.HCP_Audience_Mix__c, fieldMap.get('HCP_Aud_Mix_Learners_not_US_based_Notes__c').getDescribe().getLabel(), this.fundReq.HCP_Aud_Mix_Learners_not_US_based_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c)
                };
            } else if (this.fundReq.Record_Type_Name__c == 'Philanthropic') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Volunteering_Opp_Not_Avail_to_Community__c').getDescribe().getLabel(), this.fundReq.Volunteering_Opp_Not_Avail_to_Community__c, fieldMap.get('Broad_Audience_Volunteer_Not_Avail_Notes__c').getDescribe().getLabel(), this.fundReq.Broad_Audience_Volunteer_Not_Avail_Notes__c),
                        new FieldUtil(fieldMap.get('Inappropriate_Event_Type__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Event_Type__c, fieldMap.get('Event_Type_Inappropriate_Notes__c').getDescribe().getLabel(), this.fundReq.Event_Type_Inappropriate_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                        new FieldUtil(fieldMap.get('No_Undue_Influence_General_Org_Support__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_General_Org_Support__c, fieldMap.get('No_Undue_Influence_Gen_Org_Support_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Gen_Org_Support_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Not_a_Non_Profit__c').getDescribe().getLabel(), this.fundReq.Organization_Not_a_Non_Profit__c, fieldMap.get('Org_Type_Not_a_Non_Profit_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Not_a_Non_Profit_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c)
                };
                if (customSettings.gFRS_Legal_Reviewer_Fields_Required__c) {
                    ComplianceFlags.add(new FieldUtil(fieldMap.get('Organization_Develops_Medicare__c').getDescribe().getLabel(), this.fundReq.Organization_Develops_Medicare__c, fieldMap.get('Legal_Review_Develops_Medicare_Notes__c').getDescribe().getLabel(), this.fundReq.Legal_Review_Develops_Medicare_Notes__c));
                }
            } else if (this.fundReq.Record_Type_Name__c == 'Scientific Projects') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('Inappropriate_Event_Type__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Event_Type__c, fieldMap.get('Event_Type_Inappropriate_Notes__c').getDescribe().getLabel(), this.fundReq.Event_Type_Inappropriate_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_for_Developing_CPG__c').getDescribe().getLabel(), this.fundReq.Funding_for_Developing_CPG__c, fieldMap.get('No_Undue_Influence_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Owned_by_HCPs__c, fieldMap.get('Org_Type_Owned_by_HCPs_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Owned_by_HCPs_Notes__c),
                        new FieldUtil(fieldMap.get('Inappropriate_Org_Type_for_Scientific__c').getDescribe().getLabel(), this.fundReq.Inappropriate_Org_Type_for_Scientific__c, fieldMap.get('Org_Type_Sci_Proj_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Sci_Proj_Notes__c)
                };
            }

            ComplianceFlags.addAll(
                    new FieldUtil[]{
                            new FieldUtil(fieldMap.get('Request_Submitted_by_Individual_or_Group__c').getDescribe().getLabel(), this.fundReq.Request_Submitted_by_Individual_or_Group__c, fieldMap.get('Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Individual_or_Group_Notes__c),
                            new FieldUtil(fieldMap.get('Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.fundReq.Organization_Reputation_Blacklist__c, fieldMap.get('Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Reputation_Blacklist_Notes__c),
                            new FieldUtil(fieldMap.get('Organization_Type_Political_Sectarian_2__c').getDescribe().getLabel(), this.fundReq.Organization_Type_Political_Sectarian_2__c, fieldMap.get('Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.fundReq.Org_Type_Political_Sectarian_Notes__c),
                            new FieldUtil('', '', fieldMap.get('Manual_Resolution__c').getDescribe().getLabel(), this.fundReq.Manual_Resolution__c)
                    }
            );

            ApprovalsOrder = new List<String>{
                'Business_Approver_Decision_Date__c',
                'Financial_Approver_1_Decision_Date__c',
                'Financial_Approver_2_Decision_Date__c',
                'Financial_Approver_3_Decision_Date__c'
            };

            Map<String, String> approvalsLabels = new Map<String, String>{
                'Business_Approver_Decision_Date__c' => fieldMap.get('Business_Approver__c').getDescribe().getLabel(),
                'Financial_Approver_1_Decision_Date__c' => fieldMap.get('Financial_Approver_1__c').getDescribe().getLabel(),
                'Financial_Approver_2_Decision_Date__c' => fieldMap.get('Financial_Approver_2__c').getDescribe().getLabel(),
                'Financial_Approver_3_Decision_Date__c' => fieldMap.get('Financial_Approver_3__c').getDescribe().getLabel()
            };

            AcknowledgeCurrentRevenueFlags =  String.isNotBlank(this.fundReq.Acknowledge_Current_Revenue_Flags__c)?
                (Map<String,Object>)JSON.deserializeUntyped(this.fundReq.Acknowledge_Current_Revenue_Flags__c) : new Map<String, Object>();

            Boolean allFalse = true;
            for(Object approval : AcknowledgeCurrentRevenueFlags.values()) {
                if((Boolean)approval)
                    allFalse = false;
            }
            if(allFalse) {
                AcknowledgeCurrentRevenueFlags = null;
                ApprovalsOrder = null;
            } else {
                for(String approvalField : AcknowledgeCurrentRevenueFlags.keySet()) {
                    Integer indexOfApprovalSteps = ApprovalsOrder.indexOf(approvalField);
                    if(indexOfApprovalSteps == -1) {
                        AcknowledgeCurrentRevenueFlags = null;
                        ApprovalsOrder = null;
                        break;
                    }
                    if(this.fundReq.get(approvalField) == null) {
                        ApprovalsOrder.remove(indexOfApprovalSteps);
                    }
                }
                for(String approvalField : AcknowledgeCurrentRevenueFlags.keySet()) {
                    AcknowledgeCurrentRevenueFlags.put(approvalField, new Map<String, Object>{
                        'value' => AcknowledgeCurrentRevenueFlags.get(approvalField),
                        'label' => approvalsLabels.get(approvalField)
                    });
                }
            }

        } catch (Exception err) {
            System.debug('unable to load organization and funding request info:' + err.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occurred while loading the funding request'));
            return;
        }
    }

    public class FieldUtil {
        public String labelName { get; set; }
        public String fieldValue { get; set; }
        public String secondLabelName { get; set; }
        public String seconfFieldValue { get; set; }

        public FieldUtil(String labName, String fielName, String secondLabel, String secondValue) {
            this.labelName = labName;
            this.fieldValue = fielName;
            this.secondLabelName = secondLabel;
            this.seconfFieldValue = secondValue;
        }
    }

}