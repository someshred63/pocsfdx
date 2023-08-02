/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RAP-CMGT-FAX-12_Denial_of_Coverage.doc
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type              : Fax Coversheet
    // Word Template     : Denial of Coverage Raptiva.doc
    // Label in SF       : 
/********************************************************************/

@isTest
private class SCM_MD_FAX_DenialofCoverage_Raptiva_Test {
    public static testMethod void Test_SCM_MD_FAX_DenialofCoverage_Raptiva() {
    
     List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
                                         from SCM_Merge_Document__c 
                                         where Merge_Class_Name__c='SCM_MD_FAX_DenialofCoverage_Raptiva'];
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Raptiva');
        String caseId = documentCase.Id;
        String argLookupId = '';
        if(docs.size()>0)
            argLookupId=docs[0].Id;  
            
        SCM_MD_FAX_DenialofCoverage_Raptiva mergeDoc = new SCM_MD_FAX_DenialofCoverage_Raptiva(caseId, argLookupId);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString(); 
    }
}