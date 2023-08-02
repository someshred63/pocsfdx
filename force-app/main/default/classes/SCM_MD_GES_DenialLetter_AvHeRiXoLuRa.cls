public class SCM_MD_GES_DenialLetter_AvHeRiXoLuRa extends SCM_MD_Standard {

    public SCM_MD_GES_DenialLetter_AvHeRiXoLuRa (String caseID, String argLookupId) {
        super(caseID, argLookupId);
    }
       
    public override void createMergeFields() {
        super.createMergeFields();
                    
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));       
         //7. GATCF_Fax               
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));     
    }
}