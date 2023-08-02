@isTest
private class SCM_MD_Fax_CoverageEstablished_Test {

    static testMethod void myUnitTest() {
       //local variables
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';  
        
        SCM_MD_Fax_CoverageEstablished mergeDoc = 
            new SCM_MD_Fax_CoverageEstablished(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }
}