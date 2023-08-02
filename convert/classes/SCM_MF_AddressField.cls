// Created By Reji Joseph

public virtual class SCM_MF_AddressField extends SCM_MergeField{
    public Address_vod__c address;
    private static List<Address_vod__c> addressList;
    public SCM_MF_AddressField(String addressId)
    {
        checked = false;
        displayCheck= false;
        displayTextBox=true;
        displayLabel = false;
        className = 'SCM_MF_AddressField';
        key = 'AddressField'; 
        if(addressList==null)
        {
            addressList= [Select a.Zip_vod__c, a.Zip_4_vod__c, a.Wait_Time_gne__c, a.Wait_List_gne__c, a.UNKNOWN_gne__c, a.Toll_Free_gne__c, a.Third_Party_gne__c, a.Third_Party_Index_gne__c, a.Third_Party_Id_gne__c, a.TLX_Address_Id_gen__c, a.SystemModstamp, a.Status_gne__c, a.State_vod__c, a.Staff_notes_vod__c, a.Special_instructions_gne__c, a.Source_vod__c, a.Shipping_vod__c, a.Service_Quality_Survey_Offered_Date_gne__c, a.Satellite_gne__c, a.Sample_Status_vod__c, a.SOLD_TO_gne__c, a.SAP_ID_gne__c, a.RecordTypeId, a.Proactive_BI_Opt_In_gne__c, a.Primary_vod__c, a.Practice_Type_gne__c, a.Practice_Size_gne__c, a.Phone_vod__c, a.Phone_2_vod__c, a.Phone_2_Ext_gne__c, a.Phone_1_Ext_gne__c, a.Operating_Hours_Start_gne__c, a.Operating_Hours_End_gne__c, a.Office_gne__c, a.Office_Notes_vod__c, a.Offered_To_gne__c,  a.Name, a.Mobile__c, a.MayEdit, a.Map_vod__c, a.Mailing_vod__c, a.MDM_GLID_gne__c, a.MDM_Address_ID_gne__c, a.Longitude_vod__c, a.Location_Specific_Preferences_gne__c, a.License_vod__c, a.License_Valid_To_Sample_vod__c, a.License_Status_vod__c, a.License_Expiration_Date_vod__c, a.Latitude_vod__c, a.LastModifiedDate, a.LastModifiedById, a.IsLocked, a.IsDeleted, a.Injection_Training_gne__c, a.Infusion_Services_gne__c, a.Infusion_Hours_Start_gne__c, a.Infusion_Hours_End_gne__c, a.Infusion_Chairs_gne__c, a.Include_in_Territory_Assignment_vod__c, a.Inactive_vod__c, a.Inactivate_User_gne__c, a.Inactivate_Reason_gne__c, a.Inactivate_Count_gne__c, a.Id, a.Hospital_gne__c, a.Home_vod__c, a.Genentech_Product_Experience_gne__c, a.Gatekeeper_gne__c, a.GOLD_RECORD_gne__c, a.Fax_vod__c, a.Fax_2_vod__c, a.FORWARD_TO_gne__c, a.External_ID_vod__c, a.Email_gne__c,  a.Date_Last_Offered_gne__c, a.Date_Inactive_gne__c, a.Data_Source_gne__c, a.DEA_vod__c, a.DEA_gne__c, a.DEA_License_Address_vod__c, a.DEA_Expiration_Date_vod__c, a.CreatedDate, a.CreatedById, a.Country_gen__c, a.Comment_vod__c, a.Clinic_gne__c, a.City_vod__c, a.Choose_to_Take_Survey_gne__c, a.Buy_and_Bill_gne__c, a.Business_vod__c, a.Billing_vod__c, a.Best_Times_vod__c, a.BI_Interval_gne__c, a.Appt_Required_vod__c, a.Appointment_Type_gne__c,  a.Address_line_2_vod__c, a.Address_Type_gne__c, a.Address_Line_4_gne__c, a.Address_Line_3_gne__c, a.Address_1_gne__c, a.Account_vod__c, a.Accepting_New_Patients_gne__c, a.AMS_gold_record_gne__c, a.AIC_Services_gne__c, a.AIC_Instructions_gne__c from Address_vod__c a
                  WHERE a.Id=:addressId
                 ];
        }
        
        if(addressList.size()>0)
            address=addressList[0];
        else
            address=null;
    }
}