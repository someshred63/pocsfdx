// Added By: Deepak Yadav
// Merge field for Physician first, middle and last name
public class SCM_MF_PhysicianFirstMidAndLastName  extends SCM_MF_PhysicianCollection {
    
    public SCM_MF_PhysicianFirstMidAndLastName(String accountId) {
        super(accountId);
        
        key = 'Physician First Middle And Last Name';
        checked = false;
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        fieldType = FieldTypes.fullNameField; 
        className = 'SCM_MF_PhysicianFirstMidAndLastName';
        fieldValue=getFieldValue();
    }
    public SCM_MF_PhysicianFirstMidAndLastName(String accountId, string newkey) {
       this(accountId);
        key = newkey;
    }
    public override String getFieldValue() {
        String fullName = '';       
        if(physicianManager !=null){              
            fullName = (physicianManager.FirstName == null)? '': physicianManager.FirstName;
            if (physicianManager.Middle_vod__c != null){
                fullName = fullName + ' ' + physicianManager.Middle_vod__c;
            }
            fullName = fullName + ' ' + ((physicianManager.LastName == null)? '': physicianManager.LastName) ;
            return fullName ;       
        }
        else {
            return fullName ;
        }
    }

}