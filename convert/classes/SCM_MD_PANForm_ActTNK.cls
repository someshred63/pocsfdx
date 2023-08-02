/********************************************************************/
    // Developer Name    : Deepti(Deepak)
    // Document Name     : ACT-CMGT-FAX-45 PAN   
    // PRODUCT GROUP     : Activase and TNKase
    // Type              : System Document
    // Word Template     : CMGT-FAX-45PANForm.doc 
    // Label in SF       : Pan Form
    
/********************************************************************/
public class SCM_MD_PANForm_ActTNK extends SCM_MergeDocument {
	 public SCM_MD_PANForm_ActTNK(String caseID, String argLookupId) {
        super(caseID, argLookupId);
       }
   	 public override void createMergeFields() {
    	
    	//0. Case Number(Case_Number)
     	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
     	
     	//1. Patient ID(Patient Id)
     	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
     	
     	//2. GATCF_Phone(GATCF_Phone)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
     	
     	//3. GATCF_Fax(GATCF_Fax)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
    }
}