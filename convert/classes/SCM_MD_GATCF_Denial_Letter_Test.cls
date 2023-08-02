//Created by : Prabha
//Created on : 16th Jan 2009
@isTest
private class SCM_MD_GATCF_Denial_Letter_Test {

    static testMethod void myUnitTest() {
       //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id; 
        String argLookupId = '';
        
        SCM_MD_GATCF_Denial_Letter mergeDoc = 
            new SCM_MD_GATCF_Denial_Letter(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }
}