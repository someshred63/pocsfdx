// Added By: Deepak
@isTest
private class SCM_MD_Fax_DenialOfCoverage_Pul_Test {
     static testMethod void DenialOfCoverageTest() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';      

        SCM_MD_Fax_DenialOfCoverage_Pul mergeDoc =
             new SCM_MD_Fax_DenialOfCoverage_Pul(caseId, argLookupId);            

        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        System.debug(test);

    }

}