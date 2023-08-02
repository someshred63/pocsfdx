/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : RAP-CMGT-FAX-29 NEW REFERRAL
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type              : Fax Coversheet
    // Word Template     : NewReferral_Raptiva.doc   
    // Label in SF       : NewReferral_Raptiva
    
/********************************************************************/

public class SCM_MD_Fax_NewReferral_Raptiva extends SCM_MergeDocument implements IStandardComboBox {
    
    private string recordType;
    private String physicianId;
    private String pid;
    
    private SCM_MergeFieldCheckbox SMNAttachedChk;
    private SCM_MergeFieldCheckbox HistoryChk;
    private SCM_MergeFieldCheckbox TreatmentChk;
    private SCM_MergeFieldCheckbox OfficeNotesChk;
    private SCM_MergeFieldCheckbox PCPReferralChk;
    private SCM_MergeFieldCheckbox PriorAuthFormAttachChk;
    private SCM_MergeFieldCheckbox PrescriptionChk;
    private SCM_MergeFieldCheckbox PANandReleaseofInfo3Chk;
    private SCM_MergeFieldCheckbox BodySurfaceAreaChk;
    private SCM_MergeFieldCheckbox PriorTreatmentChk;
    private SCM_MergeFieldCheckbox PASIScoreIChk;
    private SCM_MergeFieldCheckbox QualityOfLifeSurveyChk;
    private SCM_MergeField Other;

    private SCM_MergeSection DocsRequiredStmntInfo;
    
     public SCM_MD_Fax_NewReferral_Raptiva(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }        
    public override void createMergeFields() {
        
        recordType = selectedCase.RecordType.Name ;
        physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        string pid = selectedCase.Patient_gne__c;
        
        //0. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        //1. Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        //2. Phone Raptiva
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));        
        //3. Fax Raptiva        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));        
        //4. CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));        
        //5. Attn:(ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        //6. Addressed To:(RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        //7. RECFax Number:(RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        //10. Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        //11. Patient Full Name(Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        //12. Patient DOB(Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        //13. Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
        //14. Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));                     
        
        //---------------------------------second page-----------------------------------------//
        // Medical Information       
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.label = 'Medical Information:';
        formInfo.headerText = 'The following document(s) are required ';       
        formInfo.key = 'Medical Information';
        
        //1. UI_DocsRequiredStmnt 
        // Merge Section
        DocsRequiredStmntInfo = new SCM_MergeSection();                 
        DocsRequiredStmntInfo.key = 'DocsRequiredStmnt';
        this.mergeSections.add(DocsRequiredStmntInfo);
        
        // Check Boxes
        //1.1  UI_SMNAttached
        SMNAttachedChk = 
                new SCM_MergeFieldCheckbox('SMNAttached', 'SMN (attached)');       
        SMNAttachedChk.fieldValue = 'SMN (attached) \r\n';
        SMNAttachedChk.totalWidth = '270';
        SMNAttachedChk.isNewLine = true;
        formInfo.subFields.add(SMNAttachedChk);
        
        //1.2  UI_History
        HistoryChk = 
                new SCM_MergeFieldCheckbox('History', 'History & Physical');       
        HistoryChk.fieldValue = 'History & Physical \r\n';
        HistoryChk.totalWidth = '270';
        HistoryChk.isNewLine = false;
        formInfo.subFields.add(HistoryChk);
        
        //1.3  UI_Treatment
        TreatmentChk = 
                new SCM_MergeFieldCheckbox('Treatment', 'Treatment Plan');       
        TreatmentChk.fieldValue = 'Treatment Plan \r\n';
        TreatmentChk.totalWidth = '270';
        TreatmentChk.isNewLine = true;
        formInfo.subFields.add(TreatmentChk);
        
        //1.4  UI_OfficeNotes
        OfficeNotesChk = 
                new SCM_MergeFieldCheckbox('OfficeNotes', 'Office Visit Notes');       
        OfficeNotesChk.fieldValue = 'Office Visit Notes \r\n';
        OfficeNotesChk.totalWidth = '270';
        OfficeNotesChk.isNewLine = false;
        formInfo.subFields.add(OfficeNotesChk);
        
        //1.5  UI_PCPReferral
        PCPReferralChk = 
                new SCM_MergeFieldCheckbox('PCPReferral', 'PCP Referral');       
        PCPReferralChk.fieldValue = 'PCP Referral \r\n';
        PCPReferralChk.totalWidth = '270';
        PCPReferralChk.isNewLine = true;
        formInfo.subFields.add(PCPReferralChk); 
         
        //1.6  UI_PriorAuthFormAttach
        PriorAuthFormAttachChk = 
                new SCM_MergeFieldCheckbox('PriorAuthFormAttach', 'Prior Authorization form (attached)');       
        PriorAuthFormAttachChk.fieldValue = 'Prior Authorization Form (attached) \r\n';
        PriorAuthFormAttachChk.totalWidth = '270';
        PriorAuthFormAttachChk.isNewLine = true;
        formInfo.subFields.add(PriorAuthFormAttachChk);
        
        //1.7  UI_Prescription
        PrescriptionChk = 
                new SCM_MergeFieldCheckbox('Prescription', 'Prescription');       
        PrescriptionChk.fieldValue = 'Prescription \r\n';
        PrescriptionChk.totalWidth = '270';
        PrescriptionChk.isNewLine = true;
        formInfo.subFields.add(PrescriptionChk);
        
          //1.8  UI_PANandReleaseofInfo3
        PANandReleaseofInfo3Chk = 
                new SCM_MergeFieldCheckbox('PANandReleaseofInfo3', 'Patient Authorization Notice of Release of Information (PAN)');       
        
        PANandReleaseofInfo3Chk.totalWidth = '270';        
        PANandReleaseofInfo3Chk.isNewLine = false;
        PANandReleaseofInfo3Chk.displayExtraHTML = true; 
        PANandReleaseofInfo3Chk.extraHTML='Patient Authorization Notice of Release of Information (PAN) \r\n';
        PANandReleaseofInfo3Chk.displayLabel = false; 
        //PANandReleaseofInfo3Chk.fieldValue = 'Patient Authorization Notice of Release of Information \r\n';                                                           
        formInfo.subFields.add(PANandReleaseofInfo3Chk);
               
        //1.9  UI_BodySurfaceArea
        BodySurfaceAreaChk = 
                new SCM_MergeFieldCheckbox('BodySurfaceArea', 'Body Surface Area (BSA)');       
        BodySurfaceAreaChk.fieldValue = 'Body Surface Area \r\n';
        BodySurfaceAreaChk.totalWidth = '270';
        BodySurfaceAreaChk.isNewLine = true;
        formInfo.subFields.add(BodySurfaceAreaChk);
        
        //1.10  UI_PriorTreatment
        PriorTreatmentChk = 
                new SCM_MergeFieldCheckbox('PriorTreatment', 'Prior Treatment(s)');       
        PriorTreatmentChk.fieldValue = 'Prior Treatment(s) \r\n';
        PriorTreatmentChk.totalWidth = '270';
        PriorTreatmentChk.isNewLine = false;
        formInfo.subFields.add(PriorTreatmentChk);
        
        //1.11  UI_PASIScoreI
        PASIScoreIChk = 
                new SCM_MergeFieldCheckbox('PASIScoreI', 'PASI Score');       
        PASIScoreIChk.fieldValue = 'PASI Score \r\n';
        PASIScoreIChk.totalWidth = '270';
        PASIScoreIChk.isNewLine = true;
        formInfo.subFields.add(PASIScoreIChk);
        
        //1.12  UI_QualityOfLifeSurvey
        QualityOfLifeSurveyChk = 
                new SCM_MergeFieldCheckbox('QualityOfLifeSurvey', 'Quality of Life Survey');       
        QualityOfLifeSurveyChk.fieldValue = 'Quality of Life Survey \r\n';
        QualityOfLifeSurveyChk.totalWidth = '270';
        QualityOfLifeSurveyChk.isNewLine = false;
        formInfo.subFields.add(QualityOfLifeSurveyChk);
        
        //1.13  UI_Other
        Other = new SCM_MF_OtherDocuments('UI_Other', 'Other');
        formInfo.subFields.add(Other);
        
        this.mergeFields.add(formInfo);
        
        // Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }                

        public override void getLatestValues()  {
            if  ((SMNAttachedChk.checked == false)&&
                (HistoryChk.checked == false)&&
                (TreatmentChk.checked == false)&&
                (OfficeNotesChk.checked == false)&&
                (PCPReferralChk.checked == false)&&
                (PriorAuthFormAttachChk.checked == false)&&
                (PrescriptionChk.checked == false)&&
                (PANandReleaseofInfo3Chk.checked == false)&&
                (BodySurfaceAreaChk.checked == false)&&
                (PriorTreatmentChk.checked == false)&&
                (PASIScoreIChk.checked == false)&&
                (QualityOfLifeSurveyChk.checked == false) &&
                (Other.getMergeValue() == null || Other.getMergeValue().equals('')))
                {
                    DocsRequiredStmntInfo.visible = false;
                }
            else
            {
                    DocsRequiredStmntInfo.visible = true;
            }   
        
        }
}