//created by Sridhar

@isTest
private class SCM_MD_Fax_StaUpd_ReqAddInf_Nut_Test {
    public static testMethod void myUnitTest() {
        //local variables
        String argLookupID;  
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        argLookupID = '';
        
        SCM_MD_Fax_StaUpd_ReqForAddInf_Nut mergeDoc = 
            new SCM_MD_Fax_StaUpd_ReqForAddInf_Nut(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);       
    }
}