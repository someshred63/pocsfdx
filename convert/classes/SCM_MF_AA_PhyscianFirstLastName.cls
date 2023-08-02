public class SCM_MF_AA_PhyscianFirstLastName extends SCM_MergeField {
    public SCM_MF_AA_PhyscianFirstLastName(Case selectedCase) {
        
        
        key = 'RECNAME_AntAccs';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_AA_PhyscianFirstLastName';
        Account phys = [select firstName,LastName from Account where id = :selectedCase.Case_Treating_Physician_gne__c limit 1];
        
        try {
        if (phys.FirstName != null)
        {
            
        fieldValue = phys.FirstName + ' ';
        }
        if (phys.LastName != null)
        {
            
        fieldValue += phys.LastName + ' ';
        }
        }
        catch (exception ex){
        fieldValue = '';    
        }
    }
}