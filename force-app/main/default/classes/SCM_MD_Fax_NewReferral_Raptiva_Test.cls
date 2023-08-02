@isTest
//Added: Jatin Setia
//Document: RAP-CMGT-FAX-29 NEW REFERRAL
private class SCM_MD_Fax_NewReferral_Raptiva_Test {

    static testMethod void myUnitTest() {
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        SCM_MD_Fax_NewReferral_Raptiva mergeDoc = new SCM_MD_Fax_NewReferral_Raptiva(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
        System.debug(test);        
    }
}