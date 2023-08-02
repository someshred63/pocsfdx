@isTest
private class GNE_SFA2_FRMAccountDCRControllerTest {
            
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
        GNE_SFA2_DCR_Config_Items_gne__c cit1 = new GNE_SFA2_DCR_Config_Items_gne__c(
            Name = 'HCP Change Address::04', 
            Value_gne__c = 'Name::Address_Line_1_gne__c',
            Key_gne__c = 'HCP_Existing_Address_Typo_Missing_Info',
            Is_Active_gne__c = true,
            Configuration_Type_gne__c = 'FieldMapping'
        );
        GNE_SFA2_DCR_Config_Items_gne__c cit2 = new GNE_SFA2_DCR_Config_Items_gne__c(
            Name = 'HCP Change Address::06', 
            Value_gne__c = 'City_vod__c::City_gne__c',
            Key_gne__c = 'HCP_Existing_Address_Typo_Missing_Info',
            Is_Active_gne__c = true,
            Update_Parent_gne__c = true,
            Configuration_Type_gne__c = 'FieldMapping'
        );
        GNE_SFA2_DCR_Config_Items_gne__c cit3 = new GNE_SFA2_DCR_Config_Items_gne__c(
            Name = 'HCP Change Address::05', 
            Value_gne__c = 'Zip_vod__c::Zip_gne__c',
            Key_gne__c = 'HCP_Existing_Address_Typo_Missing_Info',
            Is_Active_gne__c = true,
            Configuration_Type_gne__c = 'FieldMapping'
        );
        GNE_SFA2_DCR_Config_Items_gne__c cit4 = new GNE_SFA2_DCR_Config_Items_gne__c(
            Name = 'HCP Change Address::07', 
            Value_gne__c = 'State_vod__c::State_gne__c',
            Key_gne__c = 'HCP_Existing_Address_Typo_Missing_Info',
            Is_Active_gne__c = true,
            Configuration_Type_gne__c = 'FieldMapping'
        );
        insert new List<GNE_SFA2_DCR_Config_Items_gne__c> {cit, cit1, cit2, cit3, cit4};
    }
    
    /**
     * initial test to test all getters
     */ 
    @isTest
    static void initTest() {
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
            dcrContr.RequestRecordType = 'HCOChangeInfo';
            dcrContr.chooseRecordType();
            System.assertEquals(true, dcrContr.getAccountActive());
            System.assertEquals(false, dcrContr.getHCOReactivateInactivate());
            System.assertEquals(false, dcrContr.getIsAddresSelectorVisible());
            System.assert(dcrContr.getLabelForDCRRequest().contains('Use this request to identify a location change'));
            dcrContr.getOrganizationTypes();
            dcrContr.RequestRecordType = 'HCODuplicate';
            dcrContr.chooseRecordType();
            System.assert(dcrContr.getLabelForDCRRequest().contains('Select up to five different Organizations that should be merged'));
            dcrContr.RequestRecordType = 'HCOReactivate';
            dcrContr.chooseRecordType();
            System.assert(dcrContr.getLabelForDCRRequest().contains('When necessary, select the reason for the request and select'));
        Test.stopTest();        
    }
    
    @isTest
    static void testSelectAddress(){
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        GNE_FRM_TestData.ForFRMAccountDCRControllerTest testData = new GNE_FRM_TestData.ForFRMAccountDCRControllerTest();

        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
            GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
            dcrContr.RequestRecordType = 'HCOChangeInfo';
            dcrContr.chooseRecordType();
            dcrContr.selectedAddressId = [SELECT Id FROM Address_vod__c LIMIT 1].Id;
            dcrContr.selectAddress();
        Test.stopTest(); 
        
        System.assertEquals(false, dcrContr.getIsAddresSelectorVisible());
        System.assertEquals('514 East Alvin Avenue', dcrContr.selectedAddress.Name);
    }
    
    /**
     * scenario: Change Organization Info
     * change value for address and Account
     * We expect: 2 DCR will be created (one for Address, one for Account)
     */ 
    @isTest
    static void testHCOChangeInfo2DCR(){
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);
        GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
        dcrContr.RequestRecordType = 'HCOChangeInfo';
        dcrContr.chooseRecordType();
        
        Test.startTest();
            dcrContr.changeRequest.Account_Group_gne__c = 'TEST GROUP';
            dcrContr.changeRequest.Address_Line_1_gne__c = '517 East Alvin Avenue';
            dcrContr.saveRequests();
        Test.stopTest();        
        
        List<Change_Request_gne__c> dcrs = [
            SELECT Id, RecordType.Name, Address_Line_2_gne__c, Account_gne__c, Account_Group_gne__c 
            FROM Change_Request_gne__c
        ]; 
        System.assertEquals(2, dcrs.size());
        for(Change_Request_gne__c cr : dcrs){
            if(cr.Account_Group_gne__c == 'TEST GROUP'){
                System.assertEquals('HCO Change Organization Info', cr.RecordType.Name);
            } else {
                System.assertEquals('HCO Change Address', cr.RecordType.Name);
            }
        }
    }
    
    /*
     * scenario: Change Organization Info
     * change value for Account only.
     * We expect: 1 DCR will be created (only for Account)
     */ 
    @isTest
    static void testHCOChangeInfo_AccountReq() {
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);
        GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
        dcrContr.RequestRecordType = 'HCOChangeInfo';
        dcrContr.chooseRecordType();
        
        Test.startTest();
            dcrContr.changeRequest.Account_Group_gne__c = 'TEST GROUP';
            dcrContr.saveRequests();
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
    
    /*
     * scenario: Change Organization Info
     * change value for Address only.
     * We expect: 1 DCR will be created (only for Address)
     */ 
    @isTest
    static void testHCOChangeInfo_AddressReq() {
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);
        GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
        dcrContr.RequestRecordType = 'HCOChangeInfo';
        dcrContr.chooseRecordType();
        
        Test.startTest();
            dcrContr.changeRequest.Address_Line_1_gne__c = '517 East Alvin Avenue';
            dcrContr.saveRequests();
        Test.stopTest();        
        
        List<Change_Request_gne__c> dcrs = [
            SELECT Id, RecordType.Name, Address_Line_2_gne__c, Account_gne__c, Account_Group_gne__c 
            FROM Change_Request_gne__c
        ]; 
        System.assertEquals(1, dcrs.size());
        for(Change_Request_gne__c cr : dcrs){
            System.assertEquals('HCO Change Address', cr.RecordType.Name);
        }
    }
    
    /*
     * Negative scenario: Change Organization Info
     * NO changes!
     * We expect: user will see Message
     */ 
    @isTest
    static void test_NO_Changes_Detected() {
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);
        GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
        dcrContr.RequestRecordType = 'HCOChangeInfo';
        dcrContr.chooseRecordType();
        
        Test.startTest();
            dcrContr.saveRequests();
        Test.stopTest();     
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        Boolean isError = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Please change at least one attribute for your data change request.')){
                isError = true;
            }
        }
        System.assert(isError);
        
        List<Change_Request_gne__c> dcrs = [
            SELECT Id, RecordType.Name, Address_Line_2_gne__c, Account_gne__c, Account_Group_gne__c 
            FROM Change_Request_gne__c
        ]; 
        System.assertEquals(0, dcrs.size());
    }
    
    /*
     * scenario: Remove Duplicate Organization
     * add two accounts to remove
     * We expect: 1 DCR will be created 
     */ 
    @isTest
    static void testRemove_Duplicate_Organization() {
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        Account duplicateAccount01 = GNE_FRM_TestUtilities.createAccount('dupTest acc1', 'FRM_HCO', 'Clinic', false);
        Account duplicateAccount02 = GNE_FRM_TestUtilities.createAccount('dupTest acc2', 'FRM_HCO', 'Clinic', false);
        insert new List<Account> {duplicateAccount01, duplicateAccount02};
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);
        GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
        dcrContr.RequestRecordType = 'HCODuplicate';
        dcrContr.chooseRecordType();
        
        Test.startTest();   
            dcrContr.changeRequest.Duplicate_Account_2_gne__c = duplicateAccount01.Id;
            dcrContr.changeRequest.Duplicate_Account_3_gne__c = duplicateAccount02.Id;
            dcrContr.saveRecord();
        Test.stopTest();     
                
        List<Change_Request_gne__c> dcrs = [
            SELECT Id, RecordType.Name, Duplicate_Account_2_gne__c, Duplicate_Account_3_gne__c
            FROM Change_Request_gne__c
        ]; 
        System.assertEquals(1, dcrs.size());
        System.assertEquals(duplicateAccount01.Id, dcrs[0].Duplicate_Account_2_gne__c);
        System.assertEquals(duplicateAccount02.Id, dcrs[0].Duplicate_Account_3_gne__c);
        System.assertEquals('HCO Remove Duplicate Organization', dcrs[0].RecordType.Name);
    }
    
    /*
     * scenario: Inactivate/Reactivate Organization
     * Account is active
     * We expect: 1 DCR will be created 
     */ 
    @isTest
    static void testInactivateOrg() {
        Account baseAccount = [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];

        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);
        GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
        dcrContr.RequestRecordType = 'HCOReactivate';
        dcrContr.chooseRecordType();
        
        Test.startTest();  
            System.assertEquals(true, dcrContr.getHCOReactivateInactivate());
            System.assertEquals(true, dcrContr.getAccountActive()); 
            dcrContr.changeRequest.Reason_dcr_gne__c = 'Organization has closed';
            dcrContr.saveRecord();
        Test.stopTest();     
                
        List<Change_Request_gne__c> dcrs = [
            SELECT Id, RecordType.Name, Duplicate_Account_2_gne__c, Duplicate_Account_3_gne__c, Reason_dcr_gne__c 
            FROM Change_Request_gne__c
        ]; 

        System.assertEquals(1, dcrs.size());
        System.assertEquals('Organization has closed', dcrs[0].Reason_dcr_gne__c);
        System.assertEquals('HCO Remove/Inactivate Organization', dcrs[0].RecordType.Name);
    }
    
     /*
     * scenario: Inactivate/Reactivate Organization
     * Account is Inactivate
     * We expect: 1 DCR will be created 
     */ 
    @isTest
    static void testReactivateOrg() {
        Account baseAccount = [
            SELECT Id, MDMID_Status_gne__c
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        baseAccount.MDMID_Status_gne__c = 'Inactive';
        update baseAccount;

        PageReference pageRef = new PageReference('/apex/GNE_SFA2_FRMAccountDCR?id='+baseAccount.Id);
        Test.setCurrentPage(pageRef);
        GNE_SFA2_FRMAccountDCRController dcrContr = new GNE_SFA2_FRMAccountDCRController(new ApexPages.StandardController(baseAccount));
        dcrContr.RequestRecordType = 'HCOReactivate';
        dcrContr.chooseRecordType();
        
        Test.startTest();  
            System.assertEquals(true, dcrContr.getHCOReactivateInactivate());
            System.assertEquals(false, dcrContr.getAccountActive()); 
            dcrContr.saveRecord();
        Test.stopTest();     
                
        List<Change_Request_gne__c> dcrs = [
            SELECT Id, RecordType.Name, Duplicate_Account_2_gne__c, Duplicate_Account_3_gne__c, Reason_dcr_gne__c 
            FROM Change_Request_gne__c
        ]; 

        System.assertEquals(1, dcrs.size());
        System.assertEquals('Re-acivate HCO', dcrs[0].Reason_dcr_gne__c);
        System.assertEquals('HCO Reactivate Account', dcrs[0].RecordType.Name);
    }
}