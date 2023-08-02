@isTest
public class EDM_Deactivate_Partner_Users_Batch_Test {

    @testSetup
    private static void initData(){
        GNE_Foun_Misc_Config_Items_gne__c conf1 = new GNE_Foun_Misc_Config_Items_gne__c(
                Name = 'Email_To_Report_Deactivated_Part_Usr',
                Configuration_Value_gne__c = 'waldemar.kaczor@contractors.roche.com'
        );
        insert conf1;
    }

    public static testMethod void executeBatch() {
        Test.startTest();
        EDM_Deactivate_Partner_Users_Batch b = new EDM_Deactivate_Partner_Users_Batch();
        database.executebatch(b);
        Test.stopTest();
    }
}