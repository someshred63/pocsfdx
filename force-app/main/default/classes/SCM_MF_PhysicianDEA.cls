// Join Case.Case_Treating_Physician_gne__c to Account.ID and
// join Account.ID to ProfileID_Licence_gne__c.Account_Name_gne and 
// return a list of Profiles where ProfileID_Licence_gne__c.ID_Licences_Type_gne__c = “DEA#”, 
// Then Merge ProfileID_Licence_gne__c.ID_License_gne__c where last modified.

// Added by Jatin Setia
// Merge class for Physician DEA

public class SCM_MF_PhysicianDEA extends SCM_MergeField
{
    private string accountId;
    private String phyDEA = '';
    
    private static List<ProfileID_License_gne__c> profileList;
    public SCM_MF_PhysicianDEA(string accountId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        Key='Physician DEA';
        className = 'SCM_MF_PhysicianDEA';
        this.accountId=accountId;
        this.fieldValue = getFieldValue();
    }
    public override String getFieldValue()
    {
        if(profileList==null)
        {
         try{
            profileList=[select p.ID_License_gne__c from  ProfileID_License_gne__c p     
                        where p.Account_Name_gne__c=:accountId                        
                        and p.ID_License_Type_gne__c = 'DEA #'  order by p.LastModifiedDate desc limit 500];
         }catch(Exception e){
         		profileList = null;
         }          
        }
        if(profileList.size() > 0)
        {
            ProfileID_License_gne__c profileID =profileList[0];
            phyDEA=profileID.ID_License_gne__c; 
            phyDEA=(phyDEA==null)?'':phyDEA;
        }
        
        return phyDEA;
                
    }
}