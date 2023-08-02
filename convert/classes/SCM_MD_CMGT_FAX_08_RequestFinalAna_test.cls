public class SCM_MD_CMGT_FAX_08_RequestFinalAna_test {

     static testMethod void myUnitTest() {
   Case documentCase = SCM_CreateTestData.CreateCase();
      String caseId = documentCase.Id;
      String argLookupId = '';
      SCM_MD_CMGT_FAX_08_RequestFinalAnalysis mergeDoc = new SCM_MD_CMGT_FAX_08_RequestFinalAnalysis(caseId, argLookupId);
      SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
      String test = mergeDoc.getXMLString(); 
      //SCM_CreateTestData.CreateCase() is a method that generates a case and uses it to test your class. 
      //It has most of the fields we need. However, if we find some fields missing in the case data,
     // we can add that to the SCM_CreateTestData.CreateCase() method.
    }



}