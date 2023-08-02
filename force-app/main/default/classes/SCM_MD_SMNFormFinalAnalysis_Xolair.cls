/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : XOL-CMGT-FAX-38_SMN_Form_FinalAnalysis
    // Type              : System Document
    // Word Template     : SMNFormFinalAnalysis_Xol.doc    
    // Label in SF       : SMN Form 
    
/********************************************************************/

public class SCM_MD_SMNFormFinalAnalysis_Xolair extends SCM_MergeDocument {
    
    protected String patientId;
    protected String patientIdLocal;
    protected String caseIdLocal;
    protected String pid;
    protected String physicianId;
    
    public SCM_MD_SMNFormFinalAnalysis_Xolair(String caseId, String argLookupId)
    {
        super(caseId,argLookupId);             
    }
    
    public override void createMergeFields()
    { 
        patientId = selectedCase.Patient_gne__r.Id;
        patientIdLocal = selectedCase.Patient_gne__r.Id;
        caseIdLocal = selectedCase.Id;
        string pid = selectedCase.Patient_gne__c;
		String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
		String CaseType = selectedCase.RecordType.Name;
		       
        //Case ID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));        
        
         
        this.mergeRecipientInfo.addall(SCM_MF_PatientFieldFactory.GetAllNames(pid)); 
        this.mergeRecipientInfo.addall(SCM_MF_Physician_FieldFactory.GetAllNames(physicianId));
        this.mergeRecipientInfo.addall(SCM_MF_PatientAddressFactory.GetAll(patientId));
        this.mergeRecipientInfo.addall(SCM_MF_PhysicianAddress_FieldFactory.GetAll(selectedcase.id));
        this.mergeRecipientInfo.addall(SCM_MF_PatientContact_FieldFactory.GetAllNames(pid));
        //Patient Home Phone(PatientHomePhone) 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.Patient_Home_Phone(pid));
        
        //Patient Work Phone(PatientWorkPhone) 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientWorkPhone(pid));
        /*
        //Patient StAddress2
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(patientId));

        //Patient City ---PatientCity
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.City(pid));
        
        //Patient State ---PatientState
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.State(pid));
        
        //PatientZip ---PatientZip
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.Zip(pid));
        */
        //PatientPrimeConFullName(PatientPrimeConFullName) 
       // this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(pid));
        
        // PatientPrimeConRelationship ---Relationship(if not merging use SCM_MF_PatientRelationship)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientRelationship(pid));
        
        //PatientPrimeConHmPh ---PatientPrimeConHmPh
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(pid));
        
        //Male
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(pid));
        
        //Female
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(pid));
        
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
        //Insurance Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '1'));
        
        //Insurance Phone SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '1'));

        //Subscriber Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '1'));
        
        // Subsriber ID SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '1'));
        
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
        
        // GroupNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '2'));
        
       
        
        //Physician Phone(Change the key for factory class:PhysContactPh)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)); 
        
        //Physician Fax(Change key:PhysContactFax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(SelectedCase));
        /*
        //Physician StAddress(PhysicianStreetAddrs)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //Physician City
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_City(selectedcase.id));
        
        //Physician State
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_State(physicianId));
        
        //PhysicianZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Zip(physicianId));
        */
        //Physician DEA#(Change key: Physician DEA)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId)); 
        
        // PhysicianTaxID
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.TaxID(physicianId));
        
        //Physician License ID
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId));
        
        // ProviderNPI
        this.mergeRecipientInfo.add(new SCM_MF_ProviderNPINew(selectedCase.Case_Treating_Physician_gne__r.Id));
    }
}