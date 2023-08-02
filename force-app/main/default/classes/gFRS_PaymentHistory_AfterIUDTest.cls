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
private class gFRS_PaymentHistory_AfterIUDTest {
    
    @isTest(SeeAllData=true)
    static void changeFRStatusAfterUpdSAPDocIDTest() {
         
         GFRS_Funding_Request__c objRequest;
         
         SetUpTestObjects testObjects = new  SetUpTestObjects();
         
         Test.startTest();
         system.debug('Check is objRequestLOASigned');
         System.assertEquals('Yes',testObjects.objRequestLOASigned.LOA_Signed__c);
         system.debug('Check is objRequestLOANotSigned');
         System.assertEquals(null,testObjects.objRequestLOANotSigned.LOA_Signed__c);
         
         testObjects.objPaymentHistLOASigned.SAP_Doc_ID__c ='1234567';
         update testObjects.objPaymentHistLOASigned;
         objRequest = [select Id, Sub_Status__c from GFRS_Funding_Request__c where Id=: testObjects.objPaymentHistLOASigned.Grant__c];
         System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES, objRequest.Sub_Status__c);
         
         testObjects.objPaymentHistLOANotSigned.SAP_Doc_ID__c ='9876543';
         update testObjects.objPaymentHistLOANotSigned;
         objRequest = [select Id, Sub_Status__c from GFRS_Funding_Request__c where Id=: testObjects.objPaymentHistLOANotSigned.Grant__c];
         System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA, objRequest.Sub_Status__c);
         
         system.debug('Negative test.');
         testObjects.objPaymentHistHCCHAR.SAP_Doc_ID__c ='9876543';
         update testObjects.objPaymentHistHCCHAR;
         objRequest = [select Id, Sub_Status__c from GFRS_Funding_Request__c where Id=: testObjects.objPaymentHistHCCHAR.Grant__c];
         System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_PAYMENT, objRequest.Sub_Status__c);
         
         Test.stopTest();
    }
    
    private class SetUpTestObjects
    {
        public Account objAccount;
        public Contact objContact;
        public User objUser;
        
        public List<GFRS_Funding_Request__c> objListRequest = new List<GFRS_Funding_Request__c>();
        public GFRS_Funding_Request__c objRequestLOASigned;
        public GFRS_Funding_Request__c objRequestLOANotSigned;
        public GFRS_Funding_Request__c objRequestHCCHAR;// for negative test
        
        public List<GFRS_Payment_History__c> objPaymentHist = new List<GFRS_Payment_History__c>();
        public GFRS_Payment_History__c objPaymentHistLOASigned;
        public GFRS_Payment_History__c objPaymentHistLOANotSigned;
        public GFRS_Payment_History__c objPaymentHistHCCHAR; //for negative test
        
        
        public GFRS_Organization__c objOrg;
        public GFRS_Location__c objLoc;
        
        public SetUpTestObjects()
        {
            String gFRSAccountRecordTypeId = [select id from RecordType where SobjectType = 'Account' and Name='gFRS'].id;
            this.objAccount = new Account( Name = gFRS_TestCreationUtils.makeUnique( 'accTest' ), RecordTypeId = gFRSAccountRecordTypeId);
            insert this.objAccount;
            
            this.objOrg = gFRS_TestCreationUtils.createOrganization2( '66-1298349', this.objAccount.id );
            upsert this.objOrg;
            
            this.objLoc = gFRS_TestCreationUtils.createLocation( 'accTestLocation', this.objOrg.id );
            insert this.objloc;
            
            //objContact = gFRS_TestCreationUtils.createContact(objAccount);
            
            objContact = new Contact(
            FirstName = 'Test',
            LastName = 'Test',
            Email = 'test@test.com',
            Phone = '555-555-555',
            AccountID = objAccount.Id
            );
            
            insert objContact;
            
            objUser = gFRS_TestCreationUtils.createUser(objContact, 'test2@test.com');
            insert objUser;
            
            objRequestLOASigned = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS,'Breast Cancer', '', '', objOrg.id, objLoc.id );
            objRequestLOASigned.Status__c  = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
            objRequestLOASigned.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
            objRequestLOASigned.LOA_Signed__c='Yes';
            objListRequest.Add(objRequestLOASigned);
            
            objRequestLOANotSigned = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS,'Asthma', '', '', objOrg.id, objLoc.id );
            objRequestLOANotSigned.Status__c  = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
            objRequestLOANotSigned.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA;
            objListRequest.Add(objRequestLOANotSigned);
            
            objRequestHCCHAR = gFRS_TestCreationUtils.createFundingRequestWithTA(gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS,'Asthma', '', '', objOrg.id, objLoc.id );
            objRequestHCCHAR.Status__c  = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
            objRequestHCCHAR.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
            objListRequest.Add(objRequestHCCHAR);
            
            insert objListRequest;
            
            objPaymentHistLOASigned = gFRS_TestCreationUtils.createFullPayment(objRequestLOASigned.Id,objRequestLOASigned.Name);
            objPaymentHist.add(objPaymentHistLOASigned);
            objPaymentHistLOANotSigned = gFRS_TestCreationUtils.createFullPayment(objRequestLOANotSigned.Id,objRequestLOANotSigned.Name);
            objPaymentHist.add(objPaymentHistLOANotSigned);
            objPaymentHistHCCHAR = gFRS_TestCreationUtils.createFullPayment(objRequestHCCHAR.Id,objRequestHCCHAR.Name);
            objPaymentHist.add(objPaymentHistHCCHAR);
            
            insert objPaymentHist;
        }
    }
}