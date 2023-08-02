@isTest
private class SCM_MD_NUT_CMGT_FAX29_NEWREFERRAL_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
               
        SCM_MD_NUT_CMGT_FAX29_NEWREFERRAL mergeDoc = 
        	new SCM_MD_NUT_CMGT_FAX29_NEWREFERRAL(caseId, argLookupID);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
    }
}