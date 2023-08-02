@isTest
private class SCM_MD_FAX_DenialOfCoverage_XOL_Test {

    static testMethod void myUnitTest() {
        String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gjmDIAQ';
        //caseId = '500S0000000g0iF';
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Raptiva');
        caseId = documentCase.Id;
        argLookupID = '';       
        SCM_MD_FAX_DenialOfCoverage_XOL mergeDoc = new SCM_MD_FAX_DenialOfCoverage_XOL(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
    }
}