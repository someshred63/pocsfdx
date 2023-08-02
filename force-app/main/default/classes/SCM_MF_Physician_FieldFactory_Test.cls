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
private class SCM_MF_Physician_FieldFactory_Test {

    static testMethod void myUnitTest() {
        //Factory Test Class
        SCM_MergeField testMF = new SCM_MergeField();
        String strKey ='';
        String strFieldValue ='';
        
        Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Lucentis');
        System.debug(' TestCase ID :' + testCase.Id);
        System.debug(' Physician ID :' +testCase.Case_Treating_Physician_gne__c);       
        //Account casePhysician = [Select Id,FirstName,LastName from Account where FirstName = 'PhysicianFirst' and LastName='PhysicianLast' limit 1];
        //System.debug(' Physician FirstName :' + casePhysician.FirstName);       
        //System.debug(' Physician LastName :' + casePhysician.LastName);     
     
        testMF = SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(testCase.Case_Treating_Physician_gne__c);     
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('1. Method Name : PhysicianFirstLastName and  Key Returned :'+ strKey + ' FiledValue :' + strFieldValue);      
        System.assertEquals(strKey,'Physician First Last Name');
        //System.debug('Firstname ' +testCase.Case_Treating_Physician_gne__r.FirstName);
        //System.debug(' FirstName :' + casePhysician.FirstName + ' LastName :' + casePhysician.LastName + '  and   strFieldValue = '+strFieldValue);       
        System.assertEquals(strFieldValue, 'PhysicianFirst PhysicianLast');
        
        testMF = SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(testCase.Case_Treating_Physician_gne__c);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('2. Method Name : ATTN_PhysicianContactName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );  
        System.assertEquals(strKey,'ATTN_Attn');
        //System.debug(' strFieldValue :' + strFieldValue);
        System.assertEquals(strFieldValue, 'PhysicianFirst');
        
        testMF = SCM_MF_Physician_FieldFactory.PhysicianLastName(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('3. Method Name : PhysicianLastName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );  
        System.assertEquals(strKey,'Physician Last Name');
        System.assertEquals(strFieldValue, 'PhysicianLast');
    
        testMF = SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('4. Method Name : PhysicianFirstMidAndLastName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );   
        //System.debug(' strFieldValue :' + strFieldValue);
        System.assertEquals(strKey,'RECNAME_To');
        System.assertEquals(strFieldValue, 'PhysicianFirst PhysicianLast, M.D.');
    
        testMF = SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('5. Method Name : PhysicianFirstLastName_Textbox and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue ); 
        System.assertEquals(strKey,'RECNAME');
        System.assertEquals(strFieldValue, 'PhysicianFirst PhysicianLast');
                            
        testMF = SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName_Invisible(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('6. Method Name : PhysicianFirstMidAndLastName_Invisible and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue ); 
        System.assertEquals(strKey,'PhysicianFullName');
        //System.debug(' strFieldValue :' + strFieldValue);
        System.assertEquals(strFieldValue, 'PhysicianFirst PhysicianLast, M.D.');
    
        testMF = SCM_MF_Physician_FieldFactory.PhysicianFax(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('7. Method Name : PhysicianFax and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );   
        System.assertEquals(strKey,'RECFAX_Fax');
        System.assertEquals(strFieldValue, null);
        
        testMF = SCM_MF_Physician_FieldFactory.PhysicianTitle(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('8. Method Name : PhysicianTitle and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
        System.assertEquals(strFieldValue, '');
                    
        testMF = SCM_MF_Physician_FieldFactory.PhysicianDEA(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('9. Method Name : PhysicianDEA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );   
        System.assertEquals(strKey,'Physician DEA');
        //string phyDEA = strFieldValue;
        System.debug(' strFieldValue :' + strFieldValue);
        System.assertEquals(strFieldValue, '');
            
        testMF = SCM_MF_Physician_FieldFactory.ProfileLicenceID(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('10. Method Name : ProfileLicenceID and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );      
        System.assertEquals(strKey,'Physician Profile Luncentis');
        //string phyLic = strFieldValue;
        System.assertEquals(strFieldValue, '');
        
        testMF = SCM_MF_Physician_FieldFactory.TaxID(testCase.Case_Treating_Physician_gne__r.Id);
        strKey = testMF.getKey();
        strFieldValue = testMF.getFieldValue();
        System.debug('11. Method Name : TaxID and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );     
        System.assertEquals(strKey,'Physician Tax Id');
        System.assertEquals(strFieldValue, '');
            
    }
}