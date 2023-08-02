public virtual class SCM_MD_GATCFRxPrefill extends SCM_MergeDocument{
    public  SCM_MD_GATCFRxPrefill (String caseId, String argLookupId) { 
        super(caseId, argLookupId);
    }
    
    public virtual override void createMergeFields() {
        String patientId = selectedCase.Patient_gne__r.Id;
        
        SCM_MF_PatientFirstAndLastName name = new SCM_MF_PatientFirstAndLastName(selectedCase);
		mergeRecipientInfo.add(name);
		
		SCM_MF_PatientDOB dateOfBirth = new SCM_MF_PatientDOB(patientId);
		mergeRecipientInfo.add(dateOfBirth); 
		
		//get physician associated with case
		String physicianId = selectedCase.Case_Treating_Physician_gne__c;
		
		SCM_MF_PrescriberFullName prescriberFullName = new SCM_MF_PrescriberFullName(physicianId);
		mergeRecipientInfo.add(prescriberFullName); 
    }
}