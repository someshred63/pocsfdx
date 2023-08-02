public class SCM_MF_Case extends SCM_MergeField{

    public static Case documentCase; 
    public SCM_MF_Case(String caseId)
    {
         this.className = 'SCM_MF_Case'; 
         displayCheck = false;
         displayTextBox = false;
         displayLabel = true;
         if(documentCase==null)
         {
           documentCase = [select  
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
                
                 
                  c.Eligibility_gne__c, c.Enroll_Comp_Original_Receipt_gne__c, 
                  c.Enroll_Date_Calc_gne__c, c.Enroll_SMN_Form_Signed_Date_gne__c, 
                  
                  //c.Enrollment_Form_Rec_gne__c, 
                  c.Enrollment_Not_Complete_Reason_gne__c, c.Facility_gne__c, 
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
                  c.Medical_History_gne__c, c.Medical_History_gne__r.Id, 
                  c.New_Insurance_Coverage_Obtained_by_gne__c, 
                  c.New_Insurance_Coverage_Obtained_by_gne__r.Id, 
                  c.New_Insurance_Coverage_Obtained_Date_gne__c, 
                  c.New_Insurance_Coverage_Obtained_gne__c, 
                  c.New_Insurance_gne__c, c.OK_to_Contact_Patient_gne__c, 
                  c.Open_Enrollment_Date_gne__c, c.Origin, c.Other_Description_gne__c, 
                  c.Other_Injection_Training_Provided_By_gne__c, 
                  c.Out_of_Network_gne__c, c.OwnerId, c.PAN_gne__c, 
                  c.ParentId, c.Patient_gne__c, c.Practice_gne__c, c.Priority, 
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
                  //c.Time_at_Vendor_SP_gne__c, c.Time_to_Conversion__c, 
                  c.Type, c.Type_gne__c, c.Vendor_Case_ID_gne__c, c.Vendor_Name_gne__c, 
                  c.Verbal_Consent_gne__c, c.Verbal_Consent_Obtained_by_gne__c, 
                  c.Verbal_Consent_Obtained_On_gne__c, c.Verified_Income_gne__c, 
                  c.VIP_Note_gne__c, c.Web_Pat_ID_gne__c, c.Year_Screened_gne__c, 
                  c.Zip_gne__c 
            from Case c
            Where c.Id=:caseId];
          }
          
    }
}