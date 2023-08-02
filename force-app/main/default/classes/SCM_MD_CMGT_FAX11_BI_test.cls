@isTest
private class SCM_MD_CMGT_FAX11_BI_test {
    public static testMethod void test() {
        //local variables
        //String caseId = '500S0000000gmAcIAI';
        //caseId = '500S0000000gnRoIAI';
        String caseId;  // case no : 0010017318
       Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_CMGT_FAX11_BenefitsInvestigation mergeDoc = new SCM_MD_CMGT_FAX11_BenefitsInvestigation(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    } 
}