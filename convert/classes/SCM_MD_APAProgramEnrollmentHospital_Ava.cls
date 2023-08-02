//Added: Paras Sharma
//Document: CMGT-FAX-65 - APA Program Enrollment Form Hospital
//Avastin

public class SCM_MD_APAProgramEnrollmentHospital_Ava extends SCM_MergeDocument{

    protected String caseId;
    
    public SCM_MD_APAProgramEnrollmentHospital_Ava(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
    public override void createMergeFields() {
        // Case Number (CaseID)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        // Adding this getting the details in the metadata
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_PhoneShort
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    
        //CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 

        // Access Solution
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));

        //Patient name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.Id));
    
        //Patient CheckBox Male
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(selectedCase.patient_gne__r.Id));
    
        //Patient CheckBox Female
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(selectedCase.patient_gne__r.Id));
    
        //Patient StAddress2
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientStAddress2(selectedCase.patient_gne__r.Id));
        
        //Patient City
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.City(selectedCase.patient_gne__r.Id));
        
        //Patient State 
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.State(selectedCase.patient_gne__r.Id));
        
        //Patient Zip
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.Zip(selectedCase.patient_gne__r.Id));
        
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.Id));

        //Patient HomePhone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientHomePhone(selectedCase.patient_gne__r.Id));

        //Patient WorkPhone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientWorkPhone(selectedCase.patient_gne__r.Id));
        
        // FacilityName
        this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));

        // PhysicianFirstLastName
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));

        // Office Hours
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficeHours(selectedCase.Address_gne__r.Id));

        // Physician StAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));

        // Physician City
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_City(selectedcase.id));
        
        // Physician State
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_State(selectedcase.id));
        
        // Physician Zip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Zip(selectedcase.id));
        
        // Physician Phone
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianPhone(selectedCase.Case_Treating_Physician_gne__r.Id));
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianPhoneSMN_Luc(selectedCase.Case_Treating_Physician_gne__r.Id, selectedCase.RecordType.Name));
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianPhone(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // Physician Fax
        //this.mergeRecipientInfo.add(new SCM_MF_Physician_Fax(selectedCase.Case_Treating_Physician_gne__r.Id));
        //this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax2(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // PhysicianPhone
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficePhone(selectedCase));
        //this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
        
        // PhysicianFax
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficeFax(selectedCase));
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
        
        // PhysicianContactFullName
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase));
        
        // PhysicianContactPhone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
        
        //ICD9 Code
        this.mergeRecipientInfo.add(new SCM_MF_PrimaryICD9Code(selectedCase.Id));
        
        //ICD9Descriptio
        this.mergeRecipientInfo.add(new SCM_MF_ICD9Description(selectedCase.Id));
        
        // TNMIIIB
        this.mergeRecipientInfo.add(new SCM_MF_TNMIIIB(selectedCase.Medical_History_gne__r.Id));

        // TNMIIIC
        this.mergeRecipientInfo.add(new SCM_MF_TNMIIIC(selectedCase.Medical_History_gne__r.Id));

        // TNMIV
        this.mergeRecipientInfo.add(new SCM_MF_TNMIV(selectedCase.Medical_History_gne__r.Id));
        
        //HER2StatusN
        this.mergeRecipientInfo.add(new SCM_MF_HER2StatusN(selectedCase));
        
        //HER2StatusP
        this.mergeRecipientInfo.add(new SCM_MF_HER2StatusP(selectedCase));
    }
}