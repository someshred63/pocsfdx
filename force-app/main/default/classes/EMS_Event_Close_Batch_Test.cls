@isTest
private class EMS_Event_Close_Batch_Test {

    public static Integer BATCH_SIZE = 2;

    @isTest
    static void closeMedOpsApprovedEventTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today() - 7, Date.today() - 1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);
        EMS_Test_Util.createAttendees(events);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        EMS_Event_Trigger_Helper.clearAttendeeForEvents();

        for (EMS_Event__c ev : events) {
            ev.Status_gne__c = 'Med Ops Approved';
        }
        update events;

        Test.startTest();
        Database.executeBatch(new EMS_Event_Close_Batch());
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Closed', event.Status_gne__c);
        }
    }
/*
    @isTest SOQL 101
    static void cancelPendingEventTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today()-7, Date.today()-1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);
        EMS_Test_Util.createAttendees(events);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        EMS_Event_Trigger_Helper.clearAttendeeForEvents();

        // submit to approval
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            event.Submitted_Date_gne__c = System.today();
            event.Submitted_By_gne__c = UserInfo.getUserId();
            event.Approver_gne__c = UserInfo.getUserId();


            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        System.debug(LoggingLevel.ERROR, '### 1 :' + Limits.getQueries() + '   ' + Limits.getDMLRows());
        update events;

        System.debug(LoggingLevel.ERROR, '### 2 :' + Limits.getQueries() + '   ' + Limits.getDMLRows());

        Approval.process(requests);

        Test.startTest();
        Database.executeBatch(new EMS_Event_Close_Batch());
        Test.stopTest();

        for(EMS_Event__c event : [ SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('Cancelled', event.Status_gne__c);
        }
    }
*/
    @isTest
    static void closeOldGDEventOwnerApprovedEventTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('GD', 'Grant in Aid Education - Institution / Organization', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'GD', 'Grant in Aid Education - Institution / Organization', Date.today() - 7, Date.today() - 1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);
        EMS_Event_Trigger_Helper.clearProcessedSet();
        for (EMS_Event__c ev : events) {
            ev.Status_gne__c = 'Approved';
        }
        update events;

        Test.startTest();
        Database.executeBatch(new EMS_Event_Close_Batch());
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Closed', event.Status_gne__c);
        }
    }

    @isTest
    static void cancelOldGDEventOwnerApprovedEventTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('GD', 'Grant in Aid Education - Institution / Organization', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'GD', 'Grant in Aid Education - Institution / Organization', Date.today() - 7, Date.today() - 1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);

        Test.startTest();
        Database.executeBatch(new EMS_Event_Close_Batch());
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Cancelled', event.Status_gne__c);
        }
    }

    @isTest
    static void closeOldGDEventMedOpsApprovedEventTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('GD', 'Grant in Aid Education - Institution / Organization', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Planned', mmUser, 'GD', 'Grant in Aid Education - Institution / Organization', Date.today() - 7, Date.today() - 1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);

        EMS_Event_Trigger_Helper.clearProcessedSet();

        for (EMS_Event__c ev : events) {
            ev.Status_gne__c = 'Med Ops Approved';
        }
        update events;

        Test.startTest();
        Database.executeBatch(new EMS_Event_Close_Batch());
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Closed', event.Status_gne__c);
        }
    }

    @isTest
    static void cancelOldGDEventMedOpsApprovedEventTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('GD', 'Grant in Aid Education - Institution / Organization', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Planned', mmUser, 'GD', 'Grant in Aid Education - Institution / Organization', Date.today() - 7, Date.today() - 1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);

        Test.startTest();
        Database.executeBatch(new EMS_Event_Close_Batch());
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Cancelled', event.Status_gne__c);
        }
    }

    /* SOQL 101
    @isTest 
    static void dontCloseCancelledEventTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MM');
        Id pmUser = ids[0];
        Id mmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mmUser);

        List<EMS_Cost_Center_gne__c> medicalCostCenters = EMS_Test_Util.createCostCenters('Medical Department', 1, true);
        EMS_Budget_Product_gne__c medicalPb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, mmUser, medicalCostCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'Accredited CHE Implementation', medicalCostCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUser, 'Learning Programs', 'Accredited CHE Implementation', Date.today()-7, Date.today()-1, 100.0, BATCH_SIZE);
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, medicalPb.Assigned_to_gne__c, events, medicalPb.Id, null, null);
        EMS_Test_Util.createAttendees(events);

        EMS_Event_Trigger_Helper.clearProcessedSet();
        for (EMS_Event__c ev : events) {
            ev.Status_gne__c = 'Cancelled';
        }
        update events;

        Test.startTest();
        Database.executeBatch(new EMS_Event_Close_Batch());
        Test.stopTest();

        for(EMS_Event__c event : [ SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
            System.assertEquals('Cancelled', event.Status_gne__c);
        }
    }*/
}