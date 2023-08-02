@isTest
private class SCM_MD_SMNFormPediatric_Nut_Test {

    static testMethod void doUnitTest() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
       SCM_MD_SMNFormPediatric_Nut mergeDoc = new SCM_MD_SMNFormPediatric_Nut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}