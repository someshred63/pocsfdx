/********************************************************************/
    // Developer Name    : Deeppak Yadav
    // Document Name     : NUTR-CMGT-FAX-38_SMN_Form_FinalAnalysis_Pediatric.doc
    // PRODUCT GROUP     : Growth Hormone / Nutropin
    // Type              : System Document
    // Word Template     : SMN_Form_Pediatric_Nut.doc    
    // Label in SF       : SMN Form Pediatric 
    
/********************************************************************/
public class SCM_MD_SMNFormPediatric_Nut extends SCM_MergeDocument {	  
	
	public SCM_MD_SMNFormPediatric_Nut(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }        
    public override void createMergeFields() {
        String patientId = selectedCase.Patient_gne__r.Id;
        String caseIdLocal = selectedCase.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        this.mergeRecipientInfo.addall(SCM_MF_PatientFieldFactory.GetAllNames(selectedCase.Patient_gne__c)); 
        this.mergeRecipientInfo.addall(SCM_MF_Physician_FieldFactory.GetAllNames(selectedCase.Case_Treating_Physician_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PatientAddressFactory.GetAll(selectedCase.Patient_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PhysicianAddress_FieldFactory.GetAll(selectedcase.id));
        this.mergeRecipientInfo.addall(SCM_MF_PatientContact_FieldFactory.GetAllNames(selectedCase.Patient_gne__c));
        
        
        //Case Number (CaseID) (key Case Number)j
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient ID (key Patient ID)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        //Phone (key CR_Phone)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //Fax (key CR_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));

        //Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));

		//PatientStAddress2
		this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(patientId));
    	
    	String CaseType = selectedCase.RecordType.Name;

        //PatientCityStateZip 
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(patientId));
		
		// PatientSSN
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientSSN(patientId));
		
   		// Male(key chkMale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(patientId));
   		
   		// Female (key chkFemale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(patientId));
	    
         // PatientPrimeConRelationship (key Relationship)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientRelationship(patientId));
        
        // PatientPrimeConFullName (key PatientPrimeConFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(patientId));
		
        // PatientPrimeConHmPh (key Pat_Home_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(patientId));

        // PatientPrimeConWkPh (key Pat_Work_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(patientId));
        
        // PatientPrimeConOthPh (key Pat_Other_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientOtherPhone(patientId));
        
        // Insurance Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '1'));
        
        // Insurance Phone SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '1'));

        // Subscriber Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '1'));
        
        // Subsriber ID SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '1'));
		
        // Insurance Employer SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '1'));

        // GroupPolicyNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '1'));
		
        // Insurance Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '2'));
        
        // Insurance Phone SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '2'));

        // Subscriber Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '2'));
        
        // Subsriber ID SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '2'));

        // Insurance Employer SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '2'));

        // GroupNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '2'));
		
		//NewStart, ContinuedTherapy, Restart
		this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase, true));
		this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase, true));
		this.mergeRecipientInfo.add(new SCM_MF_ChkRestart(selectedCase, true));
        
        // ICD9Code
        this.mergeRecipientInfo.add(new SCM_MF_PrimaryICD9Code(selectedCase.Id));
		
		// GHStimTestDate (Key: 'GHStimTestDate')
		this.mergeRecipientInfo.add(new SCM_MF_GHStimTestDate(selectedCase.Medical_History_gne__r.id));
		
		// Agent (Key: 'Agent')
		this.mergeRecipientInfo.add(new SCM_MF_MedHistory_Agent(selectedCase.Medical_History_gne__r.id));
		
		// PeakValue (Key: 'PeakValue')
		this.mergeRecipientInfo.add(new SCM_MF_MedHistory_PeakValue(selectedCase.Medical_History_gne__r.id));
		
    	//2GHStimTestDate
    	this.mergeRecipientInfo.add(new SCM_MF_SecondGHStimTestDate(selectedCase.Medical_History_gne__r.id));
    	
    	//2Agent
    	this.mergeRecipientInfo.add(new SCM_MF_SecondAgent(selectedCase.Medical_History_gne__r.id));
		   	
		//2PeakValue
		this.mergeRecipientInfo.add(new SCM_MF_MedHistorySecondPeakValue(selectedCase.Medical_History_gne__r.id));
				 
    	//DateTherapyInit
    	this.mergeRecipientInfo.add(new SCM_MF_MedHistoryDateTherapyInit(selectedCase.Medical_History_gne__r.id));
    	
        //Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        //Physician DEA#
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
        
        //Physician StAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //Physician Phone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)); 

        //Physician Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
        
        // PhysicianTaxID
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.TaxID(physicianId));
        
        //Physician License ID
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId));
        
        // ProviderNPI
        this.mergeRecipientInfo.add(new SCM_MF_ProviderNPINew(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // FacilityNPI
        this.mergeRecipientInfo.add(new SCM_MF_FacilityNPI(selectedCase));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(patientId));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientLastName(patientId));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.State(patientId));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.Zip(patientId));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.City(patientId));
        
        
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(patientId));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeworkPh(patientId));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConLastName(patientId));
        
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFirstName(patientId));
        
       
        
        
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(physicianId));
        
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstName(physicianId));
        
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_City(selectedcase.id));
        
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_State(selectedcase.id));
        
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Zip(selectedcase.id));
        
        
        
        
    }
}