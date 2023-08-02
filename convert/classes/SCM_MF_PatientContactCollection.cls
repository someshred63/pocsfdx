public virtual class SCM_MF_PatientContactCollection extends SCM_MergeField {
    
    protected Patient_Contact_gne__c patientContact;
    private static List<Patient_Contact_gne__c> patientContactList; 
    public SCM_MF_PatientContactCollection(String patientId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = true;
        if(patientContactList==null)
        {
        patientContactList= [Select p.Address_Same_As_Patient_gne__c, 
        							 p.Counter_gne__c, 
        							 p.Country_gne__c, 
        							 p.CreatedById, 
        							 p.CreatedBy.Id, 
        							 p.CreatedDate, 
        							 p.First_Name_gne__c, 
        							 p.Hearing_Impaired_gne__c, 
        							 p.Id, 
        							 p.IsDeleted, 
        							 p.IsLocked, 
        							 p.LAST_NAME_CONT_gne__c, 
        							 p.LastModifiedById, 
        							 p.LastModifiedBy.Id, 
        							 p.LastModifiedDate, 
        							 p.MayEdit, 
        							 p.Name, 
        							 p.Non_English_Speaking_gne__c, 
        							 p.Other_Phone_Type_gne__c, 
        							 p.pat_con_City_gne__c, 
        							 p.pat_con_Contact_Type_gne__c, 
        							 p.pat_con_Email_gne__c, 
        							 p.pat_con_Home_Phone_gne__c, 
        							 p.pat_con_Mail_Box_gne__c, 
        							 p.pat_con_Other_Phone_gne__c, 
        							 p.pat_con_Patient_gne__c, 
        							 p.pat_con_Patient_gne__r.Id, 
        							 p.pat_con_Prefix_gne__c, 
        							 p.pat_con_Relationship_to_Patient_gne__c, 
        							 p.pat_con_State_gne__c, 
        							 p.pat_con_Street_gne__c, 
        							 p.pat_con_VIP_Note_gne__c, 
        							 p.pat_con_Work_gne__c, 
        							 p.pat_con_Zip_gne__c, 
        							 p.Preferred_Language_gne__c, 
        							 p.Release_gne__c, 
        							 p.SystemModstamp, 
        							 p.Translator_Needed_gne__c 
        					from Patient_Contact_gne__c p
        					WHERE p.pat_con_Patient_gne__c = :patientId 
        					LIMIT 500];
        }
        if(patientContactList.size()>=1)
            patientContact= patientContactList[0];
        else
        {
            patientContact = null;            
        }
    }
}