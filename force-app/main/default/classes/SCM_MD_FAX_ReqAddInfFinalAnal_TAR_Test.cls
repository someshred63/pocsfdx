/**
  * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCM_MD_FAX_ReqAddInfFinalAnal_TAR_Test {

    static testMethod void myUnitTest() {
        String caseId = '500S0000000gUpoIAE';
        String argLookupId = '';
     
        SCM_MD_FAX_ReqAddInfFinalAnal_TAR mergeDoc = 
            new SCM_MD_FAX_ReqAddInfFinalAnal_TAR(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test); 
    }
}