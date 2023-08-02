@isTest
// Developer Name    : Jatin Setia
// Document Name     : LUC-CMGT-FAX-41 Acknowledgement Letter.doc
private class SCM_MD_AcknowledgementLetter_Luc_Test {
    static testMethod void myUnitTest() {
       //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_AcknowledgementLetter_Lucentis mergeDoc = new SCM_MD_AcknowledgementLetter_Lucentis(caseId, argLookupID); 
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }             
}