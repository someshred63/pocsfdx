public without sharing class gFRS_Ltng_CompilanceController {
    
    public gFRS_Ltng_Application__c fundReq { get; set; }
    public gFRS_Ltng_Compliance_Flag__c compReq { get; set; }
    public List<FieldUtil> ComplianceFlags { get; set; }
    public Map<String, Object> AcknowledgeCurrentRevenueFlags {get;set;}
    public List<String> ApprovalsOrder {get; set;}
    public gFRS_Ltng_Application__c fundReqRec { get; set; }
    
    public gFRS_Ltng_CompilanceController(ApexPages.StandardController std) {
        fundReq = (gFRS_Ltng_Application__c) std.getRecord();
        //fundReq = [SELECT Id FROM gFRS_Ltng_Application__c WHERE Id= 'aKP3C0000004GthWAE' LIMIT 1];
        system.debug('fundReq.Id'+fundReq.Id);
        system.debug('fundReq'+fundReq);
        //this.compReq = (gFRS_Ltng_Compliance_Flag__c) std.getRecord();
        //GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        try {
                /*DescribeSObjectResult describeResult = compReq.Id.getSObjectType().getDescribe();      
                List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );	
                String query =	  ' SELECT ' +	      String.join( fieldNames, ',' ) +	  ' FROM ' +	      describeResult.getName() +	  ' WHERE ' +  'gFRS_Application__c = :fundReq.Id' +	  ' LIMIT 1 '	;	
                compReq = Database.query( query );*/
            	compReq = [Select Id,Manual_Resolution__c,No_Undue_Influence_Clinical_Practices__c,gFRS_No_Undue_Influ_Clinical_Pract_Notes__c,
                          			 gFRS_Organization_Reputation_Blacklist__c,gFRS_Org_Reputation_Blacklist_Notes__c,
                          			OrgType_Charitable_Foundation_of_a_Group__c,gFRS_Org_Type_Individual_or_Group_Notes__c,
                          			Organization_Type_Poltical_Sec__c,gFRRS_Org_Type_Political_Sectarian_Notes__c,
                          			Organization_Ownership_Individual_OR_Gr__c,Organization_Ownership_Ind_OR_Grp_Notes__c,
                          			No_Undue_Influence_General_Org_Support__c,No_Undue_Influence_General_Org_Support_N__c,
                          			Broad_Audience_Not_Open_To_Public__c,Broad_Audience_Not_Open_To_Public_Notes__c,
                          			OrgType_Other__c,OrgType_Other_Notes__c,
                          			Promotional_Material_Separated_from_CME__c,Promo_Material_Separated_from_CME_Notes__c,
                          			Reach_of_the_Event_Program__c,Reach_of_the_Event_Program_Notes__c,
                           			Organization_Type_Memberships__c,Organization_Type_Memberships_Notes__c,
                           			Organization_Type_Field_Exhibits__c,Organization_Type_Field_Exhibits_Notes__c,
                           			Funding_Purpose_Target_audience_not_HCPs__c,gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c,
                           			HCP_Audience_Mix_Learners_not_US_based__c,gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c
                           			 from gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =:fundReq.Id LIMIT 1];
            	system.debug('compReq'+compReq);
            	fundReqRec = [Select Id,Name,RecordType.Name,Organization__r.Name,Organization__r.Organization_Name__c,Event_Program_Type__c,Event_Program_Title__c,FPO_Reviewer_Decision_Date__c,Business_Approver_Decision_Date__c,Final_Approver_Decision_Date__c FROM gFRS_Ltng_Application__c WHERE Id =:fundReq.Id];
            	system.debug('fundReqRec'+fundReqRec);
            //this.fundReq = [ SELECT Id,RecordType.Name]
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType gfrsSchema = schemaMap.get('gFRS_Ltng_Compliance_Flag__c');
            Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();
            system.debug('fundReqRec.RecordType.Name'+fundReqRec.RecordType.Name);
            if (fundReqRec.RecordType.Name == 'Community Giving' || fundReqRec.RecordType.Name == 'Education Focused Giving K-12' ||
                fundReqRec.RecordType.Name == 'Foundation Safety Net Support' || fundReqRec.RecordType.Name == 'Foundation Undergraduate' ) {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.compReq.gFRS_Organization_Reputation_Blacklist__c, fieldMap.get('gFRS_Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Reputation_Blacklist_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.compReq.OrgType_Charitable_Foundation_of_a_Group__c, fieldMap.get('gFRS_Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Type_Individual_or_Group_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.compReq.Organization_Type_Poltical_Sec__c, fieldMap.get('gFRRS_Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Individual_OR_Gr__c, fieldMap.get('Organization_Ownership_Ind_OR_Grp_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Ind_OR_Grp_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Other__c').getDescribe().getLabel(), this.compReq.OrgType_Other__c, fieldMap.get('OrgType_Other_Notes__c').getDescribe().getLabel(), this.compReq.OrgType_Other_Notes__c)
                };
            } else if (fundReqRec.RecordType.Name == 'Patient and Health Focused Giving') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.compReq.No_Undue_Influence_Clinical_Practices__c, fieldMap.get('gFRS_No_Undue_Influ_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c),
                    	new FieldUtil(fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.compReq.gFRS_Organization_Reputation_Blacklist__c, fieldMap.get('gFRS_Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Reputation_Blacklist_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.compReq.OrgType_Charitable_Foundation_of_a_Group__c, fieldMap.get('gFRS_Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Type_Individual_or_Group_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.compReq.Organization_Type_Poltical_Sec__c, fieldMap.get('gFRRS_Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Individual_OR_Gr__c, fieldMap.get('Organization_Ownership_Ind_OR_Grp_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Ind_OR_Grp_Notes__c),
                        new FieldUtil(fieldMap.get('No_Undue_Influence_General_Org_Support__c').getDescribe().getLabel(), this.compReq.No_Undue_Influence_General_Org_Support__c, fieldMap.get('No_Undue_Influence_General_Org_Support_N__c').getDescribe().getLabel(), this.compReq.No_Undue_Influence_General_Org_Support_N__c),
                        new FieldUtil(fieldMap.get('Broad_Audience_Not_Open_To_Public__c').getDescribe().getLabel(), this.compReq.Broad_Audience_Not_Open_To_Public__c, fieldMap.get('Broad_Audience_Not_Open_To_Public_Notes__c').getDescribe().getLabel(), this.compReq.Broad_Audience_Not_Open_To_Public_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Other__c').getDescribe().getLabel(), this.compReq.OrgType_Other__c, fieldMap.get('OrgType_Other_Notes__c').getDescribe().getLabel(), this.compReq.OrgType_Other_Notes__c)
                };
            } else if (fundReqRec.RecordType.Name == 'Scientific and Research Focused Giving' || fundReqRec.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.compReq.No_Undue_Influence_Clinical_Practices__c, fieldMap.get('gFRS_No_Undue_Influ_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c),
                    	new FieldUtil(fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.compReq.gFRS_Organization_Reputation_Blacklist__c, fieldMap.get('gFRS_Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Reputation_Blacklist_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.compReq.OrgType_Charitable_Foundation_of_a_Group__c, fieldMap.get('gFRS_Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Type_Individual_or_Group_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.compReq.Organization_Type_Poltical_Sec__c, fieldMap.get('gFRRS_Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Individual_OR_Gr__c, fieldMap.get('Organization_Ownership_Ind_OR_Grp_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Ind_OR_Grp_Notes__c),
                        new FieldUtil(fieldMap.get('Broad_Audience_Not_Open_To_Public__c').getDescribe().getLabel(), this.compReq.Broad_Audience_Not_Open_To_Public__c, fieldMap.get('Broad_Audience_Not_Open_To_Public_Notes__c').getDescribe().getLabel(), this.compReq.Broad_Audience_Not_Open_To_Public_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Other__c').getDescribe().getLabel(), this.compReq.OrgType_Other__c, fieldMap.get('OrgType_Other_Notes__c').getDescribe().getLabel(), this.compReq.OrgType_Other_Notes__c)
                };
            } else if (fundReqRec.RecordType.Name == 'Independent Medical Education (CME)') {
                ComplianceFlags = new List<FieldUtil>{
                        new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.compReq.No_Undue_Influence_Clinical_Practices__c, fieldMap.get('gFRS_No_Undue_Influ_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c),
                    	new FieldUtil(fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.compReq.gFRS_Organization_Reputation_Blacklist__c, fieldMap.get('gFRS_Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Reputation_Blacklist_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.compReq.OrgType_Charitable_Foundation_of_a_Group__c, fieldMap.get('gFRS_Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Type_Individual_or_Group_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.compReq.Organization_Type_Poltical_Sec__c, fieldMap.get('gFRRS_Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Individual_OR_Gr__c, fieldMap.get('Organization_Ownership_Ind_OR_Grp_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Ind_OR_Grp_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Other__c').getDescribe().getLabel(), this.compReq.OrgType_Other__c, fieldMap.get('OrgType_Other_Notes__c').getDescribe().getLabel(), this.compReq.OrgType_Other_Notes__c),
                        new FieldUtil(fieldMap.get('Funding_Purpose_Target_audience_not_HCPs__c').getDescribe().getLabel(), this.compReq.Funding_Purpose_Target_audience_not_HCPs__c, fieldMap.get('gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c').getDescribe().getLabel(), this.compReq.gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c),
                        new FieldUtil(fieldMap.get('HCP_Audience_Mix_Learners_not_US_based__c').getDescribe().getLabel(), this.compReq.HCP_Audience_Mix_Learners_not_US_based__c, fieldMap.get('gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c)
                };
            } else if (fundReqRec.RecordType.Name == 'Field Exhibits') {
                ComplianceFlags = new List<FieldUtil>{
                    	new FieldUtil(fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.compReq.gFRS_Organization_Reputation_Blacklist__c, fieldMap.get('gFRS_Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Reputation_Blacklist_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.compReq.OrgType_Charitable_Foundation_of_a_Group__c, fieldMap.get('gFRS_Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Type_Individual_or_Group_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.compReq.Organization_Type_Poltical_Sec__c, fieldMap.get('gFRRS_Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Individual_OR_Gr__c, fieldMap.get('Organization_Ownership_Ind_OR_Grp_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Ind_OR_Grp_Notes__c),
                        new FieldUtil(fieldMap.get('Reach_of_the_Event_Program__c').getDescribe().getLabel(), this.compReq.Reach_of_the_Event_Program__c, fieldMap.get('Reach_of_the_Event_Program_Notes__c').getDescribe().getLabel(), this.compReq.Reach_of_the_Event_Program_Notes__c),
                        new FieldUtil(fieldMap.get('Promotional_Material_Separated_from_CME__c').getDescribe().getLabel(), this.compReq.Promotional_Material_Separated_from_CME__c, fieldMap.get('Promo_Material_Separated_from_CME_Notes__c').getDescribe().getLabel(), this.compReq.Promo_Material_Separated_from_CME_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Field_Exhibits__c').getDescribe().getLabel(), this.compReq.Organization_Type_Field_Exhibits__c, fieldMap.get('Organization_Type_Field_Exhibits_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Type_Field_Exhibits_Notes__c)
                };
            } else if (fundReqRec.RecordType.Name == 'Commercial Sponsorship' || fundReqRec.RecordType.Name == 'Non-Commercial Sponsorship') {
                ComplianceFlags = new List<FieldUtil>{
                    	new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.compReq.No_Undue_Influence_Clinical_Practices__c, fieldMap.get('gFRS_No_Undue_Influ_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c),
                    	new FieldUtil(fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.compReq.gFRS_Organization_Reputation_Blacklist__c, fieldMap.get('gFRS_Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Reputation_Blacklist_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.compReq.OrgType_Charitable_Foundation_of_a_Group__c, fieldMap.get('gFRS_Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Type_Individual_or_Group_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.compReq.Organization_Type_Poltical_Sec__c, fieldMap.get('gFRRS_Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Individual_OR_Gr__c, fieldMap.get('Organization_Ownership_Ind_OR_Grp_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Ind_OR_Grp_Notes__c),
                        new FieldUtil(fieldMap.get('Promotional_Material_Separated_from_CME__c').getDescribe().getLabel(), this.compReq.Promotional_Material_Separated_from_CME__c, fieldMap.get('Promo_Material_Separated_from_CME_Notes__c').getDescribe().getLabel(), this.compReq.Promo_Material_Separated_from_CME_Notes__c)
                };
            } else if (fundReqRec.RecordType.Name == 'Corporate Memberships') {
                ComplianceFlags = new List<FieldUtil>{
                    	new FieldUtil(fieldMap.get('No_Undue_Influence_Clinical_Practices__c').getDescribe().getLabel(), this.compReq.No_Undue_Influence_Clinical_Practices__c, fieldMap.get('gFRS_No_Undue_Influ_Clinical_Pract_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c),
                    	new FieldUtil(fieldMap.get('gFRS_Organization_Reputation_Blacklist__c').getDescribe().getLabel(), this.compReq.gFRS_Organization_Reputation_Blacklist__c, fieldMap.get('gFRS_Org_Reputation_Blacklist_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Reputation_Blacklist_Notes__c),
                        new FieldUtil(fieldMap.get('OrgType_Charitable_Foundation_of_a_Group__c').getDescribe().getLabel(), this.compReq.OrgType_Charitable_Foundation_of_a_Group__c, fieldMap.get('gFRS_Org_Type_Individual_or_Group_Notes__c').getDescribe().getLabel(), this.compReq.gFRS_Org_Type_Individual_or_Group_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Poltical_Sec__c').getDescribe().getLabel(), this.compReq.Organization_Type_Poltical_Sec__c, fieldMap.get('gFRRS_Org_Type_Political_Sectarian_Notes__c').getDescribe().getLabel(), this.compReq.gFRRS_Org_Type_Political_Sectarian_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Ownership_Individual_OR_Gr__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Individual_OR_Gr__c, fieldMap.get('Organization_Ownership_Ind_OR_Grp_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Ownership_Ind_OR_Grp_Notes__c),
                        new FieldUtil(fieldMap.get('Promotional_Material_Separated_from_CME__c').getDescribe().getLabel(), this.compReq.Promotional_Material_Separated_from_CME__c, fieldMap.get('Promo_Material_Separated_from_CME_Notes__c').getDescribe().getLabel(), this.compReq.Promo_Material_Separated_from_CME_Notes__c),
                        new FieldUtil(fieldMap.get('Organization_Type_Memberships__c').getDescribe().getLabel(), this.compReq.Organization_Type_Memberships__c, fieldMap.get('Organization_Type_Memberships_Notes__c').getDescribe().getLabel(), this.compReq.Organization_Type_Memberships_Notes__c)
                };
            }
            
            ComplianceFlags.addAll(
                    new FieldUtil[]{
                            new FieldUtil('', '', fieldMap.get('Manual_Resolution__c').getDescribe().getLabel(), this.compReq.Manual_Resolution__c)
                    }
            );
            
        }
        catch (Exception err) {
            System.debug('unable to load organization and funding request info:' + err.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occurred while loading the funding request'));
            return;
        }
    }
    
    public class FieldUtil {
        public String labelName { get; set; }
        public String fieldValue { get; set; }
        public String secondLabelName { get; set; }
        public String secondFieldValue { get; set; }
        
        public FieldUtil(String labName, String fielName, String secondLabel, String secondValue) {
            this.labelName = labName;
            this.fieldValue = fielName;
            this.secondLabelName = secondLabel;
            this.secondFieldValue = secondValue;
        }
    }
}