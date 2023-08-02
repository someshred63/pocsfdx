//Added: Rajesh Sinha
//Document: Consolidated PUL-NUT CMGT-FAX-62 Family Intro Letter Spanish final.doc 
//Test class for PULMONARY/ PULMOZYME AND GROWTH HARMONE/NUTROPIN
@isTest
private class SCM_MD_FamIntLetSpanish_PULNUT_Test {

    static testMethod void FamIntLetSpanish_PULNUT_Test() {
        // TO DO: implement unit test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
               
        SCM_MD_FamIntLetSpanish_PULNUT mergeDoc = 
        	new SCM_MD_FamIntLetSpanish_PULNUT(caseId, argLookupID);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        String test = mergeDoc.getXMLString();
                       
    }
}