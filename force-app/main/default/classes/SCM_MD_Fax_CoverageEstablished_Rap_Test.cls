/**
Added: Rajesh Sinha
Document: RAP-CMGT-FAX-13 COVERAGE ESTABLISHED.DOC
Test Class for Raptiva
*/
@isTest
private class SCM_MD_Fax_CoverageEstablished_Rap_Test {

    static testMethod void CoverageEstablished_Rap_Test() {
        // TO DO: implement unit test
        String caseId;
        String argLookupID;  
        //caseId = '500S0000000gntA';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';       
        SCM_MD_Fax_CoverageEstablished_Rap mergeDoc = new SCM_MD_Fax_CoverageEstablished_Rap(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        /**
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        //test for Addressed To
        String to = fields[1].fieldValue; 
        System.assertEquals(to , '');
        */
                
    }
}