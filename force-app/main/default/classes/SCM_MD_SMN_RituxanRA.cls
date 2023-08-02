//********************************************************************
    // Developer Name    : Reji Joseph
    // Document Name     : RA-CMGT-FAX-38_SMN_Form_FinalAnalysis.doc
    // PRODUCT GROUP     : Rheumatology / Rituxan RA
    // Type              : System Document
    // Word Template     : SMN Form RituxanRA.doc
    // Label in SF       : 
//********************************************************************/ 

public class SCM_MD_SMN_RituxanRA extends SCM_MergeDocument{
    public SCM_MD_SMN_RituxanRA(String caseId, String argLookupId) {
        super(caseId,argLookupId);   
    }
    
    public override void createMergeFields()  {   
        String patientId = selectedCase.Patient_gne__r.Id;
        String caseIdLocal = selectedCase.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        this.mergeRecipientInfo.addall(SCM_MF_PatientFieldFactory.GetAllNames(selectedCase.Patient_gne__c)); 
        this.mergeRecipientInfo.addall(SCM_MF_Physician_FieldFactory.GetAllNames(selectedCase.Case_Treating_Physician_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PatientAddressFactory.GetAll(selectedCase.Patient_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PhysicianAddress_FieldFactory.GetAll(selectedcase.id));
        this.mergeRecipientInfo.addall(SCM_MF_PatientContact_FieldFactory.GetAllNames(selectedCase.Patient_gne__c));
        
        
        //Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient ID (key Patient ID)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        //Phone (key CR_Phone)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //Fax (key CR_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));

        //Fax (key CR_URL)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));

        //PatientLastName(key PatientLastName)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientLastName(patientId));

        //PatientLastName(key PatientFirstName)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(patientId));

        //Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));

		//PatientStAddress2
		this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(patientId));

        //PatientStAddress1 (key
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine1(patientId));

        //PatientCityStateZip 
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(patientId));


this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.City(patientId));
this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.State(patientId));
this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.Zip(patientId));
        //Patient Home Phone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientHomePhone(patientId));
		//-----------------------------------------------------------------------------------------
   		// Male(key chkMale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(patientId));
   		
   		// Female (key chkFemale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(patientId));
        //-----------------------------------------------------------------------------------------
        // Primary Insurance Details
        //-----------------------------------------------------------------------------------------
        // Insurance Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '1'));
        
        // Insurance Phone SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '1'));

        // Subscriber Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '1'));

        // GroupPolicyNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '1'));
        //-----------------------------------------------------------------------------------------
        // Secondary  Insurance Details
        //-----------------------------------------------------------------------------------------
        // Insurance Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '2'));
        
        // Insurance Phone SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '2'));

        // Subscriber Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '2'));

        // GroupNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '2'));
        //-----------------------------------------------------------------------------------------
        //Facility Name
    	this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));
               	
        //Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(physicianId));
this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstName(physicianId));        
this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_City(SelectedCase.Id));        
this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_State(SelectedCase.Id));
this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Zip(SelectedCase.Id));          
        
        
        //Physician Phone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)); 

        //Physician Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));

        //Physician StAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //Physician DEA#
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //Physician License ID
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //Physician Tax ID
    	this.mergeRecipientInfo.add(new SCM_MF_PhysicianProfileTax(selectedCase.Case_Treating_Physician_gne__r.Id));
    	
        // ProviderNPI
        this.mergeRecipientInfo.add(new SCM_MF_ProviderNPINew(selectedCase.Case_Treating_Physician_gne__r.Id));
    }
}