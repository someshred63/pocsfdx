/********************************************************************/
    // Developer Name    : Deepti
    // Document Name     : ACT-TNK-CMGT-FAX-38-SMN_Form_FinalAnalysis.doc
    // PRODUCT GROUP     : Activase / Activase, TNKase / TNKase
    // Type      		 : System Document
    // Word Template     : CMGT-FAX38-SMNForm-ActTNK
    // Label in SF       : SMN Form  
    
/********************************************************************/
public class SCM_MD_SMNForm_ActTNK extends SCM_MergeDocument{
	
	public SCM_MD_SMNForm_ActTNK(String caseId, String argLookupId){
        super(caseId, argLookupId);
     }
     
    public override void createMergeFields(){
    	
    	String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
    	
    	this.mergeRecipientInfo.addall(SCM_MF_PatientFieldFactory.GetAllNames(selectedCase.Patient_gne__c)); 
        this.mergeRecipientInfo.addall(SCM_MF_Physician_FieldFactory.GetAllNames(selectedCase.Case_Treating_Physician_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PatientAddressFactory.GetAll(selectedCase.Patient_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PhysicianAddress_FieldFactory.GetAll(selectedcase.id));
        this.mergeRecipientInfo.addall(SCM_MF_PatientContact_FieldFactory.GetAllNames(selectedCase.Patient_gne__c));
        
        //-------------------------------------------------------------------------------------------    
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        //-------------------------------------------------------------------------------------------
       
        // 2 GATCF phone(Key:GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase)); 
        
        // 3 GATCF_Fax(Key:GATCF_Fax)
	    this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
	         
        // 4 Patient Full Name(Key:Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        // 5 PatientStAddress2(Key:Patient AddressLine2)
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(selectedCase.Patient_gne__r.Id));
        
        // 6 PatientCityStateZip(Key:PatientCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(selectedCase.Patient_gne__r.Id));
        
        // 7 DOB(Key:Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        
        // 8 PatientHomePhone(Key:PatientHomePhone)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.Patient_Home_Phone(selectedCase.Patient_gne__r.Id));
        
        // 9 ChkMale(Key:chkMale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(selectedCase.Patient_gne__r.Id));
        
        //10 ChkFemale(Key:chkFemale)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(selectedCase.Patient_gne__r.Id));
        
        //11 FacilityName(Key:FacilityName)
	    this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));
	        
	    //12 PhysicianFullName (Key: 'PhysicianFullName')
	    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName_Invisible(physicianId));
         
        //13 PhysicianDEA(Key:Physician DEA) 
		this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(physicianId));
		
		//14 PhysicianLicenseID(Key:Physician Profile Luncentis)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ProfileLicenceID(physicianId));
        
        //15 PhysicianStAddress(Key:PhysicianStreetAddrs)
	    this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id)); // (Key:'PhysicianStAddress' )
		
		//16 PhysicianCityStateZip(Key:PhyCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
         
        //17 PhysicianPhone(Key:PhysContactPh)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
         
        //18 PhysicianFax(Key:PhysContactFax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
           
        //19 ICD9Code(Key:Primary ICD9 Code)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Code(selectedCase));
	        
	    //20 ICD9Descrptn(Key:Primary ICD9 Desc)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Desc(selectedCase));
	        
	    //21 2ICD9Code(Key:2ICD9 Code)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Code2(selectedCase));
	        
	    //22 2ICD9Descrptn(Key:2ICD9 Desc)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.ICD9Desc2(selectedCase));
	        
	    //23 DateofDX(Key:Date Of Diagnosis)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.DateofDX(selectedCase));
	        
	    //24 Height(Key:Height)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.Height(selectedCase));
	        
	    //25 Weight(Key:Weight)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.Weight(selectedCase));
	        
	    //26, 27, 28 PoAPhysician, PoAHospOut, PoAHospIn(Key : POAPhysician , PoAHospOut , POAHospIn)
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PoAPhysician(selectedCase));
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PoAHospOut(selectedCase));
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.PoAHospIn(selectedCase)); 
	       
	    //29 DateofTreatment
	    this.mergeRecipientInfo.add(SCM_MF_EnrollmentFactory.DateofTreatment(selectedCase));
	 }         
}