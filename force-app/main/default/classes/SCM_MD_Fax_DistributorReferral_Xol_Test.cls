@isTest
    // Developer Name    : Jatin Setia
    // Document Name     : XOL-CMGT-FAX-23_Distributor_Referral_FinalAnalysis.doc
    
private class SCM_MD_Fax_DistributorReferral_Xol_Test {

    static testMethod void testDistributorReferral_Xol() {
        //local variables

        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_Fax_DistributorReferral_Xol mergeDoc =
             new SCM_MD_Fax_DistributorReferral_Xol(caseId, argLookupId);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        String test = mergeDoc.getXMLString();
        //System.assertEquals(fields[18].getFieldValue(), 'G abhay');
         
    }
}