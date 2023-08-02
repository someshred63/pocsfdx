// Created by HSINGH
// Triage / Vendor requirement
// Last updated on : 06/24/2009
// 06/23/2009 Offshore-209: Validate Treating Location Adress, Phone, Fax
/* 06/24/2009 Alex Chupkin / Nadine LeBlanc: McKesson Adjustments
   1) Remove obsolete validation rules:
   "...record must be either "Major Medical" or "Retail/Prescription"..."
   "...record must not have a Rank of either "Other" or "Inactive"...."
   "...must have a Subscriber Name and either a Subscriber # or Policy #..."
   2) Remove incorrect PAN Form validation:
   "...must have a Patient with a valid First Name, Last Name, DOB ,Gender, PAN Form 1 and PAN Form 2."
   remove condition: casechk.Patient_gne__r.PAN_gne__c == null || casechk.Patient_gne__r.PAN_Form_2_gne__c == null
   3) Fix valid PAN Form validation:  PAN FORM 1, Nutropin OR PAN FORM 2 Nutropin is available

*/

global class GNE_CM_Case_Vendor_Validations_Check
{
    public List<String> validate_External_Mckesson(case cs)
    {
        Integer patientPrimaryIds = 0;
        Id patientId;
        Set<ID> patientInvalidAddressIds = new Set<ID>();
        Integer invalidinsbiflag=0;
        Integer invalidbenflag=0;
        Integer insuranceflag=0;
        List<String> result = new List<String>();
        Case casechk = new Case();
        Integer initialFamilyCallTasks = 0; 
        List<Task> openactivitylist=new List<Task>();
                                                                
        try
        {                                                       
            casechk = [select (Select Id, BI_BI_Status_gne__c, Case_BI_gne__c, Benefit_Type_gne__c, BI_Insurance_gne__r.Rank_gne__c from Benefit_Investigation_gne__r), 
                           Id, (select Case_Insurance_gne__c, Subscriber_Name_gne__c, Subscriber_Num_gne__c, Policy_Number_gne__c FROM Insurance__r), 
                           product_gne__c, CaseNumber, Patient_gne__c, Case_Treating_Physician_gne__c, Case_Treating_Physician_gne__r.FirstName, Case_Treating_Physician_gne__r.LastName,
                           Address_gne__r.Phone_vod__c, Address_gne__r.Fax_vod__c, Address_gne__r.Name, Address_gne__r.City_vod__c, Address_gne__r.State_vod__c, Address_gne__r.Zip_vod__c, 
                           Patient_gne__r.pat_dob_gne__c, Patient_gne__r.pat_gender_gne__c, Patient_gne__r.PAN_gne__c, Patient_gne__r.PAN_Form_2_gne__c,Patient_gne__r.PAN_Form_1_Product_gne__c,
                           Patient_gne__r.PAN_Form_2_Product_gne__c, Medical_History_gne__c, Medical_History_gne__r.ICD9_Code_1_gne__c, Medical_History_gne__r.Therapy_Type_gne__c,
                           Medical_History_gne__r.Drug_gne__c, status from Case where Id = :cs.Id];
             
             //Added new check for case closed on 5/5/2009
             if(casechk.Status.startsWith('Closed'))
             result.add('Case cannot be prepared for vendor since it has been Closed.');             
                  
            //Incorporated Validation Rule Reqd_BR_Vendor_Data_03_Patient      
            if(casechk.Patient_gne__c != null)
                patientId = casechk.Patient_gne__c; 
            else
                result.add('Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Patient with a valid First Name, Last Name.');
            
            
            //Modified as per Offshore-209
           //Requires that a Prescriber must exist and have a Phone for Nutropin Cases being worked on by “EXTERNAL - MCKESSON” in either a Benefits Investigation or Appeals Follow-up function per Business Rule BR-Vendor-Data -03.          
            if(casechk.Case_Treating_Physician_gne__c == null ||casechk.Case_Treating_Physician_gne__r.FirstName == null || casechk.Case_Treating_Physician_gne__r.LastName == null) 
                result.add('Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Prescriber with a valid First Name and Last Name.');
                          
            if(casechk.Address_gne__c == null)
                result.add('Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Treating Location.'); 
            else if(casechk.Address_gne__r.Name ==null || casechk.Address_gne__r.City_vod__c ==null || casechk.Address_gne__r.State_vod__c ==null || casechk.Address_gne__r.Zip_vod__c ==null ||casechk.Address_gne__r.Phone_vod__c ==null || casechk.Address_gne__r.Fax_vod__c == null) 
                result.add('Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have the following Treating Location address fields: "Street Address", "City", "State", "Zip", "Phone 1" and "Fax" values. These fields are located in the Address Detail.');
             
                            
            //Requires that a Patient must have a DOB for Nutropin Cases being worked on by something other than “GENENTECH” and in either a Benefits Investigation or Appeals Follow-up function per Business Rule BR-Vendor-Data -03.
            if(casechk.Patient_gne__c != null && (casechk.Patient_gne__r.pat_dob_gne__c  == null || casechk.Patient_gne__r.pat_gender_gne__c == null)) // -- Removed as per 6/24/09 requirement: || casechk.Patient_gne__r.PAN_gne__c == null || casechk.Patient_gne__r.PAN_Form_2_gne__c == null))
                result.add('Nutropin Cases being worked by EXTERNAL - MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Patient with a valid First Name, Last Name, DOB ,Gender'); //-- Removed as per 6/24/09 requirement: , PAN Form 1 and PAN Form 2.');
            
            // Requires the assoicated MH to have a Drug, ICD9 Code1 and Therapy type
            //Modified as per Offshore-260
            if(casechk.Medical_History_gne__r.ICD9_Code_1_gne__c == null || casechk.Medical_History_gne__r.Therapy_Type_gne__c == null || casechk.Medical_History_gne__r.Drug_gne__c == null || casechk.Medical_History_gne__r.Drug_gne__c == 'Not Furnished')
                result.add('Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Medical History with a valid ICD9, Therapy Type and Drug.');               
                       
             //new validation added on 4/8/09 to check PAN and PAN Product on Patient
             //if(casechk.Patient_gne__c != null && (casechk.Patient_gne__r.PAN_gne__c !=null || casechk.Patient_gne__r.PAN_Form_2_gne__c !=null) && !((casechk.Patient_gne__r.PAN_gne__c != 'No' && casechk.Patient_gne__r.PAN_Form_1_Product_gne__c == casechk.product_gne__c) || (casechk.Patient_gne__r.PAN_Form_2_gne__c != 'No' && casechk.Patient_gne__r.PAN_Form_2_Product_gne__c == casechk.product_gne__c)))
             // validation corrected on 6/24/09 to check PAN 1 or PAN 2 with Product on Patient
             if (casechk.Patient_gne__c != null && ((casechk.Patient_gne__r.PAN_gne__c == null && casechk.Patient_gne__r.PAN_Form_2_gne__c == null) || (casechk.Patient_gne__r.PAN_gne__c == null && (casechk.Patient_gne__r.PAN_Form_2_gne__c != 'Yes' || casechk.Patient_gne__r.PAN_Form_2_Product_gne__c != casechk.product_gne__c)) || (casechk.Patient_gne__r.PAN_Form_2_gne__c == null && (casechk.Patient_gne__r.PAN_gne__c != 'Yes' || casechk.Patient_gne__r.PAN_Form_1_Product_gne__c != casechk.product_gne__c)) || ((casechk.Patient_gne__r.PAN_gne__c != 'Yes' || casechk.Patient_gne__r.PAN_Form_1_Product_gne__c != casechk.product_gne__c) && (casechk.Patient_gne__r.PAN_Form_2_gne__c != 'Yes' || casechk.Patient_gne__r.PAN_Form_2_Product_gne__c != casechk.product_gne__c))))
                result.add('Nutropin Cases being worked by EXTERNAL - MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Patient with either PAN Form 1 or PAN Form 2 with PAN Form Product as Nutropin.');
                       
            /*  -- -- Removed as per 6/24/09 requirement:       
            for(Benefit_Investigation_gne__c bi: casechk.Benefit_Investigation_gne__r)
            {
                if(bi.Benefit_Type_gne__c != 'Major Medical' && bi.Benefit_Type_gne__c != 'Retail/Prescription')
                {
                    invalidbenflag=1;
                } // end of if Bi
                            
                if (bi.BI_Insurance_gne__r.Rank_gne__c == 'Other' || bi.BI_Insurance_gne__r.Rank_gne__c == 'Inactive')
                {
                    invalidinsbiflag=1;
                } // end of if Insurance
             } // end of for
             //Incorporated GNE_CM_validate_BR_Vendor_Data_03_Case_gne, Get invalid Insurances             
             for(Insurance_gne__c ins: casechk.Insurance__r)
             {      
                if((ins.Subscriber_Name_gne__c == '' || ins.Subscriber_Name_gne__c == null) || ((ins.Subscriber_Num_gne__c == '' || ins.Subscriber_Num_gne__c ==null) && (ins.Policy_Number_gne__c == '' || ins.Policy_Number_gne__c ==null)))
                    insuranceflag=1;                                  
             }   
                    
             if(invalidbenflag==1)
             {
                result.add('For Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function, the Benefit Type of each Benefit Investigation record must be either "Major Medical" or "Retail/Prescription". Please correct the Benefit Investigation records.');                                       
             }   
             // Flag invalid Insurances' Benefit Investigations' Cases with an error
             if(invalidinsbiflag==1)
             {
                result.add('For Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function, the Insurance record of each Benefit Investigation record must not have a Rank of either "Other" or "Inactive". Please correct the Benefit Investigation Insurance records.');
             }
                                               
             if(insuranceflag==1)
             {
                 result.add('For Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function, each Insurance record must have a Subscriber Name and either a Subscriber # or Policy #. Please correct the Insurance records.');                                                                       
             }
            */
                     
         /*--Patient Address record validation and the Activity record validation for Business Rule BR-Vendor_Data-04--*/  
        // Loop through the Patient Addresses checking for Primary as well as required fields
       
            for (Patient_Address_gne__c pa : [SELECT id, Primary_Address_gne__c, Address_Line_1_gne__c, City_gne__c, State_gne__c, Zip_gne__c, Patient_gne__c FROM Patient_Address_gne__c WHERE Patient_gne__c = :patientId])
            {
                // Set PatientsPrimaryID flag for Primary Address
                if (pa.Primary_Address_gne__c == 'Yes')
                    patientPrimaryIds = 1;        
                // Add Patients IDs that have an invalid Address
                if (pa.Address_Line_1_gne__c == null || pa.City_gne__c == null || pa.State_gne__c == null || pa.Zip_gne__c == null)
                    patientInvalidAddressIds.add(pa.Patient_gne__c);
            }                      
        //Part of BR Vendor Data 04, Flag Cases having Errors
            if (patientPrimaryIds == 0)
                result.add('Patients for Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Primary Address. Please enter a Primary Address for the Patient.');
            
            if (patientInvalidAddressIds.contains(casechk.Patient_gne__c))
                result.add('Patients\' Addresses for Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have an Address 1, City, State and Zip.');
        
            //Get a list of Task associated with the Case
            openactivitylist=[Select WhatId, case_id_gne__c, Subject from Task where WhatId = :cs.Id];
         
            //BR_Vendor_Data_04_Case, Check whether or not Case has associated Prepare and Send Case to vendor Task
    
            for (Task tasks : openactivitylist)
            {
                if(tasks.Subject == 'Prepare and send case to vendor')
                initialFamilyCallTasks = 1;    
            } 
                                    
            if (initialFamilyCallTasks == 0)
               result.add('Nutropin Cases being worked by EXTERNAL – MCKESSON in either a Benefits Investigation or Appeals Follow-up function must have a Prepare and send case to vendor Task. Please create a Prepare and send case to vendor Task.');
                
        } // End of try
        catch(exception e)
        {
            result.add('ERROR IN VALIDATION CLASS::' +  e.getMessage());
        } // End of catch
        finally
        {
            openactivitylist.clear();
            patientInvalidAddressIds.clear();
            
        } // End of finally 
        return result; 
    }// end of function validate_External_Mckesson
} // End of Class