@isTest
private class SCM_MD_SMNFormFinalAnalysis_PUL_Test {

    static testMethod void myUnitTest() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
       	SCM_MD_SMNFormFinalAnalysis_PUL mergeDoc = new SCM_MD_SMNFormFinalAnalysis_PUL(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}