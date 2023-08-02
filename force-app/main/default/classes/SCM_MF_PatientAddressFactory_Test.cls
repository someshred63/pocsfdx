//Added: Paras Sharma
//Test Class for SCM_MF_PatientAddressFactory

@isTest
private class SCM_MF_PatientAddressFactory_Test {

    static testMethod void myUnitTest() {
        //Factory Test Class
            SCM_MergeField testMF = new SCM_MergeField();
            String strKey ='';
            String strFieldValue ='';
            
            Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Lucentis');
            String PatId = testCase.Patient_gne__c;
            System.debug('Patient Id in test case: ' + PatId);
            
            //PatientAddressLine1
            testMF = SCM_MF_PatientAddressFactory.PatientAddressLine1(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PatientAddressLine1 and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Patient AddressLine1');
            System.assertEquals(strFieldValue, '1001 Main Street');
            
            //PatientAddressLine2
            testMF = SCM_MF_PatientAddressFactory.PatientAddressLine2(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PatientAddressLine2 and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Patient AddressLine2');
            System.assertEquals(strFieldValue, 'Apt 345');
            
            //City
            testMF = SCM_MF_PatientAddressFactory.City(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : City and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientCity');
            System.assertEquals(strFieldValue, 'San Mateo');
            
            //State
            testMF = SCM_MF_PatientAddressFactory.State(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : State and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientState');
            System.assertEquals(strFieldValue, 'CA');
            
            //Zip
            testMF = SCM_MF_PatientAddressFactory.Zip(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : Zip and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientZip');
            System.assertEquals(strFieldValue, '99999');
            
            //PatientCityStateZip
            testMF = SCM_MF_PatientAddressFactory.PatientCityStateZip(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PatientCityStateZip and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientCityStateZip');
            System.assertEquals(strFieldValue, 'San Mateo, CA  99999');
            
            //PatientPhone
            testMF = SCM_MF_PatientAddressFactory.PatientPhone(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PatientPhone and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientPhone');
            System.assertEquals(strFieldValue, '(999) 999-1234');
            
            //PatientStAddress2
            testMF = SCM_MF_PatientAddressFactory.PatientStAddress2(PatId);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PatientStAddress2 and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PatientStAddress2');
            System.assertEquals(strFieldValue, '1001 Main Street Apt 345');
    }
}