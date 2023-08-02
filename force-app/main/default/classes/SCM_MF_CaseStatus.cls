public class SCM_MF_CaseStatus extends SCM_MergeField {
    public SCM_MF_CaseStatus(Case selectedCase) {
        key = 'CaseStatus';     
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
    
        try {
        if (selectedCase.Status != null)
            fieldValue = selectedCase.Status;
        else
            fieldValue = '';
        }
        catch (exception ex) 
        {
        	fieldvalue = '';
        }
    }
}