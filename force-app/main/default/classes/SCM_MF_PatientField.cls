public virtual class SCM_MF_PatientField extends SCM_MergeField {
    protected Patient_gne__c patient;
    private static List<Patient_gne__c> patientList;
    public SCM_MF_PatientField(String patientId)
    {
        checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		if(patientList==null)
		{
         patientList = [Select 	   p.Counter_gne__c, 
								   p.Created_Date_Calc_gne__c, 
								   p.Dist_Pat_ID_gne__c, 
								   p.Eligible_for_Nutropin_Starter_gne__c, 
								   p.Eligible_for_Pulmozyme_Starter_gne__c, 
								   p.Hearing_Impaired_gne__c, 
								   p.Id, 
								   p.Mid_Initial_gne__c, 
								   p.Name, 
								   p.Non_English_Speaking_gne__c, 
								   p.Note_gne__c, 
								   p.PAN_Form_1_Expiration_Date_gne__c, 
								   p.PAN_Form_1_Product_gne__c, 
								   p.PAN_Form_2_Exipration_Date_gne__c, 
								   p.PAN_Form_2_gne__c, 
								   p.PAN_Form_2_Product_gne__c, 
								   p.PAN_Form_2_Rec_gne__c, 
								   p.PAN_Form_2_Signed_gne__c, 
								   p.PAN_Form_Rec_gne__c, 
								   p.PAN_Form_Signed_gne__c, 
								   p.PAN_gne__c, 
								   p.PAN_TAT_gne__c, 
								   p.pat_dob_gne__c, 
								   p.pat_email_gne__c, 
								   p.pat_first_name_gne__c, 
								   p.pat_gender_gne__c, 
								   p.pat_home_phone_gne__c, 
								   p.pat_income_gne__c, 
								   p.pat_other_phone_gne__c, 
								   p.pat_other_phone_type_gne__c, 
								   p.pat_patient_deceased_gne__c, 
								   p.pat_prefix_gne__c, 
								   p.pat_work_phone_gne__c, 
								   p.Patient_ID_gne__c, 
								   p.Patient_Name__c, 
								   p.Patient_Number_gne__c, 
								   p.Patient_Preferred_Distributor_gne__c, 
								   p.Preferred_Language_gne__c, 
								   p.Release_gne__c, 
								   p.Service_Quality_gne__c, 
								   p.Service_Quality_Offered_Date_gne__c, 
								   p.ssn_gne__c, 
								   p.Status_Change_Date_gne__c, 
								   p.Suffix_gne__c, 
								   p.Translator_Needed_gne__c, 
								   p.Vendor_Case_ID_gne__c, 
								   p.Web_Pat_ID_gne__c 
					from Patient_gne__c p 
  					Where Id=:patientId
                 ];
		}
        if(patientList.size()==1)
            patient= patientList[0];
        else
        {
            patient = null; 
        }
    }

}