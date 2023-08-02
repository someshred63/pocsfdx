@isTest
private class EMS_Event_Field_Updates_Test {

    private static Integer BATCH_SIZE = 11;

    private static Id fetchApprovalProcessItems(Id objectId) {
        List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, CreatedById, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                where TargetObject.Id = :objectId
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    return piw.Id; //Only one item can be in pending status.
                }
            }
        }
        return null;
    }

    private static Map<Id, Id> fetchApprovalProcessItems(List<EMS_Event__c> events) {
        Map<Id, Id> result = new Map<Id, Id>();
        List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, CreatedById, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                where TargetObjectId IN :events
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    result.put(pi.TargetObjectId, piw.Id);
                }
            }
        }
        return result;
    }

    private static Approval.ProcessWorkitemRequest constructApprovalRequest(String action, Id processInstanceWorkitemId, String comments) {
        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setComments(comments);
        request.setAction(action);
        request.setWorkitemId(ProcessInstanceWorkitemId);
        return request;
    }

    public static testMethod void territoryIdPopulatedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        // select territory id
        EMS_Util.EMS_Territory pmTerr = EMS_Util.getUserTerritories(pmUsers[0])[0];

        try {
            Test.startTest();

            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, pmTerr.Name, BATCH_SIZE);

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        for (EMS_Event__c event : [SELECT Assigned_To_Territory_Requestor_Id_gne__c, Assigned_To_Territory_Owner_Id_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(pmTerr.Id, event.Assigned_To_Territory_Owner_Id_gne__c);
            System.assertEquals(pmTerr.Id, event.Assigned_To_Territory_Requestor_Id_gne__c);
        }
    }

    public static testMethod void validateRecordTypecChangeOnCancelTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        // select record type
        RecordType cancelledEventRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Event__c' AND DeveloperName = 'EMS_Cancelled_Event' LIMIT 1];

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);

        try {
            Test.startTest();
            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Cancelled';
            }
            update events;

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        for (EMS_Event__c event : [SELECT RecordTypeId FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(cancelledEventRecordType.Id, event.RecordTypeId);
        }
    }

    public static testMethod void validateRecordTypecChangeOnCloseTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        // select record type
        RecordType closedEventRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Event__c' AND DeveloperName = 'EMS_Closed_Event' LIMIT 1];

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), BATCH_SIZE);

        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Closed';
            }
            update events;

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, e.getMessage());
        }

        for (EMS_Event__c event : [SELECT RecordTypeId FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(closedEventRecordType.Id, event.RecordTypeId);
        }
    }

    public static testMethod void validateRecordTypecChangeOnSignedAgreementRecievedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        // select record type
        RecordType signedAgreementRecievedRecordType = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Event__c' AND DeveloperName = 'EMS_Signed_Agreement_Received_Event' LIMIT 1];

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);

        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Signed Agreement Received';
            }
            update events;

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        for (EMS_Event__c event : [SELECT RecordTypeId FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(signedAgreementRecievedRecordType.Id, event.RecordTypeId);
        }
    }

    public static testMethod void costCenterTypePopulatedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            Test.startTest();

            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        for (EMS_Event__c event : [SELECT Cost_Center_Type_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Commercial Department', event.Cost_Center_Type_gne__c);
        }
    }

    public static testMethod void plannedFlagPopulatedForPlannedEventTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            Test.startTest();

            events = EMS_Test_Util.createEvents('Planned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Event should be inserted');
        }

        for (EMS_Event__c event : [SELECT Is_Planned_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            System.assertEquals(true, event.Is_Planned_gne__c);
        }
    }

    public static testMethod void plannedFlagNotPopulatedForUnplannedTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            Test.startTest();

            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Event should be inserted');
        }

        for (EMS_Event__c event : [SELECT Is_Planned_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            System.assertEquals(false, event.Is_Planned_gne__c);
        }
    }

    public static testMethod void statusChangedOnRecallForUnplannedEventTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 1.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);

        Map<Id, Id> processInstanceWorkitemIds = fetchApprovalProcessItems(events);
        List<Approval.ProcessWorkitemRequest> recallRequests = new List<Approval.ProcessWorkitemRequest>();
        for (EMS_Event__c event : events) {
            // recall event from approval
            recallRequests.add(constructApprovalRequest('Removed', processInstanceWorkitemIds.get(event.Id), null));
        }
        Approval.process(recallRequests);
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Approval_Rejection_Comments_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            System.assertEquals('Unplanned', event.Status_gne__c);
        }
    }

    public static testMethod void statusChangedOnRecallForPlannedEventTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Planned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 1.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);

        Map<Id, Id> processInstanceWorkitemIds = fetchApprovalProcessItems(events);
        List<Approval.ProcessWorkitemRequest> recallRequests = new List<Approval.ProcessWorkitemRequest>();

        for (EMS_Event__c event : events) {
            // recall event from approval
            recallRequests.add(constructApprovalRequest('Removed', processInstanceWorkitemIds.get(event.Id), 'sample recall comment'));
        }
        Approval.process(recallRequests);
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            System.assertEquals('Planned', event.Status_gne__c);
        }
    }

    public static testMethod void overrideApproverNoDelegationTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 1.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Approver_gne__c FROM EMS_Event__c WHERE Id IN :events LIMIT 1]) {
            System.assertEquals(pmUsers[0], event.Approver_gne__c);
        }
    }

    public static testMethod void overrideApproverWithDelegationTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', null);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        // create delegation record
        EMS_Test_Util.createUserDelegation(pmUsers[0], repUsers[0], System.today(), System.today(), 'test comments');

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 1.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Approver_gne__c FROM EMS_Event__c WHERE Id = :events]) {
            System.assertEquals(repUsers[0], event.Approver_gne__c);
        }
    }

    public static testMethod void updateStatusForSpeakerTour_test() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        Id aarcUser = EMS_Test_Util.findExistingUser('AARC', null)[0];
        System.assertNotEquals(null, aarcUser);
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Consultancy Meeting Medical', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);

        // Speaker Tour Parent Event
        EMS_Event__c parentEvent = EMS_Test_Util.prepareEvent('Awaiting Signature from HCP', pmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, null, null, null);
        parentEvent.Speaker_Tour_gne__c = true;
        insert parentEvent;

        // Add Contract
        User aarcUserRecord = [SELECT Id FROM User WHERE Id = :aarcUser AND IsActive = true][0];
        EMS_Test_Util.getUserApplicationContext(aarcUserRecord, true, 'AARC', null, 'EMS-Canada');
        System.runAs(aarcUserRecord) {
            EMS_Test_Util.createAttachments(new List<EMS_Event__c>{
                    parentEvent
            }, 'Signed Contract');
        }
        // Child Events
        List<EMS_Event__c> childEvents = EMS_Test_Util.prepareEvents('Pending Med Ops Review', pmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 10, null, null, null, BATCH_SIZE);
        for (EMS_Event__c event : childEvents) {
            event.Parent_Speaker_Tour_Event_gne__c = parentEvent.Id;
        }
        insert childEvents;


        Test.startTest();
        for (EMS_Event__c ev : childEvents) {
            ev.Status_gne__c = 'Med Ops Approved';
        }
        update childEvents;
        Test.stopTest();

        for (EMS_Event__c ev : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN:childEvents]) {
            System.assertEquals('Signed Agreement Received', ev.Status_gne__c);
        }
    }

    public static testMethod void updateStatusForSpeakerTourOnAdd_test() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        Id aarcUser = EMS_Test_Util.findExistingUser('AARC', null)[0];
        System.assertNotEquals(null, aarcUser);
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Consultancy Meeting Medical', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);

        // Speaker Tour Parent Event
        EMS_Event__c parentEvent = EMS_Test_Util.prepareEvent('Awaiting Signature from HCP', pmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, null, null, null);
        parentEvent.Speaker_Tour_gne__c = true;
        insert parentEvent;

        // Add Contract
        User aarcUserRecord = [SELECT Id FROM User WHERE Id = :aarcUser AND IsActive = true][0];
        EMS_Test_Util.getUserApplicationContext(aarcUserRecord, true, 'AARC', null, 'EMS-Canada');
        System.runAs(aarcUserRecord) {
            EMS_Test_Util.createAttachments(new List<EMS_Event__c>{
                    parentEvent
            }, 'Signed Contract');
        }
        // Child Events
        List<EMS_Event__c> childEvents = EMS_Test_Util.prepareEvents('Awaiting Signature from HCP', pmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 10, null, null, null, BATCH_SIZE);
        insert childEvents;

        Test.startTest();
        for (EMS_Event__c event : childEvents) {
            event.Parent_Speaker_Tour_Event_gne__c = parentEvent.Id;
        }
        update childEvents;
        Test.stopTest();

        for (EMS_Event__c ev : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN:childEvents]) {
            System.assertEquals('Signed Agreement Received', ev.Status_gne__c);
        }
    }

    public static testMethod void updateStatusForSpeakerTourOnRemove_test() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        Id aarcUser = EMS_Test_Util.findExistingUser('AARC', null)[0];
        System.assertNotEquals(null, aarcUser);
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Consultancy Meeting Medical', costCenters[0]);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', costCenters[0]);

        // Speaker Tour Parent Event
        EMS_Event__c parentEvent = EMS_Test_Util.prepareEvent('Awaiting Signature from HCP', pmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 1, null, null, null);
        parentEvent.Speaker_Tour_gne__c = true;
        insert parentEvent;

        // Add Contract
        User aarcUserRecord = [SELECT Id FROM User WHERE Id = :aarcUser AND IsActive = true][0];
        EMS_Test_Util.getUserApplicationContext(aarcUserRecord, true, 'AARC', null, 'EMS-Canada');
        System.runAs(aarcUserRecord) {
            EMS_Test_Util.createAttachments(new List<EMS_Event__c>{
                    parentEvent
            }, 'Signed Contract');
        }
        // Child Events
        List<EMS_Event__c> childEvents = EMS_Test_Util.prepareEvents('Awaiting Signature from HCP', pmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today(), Date.today() + 10, null, null, null, BATCH_SIZE);
        insert childEvents;

        Test.startTest();
        for (EMS_Event__c event : childEvents) {
            event.Parent_Speaker_Tour_Event_gne__c = parentEvent.Id;
        }
        update childEvents;
        childEvents = [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN:childEvents];
        for (EMS_Event__c ev : childEvents) {
            System.assertEquals('Signed Agreement Received', ev.Status_gne__c);
        }

        for (EMS_Event__c event : childEvents) {
            event.Parent_Speaker_Tour_Event_gne__c = null;
        }
        update childEvents;
        Test.stopTest();

        for (EMS_Event__c ev : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN:childEvents]) {
            System.assertEquals('Med Ops Approved', ev.Status_gne__c);
        }

    }

    /*public static testMethod void setCommentsOnEventApprovalTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 1.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();

        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);

        Map<Id, Id> processInstanceWorkitemIds = fetchApprovalProcessItems(events);
        List<Approval.ProcessWorkitemRequest> approveRequests = new List<Approval.ProcessWorkitemRequest>();

        for(EMS_Event__c event : events) {
            // approve event
            approveRequests.add(constructApprovalRequest('Approve', processInstanceWorkitemIds.get(event.Id), 'sample comment'));
        }
        Approval.process(approveRequests);

        for(EMS_Event__c event : [ SELECT Approval_Rejection_Comments_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('sample comment', event.Approval_Rejection_Comments_gne__c);
        }

        // now check med ops approval
        requests = new List<Approval.ProcessSubmitRequest>();
        for(EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        result = Approval.process(requests);

        processInstanceWorkitemIds = fetchApprovalProcessItems(events);
        approveRequests = new List<Approval.ProcessWorkitemRequest>();
        for(EMS_Event__c event : events) {
            // approve event
            approveRequests.add(constructApprovalRequest('Approve', processInstanceWorkitemIds.get(event.Id), 'sample med ops approval comment'));
        }
        Approval.process(approveRequests);

        Test.stopTest();

        for(EMS_Event__c event : [ SELECT Approval_Rejection_Comments_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('Med Ops Approved', event.Status_gne__c);
            System.assertEquals('sample med ops approval comment', event.Approval_Rejection_Comments_gne__c);
        }
    }

    public static testMethod void setCommentsOnEventRejectTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 1.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);

        Map<Id, Id> processInstanceWorkitemIds = fetchApprovalProcessItems(events);
        List<Approval.ProcessWorkitemRequest> approveRequests = new List<Approval.ProcessWorkitemRequest>();

        for(EMS_Event__c event : events) {
            // approve event
            approveRequests.add(constructApprovalRequest('Reject', processInstanceWorkitemIds.get(event.Id), 'sample reject comment'));
        }
        Approval.process(approveRequests);
        Test.stopTest();

        for(EMS_Event__c event : [ SELECT Approval_Rejection_Comments_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('Rejected', event.Status_gne__c);
            System.assertEquals('sample reject comment', event.Approval_Rejection_Comments_gne__c);
        }
    }

    public static testMethod void setCommentsOnEventMedOpsRejectTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 1.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        Test.startTest();
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for(EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        Approval.process(requests);

        Map<Id, Id> processInstanceWorkitemIds = fetchApprovalProcessItems(events);
        List<Approval.ProcessWorkitemRequest> approveRequests = new List<Approval.ProcessWorkitemRequest>();
        for(EMS_Event__c event : events) {
            // approve event
            approveRequests.add(constructApprovalRequest('Approve', processInstanceWorkitemIds.get(event.Id), 'sample comment'));
        }
        Approval.process(approveRequests);

        for(EMS_Event__c event : [ SELECT Approval_Rejection_Comments_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('sample comment', event.Approval_Rejection_Comments_gne__c);
        }

        // now check med ops approval
        requests = new List<Approval.ProcessSubmitRequest>();
        for(EMS_Event__c event : events) {
            // submit event for approval
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        Approval.process(requests);

        for(EMS_Event__c event : [ SELECT Approval_Rejection_Comments_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('Pending Med Ops Review', event.Status_gne__c);
        }

        processInstanceWorkitemIds = fetchApprovalProcessItems(events);
        List<Approval.ProcessWorkitemRequest> rejectRequests = new List<Approval.ProcessWorkitemRequest>();

        for(EMS_Event__c event : events) {
            // reject event
            rejectRequests.add(constructApprovalRequest('Reject', processInstanceWorkitemIds.get(event.Id), 'med ops rejection comment'));
        }
        Approval.process(rejectRequests);
        Test.stopTest();

        for(EMS_Event__c event : [ SELECT Approval_Rejection_Comments_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('Med Ops Rejected', event.Status_gne__c);
            System.assertEquals('med ops rejection comment', event.Approval_Rejection_Comments_gne__c);
        }
    }*/
}