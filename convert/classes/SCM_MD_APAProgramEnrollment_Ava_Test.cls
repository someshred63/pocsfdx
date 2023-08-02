@isTest
private class SCM_MD_APAProgramEnrollment_Ava_Test {
    public static testMethod void testClaimsFollowUp() {
         String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gmAqIAI';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_APAProgramEnrollmentHospital_Ava mergeDoc = 
        	new SCM_MD_APAProgramEnrollmentHospital_Ava(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
    }
}