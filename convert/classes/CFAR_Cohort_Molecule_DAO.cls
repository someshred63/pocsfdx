public class CFAR_Cohort_Molecule_DAO {
    public static List<CFAR_Cohort_Molecule_gne__c> fetchCohortMoleculeForClinicalReport(String parameters){
        String queryString = 
            'SELECT Id, Name, Generated_Forecasts__c, Cohort_ref_gne__r.Trial_ref_gne__c, Cohort_ref_gne__r.Trial_ref_gne__r.Name, Cohort_ref_gne__r.Trial_ref_gne__r.frm_Genentech_Primary_Contact_ref_gne__c, Dosage_Qty_gne__c, Dosage_Frequency_gne__c, '+
                'Dosage_Interval_gne__c, Months_On_Therapy_gne__c, '+
                'Cohort_ref_gne__r.Cohort_number_gne__c, Cohort_ref_gne__r.Total_Cohort_Patients_gne__c, '+
                'Molecule_Configuration_ref_gne__r.Configuration_gne__c, Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__c, Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__r.Name, Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__r.Active_gne__c, '+
                'Molecule_Configuration_ref_gne__r.Product_gne__r.Name, Molecule_Configuration_ref_gne__r.Product_gne__r.Generic_Name_gne__c ' +
            'FROM CFAR_Cohort_Molecule_gne__c '+
            'WHERE Cohort_ref_gne__r.Trial_ref_gne__c != null ';
        queryString += parameters;
        queryString += ' ORDER BY Cohort_ref_gne__r.Trial_ref_gne__r.Name, Cohort_ref_gne__r.Cohort_number_gne__c, Molecule_Configuration_ref_gne__r.Product_gne__r.Name ';
        queryString += ' LIMIT 9999';
        
        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);  
    }
    
    public static Map<Id, CFAR_Trial_gne__c> fetchTrialsForClinicalReport(Set<Id> trialIds){
        return new Map<Id, CFAR_Trial_gne__c>([
            SELECT Id, Name, Other_Trial_gne_Id__c, CTMS_gne__c, frm_Genentech_Primary_Contact_ref_gne__c, frm_Trial_Type_ref_gne__c, Planned_Enrollment_gne__c,
                Enrolled_Sum_rollup_gne__c, CFAR_Rate_of_Accrual_gne__c, Enrollment_Enrolled_Num_gne__c,
            (SELECT Total_Cohort_Patients_gne__c FROM gSTARS_Cohorts__r),
            (SELECT frm_Other_GNE_Agent_gne__c FROM gSTARS_Trial_Other_GNE_Agents__r),
            (SELECT Name, Planned_Date_gne__c, Actual_Date_gne__c FROM CFAR_Milestone_Activities__r ORDER BY Planned_Date_gne__c),
            (SELECT frm_Name_gne__c, frm_function_role_gne__c
             FROM CFAR_Team_Members__r 
             WHERE Function_Role_gne__c IN  (:CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER, :CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR)
                 AND frm_Is_Inactive_gne__c = false )
            FROM CFAR_Trial_gne__c
            WHERE Id IN :trialIds
            ORDER BY CreatedDate DESC
        ]);     
    }

    private static final String COHORT_MOLECULE_COMMON_BASE = 'SELECT Id, Name, Generated_Forecasts__c, Cohort_ref_gne__r.Trial_ref_gne__c, Cohort_ref_gne__r.Trial_ref_gne__r.Name, Cohort_ref_gne__r.Trial_ref_gne__r.frm_Genentech_Primary_Contact_ref_gne__c, Dosage_Qty_gne__c, Dosage_Frequency_gne__c, ' +
            'Dosage_Interval_gne__c, Months_On_Therapy_gne__c, ' +
            'Cohort_ref_gne__r.Cohort_number_gne__c, Cohort_ref_gne__r.Total_Cohort_Patients_gne__c, ' +
            'Molecule_Configuration_ref_gne__r.Configuration_gne__c, Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__c, Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__r.Name, Molecule_Configuration_ref_gne__r.CFAR_Unit_Type_ref_gne__r.Active_gne__c, ' +
            'Molecule_Configuration_ref_gne__r.Product_gne__r.Name, Molecule_Configuration_ref_gne__r.Product_gne__r.Generic_Name_gne__c ' +
            'FROM CFAR_Cohort_Molecule_gne__c ';

    public static List<CFAR_Cohort_Molecule_gne__c> fetchCohortMoleculeForGenerateForecasts(Set<Id> cohortIds){
        String queryString = COHORT_MOLECULE_COMMON_BASE + 'WHERE Cohort_ref_gne__c IN :cohortIds';
        queryString += ' ORDER BY Cohort_ref_gne__r.Trial_ref_gne__r.Name, Cohort_ref_gne__r.Cohort_number_gne__c, Molecule_Configuration_ref_gne__r.Product_gne__r.Name ';
        queryString += ' LIMIT 9999';

        CFAR_Utils.logInfo(queryString);
        return Database.query(queryString);
    }

    public static List<CFAR_Cohort_Molecule_gne__c> fetchCohortMoleculeForForecasts(Set<Id> moleculeIds){
        String queryString = COHORT_MOLECULE_COMMON_BASE + 'WHERE Id IN :moleculeIds AND Cohort_ref_gne__r.Trial_ref_gne__r.Drug_Supply_Generate_Forecasts_Date__c != null';
        return Database.query(queryString);
    }
}