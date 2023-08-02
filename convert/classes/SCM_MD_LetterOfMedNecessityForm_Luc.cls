/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : LUC-CMGT-FAX-47_Letter_of_Medical_Necessity_Form.doc
    // Type              : System Document
    // Word Template     : Letter_of_Medical_Necessity_Luc.doc    
    // Label in SF       : Letter of Medical Necessity
    
/********************************************************************/

public class SCM_MD_LetterOfMedNecessityForm_Luc extends SCM_MergeDocument{

    protected String caseId;

    public SCM_MD_LetterOfMedNecessityForm_Luc(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }

    public override void createMergeFields() {
        // Date
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());

        // PatientAge
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientAge(selectedCase.Patient_gne__r.Id));
        
        // Gender
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGender(selectedCase.Patient_gne__r.Id));
        
        // DateofDX
        this.mergeRecipientInfo.add(new SCM_MF_DateOfDiagnosis(selectedCase.Id));
        
        // HisHer
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientHisHer(selectedCase.Patient_gne__r.Id));
        
        // PhysicianPhone
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianConatcPhone(selectedCase));
        
        // PhysicianFullName
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.Id));

        // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Id));
        
        SCM_MF_Insurance_Factory.getPA(selectedCase.Id);
        
        // InsuranceName_PA
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNamePA(selectedCase.Id));
        
        // InsuranceConFullName_PA
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceConFullName_PA(selectedCase.Id));
        
        // InsuranceStAddress_PA
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceStAddress_PA(selectedCase.Id));
        
        // InsuranceCityStateZip_PA
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceCityStateZip_PA(selectedCase.Id));
        
        // SubscriberID_PA
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberID_PA(selectedCase.Id));
        
        // GroupNum_PA
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNum_PA(selectedCase.Id));
        
        // PolicyNum_PA 
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.PolicyNum_PA(selectedCase.Id));
                
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
    }
}