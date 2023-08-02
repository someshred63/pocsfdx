/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : XOL-CMGT-FAX-36_Second_Level_Appeal_FinalAnalysis.doc
    // Product           : Respiratory/Xolair
    // Type              : Fax Coversheet
    // Word Template     : XOL-CMGT-FAX-36_Second_Level_Appeal.doc  
    // Label in SF       : 
    
/********************************************************************/
public class SCM_MD_FAX_SecondLevelAppeal_Xol extends SCM_MergeDocument implements IStandardComboBox{
    
    //Sections
    private SCM_MergeSection UIXOLReviewingAppealLevel;
    private SCM_MergeSection UIXOLFaxDenialLetter;
    private SCM_MergeSection UIAddionalDocAppeal;
    
    //Check Boxes
    private SCM_MergeFieldCheckbox ReviewingAppealLevelChk;
    private SCM_MergeFieldCheckbox FaxDenialLetterChk;
    private SCM_MergeFieldCheckbox Checkbox7;
    private SCM_MergeFieldCheckbox Checkbox8;
    private SCM_MergeFieldCheckbox Checkbox9;
    private SCM_MergeFieldCheckbox Checkbox10;
    private SCM_MergeFieldCheckbox Checkbox11;
    private SCM_MergeFieldCheckbox Checkbox12;
    private SCM_MergeFieldCheckbox Checkbox13;
    private SCM_MergeFieldCheckbox Checkbox14;
    private SCM_MergeFieldCheckbox Checkbox15;
    
    //Text Boxes 
    private SCM_MergeField UIOtherDoc4;
    private SCM_MergeField UIOtherDoc5;
    private SCM_MergeField UIOtherDoc6;
    private SCM_MergeField UIOtherDoc7;
    private SCM_MergeField UIOtherDoc8;
    private SCM_MergeField UIOtherDoc9;
    private SCM_MergeField UIOtherDoc10;
    private SCM_MergeField UIOtherDoc11;
    private SCM_MergeField UIOtherDoc12;

    //Appeal Level combo box
    private SCM_MergeField mfAppealLevel;
    private SCM_MergeField AppealLevel;
    
    public SCM_MD_FAX_SecondLevelAppeal_Xol(String caseID, String argLookupId) {
            super(caseID, argLookupId);
           
    }

    public override void createMergeFields() {
        
        String recordType = selectedCase.RecordType.Name;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientId = selectedCase.patient_gne__r.Id;
        
        //Attn
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //Recname
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));       
        
        //Recfax
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

        //Case ID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR FAX
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //CR URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
        
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));

        // Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));

        // ConfidNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //===========================Second Screen UI=======================================================
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Documentation: ';
        docu.headerText = 'The Payor will continue the medical review upon receipt of the following additional document(s): ';       
        docu.key = 'Documentation';
        
        SCM_MergeFieldGroup referedTo = new SCM_MergeFieldGroup();
        referedTo.label = 'Refered To';
        referedTo.headerText = 'Refered To: ';       
        referedTo.key = 'referedTo';
        
        //MS - Fax Denial Letter
        UIXOLFaxDenialLetter = new SCM_MergeSection();        
        UIXOLFaxDenialLetter.key = 'UI_XOL_FaxDenialLetter';
        this.mergeSections.add(UIXOLFaxDenialLetter);

        //MS - Addional Doc Appeal
        UIAddionalDocAppeal = new SCM_MergeSection();        
        UIAddionalDocAppeal.key = 'UI_AddionalDocAppeal';
        this.mergeSections.add(UIAddionalDocAppeal);
        
        //MS - Reviewing Appeal Level        
        UIXOLReviewingAppealLevel = new SCM_MergeSection();        
        UIXOLReviewingAppealLevel.key = 'UI_XOL_ReviewingAppealLevel';
        this.mergeSections.add(UIXOLReviewingAppealLevel);

        //MS - Appeal Level
        AppealLevel = new SCM_MergeField();
        AppealLevel.key = 'AppealLevel';
        AppealLevel.FieldValue = '';
        AppealLevel.displayCheck = false;
        AppealLevel.displayTextbox = false;
        AppealLevel.isRequired = false;
        this.mergeRecipientInfo.add(AppealLevel);

        //populate Appeal Level Combo Box
        
        ReviewingAppealLevelChk = 
                new SCM_MergeFieldCheckbox('UI_XOL_ReviewingAppealLevel', 'Access Solutions is reviewing the case for');        
        ReviewingAppealLevelChk.fieldValue = '';
        ReviewingAppealLevelChk.width = '17';
        ReviewingAppealLevelChk.totalWidth = '260';
        ReviewingAppealLevelChk.isNewLine = false;
        referedTo.subFields.add(ReviewingAppealLevelChk);

        mfAppealLevel = new SCM_MergeField();
        mfAppealLevel.displayCheck = false;      
        mfAppealLevel.displayDropDown = true;
        mfAppealLevel.displayTextBox = false; 
        mfAppealLevel.displayLabel = false;
        mfAppealLevel.isRequired = false;
        mfAppealLevel.isNewLine = false;
        mfAppealLevel.totalWidth = '50'; 
        mfAppealLevel.setControlStyle('width:50px'); 
        
        mfAppealLevel.selectionItems.add(new SelectOption(' ',' '));
        mfAppealLevel.selectionItems.add(new SelectOption('1st','1st'));
        mfAppealLevel.selectionItems.add(new SelectOption('2nd','2nd'));
        mfAppealLevel.selectionItems.add(new SelectOption('3rd','3rd'));
        mfAppealLevel.selectionItems.add(new SelectOption('4th','4th'));
        mfAppealLevel.selectionItems.add(new SelectOption('5th','5th'));

        mfAppealLevel.setSelectionItems(mfAppealLevel.selectionItems);
        referedTo.subFields.add(mfAppealLevel);
        
        SCM_MergeField labelend = new SCM_MergeField();
        labelend.displayCheck = false;       
        labelend.displayDropDown = false;
        labelend.displayTextBox = false; 
        labelend.displayLabel = true;
        labelend.isRequired = false;
        labelend.isNewLine = false;
        labelend.totalWidth = '120';
        labelend.setControlStyle('width:100px;vertical-align:bottom');
        labelend.label = 'level appeal';
        
        referedTo.subFields.add(labelend);
        
        FaxDenialLetterChk = 
                new SCM_MergeFieldCheckbox('UI_XOL_FaxDenialLetter', 'Please fax the denial letter to Access Solutions');       
        FaxDenialLetterChk.fieldValue = '';
        FaxDenialLetterChk.totalWidth = '400';
        FaxDenialLetterChk.isNewLine = true;
        referedTo.subFields.add(FaxDenialLetterChk);
        
        SCM_MergeFieldCheckbox Checkbox1 = 
                new SCM_MergeFieldCheckbox('UI_XOL_SMN', 'SMN(Completed and signed)');      
        Checkbox1.fieldValue = 'SMN(Completed and signed) \r\n';
        Checkbox1.totalWidth = '600';
        Checkbox1.isNewLine = true;
        docu.subFields.add(Checkbox1);

        SCM_MergeFieldCheckbox Checkbox2 = 
                new SCM_MergeFieldCheckbox('UI_XOL_InitialHistoryPhysical', 'Initial History/Physical');        
        Checkbox2.fieldValue = 'Initial History/Physical \r\n';
        Checkbox2.totalWidth = '600';
        Checkbox2.isNewLine = true;
        docu.subFields.add(Checkbox2);

        SCM_MergeFieldCheckbox Checkbox3 = 
                new SCM_MergeFieldCheckbox('UI_SkinAllergyTestResults', 'Skin/Allergy Test Results');       
        Checkbox3.fieldValue = 'Skin/Allergy Test Results \r\n';
        Checkbox3.totalWidth = '600';
        Checkbox3.isNewLine = true;
        docu.subFields.add(Checkbox3);

        SCM_MergeFieldCheckbox Checkbox4 = 
                new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');      
        Checkbox4.fieldValue = 'Prescription \r\n';
        Checkbox4.totalWidth = '600';
        Checkbox4.isNewLine = true;
        docu.subFields.add(Checkbox4);

        SCM_MergeFieldCheckbox Checkbox5 = 
                new SCM_MergeFieldCheckbox('UI_PrioAuthForm', 'Prior Authorization Form');      
        Checkbox5.fieldValue = 'Prior Authorization Form (signed & completed) \r\n';
        Checkbox5.totalWidth = '600';
        Checkbox5.isNewLine = true;
        docu.subFields.add(Checkbox5);

        SCM_MergeFieldCheckbox Checkbox6 = 
                new SCM_MergeFieldCheckbox('UI_PatientAuthorizationNotification', 'Patient Authorization Notification');        
        Checkbox6.fieldValue = 'Patient Authorization Notification \r\n';
        Checkbox6.totalWidth = '600';
        Checkbox6.isNewLine = true;
        docu.subFields.add(Checkbox6);

        Checkbox7 = 
                new SCM_MergeFieldCheckbox('UI_XOL_TreatmentPlan', 'Xolair Treatment Plan');        
        Checkbox7.fieldValue = 'Xolair Treatment Plan: ';
        Checkbox7.totalWidth = '230';
        Checkbox7.isNewLine = true;
        docu.subFields.add(Checkbox7);
        
        UIOtherDoc4 = new SCM_MF_OtherDocuments('UI_OtherDoc4', '');
        UIOtherDoc4.isNewLine = false;
        UIOtherDoc4.totalWidth = '270';
        docu.subFields.add(UIOtherDoc4);
        
        Checkbox8 = 
                new SCM_MergeFieldCheckbox('UI_ProgressNotes', 'Progress Notes');       
        Checkbox8.fieldValue = 'Progress Notes: ';
        Checkbox8.totalWidth = '230';
        Checkbox8.isNewLine = true;
        docu.subFields.add(Checkbox8);

        UIOtherDoc5 = new SCM_MF_OtherDocuments('UI_OtherDoc5', '');
        UIOtherDoc5.isNewLine = false;
        UIOtherDoc5.totalWidth = '270';
        docu.subFields.add(UIOtherDoc5);

        Checkbox9 = 
                new SCM_MergeFieldCheckbox('UI_XOL_PulmonaryFunctionTests', 'Pulmonary Function Tests');        
        Checkbox9.fieldValue = 'Pulmonary Function Tests: ';
        Checkbox9.totalWidth = '230';
        Checkbox9.isNewLine = true;
        docu.subFields.add(Checkbox9);

        UIOtherDoc6 = new SCM_MF_OtherDocuments('UI_OtherDoc6', '');
        UIOtherDoc6.isNewLine = false;
        UIOtherDoc6.totalWidth = '270';
        docu.subFields.add(UIOtherDoc6);

        Checkbox10 = 
                new SCM_MergeFieldCheckbox('UI_HospitalAdmissionNotesER', 'Hospital Admission Notes/ER Notes');     
        Checkbox10.fieldValue = 'Hospital Admission Notes/ER Notes: ';
        Checkbox10.totalWidth = '230';
        Checkbox10.isNewLine = true;
        docu.subFields.add(Checkbox10);

        UIOtherDoc7 = new SCM_MF_OtherDocuments('UI_OtherDoc7', '');
        UIOtherDoc7.isNewLine = false;
        UIOtherDoc7.totalWidth = '270';
        docu.subFields.add(UIOtherDoc7);

        Checkbox11 = 
                new SCM_MergeFieldCheckbox('UI_IgELevelsReports', 'IgE Levels/Reports');
        Checkbox11.fieldValue = 'IgE Levels/Reports: ';
        Checkbox11.totalWidth = '230';
        Checkbox11.isNewLine = true;
        docu.subFields.add(Checkbox11);

        UIOtherDoc8 = new SCM_MF_OtherDocuments('UI_OtherDoc8', '');
        UIOtherDoc8.isNewLine = false;
        UIOtherDoc8.totalWidth = '270';
        docu.subFields.add(UIOtherDoc8);

        Checkbox12 = 
                new SCM_MergeFieldCheckbox('UI_DenialLetter', 'Denial Letter(s)');
        Checkbox12.fieldValue = 'Denial Letter(s): ';
        Checkbox12.totalWidth = '230';
        Checkbox12.isNewLine = true;
        docu.subFields.add(Checkbox12);

        UIOtherDoc9 = new SCM_MF_OtherDocuments('UI_OtherDoc9', '');
        UIOtherDoc9.isNewLine = false;
        UIOtherDoc9.totalWidth = '270';
        docu.subFields.add(UIOtherDoc9);
        
        Checkbox13 = 
                new SCM_MergeFieldCheckbox('UI_AppealLetter', 'Appeal Letter(s)');
        Checkbox13.fieldValue = 'Appeal Letter(s): ';
        Checkbox13.totalWidth = '230';
        Checkbox13.isNewLine = true;
        docu.subFields.add(Checkbox13);

        UIOtherDoc10 = new SCM_MF_OtherDocuments('UI_OtherDoc10', '');
        UIOtherDoc10.isNewLine = false;
        UIOtherDoc10.totalWidth = '270';
        docu.subFields.add(UIOtherDoc10);

        Checkbox14 = 
                new SCM_MergeFieldCheckbox('UI_ExpOfBenefits', 'Explanation of Benefits (EOB)');
        Checkbox14.fieldValue = 'Explanation of Benefits (EOB): ';
        Checkbox14.totalWidth = '230';
        Checkbox14.isNewLine = true;
        docu.subFields.add(Checkbox14);

        UIOtherDoc11 = new SCM_MF_OtherDocuments('UI_OtherDoc11', '');
        UIOtherDoc11.isNewLine = false;
        UIOtherDoc11.totalWidth = '270';
        
        docu.subFields.add(UIOtherDoc11);

        Checkbox15 = 
                new SCM_MergeFieldCheckbox('UI_Claims', 'Claims');
        Checkbox15.fieldValue = 'Claims: ';
        Checkbox15.totalWidth = '230';
        Checkbox15.isNewLine = true;
        docu.subFields.add(Checkbox15);

        UIOtherDoc12 = new SCM_MF_OtherDocuments('UI_OtherDoc12', '');
        UIOtherDoc12.isNewLine = false;
        UIOtherDoc12.totalWidth = '270';
        docu.subFields.add(UIOtherDoc12);

        SCM_MergeField OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1', 'Other Documentations');
        SCM_MergeField OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
        SCM_MergeField OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3', '');
        docu.subFields.add(OtherDoc1);
        docu.subFields.add(OtherDoc2);
        docu.subFields.add(OtherDoc3);

        this.mergeFields.add(docu);
        this.mergeFields.add(referedTo);
       

        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
            
        comments.headerText = 'Comments: ';
        comments.key = 'Comments1';
        CommentField.key = 'Comments';                                  
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);
    }
    
    public override void getLatestValues()
    {
        // Reviewing Appeal Level
        if(ReviewingAppealLevelChk.checked == false)
        {
            UIXOLReviewingAppealLevel.visible = false;
        }
        else
        {
            UIXOLReviewingAppealLevel.visible = true;

            //Merge Appeal Level value 
            if (mfAppealLevel.mergeValue != '' && mfAppealLevel.mergeValue != null)
            {
                AppealLevel.mergeValue = mfAppealLevel.getMergeValue();
            }
            else
                AppealLevel.mergeValue = '0';
        }
        
        // Fax Denial Letter
        if (FaxDenialLetterChk.checked == false)
        {
            UIXOLFaxDenialLetter.visible = false;
        }
        else
        {
            UIXOLFaxDenialLetter.visible = true;
        }
        
        // Addional Doc Appeal - following controls have blank/null values/unchecked 
        if (ReviewingAppealLevelChk.checked == false && FaxDenialLetterChk.checked == false && 
                Checkbox7.checked == false && Checkbox8.checked == false && 
                Checkbox9.checked == false && Checkbox10.checked == false && 
                Checkbox11.checked == false && Checkbox12.checked == false && 
                Checkbox13.checked == false && Checkbox14.checked == false && 
                Checkbox15.checked == false &&
                (UIOtherDoc4.mergeValue == '' || UIOtherDoc4.mergeValue == null) &&
                (UIOtherDoc5.mergeValue == '' || UIOtherDoc5.mergeValue == null) &&
                (UIOtherDoc6.mergeValue == '' || UIOtherDoc6.mergeValue == null) &&
                (UIOtherDoc7.mergeValue == '' || UIOtherDoc7.mergeValue == null) &&
                (UIOtherDoc8.mergeValue == '' || UIOtherDoc8.mergeValue == null) &&
                (UIOtherDoc9.mergeValue == '' || UIOtherDoc9.mergeValue == null) &&
                (UIOtherDoc10.mergeValue == '' || UIOtherDoc10.mergeValue == null) &&
                (UIOtherDoc11.mergeValue == '' || UIOtherDoc11.mergeValue == null) &&
                (UIOtherDoc12.mergeValue == '' || UIOtherDoc12.mergeValue == null))
        {
            UIAddionalDocAppeal.visible = false;
        }
        else
        {
            UIAddionalDocAppeal.visible = true;
        }
    
        // if check boxes are unchecked, corresponding text should be empty as well
        if(Checkbox7.checked == false) UIOtherDoc4.mergeValue = '';
        if(Checkbox8.checked == false) UIOtherDoc5.mergeValue = '';
        if(Checkbox9.checked == false) UIOtherDoc6.mergeValue = '';
        if(Checkbox10.checked == false) UIOtherDoc7.mergeValue = '';
        if(Checkbox11.checked == false) UIOtherDoc8.mergeValue = '';
        if(Checkbox12.checked == false) UIOtherDoc9.mergeValue = '';
        if(Checkbox13.checked == false) UIOtherDoc10.mergeValue = '';
        if(Checkbox14.checked == false) UIOtherDoc11.mergeValue = '';
        if(Checkbox15.checked == false) UIOtherDoc12.mergeValue = '';
        
        //to avoid extra line or overlapse of the values in merge document
        if ((Checkbox7.checked == true) && (UIOtherDoc4.mergeValue == '' || UIOtherDoc4.mergeValue == null)) UIOtherDoc4.mergeValue = '\r';
        if ((Checkbox8.checked == true) && (UIOtherDoc5.mergeValue == '' || UIOtherDoc5.mergeValue == null)) UIOtherDoc5.mergeValue = '\r';
        if ((Checkbox9.checked == true) && (UIOtherDoc6.mergeValue == '' || UIOtherDoc6.mergeValue == null)) UIOtherDoc6.mergeValue = '\r';
        if ((Checkbox10.checked == true) && (UIOtherDoc7.mergeValue == '' || UIOtherDoc7.mergeValue == null)) UIOtherDoc7.mergeValue = '\r';
        if ((Checkbox11.checked == true) && (UIOtherDoc8.mergeValue == '' || UIOtherDoc8.mergeValue == null)) UIOtherDoc8.mergeValue = '\r';
        if ((Checkbox12.checked == true) && (UIOtherDoc9.mergeValue == '' || UIOtherDoc9.mergeValue == null)) UIOtherDoc9.mergeValue = '\r';
        if ((Checkbox13.checked == true) && (UIOtherDoc10.mergeValue == '' || UIOtherDoc10.mergeValue == null)) UIOtherDoc10.mergeValue = '\r';
        if ((Checkbox14.checked == true) && (UIOtherDoc11.mergeValue == '' || UIOtherDoc11.mergeValue == null)) UIOtherDoc11.mergeValue = '\r';
        if ((Checkbox15.checked == true) && (UIOtherDoc12.mergeValue == '' || UIOtherDoc12.mergeValue == null)) UIOtherDoc12.mergeValue = '\r';
    }    
}