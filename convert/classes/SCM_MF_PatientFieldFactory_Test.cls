/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 
@isTest
private class SCM_MF_PatientFieldFactory_Test {

    static testMethod void myUnitTest() {
        
        SCM_MergeField testMF = new SCM_MergeField();
        String strKey ='';
        String strFieldValue ='';
        
        Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Lucentis');
        System.debug(' TestCase ID :' + testCase.Id);
        System.debug(' Patient ID :' +testCase.Patient_gne__c);       
        
        testMF = SCM_MF_PatientFieldFactory.PatientFirstAndLastName(testCase.Patient_gne__c);       
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('1. Method Name : PatientFirstAndLastName and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);     
        System.assertEquals(strKey,'Patient_First_And_Last_Name');
        System.assertEquals(strFieldValue, 'fname TestPatient');
        System.assertEquals(testMF.checked, false);
        System.assertEquals(testMF.displayCheck, false);
        System.assertEquals(testMF.displayTextBox, false);
        System.assertEquals(testMF.displayLabel, false);    
        
        testMF = SCM_MF_PatientFieldFactory.PatientDOB(testCase.Patient_gne__c);        
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('2. Method Name : PatientDOB and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);      
        System.assertEquals(strKey,'Patient_DOB');
        System.assertEquals(strFieldValue, '6/2/1981');
        
        testMF = SCM_MF_PatientFieldFactory.PatientAge(testCase.Patient_gne__c);        
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('3. Method Name : PatientAge and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);      
        System.assertEquals(strKey,'PatientAge');
        System.assertEquals(strFieldValue, '27');
        
        testMF = SCM_MF_PatientFieldFactory.Patient_Home_Phone(testCase.Patient_gne__c);        
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('4. Method Name : Patient_Home_Phone and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);      
        System.assertEquals(strKey,'PatientHomePhone');
        System.assertEquals(strFieldValue, '(222) 222-2222');
        
        testMF = SCM_MF_PatientFieldFactory.PatientFirstMiddleAndLastName(testCase.Patient_gne__c);     
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('5. Method Name : PatientFirstMiddleAndLastName and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);       
        System.assertEquals(strKey,'PatientFullName');
        System.assertEquals(strFieldValue, 'fname TestPatient');
        
        testMF = SCM_MF_PatientFieldFactory.PatientGender(testCase.Patient_gne__c);     
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('6. Method Name : PatientGender and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);       
        System.assertEquals(strKey,'Patient Gender');
        System.assertEquals(strFieldValue, 'Male');
        
        testMF = SCM_MF_PatientFieldFactory.PatientHisHer(testCase.Patient_gne__c);     
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('7. Method Name : PatientHisHer and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);       
        System.assertEquals(strKey,'His_Her');
        System.assertEquals(strFieldValue, 'His');
        
        testMF = SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(testCase.Patient_gne__c);     
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('8. Method Name : PatientGenderCheckBoxMale and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);       
        System.assertEquals(strKey,'chkMale');
        System.assertEquals(strFieldValue, 'R');
        
        testMF = SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(testCase.Patient_gne__c);       
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('9. Method Name : PatientGenderCheckBoxFemale and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);     
        System.assertEquals(strKey,'chkFemale');
        System.assertEquals(strFieldValue, '£');
        
        testMF = SCM_MF_PatientFieldFactory.PatientFirstName(testCase.Patient_gne__c);      
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('10. Method Name : PatientFirstName and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);        
        System.assertEquals(strKey,'PatientFirstName');
        System.assertEquals(strFieldValue, 'fname');
        
        testMF = SCM_MF_PatientFieldFactory.PatientLastName(testCase.Patient_gne__c);       
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('11. Method Name : PatientLastName and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);     
        System.assertEquals(strKey,'PatientLastName');
        System.assertEquals(strFieldValue, 'TestPatient');
        
        testMF = SCM_MF_PatientFieldFactory.PatientHomePhone(testCase.Patient_gne__c);      
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('12. Method Name : PatientHomePhone and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);        
        System.assertEquals(strKey,'PatientHomePhone');
        System.assertEquals(strFieldValue, '(222) 222-2222');
        
        testMF = SCM_MF_PatientFieldFactory.PatientWorkPhone(testCase.Patient_gne__c);      
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('13. Method Name : PatientWorkPhone and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);        
        System.assertEquals(strKey,'PatientWorkPhone');
        System.assertEquals(strFieldValue, '(708) 555-5555');
        
        testMF = SCM_MF_PatientFieldFactory.PatientCellPhone(testCase.Patient_gne__c);      
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('14. Method Name : PatientCellPhone and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);        
        System.assertEquals(strKey,'PatientCellPhone');
        System.assertEquals(strFieldValue, '(708) 555-5555');
        
        testMF = SCM_MF_PatientFieldFactory.PatientSSN(testCase.Patient_gne__c);        
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('15. Method Name : PatientSSN and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);      
        System.assertEquals(strKey,'PatientSSN');
        System.assertEquals(strFieldValue, '111-11-1111');
        
        // Negative TestCase
        SCM_MF_PatientFieldFactory.clearList();
        
        SCM_MergeField testMFN = new SCM_MergeField();
        testMFN = SCM_MF_PatientFieldFactory.PatientFirstAndLastName('a0LS0000000CGTXA4');        
        strKey = testMFN.getKey();
        System.debug(' testMFN.getKey :' +SCM_MF_PatientFieldFactory.PatientFirstAndLastName('a0LS0000000CGTWA4'));
        System.debug(' testMFN.getFieldValue :' +testMFN.getFieldValue());        
        strFieldValue = testMFN.getFieldValue();
        System.debug('16. Method Name : PatientFirstAndLastName and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);     
        System.assertEquals(strKey,'Patient_First_And_Last_Name');
        System.assertEquals(strFieldValue, '');
        System.assertEquals(testMF.checked, false);
        System.assertEquals(testMF.displayCheck, false);
        System.assertEquals(testMF.displayTextBox, false);
        System.assertEquals(testMF.displayLabel, false);    
        
        testMFN = SCM_MF_PatientFieldFactory.PatientDOB('a0LS0000000CGTXA4');        
        strKey = testMFN.getKey();
        strFieldValue = testMFN.getFieldValue();
        System.debug('17. Method Name : PatientDOB and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);      
        System.assertEquals(strKey,'Patient_DOB');
        System.assertEquals(strFieldValue, null);
        
        testMFN = SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale('a0LS0000000CGTXA4');     
        strKey = testMFN.getKey();
        strFieldValue = testMFN.getFieldValue();
        System.debug('8. Method Name : PatientGenderCheckBoxMale and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);       
        System.assertEquals(strKey,'chkMale');
        System.assertEquals(strFieldValue, '£');
        
        testMFN = SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale('a0LS0000000CGTXA4');       
        strKey = testMFN.getKey();
        strFieldValue = testMFN.getFieldValue();
        System.debug('9. Method Name : PatientGenderCheckBoxFemale and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);     
        System.assertEquals(strKey,'chkFemale');
        System.assertEquals(strFieldValue, '£');
        
        
        testMFN = SCM_MF_PatientFieldFactory.PatientHomePhone('a0LS0000000CGTXA4');      
        strKey = testMFN.getKey();
        strFieldValue = testMFN.getFieldValue();
        System.debug('12. Method Name : PatientHomePhone and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);        
        System.assertEquals(strKey,'PatientHomePhone');
        System.assertEquals(strFieldValue, '');
        
        testMFN = SCM_MF_PatientFieldFactory.PatientWorkPhone('a0LS0000000CGTXA4');      
        strKey = testMFN.getKey();
        strFieldValue = testMFN.getFieldValue();
        System.debug('13. Method Name : PatientWorkPhone and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);        
        System.assertEquals(strKey,'PatientWorkPhone');
        System.assertEquals(strFieldValue, '');
        
        testMFN = SCM_MF_PatientFieldFactory.PatientCellPhone('a0LS0000000CGTXA4');      
        strKey = testMFN.getKey();
        strFieldValue = testMFN.getFieldValue();
        System.debug('14. Method Name : PatientCellPhone and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);        
        System.assertEquals(strKey,'PatientCellPhone');
        System.assertEquals(strFieldValue, '');
        
        testMFN = SCM_MF_PatientFieldFactory.PatientSSN('a0LS0000000CGTXA4');        
        strKey = testMFN.getKey();
        strFieldValue = testMFN.getFieldValue();
        System.debug('15. Method Name : PatientSSN and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);      
        System.assertEquals(strKey,'PatientSSN');
        System.assertEquals(strFieldValue, '');
        
    }
}