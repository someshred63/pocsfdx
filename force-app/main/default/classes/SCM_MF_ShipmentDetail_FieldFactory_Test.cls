// Created By sridhar


@isTest
private class SCM_MF_ShipmentDetail_FieldFactory_Test {
    static testMethod void myUnitTest() {
            //Factory Test Class
            SCM_MergeField testMF = new SCM_MergeField();
            String strKey ='';
            String strFieldValue ='';
            
            Case testCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Lucentis');
           
           
             
            //DocumentNumber      
            testMF = SCM_MF_ShipmentDetail_FieldFactory.DocumentNumber(testCase);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('1. Method Name : DocumentNumber and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Documentnumber');
            System.assertEquals(strFieldValue, '1234');
            
            //PurchaseNumber
            testMF = SCM_MF_ShipmentDetail_FieldFactory.PurchaseNumber(testCase);
            strKey = testMF.getKey();
            strFieldValue = testMF.getFieldValue();
            System.debug('2. Method Name : PurchaseNumber and  Key Returned :'+ strKey + ' FieldValue :' + strFieldValue );
            System.assertEquals(strKey, 'Purchasenumber');
            //System.assertEquals(strFieldValue, 'PO-0010009283'); Cannot test this field as it is auto-generated.
            
            
            
            
            
    }
}