// Added By: Deepak Yadav
// Merge field for Physician first name
public class SCM_MF_PhysicianFirstName extends SCM_MF_PhysicianCollection {
	
	public SCM_MF_PhysicianFirstName(String accountId) {
		super(accountId);
		
		key = 'Physician First Name';
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
	}
	
	public override String getFieldValue() {				
		if(physicianManager !=null && physicianManager.FirstName != null ){
			return physicianManager.FirstName ;		
		}
		else {
			return '' ;
		}
  	}
}