/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RAP_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type              : Fax Coversheet
    // Word Template     : Information Documentation Retrieval Raptiva.doc
    // Label in SF       : 
/********************************************************************/
public class SCM_MD_FAX_INFO_DOC_RET_Raptiva extends SCM_MergeDocument implements IStandardComboBox{
    public SCM_MD_FAX_INFO_DOC_RET_Raptiva(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
 
         //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // Patient ID (key Patient ID)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        //-------------------------------------------------------------------------------------------       
        // GATCF Phone (key GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        // GATCF Fax (key GATCF_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        // GATCF URL (key GATCF_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Product Name (key Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        //-------------------------------------------------------------------------------------------
        // PrivacyNotice (key PrivacyNotice)
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
        
        // Confidentiality Notice (key ConfidNotice)
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Current Date (key Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        //-------------------------------------------------------------------------------------------
        // PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));

        // Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        //-------------------------------------------------------------------------------------------
        // First Page
        //-------------------------------------------------------------------------------------------
        // Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));

        // Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));

        // From and EXt (key From & Ext)
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
        //-------------------------------------------------------------------------------------------
        //second page
        //-------------------------------------------------------------------------------------------
        //  Additional Information Required:
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Additional Information Required:';
        docu.headerText = '';       
        //docu.headerText = 'The Payor will continue the medical review upon receipt of the following additional document(s):';
        docu.key = 'Documentation';

        //-------------------------------------------------------------------------------------------
        //  1. Patient Contact Number (alternative)
        SCM_MergeFieldCheckbox Checkbox1 = new SCM_MergeFieldCheckbox('UI_PatientCoPhAlt', 'Patient Contact Number (alternative)');       
        Checkbox1.fieldValue = 'Patient Contact Number (alternative) \r\n';
        Checkbox1.totalWidth = '270';
        docu.subFields.add(Checkbox1);

        //-------------------------------------------------------------------------------------------
        //  2. Physician Signature
        SCM_MergeFieldCheckbox Checkbox2 = new SCM_MergeFieldCheckbox('UI_PhysicianSignature', 'Physician Signature');
        Checkbox2.fieldValue = 'Physician Signature \r\n';
        Checkbox2.totalWidth = '270';        
        docu.subFields.add(Checkbox2);  
        
        //-------------------------------------------------------------------------------------------
        //  3. Date of Physician Signature
        SCM_MergeFieldCheckbox Checkbox3 = new SCM_MergeFieldCheckbox('UI_DatePhysicianSignature', 'Date of Physician Signature');          
        Checkbox3.fieldValue = 'Date of Physician Signature \r\n';       
        Checkbox3.totalWidth = '270';
        docu.subFields.add(Checkbox3);

        //-------------------------------------------------------------------------------------------
        //  4. Patient’s Weight
        SCM_MergeFieldCheckbox Checkbox4 = new SCM_MergeFieldCheckbox('UI_PatientsWeight', 'Patient’s Weight');          
        Checkbox4.fieldValue = 'Patient’s Weight \r\n';       
        Checkbox4.totalWidth = '270';
        docu.subFields.add(Checkbox4);
       
        //-------------------------------------------------------------------------------------------
        //  5. Weekly Dose   
        SCM_MergeFieldCheckbox Checkbox5 = new SCM_MergeFieldCheckbox('UI_WeeklyDose', 'Weekly Dose');          
        Checkbox5.fieldValue = 'Weekly Dose \r\n';       
        Checkbox5.totalWidth = '270';
        docu.subFields.add(Checkbox5);
        
        //-------------------------------------------------------------------------------------------
        //  6.  Dose Prescription Refill     
        SCM_MergeFieldCheckbox Checkbox6 = new SCM_MergeFieldCheckbox('UI_DosePrescriptionRefill', 'Dose Prescription Refill');         
        Checkbox6.fieldValue = 'Dose Prescription Refill \r\n';     
        Checkbox6.totalWidth = '270';
        docu.subFields.add(Checkbox6);
        
        //-------------------------------------------------------------------------------------------
        this.mergeFields.add(docu);
        //-------------------------------------------------------------------------------------------
        
        //  Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
}