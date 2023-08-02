//Added: Paras Sharma
//Document: CMGT-FAX-04 GATCF Tab - GATCF Referral for Injection Training.doc
//Test class for Nutropin/Raptiva
@isTest
private class SCM_MD_Fax_GATCFRefForInjTra_RapNut_Test {

    static testMethod void Fax_GATCFRefForInjTra_RapNut_Test() {

		//local variables
		Case documentCase = SCM_CreateTestData.CreateCase();
		String caseId = documentCase.Id;
		String argLookupId = '';

		SCM_MD_Fax_GATCFRefForInjTra_RapNut mergeDoc =
		     new SCM_MD_Fax_GATCFRefForInjTra_RapNut(caseId, argLookupId);
		SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
		String test = mergeDoc.getXMLString();
	}
}