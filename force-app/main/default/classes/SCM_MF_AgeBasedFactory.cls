public class SCM_MF_AgeBasedFactory {
    private static SCM_MergeField createMergeField(String key) {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        mf.fieldValue =''; 
        return mf;
    }
    
    private static List<Patient_gne__c> patientList;
    private static List<Patient_Address_gne__c> patientAddressList;
    private static List<Patient_Contact_gne__c> patientContactList;
    
    private static Patient_gne__c getPatient(String patientId) {
    	try {
	        if (patientList == null) {
	            patientList = [Select p.pat_dob_gne__c,
	                p.pat_first_name_gne__c,
	                p.Name
	                From Patient_gne__c p
	                Where p.Id = :patientId];
	        }
	        if (!patientList.isEmpty())
	            return patientList[0];
	        else
	            return null;
    	}
    	catch (Exception e) {
    		return null;
    	}
    }

    private static Patient_Address_gne__c getPatientAddress(String patientId){
    	try {
	        if (patientAddressList == null) {
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
	
	        if (patientAddressList.isEmpty())
	            return null;
	        else if (patientAddressList.size() == 1)
	            return patientAddressList[0];
	        else {
	            List<Patient_Address_gne__c> primary = new List<Patient_Address_gne__c>();
	                
	            for (Patient_Address_gne__c add : patientAddressList) {
	                if (add.Primary_Address_gne__c == 'Yes')
	                    primary.add(add);
	            }
	                
	            if (primary.isEmpty())
	                return patientAddressList[0];
	            else if (primary.size() == 1)
	                return primary[0];
	            else {
	                List<Patient_Address_gne__c> mailing = new List<Patient_Address_gne__c>();
	                    
	                for (Patient_Address_gne__c add1 : primary) {
	                    if (add1.Type_gne__c == 'Mailing')
	                        mailing.add(add1);
	                }
	                    
	                if (!mailing.isEmpty())
	                    return mailing[0];
	                else {
	                    List<Patient_Address_gne__c> home = new List<Patient_Address_gne__c>();
	                        
	                    for (Patient_Address_gne__c add2 : primary) {
	                        if (add2.Type_gne__c == 'Home')
	                            home.add(add2);
	                    }
	                        
	                    if (!home.isEmpty())
	                        return home[0];
	                    else
	                        return patientAddressList[0];
	                }
	            }
	        }
    	}
    	catch (Exception e) {
    		return null;
    	}
    }
    
    private static Patient_Contact_gne__c getPatientContact(String patientId) {
        try {
	        if(patientContactList == null) {
	            patientContactList = [Select p.pat_con_Patient_gne__r.Patient_ID_gne__c, 
	                                         p.pat_con_Patient_gne__c, 
	                                         p.pat_con_Contact_Type_gne__c, 
	                                         p.LAST_NAME_CONT_gne__c, 
	                                         p.First_Name_gne__c,
	                                         p.pat_con_Home_Phone_gne__c,
	                                         p.pat_con_Work_gne__c,
	                                         p.pat_con_Other_Phone_gne__c,
	                                         p.pat_con_Relationship_to_Patient_gne__c,
	                                         p.pat_con_Mail_Box_gne__c,
	                                         p.pat_con_Street_gne__c,
	                                         p.pat_con_City_gne__c,
	                                         p.pat_con_State_gne__c,
	                                         p.pat_con_Zip_gne__c
	                                  From Patient_Contact_gne__c p
	                                  where p.pat_con_Patient_gne__c=:patientId 
	                                  order by p.LastModifiedDate desc 
	                                  LIMIT 500];
	        }
	                                  
	        if (patientContactList.isEmpty())
	            return null;
	        else if (patientContactList.size() == 1)
	            return patientContactList[0];
	        else {
	            List<Patient_Contact_gne__c> primary = new List<Patient_Contact_gne__c>();
	            
	            for (Patient_Contact_gne__c patCon : patientContactList) {
	                if ((patCon.pat_con_Contact_Type_gne__c != null) && (patCon.pat_con_Contact_Type_gne__c == 'Primary'))
	                    primary.add(patCon);
	            }
	            
	            if (primary.size() == 1)
	                return primary[0];
	            else if (primary.size() > 1) {
	                Patient_Contact_gne__c retPatCon;
	                for (Patient_Contact_gne__c relPatCon : primary) {
	                    String relationship = relPatCon.pat_con_Relationship_to_Patient_gne__c;
	                    if (relationship != null) {
		                    if (relationship.equals('Parent') || relationship.equals('Legal Guardian')) {
		                        retPatCon = relPatCon;
		                        break;
		                    }
	                    }       
	                }
	                if (retPatCon  == null) 
	                    return primary[0];
	                else
	                    return retPatCon;
	            }
	            else {
	                Patient_Contact_gne__c retPatCon1;
	                for (Patient_Contact_gne__c relPatCon1 : patientContactList) {
	                    String relationship1 = relPatCon1.pat_con_Relationship_to_Patient_gne__c;
	                    if (relationship1 != null) {
	                    	if (relationship1.equals('Parent') || relationship1.equals('Legal Guardian')) {
	                        	retPatCon1 = relPatCon1;
	                        	break;
	                    	}
	                    }       
	                }
	                if (retPatCon1 == null)
	                    return patientContactList[0];
	                else
	                    return retPatCon1;
	            }
	        }
        }
        catch (Exception e) {
        	return null;
        }
   }
        
    private static Integer getAgeMonths(String patientId) {
        Patient_gne__c patient = getPatient(patientId);
        
        if (patient != null) {
            Date dob = patient.pat_dob_gne__c;
            
            if (dob != null)
                return dob.monthsBetween(Date.today());
            else
                return 0;
        }
            else {
                return 0;
        }
        
    }
    
    public static SCM_MergeField AgeBasedFullName(String patientId) {
        SCM_MergeField mField = createMergeField('AgeBasedFullName');
        
        try {
	        if (getAgeMonths(patientId) > 216) {
	            mField.fieldValue = SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId).fieldValue;
	        }
	        else {
	            Patient_Contact_gne__c patCon = getPatientContact(patientId);
	            
	            if (patCon != null) {
		            String firstName = patCon.First_Name_gne__c;
		            String lastName = patCon.Last_Name_CONT_gne__c;
		            
		            if (firstName == null)
		                firstName = '';
		            if (lastName == null)
		                lastName = '';
		            
		            mField.fieldValue = firstName + ' ' + lastName;
	            }
	            else
	            	mField.fieldValue = SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId).fieldValue;
	                          
	        }
        }
        catch (Exception e) {
        	mField.fieldValue = '';
        }
        return mField;
    }
    
    public static SCM_MergeField AgeBasedStAddress(String patientId) {
        SCM_MergeField mField = createMergeField('AgeBasedStAddress');
        Patient_Contact_gne__c patCon = getPatientContact(patientId);
        
        if ((getAgeMonths(patientId) > 216) || (patCon == null)) {
            
            Patient_Address_gne__c patAddress = getPatientAddress(patientId);
            
            if (patAddress != null) {
                String addressLine1 = patAddress.Address_Line_1_gne__c;
                String addressLine2 = patAddress.Address_Line_2_gne__c;
                
                if (addressLine1 == null)
                    addressLine1 = '';
                    
                if (addressLine2 == null)
                    addressLine2 = '';
                    
                if (!addressLine1.equals('') && !addressLine2.equals(''))
                    mField.fieldValue = addressLine1 + ' ' + addressLine2;
                else if (addressLine1.equals('') && addressLine2.equals(''))
                    mField.fieldValue = '';
                else if (addressLine1.equals(''))
                    mField.fieldValue = addressLine2;
                else
                    mField.fieldValue = addressLine1;
            }
            else
                mField.fieldValue = '';
        }
        else {
            String mailBox = patCon.pat_con_Mail_Box_gne__c;
            String street = patCon.pat_con_Street_gne__c;
            
            if (mailBox == null)
               mailBox = '';
            if (street == null)
                street = '';
            
            mField.fieldValue = street  + ' ' +mailBox ;                
        }
      
        return mField;
    }
    
    public static SCM_MergeField AgeBasedCityStateZip(String patientId) {
        SCM_MergeField mField = createMergeField('AgeBasedCityStateZip');
        
        try {
	        Patient_Contact_gne__c patCon = getPatientContact(patientId);
	        
	        if ((getAgeMonths(patientId) > 216) || (patCon == null)) {
	            
	            Patient_Address_gne__c patAddress = getPatientAddress(patientId);
	            String city = patAddress.City_gne__c;
	            String state = patAddress.State_gne__c;
	            String zip = patAddress.Zip_gne__c;
	            
	            if (city == null)
	                city = '';
	                
	            if (state == null)
	                state = '';
	                
	            if (zip == null)
	                zip = '';
	            
	            mField.fieldValue = city + ' ' + state + ' ' + zip; 
	            
	        }
	        else {
	            String city = patCon.pat_con_City_gne__c;
	            String state = patCon.pat_con_State_gne__c;
	            String zip = patCon.pat_con_Zip_gne__c;
	            
	            if (city == null)
	               city = '';
	            if (state == null)
	                state = '';
	            if (zip == null)
	                zip = '';
	            
	            mField.fieldValue = city + ' ' + state + ' ' + zip;                
	        
	        }
        }
	    catch (Exception e) {
	      	mField.fieldValue = '';
	    }        
        return mField;
    }
}