@isTest
private class GNE_SFA2_DCR_Validation_Rules_Test {
    static Map<String,Id> recordTypeName2Id = getRecordTypeName2Id();
    static Map<String,Id> getRecordTypeName2Id(){
        recordTypeName2Id = new Map<String,Id>();
        for(RecordType rt: [
            SELECT DeveloperName, Name, SobjectType 
            FROM RecordType 
			WHERE SobjectType ='Change_Request_gne__c'
        ]){
            recordTypeName2Id.put(rt.DeveloperName, rt.Id);
        }
        return recordTypeName2Id;
    }
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
    
    @isTest
    static void test_InsertDCR(){
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.Account_gne__c = baseAccount.Id;
        Test.startTest();
            insert changeReq;
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Change_Request_gne__c].size());
        System.assertEquals(true,GNE_SFA2_DCR_Validation_Rules.checkPostalCodeFormat('dddff33'));
    }
    
    @isTest 
    static void test_HCO_Change_Organization_Info(){
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.Account_gne__c = baseAccount.Id;
        changeReq.RecordTypeId = recordTypeName2Id.get('HCO_Change_Organization_Info');
        changeReq.New_Organization_Name_gne__c = 'NEW NAME';
        Test.startTest();
            insert changeReq;
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM Change_Request_gne__c].size());        
    }
    
    @isTest 
    static void test_CanadianUser_HCO_Change_Organization_Info_Error(){
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User canadianUser = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), true); 
        insert new GNE_SFA2_Canadian_Users__c(Name = 'System Administrator', GNE_SFA2_Profile_Name__c = 'System Administrator');
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate, Account_type_gne__c
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.Account_gne__c = baseAccount.Id;
        changeReq.RecordTypeId = recordTypeName2Id.get('HCO_Change_Organization_Info');
        changeReq.New_Organization_Name_gne__c = 'Test acc';
        changeReq.account_type_dcr_gne__c = baseAccount.Account_type_gne__c;
        Test.startTest();
        	System.runAs(canadianUser){
                try{
                    insert changeReq;
                } catch(Exception ex){
                    System.debug('+++ '+ex.getMessage());
                    Boolean expectedExceptionThrown =  ex.getMessage().contains('Please change at least one attribute for your data change request') ? true : false;
					System.AssertEquals(true,expectedExceptionThrown);
                }
            }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Change_Request_gne__c].size());        
    }
    
    @isTest 
    static void test_HCO_Change_Organization_Info_Error(){
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate, Account_type_gne__c
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.Account_gne__c = baseAccount.Id;
        changeReq.RecordTypeId = recordTypeName2Id.get('HCO_Change_Organization_Info');
        changeReq.New_Organization_Name_gne__c = 'Test acc';
        changeReq.account_type_dcr_gne__c = baseAccount.Account_type_gne__c;
        Test.startTest();
            try{
                insert changeReq;
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Please change at least one attribute for your data change request') ? true : false;
                System.AssertEquals(true,expectedExceptionThrown);
            }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Change_Request_gne__c].size());        
    }

    @isTest 
    static void test_CanadianUser_HCP_Change_HCP_Info_Error(){
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User canadianUser = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), true); 
        insert new GNE_SFA2_Canadian_Users__c(Name = 'System Administrator', GNE_SFA2_Profile_Name__c = 'System Administrator');
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate, Account_type_gne__c,
                    Language_of_Preference_can_gne__c, Rep_Specialty_can_gne__c
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.Account_gne__c = baseAccount.Id;
        changeReq.RecordTypeId = recordTypeName2Id.get('HCP_Change_HCP_Info');
        changeReq.New_Organization_Name_gne__c = 'Test acc';
        changeReq.account_type_dcr_gne__c = baseAccount.Account_type_gne__c;
       // changeReq.Language_of_Preference_dcr_gne__c = baseAccount.Language_of_Preference_can_gne__c;
        //changeReq.Rep_Specialty_dcr_gne__c = baseAccount.Rep_Specialty_can_gne__c;
        Test.startTest();
        	System.runAs(canadianUser){
                try{
                    insert changeReq;
                } catch(Exception ex){
                    System.debug('+++ '+ex.getMessage());
                    Boolean expectedExceptionThrown =  ex.getMessage().contains('Please change at least one attribute for your data change request') ? true : false;
					System.AssertEquals(true,expectedExceptionThrown);
                }
            }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Change_Request_gne__c].size());
    }
    
    @isTest 
    static void test_HCP_Change_HCP_Info_Error(){
        Account baseAccount = [
            SELECT Id, RecordTypeId, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate, Account_type_gne__c
            FROM Account 
            WHERE Name = 'Test acc' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.Account_gne__c = baseAccount.Id;
        changeReq.RecordTypeId = recordTypeName2Id.get('HCP_Change_HCP_Info');
        changeReq.New_Organization_Name_gne__c = 'Test acc';
        changeReq.account_type_dcr_gne__c = baseAccount.Account_type_gne__c;
        Test.startTest();
            try{
                insert changeReq;
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Please change at least one attribute for your data change request') ? true : false;
                System.AssertEquals(true,expectedExceptionThrown);
            }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Change_Request_gne__c].size());        
    }
    
    //HCO_Change_Address
    @isTest 
    static void test_CanadianUser_HCO_Change_Address_Error(){
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User canadianUser = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), true); 
        insert new GNE_SFA2_Canadian_Users__c(Name = 'System Administrator', GNE_SFA2_Profile_Name__c = 'System Administrator');
        Address_vod__c baseAddress = [
            SELECT Id, City_vod__c, Province_can_gne__c, Postal_Code_can_gne__c, Name
            FROM Address_vod__c
            WHERE Name = '514 East Alvin Avenue' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.RecordTypeId = recordTypeName2Id.get('HCO_Change_Address');
        changeReq.Current_Address_gne__c = baseAddress.Id;
        changeReq.address_line_1_gne__c = baseAddress.name;
        changeReq.city_gne__c = baseAddress.City_vod__c;
        changeReq.Province_can_gne__c = baseAddress.Province_can_gne__c;
        changeReq.Postal_Code_can_gne__c = baseAddress.Postal_Code_can_gne__c;
        Test.startTest();
        	System.runAs(canadianUser){
                try{
                    insert changeReq;
                } catch(Exception ex){
                    System.debug('+++ '+ex.getMessage());
                    Boolean expectedExceptionThrown =  ex.getMessage().contains('Please change at least one attribute for your data change request') ? true : false;
					System.AssertEquals(true,expectedExceptionThrown);
                }
            }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Change_Request_gne__c].size());        
    }
    
    @isTest 
    static void test_HCO_Change_Address_Error(){
        Address_vod__c baseAddress = [
            SELECT Id, City_vod__c, State_vod__c, Zip_vod__c, Name
            FROM Address_vod__c 
            WHERE Name = '514 East Alvin Avenue' LIMIT 1
        ];
        Change_Request_gne__c changeReq = new Change_Request_gne__c();
        changeReq.RecordTypeId = recordTypeName2Id.get('HCO_Change_Address');
        changeReq.Current_Address_gne__c = baseAddress.Id;
        changeReq.address_line_1_gne__c = baseAddress.name;
        changeReq.city_gne__c = baseAddress.City_vod__c;
        changeReq.State_gne__c = baseAddress.State_vod__c; 
        changeReq.Zip_gne__c = baseAddress.Zip_vod__c;
        Test.startTest();
            try{
                insert changeReq;
            } catch(Exception ex){
                Boolean expectedExceptionThrown =  ex.getMessage().contains('Please change at least one attribute for your data change request') ? true : false;
                System.AssertEquals(true,expectedExceptionThrown);
            }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Change_Request_gne__c].size());        
    }
}