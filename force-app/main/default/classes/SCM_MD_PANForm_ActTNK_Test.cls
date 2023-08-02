//Created by :Deepti(Deepak)
//Test Class for SCM_MD_PANForm_ActTNK
@isTest
private class SCM_MD_PANForm_ActTNK_Test {

    static testMethod void PANFormTest() {
        //local variables

        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';

        SCM_MD_PANForm_ActTNK mergeDoc =
			new SCM_MD_PANForm_ActTNK(caseId, argLookupId);
		SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
		String test = mergeDoc.getXMLString();
    }
}