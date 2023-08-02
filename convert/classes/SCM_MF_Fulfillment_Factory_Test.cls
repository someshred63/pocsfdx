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
private class SCM_MF_Fulfillment_Factory_Test {

    static testMethod void myUnitTest() {
       //Factory Test Class
       SCM_MergeField testMF = new SCM_MergeField();
       String strKey ='';
       String strFieldValue ='';
            
       Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Herceptin');
       String caseId = testCase.Id;
       System.debug('Case Id in test case: ' + caseId);
            
       //DispensingCenter
       testMF = SCM_MF_Fulfillment_Factory.DispensingCenter(caseId);
       strKey = testMF.getKey();
       strFieldValue = testMF.getFieldValue();
       System.debug('1. Method Name : DispensingCenter and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
       System.assertEquals(strKey, 'Dispensing Center');
       System.assertEquals(strFieldValue, 'DistFirst DistLast');

       //DispensingCenter
       testMF = SCM_MF_Fulfillment_Factory.DispensingCenter(caseId);
       strKey = testMF.getKey();
       strFieldValue = testMF.getFieldValue();
       System.debug('1. Method Name : DispensingCenter and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
       System.assertEquals(strKey, 'Dispensing Center');
       System.assertEquals(strFieldValue, 'DistFirst DistLast');

       //DispensingCenter_TextBox
       testMF = SCM_MF_Fulfillment_Factory.DispensingCenter_TextBox(caseId);
       strKey = testMF.getKey();
       strFieldValue = testMF.getFieldValue();
       System.debug('1. Method Name : DispensingCenter and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
       System.assertEquals(strKey, 'ATTN_Attn');
       System.assertEquals(testMF.displayLabel, true);
       System.assertEquals(testMF.displayTextbox, true);
       System.assertEquals(testMF.label, 'Attn:');
       System.assertEquals(strFieldValue, '');

       //DispensingContactPhone
       testMF = SCM_MF_Fulfillment_Factory.DispensingContactPhone(caseId);
       strKey = testMF.getKey();
       strFieldValue = testMF.getFieldValue();
       System.debug('1. Method Name : DispensingContactPhone and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
       System.assertEquals(strKey, 'DispensingContactPhone');
       System.assertEquals(strFieldValue, '');

       //DispensingContactName
       testMF = SCM_MF_Fulfillment_Factory.DispensingContactName(caseId);
       strKey = testMF.getKey();
       strFieldValue = testMF.getFieldValue();
       System.debug('1. Method Name : DispensingContactName and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
       System.assertEquals(strKey, 'DispensingContactName');
       System.assertEquals(strFieldValue, '');

       //FulFillmentFaxNumber
       testMF = SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber(caseId);
       strKey = testMF.getKey();
       strFieldValue = testMF.getFieldValue();
       System.debug('1. Method Name : FulFillmentFaxNumber and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
       System.assertEquals(strKey, 'RECFAX_Fax');
       System.assertEquals(testMF.displayLabel, true);
       System.assertEquals(testMF.displayTextbox, true);
       System.assertEquals(testMF.label, 'Fax:');
       System.assertEquals(strFieldValue, '');

        //FulfillmentAddressTo
       testMF = SCM_MF_Fulfillment_Factory.FulfillmentAddressTo(caseId);
       strKey = testMF.getKey();
       strFieldValue = testMF.getFieldValue();
       System.debug('1. Method Name : FulfillmentAddressTo and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
       System.assertEquals(strKey, 'RECNAME_To');
       System.assertEquals(testMF.displayLabel, true);
       System.assertEquals(testMF.displayTextbox, true);
       System.assertEquals(testMF.label, 'Addressed To:');
       System.assertEquals(strFieldValue, 'DistFirst DistLast');
        
    }
}