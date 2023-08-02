//Created By Sridhar

@isTest
private class SCM_MF_PatientContact_FieldFactory_Test {
    static testMethod void myUnitTest() {
            //Factory Test Class
            SCM_MergeField testMF = new SCM_MergeField();
            String strKey ='';
            String strFieldValue ='';
            
            Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Avastin');
            String patientId = testCase.Patient_gne__c;
            System.debug('Patient Id in test case: ' + patientId);
            
            //PatientContactFullName              
            testMF = SCM_MF_PatientContact_FieldFactory.PatientContactFullName(patientId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PatientContactFullName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientFullName');
            System.assertEquals(strFieldValue, '');
            
            //PatientPrimeConHmPh
            testMF = SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(patientId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('2. Method Name : PatientPrimeConHmPh and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientPrimeConHmPh');
            System.assertEquals(strFieldValue, '');
            
            //PatientHomePhone
            testMF = SCM_MF_PatientContact_FieldFactory.PatientHomePhone(patientId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('3. Method Name : PatientHomePhone and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Pat_Home_Ph');
            System.assertEquals(strFieldValue, '123456');
            
            //PatientWorkPhone
            testMF = SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(patientId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('4. Method Name : PatientWorkPhone and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Pat_Work_Ph');
            System.assertEquals(strFieldValue, '654321');
            
            //PatientOtherPhone
            testMF = SCM_MF_PatientContact_FieldFactory.PatientOtherPhone(patientId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('5. Method Name : PatientOtherPhone and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Pat_Other_Ph');
            System.assertEquals(strFieldValue, '1212121');
            
            //PatientPrimaryConFullName
            testMF = SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(patientId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('6. Method Name : PatientPrimaryConFullName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientPrimeConFullName');
            System.assertEquals(strFieldValue, 'Fname Lname');
            
            //PatientRelationship
            testMF = SCM_MF_PatientContact_FieldFactory.PatientRelationship(patientId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('7. Method Name : PatientRelationship and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Relationship');
            System.assertEquals(strFieldValue, 'ABCRelashion');
            
            
            
              
            
            
    }
}