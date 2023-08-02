/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : Final TAR-PUL-NUT-RAP-XOL(PT) - CMGT-FAX-51 - GATCF Approval Form.doc
    // PRODUCT GROUP     : Tarceva, Pulmozyme, Nutropin, Raptiva, Xolair(Patient)
    // Type              : System Document
    // Word Template     : GATCF_ApprovalFormPt_TarPulNulRapXol.doc
    // Label in SF       : 
/********************************************************************/

public class SCM_MD_GATCFAprFmPt_TarPulNutRapXol extends SCM_MergeDocument {
    public SCM_MD_GATCFAprFmPt_TarPulNutRapXol(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
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
        this.mergeFields.add(new SCM_MF_Product_DrugName(selectedCase));
        this.mergeFields.add(new SCM_MF_Product_Name(selectedCase));
        //-------------------------------------------------------------------------------------------
        // PrivacyNotice (key PrivacyNotice)
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
        
        // Confidentiality Notice (key ConfidNotice)
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Product Scientific (key ProdScientific)
        this.mergeFields.add(new SCM_MF_Product_ScientificName(selectedCase)); 
        
        // Current Date (key Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        //-------------------------------------------------------------------------------------------
        // PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));

        // Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        //-------------------------------------------------------------------------------------------
        // Age based conditions
        // AgeBasedFullName (key AgeBasedFullName)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(selectedCase.Patient_gne__r.Id));
        
        // AgeBasedStAddress (key AgeBasedStAddress)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(selectedCase.Patient_gne__r.Id));
        
        // AgeBasedCityStateZip (key AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(selectedCase.Patient_gne__r.Id));
       
        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
         
        //Foundation Specialist
        String recordType = selectedCase.RecordType.Name;        
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }       
        
        //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        SCM_MergeField Your = new SCM_MergeField();
        Date dob = Date.newInstance(1900, 1, 1);
        if(selectedCase.Patient_gne__r.pat_dob_gne__c != null){
            dob = selectedCase.Patient_gne__r.pat_dob_gne__c;
        }
        Date current = Date.Today();
        integer monthDiff = dob.monthsBetween(current);
        integer yrs = (monthDiff/12); 
        //-------------------------------------------------------------------------------------------
        string  yourVal = '';
        
        if(yrs >= 18)
        {
            yourVal = 'your';            
            Your.fieldValue = (yourVal == null)?'':yourVal;
            Your.key = 'Your';
            this.mergeRecipientInfo.add(Your);
        }
        else
        {
            SCM_MF_PatientFirstAndLastName Yours = new SCM_MF_PatientFirstAndLastName(selectedCase);
            yourVal = Yours.getFieldValue();            
            Your.fieldValue = (yourVal == null)?'':yourVal + '\'s';
            Your.key = 'Your';
            this.mergeRecipientInfo.add(Your);
        }
        //-------------------------------------------------------------------------------------------
    }
}