// Created By: Sridhar
// Test class for SCM_MD_Fax08_Req_For_AddInfFnAna_RitRA
@isTest
private class SCM_MD_Fax_Req_For_AIFnAna_RitRA_Test {

    static testMethod void myUnitTest() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_Fax08_Req_For_AddInfFnAna_RitRA mergeDoc =
             new SCM_MD_Fax08_Req_For_AddInfFnAna_RitRA(caseId, argLookupId);
        
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        
             
    }
}