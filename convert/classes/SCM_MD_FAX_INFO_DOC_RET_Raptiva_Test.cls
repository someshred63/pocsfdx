/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RAP_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type              : Fax Coversheet
    // Word Template     : Information Documentation Retrieval Raptiva.doc
    // Label in SF       : 
/********************************************************************/

@isTest
private class SCM_MD_FAX_INFO_DOC_RET_Raptiva_Test {
    public static testMethod void Test_SCM_MD_FAX_INFO_DOC_RET_Raptiva() {
        //local variables
        String caseId;
        //caseId = '500S0000000glSx';
        String argLookupId = '';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        SCM_MD_FAX_INFO_DOC_RET_Raptiva mergeDoc = new SCM_MD_FAX_INFO_DOC_RET_Raptiva(caseId, argLookupId);
		string test = mergeDoc.getXMLString(); 
    }
}