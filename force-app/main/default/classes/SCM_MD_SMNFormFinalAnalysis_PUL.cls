/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : PUL-CMGT-FAX-38_SMN_Form_FinalAnalysis
    // PRODUCT GROUP     : Pulmozyme
    // Type              : System Document
    // Word Template     : 
   
/********************************************************************/    

public class SCM_MD_SMNFormFinalAnalysis_PUL extends SCM_MergeDocument {
    
    protected String patientId;
    protected String physicianId;
    
    public SCM_MD_SMNFormFinalAnalysis_PUL(String caseId, String argLookupId)
    {
        super(caseId,argLookupId);             
    }
    
    public override void createMergeFields()
    { 
        patientId = selectedCase.Patient_gne__r.Id;
        physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
		
		this.mergeRecipientInfo.addall(SCM_MF_PatientFieldFactory.GetAllNames(selectedCase.Patient_gne__c)); 
        this.mergeRecipientInfo.addall(SCM_MF_Physician_FieldFactory.GetAllNames(selectedCase.Case_Treating_Physician_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PatientAddressFactory.GetAll(selectedCase.Patient_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PhysicianAddress_FieldFactory.GetAll(selectedcase.id));
        this.mergeRecipientInfo.addall(SCM_MF_PatientContact_FieldFactory.GetAllNames(selectedCase.Patient_gne__c));
        
		       
        //Case ID (Key Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //CR_Phone ( key CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax (key CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    
        //CR_URL ( key CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
       
        //PatientFirstName (key PatientFirstName)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(patientId));
        
        //PatientLastName (key PatientLastName)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientLastName(patientId));
        
     	//PatientStAddress2
		this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(patientId));
   
        //PatientCityStateZip 
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(patientId));
   
        //PatientHomePhone (key PatientHomePhone)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.Patient_Home_Phone(patientId));
        
        //DOB(key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
    
        //ChkMale (key chkMale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(selectedCase.Patient_gne__c));
         
        //ChkFemale (key chkFemale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(selectedCase.Patient_gne__c));

		// --------- Prime Contact Info
		        
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
    
        
        
        
        //InsuranceNameSMN (key InsuranceNameSMN)
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '1'));
        
        //InsurancePhoneSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '1'));
        
        //SubscriberNameSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '1'));
        
        //SubscriberIDSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '1'));
        
        //GroupNumSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '1'));
        
        //InsuranceEmployerSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '1'));
        
        //2InsuranceNameSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '2'));
        
        //2InsurancePhoneSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '2'));
        
        //2InsSubscriberSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '2'));
        
        //2InsSubscriberIDSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '2'));
        
        //2InsGroupNumSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '2'));
        
        //2InsuranceEmployerSMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '2'));
        
        //PhysicianFullName(key Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        //PhysicianPhone (key PhysContactPh)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)); 
        
        //PhysicianFax (key PhysContactFax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(SelectedCase));
        
        //PhysicianStAddress (key PhysicianStreetAddrs)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //PhysicianCityStateZip (Key PhyCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //PhysicianDEA(key Physician DEA)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId)); 
        
        //PhysicianTaxID (key Physician Tax Id)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.TaxID(physicianId));
        
        //ProviderNPI (key ProviderNPINew)
        this.mergeRecipientInfo.add(new SCM_MF_ProviderNPINew(physicianId));
        
        //FacilityNPI (key FacilityNPI)
        this.mergeRecipientInfo.add(new SCM_MF_FacilityNPI(selectedCase));
        
        //PhysicianLicenceID (key Physician Profile Luncentis)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId));
        
        
        
    }
}