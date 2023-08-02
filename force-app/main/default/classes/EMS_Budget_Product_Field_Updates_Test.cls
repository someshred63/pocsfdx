@isTest
private class EMS_Budget_Product_Field_Updates_Test {

    private static final Integer BATCH_SIZE = 210;
    private static final String COST_CENTER_NAME = 'Commercial Product';
    private static final String PB_TERRITORY = 'ROCHE-CANADA';

    /**
     *  1. updateTerritoryId
     *  2. updateName
     *  3. deactivateBudget
     */

    //1. updateTerritoryId
    private static testMethod void updateTerritoryId_newRecordInserted_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        Integer i = 0;
        String currentYear = String.valueOf(Date.today().year());
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
        Id terrId = EMS_Util.getTerritoryByName(PB_TERRITORY).territoryId;

        // Test on Insert trigger
        for (EMS_Budget_Product_gne__c pb : [SELECT Id, Assigned_To_Territory_Id__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(terrId, pb.Assigned_To_Territory_Id__c);
            i++;
        }
    }

    //2. updateName. Change name_gne__c to predefined schema
    private static testMethod void updateName_onBeforeInsertOnBeforeUpdate_NameIsUpdated_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        String currentYear = String.valueOf(Date.today().year());
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 1000.0, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);

        // Test on Insert trigger
        List<EMS_Budget_Product_gne__c> pbList = [SELECT Id, Name_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets ORDER BY Name_gne__c ASC];
        // 0, 1, 10, 100, 101, 102... Do not use For Each loop for asserts
        System.assertEquals('PB-' + currentYear + '-' + 'CostCenter-0-ProductIndication0-' + PB_TERRITORY, pbList[0].Name_gne__c);
        if (BATCH_SIZE > 3) {
            System.assertEquals('PB-' + currentYear + '-' + 'CostCenter-1-ProductIndication1-' + PB_TERRITORY, pbList[1].Name_gne__c);
            System.assertEquals('PB-' + currentYear + '-' + 'CostCenter-10-ProductIndication10-' + PB_TERRITORY, pbList[2].Name_gne__c);
        }

        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Name_gne__c = 'no name';
        }
        update productBudgets;

        // Test on update trigger
        System.assertEquals('PB-' + currentYear + '-' + 'CostCenter-0-ProductIndication0-' + PB_TERRITORY, pbList[0].Name_gne__c);
        if (BATCH_SIZE > 3) {
            System.assertEquals('PB-' + currentYear + '-' + 'CostCenter-1-ProductIndication1-' + PB_TERRITORY, pbList[1].Name_gne__c);
            System.assertEquals('PB-' + currentYear + '-' + 'CostCenter-10-ProductIndication10-' + PB_TERRITORY, pbList[2].Name_gne__c);
        }
    }

    //3 deactivateBudget. Change record type when budget is set to inactive
    private static testMethod void deactivateBudget_budgetIsSetToInactive_ChangeRecordType_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);

        Test.startTest();
        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Status_gne__c = 'Inactive';
        }
        update productBudgets;
        Test.stopTest();

        Id inactivePBRT = EMS_Test_Util.pbRecordTypesMap.get('EMS Canada Inactive Product Budget');
        // Test on Update
        for (EMS_Budget_Product_gne__c pb : [SELECT Id, RecordTypeId FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(inactivePBRT, pb.RecordTypeId);
        }
    }
}