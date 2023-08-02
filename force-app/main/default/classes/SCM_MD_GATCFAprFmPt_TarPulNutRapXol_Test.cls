/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : Final TAR-PUL-NUT-RAP-XOL(PT) - CMGT-FAX-51 - GATCF Approval Form.doc
    // PRODUCT GROUP     : Tarceva, Pulmozyme, Nutropin, Raptiva, Xolair(Patient)
    // Type              : System Document
    // Word Template     : GATCF_ApprovalFormPt_TarPulNulRapXol.doc
    // Label in SF       : 
/********************************************************************/

@isTest
private class SCM_MD_GATCFAprFmPt_TarPulNutRapXol_Test {
    public static testMethod void Test_SCM_MD_GATCFAprFmPt_TarPulNutRapXol() {
    
     List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
                                         from SCM_Merge_Document__c 
                                         where Merge_Class_Name__c='SCM_MD_GATCFAprFmPt_TarPulNutRapXol'];
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Raptiva');
        String caseId = documentCase.Id;
        String argLookupId = '';
        if(docs.size()>0)
            argLookupId=docs[0].Id;  
            
        SCM_MD_GATCFAprFmPt_TarPulNutRapXol mergeDoc = new SCM_MD_GATCFAprFmPt_TarPulNutRapXol(caseId, argLookupId);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString(); 
    }
}