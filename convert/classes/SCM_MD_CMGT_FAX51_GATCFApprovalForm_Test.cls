@isTest
private class SCM_MD_CMGT_FAX51_GATCFApprovalForm_Test {
    public static testMethod void myUnitTest() {
        //local variables
        String caseId;
        String argLookupId = '';
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        
        SCM_MD_CMGT_FAX51_GATCFApprovalForm mergeDoc = 
            new SCM_MD_CMGT_FAX51_GATCFApprovalForm(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);       
    }
}