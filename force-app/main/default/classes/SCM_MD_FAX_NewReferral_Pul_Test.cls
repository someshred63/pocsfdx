/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : PUL-CMGT-FAX-29 NEW REFERRAL.doc
    // PRODUCT GROUP     : Pulmonary / Pulmozyme
    // Type              : Fax Coversheet
    // Word Template     : New Referral Pulmozyme.doc
    // Label in SF       : 
/********************************************************************/
@isTest
private class SCM_MD_FAX_NewReferral_Pul_Test {
    public static testMethod void Test_SCM_MD_FAX_NewReferral_Pul() {
    
     List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
                                         from SCM_Merge_Document__c 
                                         where Merge_Class_Name__c='SCM_MD_FAX_NewReferral_Pul'];
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Pulmozyme');
        String caseId = documentCase.Id;
        String argLookupId = '';
        if(docs.size()>0)
            argLookupId=docs[0].Id;  
            
        SCM_MD_FAX_NewReferral_Pul mergeDoc = new SCM_MD_FAX_NewReferral_Pul(caseId, argLookupId);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString(); 
    }
}