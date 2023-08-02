// Added By: Shobha Rawat
@isTest
private class SCM_MD_FamilyIntroLetDistributr_Rap_Test {

    static testMethod void SCM_MD_FamilyIntroLetDistributrTest() {
    	//local variables
        String caseId = '';
        String argLookupId = '';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        SCM_MD_FamilyIntroLetDistributor_Rap mergeDoc = 
            new SCM_MD_FamilyIntroLetDistributor_Rap(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
          
    }
}