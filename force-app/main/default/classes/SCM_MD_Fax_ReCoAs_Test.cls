@isTest
private class SCM_MD_Fax_ReCoAs_Test {
             


    static testMethod void Fax_Fax_ReCoAs_Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        argLookupID = '';       
        SCM_MD_Fax_ReCoAs_LuNuRaRaRiAvHeXoTaPu mergeDoc = new SCM_MD_Fax_ReCoAs_LuNuRaRaRiAvHeXoTaPu(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
    }
}