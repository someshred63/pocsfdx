// Created by Sridhar
@isTest


private class SCM_MD_AppealCoverLetter_Luc_Test 
{
    public static testMethod void SCM_MD_AppealCoverLetter_Luc_Test()
    {
        String caseId;
        String argLookupId = '';
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        
        SCM_MD_AppealLetter_Lucentis mergeDoc = 
            new SCM_MD_AppealLetter_Lucentis(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);    
       
    }
}