/**
 Test Class for SCM_MD_Fax50_ClosureLetterPat_XOL.cls..
 created by Vishwanath
  */
  
  
@isTest
private class SCM_MD_Fax50_ClosureLetterPat_XOL_Test 
 {

    static testMethod void SCM_MD_Fax50_ClosureLetterPat_XOL_Test()
     {
        //local variables
        String caseId ;
        String argLookupId ;
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
       	SCM_MD_Fax50_ClosureLetterPat_XOL mergeDoc = new SCM_MD_Fax50_ClosureLetterPat_XOL(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
                     
     }
}