public class SCM_MD_InitialReport_RA extends SCM_MergeDocument implements IStandardComboBox {
    
    protected String caseId;
    
    
    public SCM_MD_InitialReport_RA(String caseId, String argLookupId) {
        
        super(caseId, argLookupId);
        
        caseId = caseId; 
    }

    public override void createMergeFields() {
        // CR_Phone
        mergefields.add( new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax
        mergefields.add( new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR_URL
        mergefields.add( new SCM_MF_Product_URL_CR(selectedCase));   

        // Attn:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // To RECNAME_To:
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id) );
        this.mergeRecipientInfo.add(new SCM_MF_AA_PhyscianFirstLastName(selectedCase));
        
        // Fax RECFAX_Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // From    
        this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__c));
        
        // Ext #
        this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__c) );
        
        // CurrentDate
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());

        // Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
 		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
   		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
		this.mergeImages.add(new SCM_MI_Logo(SelectedCase));
        // AntAccs_PanExpDate
        this.mergeRecipientInfo.add(new SCM_MF_AA_PanExpiration(selectedCase));

        // AntAccs_PatientFullName
        this.mergeRecipientInfo.add(new SCM_MF_AA_PatientFullName(selectedCase));

        // AntAccs_DOB
        this.mergeRecipientInfo.add(new SCM_MF_AA_DOB(selectedCase));

        // AntAccs_DOB
        this.mergeRecipientInfo.add(new SCM_MF_AA_ReferralDate(selectedCase));
    }
}