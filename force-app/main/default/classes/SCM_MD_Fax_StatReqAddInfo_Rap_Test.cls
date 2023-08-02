/**
 Test Class for SCM_MD_Fax_StatReqAddInfo_Rap.cls.
 created by Vishwanath
  */
  

@isTest
private class SCM_MD_Fax_StatReqAddInfo_Rap_Test
 {

    static testMethod void SCM_MD_Fax_StatReqAddInfo_Rap_Test()
     {
        //local variables
        String caseId = '500S0000000glSx';
        String argLookupId = '';
        
        SCM_MD_Fax_StatReqAddInfo_Rap mergeDoc = 
            new SCM_MD_Fax_StatReqAddInfo_Rap(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);                          
     }
}