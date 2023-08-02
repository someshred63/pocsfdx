@isTest
private class SCM_MD_Fax_Claim_Status_Luc_Test {
    public static testMethod void testClaimsFollowUp() {
         String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gmAqIAI';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_Fax_Claim_Status_Luc mergeDoc = 
        	new SCM_MD_Fax_Claim_Status_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
    }
}