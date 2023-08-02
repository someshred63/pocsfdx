/********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : XOL-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis
    // PRODUCT GROUP     : Xolair
    // Type              : Fax Coversheet
    // Word Template     :XOL CMGT FAX08 ReqForAddInfo
    
/********************************************************************/
@isTest
private class SCM_MD_Xol_Fax08_ReqAddInfo_Test {
    public static testMethod void Test_SCM_MD_Xol_Fax08_ReqAddInfo() {
        //local variables
        //String caseId = '500S0000000gmAcIAI';
        //caseId = '500S0000000gnRoIAI';
        String caseId;  // case no : 0010017318
       Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_Xol_Fax08_ReqAddInfo mergeDoc = new SCM_MD_Xol_Fax08_ReqAddInfo(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    } 
}