//Added: Rajesh Sinha
//Document: RA-CMGT-FAX-07 Appeal Information
//Test class for Rheumatology / Rituxan RA
@isTest
private class SCM_MD_CMGT_FAX07_AppealInfo_Test {

    static testMethod void FAX07_AppealInfo_Test() {
        // TO DO: implement unit test
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
               
        SCM_MD_CMGT_FAX07_AppealInfo mergeDoc = 
        	new SCM_MD_CMGT_FAX07_AppealInfo(caseId, argLookupID);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        String test = mergeDoc.getXMLString();
        System.debug(test);          
    }
}