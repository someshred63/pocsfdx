@isTest
// Added By: Deepak Yadav
private class SCM_MD_FormRequestLetter_LucPulNut_Test {
	
	public static testMethod void testFormRequestLetter() {
	 String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        argLookupID = '';       
        SCM_MD_FormRequestLetter_LucPulNut mergeDoc = new SCM_MD_FormRequestLetter_LucPulNut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
    }
}