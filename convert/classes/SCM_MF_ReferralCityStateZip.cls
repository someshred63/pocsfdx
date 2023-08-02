public class SCM_MF_ReferralCityStateZip extends SCM_MF_AddressCollection {
	
	  
	public SCM_MF_ReferralCityStateZip(String addressId){
    	super(addressId);
		    	      
		Key = 'ReferralCityStateZip';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_ReferralCityStateZip';
    }
    
    public SCM_MF_ReferralCityStateZip(String addressId,Case selectedCase){
    	super(addressId,selectedCase);
		    	      
		Key = 'ReferralCityStateZip';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;    
        fieldValue=getFieldValue();
        className='SCM_MF_ReferralCityStateZip';
    }
    
    
    public override String getFieldValue() {
    	 
    		String referredByType = selectedCase.Referred_By_Type_gne__c;
    		string cityStateZip = '';
    		if(ReferredByType == 'Physician/MDO' || ReferredByType == 'Nurse Practitioner'|| ReferredByType == 'Hospital') 
    		{
			if(addressRecord !=Null){
    			if (addressRecord.City_vod__c != null)
	    			cityStateZip = addressRecord.City_vod__c ;
				if (addressRecord.State_vod__c!= null)
	    			cityStateZip = cityStateZip + ' ' + addressRecord.State_vod__c ;
				if (addressRecord.Zip_vod__c != null)
	    			cityStateZip = cityStateZip + ' ' + addressRecord.Zip_vod__c ;
	   		 }
    		}
	   		   cityStateZip=(cityStateZip==null)?'':cityStateZip;  
    		   return cityStateZip;	
		
     
 }

}