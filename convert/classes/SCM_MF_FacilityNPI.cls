public class SCM_MF_FacilityNPI extends SCM_MergeField {
  private string practice_id;
  private string facility_id;
  
  public SCM_MF_FacilityNPI(Case selectedCase) {
        practice_id = selectedCase.Practice_gne__c;
        facility_id = selectedCase.Facility_gne__c;
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        setKey('FacilityNPI');
        className = 'SCM_MF_FacilityNPI';
        fieldValue=getFieldValue();
  }
  /* Logic
    
     If Case.Practice_gne__c  <> NULL, 
      then Join Case.Practice_gne__c to Account.ID and join Account.ID to ProfileID_Licence_gne__c.Account_Name_gne and return a list of Profiles 
      where ProfileID_Licence_gne__c.ID_Licences_Type_gne__c = "NPI #". 
     Then
       Merge ProfileID_Licence_gne__c.ID_License_gne__c where last modified., 
     else
       If Case.Facility_gne__c  <> NULL, 
        then Join Case.Facility_gne__c to Account.ID and join Account.ID to ProfileID_Licence_gne__c.Account_Name_gne and return a list of Profiles 
        where ProfileID_Licence_gne__c.ID_Licences_Type_gne__c = "NPI #". 
       Then
         Merge ProfileID_Licence_gne__c.ID_License_gne__c where last modified, 
       else Merge ""
   */

    public override String getFieldValue() {
            String accID = '';

            if (practice_id != null)
            {
                accID = practice_id;
            }
            else if (facility_id != null)  
            {
                accID = facility_id;
            }

            if(accID != '')
            {
                List<ProfileID_License_gne__c> profile = [Select p.ID_License_Type_gne__c,
                                                           p.ID_License_gne__c 
                                                      FROM ProfileID_License_gne__c p
                                                     WHERE p.Account_Name_gne__c=:accID Limit 1];
            
                if (!profile.isEmpty())
                {
                    if (profile[0].ID_License_gne__c != null)
                    	return profile[0].ID_License_gne__c;
                    else
                    	return '';
                }
            }
            return '';
    }
}