//********************************************************************
    // Developer Name    : Reji Joseph
    // Document Name     : RAP-CMGT-FAX-38_SMNForm_FinalAnalysis.doc
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type              : System Document
    // Word Template     : SMN_Form_Raptiva.doc
    // Label in SF       : 
//********************************************************************/ 

public class SCM_MD_SMN_Raptiva extends SCM_MergeDocument{
    public SCM_MD_SMN_Raptiva(String caseId, String argLookupId) {
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

        //PatientStAddress1 (key
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine1(patientId));

        //PatientCityStateZip 
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(patientId));

        //Patient Home Phone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientHomePhone(patientId));

        //Patient Work Phone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientWorkPhone(patientId));

        //SCM_MF_Patient_CellPhone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientCellPhone(patientId));
        
		//-----------------------------------------------------------------------------------------
		// Patient Primary Contact Details
		//-----------------------------------------------------------------------------------------
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
        
        // Subsriber ID SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '1'));

        // Insurance Employer SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '1'));

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
        
        // Subsriber ID SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '2'));

        // Insurance Employer SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '2'));

        // GroupNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '2'));
       	
        //Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        //Physician Phone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)); 

        //Physician Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));

        //Physician StAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //Physician DEA#
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
        
        //Physician License ID
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId));
    }
}