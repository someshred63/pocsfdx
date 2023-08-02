public class SCM_MD_GESApprovalLetter_RAXOLLUC extends SCM_MD_Standard {

    public SCM_MD_GESApprovalLetter_RAXOLLUC (String caseID, String argLookupId) {
        super(caseID, argLookupId);
    }
      
    public override void createMergeFields() {
        super.createMergeFields();
        //upper infus inj
        
        this.mergeFields.add(new SCM_MF_Upper_Infus_Inj(selectedCase.Product_gne__c));
        //lower infus inj
        this.mergeFields.add(new SCM_MF_Lower_Infus_Inj(selectedCase.Product_gne__c));
        //6. GATCF_Phone                       
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));       

      
        //7. GATCF_Fax               
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));     
    }
}