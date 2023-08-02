@IsTest
private class CFAR_ClinicalSupplyReport_DataModel_Test {

    @testSetup
    static void setup() {
        CFAR_Theme_gne__c theme = new CFAR_Theme_gne__c(
                Name = '99999',
                Theme_Name_gne__c = 'Accutane',
                Active_gne__c = true
        );
        insert theme;

        CFAR_Product_gne__c product1 = new CFAR_Product_gne__c(
                Theme_ref_gne__c = theme.Id,
                Name = 'Accutane',
                Generic_Name_gne__c = 'acc',
                Active_gne__c = true
        );
        insert product1;

        CFAR_Unit_Type_gne__c unitType = new CFAR_Unit_Type_gne__c();
        unitType.Name = 'Tablet';
        unitType.Active_gne__c = true;
        insert unitType;

        CFAR_Molecule_Configuration_gne__c molecConfig = new CFAR_Molecule_Configuration_gne__c(
                Product_gne__c = product1.Id,
                CFAR_Unit_Type_ref_gne__c = unitType.id,
                Configuration_gne__c = '100mg',
                Active_gne__c = true
        );
        insert molecConfig;

        CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c(
                Name = 'type 1',
                Active_gne__c = true
        );
        insert trialType;

        CFAR_Trial_gne__c t1 = CFAR_DataFactory.createTrial(0);
        t1.CTMS_gne__c = '09999';
        t1.Trial_Type_ref_gne__c = trialType.Id;
        t1.Other_Trial_gne_Id__c = '99983';
        t1.Genentech_Primary_Contact_ref_gne__c = CFAR_TestUtils.createTestPrimaryContact().Id;
        CFAR_Trial_gne__c t2 = CFAR_DataFactory.createTrial(1);
        t2.CTMS_gne__c = '09996';
        t2.Trial_Type_ref_gne__c = trialType.Id;
        t2.Other_Trial_gne_Id__c = '99985';
        t2.Genentech_Primary_Contact_ref_gne__c = CFAR_TestUtils.createTestPrimaryContact().Id;
        insert new List<CFAR_Trial_gne__c>{
                t1, t2
        };

        CFAR_Cohort_gne__c coh1 = CFAR_DataFactory.createCohort(t1, 1, 50);
        coh1.Total_Cohort_Patients_gne__c = 100;
        CFAR_Cohort_gne__c coh2 = CFAR_DataFactory.createCohort(t2, 2, 50);
        coh2.Total_Cohort_Patients_gne__c = 50;
        insert new List<CFAR_Cohort_gne__c>{
                coh1, coh2
        };

        CFAR_Cohort_Molecule_gne__c cm1 = CFAR_DataFactory.createCohortMolecule(coh1, 5, 1, molecConfig);
        cm1.Months_On_Therapy_gne__c = 5;
        CFAR_Cohort_Molecule_gne__c cm2 = CFAR_DataFactory.createCohortMolecule(coh2, 2, 1, molecConfig);
        cm2.Months_On_Therapy_gne__c = 2;
        insert new List<CFAR_Cohort_Molecule_gne__c>{
                cm1, cm2
        };

        CFAR_Milestone_Activity_gne__c mil1 = CFAR_DataFactory.createMilestoneActivity(t1, 'Activation');
        CFAR_Milestone_Activity_gne__c mil2 = CFAR_DataFactory.createMilestoneActivity(t1, 'Proposal Approval');
        CFAR_Milestone_Activity_gne__c mil3 = CFAR_DataFactory.createMilestoneActivity(t1, 'Draft Protocol Approval');
        CFAR_Milestone_Activity_gne__c mil4 = CFAR_DataFactory.createMilestoneActivity(t1, 'IMD Approval');
        CFAR_Milestone_Activity_gne__c mil5 = CFAR_DataFactory.createMilestoneActivity(t1, 'SRT Protocol Approval');
        CFAR_Milestone_Activity_gne__c mil6 = CFAR_DataFactory.createMilestoneActivity(t1, 'TRAC Protocol Approval');
        CFAR_Milestone_Activity_gne__c mil7 = CFAR_DataFactory.createMilestoneActivity(t1, 'FPI');
        CFAR_Milestone_Activity_gne__c mil8 = CFAR_DataFactory.createMilestoneActivity(t1, 'LPI');
        CFAR_Milestone_Activity_gne__c mil9 = CFAR_DataFactory.createMilestoneActivity(t1, 'LPO');
        CFAR_Milestone_Activity_gne__c mil10 = CFAR_DataFactory.createMilestoneActivity(t1, 'Study Closure');
        insert new List<CFAR_Milestone_Activity_gne__c>{
                mil1, mil2, mil3, mil4, mil5, mil6, mil7, mil8, mil9, mil10
        };
        System.assert(true);
    }

    @IsTest
    static void shouldCalculateMonthsAvgSince() {
        Integer results = CFAR_ClinicalSupplyReport_DataModel.monthsAvgSince(Date.newInstance(2018, 2, 17));
        System.assert(results != null);
        System.assert(results > 0);
    }

    @IsTest
    static void shouldCalculateMonthsAvgBetween() {
        Integer results = CFAR_ClinicalSupplyReport_DataModel.monthsAvgBetween(Date.newInstance(2017, 2, 17), Date.newInstance(2018, 2, 17));
        System.assert(results != null);
        System.assert(results > 0);
        System.assertEquals(12, results);
    }

    @IsTest
    private static void shouldPrepareCohortMoleculeWrapper() {
        // given
        CFAR_Trial_gne__c trial = [
                SELECT Id, (SELECT Id,Planned_Date_gne__c, Actual_Date_gne__c, Name FROM CFAR_Milestone_Activities__r)
                FROM CFAR_Trial_gne__c
                WHERE CTMS_gne__c = '09999'
        ];
        CFAR_Cohort_Molecule_gne__c cohortMolecule = [
                SELECT Id
                FROM CFAR_Cohort_Molecule_gne__c
                WHERE Cohort_ref_gne__c IN (SELECT Id FROM CFAR_Cohort_gne__c WHERE Trial_ref_gne__c = :trial.Id)
        ];
        CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper wrapper = new CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper(cohortMolecule, trial);
        System.assertEquals(10, wrapper.actual2Date.size());
        System.assertEquals(10, wrapper.planned2Date.size());
        System.assert(wrapper.role2TeamMember == null);
        System.assert(wrapper.month2quota == null);
        System.assert(wrapper.year2quota == null);
        System.assert(wrapper.firstFewMonthsOfNextYear == null);
    }

    @IsTest
    static void shouldFillAllWrapperVariables() {
        // given
        CFAR_Trial_gne__c trial = [
                SELECT Id, Other_Trial_gne_Id__c, CTMS_gne__c, Name,
                        frm_Genentech_Primary_Contact_ref_gne__c, frm_Trial_Type_ref_gne__c,
                        Planned_Enrollment_gne__c,Enrolled_Sum_rollup_gne__c
                FROM CFAR_Trial_gne__c
                WHERE CTMS_gne__c = '09999'
        ];
        CFAR_Cohort_Molecule_gne__c cohortMolecule = [
                SELECT Id, Dosage_Qty_gne__c,Months_On_Therapy_gne__c, Dosage_Frequency_gne__c,Dosage_Interval_gne__c,
                        Cohort_ref_gne__r.Cohort_number_gne__c,
                        Cohort_ref_gne__r.Total_Cohort_Patients_gne__c,
                        Molecule_Configuration_ref_gne__r.Product_gne__r.Generic_Name_gne__c,
                        Molecule_Configuration_ref_gne__r.Configuration_gne__c,
                        Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__r.Name
                FROM CFAR_Cohort_Molecule_gne__c
                WHERE Cohort_ref_gne__c IN (SELECT Id FROM CFAR_Cohort_gne__c WHERE Trial_ref_gne__c = :trial.Id)
        ];
        CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper wrapper = new CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper(cohortMolecule, trial);
        // when
        CFAR_ClinicalSupplyReport_DataModel.fillAllWrapperVariables(wrapper);
        // then
        System.assertEquals(cohortMolecule.Dosage_Qty_gne__c, wrapper.singleDose);
        System.assertEquals(cohortMolecule.Months_On_Therapy_gne__c, wrapper.monthsOnTherapy);

        System.assertEquals(cohortMolecule.Cohort_ref_gne__r.Cohort_number_gne__c, wrapper.cohort);
        System.assertEquals(cohortMolecule.Cohort_ref_gne__r.Total_Cohort_Patients_gne__c, wrapper.patientsPerCohort);
        System.assertEquals('no configuration', wrapper.doseRegiment);
        System.assertEquals(cohortMolecule.Molecule_Configuration_ref_gne__r.Product_gne__r.Generic_Name_gne__c, wrapper.impShipped);

        System.assertEquals(trial.CTMS_gne__c, wrapper.ctms);
        System.assertEquals(trial.Name, wrapper.gStars);
        System.assertEquals(trial.frm_Genentech_Primary_Contact_ref_gne__c, wrapper.csm);
        System.assertEquals(trial.frm_Trial_Type_ref_gne__c, wrapper.trialType);
        System.assertEquals(trial.Planned_Enrollment_gne__c, wrapper.plannedEnrollment);
        System.assertEquals(trial.Enrolled_Sum_rollup_gne__c, wrapper.actualEnrollment);
    }

    @IsTest
    static void shouldFetchForecast() {
        // given
        CFAR_Trial_gne__c trial = [
                SELECT Id, Other_Trial_gne_Id__c, CTMS_gne__c, Name,
                        frm_Genentech_Primary_Contact_ref_gne__c, frm_Trial_Type_ref_gne__c,
                        Planned_Enrollment_gne__c,Enrolled_Sum_rollup_gne__c, CFAR_Rate_of_Accrual_gne__c,
                        Enrollment_Enrolled_Num_gne__c, (SELECT Id,Planned_Date_gne__c, Actual_Date_gne__c, Name FROM CFAR_Milestone_Activities__r), (SELECT Id, Total_Cohort_Patients_gne__c FROM gSTARS_Cohorts__r)
                FROM CFAR_Trial_gne__c
                WHERE CTMS_gne__c = '09999'
        ];
        CFAR_Cohort_Molecule_gne__c cohortMolecule = [
                SELECT Id, Dosage_Qty_gne__c,Months_On_Therapy_gne__c, Dosage_Frequency_gne__c,Dosage_Interval_gne__c,
                        Cohort_ref_gne__r.Cohort_number_gne__c,
                        Cohort_ref_gne__r.Total_Cohort_Patients_gne__c,
                        Molecule_Configuration_ref_gne__r.Product_gne__r.Generic_Name_gne__c,
                        Molecule_Configuration_ref_gne__r.Configuration_gne__c,
                        Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__r.Name
                FROM CFAR_Cohort_Molecule_gne__c
                WHERE Cohort_ref_gne__c IN (SELECT Id FROM CFAR_Cohort_gne__c WHERE Trial_ref_gne__c = :trial.Id)
        ];
        CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper wrapper = new CFAR_ClinicalSupplyReport_DataModel.CohortMoleculeWrapper(cohortMolecule, trial);
        // when
        Map<String, Integer> results = CFAR_ClinicalSupplyReport_DataModel.fetchForecasts(wrapper);
        // then
        System.assert(results != null);
        System.assert(!results.isEmpty());
    }
}