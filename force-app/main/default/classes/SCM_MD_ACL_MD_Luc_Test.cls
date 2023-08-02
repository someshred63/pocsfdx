// Added By: Reji Joseph
// Doc Name: System Document
// PRODUCT GROUP: OPTHALMOLOGY
// LUC-CMGT-FAX-59a Appeal Cover Letter MD

@isTest
private class SCM_MD_ACL_MD_Luc_Test {
    public static testMethod void Test_SCM_MD_ACL_MD_Luc() {
        //local variables
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        String caseId = TestCase.Id;
        String argLookupId = '';
        
        SCM_MD_ACL_MD_Luc mergeDoc = new SCM_MD_ACL_MD_Luc(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
                System.debug(test);
    }
}