//Added: Paras Sharma
//Document: CMGT-FAX-63 - GATCF Approval Spanish Form Analysis v1.0 -FINAL
//Test Class for Lucentis
@isTest
private class SCM_MD_GATCFApprovalSpanishLet_Luc_Test {
    public static testMethod void GATCFApprovalSpanishLet_Luc_Test() {
        
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        argLookupID = '';       
        SCM_MD_GATCFApprovalSpanishLetter_Luc mergeDoc = new SCM_MD_GATCFApprovalSpanishLetter_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();       
    }
}