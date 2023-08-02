//Added: Rajesh Sinha
//Document: RAP-CMGT-FAX-23_Ditributor_Referral_FinalAnalysis.doc  
//Test class for Dermatology / Raptiva

@isTest
private class SCM_MD_Fax_DistributorReferral_Rap_Test {

    static testMethod void DistributorReferral_Rap_Test() {
        // TO DO: implement unit test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
               
        SCM_MD_Fax_DistributorReferral_Rap mergeDoc = 
        	new SCM_MD_Fax_DistributorReferral_Rap(caseId, argLookupID);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        String test = mergeDoc.getXMLString();
                       
    }
}