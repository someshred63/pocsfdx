//Added: Rajesh Sinha
//Document: XOL-CMGT-FAX-53_GATCF_Rx_Prefill.DOC
//Test Class for Xolair
@isTest
private class SCM_MD_GATCFRxPrefill_XOL_Test {
    static testMethod void GATCFRxPrefill_XOL_Test() {
        // TO DO: implement unit test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';     
        SCM_MD_GATCFRxPrefill_XOL mergeDoc = new SCM_MD_GATCFRxPrefill_XOL(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
   }
}