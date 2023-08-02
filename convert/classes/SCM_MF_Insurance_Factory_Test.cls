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
private class SCM_MF_Insurance_Factory_Test {

    static testMethod void myUnitTest() {
            //Factory Test Class
            SCM_MergeField testMF = new SCM_MergeField();
            String strKey ='';
            String strFieldValue ='';
            
            Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Herceptin');

            //InsuranceContactNamePA
            testMF = SCM_MF_Insurance_Factory.InsuranceContactNamePA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceContactNamePA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'ATTN_PA');
            System.assertEquals(strFieldValue, '');

            //InsuranceContactFaxPA
            testMF = SCM_MF_Insurance_Factory.InsuranceContactFaxPA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceContactFaxPA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'RECFAX_PA');
            System.assertEquals(strFieldValue, '');

            //InsurancePhone
            testMF = SCM_MF_Insurance_Factory.InsurancePhone(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsurancePhone and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'InsurancePhone');
            System.assertEquals(strFieldValue, '');

            //InsuranceNamePA
            testMF = SCM_MF_Insurance_Factory.InsuranceNamePA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceNamePA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'RECNAME_Payor');
            System.assertEquals(strFieldValue, '');

            //InsuranceConFullName_PA
            testMF = SCM_MF_Insurance_Factory.InsuranceConFullName_PA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceConFullName_PA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'InsuranceConFullName_PA');
            System.assertEquals(strFieldValue, '');

            //InsuranceStAddress_PA
            testMF = SCM_MF_Insurance_Factory.InsuranceStAddress_PA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceStAddress_PA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'InsuranceStAddress_PA');
            System.assertEquals(strFieldValue, '');

            //InsuranceCityStateZip_PA
            testMF = SCM_MF_Insurance_Factory.InsuranceCityStateZip_PA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceCityStateZip_PA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'InsuranceCityStateZip_PA');
            System.assertEquals(strFieldValue, '');

            //SubscriberID_PA
            testMF = SCM_MF_Insurance_Factory.SubscriberID_PA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : SubscriberID_PA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'SubscriberID_PA');
            System.assertEquals(strFieldValue, '');

            //GroupNum_PA
            testMF = SCM_MF_Insurance_Factory.GroupNum_PA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : GroupNum_PA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'GroupNum_PA');
            System.assertEquals(strFieldValue, '');

            //PolicyNum_PA
            testMF = SCM_MF_Insurance_Factory.PolicyNum_PA(testCase.Id);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : PolicyNum_PA and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'PolicyNum_PA');
            System.assertEquals(strFieldValue, '');

            //InsuranceNameSMN
            testMF = SCM_MF_Insurance_Factory.InsuranceNameSMN(testCase, '1');
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceNameSMN and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'InsuranceNameSMN1');
            System.assertEquals(strFieldValue, '');

            //InsurancePhoneSMN
            testMF = SCM_MF_Insurance_Factory.InsurancePhoneSMN(testCase, '1');
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsurancePhoneSMN and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'InsurancePhoneSMN1');
            System.assertEquals(strFieldValue, '');

            //SubscriberNameSMN
            testMF = SCM_MF_Insurance_Factory.SubscriberNameSMN(testCase, '1');
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : SubscriberNameSMN and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'SubscriberNameSMN1');
            System.assertEquals(strFieldValue, '');

            //GroupNumSMN
            testMF = SCM_MF_Insurance_Factory.GroupNumSMN(testCase, '1');
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : GroupNumSMN and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'GroupNumSMN1');
            System.assertEquals(strFieldValue, '');

            //InsuranceEmployerSMN
            testMF = SCM_MF_Insurance_Factory.InsuranceEmployerSMN(testCase, '1');
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : InsuranceEmployerSMN and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'InsuranceEmployerSMN1');
            System.assertEquals(strFieldValue, '');

    }
}