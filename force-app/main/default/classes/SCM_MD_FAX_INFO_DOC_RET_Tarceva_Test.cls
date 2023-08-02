//created by Sridhar

@isTest
private class SCM_MD_FAX_INFO_DOC_RET_Tarceva_Test {
    public static testMethod void SCM_MD_FAX_INFO_DOC_RET_Tarceva_Test() {
        //local variables
      Case documentCase = SCM_CreateTestData.CreateCase();
      String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_FAX_INFO_DOC_RET_Tarceva mergeDoc = 
            new SCM_MD_FAX_INFO_DOC_RET_Tarceva(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);       
    }
}