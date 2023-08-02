//Added: Rajesh Sinha
//Document: NUT-CMGT-FAX-32 APPEAL REQUEST FOR ADDITIONAL DOCUMENTS.DOC
//Test Class for Nutropin
@isTest
private class SCM_MD_Fax_AppealReq_Nutropin_Test {

    static testMethod void AppealReq_Nutropin_Test() {
        // TO DO: implement unit test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
              
        SCM_MD_Fax_AppealReq_Nutropin mergeDoc = new SCM_MD_Fax_AppealReq_Nutropin(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}