/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : LUC-CMGT-FAX-44 PAN - Spanish Form.doc
    // Type				 : System Document
    // Word Template     : PAN_Spanish_Form.doc    
    // Label in SF       : Pan Spanish Form
    
/********************************************************************/

public class SCM_MD_PAN_SpanishForm_Lucentis extends SCM_MergeDocument {
    public SCM_MD_PAN_SpanishForm_Lucentis(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    
     public override void createMergeFields() {
     	
		//CR_Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        //Patient Id
	    this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
	
		//Case Number	
		this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
     }
}