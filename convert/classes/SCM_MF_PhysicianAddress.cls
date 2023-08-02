// Added By: Deepak Yadav
// Merge field for Phyisician
public class SCM_MF_PhysicianAddress extends SCM_MF_PhysicianAddCollection {
	  
	public SCM_MF_PhysicianAddress(String accountId) {
		super(accountId);
		
		key = 'Physician Address' ;
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
	}
	
	public override String getFieldValue() {
		if(physicianAddress !=null){
  			return physicianAddress.Name ; 
  			// Note: Mail_Box_gne__c field not found yet. when it get found then it has to be added in the return string
		}
		else {
			return '';
		}
  	}

}