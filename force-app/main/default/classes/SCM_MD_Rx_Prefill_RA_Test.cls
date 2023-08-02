@isTest
private class SCM_MD_Rx_Prefill_RA_Test {

    static testMethod void myUnitTest() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
        SCM_MD_Rx_Prefill_RA mergeDoc = new SCM_MD_Rx_Prefill_RA(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}