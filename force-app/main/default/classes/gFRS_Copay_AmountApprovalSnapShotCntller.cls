public class gFRS_Copay_AmountApprovalSnapShotCntller {
    
    public GFRS_copay_Funding_Request__c fundingReq { get; set; }
    public GFRS_Organization__c org {get; set;}
    public List<FieldUtil> ApproverDetails {get;set;}
    public List<FieldUtil> ComplianceFlags {get;set;} 
    public List<gFRS_CoPay_Disease_State__c> diseaseStateList {get; set;}
    
    public gFRS_Copay_AmountApprovalSnapShotCntller(ApexPages.StandardController std){
        
        GFRS_copay_Funding_Request__c fundReq = (GFRS_copay_Funding_Request__c)std.getRecord();
        
        this.fundingReq = [select Id, Name, Organization_Name__c, Donation_Requested_for_YY_quarter1__c, Manual_Resolution__c, No_Undue_Influence_Clinical_Practices__c, Donation_requested_for_quarter__c,
                            CST_Reviewer__c, CST_Approver__c, Finance_Approver__c, VP_Approver__c, CFO_Approver__c, Estimated_Current_Revenue_Exceeded_33__c, No_Undue_Influence_Clinical_Pract_Notes__c,
                            Requested_Amount1__c, Total_Payment_Amount__c, Estimated_Current_Revenue_Percent__c, Organization__c, Locationcopay__r.Vendor_ID__c,
                            Organization_Reputation_Blacklist__c, Organization_Type_Owned_by_HCPs__c, Organization_Type_Political_Sectarian__c, Locationcopay__r.Partner_Bank_Type__c,
                            Organization_Type_Religious__c, Organization_Outdated_OIG_Opinion__c, Organization_DiseaseFundDefinition__c, Locationcopay__r.Vendor_Name__c,
                            CST_Reviewer__r.Name, CST_Approver__r.Name, Finance_Approver__r.Name, VP_Approver__r.Name, CFO_Approver__r.Name, Organization_Type_Individual_or_Group__c,
                            Org_Reputation_Blacklist_Notes__c, Organization_Outdated_OIG_Opinion_Notes__c, Org_Disease_Fund_Definition_Notes__c, Org_Type_Individual_or_Group_Notes__c,
                            Org_Type_Political_Sectarian_Notes__c, Org_Type_Owned_by_HCPs_Notes__c, Organization_Type_Religious_Notes__c, Compliance_Checks_Messages__c,
                            (Select Disease_State_Fund_Name__c, Payment_Amount__c, Requested_Donation_Amount__c, Approved_Amount__c from gFRS_CoPay_Disease_State__r ) 
                            from  GFRS_copay_Funding_Request__c where id = : fundReq.id];
                            
        if(this.fundingReq.Estimated_Current_Revenue_Exceeded_33__c == False && this.fundingReq.Estimated_Current_Revenue_Percent__c > 33.0){
            this.fundingReq.Estimated_Current_Revenue_Exceeded_33__c = True;
        }
        
        this.org = [select id, Name, Organization_Name__c from GFRS_Organization__c where id = : fundingReq.Organization__c];
                            
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType gfrsSchema = schemaMap.get('GFRS_Copay_Funding_Request__c');
        Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
            
        ComplianceFlags = new List<FieldUtil> {
            new FieldUtil(fieldMap.get('Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.fundingReq.Organization_Reputation_Blacklist__c, this.fundingReq.Org_Reputation_Blacklist_Notes__c),
            new FieldUtil(fieldMap.get('Organization_Type_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundingReq.Organization_Type_Owned_by_HCPs__c, this.fundingReq.Org_Type_Owned_by_HCPs_Notes__c),
            new FieldUtil(fieldMap.get('Organization_Type_Political_Sectarian__c').getDescribe().getLabel(), this.fundingReq.Organization_Type_Political_Sectarian__c, this.fundingReq.Org_Type_Political_Sectarian_Notes__c),
            new FieldUtil(fieldMap.get('Organization_Type_Religious__c').getDescribe().getLabel(), this.fundingReq.Organization_Type_Religious__c, this.fundingReq.Organization_Type_Religious_Notes__c),
            new FieldUtil(fieldMap.get('Organization_Outdated_OIG_Opinion__c').getDescribe().getLabel(), this.fundingReq.Organization_Outdated_OIG_Opinion__c, this.fundingReq.Organization_Outdated_OIG_Opinion_Notes__c),
            new FieldUtil(fieldMap.get('Organization_DiseaseFundDefinition__c').getDescribe().getLabel(), this.fundingReq.Organization_DiseaseFundDefinition__c, this.fundingReq.Org_Disease_Fund_Definition_Notes__c),
            new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.fundingReq.No_Undue_Influence_Clinical_Practices__c, this.fundingReq.No_Undue_Influence_Clinical_Pract_Notes__c),
            new FieldUtil(fieldMap.get('Organization_Type_Individual_or_Group__c').getDescribe().getLabel(), this.fundingReq.Organization_Type_Individual_or_Group__c, this.fundingReq.Org_Type_Individual_or_Group_Notes__c)
        };
        
        ApproverDetails = new List<FieldUtil>{
            new FieldUtil(fieldMap.get('CST_Reviewer__c').getDescribe().getLabel(), this.fundingReq.CST_Reviewer__r.Name),
            new FieldUtil(fieldMap.get('CST_Approver__c').getDescribe().getLabel(), this.fundingReq.CST_Approver__r.Name),
            new FieldUtil(fieldMap.get('Finance_Approver__c').getDescribe().getLabel(), this.fundingReq.Finance_Approver__r.Name),
            new FieldUtil(fieldMap.get('VP_Approver__c').getDescribe().getLabel(), this.fundingReq.VP_Approver__r.Name)
        };
        
        diseaseStateList = new List<gFRS_CoPay_Disease_State__c>();
        double Requested_Donation_Amount = 0.0;
        double Approved_Amount = 0.0;
        double Payment_Amount = 0.0;
        for(gFRS_CoPay_Disease_State__c ds : fundingReq.gFRS_CoPay_Disease_State__r){
            diseaseStateList.add(ds);
            
            if(ds.Requested_Donation_Amount__c!= null){
                Requested_Donation_Amount = Requested_Donation_Amount + ds.Requested_Donation_Amount__c;
            }
            
            if(ds.Approved_Amount__c!= null){
                Approved_Amount = Approved_Amount + ds.Approved_Amount__c;
            }
            
            if(ds.Payment_Amount__c!= null){
                Payment_Amount = Payment_Amount + ds.Payment_Amount__c;
            }
           
        }
        gFRS_CoPay_Disease_State__c sumDS = new gFRS_CoPay_Disease_State__c(Disease_State_Fund_Name__c = 'Total ', Requested_Donation_Amount__c = Requested_Donation_Amount, Approved_Amount__c = Approved_Amount, Payment_Amount__c = Payment_Amount);
        diseaseStateList.add(sumDS);
        
        
        if(String.isNotBlank(this.fundingReq.CFO_Approver__c)){
            FieldUtil CFO_Approver_Details = new FieldUtil(fieldMap.get('CFO_Approver__c').getDescribe().getLabel(),  this.fundingReq.CFO_Approver__r.Name);
            ApproverDetails.add(CFO_Approver_Details);
        }
        
    }
    
    public class FieldUtil{
        public String labelName{get;set;}
        public String fieldValue{get;set;}
        public String fieldNotes{get;set;}
        
        public FieldUtil(String labName, String fieldValue) {
            this.labelName=labName;
            this.fieldValue=fieldValue;
        }
        
        public FieldUtil(String labName, String fieldValue, String fieldNotes) {
            this.labelName=labName;
            this.fieldValue=fieldValue;
            this.fieldNotes=fieldNotes;
        }
    }

}