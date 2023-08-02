public without sharing class gFRS_CoPay_Summary_Snapshot {
    
    public gFRS_Ltng_CAF_Application__c fundingReq { get; set; }
    public gFRS_Ltng_Organization__c org {get; set;}
    public List<FieldUtil> ApproverDetails {get;set;}
    public List<FieldUtil> ComplianceFlags {get;set;} 
    public List<gFRS_CAF_Disease_State__c> diseaseStateList {get; set;}
    public gFRS_Ltng_CAF_Application__c fundReq { get; set; }
    
    public gFRS_CoPay_Summary_Snapshot(ApexPages.StandardController std){
        
        fundReq = (gFRS_Ltng_CAF_Application__c) std.getRecord();
        system.debug('fundReq.Id'+fundReq.Id);
        system.debug('fundReq'+fundReq);
        this.fundingReq = [select Id, Name,Donation_Requested_for_Quarter__c,Total_Apprv_Amount__c,Year__c,Grant_Approver__c,Grant_Approver__r.Name,Finance_Approver__c,Finance_Approver__r.Name,
                           VP_Approver__c,VP_Approver__r.Name,CFO_Approver__c,CFO_Approver__r.Name,Total_Requested_Amount__c,Total_Payment_Amount__c,Estimated_Current_Revenue__c,
                           gFRS_Organization__c,Acknowledge_Current_Revenue_33__c,Organization_Reputation_Blacklist__c,Org_Reputation_Blacklist_Notes__c,
                           OrgType_Charitable_Foundation_of_a_Group__c,OrgType_Charitable_Foundation_Notes__c,Organization_Type_Poltical_Sec__c,Org_Type_Political_Sectarian_Notes__c,
                           No_Undue_Influence_Clinical_Practices__c	,No_Undue_Influence_Clinical_Pract_Notes__c,Manual_Resolution__c,
                            (Select Disease_Fund_Name__c, Payment_Amount__c, Requested_Donation_Amount__c, Approved__c from gFRS_CAF_Disease_State__r ) 
                            from  gFRS_Ltng_CAF_Application__c where id = : fundReq.id];
                            
        if(this.fundingReq.Acknowledge_Current_Revenue_33__c == False && this.fundingReq.Estimated_Current_Revenue__c > 33.0){
            this.fundingReq.Acknowledge_Current_Revenue_33__c = True;
        }
        
        this.org = [select id, Name, Organization_Name__c from gFRS_Ltng_Organization__c where id = : fundingReq.gFRS_Organization__c];
                            
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType gfrsSchema = schemaMap.get('gFRS_Ltng_CAF_Application__c');
        Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
            
        ComplianceFlags = new List<FieldUtil> {
            new FieldUtil(fieldMap.get('Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.fundingReq.Organization_Reputation_Blacklist__c, this.fundingReq.Org_Reputation_Blacklist_Notes__c),
            new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.fundingReq.OrgType_Charitable_Foundation_of_a_Group__c, this.fundingReq.OrgType_Charitable_Foundation_Notes__c),
            new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.fundingReq.Organization_Type_Poltical_Sec__c, this.fundingReq.Org_Type_Political_Sectarian_Notes__c),
            new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.fundingReq.No_Undue_Influence_Clinical_Practices__c, this.fundingReq.No_Undue_Influence_Clinical_Pract_Notes__c)
            //new FieldUtil(fieldMap.get('Organization_Outdated_OIG_Opinion__c').getDescribe().getLabel(), this.fundingReq.Organization_Outdated_OIG_Opinion__c, this.fundingReq.Organization_Outdated_OIG_Opinion_Notes__c),
            //new FieldUtil(fieldMap.get('Organization_DiseaseFundDefinition__c').getDescribe().getLabel(), this.fundingReq.Organization_DiseaseFundDefinition__c, this.fundingReq.Org_Disease_Fund_Definition_Notes__c),
            //new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.fundingReq.No_Undue_Influence_Clinical_Practices__c, this.fundingReq.No_Undue_Influence_Clinical_Pract_Notes__c),
            //new FieldUtil(fieldMap.get('Organization_Type_Individual_or_Group__c').getDescribe().getLabel(), this.fundingReq.Organization_Type_Individual_or_Group__c, this.fundingReq.Org_Type_Individual_or_Group_Notes__c)
        };
        
        ApproverDetails = new List<FieldUtil>{
            new FieldUtil(fieldMap.get('Grant_Approver__c').getDescribe().getLabel(), this.fundingReq.Grant_Approver__r.Name),
            new FieldUtil(fieldMap.get('Finance_Approver__c').getDescribe().getLabel(), this.fundingReq.Finance_Approver__r.Name),
            new FieldUtil(fieldMap.get('VP_Approver__c').getDescribe().getLabel(), this.fundingReq.VP_Approver__r.Name)
        };
        
        diseaseStateList = new List<gFRS_CAF_Disease_State__c>();
        double Requested_Donation_Amount = 0.0;
        double Approved_Amount = 0.0;
        double Payment_Amount = 0.0;
        for(gFRS_CAF_Disease_State__c ds : fundingReq.gFRS_CAF_Disease_State__r){
            diseaseStateList.add(ds);
            
            if(ds.Requested_Donation_Amount__c!= null){
                Requested_Donation_Amount = Requested_Donation_Amount + ds.Requested_Donation_Amount__c;
            }
            
            if(ds.Approved__c!= null){
                Approved_Amount = Approved_Amount + ds.Approved__c;
            }
            
            if(ds.Payment_Amount__c!= null){
                Payment_Amount = Payment_Amount + ds.Payment_Amount__c;
            }
           
        }
        gFRS_CAF_Disease_State__c sumDS = new gFRS_CAF_Disease_State__c(Disease_Fund_Name__c = 'Total ', Requested_Donation_Amount__c = Requested_Donation_Amount, Approved__c = Approved_Amount, Payment_Amount__c = Payment_Amount);
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