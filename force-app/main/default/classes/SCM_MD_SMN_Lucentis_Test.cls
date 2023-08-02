// Created  By: Reji Joseph
// Document No: CMGT-FAX-38 - SMN Form Analysis with SFDC Mappings v2.0.doc

@IsTest
private class SCM_MD_SMN_Lucentis_Test {
    public static testMethod void SCM_MD_TestSMN_Lucentis()
    {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;

        argLookupID = '';       
        SCM_MD_SMN_Lucentis mergeDoc = new SCM_MD_SMN_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        mergeDoc.getLatestValues();
    }
}