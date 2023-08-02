/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 

/**
 Test Class for SCM_MD_FAX_INFO_DOC_RET_RITUXAN.cls..
 Recreated by Sridhar.vangala
 */
@isTest
private class SCM_MD_FAX_INFO_DOC_RET_RITUXAN_TEST
 {

    static testMethod void SCM_MD_FAX_INFO_DOC_RET_RITUXAN_TEST()
     {
        //local variables
        String caseId = '500S0000000glSx';
        String argLookupId = '';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        SCM_MD_FAX_INFO_DOC_RET_RITUXAN mergeDoc = 
            new SCM_MD_FAX_INFO_DOC_RET_RITUXAN(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);                          
     }
}