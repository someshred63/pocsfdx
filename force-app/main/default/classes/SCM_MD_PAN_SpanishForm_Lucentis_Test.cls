//Created by : Prabha
//Created on : 13th Jan 2009
@isTest
private class SCM_MD_PAN_SpanishForm_Lucentis_Test {

    static testMethod void myUnitTest() {
       //local variables
        String caseId;
        String argLookupId = '';
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;
        
        SCM_MD_PAN_SpanishForm_Lucentis mergeDoc = 
            new SCM_MD_PAN_SpanishForm_Lucentis(caseId, argLookupId);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);  
    }
}