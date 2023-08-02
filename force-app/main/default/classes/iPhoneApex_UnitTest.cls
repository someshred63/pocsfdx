/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers. Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 *  @author: Krzysztof Leszek, Roche
 *  Date: 21-February-2010
 *  Description: iPhone API Unit Test Class
 *                           
 *  Modification History
 *  Date        Name        Description
 *                
 */
@isTest
private class iPhoneApex_UnitTest {
    
    private static List<User> objUserList;
    private static List<USER_SAP_IDs_gne__c> objUserSAPList;
    private static Product_vod__c objSampleProduct;
    private static Product_vod__c objDetailProduct;
    private static Test_Script_gne__c objTestScript;
    private static List<Rep_Roster_vod__c> objRepRosterList;
        
    /**
    * Initialize Unit Test Data
    */
    static {
        // Create test user
        // 'Setup-Object DML' needs to run in context of a current user see: 
        // http://community.salesforce.com/t5/Apex-Code-Development/DML-not-allowed-on-user-in-test-context/m-p/98393
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {            
            Profile objProfile  = [SELECT Id FROM Profile WHERE Name = 'Standard User' limit 1];
            UserRole objUserRole= [SELECT Id FROM UserRole WHERE Name = 'Standard User' limit 1];
            objUserList = new List<User>();
            objUserList.add(new User(Alias              = 'beckeya1',
                                    Email               = 'beckeyatest@gene.com',
                                    FirstName           = 'BeckyUTEST',
                                    LastName            = 'AbbeyTEST',                                    
                                    UserName            = 'beckeyatest@gene.com.test',
                                    CommunityNickname   = 'BECKY ABBEY TEST',
                                    //SAP_User_ID_gen__c  = '000',
                                    UserRoleId          = objUserRole.Id,
                                    ProfileId           = objProfile.Id,
                                    TimeZoneSidKey      = 'America/Los_Angeles',
                                    LocaleSidKey        = 'en_US',
                                    EmailEncodingKey    = 'ISO-8859-1',
                                    LanguageLocaleKey   = 'en_US'));  
                                                                
            objUserList.add(new User(Alias              = 'lucass1',
                                    Email               = 'lucasstest@gene.com',
                                    FirstName           = 'LucasUTEST',
                                    LastName            = 'ScottTEST',
                                    UserName            = 'lucasstest@gene.com.test',
                                    CommunityNickname   = 'LUCAS SCOTT TEST',
                                    //SAP_User_ID_gen__c  = '001',          -- SAP User Id has been moved to the User SAP IDs object 
                                    External_Id_gne__c  = 'lucasstest', 
                                    UserRoleId          = objUserRole.Id,
                                    ProfileId           = objProfile.Id,
                                    TimeZoneSidKey      = 'America/Los_Angeles',
                                    LocaleSidKey        = 'en_US',
                                    EmailEncodingKey    = 'ISO-8859-1',
                                    LanguageLocaleKey   = 'en_US'));                                            
            insert objUserList;                                                                 
        }             
        // Add User SAP IDs
        objUserSAPList = new List<USER_SAP_IDs_gne__c>();
        for (Integer i = 0; i < objUserList.size(); i++) {
			objUserSAPList.add(new USER_SAP_IDs_gne__c(User_gne__c 		= objUserList[i].Id,
													   UNIX_ID_gne__c 	= objUserList[i].UserName.substring(0, objUserList[i].UserName.indexOf('@')),
													   SAP_ID_gne__c	= '00' + i, 
	                                    			   Status_gne__c	= true));
        }	                                    			  
       	insert objUserSAPList; 
       
        // Create Sample Product
        objSampleProduct = new Product_vod__c(Name                          = 'TAMIFLU CAPS 90MG SAMPLE KL TEST',
                                              NDC_Number_gne__c             = 'TAMI-001', 
                                              Product_Type_vod__c           = 'Sample',
                                              Description_vod__c            = 'Flu treatment and prevention in adults and children aged 1 year and older.',
                                              SAP_Material_ID_gne__c        = 'SAP TAMI-001',
                                              Manufacturer_vod__c           = 'Roche Laboratories',
                                              Quantity_Per_Case_vod__c      = 10,
                                              Rep_Order_Limit_gne__c        = 100,
                                              Sample_U_M_vod__c             = 'Case',
                                              Sample_Order_Start_Date_gne__c= Date.today().addDays(-2), 
                                              Sample_Order_End_Date_gne__c  = Date.today().addDays(5),
                                              Company_Product_vod__c        = true);
        upsert objSampleProduct;        
        
        // Create Detail Product
        objDetailProduct = new Product_vod__c(Name                      = 'Tamiflu Detail KL Test',
                                              Product_Type_vod__c       = 'Detail',
                                              Manufacturer_vod__c       = 'Roche Laboratories',
                                              Company_Product_vod__c    = true);
        upsert objDetailProduct;         
        
        // Create Test Script
        objTestScript = new Test_Script_gne__c(Name = 'Unit-001', Description_gne__c = 'Test Script Used by Unit Test Class');
        upsert(objTestScript);   
        
        // Create Rep Roster records
        objRepRosterList = new List<Rep_Roster_vod__c>();
        for (Integer i = 0; i < objUserList.size(); i++) {
            String sName = objUserList[i].FirstName + ' ' + objUserList[i].LastName;
            objRepRosterList.add(new Rep_Roster_vod__c(Name = sName, Inspection_Deadline_gne__c = Date.today()));
        }
        upsert objRepRosterList;   
        
        // Approve Rep Roster records
        for (Integer i = 0; i < objRepRosterList.size(); i++) {
			Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
			req.setComments('Approving request.');
			req.setAction('Approve');
			req.setWorkitemId([select Id from ProcessInstanceWorkitem where ProcessInstanceId = :[Select Id from ProcessInstance where Status ='Pending' and TargetObjectId = :objRepRosterList[i].Id].Id].Id);
			Approval.ProcessResult result =  Approval.process(req);          	
        }                   
    }   
    
    /**
    * Verify that validation engine correctly executes sample disbursements using iPhone API
    * (applicable to Test Script Data records having record type = Sample Disbursement iPhone)
    * Test Scenario: 
    *   1. Define sample order for 'BECKY ABBEY TEST' user in the Test Script Data object
    *   2. Define new account in the Test Script Data object
    *   3. Define new shipment ('KL-Unit-S-1') for the order (1) in the Test Script Data object
    *   4. Define shipment acknowledgment in the Test Script Data object (multi-lot shipment)
    *   5. Define sample disbursement using iPhone API from one of the lots included in the shipment in the Test Script Data object
    *   6. Start validation engine
    *   7. Verify that the disbursement has been correctly recorded  
    * Expected result: a. Sample disbursement is correctly recorded in the system   
    *                  b. Validation report correctly shows quantity disbursed   
    */       
    static testMethod void verifyTestSctiptData_SampleDisbursementiPhone() {                                                                                                                                  
        // Initialize test script with data
        // Sample Order
        List<Test_Data_gne__c> objTestScriptList = new List<Test_Data_gne__c>();
        objTestScriptList.add(new Test_Data_gne__c( RecordTypeId            = Schema.SObjectType.Test_Data_gne__c.getRecordTypeInfosByName().get('Sample Order').getRecordTypeId(),
                                                    Sample_gne__c           = objSampleProduct.Name,
                                                    Sample_Lot_Owner_gne__c = objUserList[0].FirstName + ' ' + objUserList[0].LastName,  
                                                    Quantity_gne__c         = 30,
                                                    Test_Script_gne__c      = objTestScript.Id,                 // Reference to the parent test script
                                                    Order_gne__c            = 1));                              // Order in which the test data record will be processed                                                    
        insert objTestScriptList;
        objTestScriptList = [SELECT Name FROM Test_Data_gne__c WHERE Test_Script_gne__c = :objTestScript.Id ORDER BY Order_gne__c ASC];
        // Update order status
        objTestScriptList.add(new Test_Data_gne__c(RecordTypeId             = Schema.SObjectType.Test_Data_gne__c.getRecordTypeInfosByName().get('Sample Shipment API - Update Order Status').getRecordTypeId(),
                                                   Order_Request_Id_gne__c  = objTestScriptList[0].Name,        // Order Name
            									   SAP_Order_Id_gne__c		= 'SAP-0001',		 				// SAP Order Id         
                                                   SAP_Order_Status_gne__c  = 'Acknowledged',                   // Order Status (TRUE = Acknowledged, FALSE = Not Acknowledged)
                                                   Test_Script_gne__c       = objTestScript.Id,                 // Reference to the parent test script
                                                   Order_gne__c             = 2));                              // Order in which the test data record will be processed
        // Define test account                                                   
        objTestScriptList.add(new Test_Data_gne__c(RecordTypeId             = Schema.SObjectType.Test_Data_gne__c.getRecordTypeInfosByName().get('Account').getRecordTypeId(),
                                                   Account_Type_gne__c      = 'Health Care Professional',                                   // Account Type 
                                                   Salutation_gne__c        = 'Ms.',                                                        // Salutation
                                                   First_Name_gne__c        = 'Brook',                                                      // First Name
                                                   Last_Name_gne__c         = 'James_UTest',                                                // Last Name    
                                                   Sample_Lot_Owner_gne__c  = objUserList[0].FirstName + ' ' + objUserList[0].LastName,     // Account Owner
                                                   Address_Line_1_gne__c    = '24 Weatherall Ave',                                          // Address Line 1
                                                   City_gne__c              = 'Los Angeles',                                                // City
                                                   State_gne__c             = 'CA',                                                         // State
                                                   Zip_gne__c               = '10001',                                                      // Zip Code
                                                   License_gne__c           = '987654',                                                     // State License Number for the corresponding State of the Address
                                                   License_Exp_Date_gne__c  = Date.today().addDays(1),                                      // The expiration date for the HCP's State License (must be after today)
                                                   License_Status_gne__c    = 'Valid',                                                      // The Status of the HCP's State License. Only drop off samples to HCPs with Valid Samples.
                                                   Test_Script_gne__c       = objTestScript.Id,                                             // Reference to the parent test script
                                                   Order_gne__c             = 3));                                                     
        // Valid Shipment assigned to an order having Acknowledged status                                                 
        objTestScriptList.add(new Test_Data_gne__c(RecordTypeId             = Schema.SObjectType.Test_Data_gne__c.getRecordTypeInfosByName().get('Sample Shipment API - updateOrCreateShipment').getRecordTypeId(),
                                                   Lot_gne__c               = 'KL-0001,KL-0002',                // Lot Name
                                                   Order_Request_Id_gne__c  = objTestScriptList[0].Name,        // Order Request Id 
                                                   Sample_gne__c            = objSampleProduct.NDC_Number_gne__c,// NDC
                                                   Shipment_Id_gne__c       = 'KL-Unit-S-1',                    // Shipment Id
                                                   Quantity_Shipped_gne__c  = '20,10',                          // Qty
                                                   Tracking_gne__c          = 'KL-UPS-1',                       // UPS Tracking Id
                                                   //SAP_gne__c               = objUserList[0].SAP_User_ID_gen__c,// SAP User Id (the SAP User Id is no longer stored on the user object)
                                                   SAP_gne__c               = objUserSAPList[0].SAP_ID_gne__c,	// SAP User Id
                                                   Expiration_Dates_gne__c   = String.valueOf(Date.today().addDays(1).month()) + '/' +
                                                                               String.valueOf(Date.today().addDays(1).day()) + '/' + 
                                                                               String.valueOf(Date.today().addDays(1).year()), // Expiration Date
                                                   Transferred_From_gne__c  = 'SAP',                            // Transferred From 
                                                   SAP_Order_Status_gne__c  = 'Shipped',                        // Shipment Status
                                                   Test_Script_gne__c       = objTestScript.Id,                 // Reference to the parent test script
                                                   Order_gne__c             = 4));                              // Order in which the test data record will be processed                                                                                                                                                                                                                                                                                                                                          
        upsert objTestScriptList;   // Need to insert the records here as Transaction_To_Acknowledge_gne__c needs to be populated below                                                            
        // Acknowledge shipment                                                                               
        objTestScriptList.add(new Test_Data_gne__c( RecordTypeId                        = Schema.SObjectType.Test_Data_gne__c.getRecordTypeInfosByName().get('Acknowledge Sample Receipt').getRecordTypeId(),
                                                    Transaction_To_Acknowledge_gne__c   = objTestScriptList[3].Id,                          // Reference to the transaction to acknowledge
                                                    Confirmed_Quantity_gne__c           = '20,10',                                          // Confirmed Qty
                                                    Receipt_Comments_gne__c             = 'Receipt Confirmed',                              // Receipt Comments
                                                    Test_Script_gne__c                  = objTestScript.Id,                                 // Reference to the parent test script
                                                    Order_gne__c                        = 5));                                              // Order in which the test data record will be processed 
        // Create disbursement
        objTestScriptList.add(new Test_Data_gne__c( RecordTypeId                        = Schema.SObjectType.Test_Data_gne__c.getRecordTypeInfosByName().get('Sample Disbursement iPhone').getRecordTypeId(),
                                                    // General information
                                                    Account_gne__c                      = objTestScriptList[2].First_Name_gne__c + ' ' + objTestScriptList[2].Last_Name_gne__c, // Account name
                                                    Status_gne__c                       = 'Submitted',                                      // Interaction status
                                                    Comments_gne__c                     = 'Test interaction',                               // Comments                                                 
                                                    Sample_Lot_Owner_gne__c             = objTestScriptList[2].Sample_Lot_Owner_gne__c,     // Account owner
                                                    iPhone_Request_Id_gne__c            = null,                                             // iPhone Request Id
                                                    // Address Information
                                                    Address_Line_1_gne__c               = objTestScriptList[2].Address_Line_1_gne__c,       // Address Line 1
                                                    Address_Line_2_gne__c               = objTestScriptList[2].Address_Line_2_gne__c,       // Address Line 2
                                                    City_gne__c                         = objTestScriptList[2].City_gne__c,                 // City
                                                    State_gne__c                        = objTestScriptList[2].State_gne__c,                // State
                                                    Zip_gne__c                          = objTestScriptList[2].Zip_gne__c,                  // Zip Code
                                                    License_gne__c                      = '987654',                                         // State License Number for the corresponding State of the Address
                                                    // Interaction objective
                                                    //Product_Name_gne__c                   = objDetailProduct.Name,                        // Name of the detail product
                                                    // Call information
                                                    Call_Date_gne__c                    = datetime.now(),                                   // Call Datetime
                                                    Call_Type_gne__c                    = 'Sales Call',                                     // Call Type                                                                                                        
                                                    Completed_gne__c                    = TRUE,                                             // Completed call
                                                    Disclaimer_gne__c                   = 'I understand terms and conditions etc.',         // Disclaimer
                                                    Signature_gne__c                    = 'Boby',                                           // Signature (will be encoded image)
                                                    Signature_Date_gne__c               = Datetime.now(),                                   // Signature Date                                               
                                                    // Sample Information
                                                    Sample_gne__c                       = objSampleProduct.Name,                            // Sample Name
                                                    Lot_gne__c                          = 'KL-0002',                                        // Lot #                                                    
                                                    Quantity_gne__c                     = 7,                                                // Quantity                                                                                                                                                                                                                                                                                                                                                                         
                                                    Test_Script_gne__c                  = objTestScript.Id,                                 // Reference to the parent test script
                                                    Order_gne__c                        = 6));                                              // Order in which the test data record will be processed (6)                                                                                                                
        upsert objTestScriptList;

        // Start the Engine for the test script     
        System.Test.StartTest();
        SampleValidationEngineWrapper.execute(objTestScript.Name);
        System.Test.StopTest();   
        
        // Verify created call record 
        ID sCallID = [SELECT SFDC_Row_Id__c FROM Test_Data_gne__c WHERE Id = :objTestScriptList[5].Id limit 1].SFDC_Row_Id__c;      // Retreive call ID
        ID sAccountID = [SELECT SFDC_Row_Id__c FROM Test_Data_gne__c WHERE Id = :objTestScriptList[2].Id limit 1].SFDC_Row_Id__c;   // Retreive account ID
        Call2_vod__c[] objCall = [SELECT OwnerId, Name, RecordType.Name, Disbursed_To_vod__c, Sample_Card_vod__c, Sample_Card_Reason_vod__c,
                                        Completion_Type_gne__c, Account_vod__c, Status_vod__c, Signature_Date_vod__c, Signature_vod__c, 
                                        Call_Type_vod__c, Interaction_Type_gne__c, License_vod__c, Call_Date_vod__c, Call_Datetime_vod__c, 
                                        Last_Device_vod__c, Is_Sampled_Call_vod__c, Address_Line_1_vod__c, City_vod__c, State_vod__c, Address_Line_2_vod__c, 
                                        Zip_vod__c, Parent_Address_vod__r.License_Valid_To_Sample_vod__c, Parent_Address_vod__r.License_Status_vod__c,
                                        Parent_Address_vod__r.License_Expiration_Date_vod__c, Parent_Address_vod__r.License_vod__c, Call_Comments_vod__c,
                                        Address_vod__c, Interaction_Status_gne__c, Detailed_Products_vod__c
                                  FROM Call2_vod__c WHERE Id = :sCallID]; 
        System.AssertEquals(1, objCall.size());       
        System.AssertEquals(objUserList[0].Id,                              objCall[0].OwnerId);                    // Call owner
        System.AssertEquals('Meeting Brief SFA-Primary-Care',               objCall[0].RecordType.Name);            // Call record type
        System.AssertEquals(null,                                           objCall[0].Disbursed_To_vod__c);        // Veeva does not populate the field !!!
        System.AssertEquals(null,                                           objCall[0].Sample_Card_vod__c);         // Sample Card number
        System.AssertEquals(null,                                           objCall[0].Sample_Card_Reason_vod__c);  // Sample Card reason
        System.AssertEquals('Completed',                                    objCall[0].Completion_Type_gne__c);     // Completion status
        System.AssertEquals(sAccountID,                                     objCall[0].Account_vod__c);             // Account ID
        System.AssertEquals('Saved_vod',                                    objCall[0].Status_vod__c);              // Status
        System.AssertEquals(objTestScriptList[5].Signature_Date_gne__c,     objCall[0].Signature_Date_vod__c);      // Signature Date
        System.AssertEquals(objTestScriptList[5].Signature_gne__c,          objCall[0].Signature_vod__c);           // Signature
        System.AssertEquals('Detail with Sample',                           objCall[0].Call_Type_vod__c);           // Call Type
        System.AssertEquals(objTestScriptList[5].Call_Type_gne__c,          objCall[0].Interaction_Type_gne__c);    // Interaction Type
        System.AssertEquals(objTestScriptList[5].License_gne__c,            objCall[0].License_vod__c);             // License #
        System.AssertEquals(objTestScriptList[5].Call_Date_gne__c.date(),   objCall[0].Call_Date_vod__c);           // Call Date
        System.AssertEquals(objTestScriptList[5].Call_Date_gne__c,          objCall[0].Call_Datetime_vod__c);       // Call Datetime
        //System.AssertEquals(null,                                 objCall[0].Last_Device_vod__c);         // Last Device      -- should be populated
        System.AssertEquals(TRUE,                                           objCall[0].Is_Sampled_Call_vod__c);     // Is Sampled Call
        /*System.AssertEquals(objTestScriptList[5].Address_Line_1_gne__c,       objCall[0].Address_Line_1_vod__c);      // Address Line 1
        System.AssertEquals(objTestScriptList[5].Address_Line_2_gne__c,     objCall[0].Address_Line_2_vod__c);      // Address Line 2
        System.AssertEquals(objTestScriptList[5].City_gne__c,               objCall[0].City_vod__c);                // City
        System.AssertEquals(objTestScriptList[5].State_gne__c,              objCall[0].State_vod__c);               // State
        System.AssertEquals(objTestScriptList[5].Zip_gne__c,                objCall[0].Zip_vod__c);                 // Zip Code*/
        System.AssertEquals('Valid',                                        objCall[0].Parent_Address_vod__r.License_Valid_To_Sample_vod__c);   // License Valid To Sample
        System.AssertEquals('Valid_vod',                                    objCall[0].Parent_Address_vod__r.License_Status_vod__c);            // License Status
        System.AssertEquals(objTestScriptList[2].License_Exp_Date_gne__c,   objCall[0].Parent_Address_vod__r.License_Expiration_Date_vod__c);   // License Expiration Date
        System.AssertEquals(objTestScriptList[2].License_gne__c,            objCall[0].Parent_Address_vod__r.License_vod__c);                   // License #
        //System.AssertEquals(objTestScriptList[5].Comments_gne__c,         objCall[0].Call_Comments_vod__c);       // Call comments        
        System.AssertEquals(objTestScriptList[5].Address_Line_1_gne__c +', '+objTestScriptList[5].City_gne__c +', '+objTestScriptList[5].State_gne__c+', '+objTestScriptList[5].Zip_gne__c,objCall[0].Address_vod__c);          // Full Address
        System.AssertEquals('Completed',                                    objCall[0].Interaction_Status_gne__c);  // Interaction status
        //System.AssertEquals(objDetailProduct.Name,                            objCall[0].Detailed_Products_vod__c);   // Detailed Products       
        
        // Verify created sample call records
        Call2_Sample_vod__c[] objCallSample = [SELECT Account_vod__c, Call_Date_vod__c, Quantity_vod__c, Lot_vod__c, Product_vod__c FROM Call2_Sample_vod__c WHERE Call2_vod__c = :sCallID];                       
        System.AssertEquals(1, objCallSample.size());       
        System.AssertEquals(sAccountID,                                     objCallSample[0].Account_vod__c);   // Account Id
        System.AssertEquals(objTestScriptList[5].Call_Date_gne__c.date(),   objCallSample[0].Call_Date_vod__c); // Call Date
        System.AssertEquals(7,                                              objCallSample[0].Quantity_vod__c);  // Quantity
        System.AssertEquals('KL-0002',                                      objCallSample[0].Lot_vod__c);       // Lot#
        System.AssertEquals(objSampleProduct.Id,                            objCallSample[0].Product_vod__c);   // Sample Product Id
         
        // Verify Call Detail Record 
        //Call2_Detail_vod__c[] objCallDetail = [SELECT Product_vod__c, Type_vod__c FROM Call2_Detail_vod__c WHERE Call2_vod__c = :sCallID];        
        //System.AssertEquals(1, objCallDetail.size());       
        //System.AssertEquals(objDetailProduct.Id,                          objCallDetail[0].Product_vod__c);   // Detail Product Id
        //System.AssertEquals('Paper_Detail_vod',                               objCallDetail[0].Type_vod__c);      // Detail Product Type
                
        // Verify created sample disbursement transaction
        String sampleLotExternalId  = objUserList[0].Id + '_' + objSampleProduct.Name.replaceAll(' ', '_') + '_KL-0002'; 
        Sample_Lot_vod__c[] objSampleLot = [SELECT Id, OwnerId, Name, Sample_vod__c, U_M_vod__c, Active_vod__c, Expiration_Date_vod__c FROM Sample_Lot_vod__c WHERE Sample_Lot_Id_vod__c  = :sampleLotExternalId];
        Sample_Transaction_vod__c[] objSampleTx = [SELECT Id, Name, Type_vod__c, RecordType.Name, Adjust_For_vod__c, Adjusted_Date_vod__c, Lot_vod__c, Transferred_From_Name_vod__c,
                                                          Transferred_From_vod__c, Transfer_To_Name_vod__c, Transfer_To_vod__c, Transferred_Date_vod__c, Account_vod__c,
                                                          Address_Line_1_vod__c, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Call_Date_vod__c,
                                                          Call_Datetime_vod__c, Call_Name_vod__c, Comments_vod__c,Confirmed_Quantity_vod__c, Disbursed_To_vod__c,
                                                          Disclaimer_vod__c, Discrepancy_vod__c, Group_Identifier_vod__c, Group_Transaction_Id_vod__c,
                                                          Inventory_Impact_Quantity_vod__c, License_vod__c, Lot_Name_vod__c, Quantity_vod__c, Receipt_Comments_vod__c,
                                                          Reason_vod__c, Received_vod__c, Ref_Transaction_Id_vod__c, Return_To_vod__c, Sample_Card_Reason_vod__c,
                                                          Sample_Card_vod__c, Sample_vod__c, Shipment_Id_vod__c, Status_vod__c, U_M_vod__c, Signature_Date_vod__c, Signature_vod__c                                                             
                                                    FROM Sample_Transaction_vod__c WHERE Lot_vod__c = :objSampleLot[0].Id AND Type_vod__c = 'Disbursement_vod'];                                                           
        System.AssertEquals(1, objSampleTx.size());           
        System.AssertEquals('Disbursement_vod',                                         objSampleTx[0].RecordType.Name);                // Transaction record type must be 'Disbursement_vod'
        System.AssertEquals(null,                                                       objSampleTx[0].Adjust_For_vod__c);              // Adjusted For
        System.AssertEquals(null,                                                       objSampleTx[0].Adjusted_Date_vod__c);           // Adjusted Date                       
        System.AssertEquals(null,                                                       objSampleTx[0].Transferred_From_Name_vod__c);   // Transferred From Name        
        System.AssertEquals(null,                                                       objSampleTx[0].Transferred_From_vod__c);        // Transferred From Id
        System.AssertEquals(null,                                                       objSampleTx[0].Transfer_To_Name_vod__c);        // Transfer To 
        System.AssertEquals(null,                                                       objSampleTx[0].Transfer_To_vod__c);             // Transfer To Id                
        System.AssertEquals(null,                                                       objSampleTx[0].Transferred_Date_vod__c);        // Transferred Date
        System.AssertEquals(sAccountID,                                                 objSampleTx[0].Account_vod__c);                 // Account Id
        /*System.AssertEquals(objTestScriptList[5].Address_Line_1_gne__c,                   objSampleTx[0].Address_Line_1_vod__c);          // Address Line 1
        System.AssertEquals(objTestScriptList[5].Address_Line_2_gne__c,                 objSampleTx[0].Address_Line_2_vod__c);          // Address Line 2
        System.AssertEquals(objTestScriptList[5].City_gne__c,                           objSampleTx[0].City_vod__c);                    // City
        System.AssertEquals(objTestScriptList[5].State_gne__c,                          objSampleTx[0].State_vod__c);                   // State                
        System.AssertEquals(objTestScriptList[5].Zip_gne__c,                            objSampleTx[0].Zip_vod__c);                     // Zip Code*/        
        System.AssertEquals(objTestScriptList[5].Call_Date_gne__c.date(),               objSampleTx[0].Call_Date_vod__c);               // Call Date
        System.AssertEquals(objTestScriptList[5].Call_Date_gne__c,                      objSampleTx[0].Call_Datetime_vod__c);           // Call Date Time
        System.AssertEquals(objCall[0].Name,                                            objSampleTx[0].Call_Name_vod__c);               // Call Name        
        System.AssertEquals(null,                                                       objSampleTx[0].Comments_vod__c);                // Comments     
        System.AssertEquals(null,                                                       objSampleTx[0].Confirmed_Quantity_vod__c);      // Confirmed Qty
        System.AssertNotEquals(null,                                                    objSampleTx[0].Disbursed_To_vod__c);            // Disbursed To
        System.AssertEquals(objTestScriptList[5].Disclaimer_gne__c,                     objSampleTx[0].Disclaimer_vod__c);              // Disclaimer
        System.AssertEquals(0,                                                          objSampleTx[0].Discrepancy_vod__c);             // Discrepancy                      
        System.AssertEquals(objCall[0].Name,                                            objSampleTx[0].Group_Identifier_vod__c);        // Group Identifier
        System.AssertEquals(objCall[0].Name,                                            objSampleTx[0].Group_Transaction_Id_vod__c);    // Group Transaction Id
        System.AssertEquals(-objTestScriptList[5].Quantity_gne__c,                      objSampleTx[0].Inventory_Impact_Quantity_vod__c);// Inventory Impact Qty
        System.AssertEquals(objTestScriptList[2].License_gne__c,                        objSampleTx[0].License_vod__c);                 // License Name
        System.AssertEquals('KL-0002',                                                  objSampleTx[0].Lot_Name_vod__c);                // Lot Name 
        System.AssertEquals(objTestScriptList[5].Quantity_gne__c,                       objSampleTx[0].Quantity_vod__c);                // Qty
        System.AssertEquals(null,                                                       objSampleTx[0].Receipt_Comments_vod__c);        // Receipt Comments
        System.AssertEquals(null,                                                       objSampleTx[0].Reason_vod__c);                  // Reason           
        System.AssertEquals(FALSE,                                                      objSampleTx[0].Received_vod__c);                // Received
        System.AssertEquals(null,                                                       objSampleTx[0].Ref_Transaction_Id_vod__c);      // Ref Transaction Id
        System.AssertEquals(null,                                                       objSampleTx[0].Return_To_vod__c);               // Return To
        System.AssertEquals(null,                                                       objSampleTx[0].Sample_Card_Reason_vod__c);      // Sample Card Reason
        System.AssertEquals(null,                                                       objSampleTx[0].Sample_Card_vod__c);             // Sample Card #                                
        System.AssertEquals(objSampleProduct.Name,                                      objSampleTx[0].Sample_vod__c);                  // Sample Name
        System.AssertEquals(null,                                                       objSampleTx[0].Shipment_Id_vod__c);             // Shipment Id      
        System.AssertEquals('Submitted_vod',                                            objSampleTx[0].Status_vod__c);                  // Status
        System.AssertEquals(null,                                                       objSampleTx[0].U_M_vod__c);                     // U/M
        System.AssertEquals(objTestScriptList[5].Signature_Date_gne__c,                 objSampleTx[0].Signature_Date_vod__c);          // Signature Date
        System.AssertEquals(objTestScriptList[5].Signature_gne__c,                      objSampleTx[0].Signature_vod__c);               // Signature                                                                   
                                                            
        // Verify validation report
        String sShippedTo   = objUserList[0].FirstName + ' ' + objUserList[0].LastName;         
        System.AssertEquals(1, [SELECT count() FROM Sample_Validation_gne__c WHERE 
                                Username_gne__c = :sShippedTo AND Lot_gne__c = 'KL-0001' AND
                                Sample_gne__c = :objSampleProduct.Name AND Transferred_In_gne__c = 20 AND Transferred_In_Exp_gne__c = 20 AND
                                Transferred_Out_gne__c = 0 AND Transferred_Out_Exp_gne__c = 0 AND Pending_Sample_Receipt_gne__c = 0 AND
                                Pending_Sample_Receipt_Exp_gne__c = 0 AND Adjusted_gne__c = 0 AND Adjusted_Exp_gne__c = 0 AND 
                                Disbursed_gne__c = 0 AND Disbursed_Exp_gne__c = 0 AND Returned_gne__c = 0 AND Returned_Exp_gne__c = 0 AND Inventory_Total_gne__c = 20 AND 
                                Inventory_Total_Exp_gne__c = 20 AND Valid_gne__c = 'Yes' AND Issue_Count_gne__c = 0]);                                      
        System.AssertEquals(1, [SELECT count() FROM Sample_Validation_gne__c WHERE 
                                Username_gne__c = :sShippedTo AND Lot_gne__c = 'KL-0002' AND
                                Sample_gne__c = :objSampleProduct.Name AND Transferred_In_gne__c = 10 AND Transferred_In_Exp_gne__c = 10 AND
                                Transferred_Out_gne__c = 0 AND Transferred_Out_Exp_gne__c = 0 AND Pending_Sample_Receipt_gne__c = 0 AND
                                Pending_Sample_Receipt_Exp_gne__c = 0 AND Adjusted_gne__c = 0 AND Adjusted_Exp_gne__c = 0 AND 
                                Disbursed_gne__c = 7 AND Disbursed_Exp_gne__c = 7 AND Returned_gne__c = 0 AND Returned_Exp_gne__c = 0 AND Inventory_Total_gne__c = 3 AND 
                                Inventory_Total_Exp_gne__c = 3 AND Valid_gne__c = 'Yes' AND Issue_Count_gne__c = 0]);                                        
    }     
        
}