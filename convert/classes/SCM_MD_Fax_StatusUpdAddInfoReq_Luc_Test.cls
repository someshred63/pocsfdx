//Added: Paras Sharma
//Document: LUC-CMGT-FAX-22_Status_Update-Additional_Information_Required.doc
//Test class for Lucentis

@isTest
private class SCM_MD_Fax_StatusUpdAddInfoReq_Luc_Test {

    static testMethod void Fax_StatusUpdAddInfoReq_Luc_Test() {
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        argLookupID = '';       
        SCM_MD_Fax_StatusUpdAddInfoReq_Luc mergeDoc = new SCM_MD_Fax_StatusUpdAddInfoReq_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString(); 
    }
}