//********************************************************************
    // Developer Name    : Reji Joseph
    // Document Name     : RA-CMGT-FAX-38_SMN_Form_FinalAnalysis.doc
    // PRODUCT GROUP     : Rheumatology / Rituxan RA
    // Type              : System Document
    // Word Template     : SMN Form RituxanRA.doc
    // Label in SF       : 
//********************************************************************/ 
@isTest
private class SCM_MD_SMN_RituxanRA_Test {
    public static testMethod void Test_SCM_MD_SMN_RituxanRA() {
    
     List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
                                         from SCM_Merge_Document__c 
                                         where Merge_Class_Name__c='SCM_MD_SMN_RituxanRA'];
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','RituxanRA');
        String caseId = documentCase.Id;
        String argLookupId = '';
        if(docs.size()>0)
            argLookupId=docs[0].Id;  
            
        SCM_MD_SMN_RituxanRA mergeDoc = new SCM_MD_SMN_RituxanRA(caseId, argLookupId);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString(); 
    }
}