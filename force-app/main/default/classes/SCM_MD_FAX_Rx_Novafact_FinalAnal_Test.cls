@isTest
private class SCM_MD_FAX_Rx_Novafact_FinalAnal_Test {

    static testMethod void myUnitTest() {
         String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gjmDIAQ';
        Case  documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';       
        SCM_MD_FAX_Rx_Novafact_FinalAnal mergeDoc = new SCM_MD_FAX_Rx_Novafact_FinalAnal(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
        
    }
}