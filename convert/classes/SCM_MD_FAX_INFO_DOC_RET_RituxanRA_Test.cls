/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RA_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
    // PRODUCT GROUP     : Rheumatology / Rituxan RA
    // Type              : Fax Coversheet
    // Word Template     : Information Documentation Retrieval Rituxan RA.doc
    // Label in SF       : 
/********************************************************************/



@isTest
private class SCM_MD_FAX_INFO_DOC_RET_RituxanRA_Test {
    public static testMethod void Test_SCM_MD_FAX_INFO_DOC_RET_RituxanRA() {
        //local variables
        String caseId = '500S0000000glSx';
        String argLookupId = '';
        
        SCM_MD_FAX_INFO_DOC_RET_RituxanRA mergeDoc = new SCM_MD_FAX_INFO_DOC_RET_RituxanRA(caseId, argLookupId);
		string test = mergeDoc.getXMLString(); 
    }
}