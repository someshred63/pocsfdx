// Added By: Deepak Yadav
// Merge field for Physician CityStateZip
// Second overloaded constrctor will join address_vod_c table direclty with case table
public class SCM_MF_PhysicianCityStateZip extends SCM_MF_PhysicianAddCollection {
	
	public SCM_MF_PhysicianCityStateZip(String accountId) {
		super(accountId);
		
		key = 'Physician City State and Zip';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        className = 'SCM_MF_PhysicianCityStateZip';
	}
	
	public SCM_MF_PhysicianCityStateZip(String accountId, String addressId) {
		super(accountId, addressId);		
		key = 'Physician City State and Zip';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        className = 'SCM_MF_PhysicianCityStateZip';
	}
	
	
    public override String getFieldValue() {
    	string cityStateZip = '';
    	if(physicianAddress != null ) {
    		if (physicianAddress.City_vod__c != null)
	    		cityStateZip = physicianAddress.City_vod__c ;
			if (physicianAddress.State_vod__c != null)
	    		cityStateZip = cityStateZip + ', ' + physicianAddress.State_vod__c ;
			if (physicianAddress.Zip_vod__c != null)
	    		cityStateZip = cityStateZip + ' ' + physicianAddress.Zip_vod__c ;
	    	return cityStateZip;
    	}    
    	else
        	return cityStateZip ;
  	}

}