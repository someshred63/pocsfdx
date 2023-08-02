// Added by Reji Joseph

//	Join Case.Case_Treating_Physician_gne__c to Account.ID and 
//	join Account.ID to ProfileID_Licence_gne__c.Account_Name_gne and return a list of Profiles 
//	where ProfileID_Licence_gne__c.ID_Licences_Type_gne__c = “DEA#”/“Tax ID”, Then
//	Merge ProfileID_Licence_gne__c.ID_License_gne__c where last modified.


public virtual class SCM_MF_PhysicianProfileCollection_Luc extends SCM_MergeField {
	
	protected ProfileID_License_gne__c physicianProfile;
	
    public SCM_MF_PhysicianProfileCollection_Luc (String AccountId, String LicenceType)
    {
    	checked=false;
    	displayCheck=false;
    	displayTextBox=false;
    	displayLabel=false;
    	Key='Physician Profile Luncentis'; 
    	className='SCM_MF_PhysicianProfileCollection_Luc';
        
        List<ProfileID_License_gne__c> phyProfileList = [Select p.Id, p.ID_License_gne__c, 
	        p.State_gne__c, p.Release_gne__c, p.Name,  p.ID_License_Type_gne__c, p.Address_gne__c, 
	        p.Account_Type_gne__c, p.Account_Name_gne__c , p.LastModifiedDate
	        From ProfileID_License_gne__c p
	        where p.Account_Name_gne__c =: AccountId and p.ID_License_Type_gne__c =: LicenceType
	        order by  p.LastModifiedDate desc
	        limit 100];
	        
		if (phyProfileList.size() == 0)
			{
				physicianProfile = null;
			}
		else
			{
				physicianProfile = phyProfileList[0];
			} 
    }
}