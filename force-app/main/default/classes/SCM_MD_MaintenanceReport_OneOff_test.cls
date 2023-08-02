@isTest
private class SCM_MD_MaintenanceReport_OneOff_test {
    public static testMethod void Test() {
     
        String caseId;  // case no : 0010017318
       Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_MaintenanceReport_OneOff mergeDoc = new SCM_MD_MaintenanceReport_OneOff(caseId, argLookupId);
        string test = mergeDoc.getXMLString(); 
    } 
}