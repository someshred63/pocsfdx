@isTest
private class SCM_MD_Fax_Claims_Status_AVA_Test {
    public static testMethod void testClaimsFollowUp() {
         String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gmAqIAI';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_Fax_Claims_Status_AVA mergeDoc = 
        	new SCM_MD_Fax_Claims_Status_AVA(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
    }
}