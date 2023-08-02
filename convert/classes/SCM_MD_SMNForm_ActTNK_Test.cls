// Added By: Deepti
// Test class SCM_MD_SMNForm_ActTNK
@isTest
private class SCM_MD_SMNForm_ActTNK_Test {
	static testMethod void SCM_MD_SMNForm_ActTNK_Test() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_SMNForm_ActTNK mergeDoc = new SCM_MD_SMNForm_ActTNK(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
		String test = mergeDoc.getXMLString();
        System.debug(test);
    }
}