public class SCM_MD_GATCFRxPrefill_Xeloda  extends SCM_MergeDocument
 {
 	private String caseRecordType;
 	protected String patientIdLocal;
	public SCM_MD_GATCFRxPrefill_Xeloda(String caseId, String argLookupId) 
	{
		super(caseId, argLookupId);
	}
	
	public override void createMergeFields()
	 {
      String patientId = selectedCase.Patient_gne__r.Id;
      patientIdLocal = selectedCase.Patient_gne__r.Id; 
     
      //1.  CaseID
       this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
   
      //GATCF_Fax key = GATCF_Fax
      this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
                     
     //GATCF_URL key = 'GATCF_URL';
      this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
     
     //PatientFullName(Patient_First_And_Last_Name)
      this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
    
      //DOB (patient)(key Patient_DOB)
      this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(PatientIdLocal));
      
 		this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
      //PhysicianFullName (key Physician First Last Name)
      this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.id));  
    
      //PhysicianStAddress    (Physician Street Address) 
       this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));	 
      
      //PhysicianCityStateZip  
      this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));     
       
      //PhysContactPh (PhysContactPh) 
     // this.mergeRecipientInfo.add(new SCM_MF_PhysicianConatcPhone(selectedCase));
      this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
      
      //PhysicianDEA   (key Physician DEA)
      this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(selectedCase.Case_Treating_Physician_gne__r.Id));
         
      //CaseWorker
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordType.equalsIgnoreCase('C&R - Standard Case')) {
         
         this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
          
          /**
            SCM_MF_CaseMangFirstAndLastName casMang = 
                new SCM_MF_CaseMangFirstAndLastName(selectedCase.Case_Manager__r.Id);
            string casMangVal = casMang.getFieldValue();
            casMang.fieldValue = casMangVal;
            casMang.key = 'Case Mang Name';
            this.mergeRecipientInfo.add(casMang);
            */
        }        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) {
        	            
          this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
      
            /**
            SCM_MF_FoundationSplName foundSpl=
                new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id);
            string foundSplVal = foundSpl.getFieldValue();
            foundSpl.fieldValue = foundSplVal;
            foundSpl.key = 'Case Mang Name';         
            this.mergeRecipientInfo.add(foundSpl);
            */
        }
    
	}
}