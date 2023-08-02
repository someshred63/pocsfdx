@isTest

 // Developer Name    : Jatin Setia
 // Document Name     : LUC-CMGT-FAX-45 – PAN Form.doc
private class SCM_MD_PanForm_Lucentis_Test 
{

    static testMethod void testPanForm_Lucentis ()
    {
       //local variables
        String caseId;
        String argLookupId = '';
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        SCM_MD_PanForm_Lucentis mergeDoc = 
            new SCM_MD_PanForm_Lucentis(caseId, argLookupId);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);    	           
  	}
}