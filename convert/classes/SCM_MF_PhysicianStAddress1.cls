// Added by Reji Joseph
// Join Case.Address_gne__c to Address_vod__c.ID and merge Address_vod__c.Address_1_gne__c 

public virtual class SCM_MF_PhysicianStAddress1 extends SCM_MergeField {

    public SCM_MF_PhysicianStAddress1 (String AccountId)
    {
    	checked=false;
    	displayCheck=false;
    	displayTextBox=false;
    	displayLabel=false;
    	Key='PhysicianStAddress'; 
    	className='SCM_MF_PhysicianStAddress1';
    	
    	fieldValue = obtainData(AccountId);
    }

	public String obtainData(String AccountId)
   	{
   		String returnString = '';
   		
 		List<Address_vod__c> phyStAddressList = [Select a.Address_1_gne__c, a.Account_vod__r.Id, 
        	a.Account_vod__c From Address_vod__c a 
        	where a.Account_vod__c  =: AccountId 
	        order by  a.LastModifiedDate desc
	        limit 100];   		
   		
		if (phyStAddressList.size() == 0)
			{
				// do nothing
			}
		else
			{
				returnString = phyStAddressList[0].Address_1_gne__c;
			}

        if(returnString==null)
        {
         	returnString=''; 
        }
        return returnString;
   	}        
        
}