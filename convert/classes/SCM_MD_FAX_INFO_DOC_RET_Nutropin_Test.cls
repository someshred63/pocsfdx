@isTest
    // Developer Name    : Jatin Setia
    // Document Name     : NUT_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
private class SCM_MD_FAX_INFO_DOC_RET_Nutropin_Test {

    static testMethod void testINFO_DOC_RET_Nutropin() {
    	//local variables

        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_FAX_INFO_DOC_RET_Nutropin mergeDoc =
             new SCM_MD_FAX_INFO_DOC_RET_Nutropin(caseId, argLookupId);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        String test = mergeDoc.getXMLString();

    }
}