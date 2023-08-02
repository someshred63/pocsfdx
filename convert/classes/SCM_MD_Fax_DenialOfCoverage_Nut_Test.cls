//created by Sridhar

@isTest
private class SCM_MD_Fax_DenialOfCoverage_Nut_Test {
    public static testMethod void myUnitTest() {
        //local variables
        //String caseId = '500S0000000glSx';
        String argLookupId = '';
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Raptiva');
        String caseId = documentCase.Id;
        SCM_MD_Fax_DenialOfCoverage_Nut mergeDoc = 
            new SCM_MD_Fax_DenialOfCoverage_Nut(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);       
    }
}