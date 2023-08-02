//Created by : Prabha

@isTest
private class SCM_MD_FAX_INF_DOC_RET_PUL_Test {

    static testMethod void myUnitTest() {
         //local variables
        String caseId = '500S0000000glSx';
        String argLookupId = '';
        
        SCM_MD_FAX_INF_DOC_RET_PUL mergeDoc = 
            new SCM_MD_FAX_INF_DOC_RET_PUL(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }
}