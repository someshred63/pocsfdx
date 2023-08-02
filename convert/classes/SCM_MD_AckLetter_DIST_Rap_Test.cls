//Added: Rajesh Sinha
//Document: RAP - CMGT-FAX-41B Acknowledgement Letter (DIST) final.doc 
//Test class for DERMATOLOGY/ RAPTIVA
@isTest
private class SCM_MD_AckLetter_DIST_Rap_Test {

    static testMethod void AckLetter_DIST_Rap_Test() {
        // TO DO: implement unit test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
               
        SCM_MD_AckLetter_DIST_Rap mergeDoc = 
        	new SCM_MD_AckLetter_DIST_Rap(caseId, argLookupID);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        String test = mergeDoc.getXMLString();
                       
    }
}