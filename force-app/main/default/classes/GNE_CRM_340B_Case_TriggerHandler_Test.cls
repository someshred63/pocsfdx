@isTest
private class GNE_CRM_340B_Case_TriggerHandler_Test {

    @testSetup 
    private static void setup() {
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'New';
        insert case340B;
        
		List<GNE_MCCO_CRM_340B_Case_Dates__c> lConfigs = new List<GNE_MCCO_CRM_340B_Case_Dates__c>();
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Duplicate Discount - TCD', Days__c = '60'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Duplicate Discount - ATCD', Days__c = '14'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Duplicate Discount - ETCD', Days__c = '42'));
		
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Diversion - TCD', Days__c = '60'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Diversion - ATCD', Days__c = '14'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Diversion - ETCD', Days__c = '42'));
		
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Self-disclosure - TCD', Days__c = '30'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Self-disclosure - ATCD', Days__c = '7'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Self-disclosure - ETCD', Days__c = '21'));
		
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Initiative - TCD', Days__c = '60'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Initiative - ATCD', Days__c = '7'));
		lConfigs.add(new GNE_MCCO_CRM_340B_Case_Dates__c(Name = 'Initiative - ETCD', Days__c = '21'));  
		insert lConfigs;
    }

    private static User createUser(String name, Id profileId, Boolean toInsert) {
        User user = new User(
            Alias = 'standt',
            Email = name + 'user@veevasystems.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = name + 'user@veevasystems.com'
        );
        system.debug(user);
        if (toInsert) insert user;
        return user;
    }
    
    private static testMethod void testValidateDeletion() {
        GNE_CRM_340B_Case__c case340B = [ SELECT Id, Case_Status__c FROM GNE_CRM_340B_Case__c LIMIT 1 ];
        case340B.Case_Status__c = 'Invoiced';
        update case340B;
        
        Test.startTest();
	        try {
	            delete case340B;
	        } catch (Exception e){
	            system.assert(e.getMessage().contains('You can only delete a case only with status New'));
	        }
        Test.stopTest();
    }
    
    private static testMethod void testSetStatusToAssigned() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Diversion';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        system.assertEquals('Assigned', [ SELECT Case_Status__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ].Case_Status__c);
    }

    private static testMethod void testSetStatusToEngagement() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Diversion';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        case340B.Non_340B_AM_Notified__c = system.today();
        case340B.Case_Plan_Created__c = system.today();
        case340B.Case_Plan__c = 'htttp://example.org';
        case340B.CE_Contacted__c = system.today();
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        system.assertEquals('Engagement', [ SELECT Case_Status__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ].Case_Status__c);
    }

    private static testMethod void testSetStatusToInvoiced() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Diversion';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        case340B.Non_340B_AM_Notified__c = system.today();
        case340B.Case_Plan_Created__c = system.today();
        case340B.Case_Plan__c = 'htttp://example.org';
        case340B.CE_Contacted__c = system.today();
        case340B.CE_Initial_Response__c = system.today();
        case340B.Agreed_Upon_Recovery__c = 12;
        case340B.Agreed_Upon_Evaluation_Period_Start_Date__c = system.today();
        case340B.Agreed_Upon_Evaluation_Period_End_Date__c = system.today();
        case340B.Underlying_Violation__c = 'Human error';
        case340B.Invoice_Requested__c = system.today();

        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        system.assertEquals('Invoiced', [ SELECT Case_Status__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ].Case_Status__c);
    }
    
    private static testMethod void testSetStatusToClosed() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Diversion';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        case340B.Non_340B_AM_Notified__c = system.today();
        case340B.Case_Plan_Created__c = system.today();
        case340B.Case_Plan__c = 'htttp://example.org';
        case340B.CE_Contacted__c = system.today();
        case340B.CE_Initial_Response__c = system.today();
        case340B.Agreed_Upon_Recovery__c = 12;
        case340B.Agreed_Upon_Evaluation_Period_Start_Date__c = system.today();
        case340B.Agreed_Upon_Evaluation_Period_End_Date__c = system.today();
        case340B.Underlying_Violation__c = 'Human error'; 
        case340B.Invoice_Requested__c = system.today();
        case340B.Invoice_Generated__c = system.today();
        case340B.Invoice_Sent_to_CE__c = system.today();
        case340B.Invoice_Received_by_CE__c = system.today();
        case340B.Payment_Received__c = system.today();
        case340B.Close_out_Letter_Sent__c = system.today();
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        system.assertEquals('Closed', [ SELECT Case_Status__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ].Case_Status__c);
    }
    
    private static testMethod void testSetCompletionDateForDuplicateDiscount() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Duplicate Discount';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        GNE_CRM_340B_Case__c resultCase =  [ SELECT Target_Completion_Date__c, Assigned_Target_Completion_Date__c, Engagement_Target_Completion_Date__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ];
        system.assertEquals(system.today().addDays(60), resultCase.Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(14), resultCase.Assigned_Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(42), resultCase.Engagement_Target_Completion_Date__c);
    }
    
    private static testMethod void testSetCompletionDateForDiversion() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Diversion';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        GNE_CRM_340B_Case__c resultCase =  [ SELECT Target_Completion_Date__c, Assigned_Target_Completion_Date__c, Engagement_Target_Completion_Date__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ];
        system.assertEquals(system.today().addDays(60), resultCase.Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(14), resultCase.Assigned_Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(42), resultCase.Engagement_Target_Completion_Date__c);
    }
    

    private static testMethod void testSetCompletionDateForSelfDisclosure() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Self-disclosure';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        GNE_CRM_340B_Case__c resultCase =  [ SELECT Target_Completion_Date__c, Assigned_Target_Completion_Date__c, Engagement_Target_Completion_Date__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ];
        system.assertEquals(system.today().addDays(30), resultCase.Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(7), resultCase.Assigned_Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(21), resultCase.Engagement_Target_Completion_Date__c);
    }
    
    private static testMethod void testValidateInvoiceSection() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Self-disclosure';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        case340B.Non_340B_AM_Notified__c = system.today();
        case340B.Case_Plan_Created__c = system.today();
        case340B.Case_Plan__c = 'htttp://example.org';
        case340B.CE_Contacted__c = system.today();
        case340B.CE_Initial_Response__c = system.today();
        case340B.Agreed_Upon_Recovery__c = 12;
        case340B.Agreed_Upon_Evaluation_Period_Start_Date__c = system.today();
        case340B.Agreed_Upon_Evaluation_Period_End_Date__c = system.today();
        case340B.Underlying_Violation__c = 'Human error';
        case340B.Invoice_Requested__c = system.today();
        insert case340B;
        
        GNE_CRM_340B_Case__c tempCase340B = [SELECT Case_Status__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
        System.assertEquals(GNE_CRM_340B_Case_TriggerHandler.CASE_STATUS_INVOICED, tempCase340B.Case_Status__c);
        
        Test.startTest();
        	case340B.Invoice_Type__c = GNE_CRM_340B_Case_TriggerHandler.INVOICE_TYPE_NOTAPPLICABLE;
            case340B.Invoice_Requested__c = null;
        	update case340B;
        Test.stopTest();
        
        case340B = [SELECT Case_Status__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
        System.assertEquals(GNE_CRM_340B_Case_TriggerHandler.CASE_STATUS_CLOSED, case340B.Case_Status__c);        
    }
    
    private static testMethod void testValidateInvoiceSectionNegativeScenario() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Self-disclosure';
        case340B.Case_Status__c = 'New';
        case340B.X340B_Account_Manager__c = u.Id;
        case340B.Non_340B_AM_Notified__c = system.today();
        case340B.Case_Plan_Created__c = system.today();
        case340B.Case_Plan__c = 'htttp://example.org';
        case340B.CE_Contacted__c = system.today();
        case340B.CE_Initial_Response__c = system.today();
        case340B.Agreed_Upon_Recovery__c = 12;
        case340B.Agreed_Upon_Evaluation_Period_Start_Date__c = system.today();
        case340B.Agreed_Upon_Evaluation_Period_End_Date__c = system.today();
        case340B.Underlying_Violation__c = 'Human error';
        case340B.Invoice_Requested__c = system.today();
        insert case340B;
        
        GNE_CRM_340B_Case__c tempCase340B = [SELECT Case_Status__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
        System.assertEquals(GNE_CRM_340B_Case_TriggerHandler.CASE_STATUS_INVOICED, tempCase340B.Case_Status__c);
        
        Test.startTest();
        	case340B.Invoice_Type__c = GNE_CRM_340B_Case_TriggerHandler.INVOICE_TYPE_NOTAPPLICABLE;
        	case340B.Invoice_Requested__c = system.today();
        	case340B.Invoice_Generated__c = system.today();
        	Boolean isExceptionRised = false;
        	String exceptionStr = '';
            try {
                update case340B;
            } catch (Exception ex) {
                isExceptionRised = true;
                exceptionStr = ex.getMessage();
            }
        Test.stopTest();
        
        System.assertEquals(true, isExceptionRised);        
        System.assertEquals(true, exceptionStr.contains('Invoice Requested'));     
        System.assertEquals(true, exceptionStr.contains('Invoice Generated')); 
        System.assertEquals(true, exceptionStr.contains('Please clear the following fields as these are not required when there is no invoicing and when Invoice Type is set to')); 
    }
    
    private static testMethod void testSetCompletionDateForInitiative() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.X340B_Account_Manager__c = u.Id;
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        GNE_CRM_340B_Case__c resultCase =  [ SELECT Target_Completion_Date__c, Assigned_Target_Completion_Date__c, Engagement_Target_Completion_Date__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ];
        system.assertEquals(system.today().addDays(60), resultCase.Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(7), resultCase.Assigned_Target_Completion_Date__c);
        system.assertEquals(system.today().addDays(21), resultCase.Engagement_Target_Completion_Date__c);
    }
    
    
    private static testMethod void testSetState() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User u = createUser('example1', profileId, true);
        
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.Account__c = acc.Id;
        
        insert new Address_vod__c(
            Account_vod__c = acc.Id,
            State_vod__c = 'CA',
            Primary_vod__c = true
        );
        
        insert new Address_vod__c(
            Account_vod__c = acc.Id,
            State_vod__c = 'TX',
            Primary_vod__c = false
        );
        
        Test.startTest();
            insert case340B;
        Test.stopTest();
        
        GNE_CRM_340B_Case__c resultCase =  [ SELECT State__c FROM GNE_CRM_340B_Case__c ORDER BY CreatedDate DESC LIMIT 1 ];
        system.assertEquals('CA', resultCase.State__c);
    }
    
    @isTest
    static void testNDCCodeOnInsert() {        
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        GNE_MCCO_340B_ProductMapping__c pm1 = new GNE_MCCO_340B_ProductMapping__c(Name = '00004024515', Product_Name__c = 'Invirase Caps 200mg 270');
        GNE_MCCO_340B_ProductMapping__c pm2 = new GNE_MCCO_340B_ProductMapping__c(Name = '50242008801', Product_Name__c = 'KADCYLA - 100 mg');
        insert new List<GNE_MCCO_340B_ProductMapping__c>{pm1, pm2};
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.Account__c = acc.Id;
        case340B.Negotiation_Products__c = 'Invirase Caps 200mg 270;KADCYLA - 100 mg';
        case340B.Initial_Products__c =  'Invirase Caps 200mg 270;KADCYLA - 100 mg';
        
        Test.startTest();
            insert case340B;    
        Test.stopTest();
        
        case340B = [SELECT NDC_Negotiation_Products__c, Negotiation_Product_with_NDC__c, Initial_Product_with_NDC__c, NDC_Initial_Products__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
        System.assertEquals('<ul><li> Invirase Caps 200mg 270 (00004024515)</li><li> KADCYLA - 100 mg (50242008801)</li></ul>', case340B.Negotiation_Product_with_NDC__c);
        System.assertEquals('00004024515;50242008801', case340B.NDC_Negotiation_Products__c);     
        System.assertEquals('<ul><li> Invirase Caps 200mg 270 (00004024515)</li><li> KADCYLA - 100 mg (50242008801)</li></ul>', case340B.Initial_Product_with_NDC__c);
        System.assertEquals('00004024515;50242008801', case340B.NDC_Initial_Products__c); 
    }

    @isTest
    static void testDeleteCase() {
        Account acc = new Account(Name = 'Test');
        insert acc;

        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'New';
        case340B.Account__c = acc.Id;

        Test.startTest();

            insert case340B;
            delete case340B;
            Account accountRecord = [Select X340B_Open_Case__c From Account Where Id =: acc.Id];
            System.assertEquals(false, accountRecord.X340B_Open_Case__c);

        Test.stopTest();

    }
    
    
    @isTest
    static void testNDCCodeOnUpdate() {        
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        GNE_MCCO_340B_ProductMapping__c pm1 = new GNE_MCCO_340B_ProductMapping__c(Name = '00004024515', Product_Name__c = 'Invirase Caps 200mg 270');
        GNE_MCCO_340B_ProductMapping__c pm2 = new GNE_MCCO_340B_ProductMapping__c(Name = '50242008801', Product_Name__c = 'KADCYLA - 100 mg');
        insert new List<GNE_MCCO_340B_ProductMapping__c>{pm1, pm2};
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.Account__c = acc.Id;
        case340B.Negotiation_Products__c = 'Invirase Caps 200mg 270;KADCYLA - 100 mg';
        case340B.Initial_Products__c =  'Invirase Caps 200mg 270;KADCYLA - 100 mg';
        insert case340B;
        
        case340B = [SELECT NDC_Negotiation_Products__c, Negotiation_Product_with_NDC__c, Negotiation_Products__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
        System.assertEquals('<ul><li> Invirase Caps 200mg 270 (00004024515)</li><li> KADCYLA - 100 mg (50242008801)</li></ul>', case340B.Negotiation_Product_with_NDC__c);
        System.assertEquals('00004024515;50242008801', case340B.NDC_Negotiation_Products__c); 
        
        Test.startTest();
        	case340B.Negotiation_Products__c = 'Invirase Caps 200mg 270';
        	case340B.Initial_Products__c = 'Invirase Caps 200mg 270';
        	update case340B;
        
            case340B = [SELECT NDC_Negotiation_Products__c, Negotiation_Product_with_NDC__c, Initial_Product_with_NDC__c, NDC_Initial_Products__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
            System.assertEquals('<ul><li> Invirase Caps 200mg 270 (00004024515)</li></ul>', case340B.Negotiation_Product_with_NDC__c);
            System.assertEquals('00004024515', case340B.NDC_Negotiation_Products__c);
        	System.assertEquals('<ul><li> Invirase Caps 200mg 270 (00004024515)</li></ul>', case340B.Initial_Product_with_NDC__c);
            System.assertEquals('00004024515', case340B.NDC_Initial_Products__c);
            
            case340B.Negotiation_Products__c = '';
            update case340B;
       
        Test.stopTest();
        
        case340B = [SELECT NDC_Negotiation_Products__c, Negotiation_Product_with_NDC__c, Negotiation_Products__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
        System.assertEquals(null, case340B.Negotiation_Product_with_NDC__c);
        System.assertEquals(null, case340B.NDC_Negotiation_Products__c);  
        
    }
    
    @isTest
    static void testNDCCodeOnUpdateNoConfig() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.Account__c = acc.Id;
        case340B.Negotiation_Products__c = 'Invirase Caps 200mg 270;KADCYLA - 100 mg';
        
        Test.startTest();
            insert case340B;    
        Test.stopTest();
        
        case340B = [SELECT NDC_Negotiation_Products__c, Negotiation_Product_with_NDC__c, Negotiation_Products__c FROM GNE_CRM_340B_Case__c WHERE Id =:case340B.Id];
        System.assertEquals('<ul><li> Invirase Caps 200mg 270 (no code found)</li><li> KADCYLA - 100 mg (no code found)</li></ul>', case340B.Negotiation_Product_with_NDC__c);
        System.assertEquals(null, case340B.NDC_Negotiation_Products__c);           
    }
    
    @isTest
    static void testSetApprovedDateOnInsertPositive() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User uManager = createUser('manager', profileId, true);
        User uRun = createUser('340user', profileId, false);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.X340B_Account_Manager__c = uManager.Id;
        
        System.runAs(uRun) {
            Test.startTest();
            	insert case340B;
        	Test.stopTest();
            
            case340B = [SELECT Case_Approved_Date__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];        
        	System.assertEquals(System.today(), case340B.Case_Approved_Date__c);  
        }                     
    }
    
    @isTest
    static void testSetApprovedDateOnInsertNegative() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User uRun = createUser('340user', profileId, false);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        
        System.runAs(uRun) {
            Test.startTest();
            	insert case340B;
        	Test.stopTest();
            
            case340B = [SELECT Case_Approved_Date__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];        
        	System.assertEquals(null, case340B.Case_Approved_Date__c);
        }
    }
    
    @isTest
    static void testSetApprovedDateOnUpdatePositive() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User uManager = createUser('manager', profileId, true);
        User uRun = createUser('340user', profileId, false);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        insert case340B;
        
        case340B = [SELECT Case_Approved_Date__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];        
        System.assertEquals(null, case340B.Case_Approved_Date__c);
        
        System.runAs(uRun) {
            Test.startTest();
            	case340B.X340B_Account_Manager__c = uManager.Id;
            	update case340B;
        	Test.stopTest();
            
            case340B = [SELECT Case_Approved_Date__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];        
        	System.assertEquals(System.today(), case340B.Case_Approved_Date__c);  
        }          
    }
    
    @isTest
    static void testSetApprovedDateOnUpdateNegative() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User uManager = createUser('manager', profileId, false);
        User uManager2 = createUser('manager2', profileId, false);
        insert new List<user>{uManager, uManager2};
        User uRun = createUser('340user', profileId, false);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        insert case340B;
        
        case340B = [SELECT Case_Approved_Date__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];        
        System.assertEquals(null, case340B.Case_Approved_Date__c);
        
        System.runAs(uRun) {
            Test.startTest();
            	case340B.X340B_Account_Manager__c = uManager.Id;
            	update case340B;
            
            	case340B = [SELECT Case_Approved_Date__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];        
        		System.assertEquals(System.today(), case340B.Case_Approved_Date__c); 
            	case340B.Case_Approved_Date__c = System.today().addDays(-3);
            	case340B.X340B_Account_Manager__c = null;
            	update case340B;
            
            	case340B.X340B_Account_Manager__c = uManager2.Id;
            	update case340B;            
            
        	Test.stopTest();
            
            case340B = [SELECT Case_Approved_Date__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];        
        	System.assertEquals(System.today().addDays(-3), case340B.Case_Approved_Date__c); 
        }    
    }
    
    @isTest
    static void testSetFutureSavings() {
        Id profileId = [SELECT Name FROM Profile WHERE Profile.Name = 'GNE-MCCO-340B' ].Id;
        User uManager = createUser('manager', profileId, true);
        User uRun = createUser('340user', profileId, false);
        
        GNE_CRM_340B_Case__c case340B = new GNE_CRM_340B_Case__c();
        case340B.Case_Type__c = 'Initiative';
        case340B.Case_Status__c = 'Assigned';
        case340B.Future_Savings_Amount1__c = 1;
        case340B.Future_Savings_Amount2__c = 2;
        case340B.Future_Savings_Amount3__c = 3;
        case340B.Future_Savings_Amount4__c = 4;
        insert case340B;
        
        System.runAs(uRun) {
            Test.startTest();
            	case340B = [SELECT Future_Savings_TotalAmount__c FROM GNE_CRM_340B_Case__c WHERE Id = :case340B.Id];
            	System.assertEquals(10, case340B.Future_Savings_TotalAmount__c);
        	Test.stopTest();
        }          
    }
}