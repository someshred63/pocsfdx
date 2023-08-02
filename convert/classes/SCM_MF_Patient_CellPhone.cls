// Added by Reji Joseph

public virtual class SCM_MF_Patient_CellPhone extends SCM_MergeField {
	
    public SCM_MF_Patient_CellPhone (String PatientId)
    {
    	checked=false;
    	displayCheck=false;
    	displayTextBox=false;
    	displayLabel=false;
    	Key='PatientCellPhone'; 
    	className='SCM_MF_Patient_CellPhone';
    	
    	fieldValue = obtainData(PatientId);
    }
    
    public String obtainData(String PatientId)
   	{
   		String returnString = '';
   		
   		List<Patient_gne__c > patientCellPhoneList = [Select p.pat_work_phone_gne__c, p.pat_other_phone_type_gne__c, 
			p.pat_other_phone_gne__c, p.pat_home_phone_gne__c, p.Id From Patient_gne__c p
	        where p.Id =: patientId and  p.pat_other_phone_type_gne__c = 'Mobile'
	        order by  p.LastModifiedDate desc
	        limit 100];
	        		
		if (patientCellPhoneList.size() == 0)
			{
				// do nothing
			}
		else
			{
				returnString = patientCellPhoneList[0].pat_other_phone_gne__c;
			}

        if(returnString==null)
        {
         	returnString=''; 
        }
        return returnString;
   	}        

}