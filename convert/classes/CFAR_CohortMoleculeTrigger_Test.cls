@IsTest
private class CFAR_CohortMoleculeTrigger_Test {

    @testSetup
    static void setup() {
        CFAR_Theme_gne__c theme = new CFAR_Theme_gne__c(
                Name = '99999',
                Theme_Name_gne__c = 'Accutane',
                Active_gne__c = true
        );
        insert theme;
        CFAR_Trial_gne__c trial = CFAR_DataFactory.createTrial(10);
        trial.Drug_Supply_Generate_Forecasts_Date__c = Date.today();
        insert trial;
        CFAR_Cohort_gne__c coh = CFAR_DataFactory.createCohort(trial, 1, 50);
        insert coh;
        CFAR_Product_gne__c product = new CFAR_Product_gne__c(
                Theme_ref_gne__c = theme.Id,
                Name = 'Accutane',
                Generic_Name_gne__c = 'acc',
                Active_gne__c = true
        );
        insert product;
        CFAR_Unit_Type_gne__c unitType = new CFAR_Unit_Type_gne__c();
        unitType.Name = 'Tablet';
        unitType.Active_gne__c = true;
        insert unitType;
        CFAR_Molecule_Configuration_gne__c molConfig = new CFAR_Molecule_Configuration_gne__c(
                Product_gne__c = product.Id,
                CFAR_Unit_Type_ref_gne__c = unitType.id,
                Configuration_gne__c = '100mg',
                Active_gne__c = true
        );
        insert molConfig;
    }

    @IsTest
    private static void shouldGenerateMoleculeForecast() {
        // given
        CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c];
        CFAR_Cohort_gne__c coh = [SELECT Id FROM CFAR_Cohort_gne__c];
        CFAR_Molecule_Configuration_gne__c molConfig = [SELECT Id FROM CFAR_Molecule_Configuration_gne__c];
        // when
        Test.startTest();
        CFAR_Cohort_Molecule_gne__c cm1 = CFAR_DataFactory.createCohortMolecule(coh, 5, 1, molConfig);
        insert cm1;
        Test.stopTest();
        // then
        List<CFAR_Cohort_Molecule_gne__c> result = [SELECT Id, Generated_Forecasts__c FROM CFAR_Cohort_Molecule_gne__c WHERE Cohort_ref_gne__r.Trial_ref_gne__c = :trial.Id];
        System.assertEquals(1, result.size());
        System.debug(result[0].Generated_Forecasts__c);
        System.assert(String.isNotBlank(result[0].Generated_Forecasts__c));
    }

}