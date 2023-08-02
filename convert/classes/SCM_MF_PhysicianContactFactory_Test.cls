@isTest
private class SCM_MF_PhysicianContactFactory_Test {
 
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
            
            //Factory Test Class
            SCM_MergeField testMF = new SCM_MergeField();
            String strKey ='';
            String strFieldValue ='';
              
            Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Herceptin');
            
            //PhysContactPh
            testMF = SCM_MF_PhysicianContactFactory.PhysicianContactPhone(testCase);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PhysicianContactPhone and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhysContactPh');
            System.assertEquals(strFieldValue, '(234) 567-8903');
            
            //PhysContactFax
            testMF = SCM_MF_PhysicianContactFactory.PhysicianContactFax(testCase);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PhysicianContactFax and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhysContactFax');
            System.assertEquals(strFieldValue, '');
            
            
            //RECFAX_Fax
            testMF = SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(testCase);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PhysicianContactFax_RECFAX and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'RECFAX_Fax');
            System.assertEquals(strFieldValue, '');
            
            
            //PhysContactFullName
            testMF = SCM_MF_PhysicianContactFactory.PhysicianContactFullName(testCase);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PhysicianContactFullName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhysContactFullName');
            System.assertEquals(strFieldValue, '');
            
        
    }
}