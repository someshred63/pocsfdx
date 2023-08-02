@isTest
private class SCM_MD_InitialReport_RA_Test {
    public static testMethod void test() {
        
        String caseId;  // case no : 0010017318
       Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_InitialReport_RA mergeDoc = new SCM_MD_InitialReport_RA(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    } 
}