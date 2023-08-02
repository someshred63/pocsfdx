@isTest
public without sharing class EMS_Event_Validation_Rules_Test_2 {

    private static Integer BATCH_SIZE = 200;

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
    
	/*private static testMethod void validateBudgetAllocationOnSubmitTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 10000000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorships', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorships', 'Sponsorship of Events', Date.today() - 2, Date.today() - 1, 100.0, BATCH_SIZE);
        } catch (Exception ex) {
            System.assert(false, 'Unplanned event should be inserted ' + ex.getMessage());
        }

        // select record type
        RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];

        // create budget allocation
        // NOTE: "attachmentsForEvent" var in EMS_Event_Trigger_Helper.cls is Empty (NOT null) 
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);       

        User pmUser = [ SELECT Id FROM User WHERe Id = :pmUsers[0] LIMIT 1 ];
        try { 
            Test.startTest();
            EMS_Test_Util.createAttachments(events, 'Letter of Request');
            
            System.runAs(pmUser) {
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                for(EMS_Event__c event : events) {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(event.id);
                    requests.add(request);
                }
                List<Approval.ProcessResult> result = Approval.process(requests);
            }
            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Event with allocated funds should be sent to approval: ' + ex.getMessage()); //   You need to attach Letter of Request to submit GD event
        }
    }*/

    private static testMethod void validateNoLetterOfRequestOnSubmitTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Grants', 'Medical Research Grant', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Grants', 'Medical Research Grant', Date.today() - 2, Date.today() - 1, 100.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        User pmUser = [SELECT Id FROM User WHERE Id = :pmUsers[0] LIMIT 1];

        try {
            Test.startTest();
            System.runAs(pmUser) {
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                for (EMS_Event__c event : events) {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(event.id);
                    requests.add(request);
                }
                List<Approval.ProcessResult> result = Approval.process(requests);
            }

            Test.stopTest();
        } catch (Exception ex) {
            //'No applicable approval process was found'
            System.assert(ex.getMessage().contains('You need to attach Letter of Request to submit'), ex.getMessage());//System.Label.Attach_Letter_Of_Request
        }
    }

    private static testMethod void validateLetterOfRequestOnSubmitTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Grants', 'Medical Research Grant', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Grants', 'Medical Research Grant', Date.today() - 2, Date.today() - 1, 100.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        User pmUser = [SELECT Id FROM User WHERE Id = :pmUsers[0] LIMIT 1];

        try {
            Test.startTest();

            System.runAs(pmUser) {
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                for (EMS_Event__c event : events) {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(event.id);
                    requests.add(request);
                }
                List<Approval.ProcessResult> result = Approval.process(requests);
            }

            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'GD Event with letter of request attached should be sent to approval ' + ex.getMessage() + ' user  ' + pmUser.Id);
        }
    }

    private static testMethod void validateCannotCloseNonGSDEventWithoutAttendeesTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Informal consulting', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Consulting Meetings', 'Informal consulting', Date.today() - 1, Date.today(), BATCH_SIZE);
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
            System.assert(false, 'Event without attendees should not be closed');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You cannot close the event without attendees.'), e.getMessage());
        }
    }

    private static testMethod void validateCanCloseNonGSDEventWithAttendeesTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Consulting Meetings', 'Informal consulting', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Consulting Meetings', 'Informal consulting', Date.today() - 1, Date.today(), BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        //add attendee to the event
        EMS_Test_Util.createAttendees(events);

        try {
            Test.startTest();

            for (EMS_Event__c event : events) {
                event.Status_gne__c = 'Closed';
            }
            update events;

            Test.stopTest();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You cannot close the event without attendees.'), e.getMessage());
        }
    }

    private static testMethod void validateCanCloseGSDEventWithoutAttendeesTest() {
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
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), BATCH_SIZE);
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
            System.assert(false, 'GSD Event without attendees should be closed');
        }
    }

    private static testMethod void validateCannotEditClosedEventTest() {
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
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // close event
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        try {
            Test.startTest();
            // change event name
            for (EMS_Event__c event : events) {
                event.Event_Name_gne__c = 'changedName';
            }
            update events;
            Test.stopTest();

            System.assert(false, 'Closed event cannot be edited');

        } catch (Exception e) {
            System.assert(e.getMessage().contains('You cannot edit Event with this status.'), e.getMessage());
        }
    }

    private static testMethod void validateCannotEditCancelledEventTest() {
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
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        for (EMS_Event__c event : events) {
            // close event
            event.Status_gne__c = 'Cancelled';
        }
        update events;

        try {
            Test.startTest();
            // change event name
            for (EMS_Event__c event : events) {
                event.Event_Name_gne__c = 'changedName';
            }
            update events;
            Test.stopTest();

            System.assert(false, 'Cancelled event cannot be edited');

        } catch (Exception e) {
            System.assert(e.getMessage().contains('You cannot edit Event with this status.'), e.getMessage());
        }
    }

    private static testMethod void validateAdminCanChangeLockedEventTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        try {
            events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);
        } catch (Exception e) {
            System.assert(false, 'Unplanned event should be inserted');
        }

        // select record type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // create budget allocation
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EMS_Test_Util.getUserApplicationContext(currentUser, true, 'Admin', null, 'EMS-Canada');

        User pmUser = [SELECT Id FROM User WHERe Id = :pmUsers[0] LIMIT 1];

        // create a letter of request
        EMS_Test_Util.createAttachments(events, 'Letter Of Request');

        try {
            Test.startTest();

            System.runAs(pmUser) {
                List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
                for (EMS_Event__c event : events) {
                    // submit event for approval
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(event.id);
                    requests.add(request);
                }
                List<Approval.ProcessResult> result = Approval.process(requests);
            }

            // change event name
            for (EMS_Event__c event : events) {
                event.Event_Name_gne__c = 'changedName';
            }
            update events;

            Test.stopTest();
        } catch (DMLException ex) {
            System.assert(false, 'Admin should be able to edit locked event: ' + ex.getMessage());
        }
    }

    private static testMethod void validateNonAdminCanChangeLockedEventTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events;

        User pmUser = [SELECT Id FROM User WHERe Id = :pmUsers[0] LIMIT 1];

        try {
            Test.startTest();
            System.runAs(pmUser) {

                try {
                    events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

                    // create a letter of request
                    EMS_Test_Util.createAttachments(events, 'Letter Of Request');

                } catch (Exception e) {
                    System.assert(false, 'Unplanned event should be inserted');
                }

                // select record type
                RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
                RecordType ownerApprovedRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Event__c' AND DeveloperName = 'EMS_Owner_Approved_Event' LIMIT 1];

                // create budget allocation
                EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

                // change status to Approved
                for (EMS_Event__c event : events) {
                    event.Status_gne__c = 'Approved';
                    event.RecordTypeId = ownerApprovedRT.Id;
                }
                update events;

                for (EMS_Event__c event : events) {
                    // change event name
                    event.Event_Name_gne__c = 'changedName';
                }
                update events;
            }
            Test.stopTest();

            System.assert(false, 'Non-Admin should not be able to edit locked event');

        } catch (Exception e) {
            System.assert(e.getMessage().contains('You cannot edit Event with this status.'), e.getMessage()); 
 //           System.assert(e.getMessage().contains('the entity is locked for editing'), e.getMessage());
        }
    }
}