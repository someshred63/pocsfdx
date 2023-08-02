public class SCM_MF_CaseType extends SCM_MergeField {
    public SCM_MF_CaseType(Case selectedCase) {
        key = 'CaseType';     
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
        className = 'CaseType';
        try {
        if (selectedCase.RecordType.Name != null)
            fieldValue = selectedCase.RecordType.Name;
        else
            fieldValue = '';
        }
        catch (exception ex) 
        {
        	fieldvalue = '';
        }
    }
}