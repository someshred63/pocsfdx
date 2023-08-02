@isTest
class SCM_MD_GATCF_DenialForm_RA_Test {

    static testMethod void testGATCF_DenialForm_RA() {
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        SCM_MD_GATCF_DenialForm_RA mergeDoc = new SCM_MD_GATCF_DenialForm_RA(caseId, argLookupID);
        mergeDoc.createMergeFields();
        String test = mergeDoc.getXMLString();
        System.debug(test);        
    }
}