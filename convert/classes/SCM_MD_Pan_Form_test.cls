@isTest
private class SCM_MD_Pan_Form_test {
    public static testMethod void Test() {
     
        String caseId;  // case no : 0010017318
       Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_Pan_Form mergeDoc = new SCM_MD_Pan_Form(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    } 
}