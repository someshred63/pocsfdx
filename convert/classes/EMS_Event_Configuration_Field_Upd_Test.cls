@isTest
private class EMS_Event_Configuration_Field_Upd_Test {
    private static final Integer BATCH_SIZE = 101;

    @isTest
    static void generateExternalIdonInsert() {
        Test.startTest();

        List<EMS_Event_Configuration_gne__c> eventConfigurations = EMS_Test_Util.createEventConfigurations('eventType', 'eventSubtype', BATCH_SIZE);

        Test.stopTest();

        for (EMS_Event_Configuration_gne__c eventConfig : [SELECT External_Id_gne__c FROM EMS_Event_Configuration_gne__c WHERE Id IN :eventConfigurations]) {
            System.assertNotEquals(null, eventConfig.External_Id_gne__c);
            System.assertEquals('eventType_eventSubtype', eventConfig.External_Id_gne__c);
        }
    }

    @isTest
    static void generateExternalIdonUpdate() {
        List<EMS_Event_Configuration_gne__c> eventConfigurations = EMS_Test_Util.createEventConfigurations('eventType', 'eventSubtype', BATCH_SIZE);
        for (EMS_Event_Configuration_gne__c eventConfig : [SELECT External_Id_gne__c FROM EMS_Event_Configuration_gne__c WHERE Id IN :eventConfigurations]) {
            System.assertNotEquals(null, eventConfig.External_Id_gne__c);
            System.assertEquals('eventType_eventSubtype', eventConfig.External_Id_gne__c);
        }

        Test.startTest();

        for (EMS_Event_Configuration_gne__c eventConfig : eventConfigurations) {
            eventConfig.Event_Sub_Type_gne__c = 'newSubtype';
        }
        update eventConfigurations;

        Test.stopTest();

        for (EMS_Event_Configuration_gne__c eventConfig : [SELECT External_Id_gne__c FROM EMS_Event_Configuration_gne__c WHERE Id IN :eventConfigurations]) {
            System.assertNotEquals(null, eventConfig.External_Id_gne__c);
            System.assertEquals('eventType_newSubtype', eventConfig.External_Id_gne__c);
        }
    }
}