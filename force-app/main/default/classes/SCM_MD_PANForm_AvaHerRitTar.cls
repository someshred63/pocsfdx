/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : CMGT-FAX-45 All ONC PAN Form.doc   
    // PRODUCT GROUP     : Oncology / Avastin or Herceptin or Rituxan or Tarceva
    // Type              : System Document
    // Word Template     : Pan_Form.doc    
    // Label in SF       : PAN Form 
    
/********************************************************************/
public class SCM_MD_PANForm_AvaHerRitTar  extends SCM_MergeDocument {
          
    public SCM_MD_PANForm_AvaHerRitTar(String caseID, String argLookupId) {
        super(caseID, argLookupId);        
    }
    
    public override void createMergeFields() {
    	// 0 Case Number
    	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));                 
         
        // 1 Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // 2 CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // 3 CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // 4 CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
    }
}