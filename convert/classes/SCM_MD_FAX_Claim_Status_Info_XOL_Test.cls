@isTest
private class SCM_MD_FAX_Claim_Status_Info_XOL_Test {
    public static testMethod void testClaimsFollowUp() {
         String caseId;
        String argLookupID;   
        
        //caseId = '500S0000000gmAqIAI';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_FAX_Claim_Status_Info_XOL mergeDoc = 
        	new SCM_MD_FAX_Claim_Status_Info_XOL(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
    }
}