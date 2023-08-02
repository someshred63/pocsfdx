/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : AVA-CMGT-FAX-65 APA Program Enrollment Form final
    // Type              : System Document
    // Word Template     : CMGT-FAX-65ProgramEnrollmentForm.doc    
    // Label in SF       : Program Enrollment Form 
    
/********************************************************************/
public class SCM_MD_ProgramEnrollmentForm_Ava extends SCM_MergeDocument{
	 
	 public SCM_MD_ProgramEnrollmentForm_Ava(String caseId, String argLookupId)
    {
        super(caseId,argLookupId);             
    }
    public override void createMergeFields()
    { 
        
        
        string CaseType = selectedCase.RecordType.Name;
        String caseRecordType = selectedCase.RecordType.Name;
        String referredByType = selectedCase.Referred_By_Type_gne__c;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c;  
        String patientId = selectedCase.Patient_gne__r.Id;
        String medicalHistory = selectedCase.Medical_History_gne__r.Id;
        string pid = selectedCase.Patient_gne__c;
        
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        // 1  Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
            
        // 2 CR_Phone Avastin(CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // 3 CR_Fax Avastin(CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // 4 GATCF_URL Avastin(GATCF_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase)); 
   
        // 5 Patient Full Name(Patient_First_And_Last_Name)
       this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
       
        // 6 ChkMale(Patient Male)
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(pid) );
         
        // 7 Chkfemale(Patient Female) 
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(pid) );
         
        // 8 PatientStAddress2(PatientStAddress2)
        this.mergeRecipientInfo.add(new SCM_MF_PatientAddress(patientId));
        
        // 9 PatientCityStateZip(Patient City State and Zip)
        this.mergeRecipientInfo.add(new SCM_MF_PatientCityStateZip(patientId));
   
        // 10 DOB(Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
   
        // 11 PatientHomePhone(PatientHomePhone)
       this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientHomePhone(pid));
        
        //12 PatientWorkPhone(PatientWorkPhone)
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientWorkPhone(pid));
        
		// 13 Facility Name(FacilityName)
        this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));
       
        // 14 PhysicianFullName()
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // 15 PhysicianDEA(Physician DEA) 
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
		
		// 16 PhysicianLicenseID(Physician Profile Luncentis)(key:Physician Profile Luncentis)
		//this.mergeRecipientInfo.add(new SCM_MF_PhysicianProfileLicenceID(selectedCase.Case_Treating_Physician_gne__r.Id));//key:PhysicianLicenceID
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId));
		
 		
 		// 17 PhysicianOfficeHours(PhysicianOfficeHours)
		this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficeHours(selectedCase.Address_gne__r.Id));
		
		// 18 PhysicianStAddress(PhysicianStAddress)
		//this.mergeRecipientInfo.add(new SCM_MF_PhysicianStAddress1(selectedCase.Address_gne__r.Id));
		 this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
	
		
		// 19 PhysicianCityStateZip(Physician City State and Zip)(key:PhyCityStateZip)
		this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
		//this.mergeRecipientInfo.add(new SCM_MF_PhysicianCityStateZip('', selectedCase.Address_gne__r.Id));
		
		// 20 PhysicianPhone(Phy_Ph)
		this.mergeRecipientInfo.add(new SCM_MF_PhysicianPhoneSMN_Luc(selectedCase.Case_Treating_Physician_gne__r.Id, CaseType));
	    //this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
	
		// 21 PhysicianFax
		//this.mergeRecipientInfo.add(new SCM_MF_PhysicianContact_Fax(selectedCase));
		this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
		
        // 22 PhysContactFullName(PhysContactFullName)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(SelectedCase));
         //this.mergeRecipientInfo.add(new SCM_MF_PhysicianContact_FullName(selectedCase));
        
        // 23 PhysContactPh(PhysContactPh)
         this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));

        // 24 ICD9Code(Primary ICD9 Code)
        this.mergeRecipientInfo.add(new SCM_MF_PrimaryICD9Code(selectedCase.Id));
        
        // 25 ICD9Descrptn(Primary ICD9 Desc)
        this.mergeRecipientInfo.add(new SCM_MF_ICD9Description(selectedCase.Id));
        
		// 26 TNMIIIB
		this.mergeRecipientInfo.add(new SCM_MF_TNMIIIB(selectedCase.Medical_History_gne__r.Id));

		// 27 TNMIIIC
		this.mergeRecipientInfo.add(new SCM_MF_TNMIIIC(selectedCase.Medical_History_gne__r.Id));

		// 28 TNMIV
		this.mergeRecipientInfo.add(new SCM_MF_TNMIV(selectedCase.Medical_History_gne__r.Id));

		// 29 POAPhysician
		this.mergeRecipientInfo.add(new SCM_MF_POAPhysician(selectedCase.Medical_History_gne__r.Id));

		// 30 PoAHospOut
		this.mergeRecipientInfo.add(new SCM_MF_PoAHospOut(selectedCase.Medical_History_gne__r.Id));

		// 31 POAHospIn
		this.mergeRecipientInfo.add(new SCM_MF_POAHospIn(selectedCase.Medical_History_gne__r.Id));
		
		   this.mergeRecipientInfo.add(new SCM_MF_HER2StatusN(SelectedCase));
   			this.mergeRecipientInfo.add(new SCM_MF_HER2StatusP(SelectedCase));       
          
    }
}