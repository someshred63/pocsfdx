/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : CMGT-FAX-40_GATCF_SMN_Form_FinalAnalysis.doc
    // Product           : Oncology / Avastin, Herceptin, Rituxan, Tarceva
    // Type              : System Document
    // Word Template     : CMGT_FAX40_GATCF_SMNForm_AvaHerRitTar.doc 
    // Label in SF       : GATCF SMN Form
    
/********************************************************************/

public class SCM_MD_GATCF_SMNForm_AvaHerRitTar extends SCM_MergeDocument{

    protected String caseId;
    
    
    public SCM_MD_GATCF_SMNForm_AvaHerRitTar(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
    public override void createMergeFields() {
        
            String caseRecordType = selectedCase.RecordType.Name;
            String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
            String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
            String productName = selectedCase.Product_gne__c; 
          	string patientID = selectedCase.Patient_gne__r.Id;
          String  errorMessage = '';

		this.mergeRecipientInfo.addall(SCM_MF_PatientFieldFactory.GetAllNames(selectedCase.Patient_gne__c)); 
        this.mergeRecipientInfo.addall(SCM_MF_Physician_FieldFactory.GetAllNames(selectedCase.Case_Treating_Physician_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PatientAddressFactory.GetAll(selectedCase.Patient_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PhysicianAddress_FieldFactory.GetAll(selectedcase.id));
        this.mergeRecipientInfo.addall(SCM_MF_PatientContact_FieldFactory.GetAllNames(selectedCase.Patient_gne__c));
        
          try {
            //0. Case Number
            this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_CaseNumber(selectedCase)'; } try {
            //1. Patient Id
            this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_PatientId(selectedCase)'; } try {
            //2. GATCF_Phone
            this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_Product_Phone_GATCF(selectedCase)'; } try {
            //3. GATCF_Fax
            this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_Product_Fax_GATCF(selectedCase)'; } try {
            //4. GATCF_URL
            this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_Product_URL_GATCF(selectedCase)'; } try {
            //5. PatientFullName
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id)'; } try {
            //6. PatientStAddress2
            //this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine2(selectedCase.Patient_gne__r.Id)); // [Key: 'PatientAddress']         
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PatientAddressFactory.PatientAddressLine2(selectedCase.Patient_gne__r.Id)'; } try {
            //PatientStAddress2
            this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(selectedCase.Patient_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PatientAddressFactory.PatientStAddress2(selectedCase.Patient_gne__r.Id)'; } try {
            //7. PatientCityStateZip        
            this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(selectedCase.Patient_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PatientAddressFactory.PatientCityStateZip(selectedCase.Patient_gne__r.Id)'; } try {
            //8. DOB
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
            // ---------------------
            //9 & 10. ChkMale & ChkFemale
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id)'; } try {
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(selectedCase.Patient_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(selectedCase.Patient_gne__r.Id)'; } try {
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(selectedCase.Patient_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(selectedCase.Patient_gne__r.Id)'; } try {
            //11. PatientHomePhone
            this.mergeRecipientInfo.add(new SCM_MF_Patient_HomePhone(selectedCase.Patient_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_Patient_HomePhone(selectedCase.Patient_gne__r.Id)'; } try {
            //12. FacilityName
            this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_FacilityName(selectedCase)'; } try {
            //13. PhysicianFullName (Key: 'Physician First Last Name')
            this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName_Invisible(physicianId));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName_Invisible(physicianId)'; } try {
            //14. PhysicianDEA
            this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId)'; } try {
            //15. PhysicianLicenseID
            this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId)'; } try {
            //16. PhysicianStAddress
            //this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedCase.Case_Treating_Physician_gne__r.Id)); // (Key:'PhysicianStAddress' )
            //this.mergeRecipientInfo.add(new SCM_MF_PhysicianStAddress(selectedCase.id)); //(Key: 'Physician Street Address')
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedCase.Case_Treating_Physician_gne__r.Id)'; } try {
            //17. PhysicianCityStateZip
            this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedCase.Case_Treating_Physician_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedCase.Case_Treating_Physician_gne__r.Id)'; } try {
            //18. PhysicianPhone
            this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)'; } try {
            //19. PhysicianFax
            this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
          } catch (Exception ex) {  errorMessage += ' SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase)'; } try {
            //Avastin, Herceptin, Rituxan, Tarceva
            // Commented by Manjunath Nilagiri as per the changes in the requirement -- Ticket#507. 
           // this.mergeRecipientInfo.add(new SCM_MF_ChkAvastin(selectedCase.Medical_History_gne__r.Id));
           // this.mergeRecipientInfo.add(new SCM_MF_ChkHerceptin(selectedCase.Medical_History_gne__r.Id));
           // this.mergeRecipientInfo.add(new SCM_MF_ChkRituxan(selectedCase.Medical_History_gne__r.Id));
          //  this.mergeRecipientInfo.add(new SCM_MF_ChkTarceva(selectedCase.Medical_History_gne__r.Id));

            // ICD9Code
            this.mergeRecipientInfo.add(new SCM_MF_PrimaryICD9Code(selectedCase.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_PrimaryICD9Code(selectedCase.Id)'; } try {
            // ICD9Descrptn
            this.mergeRecipientInfo.add(new SCM_MF_ICD9Description(selectedCase.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ICD9Description(selectedCase.Id)'; } try {
            // 2ICD9Code
            this.mergeRecipientInfo.add(new SCM_MF_2ICD9Code(selectedCase.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_2ICD9Code(selectedCase.Id)'; } try {
            // 2ICD9Descrptn
            this.mergeRecipientInfo.add(new SCM_MF_2ICD9Description(selectedCase.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_2ICD9Description(selectedCase.Id)'; } try {
            // DateofDX
            this.mergeRecipientInfo.add(new SCM_MF_DateOfDiagnosis(selectedCase.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_DateOfDiagnosis(selectedCase.Id)'; } try {
            // Height
            this.mergeRecipientInfo.add(new SCM_MF_PatHeight(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_PatHeight(selectedCase.Medical_History_gne__r.Id)'; } try {
            // Weight
            this.mergeRecipientInfo.add(new SCM_MF_PatWeight(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_PatWeight(selectedCase.Medical_History_gne__r.Id)'; } try {
            // PoAPhysician, PoAHospOut, PoAHospIn
            this.mergeRecipientInfo.add(new SCM_MF_POAPhysician(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_POAPhysician(selectedCase.Medical_History_gne__r.Id)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_PoAHospOut(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_PoAHospOut(selectedCase.Medical_History_gne__r.Id)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_POAHospIn(selectedCase.Medical_History_gne__r.Id)); 
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_POAHospIn(selectedCase.Medical_History_gne__r.Id)'; } try {
            // TreatStartY, TreatStartN
            this.mergeRecipientInfo.add(new SCM_MF_ChkTreatStartY(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkTreatStartY(selectedCase.Medical_History_gne__r.Id)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_ChkTreatStartN(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkTreatStartN(selectedCase.Medical_History_gne__r.Id)'; } try {
            // DateFirstTreatment
            this.mergeRecipientInfo.add(new SCM_MF_MedHistoryFrstYearDateOfFrstTreat(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_MedHistoryFrstYearDateOfFrstTreat(selectedCase.Medical_History_gne__r.Id)'; } try {
            // NumDosesPlanned
            this.mergeRecipientInfo.add(new SCM_MF_NumberOfDoses(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_NumberOfDoses(selectedCase.Medical_History_gne__r.Id)'; } try {
            // Dose
            this.mergeRecipientInfo.add(new SCM_MF_Dose(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_Dose(selectedCase.Medical_History_gne__r.Id)'; } try {
            // FrequencyAdmin
            this.mergeRecipientInfo.add(new SCM_MF_FrequencyOfAdmin(selectedCase.Medical_History_gne__r.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_FrequencyOfAdmin(selectedCase.Medical_History_gne__r.Id)'; } try {
            // PatientDeceasedY, PatientDeceasedN
            this.mergeRecipientInfo.add(new SCM_MF_PatientDeceasedY(selectedCase.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_PatientDeceasedY(selectedCase.Id)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_PatientDeceasedN(selectedCase.Id));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_PatientDeceasedN(selectedCase.Id)'; } try {
            // HER2StatusN, HER2StatusP
            this.mergeRecipientInfo.add(new SCM_MF_ChkHER2StatusN(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkHER2StatusN(selectedCase)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_ChkHER2StatusP(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkHER2StatusP(selectedCase)'; } try {
            // HER2TestMDakoIHC, HER2TestMOtherIHC, HER2TestMFISH
            this.mergeRecipientInfo.add(new SCM_MF_ChkHER2TestMDako(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkHER2TestMDako(selectedCase)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_ChkHER2TestMOther(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkHER2TestMOther(selectedCase)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_ChkHER2TestMFISH(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkHER2TestMFISH(selectedCase)'; } try {
            // AdjuvantYes, AdjuvantNo
            this.mergeRecipientInfo.add(new SCM_MF_ChkAdjuvantYes(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkAdjuvantYes(selectedCase)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_ChkAdjuvantNo(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkAdjuvantNo(selectedCase)'; } try {
            // NewStart, ContinuedTherapy
            this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkNewStart(selectedCase)'; } try {
            this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase));
          } catch (Exception ex) {  errorMessage += ' new SCM_MF_ChkContTherapy(selectedCase)'; }
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

        
        //Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
		 this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_City(selectedcase.id));
		 this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_State(selectedcase.id));
		 this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Zip(selectedcase.id));
		 this.mergeRecipientInfo.add(new SCM_MF_PhysicianProfileLicenceID(selectedcase.Case_Treating_Physician_gne__c));
		 this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '1'));
		 this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '2'));
		 
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
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.TNMI(selectedCase));
		
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
		//PTHormone
		this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PTHormone(selectedCase));
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
		//pat city
		this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.City(patientId));
		//pat state
		this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.State(patientId));
		//pat zip
		this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.Zip(patientId));
		//pat first name
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(patientId));
		//pat Last name
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientLastName(patientId));
		//pat cell
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientCellPhone(patientId));
		 //10 Patient Prime Contact FullName(PatientPrimeConFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(patientId)); 
                     
        //11 Patient Prime Contact Home Phone(Pat_Home_Ph)   
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(patientId));    
            
        //12 Patient Prime contact Work Phone(Pat_Work_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(patientId));
		//Relationship
		 this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientRelationship(patientId));
		
		
          if (errorMessage != '')
          {
             // SCM_LogError.sendEmail('Error in SCM_MD_GATCF_SMNForm_AvaHerRitTar', 'Error(s):' + errorMessage , true);
          }
    }
}