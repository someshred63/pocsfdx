@isTest
// Developer Name    : Jatin Setia
// Document Name     : RA-CMGT-FAX-17 REQUEST FOR PRIOR AUTHORIZATION - PREDETERMINATION.doc

private class SCM_MD_Fax_ReqForPriorAuthPret_RiRA_Test {

    static testMethod void testReqForPriorAuthPret_RiRA() {
        //local variables

        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_Fax_ReqForPriorAuthPret_RiRA mergeDoc =
             new SCM_MD_Fax_ReqForPriorAuthPret_RiRA(caseId, argLookupId);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        //String test = mergeDoc.getXMLString();
        System.assertEquals(fields[13].getFieldValue(), '');
    }
}