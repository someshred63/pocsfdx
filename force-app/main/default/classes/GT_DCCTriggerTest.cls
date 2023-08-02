@isTest
public  class GT_DCCTriggerTest {
    static testMethod void testGT_DCCTriggerTest() {
        List<GT_Data_Change_Capture_MDM__e> inkEvents = new List<GT_Data_Change_Capture_MDM__e>();
       
       inkEvents.add(new GT_Data_Change_Capture_MDM__e( payload__c = 'test'));
       Test.startTest();
       List<Database.SaveResult> results = EventBus.publish(inkEvents);
       Test.stopTest();
    }
}