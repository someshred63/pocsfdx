/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : CMGT-FAX-06 Message from Access Solutions.doc
    // PRODUCT GROUP     : All products
    // Type              : Fax Coversheet
    // Word Template     : Message Access Solution.doc
    // Label in SF       : 
/********************************************************************/
public class SCM_MD_FAX_MessageAccessSolution extends SCM_MergeDocument implements IStandardComboBox{
    public SCM_MD_FAX_MessageAccessSolution(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
    	//1. Case Number (CaseID)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 

        //-------------------------------------------------------------------------------------------
        //2. Patient ID
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
       
   		//-------------------------------------------------------------------------------------------
        //3. CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
         //CR_Phone_short
         this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
      
        //-------------------------------------------------------------------------------------------    
        //4. CR Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));    
        
        //-------------------------------------------------------------------------------------------         
        //5. CR URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //-------------------------------------------------------------------------------------------
        //6. CR Logo
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
        
        //-------------------------------------------------------------------------------------------
        // Access Solution
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
       
        //-------------------------------------------------------------------------------------------
        //6.  Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
         
        //-------------------------------------------------------------------------------------------
        //7. Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    	
      	//-------------------------------------------------------------------------------------------
        //8 Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        //-------------------------------------------------------------------------------------------
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
		//-------------------------------------------------------------------------------------------
        //11. Current Date
        this.mergeRecipientInfo.add( new SCM_MF_CurrentDate());
        
        //-------------------------------------------------------------------------------------------
         // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
         
        //-------------------------------------------------------------------------------------------
        // DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        
        //-------------------------------------------------------------------------------------------
        //14. Product Name
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));	
    	//this.mergeRecipientInfo.add(new SCM_MF_DRUG(selectedCase));
  

        //-------------------------------------------------------------------------------------------
        // 15. Privacy Notice
      	this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
      	
        //-------------------------------------------------------------------------------------------
        //16. Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //-------------------------------------------------------------------------------------------
        //second page
        //-------------------------------------------------------------------------------------------
        //  Comments
        this.mergeFields.add(new SCM_MF_Comments());  
    }
}