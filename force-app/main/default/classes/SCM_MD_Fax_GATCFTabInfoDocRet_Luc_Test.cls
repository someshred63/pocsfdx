//Added: Paras Sharma
//Document: CMGT-FAX-01 - GATCF Tab - Information / Documentation Retrieval
//Test class for Lucentis

@isTest             
private class SCM_MD_Fax_GATCFTabInfoDocRet_Luc_Test {

    static testMethod void Fax_GATCFTabInfoDocRet_Luc_Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        argLookupID = '';       
        SCM_MD_Fax_GATCFTabInfoDocRet_Luc mergeDoc = new SCM_MD_Fax_GATCFTabInfoDocRet_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
    }
}