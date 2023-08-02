@isTest
private class SCM_MD_BI_form_Test {

    static testMethod void Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        argLookupID = '';       
        SCM_MD_BI_Form_Lucent mergeDoc = new SCM_MD_BI_Form_Lucent(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
    }

}