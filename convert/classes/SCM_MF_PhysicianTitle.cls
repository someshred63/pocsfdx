public class SCM_MF_PhysicianTitle extends SCM_MF_PhysicianCollection {
    public SCM_MF_PhysicianTitle(String accountId) {
        super(accountId);
        setKey('Physician Title');
        className = 'SCM_MF_PhysicianTitle';        
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
    }
    
    public override String getFieldValue() {                
        if(physicianManager !=null && physicianManager.Title_gne__pc != null ){
            return physicianManager.Title_gne__pc;      
        }
        else {
            return '' ;
        }
    }
}