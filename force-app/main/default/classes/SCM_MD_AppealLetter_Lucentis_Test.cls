@isTest
// Added By: Deepak Yadav
// Modified by Sridhar

    

private class SCM_MD_AppealLetter_Lucentis_Test {

    static testMethod void SCM_MD_AppealLetter_Lucentis_Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        argLookupID = '';       
        SCM_MD_AppealLetter_Lucentis mergeDoc = new SCM_MD_AppealLetter_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
          
    }
}