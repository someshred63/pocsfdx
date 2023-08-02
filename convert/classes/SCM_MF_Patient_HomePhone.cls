// Added by Reji Joseph

public virtual class SCM_MF_Patient_HomePhone extends SCM_MergeField {
	
    public SCM_MF_Patient_HomePhone (String PatientId)
    {
    	checked=false;
    	displayCheck=false;
    	displayTextBox=false;
    	displayLabel=false;
    	Key='PatientHomePhone'; 
    	className='SCM_MF_Patient_HomePhone';

        fieldValue = obtainData(PatientId);
    }
    
 	public String obtainData(String PatientId)
   	{
   		String returnString = '';
   		
        List<Patient_gne__c > patientHomePhoneList = [Select p.pat_home_phone_gne__c, p.Id 
        			From Patient_gne__c p
	        		where p.Id =: PatientId 
	        		order by  p.LastModifiedDate desc
	        		limit 100];
	        		
		if (patientHomePhoneList.size() == 0)
			{
				// do nothing
			}
		else
			{
				returnString = patientHomePhoneList[0].pat_home_phone_gne__c;
			}

        if(returnString==null)
        {
         	returnString=''; 
        }
        return returnString;
   	}
}