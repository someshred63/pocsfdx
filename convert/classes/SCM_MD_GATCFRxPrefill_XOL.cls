/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : XOL-CMGT-FAX-53_GATCF_Rx_Prefill.DOC
    // PRODUCT GROUP     : Respiratory / Xolair
    // Type				 : System Document
    // Word Template     : GATCFRxPrefill_XOL   
    // Label in SF       : GATCF Rx Prefill XOL 
    
/********************************************************************/
    
public class SCM_MD_GATCFRxPrefill_XOL extends SCM_MergeDocument {
	public SCM_MD_GATCFRxPrefill_XOL (String caseId, String argLookupId) {
		super(caseID, argLookupId);
		caseId = caseID;
	} 
	 
	public override void createMergeFields() {
		String patientNumber = selectedCase.patient_gne__r.id;
		String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
					
		//0. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
		
		//1. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		
		//2. XOL GATCF Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
	
		//3. CaseWorker
        String recordType = selectedCase.RecordType.Name ;
        
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(SelectedCase));
        //4. XOL URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
		
		//5. PatientFullName('Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientNumber));
        
        //6. Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientNumber));
        
    	//7. Physician Full Name ('Physician First Last Name')
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        		
		// 8. PhysicianStAddress('PhysicianStreetAddrs')
		this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
            	 
    	// 9. PhysicianCityStateZip('PhyCityStateZip')
    	this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //10. Physician Contact Phone('PhysContactPh')  
		this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
		this.mergeRecipientInfo.add(new SCM_MF_XolairPlus(SelectedCase.Product_gne__c));

  		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
		//11. PhysicianDEA ('Physician DEA')
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
	} 

}