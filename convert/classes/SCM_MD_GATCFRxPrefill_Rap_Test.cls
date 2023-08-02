// Added By: Sridhar
// Test class for SCM_MD_GATCFRxPrefill_Raptiva
@isTest
private class SCM_MD_GATCFRxPrefill_Rap_Test {

    static testMethod void myUnitTest() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_GATCFRxPrefill_Raptiva mergeDoc =
             new SCM_MD_GATCFRxPrefill_Raptiva(caseId, argLookupId);
        
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        
             
    }
}