/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : NUT-CMGT-FAX-53_GATCF_Rx_Prefill.doc
    // PRODUCT GROUP     : Growth Hormone / Nutropin
    // Type              : System Document
    // Word Template     :     
    // Label in SF       :  
    
/********************************************************************/
public class SCM_MD_GATCFRxPrefill_Nut  extends SCM_MergeDocument {
          
    public SCM_MD_GATCFRxPrefill_Nut(String caseID, String argLookupId) {
        super(caseID, argLookupId);
        caseId = caseID;
    }
    
    public override void createMergeFields() {
    	 String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
    	// 0 Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        // 1 Patient Number
        //SCM_MF_PatientId patientID = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // 2 GATCF fax
        //key = GATCF_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));          
        
        // 3 GATCF URL
        //key = GATCF_URL
        //SCM_MF_Product_URL_GATCF URL = new SCM_MF_Product_URL_GATCF(selectedCase);
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase)); 
        
        // 4 Product
        //key = Product Name
         this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        /**
        SCM_MF_Product_Name productName = new SCM_MF_Product_Name(selectedCase) ;
        string productNameVal = productName.getFieldValue();
        productName.fieldValue = productNameVal ; 
        this.mergeRecipientInfo.add(productName); 
        */
        
        // 5 Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        //SCM_MF_PatientFirstAndLastName patFullName = new SCM_MF_PatientFirstAndLastName(selectedCase);
        //String patFullNameVal = patFullName.getFieldValue();
        //patFullName.fieldValue = patFullNameVal ;                         
        //this.mergeRecipientInfo.add(patFullName);
        
        // 6  Date Of Birth
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
          
        // 7  PhysicianFullName
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
     
        // 8 PhysicianStAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
       
        // 9 PhysicianCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
     
        //10 PhysicianPhone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
       
        //11 PhysicianDEA
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
     
		// 12 GATCF_Disclaimer		
        this.mergeRecipientInfo.add(new SCM_MF_GATCFDisclaimer());
        
  		// 13 Attn  
  		
  		 String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
           
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
                      
        }  
   
        this.mergeRecipientInfo.add(SCM_MF_MedHistoryFactory.NutropinDrug(selectedCase));
   
        this.mergeRecipientInfo.add(SCM_MF_MedHistoryFactory.NutropinVial(selectedCase));
  
        this.mergeRecipientInfo.add(SCM_MF_MedHistoryFactory.NutropinGive(selectedCase));
        
        this.mergeRecipientInfo.add(SCM_MF_MedHistoryFactory.NutropinDispense(selectedCase));
       
        this.mergeRecipientInfo.add(SCM_MF_MedHistoryFactory.NutropinDispenseRecon(selectedCase));
        
    }
	
}