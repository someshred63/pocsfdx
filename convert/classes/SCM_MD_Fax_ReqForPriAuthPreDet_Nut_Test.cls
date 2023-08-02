@isTest
private class SCM_MD_Fax_ReqForPriAuthPreDet_Nut_Test {

    static testMethod void myUnitTest() {
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        SCM_MD_Fax_ReqForPriAuthPreDet_Nut mergeDoc = new SCM_MD_Fax_ReqForPriAuthPreDet_Nut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
        System.debug(test);        
    }
}