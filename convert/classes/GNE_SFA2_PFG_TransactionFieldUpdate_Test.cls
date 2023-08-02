@isTest
private class GNE_SFA2_PFG_TransactionFieldUpdate_Test 
{
    private static final String HO_PROFILE = 'GNE-SFA-Nutropin-Manager';
    private static final String DM_PROFILE = 'GNE-SFA-Nutropin-DM';
    private static final String CS_PROFILE = 'GNE-SFA-Nutropin-CS';
    private static final String SYS_ADMIN = 'System Administrator';
    private static final String TRANSACTION_OBJECT_TYPE = 'SFA2_PFG_Transaction_gne__c';

    // static testMethod void testApprovalProcess() {
    //   User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
    //     insert adminUser;
    //     System.runAs(adminUser) {
    //         Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
    //         Map<String, object> fieldsConfig = new Map<String, object>();

    //         User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
    //         User newCS1 = csUser1;
    //         newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
    //        // newCS1.LOA_Status_gne__c = true;
    //         newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
    //         newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
    //         newCS1.PFG_Uncertified_Flag_gne__c = true;
    //         User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
    //         User newCS2 = csUser2;
    //         newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
    //         //newCS2.LOA_Status_gne__c = true;
    //         newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
    //         newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
    //         newCS2.PFG_Uncertified_Flag_gne__c = true;
    //         User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);

    //         List<sObject> dataToInsert = new List<sObject>();
    //         dataToInsert.add(newCS1);
    //         dataToInsert.add(newCS2);
    //         dataToInsert.add(dmUser);
    //         insert dataToInsert;

    //         objectConfig = new Map<sObject, Map<String, object>>();
    //         fieldsConfig = new Map<String, object>();
    //         fieldsConfig.put('User_gne__c', newCS1.Id);
    //         fieldsConfig.put('Manager_gne__c', dmUser.Id);
    //         fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
    //         fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
    //         fieldsConfig.put('Zip_gne__c', '123456');
    //         fieldsConfig.put('City_gne__c', 'San Francisco');
    //         fieldsConfig.put('State_gne__c', 'CA');
    //         fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
    //         fieldsConfig.put('Status_gne__c', 'Approved');
    //         fieldsConfig.put('Address_Changed_gne__c', true);
    //         objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
    //         SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);

    //         objectConfig = new Map<sObject, Map<String, object>>();
    //         fieldsConfig = new Map<String, object>();
    //         fieldsConfig.put('User_gne__c', newCS2.Id);
    //         fieldsConfig.put('Manager_gne__c', dmUser.Id);
    //         fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
    //         fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
    //         fieldsConfig.put('Zip_gne__c', '123452');
    //         fieldsConfig.put('City_gne__c', 'San Francisco');
    //         fieldsConfig.put('State_gne__c', 'CA');
    //         fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
    //         fieldsConfig.put('Status_gne__c', 'Submitted');

    //         // added by Konrad Maluszkiewicz
    //         fieldsConfig.put('Address_Changed_gne__c', true);


    //         objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
    //         SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
    //         dataToInsert = new List<sObject>();
    //         dataToInsert.add(storageLocation);
    //         dataToInsert.add(storageLocation2);
    //         insert dataToInsert;
    //     }
    // }

    //Allocation Transfer Test Methods
    /*
    static testMethod void testAllocationTransfer()
    {
        //supporting data creation
        //User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
        User testUser = [SELECT id, Name, ManagerId FROM User WHERE Name = 'Sarah Gahman'][0];
           
        insert new GNE_SFA2_PFG_Config_Items_gne__c(Name = 'ActiveBrandsForDTP', Value_gne__c = 'Nutropin;Actemra;');
        IC_Calc_Sales_Roster_gne__c icRoster = new IC_Calc_Sales_Roster_gne__c(Type_gne__c = 'SFA-US');
        insert icRoster;

        List<Brand_2_Salesforce_gne__c> brandsToGetCodes = new List<Brand_2_Salesforce_gne__c>();
        brandsToGetCodes.add(new Brand_2_Salesforce_gne__c(SFA_Brand_Name_gne__c = 'Actemra', CDM_Brand_Code_gne__c = 'ACT', CDM_Salesforce_Code_gne__c = 'RA',
        CDM_Salesforce_SubTeam_Code_gne__c = 'ACTRA'));
        insert brandsToGetCodes;

        SFA2_User_Sales_Roster_gne__c salesRoster = new SFA2_User_Sales_Roster_gne__c(
            User_gne__c = testUser.Id,
            User_gne__r = testUser,
            Role_gne__c = 'CS', 
            Sales_Roster_gne__c = icRoster.Id,
            Sales_Roster_gne__r = icRoster
            );
        insert salesRoster;

        //create sales roster for manager
        User manager = [SELECT Id FROM User WHERE Id = : testUser.ManagerId];
        insert new SFA2_User_Sales_Roster_gne__c(
            User_gne__c = manager.Id,
            User_gne__r = manager,
            Role_gne__c = 'CS', 
            Sales_Roster_gne__c = icRoster.Id,
            Sales_Roster_gne__r = icRoster
            );
      
        SFA2_PFG_Storage_Location_gne__c storageLocatio = new SFA2_PFG_Storage_Location_gne__c(User_gne__c = testUser.Id, User_gne__r = testUser, Status_gne__c = 'Submitted',
            Address_Line_1_gne__c  = 'Test',
            Address_Line_2_gne__c = 'Test',
            Zip_gne__c = 'Test',
            City_gne__c = 'Test',
            State_gne__c = 'Test');
        insert storageLocatio;
        SFA2_PFG_Storage_Location_gne__c addedStorageLocation = [SELECT Id, Status_gne__c FROM SFA2_PFG_Storage_Location_gne__c WHERE Id =: storageLocatio.Id];
        addedStorageLocation.Status_gne__c = 'Approved';
        update addedStorageLocation;

        User newCS1 = testUser;
        newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
        //newCS1.LOA_Status_gne__c = true;
        newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS1.PFG_Uncertified_Flag_gne__c = true;
        User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
        User newCS2 = csUser2;
        newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
        //newCS2.LOA_Status_gne__c = true;
        newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS2.PFG_Uncertified_Flag_gne__c = true;
        User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);

        List<sObject> dataToInsert = new List<sObject>();
        //dataToInsert.add(newCS1);
        dataToInsert.add(newCS2);
        dataToInsert.add(dmUser);
        insert dataToInsert;

        newCS1.ManagerId = dmUser.Id;
        newCS2.ManagerId = dmUser.Id;
        
        List<sObject> dataToUpdate = new List<sObject>();
        ////////////////dataToUpdate.add(newCS1);
        dataToUpdate.add(newCS2);
        update dataToUpdate;
        User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
        insert adminUser;
        System.runAs(adminUser)
        {
            Test.startTest();
            Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
            Map<String, object> fieldsConfig = new Map<String, object>();
            
            Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
    
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('User_Role_gne__c', 'CS');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_CS = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('User_Role_gne__c', 'DM');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_DM = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(product);
            dataToInsert.add(icCalcSR_CS);
            dataToInsert.add(icCalcSR_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS1.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS2.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS2 = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('Role_gne__c','DM');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_DM.Id);
            fieldsConfig.put('User_gne__c', dmUser.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_DM = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(salesRoster_CS);
            dataToInsert.add(salesRoster_CS2);
            dataToInsert.add(salesRoster_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS2.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
            fieldsConfig.put('Zip_gne__c', '123452');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Submitted');
            fieldsConfig.put('Address_Changed_gne__c', true);
            fieldsConfig.put('Status_gne__c', 'Approved');

            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(storageLocation);
            dataToInsert.add(storageLocation2);
            insert dataToInsert;
            
            //transaction creation
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Requested_Quantity_gne__c',100);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Generate_Shipment_Flag__c', GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED);
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction;
            List<SFA2_PFG_Transaction_gne__c> transactions = [Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ];
            System.debug('SEG test address line: '+transactions[0].Address_Line_1_gne__c);
            System.debug('SEG test address line 2: '+transactions[0].Address_Line_2_gne__c);
            system.assertEquals('Test Address Line 1', transactions[0].Address_Line_1_gne__c);
            system.assertEquals('Test Address Line 2', transactions[0].Address_Line_2_gne__c);
            system.assertEquals('San Francisco', transactions[0].City_gne__c);
            system.assertEquals('123456', transactions[0].Zip_gne__c);
            system.assertEquals('CA', transactions[0].State_gne__c);
            system.assertEquals(true, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(true, transactions[0].To_CS_Uncertified_Flag_gne__c);
            
            newCS1.LOA_HO_Override_Flag_gne__c = 'True';
            newCS2.LOA_HO_Override_Flag_gne__c = 'True';
            dataToUpdate = new List<sObject>();
            dataToUpdate.add(newCS1);
            dataToUpdate.add(newCS2);
            update dataToUpdate;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Requested_Quantity_gne__c',100);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Generate_Shipment_Flag__c', GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED);
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction2 = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction2;
    
            transactions = new List<SFA2_PFG_Transaction_gne__c>([Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction2.Id
                                                             ]);
            system.assertEquals('Test Address Line 1', transactions[0].Address_Line_1_gne__c);
            system.assertEquals('Test Address Line 2', transactions[0].Address_Line_2_gne__c);
            system.assertEquals('San Francisco', transactions[0].City_gne__c);
            system.assertEquals('123456', transactions[0].Zip_gne__c);
            system.assertEquals('CA', transactions[0].State_gne__c);
            system.assertEquals(true, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(true, transactions[0].To_CS_Uncertified_Flag_gne__c);
            
            newCS1.LOA_HO_Override_Flag_gne__c = 'False';
            newCS2.LOA_HO_Override_Flag_gne__c = 'False';
            newCS1.PFG_Uncertified_Flag_gne__c = false;
            newCS2.PFG_Uncertified_Flag_gne__c = false;
            dataToUpdate = new List<sObject>();
            dataToUpdate.add(newCS1);
            dataToUpdate.add(newCS2);
            update dataToUpdate;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Requested_Quantity_gne__c',100);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Generate_Shipment_Flag__c', GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_NOT_INITIATED);
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction3 = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction3;
            
            transactions = new List<SFA2_PFG_Transaction_gne__c>([Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction3.Id
                                                             ]);
            system.assertEquals('Test Address Line 1', transactions[0].Address_Line_1_gne__c);
            system.assertEquals('Test Address Line 2', transactions[0].Address_Line_2_gne__c);
            system.assertEquals('San Francisco', transactions[0].City_gne__c);
            system.assertEquals('123456', transactions[0].Zip_gne__c);
            system.assertEquals('CA', transactions[0].State_gne__c);
            system.assertEquals(true, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(true, transactions[0].To_CS_Uncertified_Flag_gne__c);
            
            delete storageLocation;
            List<SFA2_PFG_Storage_Location_gne__c> slAfterDelete = new List<SFA2_PFG_Storage_Location_gne__c>([Select Id from SFA2_PFG_Storage_Location_gne__c where Id =: storageLocation.Id]);
            system.assertEquals(0, slAfterDelete.size());
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'New Updated Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c newStorageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert newStorageLocation;
            
            system.assertEquals('Approved', newStorageLocation.Status_gne__c);
            
            pfgTransaction.Generate_Shipment_Flag__c = GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED;
            update pfgTransaction;
            
            transactions = new List<SFA2_PFG_Transaction_gne__c>([Select Id, Generate_Shipment_Flag__c,From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ]);
            system.assertEquals(GNE_SFA2_PFG_Util.TRANSACTION_SHIPMENT_INITIATED, transactions[0].Generate_Shipment_Flag__c);                                            
            system.assertEquals('New Updated Address Line 1', transactions[0].Address_Line_1_gne__c);
            system.assertEquals(true, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(true, transactions[0].To_CS_Uncertified_Flag_gne__c);
        }

    }
    */
    //Transfer Test Methods
    /*
    static testMethod void testTransfer()
    {
        User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
        User newCS1 = csUser1;
        newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
        //newCS1.LOA_Status_gne__c = true;
        newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS1.PFG_Uncertified_Flag_gne__c = true;
        User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
        User newCS2 = csUser2;
        newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
       // newCS2.LOA_Status_gne__c = true;
        newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS2.PFG_Uncertified_Flag_gne__c = true;
        User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);

        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(newCS1);
        dataToInsert.add(newCS2);
        dataToInsert.add(dmUser);
        insert dataToInsert;
        
        newCS1.ManagerId = dmUser.Id;
        newCS2.ManagerId = dmUser.Id;
        
        List<sObject> dataToUpdate = new List<sObject>();
        dataToUpdate.add(newCS1);
        dataToUpdate.add(newCS2);
        update dataToUpdate;
        
        User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
        insert adminUser;
        System.runAs(adminUser)
        {
            Test.startTest();
            Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
            Map<String, object> fieldsConfig = new Map<String, object>();
            
            Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
    
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('User_Role_gne__c', 'CS');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_CS = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('User_Role_gne__c', 'DM');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_DM = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('AccountAccessLevel','Edit');
            fieldsConfig.put('Active_Date__c',Date.today().addDays(-100));
            fieldsConfig.put('CaseAccessLevel','None');
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(product);
            dataToInsert.add(icCalcSR_CS);
            dataToInsert.add(icCalcSR_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS1.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS2.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS2 = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('Role_gne__c','DM');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_DM.Id);
            fieldsConfig.put('User_gne__c', dmUser.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_DM = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
    
            dataToInsert = new List<sObject>();
            dataToInsert.add(salesRoster_CS);
            dataToInsert.add(salesRoster_CS2);
            dataToInsert.add(salesRoster_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS2.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
            fieldsConfig.put('Zip_gne__c', '123452');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(storageLocation);
            dataToInsert.add(storageLocation2);
            insert dataToInsert;
            
            //Transfer Created Scenario
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Received_Quantity_gne__c',0);
            fieldsConfig.put('Requested_Quantity_gne__c',100);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction;
            
            List<SFA2_PFG_Transaction_gne__c> transactions = [Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ];
            
            system.assertEquals(false, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(false, transactions[0].To_CS_Uncertified_Flag_gne__c);
            
            //Transfer Received Scenario
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Received_Quantity_gne__c',100);
            fieldsConfig.put('Requested_Quantity_gne__c',100);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction2 = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction2;
            
            transactions = new List<SFA2_PFG_Transaction_gne__c>([Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction2.Id
                                                             ]);
            system.assertEquals(true, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(false, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(false, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(true, transactions[0].To_CS_Uncertified_Flag_gne__c);
            Test.stopTest();
        }                                                
    }
    */
    //Order Created Test Methods
/*
    static testMethod void testOrderCreated()
    {
        User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
        User newCS1 = csUser1;
        newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
        //newCS1.LOA_Status_gne__c = true;
        newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS1.PFG_Uncertified_Flag_gne__c = true;
        User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
        User newCS2 = csUser2;
        newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
       // newCS2.LOA_Status_gne__c = true;
        newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS2.PFG_Uncertified_Flag_gne__c = true;
        User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);
        
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(newCS1);
        dataToInsert.add(newCS2);
        dataToInsert.add(dmUser);
        insert dataToInsert;
        
        newCS1.ManagerId = dmUser.Id;
        newCS2.ManagerId = dmUser.Id;
        
        List<sObject> dataToUpdate = new List<sObject>();
        dataToUpdate.add(newCS1);
        dataToUpdate.add(newCS2);
        update dataToUpdate;
        
        User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
        insert adminUser;
        System.runAs(adminUser)
        {
            Test.startTest();
            Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
            Map<String, object> fieldsConfig = new Map<String, object>();
            
            Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
    
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('User_Role_gne__c', 'CS');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_CS = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('User_Role_gne__c', 'DM');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_DM = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(product);
            dataToInsert.add(icCalcSR_CS);
            dataToInsert.add(icCalcSR_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS1.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS2.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS2 = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('Role_gne__c','DM');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_DM.Id);
            fieldsConfig.put('User_gne__c', dmUser.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_DM = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(salesRoster_CS);
            dataToInsert.add(salesRoster_CS2);
            dataToInsert.add(salesRoster_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);

            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS2.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
            fieldsConfig.put('Zip_gne__c', '123452');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(storageLocation);
            dataToInsert.add(storageLocation2);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Received_Quantity_gne__c',0);
            fieldsConfig.put('Requested_Quantity_gne__c',100);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction;
            
            List<SFA2_PFG_Transaction_gne__c> transactions = [Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ];
            
            
            system.assertEquals('Test Address Line 1', transactions[0].Address_Line_1_gne__c);
            system.assertEquals('Test Address Line 2', transactions[0].Address_Line_2_gne__c);
            system.assertEquals('San Francisco', transactions[0].City_gne__c);
            system.assertEquals('123456', transactions[0].Zip_gne__c);
            system.assertEquals('CA', transactions[0].State_gne__c);
            system.assertEquals(true, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(false, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(false, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(true, transactions[0].To_CS_Uncertified_Flag_gne__c);
            Test.stopTest();
        }
    }
   */ 
    /*
    //Return Test Methods
    static testMethod void testResturn()
    {
        User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
        User newCS1 = csUser1;
        newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
       // newCS1.LOA_Status_gne__c = true;
        newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS1.PFG_Uncertified_Flag_gne__c = true;
        User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
        User newCS2 = csUser2;
        newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
       // newCS2.LOA_Status_gne__c = true;
        newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS2.PFG_Uncertified_Flag_gne__c = true;
        User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);
        
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(newCS1);
        dataToInsert.add(newCS2);
        dataToInsert.add(dmUser);
        insert dataToInsert;
        
        newCS1.ManagerId = dmUser.Id;
        newCS2.ManagerId = dmUser.Id;
        
        List<sObject> dataToUpdate = new List<sObject>();
        dataToUpdate.add(newCS1);
        dataToUpdate.add(newCS2);
        update dataToUpdate;
        
        User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
        insert adminUser;
        System.runAs(adminUser)
        {
            Test.startTest();
            Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
            Map<String, object> fieldsConfig = new Map<String, object>();
            
            Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
        
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('User_Role_gne__c', 'CS');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_CS = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('User_Role_gne__c', 'DM');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_DM = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(product);
            dataToInsert.add(icCalcSR_CS);
            dataToInsert.add(icCalcSR_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS1.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS2.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS2 = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('Role_gne__c','DM');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_DM.Id);
            fieldsConfig.put('User_gne__c', dmUser.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_DM = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
    
            dataToInsert = new List<sObject>();
            dataToInsert.add(salesRoster_CS);
            dataToInsert.add(salesRoster_CS2);
            dataToInsert.add(salesRoster_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS2.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
            fieldsConfig.put('Zip_gne__c', '123452');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(storageLocation);
            dataToInsert.add(storageLocation2);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction;
            
            List<SFA2_PFG_Transaction_gne__c> transactions = [Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ];
            
            system.assertEquals(false, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(false, transactions[0].To_CS_Uncertified_Flag_gne__c);
            Test.stopTest();
        }
    }
    */
    //Disbursement Test Methods
    static testMethod void testDisbursement()
    {
        User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
        User newCS1 = csUser1;
        newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
      //  newCS1.LOA_Status_gne__c = true;
        newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS1.PFG_Uncertified_Flag_gne__c = true;
        User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
        User newCS2 = csUser2;
        newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
     //   newCS2.LOA_Status_gne__c = true;
        newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS2.PFG_Uncertified_Flag_gne__c = true;
        User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);
        
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(newCS1);
        dataToInsert.add(newCS2);
        dataToInsert.add(dmUser);
        insert dataToInsert;
        
        newCS1.ManagerId = dmUser.Id;
        newCS2.ManagerId = dmUser.Id;
        
        List<sObject> dataToUpdate = new List<sObject>();
        dataToUpdate.add(newCS1);
        dataToUpdate.add(newCS2);
        update dataToUpdate;
        
        User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
        insert adminUser;
        System.runAs(adminUser)
        {
            Test.startTest();
            Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
            Map<String, object> fieldsConfig = new Map<String, object>();
            
            Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('User_Role_gne__c', 'CS');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_CS = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('User_Role_gne__c', 'DM');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_DM = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(product);
            dataToInsert.add(icCalcSR_CS);
            dataToInsert.add(icCalcSR_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS1.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS2.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS2 = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('Role_gne__c','DM');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_DM.Id);
            fieldsConfig.put('User_gne__c', dmUser.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_DM = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(salesRoster_CS);
            dataToInsert.add(salesRoster_CS2);
            dataToInsert.add(salesRoster_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS2.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
            fieldsConfig.put('Zip_gne__c', '123452');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(storageLocation);
            dataToInsert.add(storageLocation2);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction;
            
            List<SFA2_PFG_Transaction_gne__c> transactions = [Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ];
            
            system.assertEquals(false, transactions[0].To_CS_on_LOA_Flag_gne__c);
            //system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            //system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(false, transactions[0].To_CS_Uncertified_Flag_gne__c);
            Test.stopTest();
        }
    }
    //Request for Fulfillment Test Methods
    static testMethod void testRFF()
    {
        User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
        User newCS1 = csUser1;
        newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
       // newCS1.LOA_Status_gne__c = true;
        newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS1.PFG_Uncertified_Flag_gne__c = true;
        User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
        User newCS2 = csUser2;
        newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
     //   newCS2.LOA_Status_gne__c = true;
        newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS2.PFG_Uncertified_Flag_gne__c = true;
        User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);
        
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(newCS1);
        dataToInsert.add(newCS2);
        dataToInsert.add(dmUser);
        insert dataToInsert;
        
        newCS1.ManagerId = dmUser.Id;
        newCS2.ManagerId = dmUser.Id;
        
        List<sObject> dataToUpdate = new List<sObject>();
        dataToUpdate.add(newCS1);
        dataToUpdate.add(newCS2);
        update dataToUpdate;

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
        insert adminUser;
        System.runAs(adminUser)
        {   
            Test.startTest();   
            Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
            Map<String, object> fieldsConfig = new Map<String, object>();
            
            Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('User_Role_gne__c', 'CS');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_CS = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('User_Role_gne__c', 'DM');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_DM = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(product);
            dataToInsert.add(icCalcSR_CS);
            dataToInsert.add(icCalcSR_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS1.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS2.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS2 = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('Role_gne__c','DM');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_DM.Id);
            fieldsConfig.put('User_gne__c', dmUser.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_DM = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(salesRoster_CS);
            dataToInsert.add(salesRoster_CS2);
            dataToInsert.add(salesRoster_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS2.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
            fieldsConfig.put('Zip_gne__c', '123452');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(storageLocation);
            dataToInsert.add(storageLocation2);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Account_gne__c', testAccount.Id);
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction;
            
            List<SFA2_PFG_Transaction_gne__c> transactions = [Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ];
            
            system.assertEquals(false, transactions[0].To_CS_on_LOA_Flag_gne__c);
            //system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            //system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(false, transactions[0].To_CS_Uncertified_Flag_gne__c);
            Test.stopTest();
        }
    }
    //Adjustment Test Methods
    /*
    static testMethod void testAdjustment()
    {
        User csUser1 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS1@gene.com', 'testCS1@gene.com', 'Rep', true);
        User newCS1 = csUser1;
        newCS1.LOA_HO_Override_Flag_gne__c = 'NA';
       // newCS1.LOA_Status_gne__c = true;
        newCS1.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS1.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS1.PFG_Uncertified_Flag_gne__c = true;
        User csUser2 = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testCS2@gene.com', 'testCS2@gene.com', 'Rep', true);
        User newCS2 = csUser2;
        newCS2.LOA_HO_Override_Flag_gne__c = 'NA';
      //  newCS2.LOA_Status_gne__c = true;
        newCS2.LOA_Start_Date_gne__c = Date.today().addDays(-10);
        newCS2.LOA_End_Date_gne__c = Date.today().addDays(10);
        newCS2.PFG_Uncertified_Flag_gne__c = true;
        User dmUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'testDM@gene.com', 'testDM@gene.com', 'DM', true);
        
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(newCS1);
        dataToInsert.add(newCS2);
        dataToInsert.add(dmUser);
        insert dataToInsert;
        
        newCS1.ManagerId = dmUser.Id;
        newCS2.ManagerId = dmUser.Id;
        
        List<sObject> dataToUpdate = new List<sObject>();
        dataToUpdate.add(newCS1);
        dataToUpdate.add(newCS2);
        update dataToUpdate;
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        User adminUser = GNE_SFA2_PFG_TestHelper.prepareEnv(SYS_ADMIN, 'GNE_SFA2_PFG_Transaction_Trigger', 'admin@gene.com', 'admin@gene.com', 'Admin', true);
        insert adminUser;
        System.runAs(adminUser)
        {
            Test.startTest();
            Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
            Map<String, object> fieldsConfig = new Map<String, object>();
            
            Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('User_Role_gne__c', 'CS');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_CS = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Type_gne__c','SFA-US');
            fieldsConfig.put('Brand_Name_gne__c','Nutropin');
            //fieldsConfig.put('Is_SFA2_App_gne__c',true);
            fieldsConfig.put('Is_SFA2_Available_gne__c',true);
            fieldsConfig.put('Plan_Period_gne__c','Quarter');
            fieldsConfig.put('Runs_in_SFA2_Mode_gne__c',true);
            fieldsConfig.put('Salesforce_gne__c','Nutropin');
            fieldsConfig.put('User_Profile_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('User_Role_gne__c', 'DM');
            objectConfig.put(new IC_Calc_Sales_Roster_gne__c(), fieldsConfig);
            IC_Calc_Sales_Roster_gne__c icCalcSR_DM = (IC_Calc_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(product);
            dataToInsert.add(icCalcSR_CS);
            dataToInsert.add(icCalcSR_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS1.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-CS');
            fieldsConfig.put('Role_gne__c','CS');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_CS.Id);
            fieldsConfig.put('User_gne__c', newCS2.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_CS2 = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('Is_Active_gne__c',true);
            fieldsConfig.put('Profile_Name_gne__c','GNE-SFA-Nutropin-DM');
            fieldsConfig.put('Role_gne__c','DM');
            fieldsConfig.put('Sales_Roster_gne__c', icCalcSR_DM.Id);
            fieldsConfig.put('User_gne__c', dmUser.Id);
            objectConfig.put(new SFA2_User_Sales_Roster_gne__c(), fieldsConfig);
            SFA2_User_Sales_Roster_gne__c salesRoster_DM = (SFA2_User_Sales_Roster_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(salesRoster_CS);
            dataToInsert.add(salesRoster_CS2);
            dataToInsert.add(salesRoster_DM);
            insert dataToInsert;
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS1.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 1');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 2');
            fieldsConfig.put('Zip_gne__c', '123456');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('User_gne__c', newCS2.Id);
            fieldsConfig.put('Manager_gne__c', dmUser.Id);
            fieldsConfig.put('Address_Line_1_gne__c', 'Test Address Line 12');
            fieldsConfig.put('Address_Line_2_gne__c', 'Test Address Line 22');
            fieldsConfig.put('Zip_gne__c', '123452');
            fieldsConfig.put('City_gne__c', 'San Francisco');
            fieldsConfig.put('State_gne__c', 'CA');
            fieldsConfig.put('Phone_gne__c', '(999) 999-9999');
            fieldsConfig.put('Status_gne__c', 'Approved');
            fieldsConfig.put('Address_Changed_gne__c', true);
            objectConfig.put(new SFA2_PFG_Storage_Location_gne__c(), fieldsConfig);
            SFA2_PFG_Storage_Location_gne__c storageLocation2 = (SFA2_PFG_Storage_Location_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            
            dataToInsert = new List<sObject>();
            dataToInsert.add(storageLocation);
            dataToInsert.add(storageLocation2);
            insert dataToInsert;
            
            //Adjustment from Inventory Count
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Account_gne__c', testAccount.Id);
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            fieldsConfig.put('Inventory_Count_Flag_gne__c', true);
            
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction;
            
            List<SFA2_PFG_Transaction_gne__c> transactions = [Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction.Id
                                                             ];
            
            system.assertEquals('Test Address Line 1', transactions[0].Address_Line_1_gne__c);
            system.assertEquals('Test Address Line 2', transactions[0].Address_Line_2_gne__c);
            system.assertEquals('San Francisco', transactions[0].City_gne__c);
            system.assertEquals('123456', transactions[0].Zip_gne__c);
            system.assertEquals('CA', transactions[0].State_gne__c);
            system.assertEquals(true, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(false, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(false, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(true, transactions[0].To_CS_Uncertified_Flag_gne__c);
            
            //Adjustment from page
            objectConfig = new Map<sObject, Map<String, object>>();
            fieldsConfig = new Map<String, object>();
            fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT, TRANSACTION_OBJECT_TYPE));
            fieldsConfig.put('To_User_gne__c', newCS1.Id);
            fieldsConfig.put('From_User_gne__c', newCS2.Id);
            fieldsConfig.put('Product_gne__c', product.Id);
            fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
            fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
            fieldsConfig.put('Lot_No_gne__c', '12345678');
            fieldsConfig.put('Transaction_Date_gne__c', Date.today());
            fieldsConfig.put('Inventory_Count_Flag_gne__c', false);
            objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
            SFA2_PFG_Transaction_gne__c pfgTransaction2 = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
            insert pfgTransaction2;
            
            transactions = new List<SFA2_PFG_Transaction_gne__c>([Select Id, From_CS_on_LOA_Flag__c, From_CS_Uncertified_Flag__c, To_CS_on_LOA_Flag_gne__c, To_CS_Uncertified_Flag_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
                                                              Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, Zip_gne__c, State_gne__c from  SFA2_PFG_Transaction_gne__c where Id =: pfgTransaction2.Id
                                                             ]);
                                                             
            system.assertEquals(null, transactions[0].Address_Line_1_gne__c);
            system.assertEquals(null, transactions[0].Address_Line_2_gne__c);
            system.assertEquals(null, transactions[0].City_gne__c);
            system.assertEquals(null, transactions[0].Zip_gne__c);
            system.assertEquals(null, transactions[0].State_gne__c);
            system.assertEquals(false, transactions[0].To_CS_on_LOA_Flag_gne__c);
            system.assertEquals(true, transactions[0].From_CS_on_LOA_Flag__c);
            system.assertEquals(true, transactions[0].From_CS_Uncertified_Flag__c);
            system.assertEquals(false, transactions[0].To_CS_Uncertified_Flag_gne__c);
            Test.stopTest();
        }
        
    }
    */
}