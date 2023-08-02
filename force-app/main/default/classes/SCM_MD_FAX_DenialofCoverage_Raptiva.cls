/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : RAP-CMGT-FAX-12_Denial_of_Coverage.doc
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type              : Fax Coversheet
    // Word Template     : Denial of Coverage Raptiva.doc
    // Label in SF       : 
/********************************************************************/
    
public class SCM_MD_FAX_DenialofCoverage_Raptiva extends SCM_MergeDocument implements IStandardComboBox{
    
    private SCM_MergeSection UI_Additional_Docs;
    private SCM_MergeSection UI_RAP_FaxReqDocs;
    
    //only checkboxes
    private SCM_MergeFieldCheckbox UI_SMNComplete;
    private SCM_MergeFieldCheckbox UI_HistoryPhysical;
    private SCM_MergeFieldCheckbox UI_TreatmentPlan;
    private SCM_MergeFieldCheckbox UI_OfficeVisitNotes;
    private SCM_MergeFieldCheckbox UI_PCPReferral;
    private SCM_MergeFieldCheckbox UI_PrioAuthForm;
    private SCM_MergeFieldCheckbox UI_Prescription;
    private SCM_MergeFieldCheckbox UI_PatAuthNoticeRelInfo;
    private SCM_MergeFieldCheckbox UI_BodySurfaceArea;
    private SCM_MergeFieldCheckbox UI_PriorTreatment;
    private SCM_MergeFieldCheckbox UI_PASIScore;
    private SCM_MergeFieldCheckbox UI_QualityLifeSurvey;

    private SCM_MergeFieldCheckbox UI_RAP_AppealSpecialist;
    private SCM_MergeFieldCheckbox UI_RAP_ReferredtoAppeals;
    private SCM_MergeFieldCheckbox UI_RAP_PatientDiscussion;

    //checkbox+textbox
    private SCM_MergeFieldCheckbox UI_OtherDoc1;

    //only textboxes
    private SCM_MF_OtherDocuments  OtherDoc1;
    
    public SCM_MD_FAX_DenialofCoverage_Raptiva (String caseId, String argLookupId) {
        super(caseId, argLookupId);
    } 

    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // Patient ID (key Patient ID)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        //-------------------------------------------------------------------------------------------       
        // CR Phone (key CR_Phone_Short)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        // CR Fax (key CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR URL (key CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        //-------------------------------------------------------------------------------------------
        // Product Name (key Drug)
        this.mergeFields.add(new SCM_MF_Product_DrugName(selectedCase));
        //-------------------------------------------------------------------------------------------
        // PrivacyNotice (key PrivacyNotice)
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
        
        // Confidentiality Notice (key ConfidNotice)
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));

        // Denial Reason (key DenialReason)
        this.mergeFields.add(new SCM_MF_BI_DenialReason(selectedCase.Id));
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
        // Second Page
        //-------------------------------------------------------------------------------------------
        //  Additional Information Required:
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'The following document(s) are required';
        docu.headerText = 'Medical Information:';
        //docu.displayLabel = true;       
        //docu.headerText = 'The Payor will continue the medical review upon receipt of the following additional document(s):';
        docu.key = 'Documentation';
        
        //-------------------------------------------------------------------------------------------
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
        //-------------------------------------------------------------------------------------------
        // 1. SMN (attached)
        UI_SMNComplete = new SCM_MergeFieldCheckbox('UI_SMNComplete', 'SMN (attached)');       
        UI_SMNComplete.fieldValue = 'SMN (attached) \r\n';
        UI_SMNComplete.totalWidth = '600';
        UI_SMNComplete.isNewLine = true;     
        docu.subFields.add(UI_SMNComplete);

        //-------------------------------------------------------------------------------------------
        // 2. History & Physical 
        UI_HistoryPhysical = new SCM_MergeFieldCheckbox('UI_HistoryPhysical', 'History & Physical');
        UI_HistoryPhysical.fieldValue = 'History & Physical \r\n';
        UI_HistoryPhysical.totalWidth = '600';        
        UI_HistoryPhysical.isNewLine = true;
        docu.subFields.add(UI_HistoryPhysical);
        
        //-------------------------------------------------------------------------------------------
        // 3. Treatment Plan
        UI_TreatmentPlan = new SCM_MergeFieldCheckbox('UI_TreatmentPlan', 'Treatment Plan');          
        UI_TreatmentPlan.fieldValue = 'Treatment Plan \r\n';       
        UI_TreatmentPlan.totalWidth = '600';
        UI_TreatmentPlan.isNewLine = true;
        docu.subFields.add(UI_TreatmentPlan);

        //-------------------------------------------------------------------------------------------
        // 4. Office Visit Notes
        UI_OfficeVisitNotes = new SCM_MergeFieldCheckbox('UI_OfficeVisitNotes', 'Office Visit Notes');          
        UI_OfficeVisitNotes.fieldValue = 'Office Visit Notes \r\n';       
        UI_OfficeVisitNotes.totalWidth = '600';
        UI_OfficeVisitNotes.isNewLine = true;
        docu.subFields.add(UI_OfficeVisitNotes);
       
        //-------------------------------------------------------------------------------------------
        // 5. PCP Referral    
        UI_PCPReferral = new SCM_MergeFieldCheckbox('UI_PCPReferral', 'PCP Referral');          
        UI_PCPReferral.fieldValue = 'PCP Referral \r\n ';       
        UI_PCPReferral.totalWidth = '600';
        UI_PCPReferral.isNewLine = true;
        docu.subFields.add(UI_PCPReferral);
        
        //-------------------------------------------------------------------------------------------
        // 6. Prior Authorization Form       
        UI_PrioAuthForm = new SCM_MergeFieldCheckbox('UI_PrioAuthForms', 'Prior Authorization Form (attached) ');         
        UI_PrioAuthForm.fieldValue = 'Prior Authorization Form (attached)\r\n';     
        UI_PrioAuthForm.totalWidth = '600';
        UI_PrioAuthForm.isNewLine = true;
        docu.subFields.add(UI_PrioAuthForm);
        
        //-------------------------------------------------------------------------------------------
        // 7. Prescription
        UI_Prescription = new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');            
        UI_Prescription.fieldValue = 'Prescription \r\n';      
        UI_Prescription.totalWidth = '600';
        UI_Prescription.isNewLine = true;
        docu.subFields.add(UI_Prescription);
        
        //-------------------------------------------------------------------------------------------
        // 8. Patient Authorization Notice of Release of Information
        UI_PatAuthNoticeRelInfo = new SCM_MergeFieldCheckbox('UI_PatAuthNoticeRelInfo', 'Patient Authorization Notice of Release of Information (PAN)');         
        UI_PatAuthNoticeRelInfo.fieldValue = 'Patient Authorization Notice of Release of Information (PAN) \r\n';      
        UI_PatAuthNoticeRelInfo.totalWidth = '600';
        UI_PatAuthNoticeRelInfo.isNewLine = true;
        docu.subFields.add(UI_PatAuthNoticeRelInfo);
        
        //-------------------------------------------------------------------------------------------
        // 9. Body Surface Area (BSA)
        UI_BodySurfaceArea = new SCM_MergeFieldCheckbox('UI_BodySurfaceArea', 'Body Surface Area (BSA)');         
        UI_BodySurfaceArea.fieldValue = 'Body Surface Area (BSA) \r\n';      
        UI_BodySurfaceArea.totalWidth = '600';
        docu.subFields.add(UI_BodySurfaceArea);

        //-------------------------------------------------------------------------------------------
        // 10. Prior Treatment
        UI_PriorTreatment = new SCM_MergeFieldCheckbox('UI_PriorTreatment', 'Prior Treatment(s)');         
        UI_PriorTreatment.fieldValue = 'Prior Treatment(s) \r\n ';      
        UI_PriorTreatment.totalWidth = '600';
        UI_PriorTreatment.isNewLine = true;
        docu.subFields.add(UI_PriorTreatment);
        
        //-------------------------------------------------------------------------------------------
        // 11. PASI Score
        UI_PASIScore = new SCM_MergeFieldCheckbox('UI_PASIScore', 'PASI Score');         
        UI_PASIScore.fieldValue = 'PASI Score \r\n';      
        UI_PASIScore.totalWidth = '600';
        UI_PASIScore.isNewLine = true;
        docu.subFields.add(UI_PASIScore);
        
        //-------------------------------------------------------------------------------------------
        //  12. Quality of Life Survey
        UI_QualityLifeSurvey = new SCM_MergeFieldCheckbox('UI_QualityLifeSurvey', 'Quality of Life Survey');         
        UI_QualityLifeSurvey.fieldValue = 'Quality of Life Survey \r\n';      
        UI_QualityLifeSurvey.totalWidth = '600';
        UI_QualityLifeSurvey.isNewLine = true;
        docu.subFields.add(UI_QualityLifeSurvey);
        
        //-------------------------------------------------------------------------------------------
        // 13. Other
        UI_OtherDoc1 = new SCM_MergeFieldCheckbox('UI_OtherDoc1', 'Other: ');         
        UI_OtherDoc1.fieldValue = 'Other: ';      
        UI_OtherDoc1.totalWidth = '60';
        UI_OtherDoc1.isNewLine = true; 
        docu.subFields.add(UI_OtherDoc1);

        OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1_Txt', '');
        OtherDoc1.isNewLine = false;
        OtherDoc1.width = '250';
        OtherDoc1.totalWidth = '270';
        docu.subFields.add(OtherDoc1);
        
        //-------------------------------------------------------------------------------------------
        this.mergeFields.add(docu);
        //-------------------------------------------------------------------------------------------
        
        SCM_MergeFieldGroup docu1 = new SCM_MergeFieldGroup();
        docu1.label = 'The following document(s) are required';
        docu1.headerText = 'Form Information:';
        //docu.displayLabel = true;       
        //docu.headerText = 'The Payor will continue the medical review upon receipt of the following additional document(s):';
        docu1.key = 'Documentation';
        
        //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        UI_RAP_FaxReqDocs = new SCM_MergeSection();        
        UI_RAP_FaxReqDocs.key = 'UI_RAP_FaxReqDocs';
        this.mergeSections.add(UI_RAP_FaxReqDocs);
/**
        //-------------------------------------------------------------------------------------------
        //  1. ??Please fax the above requested document(s) to RAPTIVA Access Solutions @ (866) 481-7762
        UI_RAP_FaxReqDocs = new SCM_MergeFieldCheckbox('UI_RAP_FaxReqDocs', 'Please fax the above requested document(s) to RAPTIVA Access Solutions @ (866) 481-7762');         
        UI_RAP_FaxReqDocs.fieldValue = '??Please fax the above requested document(s) to RAPTIVA Access Solutions @ (866) 481-7762 \r\n';      
        UI_RAP_FaxReqDocs.totalWidth = '700';
        docu1.subFields.add(UI_RAP_FaxReqDocs);
*/
        //-------------------------------------------------------------------------------------------
        //  1. The case has been referred to our Appeal Specialist for review
        UI_RAP_AppealSpecialist = new SCM_MergeFieldCheckbox('UI_RAP_AppealSpecialist', 'The case has been referred to our Appeal Specialist for review');         
        UI_RAP_AppealSpecialist.fieldValue = 'The case has been referred to our Appeal Specialist for review. \r\n';      
        UI_RAP_AppealSpecialist.totalWidth = '600';
        UI_RAP_AppealSpecialist.isNewLine = true;
        docu1.subFields.add(UI_RAP_AppealSpecialist);

        //-------------------------------------------------------------------------------------------
        //  2. Access Solutions will inform the patient of the denial and of the referral to Appeals for review.
        UI_RAP_ReferredtoAppeals = new SCM_MergeFieldCheckbox('UI_RAP_ReferredtoAppeals', 'Access Solutions will inform the patient of the denial and of the referral to Appeals for review.');         
        UI_RAP_ReferredtoAppeals.fieldValue = 'Access Solutions will inform the patient of the denial and of the referral to Appeals for review. \r\n';      
        UI_RAP_ReferredtoAppeals.totalWidth = '600';
        UI_RAP_ReferredtoAppeals.isNewLine = true;
        docu1.subFields.add(UI_RAP_ReferredtoAppeals);

        //-------------------------------------------------------------------------------------------
        //  3. Access Solutions will discuss the denial with the patient.
        UI_RAP_PatientDiscussion = new SCM_MergeFieldCheckbox('UI_RAP_PatientDiscussion', 'Access Solutions will discuss the denial with the patient.');         
        UI_RAP_PatientDiscussion.fieldValue = 'Access Solutions will discuss the denial with the patient. \r\n';      
        UI_RAP_PatientDiscussion.totalWidth = '600';
        UI_RAP_PatientDiscussion.isNewLine = true;
        docu1.subFields.add(UI_RAP_PatientDiscussion);
        
        //-------------------------------------------------------------------------------------------
        this.mergeFields.add(docu1);
        //-------------------------------------------------------------------------------------------
        //  Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
    
    public override void getLatestValues()
    {    
        if  (  UI_SMNComplete.checked == false 
            && UI_HistoryPhysical.checked == false 
            && UI_TreatmentPlan.checked == false 
            && UI_OfficeVisitNotes.checked == false 
            && UI_PCPReferral.checked == false
            && UI_PrioAuthForm.checked == false 
            && UI_Prescription.checked == false
            && UI_PatAuthNoticeRelInfo.checked == false
            && UI_BodySurfaceArea.checked == false
            && UI_PriorTreatment.checked == false 
            && UI_PASIScore.checked == false 
            && UI_QualityLifeSurvey.checked == false 
            && UI_OtherDoc1.checked == false ) 
            {
                UI_Additional_Docs.visible = false;
            }
            else
            {
                UI_Additional_Docs.visible = true;
            }

            if (UI_OtherDoc1.checked==false)
            {
                    OtherDoc1.mergeValue = '';
                    //UI_Additional_Docs.visible = false;
            }
           // else
           // {
           //     UI_Additional_Docs.visible = true;
           // }
                          
            
        if  (  UI_RAP_AppealSpecialist.checked == false 
            && UI_RAP_ReferredtoAppeals.checked == false 
            && UI_RAP_PatientDiscussion.checked == false ) 
            {
                UI_RAP_FaxReqDocs.visible = false;
            }
            else
            {
                UI_RAP_FaxReqDocs.visible = true;
            }
    }
    
}