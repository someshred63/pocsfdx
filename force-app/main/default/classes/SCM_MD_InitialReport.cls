public class SCM_MD_InitialReport extends SCM_MergeDocument {
public SCM_MD_InitialReport(String caseId, String argLookupId) {
		super(caseId, argLookupId);
	}
	
	public override void createMergeFields() {
		 
		//Physcian First and last name	
		this.mergeRecipientInfo.add(new SCM_MF_AA_PhyscianFirstLastName(selectedcase));
	//Physcian First and last name	
		this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
   		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
		
	}
	
	
}