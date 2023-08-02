@isTest
//Added: Jatin Setia
//Document: XOL-CMGT-FAX-38_SMN_Form_FinalAnalysis

private class SCM_MD_SMNFormFinalAnalysis_Xolair_Test {
    static testMethod void testSMNFormFinalAnalysis_Xolair() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
              
        SCM_MD_SMNFormFinalAnalysis_Xolair mergeDoc = new SCM_MD_SMNFormFinalAnalysis_Xolair(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}