@isTest
private class SCM_MD_SMN_RXRenewLet_NuRAXo_Test {

    static testMethod void myUnitTest() {
       String caseId = '';
        String argLookupId = '';
        
        Case TestCase = SCM_CreateTestData.CreateCase();
        caseId = TestCase.Id;
        
        SCM_MD_SMN_RXRenewLet_NuRAXo mergeDoc = 
            new SCM_MD_SMN_RXRenewLet_NuRAXo(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }
}