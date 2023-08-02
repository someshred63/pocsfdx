//Added: Paras Sharma
//Document: NUTR-CMGT-FAX-38_SMN_Form_FinalAnalysis_Adult.doc
//Test class for Nutropin
@isTest
private class SCM_MD_SMNFormAdult_Nut_Test {

    static testMethod void SMNFormAdult_Nut_Test() {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
       SCM_MD_SMNFormAdult_Nut mergeDoc = new SCM_MD_SMNFormAdult_Nut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}