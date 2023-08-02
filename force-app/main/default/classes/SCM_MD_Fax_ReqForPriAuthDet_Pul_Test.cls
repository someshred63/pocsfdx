//Added: Rajesh Sinha
//Document: PUL-CMGT-FAX-17 REQUEST FOR PRIOR AUTHORIZATION - PREDETERMINATION.doc  
//Test class for Pulmonary / Pulmozyme
@isTest
private class SCM_MD_Fax_ReqForPriAuthDet_Pul_Test {

    static testMethod void ReqForPriAuthDet_Pul_Test() {
        // TO DO: implement unit test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
               
        SCM_MD_Fax_ReqForPriAuthDet_Pul mergeDoc = 
            new SCM_MD_Fax_ReqForPriAuthDet_Pul(caseId, argLookupID);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        String test = mergeDoc.getXMLString();
                       
    }
}