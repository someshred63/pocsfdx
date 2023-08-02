public class SCM_MD_YearlyBI_FaxCover extends SCM_MergeDocument{

    public SCM_MD_YearlyBI_FaxCover (String caseID, String argLookupId) {
        super(caseID, argLookupId);
    }
       
    public override void createMergeFields() {
        //1. Case Number (CaseID)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 

        //-------------------------------------------------------------------------------------------
        //6. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
       
   		//-------------------------------------------------------------------------------------------
        //3. CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        
        //-------------------------------------------------------------------------------------------    
        //4. CR Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));    
        
        //-------------------------------------------------------------------------------------------         
        //5. CR URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
    	
    	//6.  Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
         
        //-------------------------------------------------------------------------------------------
        //7. Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    	
      	//-------------------------------------------------------------------------------------------
        //8 Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
    	//Get Case.RecordType
        if(selectedCase.RecordType.Name != null)
        {
            if(selectedCase.RecordType.Name 
            == 'C&R - Continuous Care Case' || selectedCase.RecordType.Name == 'C&R - Standard Case')
            {   // key'From'
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        		// Ext
        		this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));    
            }
            if(selectedCase.RecordType.Name == 'GATCF - Standard Case')
            {  // key'From'
               this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
               // Ext
               this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));	
            }
        } 
    	 //11. Current Date
        this.mergeRecipientInfo.add( new SCM_MF_CurrentDate());
    	  // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        // ConfidNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        SCM_MergeField accsUpper = new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c);
        accsUpper.fieldValue = accsUpper.fieldValue.toUpperCase();
        accsUpper.key = 'accessSolutionsUpper';
        this.mergeRecipientInfo.add(accsUpper);
        this.mergeImages.add(new SCM_MI_logo(selectedCase));
        
    }
}