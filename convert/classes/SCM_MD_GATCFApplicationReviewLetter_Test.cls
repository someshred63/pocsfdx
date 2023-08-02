@isTest
private class SCM_MD_GATCFApplicationReviewLetter_Test 
{

    static testMethod void testGATCFApplicationReviewLetter()
    {
    	//local Variables
        String argLookupID;       
       
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_GATCFApplicationReviewLetter mergeDoc = new SCM_MD_GATCFApplicationReviewLetter(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test=mergeDoc.getXmlString();
    	 
    }
}