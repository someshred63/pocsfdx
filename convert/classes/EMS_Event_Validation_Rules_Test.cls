@isTest
public without sharing class EMS_Event_Validation_Rules_Test {

    private static Integer BATCH_SIZE = 200;

    // On before Insert 
    private static testMethod void validateCannotInsertClosedEventTest() {
        User testU = EMS_Test_Util.getSystemAdministratorUser();
        System.assertNotEquals(null, testU);
        system.runAs(testU) {
            try {
                List<EMS_Event__c> events = EMS_Test_Util.createEvents('Closed', testU.Id, Date.today(), Date.today() + 1, BATCH_SIZE);
            } catch (Exception e) {
                System.assert(e.getMessage().contains('You cannot create new Event with "Closed" status'));
            }
        }
    }

    private static testMethod void validateCanInsertUnplannedEventTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        try {
            List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }
    }

    private static testMethod void validateStartEndDateOnInsertTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        try {
            List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() + 1, Date.today(), BATCH_SIZE);
            System.assert(false, 'Event with invalid start/end date should not be inserted');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date), e.getMessage());
        }
    }

    private static testMethod void validateOwnerOnInsertTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        Id pmUserId = pmUsers[0];
        try {
            List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUserId, Date.today(), Date.today() + 1, BATCH_SIZE);
            System.assert(false, 'Event with invalid owner should not be inserted');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Event_Owner_Invalid));
        }
    }

    private static testMethod void validateProvinceNotEmptyOnNonGSDEventInsertTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        Id pmUserId = pmUsers[0];
        try {
            List<EMS_Event__c> events = EMS_Test_Util.prepareEvents('Unplanned', pmUserId, Date.today(), Date.today() + 1, BATCH_SIZE);
            for (EMS_Event__c event : events) {
                event.Province_gne__c = null;
            }
            insert events;
            System.assert(false, 'Event with empty province should not be inserted');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Must_Enter_A_Value));
        }
    }

    // On before update 
    private static testMethod void validateStartEndDateOnUpdateTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }


        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Start_Date_gne__c = Date.today() + 2;
            }
            update events;
            System.assert(false, 'Event with invalid start/end date should not be updated');

            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date));
        }
    }

    private static testMethod void validateProvinceNotEmptyOnNonGSDEventUpdateTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        Id pmUserId = pmUsers[0];
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, BATCH_SIZE);
        try {

            for (EMS_Event__c event : events) {
                event.Province_gne__c = null;
            }
            update events;
            System.assert(false, 'Event with empty province should not be updated');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Must_Enter_A_Value));
        }
    }

    private static testMethod void validateOwnerOnUpdateTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;
        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Event_Type_gne__c = 'Non-promotional program';
                event.Event_Sub_Type_gne__c = 'Non-promotional program';
            }

            update events;

            System.assert(false, 'Event with invalid owner should not be updated');

            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Event_Owner_Invalid));
        }
    }

    private static testMethod void validateCloseOnEventWithFutureEndDateTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }


        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Closed';
            }
            update events;

            System.assert(false, 'Event with future end date should not be closed');

            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.EMS_Close_Event_Future_End_Date));
        }
    }

    private static testMethod void validateCloseOnEventWithPastEndDateTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 2, Date.today() - 1, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }


        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Closed';
            }
            update events;

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Event with past end date should be closed');
        }
    }

    private static testMethod void validateCancelOnTheEventWithoutPaymentRequestsTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }


        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Cancelled';
            }
            update events;

            Test.stopTest();
        } catch (Exception e) {
            System.assert(false, 'Event without payment requests should be cancelled');
        }
    }

    private static testMethod void validateCancelOnTheEventWithPaymentRequestsTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 2, Date.today() - 1, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }


        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Cancelled';
            }
            update events;
            System.assert(false, 'Event with payment requests should not be cancelled');

            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.EMS_Cancel_Event_Payment_Initiated));
        }
    }

    // On before delete 
    private static testMethod void deleteEventWithExpensesTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 1, BATCH_SIZE);
        //EMS_Cost_Center_gne__c   

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events, 1.0, costCenters[0]);

        try {
            delete events;
            System.assert(false, 'Event with expenses should not be deleted');
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.label.Remove_Related_Expenses));
        }
    }

    private static testMethod void deleteEventWithoutExpensesTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, BATCH_SIZE);
        try {
            delete events;
        } catch (Exception e) {
            System.assert(false, 'Event with expenses should be deleted');
        }
    }

    private static testMethod void validateNoBudgetAllocationOnSubmitTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 2, Date.today() - 1, 100.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }


        try {
            Test.startTest();

            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Event__c event : events) {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(event.id);
                requests.add(request);
            }
            List<Approval.ProcessResult> result = Approval.process(requests);

            System.assert(false, 'Event without allocated funds should not be sent to approval.');

            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.EMS_Planned_Allocated));
        }
    }
    
/*
    private static testMethod void validateMPCanChangeLocationForLockedEventTest() {
        //Class.EMS_Test_Util.findDependentUserUnderSpecificRole: line 188, column 1
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MP');
        Id pmUser = ids[0];
        Id mpUser = ids[1];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mpUser);

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;
        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        User mpUserRecord = [SELECT Id FROM User WHERE Id = :mpUser LIMIT 1 ];
        EMS_Test_Util.getUserApplicationContext(mpUserRecord, true, 'MP', null, 'EMS-Canada');
        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');
        try {
            Test.startTest();
            System.runAs(mpUserRecord) {
                // submit event for approval
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                for(EMS_Event__c event : events) {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(event.id);
                    requests.add(request);
                }
                List<Approval.ProcessResult> result = Approval.process(requests); 
                // change address
                for(EMS_Event__c event : events) {
                    event.Address_gne__c = 'changedAddress';
                }
                update events;
            }
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'MP should be able to edit location for locked event: ' + ex.getMessage());
        }
    }

    private static testMethod void validateMPCannotChangeOtherFieldsForLockedEventTest() {
        //Class.EMS_Test_Util.findDependentUserUnderSpecificRole: line 188, column 1
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'MP');
        Id pmUser = ids[0];
        Id mpUser = ids[1];
        //List<Id> mpUsers = EMS_Test_Util.findExistingUser('MP', null);
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, mpUser);


        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;
        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        User mpUserRecord = [SELECT Id FROM User WHERE Id = :mpUser LIMIT 1];
        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');
        try {
            Test.startTest();
            System.runAs(mpUserRecord) {
                // submit event for approval
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                for(EMS_Event__c event : events) {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(event.id);
                    requests.add(request);
                }
                List<Approval.ProcessResult> result = Approval.process(requests); 

                for(EMS_Event__c event : events) {
                    // change address
                    event.Event_Name_gne__c = 'changedName';    
                }
                update events;
            }
            Test.stopTest();

            System.assert(false, 'MP should not be able to edit fields otehr than location for locked event');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You cannot edit Event with this status.'), e.getMessage());
        }
    }
    */
}