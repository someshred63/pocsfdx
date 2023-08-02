// Test Class for  PUL-CMGT-FAX-53_GATCF_Rx_Prefill


@isTest
private class SCM_MD_CMGT_FAX53_GATCF_Rx_Pre_Test {

    static testMethod void myUnitTest() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
        SCM_MD_CMGT_FAX53_GATCF_Rx_Prefill mergeDoc = new SCM_MD_CMGT_FAX53_GATCF_Rx_Prefill(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}