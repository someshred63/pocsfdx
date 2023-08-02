public class SCM_MF_AccCa_ICD9 extends SCM_MergeField {
    public SCM_MF_AccCa_ICD9(Case selectedCase) {
        key = 'ICD9code';     
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
        className = 'CaseType';
        try {
        if (selectedCase.Diagnosis_gne__c != null)
        
        
            fieldValue = selectedCase.Diagnosis_gne__c;
            
            if (fieldValue != null) {
            	
            	try {
            		
            	
            	//this will try to only get the numbers.
            		fieldValue = fieldvalue.split('-')[0];
            	}
            	catch(exception ex)
            	{
            		
            		
            	}
            	
            }
            
        else
            fieldValue = '';
        }
        catch (exception ex) 
        {
        	fieldvalue = '';
        }
    }
}