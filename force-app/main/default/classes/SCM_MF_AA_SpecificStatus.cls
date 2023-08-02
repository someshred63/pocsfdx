public class SCM_MF_AA_SpecificStatus extends SCM_MergeField {
    public SCM_MF_AA_SpecificStatus(Case selectedCase) {
        key = 'SpecificStatus';     
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
      fieldValue = '';
        try {
        if (selectedCase.RecordType.Name == 'C&R - Standard Case')
        {
            if (selectedcase.Cvg_gne__c != null)
            	fieldValue = 'Coverage Status: ' + selectedcase.Cvg_gne__c;
        }
        else if (selectedCase.RecordType.Name == 'C&R - Continuous Care Case')
        {
        	if (selectedcase.CCP_Approved_gne__c != null)
        	fieldvalue = 'CCP Status: ' + selectedcase.CCP_Approved_gne__c;
        }
        else if (selectedCase.RecordType.Name == 'GATCF - Standard Case')
        {
        	if (selectedcase.GATCF_Status_gne__c != null)
        		fieldvalue = 'GATCF Status: ' +  selectedcase.GATCF_Status_gne__c;
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