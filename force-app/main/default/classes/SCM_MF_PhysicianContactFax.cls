public class SCM_MF_PhysicianContactFax extends SCM_MergeField {
  private String phyId;
  public SCM_MF_PhysicianContactFax(String physicianId) {
        phyId = physicianId;
        checked = false;
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        setKey('Physician Contact Fax');
        className = 'SCM_MF_PhysicianContactFax';
        totalWidth = '270';
        width = '150';
        fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
  }

    public override String getFieldValue() {
        //get contact
        List<Contact> contacts = [Select c.Id, c.HCP_gne__r.FirstName, c.HCP_gne__r.Fax From Contact c where c.HCP_gne__r.Primary_Contact_gne__pc = true and c.HCP_gne__r.Id=:phyId order by c.HCP_gne__r.FirstName Limit 1];
        
        if (!contacts.isEmpty()) {          
            return contacts[0].HCP_gne__r.Fax;
        }
        else {
            return '';
        }
    }
        
}