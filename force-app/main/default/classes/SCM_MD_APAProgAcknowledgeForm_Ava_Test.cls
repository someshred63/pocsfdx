// Added By: Deepak Yadav
// Test class for SCM_MD_APAProgAcknowledgeForm_Ava
@isTest
private class SCM_MD_APAProgAcknowledgeForm_Ava_Test {

    static testMethod void APAProgAcknowledgeFormTest() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_APAProgAcknowledgeForm_Ava mergeDoc =
        	 new SCM_MD_APAProgAcknowledgeForm_Ava(caseId, argLookupId);
     	
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        
                
             
    }
}