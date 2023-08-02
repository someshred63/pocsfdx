@isTest
private class SCM_MD_Fax_Claims_FollowUp_Test {
    public static testMethod void testClaimsFollowUp() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;

        argLookupID = '';       
        SCM_MD_Fax_ClaimsFollowUp mergeDoc = new SCM_MD_Fax_ClaimsFollowUp(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
    }
}