// Added by Reji Joseph

//	Join Case.Case_Treating_Physician_gne__c to Account.ID and 
//	join Account.ID to ProfileID_Licence_gne__c.Account_Name_gne and return a list of Profiles 
//	where ProfileID_Licence_gne__c.ID_Licences_Type_gne__c = “DEA#”/“Tax ID/State Licence”, Then
//	Merge ProfileID_Licence_gne__c.ID_License_gne__c where last modified.


public virtual class SCM_MF_PhysicianProfileLicenceID extends SCM_MergeField {
	
    public SCM_MF_PhysicianProfileLicenceID (String AccountId)
    {
    	checked=false;
    	displayCheck=false;
    	displayTextBox=false;
    	displayLabel=false;
    	Key='PhysicianLicenceID'; 
    	className='SCM_MF_PhysicianProfileCollection_Luc';
    	
    	fieldValue = obtainData(AccountId);
    }

	public String obtainData(String AccountId)
   	{
   		String returnString = '';
   		
        List<ProfileID_License_gne__c> phyProfileList = [Select p.Id, p.ID_License_gne__c, 
	        p.State_gne__c, p.Release_gne__c, p.Name,  p.ID_License_Type_gne__c, p.Address_gne__c, 
	        p.Account_Type_gne__c, p.Account_Name_gne__c , p.LastModifiedDate
	        From ProfileID_License_gne__c p
	        where p.Account_Name_gne__c =: AccountId and p.ID_License_Type_gne__c in ('State License')
	        order by  p.LastModifiedDate desc
	        limit 500];
   		
		if (phyProfileList.size() == 0)
			{
				// do nothing
			}
		else
			{
				returnString = phyProfileList[0].ID_License_gne__c;
			}

        if(returnString==null)
        {
         	returnString=''; 
        }
        return returnString;
   	}                
}