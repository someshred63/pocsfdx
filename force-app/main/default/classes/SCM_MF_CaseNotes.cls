public class SCM_MF_CaseNotes extends SCM_MergeField {
    public SCM_MF_CaseNotes(Case selectedCase) {
        key = 'CaseNotes';     
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
      
        try {
        if (selectedCase.Access_Solutions_Online_Note_gne__c != null)
           fieldvalue = selectedcase.Access_Solutions_Online_Note_gne__c;
        else
            fieldValue = '';
        }
        catch (exception ex) 
        {
        	fieldvalue = '';
        }
    }
}