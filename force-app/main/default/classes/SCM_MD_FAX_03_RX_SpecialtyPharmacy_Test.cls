@isTest
// Developer Name    : Manjunath Nilagiri
// Document Name     : CMGT-FAX-03_RX to Specialty Pharmacy.doc
private class SCM_MD_FAX_03_RX_SpecialtyPharmacy_Test {
 		
 		static testMethod void myUnitTest() {
       //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_CMGT_FAX_03_RX_SpecialtyPharmacy mergeDoc = new SCM_MD_CMGT_FAX_03_RX_SpecialtyPharmacy(caseId, argLookupID); 
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }             
}