@isTest
private class EMS_Event_Child_Records_Update_Test {

    private static Integer BATCH_SIZE = 1;
    private static final Id regionBudgetAllocationRTId = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1].Id;

    private static testMethod void createRocheAttendeeFromEventOwnerTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        Test.startTest();
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        Test.stopTest();

        List<EMS_Roche_Attendee_gne__c> rocheAttendees = [SELECT User_gne__c, EMS_Event_gne__c FROM EMS_Roche_Attendee_gne__c where EMS_Event_gne__c IN :events];
        System.assertEquals(BATCH_SIZE, rocheAttendees.size());
        for (EMS_Roche_Attendee_gne__c rocheAttendee : rocheAttendees) {
            System.assertEquals(pmUsers[0], rocheAttendee.User_gne__c);
        }
    }

    private static testMethod void shareEventWithApproverTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Event_Trigger_Helper.clearProcessedSet();
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();
        // submit event for approval
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);
        Test.stopTest();

        String eventApproverRowCause = Schema.EMS_Event__Share.rowCause.Event_Approver__c;
        List<EMS_Event__Share> approverSharings = [SELECT Id, RowCause, ParentId, UserOrGroupId FROM EMS_Event__Share WHERE ParentId IN :events AND RowCause = :eventApproverRowCause];
        System.assertEquals(BATCH_SIZE, approverSharings.size());
        for (EMS_Event__Share approverSharing : approverSharings) {
            System.assertEquals(pmUsers[0], approverSharing.UserOrGroupId);
        }
    }

    private static testMethod void shareEventWithOwnerRequestorTerritoryTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        EMS_Util.EMS_Territory pmTerr = EMS_Util.getUserTerritories(pmUsers[0])[0];

        Test.startTest();
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, pmTerr.Name, BATCH_SIZE);
        Test.stopTest();

        String eventOwnerRowCause = Schema.EMS_Event__Share.rowCause.Event_Owner__c;
        String eventRequestorRowCause = Schema.EMS_Event__Share.rowCause.Event_Requestor__c;
        Id pmTerritoryGroupId = EMS_Util.getTerritoryGroup(pmTerr.Id);

        List<EMS_Event__Share> requestorTerritorySharings = [SELECT Id, RowCause, ParentId, UserOrGroupId FROM EMS_Event__Share WHERE ParentId IN :events AND RowCause = :eventRequestorRowCause];
        List<EMS_Event__Share> ownerTerritorySharings = [SELECT Id, RowCause, ParentId, UserOrGroupId FROM EMS_Event__Share WHERE ParentId IN :events AND RowCause = :eventOwnerRowCause];

        System.assertEquals(BATCH_SIZE, requestorTerritorySharings.size());
        System.assertEquals(BATCH_SIZE, ownerTerritorySharings.size());

        for (EMS_Event__Share requestorTerritorySharing : requestorTerritorySharings) {
            System.assertEquals(pmTerritoryGroupId, requestorTerritorySharing.UserOrGroupId);
        }
        for (EMS_Event__Share ownerTerritorySharing : ownerTerritorySharings) {
            System.assertEquals(pmTerritoryGroupId, ownerTerritorySharing.UserOrGroupId);
        }
    }

    private static testMethod void deleteTravelsConsultingMeetingsTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Informal consulting', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Consulting Meetings', 'Informal consulting', Date.today(), Date.today() + 1, BATCH_SIZE);
        EMS_Test_Util.createTravels(events);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Event_Type_gne__c = 'Sponsorship';
            event.Event_Sub_Type_gne__c = 'Sponsorship of Events';
        }
        update events;
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM EMS_Travel_gne__c WHERE EMS_Event_gne__c IN :events]);
    }

    private static testMethod void deleteTravelsLearningProgramsTest() {
        // select test user
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Medical Product', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, mmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('GD', 'Grant in Aid Education - Individual', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUsers[0], 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, BATCH_SIZE);
        EMS_Test_Util.createTravels(events);

        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Travel_gne__c WHERE EMS_Event_gne__c IN :events]);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Event_Type_gne__c = 'GD';
            event.Event_Sub_Type_gne__c = 'Grant in Aid Education - Individual';
        }
        update events;
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM EMS_Travel_gne__c WHERE EMS_Event_gne__c IN :events]);
    }

    private static testMethod void deleteInvestmentsTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 'HCO', BATCH_SIZE);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        EMS_Test_Util.createInvestmentsForMultipleEvents(events, 2);
        System.assertEquals(BATCH_SIZE * 2, [SELECT count() FROM EMS_Investment_gne__c WHERE EMS_Event_gne__c IN :events]);
        EMS_Event_Trigger_Helper.clearProcessedSet();
        for (EMS_Event__c event : events) {
            event.Investment_gne__c = 'National';
        }
        update events;
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM EMS_Investment_gne__c WHERE EMS_Event_gne__c IN :events]);
    }

    private static testMethod void adjustAllocatedAmountOnEventCloseNoExpensesTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(100.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(0.0, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnEventCloseWithExpensesLessThanPlannedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createExpenses(events, 10.0, costCenters[0]);

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(100.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(10.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnEventCloseWithExpensesHigherThanPlannedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(100.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(110.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnEventCancelNoExpensesTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(100.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(0.0, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnEventCancelWithExpensesLessThanPlannedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createExpenses(events, 10.0, costCenters[0]);

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(100.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(10.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnEventCancelWithExpensesHigherThanPlannedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(100.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(110.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnEventDeleteTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(100.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        delete events;
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(0.0, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnClosedEventWithExpensesHigherThanPlannedTest_ProductBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(0.0, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);
        Test.stopTest();

        Decimal sum = 0;
        for (EMS_Event__c event : [SELECT Total_Expenses_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            sum += event.Total_Expenses_gne__c;
        }
        System.assertEquals(110.0 * BATCH_SIZE, sum);
    }

    private static testMethod void adjustAllocatedAmountOnClosedEventWithExpensesLessThanPlannedTest_ProductBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        // close the event
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(0.0, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        EMS_Test_Util.createExpenses(events, 90.0, costCenters[0]);
        Test.stopTest();

        Decimal sum = 0;
        for (EMS_Event__c event : [SELECT Total_Expenses_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            sum += event.Total_Expenses_gne__c;
        }
        System.assertEquals(90.0 * BATCH_SIZE, sum);
    }

    private static testMethod void deleteGSDDetailsTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Preceptorships (HCP to Roche)', 'Preceptorships (HCP Delivered)', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        EMS_Test_Util.createGSDDetails(events);

        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_GSD_Detail__c WHERE EMS_Event__c IN :events]);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Event_Type_gne__c = 'Preceptorships (HCP to Roche)';
            event.Event_Sub_Type_gne__c = 'Preceptorships (HCP Delivered)';
        }
        update events;
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM EMS_GSD_Detail__c WHERE EMS_Event__c IN :events]);
    }


    private static testMethod void adjustAllocatedAmountOnCancelledEventWithExpensesHigherThanPlannedTest_ProductBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(0, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);
        Test.stopTest();

        Decimal sum = 0;
        for (EMS_Event__c event : [SELECT Total_Expenses_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            sum += event.Total_Expenses_gne__c;
        }
        System.assertEquals(110.0 * BATCH_SIZE, sum);
    }

    private static testMethod void adjustAllocatedAmountOnCancelledEventWithExpensesLessThanPlannedTest_ProductBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;

        // check events allocated amount for PB
        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        System.assertEquals(0, pb.Events_Allocated_Amount__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        EMS_Test_Util.createExpenses(events, 90.0, costCenters[0]);
        Test.stopTest();

        pb = [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id];
        Decimal sum = 0;
        for (EMS_Event__c event : [SELECT Total_Expenses_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            sum += event.Total_Expenses_gne__c;
        }
        System.assertEquals(90.0 * BATCH_SIZE, sum);
    }

    private static testMethod void createInteractionsForClosedEvent_HCP_Test() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');
        Product_vod__c tool = EMS_Test_Util.createTool(product.Id, 'test tool');

        // select territory id
        EMS_Util.EMS_Territory pmTerr = EMS_Util.getUserTerritories(pmUsers[0])[0];

        Account testAccount = EMS_Test_Util.createAndInsertAccount('HCP Canada');

        Test.startTest();
        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createAttendees(testAccount, events);
        List<EMS_Roche_Attendee_gne__c> rocheAttendees = [SELECT RecordTypeId, EMS_Event_gne__c, User_gne__c, Territory_Id_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :events];
        EMS_Test_Util.createAttendeeInteractions(events, attendees, rocheAttendees, pmTerr.Id, product.Id, strategy.Id, 'Positive', tool.Id, 1);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;
        Test.stopTest();

        // query interactions
        List<Call2_vod__c> interactions = [
                SELECT Id, Account_vod__c, Detailed_Products_vod__c, Call_Datetime_vod__c, Territory_vod__c, Attendees_vod__c,
                        Actual_Attendees_gne__c, Completed_gne__c, Date_Completed_gne__c, Interaction_Type_gne__c, OwnerId, Attendee_Type_vod__c, Call_Type_vod__c,
                        Meal_Amount_gne__c, Planned_Attendees_gne__c, Status_vod__c
                FROM Call2_vod__c
                WHERE Account_vod__c = :testAccount.Id
        ] ;
        System.assertEquals(BATCH_SIZE, interactions.size());

        for (Call2_vod__c interaction : interactions) {
            System.assertEquals(testAccount.Id, interaction.Account_vod__c);
            System.assertEquals('test product', interaction.Detailed_Products_vod__c);
            System.assertEquals(System.today(), interaction.Call_Datetime_vod__c);
            System.assertEquals(pmTerr.Name, interaction.Territory_vod__c);
            System.assertEquals(1, interaction.Attendees_vod__c);
            System.assertEquals(0, interaction.Actual_Attendees_gne__c);
            System.assertEquals(true, interaction.Completed_gne__c);
            System.assertEquals('Promotional Session', interaction.Interaction_Type_gne__c);
            System.assertEquals(pmUsers[0], interaction.OwnerId);
            System.assertEquals('Person_Account_vod', interaction.Attendee_Type_vod__c);
            System.assertEquals('Detail Only', interaction.Call_Type_vod__c);
            System.assertEquals(0, interaction.Meal_Amount_gne__c);
            System.assertEquals(0, interaction.Planned_Attendees_gne__c);
            System.assertEquals('Saved_vod', interaction.Status_vod__c);
        }

        // query call details
        List<Call2_Detail_vod__c> callDetails = [SELECT Product_vod__c, Detail_Priority_vod__c FROM Call2_Detail_vod__c WHERE Call2_vod__c IN :interactions] ;
        System.assertEquals(BATCH_SIZE, callDetails.size());

        for (Call2_Detail_vod__c callDetail : callDetails) {
            System.assertEquals(product.Id, callDetail.Product_vod__c);
            System.assertEquals(1, callDetail.Detail_Priority_vod__c);
        }

        // query call samples
        List<Call2_Sample_vod__c> callSamples = [SELECT Account_vod__c, Product_vod__c, Quantity_vod__c FROM Call2_Sample_vod__c WHERE Call2_vod__c IN :interactions] ;
        System.assertEquals(BATCH_SIZE, callSamples.size());

        for (Call2_Sample_vod__c callSample : callSamples) {
            System.assertEquals(testAccount.Id, callSample.Account_vod__c);
            System.assertEquals(tool.Id, callSample.Product_vod__c);
            System.assertEquals(1, callSample.Quantity_vod__c);
        }

        // query call discussions
        List<Call2_Discussion_vod__c> callDiscussions = [
                SELECT Account_vod__c, Product_vod__c, Product_Strategy_vod__c,
                        Product_Tactic_vod__c, Reaction_gne__c, Detail_Priority_gne__c
                FROM Call2_Discussion_vod__c
                WHERE Call2_vod__c IN :interactions
        ] ;
        System.assertEquals(BATCH_SIZE, callDiscussions.size());

        for (Call2_Discussion_vod__c callDiscussion : callDiscussions) {
            System.assertEquals(testAccount.Id, callDiscussion.Account_vod__c);
            System.assertEquals(product.Id, callDiscussion.Product_vod__c);
            System.assertEquals(strategy.Id, callDiscussion.Product_Strategy_vod__c);
            System.assertEquals(null, callDiscussion.Product_Tactic_vod__c);
            System.assertEquals('Positive', callDiscussion.Reaction_gne__c);
            System.assertEquals(1, callDiscussion.Detail_Priority_gne__c);
        }
    }

    private static testMethod void handleFMVAttendeeFields() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 5, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Consultancy Meeting Medical', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Preceptorships (HCP to Roche)', 'Preceptorships (HCP to HCP)', costCenters[1]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting', 'Informal consulting', costCenters[2]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[3]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Programs', 'Product Promo', costCenters[4]);
        Account accountRecord = EMS_Test_Util.createAndInsertAccount('HCP Canada');

        Test.startTest();
        // Create 4 Different events
        EMS_Event__c event1 = EMS_Test_Util.prepareEvent('Unplanned', pmUsers[0], 'Consulting Meetings', 'Consultancy Meeting Medical', Date.today(), Date.today() + 1, null, null, null);
        EMS_Event__c event2 = EMS_Test_Util.prepareEvent('Unplanned', pmUsers[0], 'Preceptorships (HCP to Roche)', 'Preceptorships (HCP to HCP)', Date.today(), Date.today() + 1, null, null, null);
        EMS_Event__c event3 = EMS_Test_Util.prepareEvent('Unplanned', pmUsers[0], 'Consulting', 'Informal consulting', Date.today(), Date.today() + 1, null, null, null);
        EMS_Event__c event4 = EMS_Test_Util.prepareEvent('Unplanned', pmUsers[0], 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, null, null, null);
        List<EMS_Event__c> events = new List<EMS_Event__c>{
                event1, event2, event3, event4
        };
        insert events;

        List<EMS_Attendee_gne__c> newAttendees = EMS_Test_Util.createStaticFMVAttendees(events, accountRecord);

        // Change event Type and Subtype (Do not change the order)
        events[0].Event_Type_gne__c = 'Learning Programs';//'Preceptorships (HCP to Roche)';
        events[0].Event_Sub_Type_gne__c = 'Accredited CHE Implementation';//'Preceptorships (HCP to HCP)';

        events[1].Event_Type_gne__c = 'Learning Programs';
        events[1].Event_Sub_Type_gne__c = 'Accredited CHE Implementation';

        events[2].Event_Type_gne__c = 'Learning Programs';
        events[2].Event_Sub_Type_gne__c = 'Accredited CHE Implementation';

        events[3].Event_Type_gne__c = 'Programs';
        events[3].Event_Sub_Type_gne__c = 'Product Promo';
        update events;
        Test.stopTest();

        for (EMS_Attendee_gne__c attendee : [SELECT Total_Honoraria_gne__c FROM EMS_Attendee_gne__c WHERE Id IN :newAttendees]) {
            System.assertEquals(attendee.Total_Honoraria_gne__c, null);
        }
    }

    private static testMethod void detachDependetetSpeakerTourEvents() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);
        // Speaker Tour Parent Event
        EMS_Event__c parentEvent = EMS_Test_Util.prepareEvent('Unplanned', pmUsers[0], 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, null, null, null);
        parentEvent.Speaker_Tour_gne__c = true;
        insert parentEvent;

        // Child Events
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, BATCH_SIZE);
        for (EMS_Event__c event : events) {
            event.Parent_Speaker_Tour_Event_gne__c = parentEvent.Id;
        }
        update events;

        Test.startTest();
        parentEvent.Speaker_Tour_gne__c = false;
        update parentEvent;
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Parent_Speaker_Tour_Event_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(event.Parent_Speaker_Tour_Event_gne__c, null);
        }
    }

    private static testMethod void updateStatusOnSpeakerToursWhenContractUploaded() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);
        // Speaker Tour Parent Event
        EMS_Event__c parentEvent = EMS_Test_Util.prepareEvent('Awaiting Signature from HCP', pmUsers[0], 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, null, null, null);
        parentEvent.Speaker_Tour_gne__c = true;
        insert parentEvent;

        // Child Events
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Awaiting Signature from HCP', pmUsers[0], 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, BATCH_SIZE);
        for (EMS_Event__c event : events) {
            event.Parent_Speaker_Tour_Event_gne__c = parentEvent.Id;
        }
        update events;

        Test.startTest();
        parentEvent.Status_gne__c = 'Signed Agreement Received';
        update parentEvent;
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(event.Status_gne__c, 'Signed Agreement Received');
        }
    }

/*
    //  Too many SOQL queries: 101
    private static testMethod void adjustAllocatedAmountOnRelatedBudgetEventCloseCancel_regionBudgetUpdate() {
        Decimal amount = 10.0;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0, rsmUser);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Learning Programs','Accredited CHE Implementation', Date.today(), Date.today().addDays(7), amount, BATCH_SIZE);
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsForRegion = EMS_Test_Util.createBudgetAllocations(regionBudgetAllocationRTId, amount, rb.Assigned_to_gne__c, events, null, rb.Id, null);
        Set<Id> budgetRegionIds = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c item :budgetAllocationsForRegion) {
            budgetRegionIds.add(item.EMS_Region_Budget_gne__c);
        }
        System.assertNotEquals(0, budgetRegionIds.size());
        List<AggregateResult> groupedResults = [SELECT Sum(Events_Allocated_Amount_gne__c) Sumofaa FROM EMS_Budget_Region_gne__c WHERE Id IN :budgetRegionIds];
        System.assertEquals(amount * BATCH_SIZE, groupedResults[0].get('Sumofaa'));
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;
        groupedResults = [SELECT Sum(Events_Allocated_Amount_gne__c) Sumofaa FROM EMS_Budget_Region_gne__c WHERE Id IN :budgetRegionIds];
        System.assertEquals(0, groupedResults[0].get('Sumofaa'));

        Test.stopTest();
    }*/

    private static testMethod void adjustAllocatedAmountOnRelatedBudgetEventCloseCancel_productBudgetUpdate() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0, rsmUser);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today().addDays(7), 10.0, BATCH_SIZE);

        Id productBudgetAllocationRTId = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1].Id;
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsForProduct = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRTId, 10.0, rb.Assigned_to_gne__c, events, pb.Id, null, null);
        Set<Id> budgetProductIds = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c item : budgetAllocationsForProduct) {
            budgetProductIds.add(item.EMS_Product_Budget_gne__c);
        }
        System.assertNotEquals(0, budgetProductIds.size());

        AggregateResult[] groupedResults = [SELECT Sum(Events_Allocated_Amount__c) SumOfAA FROM EMS_Budget_Product_gne__c WHERE Id IN :budgetProductIds];
        System.assertEquals(10 * BATCH_SIZE, groupedResults[0].get('SumOfAA'));

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;
        Test.stopTest();

        for (EMS_Budget_Product_gne__c budgetProduct : [SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id IN :budgetProductIds]) {
            System.assertEquals(budgetProduct.Events_Allocated_Amount__c, 0);
        }
    }

/*
    // //  Too many SOQL queries: 101
    private static testMethod void adjustEventAllocatedAmountOnRelatedBudgetWhenTotalExpensesChangedForClosedCancelledEvent_regionBudgetUpdate() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0, rsmUser);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);

        EMS_Event__c event = EMS_Test_Util.createEvent('Cancelled', pmUser, 'Learning Programs','Accredited CHE Implementation', Date.today(), Date.today().addDays(7), 10.0);
        Id regionBudgetAllocationRTId = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1].Id;
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsForRegion = EMS_Test_Util.createBudgetAllocations(regionBudgetAllocationRTId, 10.0, rb.Assigned_to_gne__c, new List<EMS_Event__c>{event}, null, rb.Id, null);
        Set<Id> budgetRegionIds = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c item :budgetAllocationsForRegion) {
            budgetRegionIds.add(item.EMS_Region_Budget_gne__c);
        }
        System.assertNotEquals(0, budgetRegionIds.size());

        Decimal amount = 100.00;
        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        // Changing Total Expenses for Event
        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(new List<EMS_Event__c>{event}, 110.0, BATCH_SIZE, costCenters[0]);
        Decimal totalExpensesAmount = [SELECT Total_Expenses_gne__c  FROM EMS_Event__c WHERE Id = :event.Id].Total_Expenses_gne__c;
        // Changing Total Expenses for Event
        for (EMS_Expense_gne__c item: expenses){
            item.Country_Expense_Amount_gne__c = amount;
        }
        update expenses;
        Test.stopTest();

        for (EMS_Budget_Region_gne__c budgetRegion : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :budgetRegionIds]) {
            System.assertEquals(budgetRegion.Events_Allocated_Amount_gne__c, amount);
        }
    }*/

    private static testMethod void createInteractionsForClosedEvent_withcontact() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');
        Product_vod__c tool = EMS_Test_Util.createTool(product.Id, 'test tool');

        EMS_Util.EMS_Territory pmTerr = EMS_Util.getUserTerritories(pmUsers[0])[0];
        Contact contactRecord = new Contact(FirstName = 'Contact Name', LastName = 'LastName');
        insert contactRecord;

        EMS_International_Speaker_gne__c newIHCP = EMS_Test_Util.createIHCP('FirstName', 'LastName');
        insert newIHCP;

        Test.startTest();
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            attendees.add(new EMS_Attendee_gne__c(
                    EMS_Event_gne__c = event.Id,
                    Contact_gne__c = contactRecord.Id,
                    Status_gne__c = 'Attended',
                    EMS_International_Speaker_gne__c = newIHCP.Id
            ));
        }
        insert attendees;

        List<EMS_Roche_Attendee_gne__c> rocheAttendees = [SELECT RecordTypeId, EMS_Event_gne__c, User_gne__c, Territory_Id_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :events];
        EMS_Test_Util.createAttendeeInteractions(events, attendees, rocheAttendees, pmTerr.Id, product.Id, strategy.Id, 'Positive', tool.Id, 1);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;
        Test.stopTest();

        List<Call2_vod__c> interactions = [
                SELECT Id, Account_vod__c, Detailed_Products_vod__c, Call_Datetime_vod__c, Territory_vod__c, Attendees_vod__c,
                        Actual_Attendees_gne__c, Completed_gne__c, Date_Completed_gne__c, Interaction_Type_gne__c, OwnerId, Attendee_Type_vod__c, Call_Type_vod__c,
                        Meal_Amount_gne__c, Planned_Attendees_gne__c, Status_vod__c
                FROM Call2_vod__c
                WHERE EMS_International_Speaker_gne__c = :newIHCP.Id
        ] ;
        System.assertEquals(BATCH_SIZE, interactions.size());

        for (Call2_vod__c interaction : interactions) {
            System.assertEquals('test product', interaction.Detailed_Products_vod__c);
            System.assertEquals(System.today(), interaction.Call_Datetime_vod__c);
            System.assertEquals(pmTerr.Name, interaction.Territory_vod__c);
            System.assertEquals(1, interaction.Attendees_vod__c);
            System.assertEquals(0, interaction.Actual_Attendees_gne__c);
            System.assertEquals(true, interaction.Completed_gne__c);
            System.assertEquals('Promotional Session', interaction.Interaction_Type_gne__c);
            System.assertEquals(pmUsers[0], interaction.OwnerId);
            System.assertEquals('Person_Account_vod', interaction.Attendee_Type_vod__c);
            System.assertEquals('Detail Only', interaction.Call_Type_vod__c);
            System.assertEquals(0, interaction.Meal_Amount_gne__c);
            System.assertEquals(0, interaction.Planned_Attendees_gne__c);
            System.assertEquals('Saved_vod', interaction.Status_vod__c);
        }
    }

    private static testMethod void deleteBudgetAllocationsOnEventTypeChange_CommercialToMedical_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> commercialCostCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c commercialPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUser, commercialCostCenters[0].Id);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', commercialCostCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, commercialPb.Assigned_to_gne__c, events, commercialPb.Id, null, null);

        // check events allocated amount for PB
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :events];
        System.assertEquals(BATCH_SIZE, budgetAllocations.size());

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        for (EMS_Event__c ev : events) {
            ev.Event_Type_gne__c = 'Learning Programs';
            ev.Event_Sub_Type_gne__c = 'Accredited CHE Implementation';
            ev.Event_Owner_gne__c = mmUser;
        }
        update events;
        Test.stopTest();

        budgetAllocations = [SELECT Id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :events];
        System.assertEquals(0, budgetAllocations.size());
    }


    private static testMethod void deleteBudgetAllocationsOnEventTypeChange_MedicalToCommercial_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> commercialCostCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c commercialPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUser, commercialCostCenters[0].Id);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', commercialCostCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);

        // check events allocated amount for PB
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :events];
        System.assertEquals(BATCH_SIZE, budgetAllocations.size());

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        for (EMS_Event__c ev : events) {
            ev.Event_Type_gne__c = 'Sponsorship';
            ev.Event_Sub_Type_gne__c = 'Sponsorship of Events';
            ev.Event_Owner_gne__c = pmUser;
        }
        update events;
        Test.stopTest();

        budgetAllocations = [SELECT Id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :events];
        System.assertEquals(0, budgetAllocations.size());
    }

    private static testMethod void submitBudgetsForLearningProgramm() {
        String type = 'Learning Programs';
        String subtype = 'Accredited CHE Implementation';

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        List<EMS_Budget_Allocation_gne__c> bas = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);

        List<EMS_Event_Configuration_gne__c> configs = [
                SELECT Budget_Approved_Label_gne__c, Budget_Approval_Required_gne__c
                FROM EMS_Event_Configuration_gne__c
                WHERE Event_Type_gne__c = :type AND Event_Sub_Type_gne__c = :subtype
        ];
        System.assertEquals(1, configs.size());
        if (String.isBlank(configs[0].Budget_Approved_Label_gne__c)) {
            configs[0].Budget_Approved_Label_gne__c = 'Pending Approval';
            update configs;
        }

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        for (EMS_Event__c ev : events) {
            ev.Status_gne__c = configs[0].Budget_Approved_Label_gne__c;
            ev.Pending_Budget_Approval_gne__c = true;
            ev.Submitted_Date_gne__c = System.today();
            ev.Submitted_By_gne__c = UserInfo.getUserId();
        }
        update events;
        Test.stopTest();
        System.assertEquals('Submitted', [SELECT Status_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :events[0].Id LIMIT 1].Status_gne__c);
    }


/*
    private static testMethod void startBudgetAllocationApproval_test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
        List<EMS_Budget_Allocation_gne__c> baList = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        for (EMS_Event__c ev : events) {
            ev.Status_gne__c = 'Pending Approval';
            ev.Pending_Budget_Approval_gne__c = true;
            ev.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Locked Event').RecordTypeId;
            ev.Submitted_Date_gne__c = System.today();
            ev.Submitted_By_gne__c = mmUser;
        }
        update events;
        Test.stopTest();

        System.assertEquals(BATCH_SIZE, [SELECT Count() FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN : baList]);
    }

    private static testMethod void recallBudgetApproval_test() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Pending', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
        List<EMS_Budget_Allocation_gne__c> baList = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(EMS_Budget_Allocation_gne__c ba : baList) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(ba.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);

        for (EMS_Event__c ev : events) {
            ev.Status_gne__c = 'Unplanned';
        }
        update events;
        Test.stopTest();

        for (ProcessInstance piItem : [SELECT Status FROM ProcessInstance WHERE TargetObjectId IN : baList]) {
            System.assertEquals('Removed', piItem.Status);
        }
    }

    private static testMethod void recalculateTotalHonorariumAmount_test() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Consultancy Meeting Medical', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);

        Account accountRecord = EMS_Test_Util.createAndInsertAccount('HCP Canada');

        // Parent Event
        EMS_Event__c parentEvent = EMS_Test_Util.prepareEvent('Unplanned', pmUser,'Consulting Meetings','Consultancy Meeting Medical', Date.today(), Date.today() + 10, null, null, null);
        parentEvent.Speaker_Tour_gne__c = true;
        insert parentEvent;
        // Child Events
        List<EMS_Event__c> childEvents = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Learning Programs','Accredited CHE Implementation', Date.today(), Date.today() + 10, BATCH_SIZE);
        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createStaticFMVAttendees(childEvents, accountRecord);

        // Config is generated for childEvents above
        EMS_Event_Configuration_gne__c eventConfig = new EMS_Event_Configuration_gne__c(
            Event_Type_gne__c = 'Learning Programs',
            Event_Sub_Type_gne__c = 'Accredited CHE Implementation',
            Description_gne__c = 'Test Configuration',
            External_Id_gne__c = 'Learning Programs_Accredited CHEs_Test Configuration'
        );
        insert eventConfig;

        // Config is generated for static createStaticFMVAttendees method
        EMS_FMV_Configuration_gne__c config1 = new EMS_FMV_Configuration_gne__c(
            Type_of_HCP_gne__c = 'PhD Researchers/Psychologists',
            Disturbance_Fee_gne__c = 'Flight (Event held in Canada/US and over 6hrs, return trip)',
            Disturbance_Fee_Amount_gne__c = 300,
            Speaker_Tour_gne__c = true,
            EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        EMS_FMV_Configuration_gne__c config2 = new EMS_FMV_Configuration_gne__c(
            Type_of_HCP_gne__c = 'PhD Researchers/Psychologists',
            Disturbance_Fee_gne__c = 'Flight (Event held in Canada/US and over 6hrs, return trip)',
            Disturbance_Fee_Amount_gne__c = 400,
            Speaker_Tour_gne__c = false,
            EMS_Event_Configuration_gne__c = eventConfig.Id
        );
        insert new List<EMS_FMV_Configuration_gne__c>{config1, config2};

        // TotalAmount values are generated for special satic FMV attendees
        Decimal totalAmountPrevious =
            Decimal.valueOf(attendees[0].HCP_hourly_rate_table_gne__c) *
                (
                Decimal.valueOf(attendees[0].Preparation_Time_1_gne__c) + Decimal.valueOf(attendees[0].Preparation_Time_2_gne__c) + Decimal.valueOf(attendees[0].Preparation_Time_3_gne__c) +
                Decimal.valueOf(attendees[0].Activity_Time_1_gne__c) + Decimal.valueOf(attendees[0].Activity_Time_2_gne__c) +Decimal.valueOf(attendees[0].Activity_Time_3_gne__c)
                )
            + config1.Disturbance_Fee_Amount_gne__c;
        Decimal totalAmountActual =
            Decimal.valueOf(attendees[0].HCP_hourly_rate_table_gne__c) *
                (
                Decimal.valueOf(attendees[0].Preparation_Time_1_gne__c) + Decimal.valueOf(attendees[0].Preparation_Time_2_gne__c) + Decimal.valueOf(attendees[0].Preparation_Time_3_gne__c) +
                Decimal.valueOf(attendees[0].Activity_Time_1_gne__c) + Decimal.valueOf(attendees[0].Activity_Time_2_gne__c) +Decimal.valueOf(attendees[0].Activity_Time_3_gne__c)
                )
            + config2.Disturbance_Fee_Amount_gne__c;

        //Link childEvenst with ParentEvent => it will change Disturbance_Fee_Amount_gne__c value for each Attendee
        for (EMS_Event__c event : childEvents) {
            event.Parent_Speaker_Tour_Event_gne__c = parentEvent.Id;
        }
        update childEvents;
        for (EMS_Attendee_gne__c att : [SELECT Total_Honoraria_gne__c FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :childEvents]) {
            System.assertEquals(totalAmountPrevious, att.Total_Honoraria_gne__c);
        }

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        parentEvent.Speaker_Tour_gne__c = false;
        update parentEvent;
        Test.stopTest();

        for (EMS_Attendee_gne__c att : [SELECT Total_Honoraria_gne__c FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :childEvents]) {
            System.assertEquals(totalAmountActual, att.Total_Honoraria_gne__c);
        }
    }

    // EMS Event Trigger Herlper
    private static testMethod void eventTriggerHelper_getRocheAttendeeForEvents_test() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        Test.startTest();
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship','Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Event__c event : events) {
            eventIds.add(event.Id);
        }
        Test.stopTest();
        System.assertEquals(BATCH_SIZE, EMS_Event_Trigger_Helper.getRocheAttendeeForEvents(eventIds).size());
    }
*/


/*  // SOQL 101 Exception
    private static testMethod void adjustAllocatedAmountOnRelatedBudgetEventCloseCancel_territoryBudgetUpdate() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0, rsmUser);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, 800, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Learning Programs','Accredited CHE Implementation', Date.today(), Date.today().addDays(7), BATCH_SIZE);

        Id territoryBudgetAllocationRTId = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Territory_Budget_Allocation' LIMIT 1].Id;
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsForTerritory = EMS_Test_Util.createBudgetAllocations(territoryBudgetAllocationRTId, 100.0, rb.Assigned_to_gne__c, events, null, null, tb.Id);
        Set<Id> budgetTerritoryIds = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c item :budgetAllocationsForTerritory) {
            budgetTerritoryIds.add(item.EMS_Product_Budget_gne__c);
        }
        System.assertNotEquals(0, budgetTerritoryIds.size());

        AggregateResult[] groupedResults = [SELECT Sum(Events_Allocated_Amount_gne__c) SumOfAA FROM EMS_Budget_Territory_gne__c WHERE Id IN :budgetTerritoryIds];
        System.assertEquals(10*BATCH_SIZE, groupedResults[0].get('SumOfAA'));

        EMS_Event_Trigger_Helper.clearProcessedSet();
        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;
        Test.stopTest();

        for (EMS_Budget_Territory_gne__c budgetTerritory : [SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :budgetTerritoryIds]) {
            System.assertEquals(budgetTerritory.Events_Allocated_Amount_gne__c, 0);
        }
    }
    // SOQL 101 EXCEPTION IN EMS_Budget_Region_gne__c trigger
    private static testMethod void adjustAllocatedAmountOnClosedEventWithExpensesHigherThanPlannedTest_RegionBudget() {
        //List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        //List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType regionBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(regionBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, rb.Id, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        // check events allocated amount for PB
        rb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :rb.Id ];
        System.assertEquals(0.0, rb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);

        Test.stopTest();

        rb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :rb.Id ];
        System.assertEquals(110.0 * BATCH_SIZE, rb.Events_Allocated_Amount_gne__c);
    }

    // SOQL 101 EXCEPTION IN EMS_Budget_Region_gne__c trigger
    private static testMethod void adjustAllocatedAmountOnClosedEventWithExpensesHigherThanPlannedTest_TerritoryBudget() {
        // select test user
        //List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        //List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));
        //List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers.get(0));

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);


        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUser);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, 800 * BATCH_SIZE, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType territoryBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Territory_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(territoryBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, null, tb.Id);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        // check events allocated amount for PB
        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(0.0, tb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);

        Test.stopTest();

        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(110.0 * BATCH_SIZE, tb.Events_Allocated_Amount_gne__c);
    }

    // SOQL 101 EXCEPTION IN EMS_Budget_Region_gne__c trigger
    private static testMethod void adjustAllocatedAmountOnClosedEventWithExpensesLessThanPlannedTest_RegionBudget() {
        // select test user
        //List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        //List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUser);


        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType regionBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(regionBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, rb.Id, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();

        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        // check events allocated amount for PB
        rb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :rb.Id ];
        System.assertEquals(0.0, rb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 90.0, costCenters[0]);

        Test.stopTest();

        rb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :rb.Id ];

        System.assertEquals(90.0 * BATCH_SIZE, rb.Events_Allocated_Amount_gne__c);
    }

    // SOQL 101 EXCEPTION IN EMS_Budget_Region_gne__c trigger
    private static testMethod void adjustAllocatedAmountOnClosedEventWithExpensesLessThanPlannedTest_TerritoryBudget() {
        // select test user
        //List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        //List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));
        //List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers.get(0));

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUser);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, 800 * BATCH_SIZE, repUser);


        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType territoryBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Territory_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(territoryBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, null, tb.Id);

        EMS_Event_Trigger_Helper.clearProcessedSet();

        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        // check events allocated amount for PB
        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(0.0, tb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 90.0, costCenters[0]);

        Test.stopTest();

        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(90.0 * BATCH_SIZE, tb.Events_Allocated_Amount_gne__c);
    }


    private static testMethod void adjustAllocatedAmountOnCancelledEventWithExpensesHigherThanPlannedTest_RegionBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUsers[0]);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType regionBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(regionBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, rb.Id, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;

        // check events allocated amount for PB
        rb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :rb.Id ];
        System.assertEquals(0.0, rb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);

        Test.stopTest();

        pb = [ SELECT Events_Allocated_Amount__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id ];
        System.assertEquals(110.0 * BATCH_SIZE, pb.Events_Allocated_Amount__c);
    }

    private static testMethod void adjustAllocatedAmountOnCancelledEventWithExpensesHigherThanPlannedTest_TerritoryBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers.get(0));

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUsers[0]);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, 800 * BATCH_SIZE, repUsers[0]);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType territoryBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Territory_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(territoryBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, null, tb.Id);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;

        // check events allocated amount for PB
        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(0.0, tb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 110.0, costCenters[0]);

        Test.stopTest();

        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(110.0 * BATCH_SIZE, tb.Events_Allocated_Amount_gne__c);
    }

    private static testMethod void adjustAllocatedAmountOnCancelledEventWithExpensesLessThanPlannedTest_RegionBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUsers[0]);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType regionBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(regionBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, rb.Id, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;

        // check events allocated amount for PB
        rb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :rb.Id ];
        System.assertEquals(0.0, rb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 90.0, costCenters[0]);

        Test.stopTest();

        rb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :rb.Id ];
        System.assertEquals(90.0 * BATCH_SIZE, rb.Events_Allocated_Amount_gne__c);
    }

    private static testMethod void adjustAllocatedAmountOnCancelledEventWithExpensesLessThanPlannedTest_TerritoryBudget() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', pmUsers.get(0));
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers.get(0));

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 900.0 * BATCH_SIZE, rsmUsers[0]);
        EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, 800 * BATCH_SIZE, repUsers[0]);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        // select record type
        RecordType territoryBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Territory_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(territoryBudgetAllocationRT.Id, 100.0, rb.Assigned_to_gne__c, events, null, null, tb.Id);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        // close the event
        for(EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;

        // check events allocated amount for PB
        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(0.0, tb.Events_Allocated_Amount_gne__c);
        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();

        // create expense
        EMS_Test_Util.createExpenses(events, 90.0, costCenters[0]);

        Test.stopTest();

        tb = [ SELECT Events_Allocated_Amount_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id = :tb.Id ];
        System.assertEquals(90.0 * BATCH_SIZE, tb.Events_Allocated_Amount_gne__c);
    }
*/
}