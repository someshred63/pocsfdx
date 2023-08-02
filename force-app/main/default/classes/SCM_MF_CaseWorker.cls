public class SCM_MF_CaseWorker extends SCM_mergefield {
	
	 public SCM_MF_CaseWorker(Case selectedCase) {
        
        checked = false;
        displayCheck = false;
        displayTextBox = true;
        displayLabel = true;
        label = 'from:';
        
        if (selectedCase.RecordType.Name.startsWith('GATCF')) {
        fieldvalue = new scm_mf_foundationSpecialist(Selectedcase).fieldvalue;
        }
        else {
        fieldvalue = 	SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(SelectedCase.Case_Manager__c).fieldvalue;
        	
        	
        	
        }
       key = 'caseworker'; 
    }

}