@isTest
private class SCM_MD_FAX43_ReqLetfinal_test {
    public static testMethod void Test() {
     
        String caseId;  // case no : 0010017318
       Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_NUT_PULCMGT_FAX43_ReqLetfinal mergeDoc = new SCM_MD_NUT_PULCMGT_FAX43_ReqLetfinal(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    } 
}