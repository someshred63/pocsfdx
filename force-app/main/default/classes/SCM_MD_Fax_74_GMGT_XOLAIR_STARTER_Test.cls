@isTest
private class SCM_MD_Fax_74_GMGT_XOLAIR_STARTER_Test {

    static testMethod void myUnitTest() {
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        SCM_MD_Fax_74_GMGT_XOLAIR_STARTER mergeDoc = new SCM_MD_Fax_74_GMGT_XOLAIR_STARTER(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
        System.debug(test);        
    }
}