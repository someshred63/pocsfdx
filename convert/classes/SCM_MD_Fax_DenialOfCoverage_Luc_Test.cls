@isTest
private class SCM_MD_Fax_DenialOfCoverage_Luc_Test {

    static testMethod void SCM_MD_Fax_DenialOfCoverage_Luc_Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;

        argLookupID = '';       
        SCM_MD_Fax_DenialOfCoverage_Luc mergeDoc = new SCM_MD_Fax_DenialOfCoverage_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        mergeDoc.getLatestValues();
    }
}