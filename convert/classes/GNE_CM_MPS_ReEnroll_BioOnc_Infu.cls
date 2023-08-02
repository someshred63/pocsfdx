/**
 * Parent class for all patient re-enrollments for the BioOncology Infusion form.
 * @author Stephen Waters
 * @created 10/2012
 */
public virtual without sharing class GNE_CM_MPS_ReEnroll_BioOnc_Infu extends GNE_CM_MPS_ReEnroll
{
    

    /**
     * Fetch a list of Medical Histories to be included in a Form 
     * 
     * @param cs Case from which a PER will be generated
     */
    public override List<Medical_History_gne__c> getFormMedicalHistories(Case cs)
    {
        List<Medical_History_gne__c> lst=[select Id, RecordType.Name, ICD9_Code_1_gne__r.ICD9_Code_gne__c, ICD9_Code_2_gne__r.ICD9_Code_gne__c, ICD9_Code_3_gne__r.ICD9_Code_gne__c from Medical_History_gne__c where Patient_Med_Hist_gne__c = :cs.Patient_gne__c and MPS_Form_gne__c = :cs.Medical_History_gne__r.MPS_Form_gne__c ORDER BY CreatedDate DESC];
        //System.debug(lst);
        return lst;
    
    }
    
    /*
     * Copy Medical History fields common to all BioOnc Infu
     */
    public override Patient_Enrollment_Request_gne__c updateFormPER (Patient_Enrollment_Request_gne__c per, Medical_History_gne__c mh)
    {       
        //per.Primary_ICD_9_Code_gne__c = coalesce(per.Primary_ICD_9_Code_gne__c, mh.ICD9_Code_1_gne__r.ICD9_Code_gne__c);
        per.Primary_ICD9_Code_gne__c = coalesce(per.Primary_ICD9_Code_gne__c, mh.ICD9_Code_1_gne__r.ICD9_Code_gne__c);
        //per.Secondary_ICD_9_Code_gne__c = coalesce(per.Secondary_ICD_9_Code_gne__c, mh.ICD9_Code_2_gne__r.ICD9_Code_gne__c);
        per.Secondary_ICD9_Code_gne__c = coalesce(per.Secondary_ICD9_Code_gne__c, mh.ICD9_Code_2_gne__r.ICD9_Code_gne__c);
        
        per.Has_treatment_started_gne__c = coalesce(per.Has_treatment_started_gne__c, mh.Has_Treatment_Started__c);
        per.If_yes_Date_of_First_Treatment_gne__c = coalesce(per.If_yes_Date_of_First_Treatment_gne__c, mh.Date_of_First_Treatment_gne__c);
        
        per.Place_of_Administration_gne__c = coalesce(per.Place_of_Administration_gne__c, GNE_CM_MPS_Utils.mh2perPlaceOfAdministration(mh.Place_of_Administration_gne__c));
        
        //per.Date_of_Diagnosis_gne__c = coalesce(per.Date_of_Diagnosis_gne__c, mh.Date_of_Diagnosis_gne__c);
        
        per.Line_of_Therapy_BioOnc_gne__c = coalesce(per.Line_of_Therapy_BioOnc_gne__c, 
            getMapPickVal(GNE_CM_MPS_Utils.mh2perLineOfTherapy(mh.Therapy_Sequence_gne__c), Patient_Enrollment_Request_gne__c.Line_of_Therapy_BioOnc_gne__c.getDescribe()));
        
        per.Chemotherapy_gne__c = coalesce(per.Chemotherapy_gne__c,truncateValue(mh.Chemotherapy_gne__c,Patient_Enrollment_Request_gne__c.Chemotherapy_gne__c.getDescribe()));
        per.Concurrent_Therapy_gne__c = coalesce(per.Concurrent_Therapy_gne__c, truncateValue(mh.Concurrent_Other_gne__c,Patient_Enrollment_Request_gne__c.Concurrent_Therapy_gne__c.getDescribe()));
        //per.Clinical_Trial_Patient_gne__c = coalesce(per.Clinical_Trial_Patient_gne__c, mh.Clinical_Trial_gne__c);
        //per.If_yes_Study_Site_gne__c = coalesce(per.If_yes_Study_Site_gne__c, mh.Study_Site_gne__c); 
        
        //Santosh Changes
        if(mh.Product_gne__c == 'Gazyva') 
        {
            per.Disease_Characteristics_gne__c  = coalesce(per.Disease_Characteristics_gne__c,mh.Disease_Characteristics_Rituxan_gne__c);
            system.debug('--------------------mh.Tumor_Staging_gne__c'+mh.Tumor_Staging_gne__c);
            if(mh.Tumor_Staging_gne__c == 'Stage 0 / Dukes A')
            {
                per.Clinical_TNM_Stage_gne__c = '0';
            }
            else if(mh.Tumor_Staging_gne__c == 'Stage IA')
            {
                per.Clinical_TNM_Stage_gne__c = 'I';
            }
            else if(mh.Tumor_Staging_gne__c == 'Stage IIA (Early Local Disease) / Dukes B')
            {
                per.Clinical_TNM_Stage_gne__c = 'IIA';
            }
            else if(mh.Tumor_Staging_gne__c == 'Stage IIB (Early Local Disease) / Dukes B')
            {
                per.Clinical_TNM_Stage_gne__c = 'IIB';
            }
            else if(mh.Tumor_Staging_gne__c == 'Stage IIIA (Advanced Local Disease) / Dukes C')
            {
                per.Clinical_TNM_Stage_gne__c = 'IIIA';
            }
            else if(mh.Tumor_Staging_gne__c == 'Stage IIIB (Advanced Local Disease) / Dukes C')
            {
                per.Clinical_TNM_Stage_gne__c = 'IIIB';
            }
            else if(mh.Tumor_Staging_gne__c == 'Stage IIIC (Advanced Local Disease) / Dukes C')
            {
                per.Clinical_TNM_Stage_gne__c = 'IIIC';
            }
            else if(mh.Tumor_Staging_gne__c == 'Stage IV (Advanced Metastatic Disease) / Dukes D')
            {
                per.Clinical_TNM_Stage_gne__c = 'IV';
            }
        }
        
        //End of Santosh Changes
        per.Test_Results_FISH_ratio_gne__c = coalesce(per.Test_Results_FISH_ratio_gne__c, 
            getMapPickVal(mh.First_Assay_Test_Fish_Value_gne__c, Patient_Enrollment_Request_gne__c.Test_Results_FISH_ratio_gne__c.getDescribe()));      
        per.Test_Results_Other_gne__c = coalesce(per.Test_Results_Other_gne__c, truncateValue(mh.Tests_Other_gne__c,Patient_Enrollment_Request_gne__c.Test_Results_Other_gne__c.getDescribe()));   
        per.Adjuvant_gne__c = coalesce(per.Adjuvant_gne__c, mh.Adjuvant_gne__c);
        
        
        GNE_CM_MPS_ReEnroll.MergeMultiSelectReturn mmsr=MergeMultiSelect(per.Previous_Treatment_Name_gne__c, 
                                                            per.Previous_Treatment_Other_gne__c, 
                                                            mh.Previous_Therapy_Regimens_gne__c, 
                                                            Patient_Enrollment_Request_gne__c.Previous_Treatment_Name_gne__c.getDescribe(), 
                                                            true);
        per.Previous_Treatment_Name_gne__c=mmsr.multiSelectValue;
        
        //Santosh Changes
        if(mh.Previous_Therapy_Regimens_gne__c == '' && mh.Previous_Therapy_Regimens_gne__c == null && mh.Product_gne__c == 'Gazyva')
        {
            per.Previous_Treatment_Name_gne__c = '';
        }
        //End
        //per.Previous_Treatment_Other_gne__c=truncateValue(mmsr.multiSelectOtherValue,Patient_Enrollment_Request_gne__c.Previous_Treatment_Other_gne__c.getDescribe());
        per.Previous_Treatment_Other_gne__c=coalesce(per.Previous_Treatment_Other_gne__c, truncateValue(mh.Previous_Other_gne__c,Patient_Enrollment_Request_gne__c.Previous_Treatment_Other_gne__c.getDescribe()));
        
        return per; 
    }
}