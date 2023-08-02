@isTest
private class SCM_MD_Fax_MessageFromGATCF_Test {

    static testMethod void myUnitTest() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';       
  
        SCM_MD_Fax_MessageFromGATCF mergeDoc = 
            new SCM_MD_Fax_MessageFromGATCF(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}