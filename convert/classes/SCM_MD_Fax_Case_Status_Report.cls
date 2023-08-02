public class SCM_MD_Fax_Case_Status_Report extends SCM_MergeDocument implements IStandardComboBox {
		
public SCM_MD_Fax_Case_Status_Report(String caseID, String argLookupId)
    {
            super(caseID, argLookupId);
            caseId = caseID;  
                     
    }
       
    public override void createMergeFields()  
    {

	//-------------------------------------------------------------------------------------------
        //3. CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
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
           //aaccp
           this.mergeRecipientInfo.add( new SCM_MF_AA_CaCCP(selectedCase));
           // access solutions
           this.mergeRecipientInfo.add( new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
            // 15. Privacy Notice
      	this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
      	 // Confidentiality Notice
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        this.mergeImages.add(new SCM_mi_logo(selectedcase));
    }
}