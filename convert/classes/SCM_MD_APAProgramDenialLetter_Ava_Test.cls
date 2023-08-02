//Added: Sridhar
//Document: CMGT-FAX-70 - APA Program Denial Letter Form Analysis v2.0 - FINAL
//Test Class for Avastin

@isTest
private class SCM_MD_APAProgramDenialLetter_Ava_Test 
{
    public static testMethod void SCM_MD_APAProgramDenialLetter_Ava_Test()
     {
       //local variables
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';  
        
        SCM_MD_APAProgramDenialLetter_Ava mergeDoc = 
            new SCM_MD_APAProgramDenialLetter_Ava(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);    
    }
}