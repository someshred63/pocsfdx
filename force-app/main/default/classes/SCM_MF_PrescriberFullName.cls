public class SCM_MF_PrescriberFullName extends SCM_MergeField {
	private String physicianId;
	
	public SCM_MF_PrescriberFullName(String accountId) {
		physicianId = accountId;
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        setKey('Physician Full Name');
        className = 'SCM_MF_PrescriberFullName';
	}
	
	public override String getFieldValue() {				
		SCM_MF_PhysicianFirstName firstName = new SCM_MF_PhysicianFirstName(physicianId);
		SCM_MF_PhysicianLastName lastName = new SCM_MF_PhysicianLastName(physicianId);
		return firstName.getFieldValue() + ' ' + lastName.getFieldValue();
  	}
}