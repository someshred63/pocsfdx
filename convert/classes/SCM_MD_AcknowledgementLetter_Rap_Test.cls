@isTest
private class SCM_MD_AcknowledgementLetter_Rap_Test {
    static testMethod void testRapAckLetter() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
     
        SCM_MD_AcknowledgementLetter_Rap mergeDoc = 
            new SCM_MD_AcknowledgementLetter_Rap(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test); 
    }
}