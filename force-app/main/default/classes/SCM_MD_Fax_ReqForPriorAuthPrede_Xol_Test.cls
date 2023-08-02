// Added By: Deepti
// Test class SCM_MD_Fax_ReqForPriorAuthPredet_Xol
@isTest
private class SCM_MD_Fax_ReqForPriorAuthPrede_Xol_Test {

    static testMethod void myUnitTest() {
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        SCM_MD_Fax_ReqForPriorAuthPredet_Xol mergeDoc = new SCM_MD_Fax_ReqForPriorAuthPredet_Xol(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
        System.debug(test);        
    }
}