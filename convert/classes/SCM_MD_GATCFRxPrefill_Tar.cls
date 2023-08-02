/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : TAR-CMGT-FAX-53_GATCF_Rx_Prefill.doc
    // PRODUCT GROUP     : Oncology / Tarceva
    // Type              : System Document
    // Word Template     : CMGT-FAX-53_GATCF_Rx_Prefill_Tar.doc    
    // Label in SF       : GATCF Rx Prefill 
    
/********************************************************************/
public class SCM_MD_GATCFRxPrefill_Tar extends SCM_MergeDocument {
     
    private String caseRecordType;      
    public SCM_MD_GATCFRxPrefill_Tar(String caseID, String argLookupId) {
        super(caseID, argLookupId);     
    }
    
    public override void createMergeFields() {
    	 String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
    	// 0 Case Number
    	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));         
        // 1 Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        // 2 GATCF phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));        
        
        
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
        //3 CaseWorker        
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordType.equalsIgnoreCase('C&R - Standard Case')) {
         
         	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) {
        	            
          this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
      
        }
        // 4 GATCF URL
        //key = GATCF_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));         
        
        // 5 Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
	             
        // 6  Date Of Birth
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
	      
        // 7  PhysicianFullName
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        // 8 PhysicianStAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id)); // (Key:'PhysicianStAddress' )	   
   
        // 9 PhysicianCityStateZip
         this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));

        
        // 23 PhysContactPh(PhysContactPh)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));

		      
         // 15 PhysicianDEA(Physician DEA) 
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
                 	
    }
}