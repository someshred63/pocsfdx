/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : LUC-CMGT-FAX-45 – PAN Form.doc
    // Type				 : System Document
    
/********************************************************************/

public class SCM_MD_PanForm_Lucentis extends SCM_MergeDocument
{
	public SCM_MD_PanForm_Lucentis(String caseID,String argLookupID) 
	{
        super(caseID, argLookupID);          
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