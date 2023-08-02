// Created By sridhar


@isTest
private class SCM_MF_PhyAddress_FieldFactory_Test {
    static testMethod void myUnitTest() {
            //Factory Test Class
            SCM_MergeField testMF = new SCM_MergeField();
            String strKey ='';
            String strFieldValue ='';
            
            Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Herceptin');
            String physicianId = testCase.Case_Treating_Physician_gne__c;
            System.debug('Physician Id in test case: ' + physicianId);
             
            //PhysicianAddress_Street         
            testMF = SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(testCase.id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PhysicianAddress_Street and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhysicianStreetAddrs');
            System.assertEquals(strFieldValue, '1234 Green Valley Rd');
            
            //PhysicianAddress_CityStateZip
            testMF = SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(testCase.id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('2. Method Name : PhysicianAddress_CityStateZip and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhyCityStateZip');
            System.assertEquals(strFieldValue, 'Atlanta GA 30301');
            
            //PhysicianAddress_City
            testMF = SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_City(physicianId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('3. Method Name : PhysicianAddress_City and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhyCity');
            System.assertEquals(strFieldValue, 'Atlanta');
            
            //PhysicianAddress_State
            testMF = SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_State(physicianId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('4. Method Name : PhysicianAddress_State and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhyState');
            System.assertEquals(strFieldValue, 'GA');
            
            //PhysicianAddress_Zip
            testMF = SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Zip(physicianId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('5. Method Name : PhysicianAddress_Zip and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PhyZip');
            System.assertEquals(strFieldValue, '30301');
           
           
    }
}