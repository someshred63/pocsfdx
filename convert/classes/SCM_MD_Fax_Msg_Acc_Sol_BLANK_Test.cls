/**
 Test Class for SCM_MD_Fax_Msg_Access_Solutions_BLANK
 Created by Sridhar.vangala
 */
@isTest
private class SCM_MD_Fax_Msg_Acc_Sol_BLANK_Test
 {

    static testMethod void SCM_MD_Fax_Msg_Acc_Sol_BLANK_Test()
     {
        //local variables
        String caseId = '500S0000000glSx';
        String argLookupId = '';
        
        SCM_MD_Fax_Msg_Access_Solutions_BLANK mergeDoc = 
            new SCM_MD_Fax_Msg_Access_Solutions_BLANK(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);                          
     }
}