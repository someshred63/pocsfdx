//CMGT-Fax-39 Enrollment Form
//Products - Avastin, Herceptin, Rituxan, Tarceva
public class SCM_MD_EnrollmentForm_Onc extends SCM_MergeDocument {

	public SCM_MD_EnrollmentForm_Onc(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
	
	public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String recordType = selectedCase.RecordType.Name;
		
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient Id              
		this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 

        //Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
        
        //PatientStAddress2
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(patientId));
		
		//PatientCityStateZip
		this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(patientId));
		
		//DOB
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
		
		//chkMale
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(patientId));
		
		//chkFemale
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(patientId));
		
		//PatientHomePhone
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientHomePhone(patientId));
		
        //Insurance Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '1'));
        
        //Insurance Phone SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '1'));

        //Subscriber Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '1'));
        
        //Subsriber ID SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '1'));

        //GroupPolicyNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '1'));
		
        //Insurance Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '2'));
        
        //Insurance Phone SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '2'));

        //Subscriber Name SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '2'));
        
        //Subsriber ID SMN
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '2'));

        //GroupNumbSMN
       	this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '2'));

        //ClinicalTrialPatientY
        this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ClinicalTrialPatientY(selectedCase));
        
        //ClinicalTrialPatientN
        this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ClinicalTrialPatientN(selectedCase));

		//StudySite
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.StudySite(selectedCase));
		
		//StudyNum
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.StudyNum(selectedCase));
		
		//ClinicalCoordinator
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ClinicalCoordinator(selectedCase));
		
		//ClinicalCoordPhone
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ClinicalCoordPhone(selectedCase));
		
		//FacilityName
		this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));
		
        //Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        //Physician DEA#
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));

		//Physician Tax Id
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.TaxID(physicianId));
		
        //MedicareNum
        this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MedicareNum(physicianId));
        
        //MedicaidNum
        this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MedicaidNum(physicianId));

        // ProviderNPI
        this.mergeRecipientInfo.add(new SCM_MF_ProviderNPINew(selectedCase.Case_Treating_Physician_gne__r.Id));

		//BlueCrossBlueShieldNum
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.BlueCrossBlueShieldNum(physicianId));
		        
        //Physician StAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));

        //Physician Phone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)); 

        //Physician Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
        
		//ICD9Code
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Code(selectedCase));
		
		//ICD9Desc
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Desc(selectedCase));
		
		//2ICD9Code
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Code2(selectedCase));
		
		//2ICD9Desc
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Desc2(selectedCase));
		
		//DateofDX
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.DateofDx(selectedCase));
		
		//Height
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.Height(selectedCase));
		
		//Weight
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.Weight(selectedCase));
		
		//TNM0
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNM0(selectedCase));
		
		//TNMIIA
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNMIIA(selectedCase));			
		
		//TNMIIB
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNMIIB(selectedCase));
		
		//TNMIIIA
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNMIIIA(selectedCase));
		
		//TNMIIIB
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNMIIIB(selectedCase));
		
		//TNMIIIC
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNMIIIC(selectedCase));
		
		//TNMIV
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNMIV(selectedCase));
		
		//MSAdrenals
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSAdrenals(selectedCase));
		
		//MSBrain
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSBrain(selectedCase));
		
		//MSBone
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSBone(selectedCase));
		
		//MSLiver
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSLiver(selectedCase));
		
		//MSLung
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSLung(selectedCase));
		
		//MSLymph
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSLymph(selectedCase));
		
		//MSOvaries
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSOvaries(selectedCase));
		
		//MSPeritoneal
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.MSPeritoneal(selectedCase));
		
		//PTNone
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTNone(selectedCase));
		
		//PTBoneMT
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTBoneMT(selectedCase));
		
		//PTChemo
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTChemo(selectedCase));
		
		//PTImmuno
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTImmuno(selectedCase));
		
		//PTRadiation
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTRadiation(selectedCase));
		
		//PTOther
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTOther(selectedCase));
		
		//PTOtherText
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTOtherText(selectedCase));
		
		//PTRadioLA
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTRadioLA(selectedCase));
		
		//PTSurgery
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTSurgery(selectedCase));
		
		//PoAPhysician
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PoAPhysician(selectedCase));
		
		//PoAHospOut
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PoAHospOut(selectedCase));
		
		//PoAHospIn
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PoAHospIn(selectedCase));
		
		//TreatStartY
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TreatStartY(selectedCase));
		
		//TreatStartN
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TreatStartN(selectedCase));
		
		//DateFirstTreatment
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.DateFirstTreatment(selectedCase));
		
		//HER2StatusN
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.HER2StatusN(selectedCase));
		
		//HER2StatusP
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.HER2StatusP(selectedCase));
		
		//HER2TestMDakoIHC
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.HER2TestMDakoIHC(selectedCase));
		
		//HER2TestMOtherIHC
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.HER2TestMOtherIHC(selectedCase));
		
		//HER2TestMFISH
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.HER2TestMFISH(selectedCase));
		
		//AdjuvantYes
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.AdjuvantYes(selectedCase));
		
		//AdjuvantNo
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.AdjuvantNo(selectedCase));
		
		//RIT_DiseaseCharLow
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.RIT_DiseaseCharLow(selectedCase));
		
		//RIT_DiseaseCharDiffuse
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.RIT_DiseaseCharDiffuse(selectedCase));
		
		//RIT_DiseaseCharRefractory
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.RIT_DiseaseCharRefractory(selectedCase));
		
		//RIT_DiseaseCharFollicular
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.RIT_DiseaseCharFollicular(selectedCase));
		
		//RIT_DiseaseCharCD20
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.RIT_DiseaseCharCD20(selectedCase));
	}
}