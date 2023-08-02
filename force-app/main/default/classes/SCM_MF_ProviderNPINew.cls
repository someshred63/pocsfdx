// Added By : Jatin Setia
// Logic is : 
        //Join Cases.Case_Treating_Physician_gne__c to Account.ID and 
        //join Account.ID to ProfileID_Licence_gne__c.Account_Name_gne and 
        //return a list of Profiles where ProfileID_Licence_gne__c.ID_Licences_Type_gne__c = "NPI #". 
        //Then Merge ProfileID_Licence_gne__c.ID_License_gne__c where last modified.

public class SCM_MF_ProviderNPINew extends SCM_MergeField {
    
    private string accountId;
    private ProfileID_License_gne__c NPI ;
    
    
    public SCM_MF_ProviderNPINew(String AccountId) {
        key = 'ProviderNPINew';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_ProviderNPINew';
        this.accountId = AccountId;
    }
    
    public override String getFieldValue() {
        string name ;
         
        List<ProfileID_License_gne__c> NPIList  = [Select p.Id, p.ID_License_gne__c, 
            p.State_gne__c, p.Release_gne__c, p.Name,  p.ID_License_Type_gne__c, p.Address_gne__c, 
            p.Account_Type_gne__c, p.Account_Name_gne__c , p.LastModifiedDate
            From ProfileID_License_gne__c p
            where p.Account_Name_gne__c =: accountId and p.ID_License_Type_gne__c in ('NPI #')
            order by  p.LastModifiedDate desc
            limit 100];

        if(NPIList.size() > 0)
        {
            NPI = NPIList[0] ;            
        }
        else
        {
            NPI = null;
         }   
        
            string providerNPI = '';
        if (NPI != null && NPI.ID_License_gne__c != null)
            providerNPI = NPI.ID_License_gne__c;
        else
            providerNPI = '';
        
        return providerNPI;

        }    

}