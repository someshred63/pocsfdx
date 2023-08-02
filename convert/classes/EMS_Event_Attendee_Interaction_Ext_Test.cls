@isTest
private class EMS_Event_Attendee_Interaction_Ext_Test {

    static testMethod void insertNewHCPAndDelete() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        Account acc = EMS_Test_Util.createAndInsertAccount('Tester', 'Test');

        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createStaticFMVAttendees(events, acc);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            String attJSON = JSON.serialize(attendees);

            EMS_Event_Attendee_Interaction_Ext.saveEventAttendees(events[0].Id, attJSON, true);

            List<EMS_Event_Attendee_Interaction_Ext.AttendeeWrapper> attResult = EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            List<String> idsToDelete = new List<String>();

            for (EMS_Event_Attendee_Interaction_Ext.AttendeeWrapper a : attResult) {
                idsToDelete.add(a.attendeeId);
            }

            EMS_Event_Attendee_Interaction_Ext.getAffiliatedAccounts(pmUsers);

            EMS_Event_Attendee_Interaction_Ext.getHCPsAndiHCPsAttendee(events[0].Id);

            EMS_Event_Attendee_Interaction_Ext.getUserTerritories(events[0].Id, pmUsers);

            String idsJSON = JSON.serialize(idsToDelete);

            EMS_Event_Attendee_Interaction_Ext.deleteEventAttendees(idsJSON, true);
        }
    }

    static testMethod void insertNewIHCP() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        EMS_International_Speaker_gne__c ihcp = EMS_Test_Util.createAndInsertIHCP('Test', 'Tester');

        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createIHCPAttendee(ihcp, events);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            String attJSON = JSON.serialize(attendees);

            EMS_Event_Attendee_Interaction_Ext.saveEventAttendees(events[0].Id, attJSON, true);

            List<EMS_Event_Attendee_Interaction_Ext.AttendeeWrapper> attResult = EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            EMS_Event_Attendee_Interaction_Ext.getHCPsAndiHCPsAttendee(events[0].Id);

            EMS_Event_Attendee_Interaction_Ext.searchAccountsContactsEmployees('Test', 1, true, false, false, pmUsers[0]);
        }
    }

    static testMethod void insertNewRocheAttendee() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<Id> adminUsers = EMS_Test_Util.findExistingUser('Admin', null);
        System.assertNotEquals(0, adminUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        Account acc = EMS_Test_Util.createAndInsertAccount('Tester', 'Test');

        EMS_Roche_Attendee_gne__c rocheAtt = EMS_Test_Util.createRocheAttendee(events[0].Id, adminUsers[0]);

        List<EMS_Roche_Attendee_gne__c> attendees = new List<EMS_Roche_Attendee_gne__c>();

        attendees.add(rocheAtt);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            String attJSON = JSON.serialize(attendees);

            EMS_Event_Attendee_Interaction_Ext.saveEventAttendees(events[0].Id, attJSON, true);

            List<EMS_Event_Attendee_Interaction_Ext.AttendeeWrapper> attResult = EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            attendees = EMS_Event_Attendee_Interaction_Ext.getRocheAttendees(events[0].Id);

            List<Id> RocheAttendeesIds = new List<Id>();

            for (EMS_Roche_Attendee_gne__c a : attendees) {
                RocheAttendeesIds.add(a.Id);
            }

            EMS_Event_Attendee_Interaction_Ext.getRocheAttendeesWithTerritories(events[0].Id);
        }
    }

    static testMethod void insertnonHCP() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.saveNonHCPAttendees(events[0].Id, 3);
        }
    }

    static testMethod void insertProductInteractionAndDelete() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');
        Product_vod__c tool = EMS_Test_Util.createTool(product.Id, 'test tool');

        EMS_Test_Util.createEventProduct(events[0].Id, product.Id, strategy.Id, null);

        EMS_Util.EMS_Territory pmTerr = EMS_Util.getUserTerritories(pmUsers[0])[0];

        Account acc = EMS_Test_Util.createAndInsertAccount('Tester', 'Test');

        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createStaticFMVAttendees(events, acc);
        List<EMS_Roche_Attendee_gne__c> rocheAttendees = [SELECT RecordTypeId, EMS_Event_gne__c, User_gne__c, Territory_Id_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :events];

        List<EMS_Interaction_gne__c> interaction = EMS_Test_Util.createAttendeeInteractions(events, attendees, rocheAttendees, pmTerr.Id, product.Id, strategy.Id, 'Positive', tool.Id, 1);

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            String attJSON = JSON.serialize(attendees);

            EMS_Event_Attendee_Interaction_Ext.saveEventAttendees(events[0].Id, attJSON, true);

            List<EMS_Event_Attendee_Interaction_Ext.AttendeeWrapper> attResult = EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            EMS_Event_Attendee_Interaction_Ext.upsertEventInteraction(interaction[0]);

            EMS_Event_Attendee_Interaction_Ext.getEventInteractions(events[0].Id);

            EMS_Event_Attendee_Interaction_Ext.getProductTools();

            EMS_Event_Attendee_Interaction_Ext.getEventProducts(events[0].Id);

            EMS_Event_Attendee_Interaction_Ext.refreshInteractions(events[0].Id);

            List<String> IdsToDelete = new List<String>();

            IdsToDelete.add(interaction[0].Id);

            EMS_Event_Attendee_Interaction_Ext.deleteEventInteractions(IdsToDelete);
        }
    }

    static testMethod void testHonorariumPopup() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        //Query for the Account record types
        List<RecordType> rtypes = [
                Select Name, Id
                From RecordType
                where sObjectType = 'EMS_FMV_Configuration_gne__c' and isActive = true
        ];

        //Create a map between the Record Type Name and Id for easy retrieval
        Map<String, Id> FMVRecordTypes = new Map<String, Id>{
        };
        for (RecordType rt : rtypes) {
            FMVRecordTypes.put(rt.Name, rt.Id);
        }

        EMS_Event_Configuration_gne__c eventConfig = new EMS_Event_Configuration_gne__c(
                Event_Type_gne__c = 'Program',
                Event_Sub_Type_gne__c = 'Product Promo',
                Description_gne__c = 'Test Configuration',
                External_Id_gne__c = 'Program_Product_Promo_Test Configuration'
        );
        insert eventConfig;

        List<EMS_FMV_Configuration_gne__c> fmvConfigs = new List<EMS_FMV_Configuration_gne__c>();

        EMS_FMV_Configuration_gne__c config1 = new EMS_FMV_Configuration_gne__c(
                Type_of_HCP_gne__c = 'PhD Researchers/Psychologists',
                Disturbance_Fee_gne__c = 'Flight (Event held in Canada/US and over 6hrs, return trip)',
                Disturbance_Fee_Amount_gne__c = 300,
                Speaker_Tour_gne__c = true,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config1);
        EMS_FMV_Configuration_gne__c config2 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Attendee Status Config'),
                Attendee_Status_gne__c = 'Attended',
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config2);
        EMS_FMV_Configuration_gne__c config3 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Attendee Contract Config'),
                Attendee_Contract_gne__c = 'HCP',
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config3);
        EMS_FMV_Configuration_gne__c config4 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Available Roles Config'),
                Available_Role_gne__c = 'Other',
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config4);
        EMS_FMV_Configuration_gne__c config5 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('KM (Round trip) Config'),
                Disturbance_Fee_gne__c = 'Fee',
                KM_round_trip_gne__c = 100,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config5);
        EMS_FMV_Configuration_gne__c config6 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Preparation Time Config'),
                Available_Role_gne__c = 'Other',
                Preparation_Time_gne__c = 1,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config6);
        EMS_FMV_Configuration_gne__c config7 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Disturbance Fee Config'),
                Disturbance_Fee_gne__c = 'Flight (Event held in Canada/US and over 6hrs, return trip)',
                Disturbance_Fee_Amount_gne__c = 300,
                Speaker_Tour_gne__c = true,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config7);
        EMS_FMV_Configuration_gne__c config8 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Hourly Rate Config'),
                Type_of_HCP_gne__c = 'PhD Researchers/Psychologists',
                Hourly_Rate_of_HCP_gne__c = 25,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config8);
        EMS_FMV_Configuration_gne__c config9 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Type of HCP Config'),
                Type_of_HCP_gne__c = 'PhD Researchers/Psychologists',
                Order_gne__c = 1,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config9);
        EMS_FMV_Configuration_gne__c config10 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Preparation Time Config'),
                Available_Role_gne__c = 'Other',
                Preparation_Time_gne__c = 2,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config10);
        EMS_FMV_Configuration_gne__c config11 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Disturbance Fee Config'),
                Disturbance_Fee_gne__c = 'Flight (Event held in Canada/US and over 2hrs, return trip)',
                Disturbance_Fee_Amount_gne__c = 100,
                Speaker_Tour_gne__c = true,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config11);
        EMS_FMV_Configuration_gne__c config12 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Disturbance Fee Config'),
                Disturbance_Fee_gne__c = 'Flight (Event held in Canada/US and over 4hrs, return trip)',
                Disturbance_Fee_Amount_gne__c = 200,
                Speaker_Tour_gne__c = true,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config12);
        EMS_FMV_Configuration_gne__c config13 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Available Roles Config'),
                Available_Role_gne__c = 'iHCP',
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config13);
        EMS_FMV_Configuration_gne__c config14 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('KM (Round trip) Config'),
                Disturbance_Fee_gne__c = 'Bigger Fee',
                KM_round_trip_gne__c = 200,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config14);
        EMS_FMV_Configuration_gne__c config15 = new EMS_FMV_Configuration_gne__c(
                RecordTypeId = FMVRecordTypes.get('Hourly Rate Config'),
                Type_of_HCP_gne__c = 'Patients',
                Hourly_Rate_of_HCP_gne__c = 35,
                EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        fmvConfigs.add(config15);

        insert fmvConfigs;

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        Account acc = EMS_Test_Util.createAndInsertAccount('Tester', 'Test');

        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createStaticFMVAttendees(events, acc);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            String attJSON = JSON.serialize(attendees);

            EMS_Event_Attendee_Interaction_Ext.saveEventAttendees(events[0].Id, attJSON, true);

            EMS_Attendee_gne__c attData = EMS_Event_Attendee_Interaction_Ext.getHCPAttendeeData(attendees[0].Id);

            EMS_Event__c eventData = EMS_Event_Attendee_Interaction_Ext.getEventData(events[0].Id);

            String FMVsettings = EMS_Event_Attendee_Interaction_Ext.getFMVsettings('Program', 'Product Promo', true);

            EMS_Event_Attendee_Interaction_Ext.saveHonorariumPopup(attData);
        }
    }

    static testMethod void testPermissions() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {

            Boolean isCanadaUser = ctrl.getIsEMSCanadaUser();
            system.assertNotEquals(isCanadaUser, true);

            Boolean canEdit = ctrl.getCanEdit();
            system.assertNotEquals(canEdit, true);

            Boolean isOwner = ctrl.getIsEventOwnerRequestor();
            system.assertNotEquals(isOwner, false);

            Boolean eventLocked = ctrl.getIsEventLockedByRecordType();
            system.assertNotEquals(eventLocked, true);

            Boolean canRequestPayment = ctrl.getCanRequestPayment();
            system.assertNotEquals(canRequestPayment, true);
        }
    }

    static testMethod void insertEmptyAttendee() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        Account acc = EMS_Test_Util.createAndInsertAccount('Tester', 'Test');

        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();

        EMS_Attendee_gne__c emptyAtt = new EMS_Attendee_gne__c();

        attendees.add(emptyAtt);

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);

            String attJSON = JSON.serialize(attendees);

            EMS_Event_Attendee_Interaction_Ext.saveEventAttendees(events[0].Id, attJSON, false);

            List<EMS_Event_Attendee_Interaction_Ext.AttendeeWrapper> attResult = EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);
        }
    }

    static testMethod void insertEmptyInteraction() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Attendee_Interaction_Ext ctrl = new EMS_Event_Attendee_Interaction_Ext(stdCtrl);

        EMS_Interaction_gne__c interaction = new EMS_Interaction_gne__c();

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        system.runAS(u) {
            EMS_Event_Attendee_Interaction_Ext.getEventAttendees(events[0].Id);
            EMS_Event_Attendee_Interaction_Ext.upsertEventInteraction(interaction);
        }
    }

}