// Added By: Sridhar
// Test class for SCM_MD_AppealCoverLet_Pat_Tar
@isTest
private class SCM_MD_AppealCovLet_Pat_Tar_Test {

    static testMethod void SCM_MD_AppealCovLetTar_Test() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_AppealCoverLet_Pat_Tar mergeDoc =
             new SCM_MD_AppealCoverLet_Pat_Tar(caseId, argLookupId);
        
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        
             
    }
}