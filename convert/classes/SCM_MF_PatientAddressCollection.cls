// Recreated by : Reji Joseph
//Updated By: Paras Sharma

public virtual class SCM_MF_PatientAddressCollection extends SCM_MergeField {
    protected Patient_Address_gne__c patientAddress;
    protected Patient_Address_gne__c patientAddressWithoutFilter;
    public static List<Patient_Address_gne__c> patientAddressList;
    public static List<Patient_Address_gne__c> patientFilteredAddressList;
    public SCM_MF_PatientAddressCollection(String patientId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = true;
        if(patientAddressList==null)
        {
			 patientAddressList = [Select p.Address_Line_1_gne__c, 
								   p.Address_Line_2_gne__c, 
								   p.City_gne__c, 
								   p.Counter_gne__c, 
								   p.Country_gne__c, 
								   p.Id, 
								   p.Name, 
								   p.Other_Phone_gne__c, 
								   p.Other_Phone_Type_gne__c, 
								   p.Patient_gne__c, 
								   p.Phone_gne__c, 
								   p.Phone_Type_gne__c, 
								   p.Primary_Address_gne__c, 
								   p.Release_gne__c, 
								   p.State_gne__c, 
								   p.Type_gne__c, 
								   p.Validated_gne__c, 
								   p.Zip_gne__c,
								   p.LastModifiedDate
						  from Patient_Address_gne__c p 
						  where p.Patient_gne__c = :patientId 
						  order by p.LastModifiedDate desc LIMIT 500];
        }
        
        if(patientAddressList.size() != 0)  {
        	patientAddressWithoutFilter = patientAddressList[0];
        }
        
        
        if(patientAddressList.size()==1)
            patientAddress= patientAddressList[0];
        else if(patientAddressList.size()>1)
        {		 
			 Boolean patientAddressSet = false;
			 // First search for type -> Mailing
        	 for(Patient_Address_gne__c address : patientAddressList)
        	 {
        	 	if(address.Type_gne__c == 'Mailing')
        	 	{
        	 		patientAddress= address;
        	 		patientAddressSet= true;
        	 	}
        	 }
        	 
        	 if(!patientAddressSet)
        	 {
        	 	// If we can't find Mailing search for type -> Home
        	 	for(Patient_Address_gne__c address : patientAddressList)
        	 	{
        	 		if(address.Type_gne__c == 'Home')
        	 		{
        	 			patientAddress= address;
        	 			patientAddressSet= true;
        	 		}
        	 	}
        	 }
        	 
        
            if(!patientAddressSet)
            {
            	//Basically returning the values without filters at this stage
            	patientAddress = patientAddressWithoutFilter;
            }
	        
        }
    }

}