public class SCM_MF_PhysicianContactName extends SCM_MergeField {
  private String phyId;
  public SCM_MF_PhysicianContactName(String physicianId) {
        phyId = physicianId;
        checked = false;
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        setKey('Physician Contact Name');
        fieldType = SCM_MergeField.FieldTypes.fullNameField;
        className = 'SCM_MF_PhysicianContactName';
  }

    public override String getFieldValue() {
        //get contact
        List<Contact> contacts = [Select c.Id, c.HCP_gne__r.FirstName From Contact c where c.HCP_gne__r.Primary_Contact_gne__pc = true and c.HCP_gne__r.Id=:phyId order by c.HCP_gne__r.FirstName Limit 1];
        
        if (!contacts.isEmpty()) {          
            if(contacts[0].HCP_gne__r.FirstName != null){
            	return contacts[0].HCP_gne__r.FirstName;}
            else{
            	return '';}
        }
        else {
            return '';
        }
    }
}