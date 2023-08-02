public class SCM_MF_PhysicianLicenceID extends SCM_MergeField {
  private string practice_id;
  private string facility_id;
  public SCM_MF_PhysicianLicenceID(Case selectedCase) {
        practice_id = selectedCase.Case_Treating_Physician_gne__c;
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        setKey('PhysicianLicenceID');
        className = 'SCM_MF_PhysicianLicenceID';
  }
  /* Logic
<<PhysicianLicenceID>>
Join Case.Case_Treating_Physician_gnec to Account.ID 
  and join Account.ID to ProfileID_Licence_gnec.Account_Name_gne 
and return a list of Profiles where ProfileID_Licence_gnec.ID_Licences_Type_gnec = “State License”, 
Then
Merge ProfileID_Licence_gnec.ID_License_gnec where last modified. 
   */

    public override String getFieldValue() {
        if(practice_id != null)
        {
            ProfileID_License_gne__c profile = [select p.ID_License_Type_gne__c,ID_License_gne__c  
                                                  from ProfileID_License_gne__c p
                                                 where p.ID_License_Type_gne__c = 'State License'
                                                   and p.Account_Name_gne__c=:practice_id Limit 1];
            if (case.Practice_gne__r.Id != null)
            {
                return profile.ID_License_gne__c;
            }
        }
        return '';
    }
}