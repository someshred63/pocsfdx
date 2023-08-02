@isTest
private class GNE_SFA2_AccountDCRControllerTest {
    @testSetup
    private static void initData(){
        Account baseAccount = GNE_FRM_TestUtilities.createAccount('Test acc', 'FRM_HCO', 'Clinic', false);
        baseAccount.MDMID_Status_gne__c = GNE_SFA2_FRMAccountDCRController.ACCOUNT_MDM_STATUS_ACTIVE;
        insert new List<Account> {baseAccount};
            
        Address_vod__c baseAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', baseAccount.Id, 'SANTA MARIA', 'CA', '93454', false);
        insert new List<Address_vod__c> {baseAddress};
        
        GNE_SFA2_DCR_Config_Items_gne__c cit = new GNE_SFA2_DCR_Config_Items_gne__c(
            Name = 'AddressDcrFields', 
            Value_gne__c = 'Name,City_vod__c,State_vod__c,Zip_vod__c',
            Key_gne__c = 'AddressDcrFields',
            Is_Active_gne__c = true,
            Configuration_Type_gne__c = 'Main'
        );
        insert new List<GNE_SFA2_DCR_Config_Items_gne__c> {cit};
    }
    
    /**
     * initial test to test all getters
     */ 
    @isTest
    static void initTest() {
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_AccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            GNE_SFA2_AccountDCRController dcrContr = new GNE_SFA2_AccountDCRController(new ApexPages.StandardController(baseAccount));      	
            System.assertEquals('nullid='+baseAccount.Id+'<br>', dcrContr.getParameters());
            System.assertEquals(true, dcrContr.getDCRRequestTypes());
            System.assertEquals(false, dcrContr.getHasCanadaProfile());
            System.assertEquals('', dcrContr.getRequestLabelDisplayText());
            System.assertEquals(false, dcrContr.getHCPDCRRequestTypes());
            System.assertEquals(true, dcrContr.getHCODCRRequestTypes());
            System.assertEquals(false, dcrContr.getHCPChangeInfo());
            System.assertEquals(false, dcrContr.getHCPDuplicate());
            System.assertEquals(false, dcrContr.getHCPInactivate());
            System.assertEquals(false, dcrContr.getHCPReactivate());
            System.assertEquals(false, dcrContr.getHCOChangeInfo());
            System.assertEquals(false, dcrContr.getHCODuplicate());
            System.assertEquals(false, dcrContr.getHCOInactivate());
            dcrContr.RequestRecordType = 'HCPChangeInfo';
            dcrContr.selectRecordType();
       	 	dcrContr.RequestRecordType = 'HCPDuplicate';
            dcrContr.selectRecordType();
        	dcrContr.RequestRecordType = 'HCPInactivate';
            dcrContr.selectRecordType();
        	dcrContr.RequestRecordType = 'HCPChangeInfo';
            dcrContr.selectRecordType();
        	dcrContr.RequestRecordType = 'HCPReactivate';
            dcrContr.selectRecordType();
        	dcrContr.RequestRecordType = 'HCOInactivate';
            dcrContr.selectRecordType();
            dcrContr.RequestRecordType = 'HCODuplicate';
        	dcrContr.selectRecordType();
        	dcrContr.RequestObjectType = 'Person Account';
            dcrContr.RequestRecordType = 'HCOChangeInfo';
        	dcrContr.selectRecordType();
            dcrContr.RequestRecordType = 'Address';
        	dcrContr.selectRecordType();
            
            Account accTemp = dcrContr.getAccount();
            System.assertEquals(baseAccount.Id, accTemp.Id);
        	System.assertEquals(false, dcrContr.getIsAccountAMSStewarded());
            Change_Request_gne__c chRq = dcrContr.getChangeRequest();
        	System.assertEquals(baseAccount.Id, chRq.account_gne__c);
            dcrContr.getAccountTypeValues();
            dcrContr.getCredentialsValues();
            dcrContr.getSpecialtiesValues();

            String acctInfo = '<b>Created By:</b> '            +   
                           baseAccount.createdBy.FirstName    + ' ' + 
                           baseAccount.createdBy.LastName     + '. ' +
                           '<b>Created Date:</b> '          +
                           baseAccount.createdDate         + ' (<b>SFDC Id:</b> '+ 
                           baseAccount.Id                  + ')' ; 
            System.assertEquals(acctInfo, dcrContr.getAccount1Info());
            System.assertEquals('', dcrContr.getAccount2Info());
        	System.assertEquals('', dcrContr.getAccount3Info());
            System.assertEquals('', dcrContr.getAccount4Info());
        	System.assertEquals('', dcrContr.getAccount5Info());     
        
            System.assertEquals('DCR', dcrContr.getActiveMenuItem() ); 
            dcrContr.getOrgTypes();
            GNE_SFA2_AccountDCRController.getOrgTypesMap();
            dcrContr.getProfTypes();
        Test.stopTest();        
    }
    
    @isTest
    static void initTestForCanadianUser() {
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User canadianUser = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), true); 
        insert new GNE_SFA2_Canadian_Users__c(Name = 'System Administrator', GNE_SFA2_Profile_Name__c = 'System Administrator');
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_AccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            System.runAs(canadianUser){
            GNE_SFA2_AccountDCRController dcrContr = new GNE_SFA2_AccountDCRController(new ApexPages.StandardController(baseAccount));    
        	GNE_SFA2_AccountDCRController.getOrgTypesMap();
        	GNE_SFA2_AccountDCRController.getProfTypesMap();
            }            
        Test.stopTest(); 
    }
    
    @isTest
    static void testConfirm() {
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User canadianUser = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), true); 
        insert new GNE_SFA2_Canadian_Users__c(Name = 'System Administrator', GNE_SFA2_Profile_Name__c = 'System Administrator');
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_AccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            GNE_SFA2_AccountDCRController dcrContr = new GNE_SFA2_AccountDCRController(new ApexPages.StandardController(baseAccount));    
        	dcrContr.RequestRecordType = 'HCOChangeInfo';
            dcrContr.selectRecordType();
            dcrContr.changeRequest.New_Organization_Name_gne__c = 'Name Changed';
        	dcrContr.confirm();
        Test.stopTest(); 
        List<Change_Request_gne__c> dcrs = [
            SELECT Id, RecordType.Name, Address_Line_2_gne__c, Account_gne__c, Account_Group_gne__c 
            FROM Change_Request_gne__c
        ];
        System.assertEquals(1, dcrs.size());
        for(Change_Request_gne__c cr : dcrs){
            System.assertEquals('HCO Change Organization Info', cr.RecordType.Name);
        }
    }
    
    @isTest
    static void testCancel() {
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User canadianUser = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), true); 
        insert new GNE_SFA2_Canadian_Users__c(Name = 'System Administrator', GNE_SFA2_Profile_Name__c = 'System Administrator');
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_AccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            GNE_SFA2_AccountDCRController dcrContr = new GNE_SFA2_AccountDCRController(new ApexPages.StandardController(baseAccount));    
        	dcrContr.RequestRecordType = 'HCOChangeInfo';
            dcrContr.selectRecordType();
        	dcrContr.cancel();
        Test.stopTest(); 
        System.assertEquals('/apex/GNE_SFA2_AccountDCR?id='+baseAccount.Id, ApexPages.currentPage().getURL());
        
    }
}