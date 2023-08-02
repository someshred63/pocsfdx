@isTest
private class GNE_SFA2_PFG_TransactionsLogic_Test 
{
    private static final String HO_PROFILE = 'GNE-SFA-Actemra-Manager';
    private static final String DM_PROFILE = 'GNE-SFA-Actemra-DM';
    private static final String CS_PROFILE = 'GNE-SFA-Actemra-CS';
    private static final String TRANS_TYPE_ALLOCATION = 'Allocation';
    public static final String TRANS_TYPE_ORDER = 'Order';
    public static final String TRANS_TYPE_DISBURSEMENT = 'Disbursement';
    public static final String TRANS_TYPE_REQUEST_FF = 'Request for Fulfillment';
    private static final String TRANSACTION_OBJECT_TYPE = 'SFA2_PFG_Transaction_gne__c';
    
    static testMethod void testOrderRequest()
    {
        //User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'Rep', true);
        User testUser = [SELECT id, Name, ManagerId FROM User WHERE Profile_Name_gne__c = 'GNE-SFA-Actemra-CS' AND Name = 'Todd Zacchera'][0];
           
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
        List<sObject> dataToInsert = new List<sObject>();
        //dataToInsert.add(testUser);
        dataToInsert.add(product);
        insert dataToInsert;

        //create user configuration
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
      
        SFA2_PFG_Storage_Location_gne__c storageLocation = new SFA2_PFG_Storage_Location_gne__c(User_gne__c = testUser.Id, User_gne__r = testUser, Status_gne__c = 'Submitted',
            Manager_gne__c = manager.Id,
            Address_Line_1_gne__c  = 'Test',
            Address_Line_2_gne__c = 'Test',
            Zip_gne__c = 'Test',
            City_gne__c = 'Test',
            State_gne__c = 'Test');
        insert storageLocation;
        SFA2_PFG_Storage_Location_gne__c addedStorageLocation = [SELECT Id, Status_gne__c FROM SFA2_PFG_Storage_Location_gne__c WHERE Id =: storageLocation.Id];
        addedStorageLocation.Status_gne__c = 'Approved';
        update addedStorageLocation;

        //create PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String,object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', '12345678');
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert pfgToUserDetail;
        //create PFG to User Detail stop
        
        //create Transaction for Order start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_ORDER, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('To_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Received_Quantity_gne__c',0);
        fieldsConfig.put('Requested_Quantity_gne__c',100);
        fieldsConfig.put('Lot_No_gne__c', '12345678');
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c orderTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert orderTransaction;
        //create Transaction for Order stop
        List<SFA2_PFG_Transaction_gne__c> trnxs = [Select Name from SFA2_PFG_Transaction_gne__c where Id =: orderTransaction.Id];
        orderTransaction.Transaction_Ref_Number_gne__c = trnxs[0].Name;
        update orderTransaction;
        List<SFA2_PFG_to_User_Detail_gne__c> userDetails = [Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: orderTransaction.To_User_gne__c
                                                            AND Product_gne__c =: orderTransaction.Product_gne__c
                                                            AND Lot_NO_gne__c =: orderTransaction.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
    }

    static testMethod void testOrderReceived()
    {   
        //User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'Rep', true);
        User testUser = [SELECT id, Name, ManagerId FROM User WHERE Name = 'Todd Zacchera'][0];
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
        List<sObject> dataToInsert = new List<sObject>();
        //dataToInsert.add(testUser);
        dataToInsert.add(product);
        insert dataToInsert;
        system.assertNotEquals(null, testUser.Id);
        system.assertNotEquals(null, product.Id);
        //create sales roster
        
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
      
        SFA2_PFG_Storage_Location_gne__c storageLocation = new SFA2_PFG_Storage_Location_gne__c(User_gne__c = testUser.Id, User_gne__r = testUser, Status_gne__c = 'Submitted',
            Manager_gne__c = manager.Id,
                                                                                                Address_Line_1_gne__c  = 'Test',
            Address_Line_2_gne__c = 'Test',
            Zip_gne__c = 'Test',
            City_gne__c = 'Test',
            State_gne__c = 'Test');
        insert storageLocation;
        SFA2_PFG_Storage_Location_gne__c addedStorageLocation = [SELECT Id, Status_gne__c FROM SFA2_PFG_Storage_Location_gne__c WHERE Id =: storageLocation.Id];
        addedStorageLocation.Status_gne__c = 'Approved';
        update addedStorageLocation;

        //create PFG to User Detail
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String,object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', '12345678');
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert pfgToUserDetail;

        //create Transaction for Order Request
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_ORDER, TRANSACTION_OBJECT_TYPE));
        //fieldsConfig.put('To_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Requested_Quantity_gne__c',100);
        fieldsConfig.put('Lot_No_gne__c', '12345678');
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c orderTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        orderTransaction.To_User_gne__c = testUser.Id;
        orderTransaction.To_User_gne__r = testUser;
        insert orderTransaction;
        system.assertNotEquals(null, orderTransaction.Id);
        List<SFA2_PFG_Transaction_gne__c> trx = [Select Name from SFA2_PFG_Transaction_gne__c where Id =: orderTransaction.Id];
        orderTransaction.Transaction_Ref_Number_gne__c = trx[0].Name; 

        orderTransaction.To_User_gne__r = testUser;                         
        update orderTransaction;
        List<SFA2_PFG_to_User_Detail_gne__c> userDetails = [Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: orderTransaction.To_User_gne__c
                                                            AND Product_gne__c =: orderTransaction.Product_gne__c
                                                            AND Lot_NO_gne__c =: orderTransaction.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        //Order Shipment
        orderTransaction.Shipped_Quantity_gne__c = 100;
        update orderTransaction;
        userDetails = new List<SFA2_PFG_to_User_Detail_gne__c>([Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: orderTransaction.To_User_gne__c
                                                            AND Product_gne__c =: orderTransaction.Product_gne__c
                                                            AND Lot_NO_gne__c =: orderTransaction.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ]);
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        //Order Received
        orderTransaction.Received_Quantity_gne__c = 100;
        update orderTransaction;
        userDetails = new List<SFA2_PFG_to_User_Detail_gne__c>([Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: orderTransaction.To_User_gne__c
                                                            AND Product_gne__c =: orderTransaction.Product_gne__c
                                                            AND Lot_NO_gne__c =: orderTransaction.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ]);
        
        system.assertEquals(2, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
    }
    
    static testMethod void testDisbursementWithoutException() {   
        //prepare supporting test data start
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(DM_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'DM', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
        Product_vod__c product2 = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(product2);
        dataToInsert.add(acc);
        insert dataToInsert;
        //prepare supporting test data stop
        dataToInsert = new List<sObject>();
        
        //prepare SFA2_PFG_Product_Limit_gne__c start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String,object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Limit_Quantity_gne__c', 2000);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Product_gne__c', product.Id);
        objectConfig.put(new SFA2_PFG_Product_Limit_gne__c(), fieldsConfig);
        sObject yearLimit = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(yearLimit);
        
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Limit_Quantity_gne__c', 1500);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Product_gne__c', product2.Id);
        objectConfig.put(new SFA2_PFG_Product_Limit_gne__c(), fieldsConfig);
        sObject yearLimit2 = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(yearLimit2);
        //prepare SFA2_PFG_Product_Limit_gne__c stop
        
        //prepare PFG_Staging_Account_Limit_Exception_gne__c start - exception deleted
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Exception_Quantity_gne__c', 3000);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Logical_Delete_Flag_gne__c', true);
        fieldsConfig.put('Product_gne__c', product.Id);
        objectConfig.put(new PFG_Staging_Account_Limit_Exception_gne__c(), fieldsConfig);
        sObject accException = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(accException);
        //prepare PFG_Staging_Account_Limit_Exception_gne__c stop
        
        //prepare PFG to User Detail start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', '12345678');
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Disbursed_gne__c',300);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', '5555555');
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product2.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product2.UOM_gne__c);
        fieldsConfig.put('Qty_Disbursed_gne__c',300);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail2 = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        
        dataToInsert.add(pfgToUserDetail);
        dataToInsert.add(pfgToUserDetail2);
        //prepare PFG to User Detail stop
        insert dataToInsert;
        
        //prepare transactions start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_DISBURSEMENT, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Received_Quantity_gne__c',100);
        fieldsConfig.put('Lot_No_gne__c', '12345678');
        fieldsConfig.put('Account_gne__c', acc.Id);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c trans = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_DISBURSEMENT, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product2.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product2.UOM_gne__c);
        fieldsConfig.put('Received_Quantity_gne__c',200);
        fieldsConfig.put('Lot_No_gne__c', '5555555');
        fieldsConfig.put('Account_gne__c', acc.Id);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);      
        SFA2_PFG_Transaction_gne__c trans2 = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        //prepare transactions stop
        List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
        transactions.add(trans);
        transactions.add(trans2);
        insert transactions;
        system.assertEquals(2, transactions.size());
        system.assertNotEquals(null, transactions[0].Id);
        system.assertNotEquals(null, transactions[1].Id);
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Id, Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id IN: transactions];
        Map<Id, String> trxMap = new Map<Id, String>();
        for(SFA2_PFG_Transaction_gne__c trx : trxs)
        {
            trxMap.put(trx.Id, trx.Name);
        }
        String limitYear = String.valueOf(trxs[0].CreatedDate.year());
        transactions[0].Transaction_Ref_Number_gne__c = trxMap.get(transactions[0].Id);
        transactions[1].Transaction_Ref_Number_gne__c = trxMap.get(transactions[1].Id);
        update transactions;
        Set<Id> accIds = new Set<Id>();
        Set<Id> prdIds = new Set<Id>();
        Set<Id> ursIds = new Set<Id>();
        Set<String> lotNrs = new Set<String>();
        for(SFA2_PFG_Transaction_gne__c pfgTrx : transactions)
        {
            accIds.add(pfgTrx.Account_gne__c);
            prdIds.add(pfgTrx.Product_gne__c);
            ursIds.add(pfgTrx.From_User_gne__c);
            lotNrs.add(pfgTrx.Lot_No_gne__c);
        }
        List<SFA2_PFG_to_User_Detail_gne__c> userDetails = [Select Id, Qty_Disbursed_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c IN: ursIds
                                                            AND Product_gne__c IN: prdIds
                                                            AND Lot_NO_gne__c IN: lotNrs
                                                            AND Merged_gne__c = false
                                                          ];
        Map<String, SFA2_PFG_to_User_Detail_gne__c> uDetailsMap = new Map<String, SFA2_PFG_to_User_Detail_gne__c>();                                        
        for(SFA2_PFG_to_User_Detail_gne__c uDet : userDetails)
        {
            String key = uDet.Product_gne__c + '_' + uDet.Lot_NO_gne__c;
            uDetailsMap.put(key, uDet);
        }                                                   
        system.assertEquals(2, userDetails.size());                                                                               
        system.assertEquals(300, uDetailsMap.get(trans.Product_gne__c+'_'+trans.Lot_No_gne__c).Qty_Disbursed_gne__c);
        system.assertEquals(300, uDetailsMap.get(trans2.Product_gne__c+'_'+trans2.Lot_No_gne__c).Qty_Disbursed_gne__c);
        List<SFA2_PFG_to_Account_Detail_gne__c> accDetails = [Select Id, Account_gne__c, Product_gne__c, Qty_Disbursed_gne__c, Distribution_Method_gne__c, Freeze_for_Pending_AOC_gne__c, Limit_Year_gne__c,
                                                             Max_Quantity_gne__c
                                                             from SFA2_PFG_to_Account_Detail_gne__c
                                                             Where  Account_gne__c IN: accIds
                                                             AND Product_gne__c IN: prdIds
                                                             AND Limit_Year_gne__c =: limitYear
                                                            ];
        Map<String, SFA2_PFG_to_Account_Detail_gne__c> accDetMap = new Map<String, SFA2_PFG_to_Account_Detail_gne__c>();
        for(SFA2_PFG_to_Account_Detail_gne__c accD : accDetails)
        {
            String key = accD.Account_gne__c+'_'+accD.Product_gne__c+'_'+accD.Limit_Year_gne__c;
            accDetMap.put(key, accD);
        }   
        
        List<SFA2_PFG_Product_Limit_gne__c> prodLmt = [Select Limit_Quantity_gne__c, Limit_Year_gne__c, Product_gne__c from SFA2_PFG_Product_Limit_gne__c];
        system.assertEquals(2, prodLmt.size());
        Map<String, SFA2_PFG_Product_Limit_gne__c> lmtYearMap = new Map<String, SFA2_PFG_Product_Limit_gne__c>();
        for(SFA2_PFG_Product_Limit_gne__c lmtYear : prodLmt)
        {
            String key = lmtYear.Product_gne__c+'_'+lmtYear.Limit_Year_gne__c;
            lmtYearMap.put(key, lmtYear);
        }                                   
        system.assertEquals(2, accDetails.size());
        system.assertEquals(trans.Account_gne__c, accDetMap.get(trans.Account_gne__c+'_'+trans.Product_gne__c+'_'+limitYear).Account_gne__c);
        system.assertEquals(trans.Product_gne__c, accDetMap.get(trans.Account_gne__c+'_'+trans.Product_gne__c+'_'+limitYear).Product_gne__c);
        system.assertEquals(trans.Received_Quantity_gne__c, accDetMap.get(trans.Account_gne__c+'_'+trans.Product_gne__c+'_'+limitYear).Qty_Disbursed_gne__c);
        system.assertEquals(trans.Distribution_Method_gne__c, accDetMap.get(trans.Account_gne__c+'_'+trans.Product_gne__c+'_'+limitYear).Distribution_Method_gne__c);
        system.assertEquals('No', accDetMap.get(trans.Account_gne__c+'_'+trans.Product_gne__c+'_'+limitYear).Freeze_for_Pending_AOC_gne__c);
        system.assertEquals(limitYear, accDetMap.get(trans.Account_gne__c+'_'+trans.Product_gne__c+'_'+limitYear).Limit_Year_gne__c);
        system.assertEquals(lmtYearMap.get(trans.Product_gne__c+'_'+limitYear).Limit_Quantity_gne__c, accDetMap.get(trans.Account_gne__c+'_'+trans.Product_gne__c+'_'+limitYear).Max_Quantity_gne__c);
        
        system.assertEquals(trans2.Account_gne__c, accDetMap.get(trans2.Account_gne__c+'_'+trans2.Product_gne__c+'_'+limitYear).Account_gne__c);
        system.assertEquals(trans2.Product_gne__c, accDetMap.get(trans2.Account_gne__c+'_'+trans2.Product_gne__c+'_'+limitYear).Product_gne__c);
        system.assertEquals(trans2.Received_Quantity_gne__c, accDetMap.get(trans2.Account_gne__c+'_'+trans2.Product_gne__c+'_'+limitYear).Qty_Disbursed_gne__c);
        system.assertEquals(trans2.Distribution_Method_gne__c, accDetMap.get(trans2.Account_gne__c+'_'+trans2.Product_gne__c+'_'+limitYear).Distribution_Method_gne__c);
        system.assertEquals('No', accDetMap.get(trans2.Account_gne__c+'_'+trans2.Product_gne__c+'_'+limitYear).Freeze_for_Pending_AOC_gne__c);
        system.assertEquals(limitYear, accDetMap.get(trans2.Account_gne__c+'_'+trans2.Product_gne__c+'_'+limitYear).Limit_Year_gne__c);
        system.assertEquals(lmtYearMap.get(trans2.Product_gne__c+'_'+limitYear).Limit_Quantity_gne__c, accDetMap.get(trans2.Account_gne__c+'_'+trans2.Product_gne__c+'_'+limitYear).Max_Quantity_gne__c);
        
        //update scenario
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_DISBURSEMENT, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Received_Quantity_gne__c',100);
        fieldsConfig.put('Lot_No_gne__c', '12345678');
        fieldsConfig.put('Account_gne__c', acc.Id);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c orderTransactionUpdate = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert orderTransactionUpdate;
        //prepare transaction stop
        system.assertNotEquals(null, orderTransactionUpdate.Id);
        trxs = new List<SFA2_PFG_Transaction_gne__c>();
        trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: orderTransactionUpdate.Id];
        orderTransactionUpdate.Transaction_Ref_Number_gne__c =trxs[0].Name;
        update orderTransactionUpdate;
        List<SFA2_PFG_to_User_Detail_gne__c> userDetailsUpdated = [Select Id, Qty_Disbursed_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: orderTransactionUpdate.From_User_gne__c
                                                            AND Product_gne__c =: orderTransactionUpdate.Product_gne__c
                                                            AND Lot_NO_gne__c =: orderTransactionUpdate.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];    
        system.assertEquals(1, userDetailsUpdated.size());                                                                                
        system.assertEquals(300, userDetailsUpdated[0].Qty_Disbursed_gne__c);
        List<SFA2_PFG_to_Account_Detail_gne__c> accDetailUpdated = [Select Qty_Disbursed_gne__c
                                                             from SFA2_PFG_to_Account_Detail_gne__c
                                                             Where  Account_gne__c =: orderTransactionUpdate.Account_gne__c
                                                             AND Product_gne__c =: orderTransactionUpdate.Product_gne__c
                                                             AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())
                                                            ];
        system.assertEquals(200, accDetailUpdated[0].Qty_Disbursed_gne__c);

    }
    static testMethod void testDisbursementWithException() {   
        //prepare supporting test data start
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(DM_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'DM', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('Hand Carry');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        //prepare supporting test data stop
        dataToInsert = new List<sObject>();
        //prepare SFA2_PFG_Product_Limit_gne__c start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String,object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Limit_Quantity_gne__c', 2000);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Product_gne__c', product.Id);
        objectConfig.put(new SFA2_PFG_Product_Limit_gne__c(), fieldsConfig);
        sObject yearLimit = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(yearLimit);
        //prepare SFA2_PFG_Product_Limit_gne__c stop
        
        //prepare PFG_Staging_Account_Limit_Exception_gne__c start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Exception_Quantity_gne__c', 3000);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Logical_Delete_Flag_gne__c', false);
        fieldsConfig.put('Product_gne__c', product.Id);
        objectConfig.put(new PFG_Staging_Account_Limit_Exception_gne__c(), fieldsConfig);
        sObject accException = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(accException);
        //prepare PFG_Staging_Account_Limit_Exception_gne__c stop
        
        //prepare PFG to User Detail start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', '12345678');
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Disbursed_gne__c',300);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        insert dataToInsert;
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_DISBURSEMENT, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Received_Quantity_gne__c',100);
        fieldsConfig.put('Lot_No_gne__c', '12345678');
        fieldsConfig.put('Account_gne__c', acc.Id);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c disbursementTransaction = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert disbursementTransaction;
        //prepare transaction stop
        system.assertNotEquals(null, disbursementTransaction.Id);
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =:disbursementTransaction.Id];
        disbursementTransaction.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update disbursementTransaction;
        List<SFA2_PFG_to_User_Detail_gne__c> userDetails = [Select Id, Qty_Disbursed_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: disbursementTransaction.From_User_gne__c
                                                            AND Product_gne__c =: disbursementTransaction.Product_gne__c
                                                            AND Lot_NO_gne__c =:disbursementTransaction.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];    
        system.assertEquals(1, userDetails.size());                                                                               
        system.assertEquals(300, userDetails[0].Qty_Disbursed_gne__c);
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDetail = [Select Id, Account_gne__c, Product_gne__c, Qty_Disbursed_gne__c, Distribution_Method_gne__c, Freeze_for_Pending_AOC_gne__c, Limit_Year_gne__c,
                                                             Max_Quantity_gne__c
                                                             from SFA2_PFG_to_Account_Detail_gne__c
                                                             Where  Account_gne__c =: disbursementTransaction.Account_gne__c
                                                             AND Product_gne__c =: disbursementTransaction.Product_gne__c
                                                             AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())
                                                            ];
        system.assertEquals(1, accDetail.size());
        system.assertEquals(disbursementTransaction.Account_gne__c, accDetail[0].Account_gne__c);
        system.assertEquals(disbursementTransaction.Product_gne__c, accDetail[0].Product_gne__c);
        system.assertEquals(disbursementTransaction.Product_gne__c, accDetail[0].Product_gne__c);
        system.assertEquals(disbursementTransaction.Received_Quantity_gne__c, accDetail[0].Qty_Disbursed_gne__c);
        system.assertEquals(disbursementTransaction.Distribution_Method_gne__c, accDetail[0].Distribution_Method_gne__c);
        system.assertEquals('No', accDetail[0].Freeze_for_Pending_AOC_gne__c);
        system.assertEquals(String.valueOf(trxs[0].CreatedDate.year()), accDetail[0].Limit_Year_gne__c);        
        system.assertEquals(2000, accDetail[0].Max_Quantity_gne__c);
        
        //update scenario
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_DISBURSEMENT, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Received_Quantity_gne__c',100);
        fieldsConfig.put('Lot_No_gne__c', '12345678');
        fieldsConfig.put('Account_gne__c', acc.Id);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c disbursementTransactionUpdate = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert disbursementTransactionUpdate;
        //prepare transaction stop
        system.assertNotEquals(null, disbursementTransactionUpdate.Id);
        trxs = new List<SFA2_PFG_Transaction_gne__c>();
        trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: disbursementTransactionUpdate.Id];
        disbursementTransactionUpdate.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update disbursementTransactionUpdate;
        List<SFA2_PFG_to_User_Detail_gne__c> userDetailsUpdated = [Select Id, Qty_Disbursed_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: disbursementTransactionUpdate.From_User_gne__c
                                                            AND Product_gne__c =: disbursementTransactionUpdate.Product_gne__c
                                                            AND Lot_NO_gne__c =: disbursementTransactionUpdate.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];    
        system.assertEquals(1, userDetailsUpdated.size());                                                                                
        system.assertEquals(300, userDetailsUpdated[0].Qty_Disbursed_gne__c);
        List<SFA2_PFG_to_Account_Detail_gne__c> accDetailUpdated = [Select Qty_Disbursed_gne__c
                                                             from SFA2_PFG_to_Account_Detail_gne__c
                                                             Where  Account_gne__c =: disbursementTransactionUpdate.Account_gne__c
                                                             AND Product_gne__c =: disbursementTransactionUpdate.Product_gne__c
                                                             AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())
                                                            ];
        system.assertEquals(200, accDetailUpdated[0].Qty_Disbursed_gne__c);
        
        //update scenario - Received_Quantity_gne__c exceeds Max Quantity
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_DISBURSEMENT, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','Hand Carry');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Received_Quantity_gne__c',5000);
        fieldsConfig.put('Lot_No_gne__c', '12345678');
        fieldsConfig.put('Account_gne__c', acc.Id);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c disbursementTransactionExceeded = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert disbursementTransactionExceeded;
        //prepare transaction stop
        system.assertNotEquals(null, disbursementTransactionExceeded.Id);
        trxs = new List<SFA2_PFG_Transaction_gne__c>();
        trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: disbursementTransactionExceeded.Id];
        disbursementTransactionExceeded.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update disbursementTransactionExceeded;
        List<SFA2_PFG_to_User_Detail_gne__c> uDetailsExceeded = [Select Id, Qty_Disbursed_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: disbursementTransactionExceeded.From_User_gne__c
                                                            AND Product_gne__c =: disbursementTransactionExceeded.Product_gne__c
                                                            AND Lot_NO_gne__c =: disbursementTransactionExceeded.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];    
        system.assertEquals(1, uDetailsExceeded.size());                                                                                  
        system.assertEquals(300, uDetailsExceeded[0].Qty_Disbursed_gne__c);
        List<SFA2_PFG_to_Account_Detail_gne__c> accDetailExceeded = [Select Qty_Disbursed_gne__c, Max_Quantity_gne__c
                                                             from SFA2_PFG_to_Account_Detail_gne__c
                                                             Where  Account_gne__c =: disbursementTransactionExceeded.Account_gne__c
                                                             AND Product_gne__c =: disbursementTransactionExceeded.Product_gne__c
                                                             AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())
                                                            ];
        system.assertEquals(5200, accDetailExceeded[0].Qty_Disbursed_gne__c);
        system.assertEquals(true, accDetailExceeded[0].Qty_Disbursed_gne__c > accDetailExceeded[0].Max_Quantity_gne__c);
    }
    static testMethod void dtpDeliveryCanceled()
    {   
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'CS', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('DTP');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        dataToInsert = new List<sObject>();
        
        //prepare PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', 'DTP-NA');
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Reserved_gne__c',300);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        
        //prepare PFG to Account Detail start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Distribution_Method_gne__c', 'DTP');
        fieldsConfig.put('Freeze_for_Pending_AOC_gne__c', 'No');
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Max_Quantity_gne__c', 1000);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Qty_to_Fulfill_gne__c', 500);
        objectConfig.put(new SFA2_PFG_to_Account_Detail_gne__c(), fieldsConfig);
        sObject pfgToAccountDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToAccountDetail);
        //prepare PFG to Account Detail stop
        insert dataToInsert;
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_REQUEST_FF, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Lot_No_gne__c', 'DTP-NA');
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Shipped_Quantity_gne__c', 0);
        fieldsConfig.put('Requested_Quantity_gne__c', 100);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c reqFF = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert reqFF;
        //prepare transaction stop
        List<SFA2_PFG_Transaction_gne__c> trnx = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =:reqFF.Id];
        reqFF.Transaction_Ref_Number_gne__c = trnx[0].Name;
        update reqFF;
        system.debug('reqFF 1 ='+reqFF);
        List<SFA2_PFG_to_User_Detail_gne__c> userDetails = [Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: reqFF.From_User_gne__c
                                                            AND Product_gne__c =: reqFF.Product_gne__c
                                                            AND Lot_NO_gne__c =: reqFF.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(300, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDet = [Select Qty_to_Fulfill_gne__c, Exception_Quantity_gne__c,
                                                                 Max_Quantity_gne__c, Qty_Disbursed_gne__c
                                                          from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trnx[0].CreatedDate.year())];
        system.assertEquals(1, accDet.size());
        system.assertEquals(600, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(1000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(0, accDet[0].Qty_Disbursed_gne__c);
        
        //Delivery Canceled
        
        reqFF.Delivery_Status_gne__c = 'Canceled';
        reqFF.Shipped_Quantity_gne__c = 0;
        update reqFF;
        
        userDetails = new List<SFA2_PFG_to_User_Detail_gne__c>([Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: reqFF.From_User_gne__c
                                                            AND Product_gne__c =: reqFF.Product_gne__c
                                                            AND Lot_NO_gne__c =: reqFF.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ]);
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(300, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        
        accDet = new List<SFA2_PFG_to_Account_Detail_gne__c>([Select Qty_to_Fulfill_gne__c, Exception_Quantity_gne__c,
                                                                 Max_Quantity_gne__c, Qty_Disbursed_gne__c
                                                          from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trnx[0].CreatedDate.year())]);
        system.assertEquals(1, accDet.size());
        system.assertEquals(600, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(1000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(0, accDet[0].Qty_Disbursed_gne__c);
    }
    static testMethod void dtpRequest()
    {
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'CS', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('DTP');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        dataToInsert = new List<sObject>();
        
        //prepare PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', 'DTP-NA');
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Reserved_gne__c', 200);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        
        //prepare PFG to Account Detail start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Distribution_Method_gne__c', 'DTP');
        fieldsConfig.put('Freeze_for_Pending_AOC_gne__c', 'No');
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Max_Quantity_gne__c', 1000);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Qty_to_Fulfill_gne__c', 500);
        fieldsConfig.put('Qty_Disbursed_gne__c', 500);
        objectConfig.put(new SFA2_PFG_to_Account_Detail_gne__c(), fieldsConfig);
        sObject pfgToAccountDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToAccountDetail);
        //prepare PFG to Account Detail stop
        insert dataToInsert;
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_REQUEST_FF, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Lot_No_gne__c', 'DTP-NA');
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Shipped_Quantity_gne__c', 0);
        fieldsConfig.put('Requested_Quantity_gne__c', 100);
        fieldsConfig.put('Received_Quantity_gne__c', 0);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c reqFF = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert reqFF;
        //prepare transaction stop
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: reqFF.Id];
        reqFF.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update reqFF;
        List<SFA2_PFG_to_User_Detail_gne__c> uDetails = [Select Qty_Reserved_gne__c from SFA2_PFG_to_User_Detail_gne__c where User_gne__c =: reqFF.From_User_gne__c AND Product_gne__c =: reqFF.Product_gne__c];
        system.assertEquals(1, uDetails.size());
        system.assertEquals(200, uDetails[0].Qty_Reserved_gne__c);
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDet = [Select Qty_to_Fulfill_gne__c, Qty_Disbursed_gne__c from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())];
        system.assertEquals(1, accDet.size());
        system.assertEquals(600, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(500, accDet[0].Qty_Disbursed_gne__c);
    }
    static testMethod void dtpReceipt()
    {
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'CS', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('DTP');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        dataToInsert = new List<sObject>();
        
        //prepare PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', 'DTP-NA');
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Reserved_gne__c', 200);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        
        //prepare PFG to Account Detail start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Distribution_Method_gne__c', 'DTP');
        fieldsConfig.put('Freeze_for_Pending_AOC_gne__c', 'No');
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Max_Quantity_gne__c', 1000);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Qty_to_Fulfill_gne__c', 500);
        fieldsConfig.put('Qty_Disbursed_gne__c', 200);
        objectConfig.put(new SFA2_PFG_to_Account_Detail_gne__c(), fieldsConfig);
        sObject pfgToAccountDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToAccountDetail);
        //prepare PFG to Account Detail stop
        insert dataToInsert;
        //prepare transaction Request
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_REQUEST_FF, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Lot_No_gne__c', 'DTP-NA');
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Requested_Quantity_gne__c', 100);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c reqFF = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert reqFF;
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: reqFF.Id];
        reqFF.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update reqFF;
        List<SFA2_PFG_to_User_Detail_gne__c> userDetails = [Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: reqFF.From_User_gne__c
                                                            AND Product_gne__c =: reqFF.Product_gne__c
                                                            AND Lot_NO_gne__c =: reqFF.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ];
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(200, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDet = [Select Qty_to_Fulfill_gne__c, Exception_Quantity_gne__c,
                                                                 Max_Quantity_gne__c, Qty_Disbursed_gne__c
                                                          from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())];
        system.assertEquals(1, accDet.size());
        system.assertEquals(600, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(1000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(200, accDet[0].Qty_Disbursed_gne__c);
        //Ship Request
        reqFF.Shipped_Quantity_gne__c = 100;
        update reqFF;
        userDetails = new List<SFA2_PFG_to_User_Detail_gne__c>([Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: reqFF.From_User_gne__c
                                                            AND Product_gne__c =: reqFF.Product_gne__c
                                                            AND Lot_NO_gne__c =: reqFF.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ]);
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(200, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        
        accDet = new List<SFA2_PFG_to_Account_Detail_gne__c>([Select Qty_to_Fulfill_gne__c, Exception_Quantity_gne__c,
                                                                 Max_Quantity_gne__c, Qty_Disbursed_gne__c
                                                          from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())]);
        system.assertEquals(1, accDet.size());
        system.assertEquals(500, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(1000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(300, accDet[0].Qty_Disbursed_gne__c);
        //Receive Request
        reqFF.Received_Quantity_gne__c = 100;
        update reqFF;
        userDetails = new List<SFA2_PFG_to_User_Detail_gne__c>([Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: reqFF.From_User_gne__c
                                                            AND Product_gne__c =: reqFF.Product_gne__c
                                                            AND Lot_NO_gne__c =: reqFF.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ]);
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(200, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        
        accDet = new List<SFA2_PFG_to_Account_Detail_gne__c>([Select Qty_to_Fulfill_gne__c, Exception_Quantity_gne__c,
                                                                 Max_Quantity_gne__c, Qty_Disbursed_gne__c
                                                          from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())]);
        system.assertEquals(1, accDet.size());
        system.assertEquals(500, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(1000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(300, accDet[0].Qty_Disbursed_gne__c);
    }
    static testMethod void dtpShipment()
    {
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'CS', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('DTP');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        dataToInsert = new List<sObject>();
        
        //prepare PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', 'DTP-NA');
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Reserved_gne__c', 200);
        fieldsConfig.put('Qty_Shipped_to_Physician_gne__c', 100);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        
        //prepare PFG to Account Detail start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Distribution_Method_gne__c', 'DTP');
        fieldsConfig.put('Freeze_for_Pending_AOC_gne__c', 'No');
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Max_Quantity_gne__c', 1000);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Qty_to_Fulfill_gne__c', 100);
        fieldsConfig.put('Qty_Disbursed_gne__c', 100);
        objectConfig.put(new SFA2_PFG_to_Account_Detail_gne__c(), fieldsConfig);
        sObject pfgToAccountDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToAccountDetail);
        //prepare PFG to Account Detail stop
        insert dataToInsert;
        //prepare transaction start Request
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_REQUEST_FF, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Lot_No_gne__c', 'DTP-NA');
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Shipped_Quantity_gne__c', 0);
        fieldsConfig.put('Requested_Quantity_gne__c', 100);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c reqFF = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert reqFF;
        //prepare transaction stop
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: reqFF.Id];
        reqFF.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update reqFF;
        List<SFA2_PFG_to_User_Detail_gne__c> userDetails = new List<SFA2_PFG_to_User_Detail_gne__c>([Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: reqFF.From_User_gne__c
                                                            AND Product_gne__c =: reqFF.Product_gne__c
                                                            AND Lot_NO_gne__c =: reqFF.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ]);
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(200, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(100, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDet = new List<SFA2_PFG_to_Account_Detail_gne__c>([Select Qty_to_Fulfill_gne__c, Exception_Quantity_gne__c,
                                                                 Max_Quantity_gne__c, Qty_Disbursed_gne__c
                                                          from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())]);
        system.assertEquals(1, accDet.size());
        system.assertEquals(200, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(1000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(100, accDet[0].Qty_Disbursed_gne__c);
        //Shipment
        reqFF.Shipped_Quantity_gne__c = 100;
        update reqFF;
        userDetails = new List<SFA2_PFG_to_User_Detail_gne__c>([Select Id, YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c, User_gne__c, Product_gne__c, Lot_NO_gne__c,
                                                                   Qty_Adjusted_gne__c, Qty_Disbursed_gne__c, Qty_Last_Physical_Inventory_gne__c,
                                                                   Qty_Reserved_gne__c, Qty_Returned_gne__c, Qty_Shipped_to_Physician_gne__c,
                                                                   Qty_Transferred_In_gne__c, Qty_Transferred_Out_gne__c 
                                                            from SFA2_PFG_to_User_Detail_gne__c
                                                            where User_gne__c =: reqFF.From_User_gne__c
                                                            AND Product_gne__c =: reqFF.Product_gne__c
                                                            AND Lot_NO_gne__c =: reqFF.Lot_No_gne__c
                                                            AND Merged_gne__c = false
                                                          ]);
        system.assertEquals(1, userDetails.size());
        system.assertEquals(500, userDetails[0].Qty_Total_Allocated_gne__c);
        system.assertEquals(500, userDetails[0].YTD_Allocated_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Adjusted_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Disbursed_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Last_Physical_Inventory_gne__c);
        system.assertEquals(200, userDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Returned_gne__c);
        system.assertEquals(100, userDetails[0].Qty_Shipped_to_Physician_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_In_gne__c);
        system.assertEquals(0, userDetails[0].Qty_Transferred_Out_gne__c);
        
        accDet = new List<SFA2_PFG_to_Account_Detail_gne__c>([Select Qty_to_Fulfill_gne__c, Exception_Quantity_gne__c,
                                                                 Max_Quantity_gne__c, Qty_Disbursed_gne__c
                                                          from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())]);
        system.assertEquals(1, accDet.size());
        system.assertEquals(100, accDet[0].Qty_to_Fulfill_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(1000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(200, accDet[0].Qty_Disbursed_gne__c);
        
        
    }
    static testMethod void dtpCreateAccDetailWithoutException()
    {
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'CS', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('DTP');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        dataToInsert = new List<sObject>();
        
        //prepare PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', 'DTP-NA');
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Reserved_gne__c', 200);
        fieldsConfig.put('Qty_Shipped_to_Physician_gne__c', 100);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        
        //prepare limit year start
        fieldsConfig = new Map<String, object>();
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig.put('Limit_Quantity_gne__c', 2000);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Product_gne__c', product.Id);
        objectConfig.put(new SFA2_PFG_Product_Limit_gne__c(), fieldsConfig);
        sObject yearLimit = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(yearLimit);
        //prepare limit year stop
        
        insert dataToInsert;
        
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_REQUEST_FF, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Lot_No_gne__c', 'DTP-NA');
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Shipped_Quantity_gne__c', 100);
        fieldsConfig.put('Requested_Quantity_gne__c', 100);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c reqFF = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert reqFF;
        //prepare transaction stop
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: reqFF.Id];
        reqFF.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update reqFF;
        
        List<SFA2_PFG_to_User_Detail_gne__c> uDetails = [Select Qty_Reserved_gne__c, Qty_Shipped_to_Physician_gne__c from SFA2_PFG_to_User_Detail_gne__c where User_gne__c =: reqFF.From_User_gne__c AND Product_gne__c =: reqFF.Product_gne__c];
        system.assertEquals(1, uDetails.size());
        system.assertEquals(200, uDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(100, uDetails[0].Qty_Shipped_to_Physician_gne__c);
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDet = [Select Account_gne__c, Qty_to_Fulfill_gne__c, Product_gne__c, Max_Quantity_gne__c,Exception_Limit_gne__c,Exception_Quantity_gne__c,
                                                                 Distribution_Method_gne__c, Limit_Year_gne__c, Freeze_for_Pending_AOC_gne__c
                                                            from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())];
        system.assertEquals(1, accDet.size());
        system.assertEquals(reqFF.Account_gne__c, accDet[0].Account_gne__c);
        system.assertEquals(reqFF.Product_gne__c, accDet[0].Product_gne__c);
        system.assertEquals(2000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(false, accDet[0].Exception_Limit_gne__c);
        system.assertEquals(0, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(reqFF.Distribution_Method_gne__c, accDet[0].Distribution_Method_gne__c);
        system.assertEquals(String.valueOf(trxs[0].CreatedDate.year()), accDet[0].Limit_Year_gne__c);
        system.assertEquals('No', accDet[0].Freeze_for_Pending_AOC_gne__c);
        system.assertEquals(0, accDet[0].Qty_to_Fulfill_gne__c);
    }
    static testMethod void dtpCreateAccDetailWithException()
    {
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'CS', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('DTP');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        dataToInsert = new List<sObject>();
        
        //prepare PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', 'DTP-NA');
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Reserved_gne__c', 200);
        fieldsConfig.put('Qty_Shipped_to_Physician_gne__c', 100);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        
        //prepare limit year start
        fieldsConfig = new Map<String, object>();
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig.put('Limit_Quantity_gne__c', 2000);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Product_gne__c', product.Id);
        objectConfig.put(new SFA2_PFG_Product_Limit_gne__c(), fieldsConfig);
        sObject yearLimit = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(yearLimit);
        //prepare limit year stop
        
        
        //prepare PFG_Staging_Account_Limit_Exception_gne__c start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Exception_Quantity_gne__c', 3000);
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Logical_Delete_Flag_gne__c', false);
        fieldsConfig.put('Product_gne__c', product.Id);
        objectConfig.put(new PFG_Staging_Account_Limit_Exception_gne__c(), fieldsConfig);
        sObject accException = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(accException);
        //prepare PFG_Staging_Account_Limit_Exception_gne__c stop
        
        insert dataToInsert;
        
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_REQUEST_FF, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Lot_No_gne__c', 'DTP-NA');
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Shipped_Quantity_gne__c', 100);
        fieldsConfig.put('Requested_Quantity_gne__c', 100);
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c reqFF = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert reqFF;
        //prepare transaction stop
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: reqFF.Id];
        reqFF.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update reqFF;
        
        List<SFA2_PFG_to_User_Detail_gne__c> uDetails = [Select Qty_Reserved_gne__c, Qty_Shipped_to_Physician_gne__c from SFA2_PFG_to_User_Detail_gne__c where User_gne__c =: reqFF.From_User_gne__c AND Product_gne__c =: reqFF.Product_gne__c];
        system.assertEquals(1, uDetails.size());
        system.assertEquals(200, uDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(100, uDetails[0].Qty_Shipped_to_Physician_gne__c);
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDet = [Select Account_gne__c, Qty_to_Fulfill_gne__c, Product_gne__c, Max_Quantity_gne__c,Exception_Limit_gne__c,Exception_Quantity_gne__c,
                                                                 Distribution_Method_gne__c, Limit_Year_gne__c, Freeze_for_Pending_AOC_gne__c
                                                            from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())];
        system.assertEquals(1, accDet.size());
        system.assertEquals(reqFF.Account_gne__c, accDet[0].Account_gne__c);
        system.assertEquals(reqFF.Product_gne__c, accDet[0].Product_gne__c);
        system.assertEquals(2000, accDet[0].Max_Quantity_gne__c);
        system.assertEquals(true, accDet[0].Exception_Limit_gne__c);
        system.assertEquals(3000, accDet[0].Exception_Quantity_gne__c);
        system.assertEquals(reqFF.Distribution_Method_gne__c, accDet[0].Distribution_Method_gne__c);
        system.assertEquals(String.valueOf(trxs[0].CreatedDate.year()), accDet[0].Limit_Year_gne__c);
        system.assertEquals('No', accDet[0].Freeze_for_Pending_AOC_gne__c);
        system.assertEquals(0, accDet[0].Qty_to_Fulfill_gne__c);
    }
    static testMethod void dtpReceiptFreezForPendingAOC()
    {
        User testUser = GNE_SFA2_PFG_TestHelper.prepareEnv(CS_PROFILE, 'GNE_SFA2_PFG_Transaction_Trigger', 'test@gene.com', 'testCS@gene.com', 'CS', true);
        Product_vod__c product = GNE_SFA2_PFG_TestHelper.createPFGproduct('DTP');
        Account acc = GNE_SFA2_PFG_TestHelper.createAccount();
        List<sObject> dataToInsert = new List<sObject>();
        dataToInsert.add(testUser);
        dataToInsert.add(product);
        dataToInsert.add(acc);
        insert dataToInsert;
        dataToInsert = new List<sObject>();
        
        //prepare PFG to User Detail start
        Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
        Map<String, object> fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Active_gne__c', true);
        fieldsConfig.put('Lot_NO_gne__c', 'DTP-NA');
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('Merged_gne__c',false);
        fieldsConfig.put('Product_gne__c',product.Id);
        fieldsConfig.put('YTD_Allocated_gne__c',500);
        fieldsConfig.put('Qty_Total_Allocated_gne__c',500);
        fieldsConfig.put('User_gne__c',testUser.Id);
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Qty_Reserved_gne__c', 200);
        fieldsConfig.put('Qty_Shipped_to_Physician_gne__c', 100);
        objectConfig.put(new SFA2_PFG_to_User_Detail_gne__c(), fieldsConfig);
        sObject pfgToUserDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToUserDetail);
        //prepare PFG to User Detail stop
        
        //prepare PFG to Account Detail start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Distribution_Method_gne__c', 'DTP');
        fieldsConfig.put('Freeze_for_Pending_AOC_gne__c', 'No');
        fieldsConfig.put('Limit_Year_gne__c', String.valueOf(Date.today().year()));
        fieldsConfig.put('Max_Quantity_gne__c', 1000);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Qty_to_Fulfill_gne__c', 500);
        fieldsConfig.put('Qty_Disbursed_gne__c', 200);
        objectConfig.put(new SFA2_PFG_to_Account_Detail_gne__c(), fieldsConfig);
        sObject pfgToAccountDetail = GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        dataToInsert.add(pfgToAccountDetail);
        //prepare PFG to Account Detail stop
        insert dataToInsert;
        //prepare transaction start
        objectConfig = new Map<sObject, Map<String, object>>();
        fieldsConfig = new Map<String, object>();
        fieldsConfig.put('RecordTypeId', GNE_SFA2_PFG_TestHelper.getRecordTypeId(TRANS_TYPE_REQUEST_FF, TRANSACTION_OBJECT_TYPE));
        fieldsConfig.put('From_User_gne__c', testUser.Id);
        fieldsConfig.put('Product_gne__c', product.Id);
        fieldsConfig.put('Distribution_Method_gne__c','DTP');
        fieldsConfig.put('UOM_gne__c',product.UOM_gne__c);
        fieldsConfig.put('Lot_No_gne__c', 'DTP-NA');
        fieldsConfig.put('Account_gne__c', acc.Id);
        fieldsConfig.put('Shipped_Quantity_gne__c', 50);
        fieldsConfig.put('Requested_Quantity_gne__c', 0);
        fieldsConfig.put('Received_Quantity_gne__c', 100);
        fieldsConfig.put('Signature_Status_gne__c', 'Overdue - Freeze 60 days or greater late');
        objectConfig.put(new SFA2_PFG_Transaction_gne__c(), fieldsConfig);
        SFA2_PFG_Transaction_gne__c reqFF = (SFA2_PFG_Transaction_gne__c)GNE_SFA2_PFG_TestHelper.createRecord(objectConfig);
        insert reqFF;
        //prepare transaction stop
        List<SFA2_PFG_Transaction_gne__c> trxs = [Select Name, CreatedDate from SFA2_PFG_Transaction_gne__c where Id =: reqFF.Id];
        reqFF.Transaction_Ref_Number_gne__c = trxs[0].Name;
        update reqFF;
        
        List<SFA2_PFG_to_User_Detail_gne__c> uDetails = [Select Qty_Reserved_gne__c, Qty_Shipped_to_Physician_gne__c from SFA2_PFG_to_User_Detail_gne__c where User_gne__c =: reqFF.From_User_gne__c AND Product_gne__c =: reqFF.Product_gne__c];
        system.assertEquals(1, uDetails.size());
        system.assertEquals(200, uDetails[0].Qty_Reserved_gne__c);
        system.assertEquals(100, uDetails[0].Qty_Shipped_to_Physician_gne__c);
        
        List<SFA2_PFG_to_Account_Detail_gne__c> accDet = [Select Qty_Disbursed_gne__c, Freeze_for_Pending_AOC_gne__c from SFA2_PFG_to_Account_Detail_gne__c where Account_gne__c =: reqFF.Account_gne__c AND Product_gne__c =: reqFF.Product_gne__c AND Limit_Year_gne__c =: String.valueOf(trxs[0].CreatedDate.year())];
        system.assertEquals(1, accDet.size());
        system.assertEquals(300, accDet[0].Qty_Disbursed_gne__c);
        system.assertEquals('Yes', accDet[0].Freeze_for_Pending_AOC_gne__c);
    }
}