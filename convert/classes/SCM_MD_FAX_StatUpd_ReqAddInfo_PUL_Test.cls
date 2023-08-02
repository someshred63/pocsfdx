@isTest
private class SCM_MD_FAX_StatUpd_ReqAddInfo_PUL_Test {

    static testMethod void myUnitTest() {
        String argLookupID;  
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        argLookupID = '';      
        SCM_MD_FAX_StatUpd_ReqAddInfo_PUL mergeDoc = new SCM_MD_FAX_StatUpd_ReqAddInfo_PUL(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}