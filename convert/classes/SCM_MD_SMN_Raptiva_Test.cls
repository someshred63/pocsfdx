//********************************************************************
    // Developer Name    : Reji Joseph
    // Document Name     : RAP-CMGT-FAX-38_SMNForm_FinalAnalysis.doc
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type              : System Document
    // Word Template     : SMN_Form_Raptiva.doc
    // Label in SF       : 
//******************************************************************** 

@IsTest
private class SCM_MD_SMN_Raptiva_Test {
    public static testMethod void Test_SCM_MD_SMN_Raptiva()
    {
        String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        
        SCM_MD_SMN_Raptiva mergeDoc = new SCM_MD_SMN_Raptiva(caseId, argLookupId);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
    }
}