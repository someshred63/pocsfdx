/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : CMGT-FAX-04 GATCF Tab - GATCF Referral for Injection Training.doc
    // Type              : Fax Coversheet
    // Word Template     : CMGT_FAX04_GATCFRefForInjTrain_RapNut.doc   
    // Label in SF       : GATCF Referral For Injection Training 
    
/********************************************************************/


public class SCM_MD_Fax_GATCFRefForInjTra_RapNut extends SCM_MergeDocument{

	public SCM_MD_Fax_GATCFRefForInjTra_RapNut(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
	
	public override void createMergeFields() 
    {
        String caseRecordType = selectedCase.RecordType.Name;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c;  
        String patientId = selectedCase.Patient_gne__r.Id;
        String patient = selectedCase.Patient_gne__c;
        String medicalHistory = selectedCase.Medical_History_gne__r.Id;
        
        //0 Case Number 
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
        
        //1 Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        
        // Product (Key: 'Product')
		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
		
		// ProdScientific (Key: 'ProdScientific')
		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
		
		// Drug (Key: 'Drug')
		this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
		
		// GATCF_Phone (Key: 'GATCF_Phone')
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
		
		// GATCF _Fax (Key: 'GATCF_Fax')
		this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
		
		// GATCF _URL (Key: 'GATCF_URL')
		this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
		
		// Attn
		this.mergeRecipientInfo.add(new SCM_MF_Fax_AttnRefForInjTrain(selectedCase));
		
		// To
		this.mergeRecipientInfo.add(new SCM_MF_Fax_AddrToRefForInjTrain());
		
		// Fax
		this.mergeRecipientInfo.add(new SCM_MF_Fax_FaxRefForInjTrain(selectedCase));
		
		// From 
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
	
        // Extension        
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));  
    
    	// CR_Phone(CR_PhoneShort)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));        
        
		// Dateshort 
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate()); 
        
		// Patient Full Name(Key: 'Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patient) );
        
        // DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patient));
        
        // PrivacyNotice (Key: 'PrivacyNotice')
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        // PatientFullAddress (Key: 'PatientAddressCityStateZip')
        this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(patientId));
        
        // PatientPrimeConFullName('PatientPrimeConFullName')
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(patientId));
        
        // PatientPrimeConRelationship('Relationship')
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientRelationship(patientId));
        
        // PatientPrimeConHmPh ('PatientPrimeConHmPh')
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(patientId));
        
		// PatientPrimeConWkPh('PatientPrimeConWkPh')
		this.mergeRecipientInfo.add(new SCM_MF_PatientPrimeConWkPh(patientId));
		
		//NewStart, ContinuedTherapy, Restart
		this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase, true));
		this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase, true));
		this.mergeRecipientInfo.add(new SCM_MF_ChkRestartTherapy(selectedCase, true));
		
        // PhysicianFullName
	    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
	  	
	  	//SalesRepName(Key:SalesRepName)
        this.mergeRecipientInfo.add(SCM_MF_SalesFieldFactory.SalesRepName(selectedCase));
        
        //SalesRepEmail(Key:SalesRepEmail)
        this.mergeRecipientInfo.add(SCM_MF_SalesFieldFactory.SalesRepEmail(selectedCase));
   
	    /////////-------Second Screen ------
	    this.mergeFields.add(new SCM_MF_Comments());
    }
}