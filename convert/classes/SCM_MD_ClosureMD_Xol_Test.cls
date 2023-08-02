@isTest
private class SCM_MD_ClosureMD_Xol_Test {

    static testMethod void myUnitTest() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
       	SCM_MD_ClosureLetForMD_Xol mergeDoc = new SCM_MD_ClosureLetForMD_Xol(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);

    } 
}