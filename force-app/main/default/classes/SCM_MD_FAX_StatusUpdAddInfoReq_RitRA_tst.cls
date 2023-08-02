@isTest
private class SCM_MD_FAX_StatusUpdAddInfoReq_RitRA_tst {
    public static testMethod void Test() {
     
        String caseId;  // case no : 0010017318
       Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_FAX_StatusUpdAddInfoReq_RitRA mergeDoc = new SCM_MD_FAX_StatusUpdAddInfoReq_RitRA(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    } 
}