@isTest
private class SCM_MD_Fax_INOResLett_Luc_Test {
    public static testMethod void testINOResLett() {
        //local variables
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';  
        
        SCM_MD_Fax_INOResLett_Luc mergeDoc = 
            new SCM_MD_Fax_INOResLett_Luc(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);       
    }
}