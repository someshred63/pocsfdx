@isTest
private class SCM_MD_GATCFApprovalPat_Luc_Test {

    static testMethod void myUnitTest() {
       //local variables
        String caseId;
        String argLookupId = '';
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        
        SCM_MD_GATCFApprovalPat_Luc mergeDoc = 
            new SCM_MD_GATCFApprovalPat_Luc(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }
}