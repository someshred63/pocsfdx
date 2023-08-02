@isTest
    // Developer Name    : Jatin Setia
    // Document Name     : Consolidated CMGT-FAX-42 PAN Request final
private class SCM_MD_PANReqConsol_AvHeRiTaRaAcRa_Test {

    static testMethod void testPANReqConsol_AvHeRiTaRaAcRa() {
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = ''; 
              
        SCM_MD_PANReqConsol_AvHeRiTaRaAcRa mergeDoc = new SCM_MD_PANReqConsol_AvHeRiTaRaAcRa(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}