// Added By: Deepak Yadav
// Merge field for Case Manger First and LAst name
public class SCM_MF_CaseMangFirstAndLastName extends SCM_MF_CaseMangCollection {
      
    public SCM_MF_CaseMangFirstAndLastName(String userId) {
        super(userId);
        
        key = 'Case Manger First And Last Name' ;
        this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = true;
        this.displayLabel = true; 
    }
    
    public override String getFieldValue() {        
        string Fullname = '';
        if(caseManager !=null){
            if( caseManager.FirstName != null) {
                Fullname = caseManager.FirstName ;              
            }
            if( caseManager.LastName != null) {
                if(Fullname == '') {
                    Fullname = caseManager.LastName ;
                }
                else {
                    Fullname = Fullname + ' ' + caseManager.LastName ;
                }
                                
            }       
        }
        Fullname= Fullname.replace('&','');
        Fullname= Fullname.replace('?','');
        return Fullname;
        
    }

}