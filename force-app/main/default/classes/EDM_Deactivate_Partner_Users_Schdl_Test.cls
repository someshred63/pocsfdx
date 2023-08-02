@isTest
public class EDM_Deactivate_Partner_Users_Schdl_Test {
    public static testMethod void executeBatch() {
        Test.startTest();
        EDM_Deactivate_Partner_Users_Schedule sch = new EDM_Deactivate_Partner_Users_Schedule();
        System.schedule('Test Check', '0 0 23 * * ?', sch);
        Test.stopTest();
    }
}