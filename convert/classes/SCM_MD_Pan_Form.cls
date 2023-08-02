/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : PUL-CMGT-FAX-45 PAN.doc
    // PRODUCT GROUP     : Pulmonary / Pulmozyme
    // Type              : System Document
    // Word Template     : PAN Form Pulmozyme.doc
    // Label in SF       : 
/********************************************************************/
 
public class SCM_MD_Pan_Form extends SCM_MergeDocument{

    protected String patientIdLocal;
    protected String cseId;
    protected String physId;
     
    public SCM_MD_Pan_Form(String caseId, String argLookupId)
    {
        super(caseId,argLookupId);   
    }
    
    public override void createMergeFields()
    {   
        //-------------------------------------------------------------------------------------------
        // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // Patient ID (key Patient ID)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		//-------------------------------------------------------------------------------------------    	
        // CR Phone (key CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
      
       	//CR_PhoneShort
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));  
              
        // CR Fax (key CR_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR URL (key CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    	//-------------------------------------------------------------------------------------------
    }
}