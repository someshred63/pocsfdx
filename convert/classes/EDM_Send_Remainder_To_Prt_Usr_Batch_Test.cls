@isTest
public class EDM_Send_Remainder_To_Prt_Usr_Batch_Test {
    public static testMethod void executeBatch() {
        Test.startTest();
        EDM_Send_Remainder_To_Partner_Usr_Batch b = new EDM_Send_Remainder_To_Partner_Usr_Batch();
        database.executebatch(b);
        Test.stopTest();
    }
}