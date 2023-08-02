@isTest
private class SCM_MD_AcknLetter_41_Pul_Ra_Nut_Test
 {

    static testMethod void SCM_MD_AcknLetter_41_Pul_Ra_Nut_Test()
     {
        //local variables
		Case documentCase = SCM_CreateTestData.CreateCase();
		String caseId = documentCase.Id;
		String argLookupId = '';
        
        SCM_MD_AcknLetter_41_Pul_Ra_Nut mergeDoc = 
            new SCM_MD_AcknLetter_41_Pul_Ra_Nut(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);                          
     }
}