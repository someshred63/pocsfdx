public class gFRS_CAF_ComplianceController {
    
    public gFRS_Ltng_CAF_Application__c fundReq {get; set;}
    public List<FieldUtil> ComplianceFlags {get;set;} 
    
    public gFRS_CAF_ComplianceController(apexPages.StandardController std){
        
        this.fundReq = (gFRS_Ltng_CAF_Application__c)std.getRecord();
        try{
            this.fundReq = [select Id, OwnerId,Name, OIG_Opinion_Attchmnt__c, Program_Audit_Attachment__c, Addition_Document_1__c, gFRS_Organization__c, gFRS_Organization__r.Name,SelectedTab__c, Status__c, Date_for_Limit_Calculation__c, Date_Submitted__c, Donation_Requested_for_Quarter__c, Donation_Requested_for_Quarter_Org__c, Org_Quarter__c, Estimated_Donation_Limit__c, YTD_Total_Approved_Donations__c, Estimated_Remaining_Donation_Limit__c, Total_Requested_Amount__c, Acknowledge_Submit__c, Total_Payment_Amount_Rollup__c, Estimated_Current_Revenue__c, Date_Created__c, Org_Fiscal_Year__c, Total_Paid_Amount_Rollup__c, Acknowledge_Current_Revenue_33__c, Internal_Sub_Status__c, External_Status__c, Sys_Approved__c, Payment_Type__c, Manual_Automated_Payment__c, Vendor_Bank_Reviewed__c, Grant_Approver__c, Finance_Approver__c, VP_Approver__c, CFO_Approver__c, Compliance_Reviewer_Comments__c, Grant_Reviewer_Comments__c, Grant_Approver_Comments__c, Rule_Considered__c, Revenue_Considered__c, Revenue__c, Limit_Calculation_Start_Date__c, Limit_Calculation_End_Date__c, YTD_Total_Approved_Amounts_Copay__c, YTD_Total_Amount_Non_Copay__c, Total_Apprv_Amount__c, Record_Type__c, Final_Approver_Decision_Date__c, Final_Rejection_Decision_Date__c, Compliance_Reviewer_Decision__c, Grant_Reviewer1_Decision__c, Grant_Reviewer2_Decision__c, Finance_Approver_Decision__c, VP_Approver_Decision__c, CFO_Approver_Decision__c, CFO_Approver_Decision_Date__c, Compliance_Reviewer_Decision_Date__c, Grant_Reviewer1_Decision_Date__c, Finance_Approver_Decision_Date__c, Grant_Reviewer2_Decision_Date__c, VP_Approver_Decision_Date__c, Finance_Approver_Comments__c, VP_Approver_Comments__c, CFO_Approver_Comments__c, Stringified_Copay_Requests__c, Stringified_Non_Copay_Requests__c, Review_Recommendation_Deck_Attachment_ID__c, Org_Reputation_Blacklist_Notes__c, Organization_Reputation_Blacklist__c, OrgType_Charitable_Foundation_Notes__c, OrgType_Charitable_Foundation_of_a_Group__c, Org_Type_Political_Sectarian_Notes__c, Organization_Type_Poltical_Sec__c, No_Undue_Influence_Clinical_Pract_Notes__c, Clinical_Practice_Guideline_Development__c, No_Undue_Influence_Clinical_Practices__c, Manual_Resolution__c, Summary_Snapshot_PDF_ID__c, Summary_Snapshot_PDF__c, Review_Recommendation_Deck_Attachment__c, Application_Acknowledgment_Notes__c, Application_Acknowledgment__c, Organization_Tax_Status_Notes__c, Organization_Tax_Status__c from gFRS_Ltng_CAF_Application__c WHERE Id = :this.fundReq.Id LIMIT 1];
                            
        if(this.fundReq.Acknowledge_Current_Revenue_33__c == False && this.fundReq.Estimated_Current_Revenue__c> 33.0 && this.fundReq.Internal_Sub_Status__c== 'Approved'){
            this.fundReq.Acknowledge_Current_Revenue_33__c = True;
        }
            
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType gfrsSchema = schemaMap.get('gFRS_Ltng_CAF_Application__c');
            Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
            
            
            ComplianceFlags = new List<FieldUtil> {
                new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Practices__c, this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.fundReq.Organization_Reputation_Blacklist__c, this.fundReq.Org_Reputation_Blacklist_Notes__c),
                    new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.fundReq.OrgType_Charitable_Foundation_of_a_Group__c, this.fundReq.OrgType_Charitable_Foundation_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.fundReq.Organization_Type_Poltical_Sec__c, this.fundReq.Org_Type_Political_Sectarian_Notes__c),
                    new FieldUtil(fieldMap.get('Application_Acknowledgment__c').getDescribe().getLabel(), this.fundReq.Application_Acknowledgment__c, this.fundReq.Application_Acknowledgment_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Tax_Status__c').getDescribe().getLabel(), this.fundReq.Organization_Tax_Status__c, this.fundReq.Organization_Tax_Status_Notes__c)
                    };
                    

            }catch (Exception err) {
                System.debug( 'unable to load organization and funding request info:' + err.getMessage() );
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding request' ));
                return;
            }
        
        
    }
    
    
    public class FieldUtil{
        public String labelName{get;set;}
        public String fieldValue{get;set;}
        public String fieldNotes{get;set;}
        
        public FieldUtil(String labName, String fieldValue, String fieldNotes) {
            this.labelName=labName;
            this.fieldValue=fieldValue;
            this.fieldNotes=fieldNotes;
        }
    }
    
}