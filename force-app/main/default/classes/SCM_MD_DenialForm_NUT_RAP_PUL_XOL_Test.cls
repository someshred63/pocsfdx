@isTest
private class SCM_MD_DenialForm_NUT_RAP_PUL_XOL_Test {

    static testMethod void myUnitTest() 
    {
        String caseId;
        String argLookupId = '';
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        
        SCM_MD_DenialForm_NUT_RAP_PUL_XOL mergeDoc = 
            new SCM_MD_DenialForm_NUT_RAP_PUL_XOL(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
    
    
}