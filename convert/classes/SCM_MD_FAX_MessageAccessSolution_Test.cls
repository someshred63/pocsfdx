/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : CMGT-FAX-06 Message from Access Solutions.doc
    // PRODUCT GROUP     : All products
    // Type              : Fax Coversheet
    // Word Template     : Message Access Solution.doc
    // Label in SF       : 
/********************************************************************/
@isTest
private class SCM_MD_FAX_MessageAccessSolution_Test {
    public static testMethod void Test_SCM_MD_FAX_MessageAccessSolution() {
        //local variables
        //String caseId = '500S0000000gmAcIAI';
        String caseId = '';  // case no : 0010017471
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        String argLookupId = '';
        
        SCM_MD_FAX_MessageAccessSolution mergeDoc = new SCM_MD_FAX_MessageAccessSolution(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    }
}