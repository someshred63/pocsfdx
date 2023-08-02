@isTest
private class SCM_MD_GATCF_APPROVAL_Form_Test {

    static testMethod void myUnitTest() {
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        SCM_MD_GATCF_APPROVAL_Form mergeDoc = new SCM_MD_GATCF_APPROVAL_Form(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
        System.debug(test);        
    }
}