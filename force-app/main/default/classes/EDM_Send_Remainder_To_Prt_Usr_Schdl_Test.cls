@isTest
public class EDM_Send_Remainder_To_Prt_Usr_Schdl_Test {
    public static testMethod void scheduleBatch() {
        Test.startTest();
        EDM_Send_Remainder_To_Prt_Usr_Schedule sch = new EDM_Send_Remainder_To_Prt_Usr_Schedule();
        System.schedule('Test Check', '0 0 23 * * ?', sch);
        Test.stopTest();
    }
}