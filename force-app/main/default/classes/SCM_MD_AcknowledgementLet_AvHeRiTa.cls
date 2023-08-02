/**************************************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : Consolidate BioOncology CMGT-FAX-41 Acknowledgement Letter
    // Type              : System Document
    // Word Template     : CMGT-FAX-41_Acknowledgement Letter_AvHeRiTa.doc    
    // Label in SF       : Consolidate BioOncology Acknowledgement Letter
    
/*************************************************************************************/


public class SCM_MD_AcknowledgementLet_AvHeRiTa extends SCM_MergeDocument{
    
      private String caseRecordType; 
      public SCM_MD_AcknowledgementLet_AvHeRiTa(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }        
       public override void createMergeFields() 
    {
          
        String caseRecordType = selectedCase.RecordType.Name;
        String referredByType = selectedCase.Referred_By_Type_gne__c;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c;  
        String patientId = selectedCase.Patient_gne__r.Id;
        String medicalHistory = selectedCase.Medical_History_gne__r.Id;
        string pid = selectedCase.Patient_gne__c;
         
        //0. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //1. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
          
        //2.  CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //3.  CR Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //4.  CR URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));  

        //5. Dateshort
        //this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());     
		this.mergeRecipientInfo.add(new SCM_MF_DateLong());
	
        //6 Refferal Office
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralOffice(selectedCase));
        
        // 7 ReferralAttn 
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralAttn(selectedCase));  
            
        //8 Refferal Street Address
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralStAddress(selectedCase));  
            
        //9 ReferralSuiteF1Unit
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralSuiteFlUnit(selectedCase));
       
         //10 ReferralCityStateZip 
         this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralCityStateZip(selectedCase));
         //Referral ACKN Phone
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralPhone(Selectedcase));
		
		//Referral ACKN Fax
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralFax(Selectedcase));
        //11 PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );

        //12 Case Worker
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordType.equalsIgnoreCase('C&R - Standard Case')) {
         
         this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));     
        }        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) {        	            
          this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
      
        }
       		//Product
		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(Selectedcase));

		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(Selectedcase));
       
  }
}