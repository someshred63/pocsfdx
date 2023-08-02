/**
* @author ADMD Team
* @date 2/04/2013
* @description gFRS_UpdateLegacyPaymentHistoryBatchTest class - Unit test class for FRS_UpdateLegacyPaymentHistoryBatch class.
*
*/
@isTest(SeeAllData=true)
private class gFRS_UpdateLegacyPaymentHistoryBatchTest {

    static testMethod void testLegacyPaymentHistoryUpdate() 
    {
        GFRS_Payment_History__c objPaymentHistory;
        GFRS_Funding_Request__c objFR;
        
        //setting up test objects
        SetUpTestObjects testObjects = new SetUpTestObjects();
        
        system.debug('Check is Fundign Request created');
        system.assertEquals((testObjects.frId!=null) ? true : false , true);
        
        system.debug('Get created funding request');
        objFR = [select ID, name from GFRS_Funding_Request__c where id=:testObjects.frId];
        
        system.debug('Get funding allocation record id for FR '+ testObjects.frId);
        Id faId = [ select id from GFRS_Funding_Allocation__c where Grant_Request__c=:testObjects.frId limit 1].id;
        system.assertEquals((testObjects.frId!=null) ? true : false , true);
        
        system.debug('Create payment history record. Without linked with FA. Simulation problem in PROD.');
        
        objPaymentHistory = new GFRS_Payment_History__c(Grant__c=testObjects.frId,Funding_Allocation__c=null);
        objPaymentHistory.SAP_Request_ID__c = objFR.Name + '01';
        objPaymentHistory.Date__c = date.today();
        objPaymentHistory.Payment_Type__c = 'Payment';
        objPaymentHistory.Action__c = 'Payment Sent';
        objPaymentHistory.RecordTypeId = [ SELECT id from RecordType where DeveloperName = 'ReadOnly' and SobjectType = 'GFRS_Payment_History__c'].id;
        objPaymentHistory.Status__c = 'Initialized';
        objPaymentHistory.InvokeType__c = 'UI';
        objPaymentHistory.Amount__c = 100;
        insert objPaymentHistory;
        system.assertEquals((objPaymentHistory.Id!=null) ? true : false , true);
        
        system.debug('Run job gFRS_UpdateLegacyPaymentHistoryBatch()');
        
        Test.startTest();
        gFRS_UpdateLegacyPaymentHistoryBatch batch = new gFRS_UpdateLegacyPaymentHistoryBatch();
        ID batchprocessid = Database.executeBatch(batch);
        Test.stopTest();
        
        system.debug('Get object payment again. Funding_Allocation__c should be populated');
        objPaymentHistory = [select id, Funding_Allocation__c from GFRS_Payment_History__c where id=:objPaymentHistory.id];
        system.assertEquals((objPaymentHistory.Funding_Allocation__c==faId) ? true : false , true);
    }
    
    private class SetUpTestObjects
    {
        public Account objAccount;
        public Contact objContact;
        public User objUser;
        public GFRS_Organization__c objOrg;
        public GFRS_Location__c objLoc;
        
        public id frId; // Funding Request ID
                
        public SetUpTestObjects()
        { 
            this.objAccount = gFRS_UnitTestHelper.CreateAccount('accTest' );            
            this.objContact = gFRS_UnitTestHelper.CreateContact(this.objAccount.Id);
            this.objUser = gFRS_UnitTestHelper.CreatePortalUser(objContact);
            
            System.runAs(this.objUser)
            { 
             this.objOrg = gFRS_UnitTestHelper.createExternalOrganization('01-9191329', this.objAccount.id );
             this.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', this.objOrg.id );
             this.frId = gFRS_UnitTestHelper.CreateIMEDFundingRequest(
             objOrg.id, objLoc.id,'Intake','Not Submitted','Not Submitted','Oncology','Breast Cancer', '' );
            }  
        }
    }
}