//created by:Shobha rawat
//Join Cases.Case_Treating_Physician_gne__c to Account.ID 
//and merge ProfileID_License.NPI_vod__c


public class SCM_MF_ProviderNPI extends SCM_MergeField {
    
    private string account_Id;
    private ProfileID_License_gne__c NPI ;
    
    
  	public SCM_MF_ProviderNPI(String accountId) {
        key = 'ProviderNPI';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_ProviderNPI';
        this.account_Id = accountId;
        fieldValue=getFieldValue();
    }
    
    public override String getFieldValue() {
    	string name ;
    	 
        List<ProfileID_License_gne__c> NPIList  = [Select p.ID_License_gne__c 
        from ProfileID_License_gne__c p
        where p.Account_Name_gne__r.Id = :account_Id LIMIT 100];
        
        if(NPIList.size() >=1){
        	NPI = NPIList[0] ;
        	name = NPI.ID_License_gne__c;
        	name=(name==null)?'':name;
        } else {
        	name = '' ;
        }
        
        return name;     

     }


}