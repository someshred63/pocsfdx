@isTest
private class EMS_Meeting_Room_Child_Rec_Upd_Test {

    private static Integer BATCH_SIZE = 101;

    @isTest
    static void sendEventForReapprovalOnMeetingRoomSectionChangeTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'OLA Implementation', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Learning Programs', 'OLA Implementation', Date.today(), Date.today() + 1, 1, BATCH_SIZE);

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        List<EMS_Meeting_Request_gne__c> meetingRequests = EMS_Test_Util.createMeetingRequests(events);
        List<EMS_Meeting_Room_gne__c> meetingRooms = EMS_Test_Util.createMeetingRooms(meetingRequests);

		EMS_Test_Util.createAttendees(events);

        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(event.id);
            requests.add(request);
        }
        List<Approval.ProcessResult> result = Approval.process(requests);

        Set<Id> eventIds = new Set<Id>();
        for (EMS_Event__c event : events) {
            eventIds.add(event.Id);
        }

        // approve
        List<Id> processInstanceWorkitemIds = new List<Id>();

        List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, CreatedById, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                where TargetObject.Id IN :eventIds
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    processInstanceWorkitemIds.add(piw.Id);
                }
            }
        }

        List<Approval.ProcessWorkitemRequest> approveRequests = new List<Approval.ProcessWorkitemRequest>();
        for (Id processInstanceWorkitemId : processInstanceWorkitemIds) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setAction('Approve');
            request.setWorkitemId(processInstanceWorkitemId);

            approveRequests.add(request);
        }

        Approval.process(approveRequests);

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Approved', event.Status_gne__c);
        }

        Test.startTest();

        for (EMS_Meeting_Room_gne__c meetingRoom : meetingRooms) {
            meetingRoom.Break_Out_Room_gne__c = 'changed name';
        }

        update meetingRooms;

        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Pending Approval', event.Status_gne__c);
        }
    }
}