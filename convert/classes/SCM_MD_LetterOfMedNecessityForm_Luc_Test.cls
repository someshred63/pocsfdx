//Added: Paras Sharma
//Document: LUC-CMGT-FAX-47_Letter_of_Medical_Necessity_Form.doc
//Test Class for Lucentis
@isTest
private class SCM_MD_LetterOfMedNecessityForm_Luc_Test {

    public static testMethod void LetterOfMedNecessityForm_Luc_Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;

        argLookupID = '';       
        SCM_MD_LetterOfMedNecessityForm_Luc mergeDoc = new SCM_MD_LetterOfMedNecessityForm_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        mergeDoc.getLatestValues();
    }
}