@isTest
private class SCM_MD_GATCF_AppSpa_PulNutRapRaXol_Test {
    static testMethod void myUnitTest() {
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        SCM_MD_GATCF_AppSpa_PulNutRapRaXol mergeDoc = new SCM_MD_GATCF_AppSpa_PulNutRapRaXol(caseId, argLookupID);
        mergeDoc.createMergeFields();
        String test = mergeDoc.getXMLString();
        System.debug(test);        
    }
}