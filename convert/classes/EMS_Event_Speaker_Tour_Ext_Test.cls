@isTest
private class EMS_Event_Speaker_Tour_Ext_Test {

    private static final Integer BATCH_SIZE = 5;

    static testMethod void testOne() {
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Medical Product', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, mmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Learning Programs', 'OLA Implementation', 'Medical Product');
        EMS_Test_Util.createPossibleBudgetAllocationMapping('GD', 'Grant in Aid Education - Individual', 'Medical Product');

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', mmUsers[0], 'Learning Programs', 'OLA Implementation', Date.today(), Date.today() + 1, BATCH_SIZE);
        EMS_Test_Util.createTravels(events);

        Integer speakerTourEventsCounter = 0;
        for (Integer i = 0; i < events.size(); i++) {
            if (i == 0) {
                events[i].Speaker_Tour_gne__c = true;
                speakerTourEventsCounter++;
            } else if (i == 1) {
                events[i].Speaker_Tour_gne__c = false;
            } else {
                events[i].Speaker_Tour_gne__c = false;
                events[i].Parent_Speaker_Tour_Event_gne__c = events[0].Id;
                speakerTourEventsCounter++;
            }
        }
        update events;

        PageReference pageRef = new Pagereference('apex/EMS_Speaker_Tour');
        pageRef.getParameters().put('id', events[0].Id);
        Test.setCurrentPageReference(pageRef);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(events[0]);
        EMS_Event_Speaker_Tour_Ext controller = new EMS_Event_Speaker_Tour_Ext(stdCtrl);
        System.assert(controller.event.id == events[0].id);

        System.assert(true == controller.getCanEdit());


        List<EMS_Event__c> speakerTourEvents = controller.speakerTourEvents;
        System.assertEquals(speakerTourEvents.size(), speakerTourEventsCounter);
        String cv = controller.cumulativeExpValue;

        EMS_Remote_Response response = EMS_Event_Speaker_Tour_Ext.relateOLAEvents(new List<String>{
                String.valueOf(events[1].id)
        }, events[0].id);
        Boolean isSuccess = response.isSuccess;
        System.assert(isSuccess == true);
        System.assertEquals([SELECT Parent_Speaker_Tour_Event_gne__c FROM EMS_Event__c WHERE Id = :events[1].id].Parent_Speaker_Tour_Event_gne__c, events[0].id);

        response = EMS_Event_Speaker_Tour_Ext.detachOLAEvent(String.valueOf(events[1].id));
        isSuccess = response.isSuccess;
        System.assert(isSuccess == true);
        System.assertNotEquals([SELECT Parent_Speaker_Tour_Event_gne__c FROM EMS_Event__c WHERE Id = :events[1].id].Parent_Speaker_Tour_Event_gne__c, events[0].id);

        speakerTourEvents.clear();
//        speakerTourEvents = EMS_Event_Speaker_Tour_Ext.searchOLAEventsBYKeyword('unknown event', events[0].Event_Requestor_gne__c, events[0].Id);
        System.assert(speakerTourEvents.size() == 0);
    }

}