public class SCM_MD_GATCF_DS_Lucentis_test {
static testMethod void Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        argLookupID = '';       
        SCM_MD_GATCF_DS_Lucentis mergeDoc = new SCM_MD_GATCF_DS_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
    }
}