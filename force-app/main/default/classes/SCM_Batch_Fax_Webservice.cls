global class SCM_Batch_Fax_Webservice {
 
//private static string FaxStatus;
 
webservice static List<Fax_Batch_gne__c> GetFaxBatchesByStatus(String mystatus) {
    List<Fax_Batch_gne__c> Fb = new List<Fax_Batch_gne__c>();
    //FaxStatus = mystatus;
    system.debug(mystatus );
    //fb = [select id from Fax_Batch_gne__c where Status__c = ''];
    fb = [Select Total_Records__c, Total_Physicians_gne__c, SystemModstamp, Product__c, OwnerId, Next_Anticipated_Batch_Run__c, Name, MayEdit, LastModifiedDate, LastModifiedById, IsLocked, IsDeleted, Id, CreatedDate, CreatedById,Status__c From Fax_Batch_gne__c where Status__c = :MyStatus];
    return FB; 
}
webservice static boolean SetFaxBatchStatusById(String id,String mystatus) {
    List<Fax_Batch_gne__c> Fb = new List<Fax_Batch_gne__c>();
    //FaxStatus = mystatus;
    try {
    system.debug(mystatus );
    //fb = [select id from Fax_Batch_gne__c where Status__c = ''];
    fb = [Select Total_Records__c, Total_Physicians_gne__c, SystemModstamp, Product__c, OwnerId, Next_Anticipated_Batch_Run__c, Name, MayEdit, LastModifiedDate, LastModifiedById, IsLocked, IsDeleted, Id, CreatedDate, CreatedById,Status__c From Fax_Batch_gne__c where id = :id];
    fb[0].Status__c = mystatus;
    update fb;
    return true;
    }
    catch (Exception ex) {
    return false;   
    } 
}
webservice static List<Fax_Batch_Item_gne__c> GetFaxBatchItemsByFaxBatchname(String Batchname) {
    List<Fax_Batch_Item_gne__c> Fb = new List<Fax_Batch_Item_gne__c>();
    string fbid = [select id from  Fax_Batch_gne__c where name = :Batchname limit 1][0].id;
    fb = [Select f.User_Full_Name__c, f.SystemModstamp, f.SMN_Expiration_Date__c, Physician__c, f.Rx_Expiration_Date__c, f.Physician_Zip__c, f.Physician_Street_Line_2__c, f.Physician_Street_Line_1__c, f.Physician_State__c, f.Physician_Primary_Phone__c, f.Physician_Last_Name__c, f.Physician_First_Name__c, f.Physician_Fax_Number__c, f.Physician_DEA_Number__c, f.Physician_City__c, f.Patient_Last_Name__c, f.Patient_First_Name__c, f.Patient_DOB__c, f.Name, f.MayEdit, f.LastModifiedDate, f.LastModifiedById, f.IsLocked, f.IsDeleted, f.Id, f.Fax_Batch__c, f.CreatedDate, f.CreatedById, f.Case_Number_gne__c From Fax_Batch_Item_gne__c f where f.fax_batch__c = :fbid];
return fb;
}
webservice static List<Fax_Batch_Item_gne__c> GetFaxBatchItemsByFaxBatchID(String BatchID) {
    List<Fax_Batch_Item_gne__c> Fb = new List<Fax_Batch_Item_gne__c>();
    fb = [Select f.User_Full_Name__c, f.SystemModstamp, f.SMN_Expiration_Date__c,Physician__c, f.Rx_Expiration_Date__c, f.Physician_Zip__c, f.Physician_Street_Line_2__c, f.Physician_Street_Line_1__c, f.Physician_State__c, f.Physician_Primary_Phone__c, f.Physician_Last_Name__c, f.Physician_First_Name__c, f.Physician_Fax_Number__c, f.Physician_DEA_Number__c, f.Physician_City__c, f.Patient_Last_Name__c, f.Patient_First_Name__c, f.Patient_DOB__c, f.Name, f.MayEdit, f.LastModifiedDate, f.LastModifiedById, f.IsLocked, f.IsDeleted, f.Id, f.Fax_Batch__c, f.CreatedDate, f.CreatedById, f.Case_Number_gne__c From Fax_Batch_Item_gne__c f where f.fax_batch__c = :BatchID];
return fb;
}
 
webservice static String GetMergeFieldValue(String MergeFieldName,string arg) {
    try {
    return SCM_MergeFieldFactory.getValue(MergeFieldName, arg);
    }catch (exception ex)
    {
    	return '';
    	
    }
} 

webservice static List<Case> GetGATCFPatientCases(string[] PatientIDs) {
    try {
    set<Id> PatientIDSet = new set<Id>();
    for(string str : PatientIDs){
    	PatientIDSet.add(str);
    	
    }
    	
    
    List<Case> patient = [Select id,Patient_gne__c from Case where Patient_gne__c in :PatientIDs and RecordType.Name = ''];
    return patient;
    }catch (exception ex)
    {
    	return null;
    	
    }
} 
webservice static String GetMergeFieldValueCase(String MergeFieldName,string CaseID) {
    try {
    	
    Case cse = [select  
                    c.RecordType.Name , 
                    c.Patient_gne__r.Name, 
                    c.Patient_gne__r.Mid_Initial_gne__c, 
                    c.Patient_gne__r.pat_dob_gne__c,
                    c.Patient_gne__r.pat_first_name_gne__c,
                    c.Patient_gne__r.Patient_Id_gne__c,
                    c.Case_Manager__r.LastName,
                    c.Case_Manager__r.FirstName, 
                    c.Account.Name,
                    c.owner.Name, 
  
                 c.Access_Solutions_Online_Note_gne__c, c.AccountId, c.Account.Id, 
                 c.Address_gne__c, c.Address_gne__r.Id, c.After_Trigger_Flag_gne__c,
                  c.AGI_Qualified_gne__c, c.Alt_Cvg_Options_Discussed_Date_gne__c, 
                  c.Approval_Date_gne__c, c.AssetId, c.Asset.Id, c.C_R_Case__c, 
                  c.Case_Being_Worked_By_gne__c, c.Case_Count_gne__c, c.Case_Manager__c, 
                  c.Case_Manager__r.Id, c.case_referral_reason_gne__c, 
                  c.Case_Treating_Physician_gne__c, c.Case_Treating_Physician_gne__r.Id, 
                  c.CaseNumber, c.CCP_Approved_gne__c, c.City_gne__c, c.ClosedDate, 
                  c.Contacted_By_gne__c, c.Contacted_By_gne__r.Id, c.ContactId, 
                  c.Contact.Id, c.Contingent_Determination_gne__c, c.CoPay_Amount_gne__c, 
                  c.CoPay_Percent_gne__c, c.Counter_gne__c, c.Coverage_Denied_Calc_gne__c, 
                  c.Coverage_Established_Calc_gne__c, c.Coverage_Established_gne__c, 
                  c.Coverage_Options_gne__c, c.CreatedById, c.CreatedBy.Id, 
                  c.CreatedDate, c.Current_Tax_Return_gne__c, c.Cvg_gne__c, 
                  c.Date_Contacted_gne__c, c.Date_Discussed_gne__c, 
                  c.Date_Enrolled_gne__c, c.Date_gne__c, c.Date_Un_Enrolled_gne__c, 
                  c.Denial_Date_gne__c, c.Description, c.Diagnosis_gne__c, 
                  c.Distributor_Case_ID_gne__c, c.Documentation_gne__c, 
                  c.Eligibility_Determination_Date_gne__c, 
                  c.Eligibility_Document_Received_Date_gne__c, 
                  c.Eligibility_gne__c, c.Enroll_Comp_Original_Receipt_gne__c, 
                  c.Enroll_Date_Calc_gne__c, c.Enroll_SMN_Form_Signed_Date_gne__c, 
                   
                  c.Enrollment_Not_Complete_Reason_gne__c, c.Facility_gne__c, c.Facility_gne__r.Id, 
                  c.File_name_gne__c, c.Financial_Checklist_Mailed_Date_gne__c, 
                  c.Foundation_Specialist_gne__c, c.Foundation_Specialist_gne__r.Id, 
                  c.Foundation_Status_gne__c, c.Function_Performed_gne__c, 
                  c.GATCF_Status_gne__c, 
                  /*
					Genentech_Owner_gne__c deleted - lookup reused
                  c.Genentech_Owner_gne__c, c.Genentech_Owner_gne__r.Id,
                  */ 
                  c.HasCommentsUnreadByOwner, c.HasSelfServiceComments, 
                  c.ICD9_Code_2_gne__c, c.ICD9_Code_3_gne__c, c.Id, c.In_Network_gne__c, 
                  c.Income_gne__c, c.Income_Range_gne__c, c.Income_Source_gne__c, 
                  c.Infusions_Total_gne__c, c.Initial_Referral_gne__c, 
                  c.Injection_Training_Provided_By_gne__c, 
                  c.Injection_Training_Requested_gne__c, c.IsClosed, 
                  c.IsClosedOnCreate, c.IsDeleted, c.IsEscalated, 
                  c.IsLocked, c.IsSelfServiceClosed, c.IsVisibleInSelfService, 
                  c.LastModifiedById, c.LastModifiedBy.Id, c.LastModifiedDate, 
                  c.Legacy_Case_ID_gne__c, c.Mailbox_gne__c, c.Mailed_Date_gne__c, 
                  c.MayEdit, c.Medical_Eligibility_gne__c, 
                  c.Medical_Eligibility_Month_gne__c, c.Medical_Eligibility_Year_gne__c, 
                  c.Medical_History_gne__c, c.Medical_History_gne__r.Id, c.Medical_History_gne__r.Drug_gne__c,
                  c.New_Insurance_Coverage_Obtained_by_gne__c, 
                  c.New_Insurance_Coverage_Obtained_by_gne__r.Id, 
                  c.New_Insurance_Coverage_Obtained_Date_gne__c, 
                  c.New_Insurance_Coverage_Obtained_gne__c, 
                  c.New_Insurance_gne__c, c.OK_to_Contact_Patient_gne__c, 
                  c.Open_Enrollment_Date_gne__c, c.Origin, c.Other_Description_gne__c, 
                  c.Other_Injection_Training_Provided_By_gne__c, 
                  c.Out_of_Network_gne__c, c.OwnerId, c.PAN_gne__c, 
                  c.ParentId, c.Patient_gne__c, c.Practice_gne__c, c.Practice_gne__r.Id,  c.Priority, 
                  c.Product_gne__c, c.PT_MD_Notified_of_Resolution_gne__c, 
                  c.Reason, c.Received_Date_gne__c, c.RecordTypeId, 
                  c.Referred_By_Date_gne__c, c.Referred_By_Party_gne__c, 
                  c.Referred_By_Person_gne__c, c.Referred_By_Type_gne__c, 
                  c.Referred_to_Vendor_SP_gne__c, c.Reimbursement_Specialist_gne__c, 
                  c.Related_C_R_Case_gne__c, c.Release_gne__c, 
                  c.Roll_Up_Infuisons_To_gne__c, c.Sent_To_Vendor_gne__c, 
                  c.Services_Requested_gne__c, c.Special_Program_Name_gne__c, 
                  c.Special_Program_Note_gne__c, c.State_Treating_Physician_gne__c, 
                  c.Status, c.Sticker_Number_gne__c, c.Subject, c.SuppliedCompany, 
                  c.SuppliedEmail, c.SuppliedName, c.SuppliedPhone, c.SystemModstamp, 
                  c.Tax_Return_Year_gne__c, c.Therapy_Status_Id_gne__c, 
                  c.Time_at_Vendor_SP_gne__c, c.Time_to_Conversion__c, 
                  c.Type, c.Type_gne__c, c.Vendor_Case_ID_gne__c, c.Vendor_Name_gne__c, 
                  c.Verbal_Consent_gne__c, c.Verbal_Consent_Obtained_by_gne__c, 
                  c.Verbal_Consent_Obtained_On_gne__c, c.Verified_Income_gne__c, 
                  c.VIP_Note_gne__c, c.Web_Pat_ID_gne__c, c.Year_Screened_gne__c, 
                  c.Zip_gne__c,Referral_Address_Line_1_gne__c ,Referral_Address_Line_1_gne__r.Id ,
                  Referred_By_Party_gne__r.id
            from Case c
            Where c.Id=:CaseID];
    return SCM_MergeFieldFactory.getValue(MergeFieldName, cse);
    }catch (exception ex)
    {
    	return '';
    	
    }
}




webservice static string GetPatienIDFromCaseID(String ID) {
try {
return [Select Patient_gne__r.Patient_ID_gne__c from case where id = :ID limit 1][0].Patient_gne__r.Patient_ID_gne__c;
}
catch (exception ex){
return '';  
}
}


webservice static SCM_Merge_Document__c GetMergeDocumentByID(String DocumentID) {
    SCM_Merge_Document__c Fb = new SCM_Merge_Document__c();
    fb = [Select s.SystemModstamp, s.Product__c, s.OwnerId, s.Name, s.Metadata_Key__c, s.Merge_Class_Name__c, s.MayEdit, s.LastModifiedDate, s.LastModifiedById, s.Label__c, s.IsLocked, s.IsDeleted, s.Id, s.CreatedDate, s.CreatedById, s.Case_Type_Name__c From SCM_Merge_Document__c s where id = :DocumentID];
return fb;
}

webservice static string GetCaseIDFromCaseNumber(String CaseNum) {
    try {
        if (CaseNum.startsWith('H-')) {
            return [select id from Hotline_gne__c where Name = :CaseNum limit 1][0].id;
        }
        else {
            return [select id from case where CaseNumber = :CaseNum limit 1][0].id;
        }
    }
    catch (exception ex){
        return '';  
    }
}
webservice static Task AddTask(task tsk) {
    insert tsk; 
    return tsk;
}

webservice static void AddFaxMetrics(Fax_Reporting_Metrics_gne__c faxmet) {
    insert faxmet; 
}
webservice static string GetUserIDFromUserName(string UserName) {
    try {
         
        list<user> un = [select id from user where username = :UserName limit 1];
        if (un.size() > 0) {
        return un[0].id;    
        }
        else {
            return '';
        }
}
catch (exception ex){
return '';  
}
}
webservice static string GetUsersNameFromUserID(string UserID) {
    try {
         
        list<user> un = [select name from user where id = :UserID limit 1];
        if (un.size() > 0) {
        return un[0].name;    
        }
        else {
            return '';
        }
}
catch (exception ex){
return '';  
}
}

webservice static list<Address_vod__c> getAddressByAccountID(string accountid) {
//string accountid = c.Case_Treating_Physician_gne__r.id;
        list<Address_vod__c> con = null;
        con = [Select a.Zip_vod__c, a.Zip_4_vod__c, a.Wait_Time_gne__c, a.Wait_List_gne__c, a.UNKNOWN_gne__c, a.Toll_Free_gne__c, a.Third_Party_gne__c, a.Third_Party_Index_gne__c, a.Third_Party_Id_gne__c, a.TLX_Address_Id_gen__c, a.SystemModstamp, a.Status_gne__c, a.State_vod__c, a.Staff_notes_vod__c, a.Special_instructions_gne__c, a.Source_vod__c, a.Shipping_vod__c, a.Service_Quality_Survey_Offered_Date_gne__c, a.Satellite_gne__c, a.Sample_Status_vod__c, a.SOLD_TO_gne__c, a.SAP_ID_gne__c, a.RecordTypeId, a.Proactive_BI_Opt_In_gne__c, a.Primary_vod__c, a.Practice_Type_gne__c, a.Practice_Size_gne__c, a.Phone_vod__c, a.Phone_2_vod__c, a.Phone_2_Ext_gne__c, a.Phone_1_Ext_gne__c, a.Operating_Hours_Start_gne__c, a.Operating_Hours_End_gne__c, a.Office_gne__c, a.Office_Notes_vod__c, a.Offered_To_gne__c, a.OK_to_Contact_Patient_gne__c, a.Name, a.Mobile__c, a.MayEdit, a.Map_vod__c, a.Mailing_vod__c, a.MDM_GLID_gne__c, a.MDM_Address_ID_gne__c, a.Longitude_vod__c, a.Location_Specific_Preferences_gne__c, a.License_vod__c, a.License_Valid_To_Sample_vod__c, a.License_Status_vod__c, a.License_Expiration_Date_vod__c, a.Latitude_vod__c, a.LastModifiedDate, a.LastModifiedById, a.IsLocked, a.IsDeleted, a.Injection_Training_gne__c, a.Infusion_Services_gne__c, a.Infusion_Hours_Start_gne__c, a.Infusion_Hours_End_gne__c, a.Infusion_Chairs_gne__c, a.Include_in_Territory_Assignment_vod__c, a.Inactive_vod__c, a.Inactivate_User_gne__c, a.Inactivate_Reason_gne__c, a.Inactivate_Count_gne__c, a.Id, a.Hospital_gne__c, a.Home_vod__c, a.Genentech_Product_Experience_gne__c, a.Gatekeeper_gne__c, a.GOLD_RECORD_gne__c, a.Fax_vod__c, a.Fax_2_vod__c, a.FORWARD_TO_gne__c, a.External_ID_vod__c, a.Email_gne__c,  a.Date_Last_Offered_gne__c, a.Date_Inactive_gne__c, a.Data_Source_gne__c, a.DEA_vod__c, a.DEA_gne__c, a.DEA_License_Address_vod__c, a.DEA_Expiration_Date_vod__c, a.CreatedDate, a.CreatedById, a.Country_gen__c, a.Comment_vod__c, a.Clinic_gne__c, a.City_vod__c, a.Choose_to_Take_Survey_gne__c, a.Buy_and_Bill_gne__c, a.Business_vod__c, a.Billing_vod__c, a.Best_Times_vod__c, a.BI_Interval_gne__c, a.Appt_Required_vod__c, a.Appointment_Type_gne__c,   a.Alternate_Fax_gne__c, a.Address_line_2_vod__c,  a.Address_Type_gne__c, a.Address_Line_4_gne__c, a.Address_Line_3_gne__c, a.Address_1_gne__c,  a.Account_vod__c, a.Accepting_New_Patients_gne__c, a.AMS_gold_record_gne__c, a.AIC_Services_gne__c, a.AIC_Instructions_gne__c From Address_vod__c a where primary_vod__c = true and Account_vod__c = :accountid order by Name limit 1];
        if (con.size() == 0) {
            con = [Select a.Zip_vod__c, a.Zip_4_vod__c, a.Wait_Time_gne__c, a.Wait_List_gne__c, a.UNKNOWN_gne__c, a.Toll_Free_gne__c, a.Third_Party_gne__c, a.Third_Party_Index_gne__c, a.Third_Party_Id_gne__c, a.TLX_Address_Id_gen__c, a.SystemModstamp, a.Status_gne__c, a.State_vod__c, a.Staff_notes_vod__c, a.Special_instructions_gne__c, a.Source_vod__c, a.Shipping_vod__c, a.Service_Quality_Survey_Offered_Date_gne__c, a.Satellite_gne__c, a.Sample_Status_vod__c, a.SOLD_TO_gne__c, a.SAP_ID_gne__c, a.RecordTypeId, a.Proactive_BI_Opt_In_gne__c, a.Primary_vod__c, a.Practice_Type_gne__c, a.Practice_Size_gne__c, a.Phone_vod__c, a.Phone_2_vod__c, a.Phone_2_Ext_gne__c, a.Phone_1_Ext_gne__c, a.Operating_Hours_Start_gne__c, a.Operating_Hours_End_gne__c, a.Office_gne__c, a.Office_Notes_vod__c, a.Offered_To_gne__c, a.OK_to_Contact_Patient_gne__c, a.Name, a.Mobile__c, a.MayEdit, a.Map_vod__c, a.Mailing_vod__c, a.MDM_GLID_gne__c, a.MDM_Address_ID_gne__c, a.Longitude_vod__c, a.Location_Specific_Preferences_gne__c, a.License_vod__c, a.License_Valid_To_Sample_vod__c, a.License_Status_vod__c, a.License_Expiration_Date_vod__c, a.Latitude_vod__c, a.LastModifiedDate, a.LastModifiedById, a.IsLocked, a.IsDeleted, a.Injection_Training_gne__c, a.Infusion_Services_gne__c, a.Infusion_Hours_Start_gne__c, a.Infusion_Hours_End_gne__c, a.Infusion_Chairs_gne__c, a.Include_in_Territory_Assignment_vod__c, a.Inactive_vod__c, a.Inactivate_User_gne__c, a.Inactivate_Reason_gne__c, a.Inactivate_Count_gne__c, a.Id, a.Hospital_gne__c, a.Home_vod__c, a.Genentech_Product_Experience_gne__c, a.Gatekeeper_gne__c, a.GOLD_RECORD_gne__c, a.Fax_vod__c, a.Fax_2_vod__c, a.FORWARD_TO_gne__c, a.External_ID_vod__c, a.Email_gne__c,  a.Date_Last_Offered_gne__c, a.Date_Inactive_gne__c, a.Data_Source_gne__c, a.DEA_vod__c, a.DEA_gne__c, a.DEA_License_Address_vod__c, a.DEA_Expiration_Date_vod__c, a.CreatedDate, a.CreatedById, a.Country_gen__c, a.Comment_vod__c, a.Clinic_gne__c, a.City_vod__c, a.Choose_to_Take_Survey_gne__c, a.Buy_and_Bill_gne__c, a.Business_vod__c, a.Billing_vod__c, a.Best_Times_vod__c, a.BI_Interval_gne__c, a.Appt_Required_vod__c, a.Appointment_Type_gne__c,   a.Alternate_Fax_gne__c, a.Address_line_2_vod__c,  a.Address_Type_gne__c, a.Address_Line_4_gne__c, a.Address_Line_3_gne__c, a.Address_1_gne__c,  a.Account_vod__c, a.Accepting_New_Patients_gne__c, a.AMS_gold_record_gne__c, a.AIC_Services_gne__c, a.AIC_Instructions_gne__c From Address_vod__c a where Account_vod__c = :accountid order by Name limit 1];
//        con = [Select a.Zip_vod__c, a.Zip_4_vod__c, a.Wait_Time_gne__c, a.Wait_List_gne__c, a.UNKNOWN_gne__c, a.Toll_Free_gne__c, a.Third_Party_gne__c, a.Third_Party_Index_gne__c, a.Third_Party_Id_gne__c, a.TLX_Address_Id_gen__c, a.SystemModstamp, a.Status_gne__c, a.State_vod__c, a.Staff_notes_vod__c, a.Special_instructions_gne__c, a.Source_vod__c, a.Shipping_vod__c, a.Service_Quality_Survey_Offered_Date_gne__c, a.Satellite_gne__c, a.Sample_Status_vod__c, a.SOLD_TO_gne__c, a.SAP_ID_gne__c, a.RecordTypeId, a.Proactive_BI_Opt_In_gne__c, a.Primary_vod__c, a.Practice_Type_gne__c, a.Practice_Size_gne__c, a.Phone_vod__c, a.Phone_2_vod__c, a.Phone_2_Ext_gne__c, a.Phone_1_Ext_gne__c, a.Operating_Hours_Start_gne__c, a.Operating_Hours_End_gne__c, a.Office_gne__c, a.Office_Notes_vod__c, a.Offered_To_gne__c, a.OK_to_Contact_Patient_gne__c, a.Name, a.Mobile__c, a.MayEdit, a.Map_vod__c, a.Mailing_vod__c, a.MDM_GLID_gne__c, a.MDM_Address_ID_gne__c, a.Longitude_vod__c, a.Location_Specific_Preferences_gne__c, a.License_vod__c, a.License_Valid_To_Sample_vod__c, a.License_Status_vod__c, a.License_Expiration_Date_vod__c, a.Latitude_vod__c, a.LastModifiedDate, a.LastModifiedById, a.IsLocked, a.IsDeleted, a.Injection_Training_gne__c, a.Infusion_Services_gne__c, a.Infusion_Hours_Start_gne__c, a.Infusion_Hours_End_gne__c, a.Infusion_Chairs_gne__c, a.Include_in_Territory_Assignment_vod__c, a.Inactive_vod__c, a.Inactivate_User_gne__c, a.Inactivate_Reason_gne__c, a.Inactivate_Count_gne__c, a.Id, a.Hospital_gne__c, a.Home_vod__c, a.Genentech_Product_Experience_gne__c, a.Gatekeeper_gne__c, a.GOLD_RECORD_gne__c, a.Fax_vod__c, a.Fax_2_vod__c, a.FORWARD_TO_gne__c, a.External_ID_vod__c, a.Email_gne__c,  a.Date_Last_Offered_gne__c, a.Date_Inactive_gne__c, a.Data_Source_gne__c, a.DEA_vod__c, a.DEA_gne__c, a.DEA_License_Address_vod__c, a.DEA_Expiration_Date_vod__c, a.CreatedDate, a.CreatedById, a.Country_gen__c, a.Comment_vod__c, a.Clinic_gne__c, a.City_vod__c, a.Choose_to_Take_Survey_gne__c, a.Buy_and_Bill_gne__c, a.Business_vod__c, a.Billing_vod__c, a.Best_Times_vod__c, a.BI_Interval_gne__c, a.Appt_Required_vod__c, a.Appointment_Type_gne__c,   a.Alternate_Fax_gne__c, a.Address_line_2_vod__c, , a.Address_Type_gne__c, a.Address_Line_4_gne__c, a.Address_Line_3_gne__c, a.Address_1_gne__c, a.Account_vod__c, a.Accepting_New_Patients_gne__c, a.AMS_gold_record_gne__c, a.AIC_Services_gne__c, a.AIC_Instructions_gne__c From Address_vod__c a where Account_vod__c = :accountid order by Name limit 1];

        }
      //if (con.size() == 0) {
        return con;
       
} 
webservice static string GetPerscriptionType(string caseid) {
 
List<case> cse = [Select Medical_History_gne__r.Prescription_Type_gne__c From case where id=:caseid];

return cse[0].Medical_History_gne__r.Prescription_Type_gne__c; 

               
}

webservice static String GetRecertificationCaseXML(String Caseid,date batchdate) {
     
    
     SCM_Merge_Document__c mdnme = [Select Name, Document_Type__c, Product__c  from SCM_Merge_Document__c where Merge_Class_Name__c=:'SCM_MD_Recertification_Partial' Limit 1];
    
     SCM_MD_Recertification_Partial md = new SCM_MD_Recertification_Partial(Caseid,mdnme.id,batchdate);
     //get the correct creation date in case this item has been requeued
     md.mergefields.clear();
     md.mergerepeaters.clear();
     md.redoMergefields();
     
     return md.getXMLString();
     
     
}

public static testMethod void testit(){
        system.debug('starttest');
        List<Fax_Batch_gne__c> Fb = new List<Fax_Batch_gne__c>();
        //fb = SCM_Batch_Fax_Webservice.GetFaxBatchesByStatus('Pending');
    //SCM_Batch_Fax_Webservice.GetFaxBatchItemsByFaxBatchID(fb[0].id);
    try {
    	SCM_Batch_Fax_Webservice.getAddressByAccountID('a1nS0000000001SIAQ');
    }catch (exception ex) {}
    try {
    SCM_Batch_Fax_Webservice.GetMergeDocumentByID('a1nS0000000001SIAQ');
    }catch (exception ex) {}
    try {
    SCM_Batch_Fax_Webservice.AddTask(new Task());
    }catch (exception ex) {}
    try {
    SCM_Batch_Fax_Webservice.GetCaseIDFromCaseNumber('1234');
    }catch (exception ex) {}
    try {
    SCM_Batch_Fax_Webservice.GetFaxBatchesByStatus('pending');
    }catch (exception ex) {}
    try {
    SCM_Batch_Fax_Webservice.GetFaxBatchItemsByFaxBatchID('a1nS0000000001SIAQ');
    }catch (exception ex) {}
    try {
    SCM_Batch_Fax_Webservice.SetFaxBatchStatusById('a1nS0000000001SIAQ','test');
    }catch (exception ex) {}
    try { 
     SCM_Batch_Fax_Webservice.GetFaxBatchItemsByFaxBatchname('');
    }catch (exception ex) {}   
     try { 
     SCM_Batch_Fax_Webservice.GetMergeDocumentByID('a1nS0000000001SIAQ');
    }catch (exception ex) {}  
     try { 
     SCM_Batch_Fax_Webservice.GetPatienIDFromCaseID('a1nS0000000001SIAQ');
    }catch (exception ex) {}  
    try { 
     SCM_Batch_Fax_Webservice.GetPerscriptionType('a1nS0000000001SIAQ');
    }catch (exception ex) {}
     try { 
     SCM_Batch_Fax_Webservice.GetUserIDFromUserName('a1nS0000000001SIAQ');
    }catch (exception ex) {}    
    }
}