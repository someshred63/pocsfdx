/**
 Test Class for SCM_MD_GATCF_Denial_Form_BIOONCOLOGY
 Created by Sridhar.vangala
 */
@isTest
private class SCM_MD_GATCF_Denial_Form_BIOONc_Test
 {

    static testMethod void SCM_MD_GATCF_Denial_Form_BIOONc_Test()
     {
        //local variables
        String caseId = '500S0000000glSx';
        String argLookupId = '';
        
        SCM_MD_GATCF_Denial_Form_BIOONCOLOGY mergeDoc = 
            new SCM_MD_GATCF_Denial_Form_BIOONCOLOGY(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);                          
     }
}