@isTest
private class EDM_MultiselectPicklistWithSrc_Ctrl_Test {

    public static testMethod void initCompNoRecordsTest() {

        EDM_MultiselectPicklistWithSearch_Ctrl ctrl = new EDM_MultiselectPicklistWithSearch_Ctrl();
        ctrl.objectTypeName = 'Event_Curriculum_gne__c';
        ctrl.columnFields = 'Id,EDM_Title_Multiselect_gne__c,Start_Date_gne__c,Aprimo_Id_gne__c';
        ctrl.columnLabels = ',,';
        ctrl.whereExpr = '';
        ctrl.checkboxField = 'Curriculum_Status_gne__c';

        ctrl.retrieveAvailable();

        System.assertEquals('', ctrl.itemsString);
    }

    public static testMethod void initCompTest() {

        List<Event_Curriculum_gne__c> eventCurriculumList = new List<Event_Curriculum_gne__c>();

        // Create Event_Curriculum_gne__c test objects
        Event_Curriculum_gne__c activeEventCurriculum = new Event_Curriculum_gne__c(Name = 'Active Test Curriculum', Start_Date_gne__c = System.today() + 7);
        Event_Curriculum_gne__c inactiveEventCurriculum = new Event_Curriculum_gne__c(Name = 'Inactive Test Curriculum', Start_Date_gne__c = System.today() - 7);
        eventCurriculumList.add(activeEventCurriculum);
        eventCurriculumList.add(inactiveEventCurriculum);
        insert(eventCurriculumList);

        EDM_MultiselectPicklistWithSearch_Ctrl ctrl = new EDM_MultiselectPicklistWithSearch_Ctrl();
        ctrl.objectTypeName = 'Event_Curriculum_gne__c';
        ctrl.columnFields = 'Id,EDM_Title_Multiselect_gne__c,Start_Date_gne__c,Aprimo_Id_gne__c';
        ctrl.columnLabels = 'L1,L2,';
        ctrl.whereExpr = '';
        ctrl.checkboxField = 'Curriculum_Status_gne__c';

        ctrl.retrieveAvailable();

        Integer countEvntCurr = [Select Count() From Event_Curriculum_gne__c] -1;


        System.assertEquals(countEvntCurr, ctrl.itemsString.countMatches(';'));
        System.assert(ctrl.itemsString.contains(eventCurriculumList[0].Id));
        System.assert(ctrl.itemsString.contains(eventCurriculumList[1].Id));
    }
}