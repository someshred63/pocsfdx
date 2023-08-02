@isTest
private class SCM_MD_FamilyIntroLetterFinal_Rap_Test {
	static testMethod void testFamilyIntroLetterFinal_Rap() {
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
        SCM_MD_FamilyIntroLetterFinal_Rap mergeDoc = new SCM_MD_FamilyIntroLetterFinal_Rap(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);         
   }
}