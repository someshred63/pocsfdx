public class gFRS_CoPay_ComplianceController {
    
    public GFRS_CoPay_Funding_Request__c fundReq {get; set;}
    public List<FieldUtil> ComplianceFlags {get;set;} 
    
    public gFRS_CoPay_ComplianceController(apexPages.StandardController std){
        
        this.fundReq = (GFRS_Copay_Funding_Request__c)std.getRecord();
        try{
            this.fundReq = [ SELECT Id, Name, Funding_Type__c, Organization_Name__c, No_Undue_Influence_Clinical_Practices__c,
                            Event_Program_Type__c, Event_Program_Title__c, HC_Compliance_Decision_Date__c, Manual_Resolution__c,
                            Decision_Date__c, Organization_Reputation_Blacklist__c, Organization_Type_Owned_by_HCPs__c,No_Undue_Influence_Clinical_Pract_Notes__c,
                            Organization_Type_Political_Sectarian__c, Organization_Type_Religious__c, Estimated_Current_Revenue_Exceeded_33__c, Sub_Status__c,
                            Organization_Outdated_OIG_Opinion__c,Organization_DiseaseFundDefinition__c, Estimated_Current_Revenue_Percent__c, Organization_Type_Individual_or_Group__c,
                            Org_Reputation_Blacklist_Notes__c, Organization_Outdated_OIG_Opinion_Notes__c, Org_Disease_Fund_Definition_Notes__c, Org_Type_Individual_or_Group_Notes__c,
                            Org_Type_Political_Sectarian_Notes__c, Org_Type_Owned_by_HCPs_Notes__c, Organization_Type_Religious_Notes__c, Compliance_Checks_Messages__c
                            FROM GFRS_Copay_Funding_Request__c
                            WHERE Id = :this.fundReq.Id
                            LIMIT 1];
                            
        if(this.fundReq.Estimated_Current_Revenue_Exceeded_33__c == False && this.fundReq.Estimated_Current_Revenue_Percent__c > 33.0 && this.fundReq.Sub_Status__c == 'Approved'){
            this.fundReq.Estimated_Current_Revenue_Exceeded_33__c = True;
        }
            
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType gfrsSchema = schemaMap.get('GFRS_Copay_Funding_Request__c');
            Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
            
            
            ComplianceFlags = new List<FieldUtil> {
                new FieldUtil(fieldMap.get('Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.fundReq.Organization_Reputation_Blacklist__c, this.fundReq.Org_Reputation_Blacklist_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Type_Owned_by_HCPs__c').getDescribe().getLabel(), this.fundReq.Organization_Type_Owned_by_HCPs__c, this.fundReq.Org_Type_Owned_by_HCPs_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Type_Political_Sectarian__c').getDescribe().getLabel(), this.fundReq.Organization_Type_Political_Sectarian__c, this.fundReq.Org_Type_Political_Sectarian_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Type_Religious__c').getDescribe().getLabel(), this.fundReq.Organization_Type_Religious__c, this.fundReq.Organization_Type_Religious_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Outdated_OIG_Opinion__c').getDescribe().getLabel(), this.fundReq.Organization_Outdated_OIG_Opinion__c, this.fundReq.Organization_Outdated_OIG_Opinion_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_DiseaseFundDefinition__c').getDescribe().getLabel(), this.fundReq.Organization_DiseaseFundDefinition__c, this.fundReq.Org_Disease_Fund_Definition_Notes__c),
                    new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.fundReq.No_Undue_Influence_Clinical_Practices__c, this.fundReq.No_Undue_Influence_Clinical_Pract_Notes__c),
                    new FieldUtil(fieldMap.get('Organization_Type_Individual_or_Group__c').getDescribe().getLabel(), this.fundReq.Organization_Type_Individual_or_Group__c, this.fundReq.Org_Type_Individual_or_Group_Notes__c)
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