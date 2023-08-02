// Added By: Deepak Yadav
// Merge field for Physician  last name
public class SCM_MF_PhysicianLastName extends SCM_MF_PhysicianCollection {
	
	public SCM_MF_PhysicianLastName(String accountId) {
		super(accountId);
		
		key = 'Physician Last Name';
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
	}
	
	public override String getFieldValue() {				
		if(physicianManager !=null && physicianManager.LastName != null ){
			return physicianManager.LastName ;		
		}
		else {
			return '' ;
		}
  	}
	
}