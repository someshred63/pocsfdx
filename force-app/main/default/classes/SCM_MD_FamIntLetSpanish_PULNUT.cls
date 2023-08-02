/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : Consolidated PUL-NUT CMGT-FAX-62 Family Intro Letter Spanish final.doc
    // Type				 : SYSTEM DOCUMENT
    // Word Template     : FamIntLettSpanish_PulNut.doc     
    // Label in SF       : Family Intro Letter Spanish
    
/********************************************************************/

public class SCM_MD_FamIntLetSpanish_PULNUT extends SCM_MergeDocument  {
	
	protected String caseId;
	public SCM_MD_FamIntLetSpanish_PULNUT(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        } 
        public override void createMergeFields() {
        	String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        	String patientNumber = selectedCase.patient_gne__r.id;
        	
        	// CR_Logo(Key 'Logo')
        	this.mergeimages.add(new SCM_MI_Logo(selectedCase));
        	
        	// Case Number
	     	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
	     	
	     	// CR_Fax('CR_Fax')
			this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
		
			// CR_Phone('CR_Phone')
			this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
	        
	        // CR_URL(Key 'CR_URL')
	        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
	        
	        // Date Long
        	this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        	
        	// AgedBasedFullName(Key 'AgeBasedFullName')
        	this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patientNumber));
        	
        	// AgedBasedStAddress(Key 'AgeBasedStAddress')
        	this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patientNumber));
        	
        	//AgedBasedCityStateZip(Key 'AgeBasedCityStateZip')
        	this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patientNumber));
        	
        	//Product(Key 'Product')
        	this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        	
        	// PatientFullName('Patient_First_And_Last_Name')
        	this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientNumber));
        	
        	// PhyscianLastName (key 'Physician Last Name')
        	this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(physicianId));
        	
        	//ProductNameS(Key 'ProductNames_Nut')
        	this.mergeRecipientInfo.add(new SCM_MF_ProductNames_Nutropin(selectedCase, true));
        	
        	//AccessSolutions(Key 'AccessSolutions')
        	this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        	
        	// CaseWorker(key 'caseworker')
		    this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
        	
        	
        }
        
}