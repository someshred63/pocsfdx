@isTest
private class GNE_SFA2_AddressDCRController_Test {
	
    private static String DCR_REQUEST_TYPE = 'DCRRequestType';
    private static String DCR_REMOVE_ADDR = 'RemoveAddress';
    private static String TEST_ADDR_NAME = '514 East Alvin Avenue';
    private static String TEST_ADDR_CITY = 'SANTA MARIA';
    private static String TEST_ADDR_STATE = 'CA';
    private static String TEST_ADDR_ZIP = '93454';

    @testSetup
    static void dataSetup() {
    	Account baseAccount = GNE_FRM_TestUtilities.createAccount('Test acc', 'FRM_HCO', 'Clinic', false);
        baseAccount.MDMID_Status_gne__c = GNE_SFA2_FRMAccountDCRController.ACCOUNT_MDM_STATUS_ACTIVE;
        insert new List<Account> {baseAccount};
            
        Address_vod__c baseAddress = GNE_FRM_TestUtilities.createAddress(TEST_ADDR_NAME, baseAccount.Id, TEST_ADDR_CITY, TEST_ADDR_STATE, TEST_ADDR_ZIP, false);
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

	@isTest
    public static void initTest() {
    	Address_vod__c testAddress = [SELECT Account_vod__c, Address_1_gne__c, Active_Flag_gne__c, Name FROM Address_vod__c WHERE Name =: TEST_ADDR_NAME LIMIT 1];
    	
    	PageReference pr = Page.GNE_SFA2_AddressDCR;
		pr.getParameters().put(DCR_REQUEST_TYPE, DCR_REMOVE_ADDR);
		Test.setCurrentPage(pr);

		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testAddress);
		GNE_SFA2_AddressDCRController testCtrl = new GNE_SFA2_AddressDCRController(stdCtrl);

			System.assertEquals(false, testCtrl.getDCRRequestTypes());
            System.assertEquals(false, testCtrl.getHasCanadaProfile());
            System.assertNotEquals('', testCtrl.getRequestLabelDisplayText());
            System.assertEquals(false, testCtrl.getNonAMSHCODCRRequestTypes());
            System.assertEquals(true, testCtrl.getNonAMSHCORemoveAddress());
			System.assertEquals(false, testCtrl.getHCPChangeAddress());
			System.assertEquals(false, testCtrl.getHCPRemoveAddress());
			System.assertEquals(false, testCtrl.getAMSHCOChangeAddress());
			System.assertEquals(false, testCtrl.getAMSHCORemoveAddress());
			System.assertEquals(false, testCtrl.getNonAMSHCOChangeAddress());
			System.assertEquals(false, testCtrl.getHCPRemoveDuplicateAddress());
			System.assertEquals(false, testCtrl.getHCPReactivateAddress());
            testCtrl.RequestRecordType = 'HCPChangeAddress';
            testCtrl.selectRecordType();
       	 	testCtrl.RequestRecordType = 'HCPRemoveAddress';
            testCtrl.selectRecordType();
        	testCtrl.RequestRecordType = 'HCPRemoveDuplicateAddress';
            testCtrl.selectRecordType();
        	testCtrl.RequestRecordType = 'HCPReactivateAddress';
            testCtrl.selectRecordType();
        	testCtrl.RequestRecordType = 'AMSHCOChangeAddress';
            testCtrl.selectRecordType();
        	testCtrl.RequestRecordType = 'AMSHCORemoveAddress';
            testCtrl.selectRecordType();
            testCtrl.RequestRecordType = 'NonAMSHCOChangeAddress';
        	testCtrl.selectRecordType();
            testCtrl.RequestRecordType = 'NonAMSHCORemoveAddress';
        	testCtrl.selectRecordType();
            
			System.assertEquals(testAddress.Account_vod__c, testCtrl.getAccount().Id);
        	System.assertEquals(false, testCtrl.getIsAccountAMSStewarded());
        	System.assertEquals('DCR', testCtrl.getActiveMenuItem());
        	System.assertNotEquals(null, testCtrl.getAddress1Info());
			System.assertEquals('', testCtrl.getAddress2Info());
			System.assertEquals('', testCtrl.getAddress3Info());
    }

    @isTest
    public static void confirmTest() {
    	Address_vod__c testAddress = [SELECT Account_vod__c, Address_1_gne__c, Active_Flag_gne__c, Name FROM Address_vod__c WHERE Name =: TEST_ADDR_NAME LIMIT 1];
    	
    	PageReference pr = Page.GNE_SFA2_AddressDCR;
		pr.getParameters().put(DCR_REQUEST_TYPE, DCR_REMOVE_ADDR);
		Test.setCurrentPage(pr);

		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testAddress);
		GNE_SFA2_AddressDCRController testCtrl = new GNE_SFA2_AddressDCRController(stdCtrl);
		
		System.assertNotEquals(null, testCtrl.confirm());
    }

    @isTest
    public static void cancelTest() {
    	Address_vod__c testAddress = [SELECT Account_vod__c, Address_1_gne__c, Active_Flag_gne__c, Name FROM Address_vod__c WHERE Name =: TEST_ADDR_NAME LIMIT 1];
    	
    	PageReference pr = Page.GNE_SFA2_AddressDCR;
		pr.getParameters().put(DCR_REQUEST_TYPE, DCR_REMOVE_ADDR);
		Test.setCurrentPage(pr);

		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(testAddress);
		GNE_SFA2_AddressDCRController testCtrl = new GNE_SFA2_AddressDCRController(stdCtrl);

		System.assertNotEquals(null, testCtrl.cancel());
    }
}