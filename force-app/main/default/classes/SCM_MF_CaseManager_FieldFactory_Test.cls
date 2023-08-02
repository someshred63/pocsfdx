//Added: Paras Sharma
//Test Class for SCM_MF_CaseManager_FieldFactory

@isTest
private class SCM_MF_CaseManager_FieldFactory_Test {

    static testMethod void myUnitTest() {
        //Factory Test Class
            SCM_MergeField testMF = new SCM_MergeField();
            String strKey ='';
            String strFieldValue ='';
            
            Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Lucentis');
            String caseMgrId = testCase.Case_Manager__c;
            System.debug('Case Manager Id in test case: ' + caseMgrId);
            User caseManager = getCaseManager(caseMgrId);
            String firstName = '';
            String lastName = '';
            String extension = '';
            
            if (caseManager != null) {
                firstName = caseManager.FirstName;
                lastName = caseManager.LastName;
                extension = caseManager.Extension;
                
                if (firstName == null)
                    firstName = '';
                if (lastName == null)
                    lastName = '';
                if (extension == null)
                    extension = '';
            }
            
            //CaseManagerFromFirstAndLastName
            testMF = SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(caseMgrId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : CaseManagerFromFirstAndLastName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'From');
            System.assertEquals(strFieldValue, firstName + ' ' + lastName);
            
            //CaseManagerExtension
            testMF = SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(caseMgrId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : CaseManagerExtension and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Ext');
            System.assertEquals(strFieldValue, extension);

    }
    
    private static User getCaseManager(String caseManagerId) {
        List<User> caseUsers = [Select Id, FirstName, LastName, Extension from User Where Id =: caseManagerId Limit 1];
        
        if (!caseUsers.isEmpty())
            return caseUsers[0];
        else
            return null;
    }
}