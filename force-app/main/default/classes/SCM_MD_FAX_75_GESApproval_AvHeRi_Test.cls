@isTest
private class SCM_MD_FAX_75_GESApproval_AvHeRi_Test {


    static testMethod void Test() {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_FAX_75_GESApprovalLetter_AvHeRi mergeDoc =
        	 new SCM_MD_FAX_75_GESApprovalLetter_AvHeRi(caseId, argLookupId);
     	
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        
                
             
    }
}