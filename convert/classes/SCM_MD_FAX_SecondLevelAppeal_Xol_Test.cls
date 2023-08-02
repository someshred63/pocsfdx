// Added By: Paras
@isTest
private class SCM_MD_FAX_SecondLevelAppeal_Xol_Test {

    static testMethod void SecondLevelAppealTest() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';      

        SCM_MD_FAX_SecondLevelAppeal_Xol mergeDoc =
             new SCM_MD_FAX_SecondLevelAppeal_Xol(caseId, argLookupId);            

        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        System.debug(test);
    }
}