/********************************************************************/
    // Developer Name    : Deepti
    // Document Name     : All ONCOLOGY - CMGT-FAX-44 PAN SPANISH
    // Type              : System Document
    // Word Template     : CMGTFAX44PanSpanish.doc
    // Label in SF       : Pan Spanish Form
    
/********************************************************************/
public class SCM_MD_PanSpanishForm_AvaHerRitTar extends SCM_MergeDocument{
    
     public SCM_MD_PanSpanishForm_AvaHerRitTar(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
    public override void createMergeFields() {
    	//Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient Id(Patient Id)             
		this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //Phone(CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));

        //Fax(CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    
    	//URL(CR_URL)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    }
}