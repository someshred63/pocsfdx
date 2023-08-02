// Added By Paras Sharma

public class SCM_MF_PhysicianCity extends SCM_MF_PhysicianAddCollection{

	public SCM_MF_PhysicianCity(String accountId) {
		super(accountId);
		
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'Physician City'; 
        className = 'SCM_MF_PhysicianCity';
        this.fieldValue = getFieldValue();
	}
	public SCM_MF_PhysicianCity(String accountId, String addressId) {
		super(accountId, addressId);		
		key = 'Physician City';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        className = 'SCM_MF_PhysicianCity';
        this.fieldValue = getFieldValue();
	}
	
    public override String getFieldValue() {
    	string city = '';
    	if(physicianAddress != null ) {
    		if (physicianAddress.City_vod__c != null){
	    		city = physicianAddress.City_vod__c ;
    		}
			return city;
    	}    
    	else
        	return city ;
  	}
	
}