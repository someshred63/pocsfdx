public class SCM_MD_ClosureLetForMD_ACTE_RA extends SCM_MergeDocument{

	
	protected String physicianId;
	private String caseRecordType;
	
	public SCM_MD_ClosureLetForMD_ACTE_RA(String caseID, String argLookupId) {
	        super(caseID, argLookupId);
	     
	    }
	    
	public override void createMergeFields() {
		 
		  physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
		this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
		 //CaseID
		 this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
		
		 //CR_Phone ( key CR_Phone)
         this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
    
   		 //CR_Fax (key CR_Fax)
   		 this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    
    	 //CR_URL ( key CR_URL)
    	 this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    	 
    	 //DateLong(key DateLong)
    	 this.mergeRecipientInfo.add(new SCM_MF_DateLong());
    	 
    	 //PhysicianFullName(key Physician First Last Name)
         this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
    	 //PhysicianStAddress(key PhysicianStreetAddrs)
         this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
    	 //PhysicianCityStateZip(Key PhyCityStateZip)
         this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.Case_Treating_Physician_gne__c));
        
         //PatientFullName(key Patient_First_And_Last_Name)
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
   
   
   this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
   this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
   this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    	//CaseWorker(Key From)
    	 
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordType.equalsIgnoreCase('C&R - Standard Case')) {
         
         this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
          
          
        }        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) {
        	            
          this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
      
        }
        
        //ConfidNotice
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
	}
	
	
	public override void getLatestValues()
    {
    	

    
    }
    
}