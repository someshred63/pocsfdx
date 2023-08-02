/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : AVST-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis.DOC
    // Type              : Fax Coversheet
    // PRODUCT GROUP     : Avastin
    // Word Template     : ReqForAddInfoFinalAnalysis_Avastin.doc    
    // Label in SF       : Request for Additional Information
    
/********************************************************************/
public class SCM_MD_Fax_ReqForAddInfo_AVST extends SCM_MergeDocument implements IStandardComboBox {
    private SCM_MergeSection UI_Additional_DocsList;
    
    private SCM_MergeFieldCheckbox UiBIOInitialHistoryPhysicalChk;
    private SCM_MergeFieldCheckbox UiPathologyReportsChk;
    private SCM_MergeFieldCheckbox UiTreatmentPlanChk;
    private SCM_MergeFieldCheckbox UiPriorTreatmentsChk;
    private SCM_MergeFieldCheckbox UiPhysicianNotesChk;
    private SCM_MergeFieldCheckbox UiCTScansChk;
    private SCM_MergeFieldCheckbox UiInfusionsRecordsChk;
    private SCM_MergeFieldCheckbox UiEKGMUCHAECHOChk;
    private SCM_MergeFieldCheckbox UiClinicalTumorStageChk;
    private SCM_MergeFieldCheckbox UiMetastaticSitesChk;
    private SCM_MergeFieldCheckbox UiExpOfBenefitsChk;
    private SCM_MergeFieldCheckbox UiDenialLetterChk;
    private SCM_MergeFieldCheckbox UiPatientAuthoNoticeReleaseInfoChk;
    private SCM_MergeField OtherDoc1;
    private SCM_MergeField OtherDoc2;
    private SCM_MergeField OtherDoc3;
    private SCM_MergeField OtherDoc4;
    private SCM_MergeField OtherDoc5;
    
    
    protected String caseId;
    
    public SCM_MD_Fax_ReqForAddInfo_AVST(String caseId, String argLookupId){
        super(caseID, argLookupId);
        caseId = caseID;
        
    }
    public override void createMergeFields(){
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String caseRecordType = selectedCase.RecordType.Name;
        String productName = selectedCase.Product_gne__c; 
        
        //0. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //1. Addressed To 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //2. Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
       //9 From Ext
        if (caseRecordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (caseRecordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        //5. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //6. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //7. AVST GATCF Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //8. AVST GATCF Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //9. AVST URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        //10. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11.PatientFullName('Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        
        //Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        //14. Drug 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
         
        //15. Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //16. Confidentiality Notice        
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        // -------------UI - Second Screen -------------------
        
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.label = 'Medical Information';
        formInfo.headerText = 'The following document(s) are required';               
        formInfo.key = 'Medical_Info_Reqd';
        
        //Merge Sections        
        UI_Additional_DocsList = new SCM_MergeSection();        
        UI_Additional_DocsList.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_DocsList); 
        
        //Checkboxes
        UiBIOInitialHistoryPhysicalChk = 
            new SCM_MergeFieldCheckbox('UiBIOInitialHistoryPhysicalChk',
                'Initial History and Physical');
        UiBIOInitialHistoryPhysicalChk.fieldValue = 'Initial History and Physical \r\n' ;
        UiBIOInitialHistoryPhysicalChk.isNewLine = false;
        UiBIOInitialHistoryPhysicalChk.totalWidth = '900';
        formInfo.subFields.add(UiBIOInitialHistoryPhysicalChk);
        
        UiPathologyReportsChk = 
            new SCM_MergeFieldCheckbox('UiPathologyReportsChk',
                'Pathology Reports');
        UiPathologyReportsChk.fieldValue = 'Pathology Reports:' ;
        UiPathologyReportsChk.isNewLine = false;                    
        UiPathologyReportsChk.totalWidth = '130';
        formInfo.subFields.add(UiPathologyReportsChk);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1', '');
        OtherDoc1.isNewLine = false;
        OtherDoc1.totalWidth = '270';
        formInfo.subFields.add(OtherDoc1);
        
        UiTreatmentPlanChk = 
            new SCM_MergeFieldCheckbox('UiTreatmentPlanChk',
                'Treatment Plan');
        UiTreatmentPlanChk.fieldValue = 'Treatment Plan \r\n' ;
        UiTreatmentPlanChk.isNewLine = false;                    
        UiTreatmentPlanChk.totalWidth = '900';
        formInfo.subFields.add(UiTreatmentPlanChk);
        
        UiPriorTreatmentsChk = 
            new SCM_MergeFieldCheckbox('UiPriorTreatmentsChk',
                'Prior Treatments');
        UiPriorTreatmentsChk.fieldValue = 'Prior Treatment:' ;
        UiPriorTreatmentsChk.isNewLine = false;                    
        UiPriorTreatmentsChk.totalWidth = '130';
        formInfo.subFields.add(UiPriorTreatmentsChk);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
        OtherDoc2.isNewLine = false;
        OtherDoc2.totalWidth = '270';
        formInfo.subFields.add(OtherDoc2);
        
                
        UiPhysicianNotesChk = 
            new SCM_MergeFieldCheckbox('UiPhysicianNotesChk',
                'Physician Notes');
        UiPhysicianNotesChk.fieldValue = 'Physician Notes:' ;
        UiPhysicianNotesChk.isNewLine = true;                    
        UiPhysicianNotesChk.totalWidth = '130';
        formInfo.subFields.add(UiPhysicianNotesChk);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3', '');
        OtherDoc3.totalWidth = '270';
        OtherDoc3.isNewLine = false;
        formInfo.subFields.add(OtherDoc3);
        
        UiCTScansChk = 
            new SCM_MergeFieldCheckbox('UiCTScansChk',
                'CT Scans');
        UiCTScansChk.fieldValue = 'CT Scans:' ;
        UiCTScansChk.isNewLine = true;                    
        UiCTScansChk.totalWidth = '130';
        formInfo.subFields.add(UiCTScansChk);
        
        OtherDoc4 = new SCM_MF_OtherDocuments('UI_OtherDoc4', '');
        OtherDoc4.isNewLine = false;
        OtherDoc4.totalWidth = '270';
        formInfo.subFields.add(OtherDoc4);
        
        UiInfusionsRecordsChk = 
            new SCM_MergeFieldCheckbox('UiInfusionsRecordsChk',
                'Infusion Records');
        UiInfusionsRecordsChk.fieldValue = 'Infusion Records:' ;
        UiInfusionsRecordsChk.isNewLine = true;                    
        UiInfusionsRecordsChk.totalWidth = '130';
        formInfo.subFields.add(UiInfusionsRecordsChk);
        
        OtherDoc5 = new SCM_MF_OtherDocuments('UI_OtherDoc5', '');
        OtherDoc5.isNewLine = false;
        OtherDoc5.totalWidth = '270';
        formInfo.subFields.add(OtherDoc5);
        
        UiEKGMUCHAECHOChk = 
            new SCM_MergeFieldCheckbox('UiEKGMUCHAECHOChk',
                'EKG/MUGA/ECHO');
        UiEKGMUCHAECHOChk.fieldValue = 'EKG/MUGA/ECHO \r\n' ;
        UiEKGMUCHAECHOChk.isNewLine = false;                    
        UiEKGMUCHAECHOChk.totalWidth = '900';
        formInfo.subFields.add(UiEKGMUCHAECHOChk);
        
        UiClinicalTumorStageChk = 
            new SCM_MergeFieldCheckbox('UiClinicalTumorStageChk',
                'Clinical Tumor Stage');
        UiClinicalTumorStageChk.fieldValue = 'Clinical Tumor Stage \r\n' ;
        UiClinicalTumorStageChk.isNewLine = false;                    
        UiClinicalTumorStageChk.totalWidth = '900';
        formInfo.subFields.add(UiClinicalTumorStageChk);
        
        UiMetastaticSitesChk = 
            new SCM_MergeFieldCheckbox('UiMetastaticSitesChk',
                'Metastatic Sites');
        UiMetastaticSitesChk.fieldValue = 'Metastatic Sites \r\n' ;
        UiMetastaticSitesChk.isNewLine = false;                    
        UiMetastaticSitesChk.totalWidth = '900';
        formInfo.subFields.add(UiMetastaticSitesChk);
        
        UiExpOfBenefitsChk = 
            new SCM_MergeFieldCheckbox('UiExpOfBenefitsChk',
                'Explanation of Benefits (EOB)');
        UiExpOfBenefitsChk.fieldValue = 'Explanation of Benefits (EOB) \r\n' ;
        UiExpOfBenefitsChk.isNewLine = false;                    
        UiExpOfBenefitsChk.totalWidth = '900';
        formInfo.subFields.add(UiExpOfBenefitsChk);
        
        UiDenialLetterChk = 
            new SCM_MergeFieldCheckbox('UiDenialLetterChk',
                'Denial letter(s)');
        UiDenialLetterChk.fieldValue = 'Denial letter(s) \r\n' ;
        UiDenialLetterChk.isNewLine = false;                    
        UiDenialLetterChk.totalWidth = '900';
        formInfo.subFields.add(UiDenialLetterChk);
        
        UiPatientAuthoNoticeReleaseInfoChk = 
            new SCM_MergeFieldCheckbox('UiPatientAuthoNoticeReleaseInfoChk',
                'Genentech Patient Authorization Notice of Release of Information (signed and dated)');
        UiPatientAuthoNoticeReleaseInfoChk.fieldValue = 'Genentech Patient Authorization Notice of Release of Information (signed and dated) \r\n' ;
        UiPatientAuthoNoticeReleaseInfoChk.isNewLine = false;                    
        UiPatientAuthoNoticeReleaseInfoChk.totalWidth = '900';
        formInfo.subFields.add(UiPatientAuthoNoticeReleaseInfoChk);
        
        this.mergeFields.add(formInfo);
        
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
            
        comments.headerText = 'Comments: ';       
        comments.key = 'Comments1';
        CommentField.key = 'Comments';                                  
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);
                    
    } 
    public override void getLatestValues(){
        
        if(UiBIOInitialHistoryPhysicalChk.checked == false && UiPathologyReportsChk.checked == false && UiTreatmentPlanChk.checked == false 
        && UiPriorTreatmentsChk.checked == false && UiPhysicianNotesChk.checked == false && UiCTScansChk.checked == false
        && UiInfusionsRecordsChk.checked == false && UiEKGMUCHAECHOChk.checked == false && UiClinicalTumorStageChk.checked == false
        && UiMetastaticSitesChk.checked == false && UiExpOfBenefitsChk.checked == false && UiDenialLetterChk.checked == false && UiPatientAuthoNoticeReleaseInfoChk.checked == false ){
            UI_Additional_DocsList.visible = false;
        }
        else{
            UI_Additional_DocsList.visible = true;
            }
            
            // if check boxes are unchecked, corresponding text should be empty as well
            if(UiPathologyReportsChk.checked == false)
            OtherDoc1.mergeValue = '';
            if(UiPriorTreatmentsChk.checked == false)
            OtherDoc2.mergeValue = '';
            if(UiPhysicianNotesChk.checked == false)
            OtherDoc3.mergeValue = '';
            if(UiCTScansChk.checked == false)
            OtherDoc4.mergeValue = '';
            if(UiInfusionsRecordsChk.checked == false)
            OtherDoc5.mergeValue = '';
            
            //to avoid extra line or overlapse of the values in merge document
            if ((UiPathologyReportsChk.checked == true) && (OtherDoc1.mergeValue == '' || OtherDoc1.mergeValue == null)) OtherDoc1.mergeValue = '\r';
            if ((UiPriorTreatmentsChk.checked == true) && (OtherDoc2.mergeValue == '' || OtherDoc2.mergeValue == null)) OtherDoc2.mergeValue = '\r';
            if ((UiPhysicianNotesChk.checked == true) && (OtherDoc3.mergeValue == '' || OtherDoc3.mergeValue == null)) OtherDoc3.mergeValue = '\r';
            if ((UiCTScansChk.checked == true) && (OtherDoc4.mergeValue == '' || OtherDoc4.mergeValue == null)) OtherDoc4.mergeValue = '\r';
            if ((UiInfusionsRecordsChk.checked == true) && (OtherDoc5.mergeValue == '' || OtherDoc5.mergeValue == null)) OtherDoc5.mergeValue = '\r';
        }
    }