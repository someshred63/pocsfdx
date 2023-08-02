// Added by Reji Joseph

//Join Case.Patient_gne__c to Patient.PatientID_gne__c and 
//	join Patient.PatientID_gne__c to Patient Address.Patient_gne__c to 
//	return a list of Patient Address objects.
	
//	If count of Patient Address = 0, then merge ""
//	If count of Patient Address = 1, 
//		then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
		
//	If count of Patient Address > 1, 
//		then return a list of Patient Address objects where Patient Address.Primary_address_gne__c = Yes
//   		If count of Patient Address = 0, then select the last updated Patient Address
//	 		If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
//   		If count of Patient Address > 1, 
//   			the return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Mailing address
   			
//      		If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
//      		If count of Patient Address > 1, 
//      			then select by Last Updated date, the Patient Address from which Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
//    			If count of Patient Address = 0, 
//	      			then return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Home Address
//         		If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
//         		If count of Patient Address > 1, then select by Last Updated date, the Patient Address from which Patient 
//					Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
//         		If count of Patient Address = 0, then select the last updated Patient Address

public virtual class SCM_MF_PatientAddessCollectionSMN_Luc extends SCM_MergeField {
    
    protected Patient_Address_gne__c PatientAddress;

    protected Patient_Address_gne__c patientAddressWithoutFilter;
    
    public SCM_MF_PatientAddessCollectionSMN_Luc (String PatientId)
    {
        checked=false;
        displayCheck=false;
        displayTextBox=false;
        displayLabel=false;
        Key='Patient Address Collection SMN Lucentis'; 
        className='SCM_MF_PatientAddessCollectionSMN_Luc';
        
        List<Patient_Address_gne__c> PatientAddressList = [Select p.Id, p.Patient_gne__c,
            p.Address_Line_1_gne__c, p.Address_Line_2_gne__c,
            p.City_gne__c, p.State_gne__c, p.Zip_gne__c, 
            p.Phone_gne__c, 
            p.Type_gne__c,  p.Primary_Address_gne__c, 
            p.Phone_Type_gne__c,  p.Name, p.LastModifiedDate
            From Patient_Address_gne__c p 
            where p.Patient_gne__c =: PatientId
            order by p.LastModifiedDate desc 
            limit 100];
            
            if (PatientAddressList.size() == 0)
                {
                    PatientAddress = null; 
                }
            else if (PatientAddressList.size() == 1)
                {
                    patientAddressWithoutFilter = PatientAddressList[0];
                    // Passing the stored value
                    PatientAddress = patientAddressWithoutFilter; 
                }
            else if (PatientAddressList.size() > 1)
                {
                    PatientAddressList = [Select p.Id, p.Patient_gne__c,
                        p.Address_Line_1_gne__c, p.Address_Line_2_gne__c,
                        p.City_gne__c, p.State_gne__c, p.Zip_gne__c, 
                        p.Phone_gne__c, 
                        p.Type_gne__c,  p.Primary_Address_gne__c, 
                        p.Phone_Type_gne__c,  p.Name, p.LastModifiedDate
                        From Patient_Address_gne__c p 
                        where p.Patient_gne__c =: PatientId and p.Primary_Address_gne__c = 'Yes'
                        order by p.LastModifiedDate desc 
                        limit 100];
                        
                    if (PatientAddressList.size() == 0)
                    {
                        PatientAddress = patientAddressWithoutFilter; 
                    }
                    else if (PatientAddressList.size() == 1)
                    {
                        PatientAddress = PatientAddressList[0];
                    }
                    else if (PatientAddressList.size() > 1)
                    {
                        PatientAddressList = [Select p.Id, p.Patient_gne__c,
                           p.Address_Line_1_gne__c, p.Address_Line_2_gne__c,
                            p.City_gne__c, p.State_gne__c, p.Zip_gne__c, 
                            p.Phone_gne__c, 
                            p.Type_gne__c,  p.Primary_Address_gne__c, 
                            p.Phone_Type_gne__c,  p.Name, p.LastModifiedDate
                            From Patient_Address_gne__c p 
                            where p.Patient_gne__c =: PatientId and p.Type_gne__c = 'Mailing'
                            order by p.LastModifiedDate desc 
                            limit 100];
                        //-----------------------------------------------------------------------------                     
                        if (PatientAddressList.size() == 0)
                        {
                            PatientAddressList = [Select p.Id, p.Patient_gne__c,
                                p.Address_Line_1_gne__c, p.Address_Line_2_gne__c,
                                p.City_gne__c, p.State_gne__c, p.Zip_gne__c, 
                                p.Phone_gne__c, 
                                p.Type_gne__c,  p.Primary_Address_gne__c, 
                                p.Phone_Type_gne__c,  p.Name, p.LastModifiedDate
                                From Patient_Address_gne__c p 
                                where p.Patient_gne__c =: PatientId and p.Type_gne__c = 'Home'
                                order by p.LastModifiedDate desc 
                                limit 100];
                            
                            if (PatientAddressList.size() == 0)
                            {
                                PatientAddress = patientAddressWithoutFilter; 
                            }
                            else if (PatientAddressList.size() >= 1)
                            {
                                PatientAddress = PatientAddressList[0];
                            }
                        }
                        //-----------------------------------------------------------------------------
                        else if (PatientAddressList.size() >= 1)
                        {
                            PatientAddress = PatientAddressList[0];
                        }
                    }
                }
    }
}