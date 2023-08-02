/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : XOL_CMGT_FAX_12__DENIALOFCOVERAGE.doc
    // PRODUCT GROUP     : Respiratory / Xolair
    // Type              : Fax Coversheet
    // Word Template     : RequestforAdditionalInf.doc    
    // Label in SF       : Request for Additional Information 
    
/********************************************************************/

public class SCM_MD_FAX_DenialOfCoverage_XOL extends SCM_MergeDocument implements IStandardComboBox {
    
    private SCM_MergeSection UI_Additional_Docs;
    private SCM_MergeSection UI_XOL_ExhaustedOptions;   
    private SCM_MergeField UI_Additional_Label; 
    
    private SCM_MergeFieldCheckbox UI_SMNComplete;
    private SCM_MergeFieldCheckbox UI_InitHistoryPhysical;
    private SCM_MergeFieldCheckbox UI_Prescription;
    private SCM_MergeFieldCheckbox UI_SkinAllergyTest;
    private SCM_MergeFieldCheckbox UI_PrioAuthForm;
    private SCM_MergeFieldCheckbox UI_PatAuthNoticeRelInfo;
    private SCM_MergeFieldCheckbox UI_XolairTreatmentPlan;
    private SCM_MergeFieldCheckbox UI_ProgressNotes;
    private SCM_MergeFieldCheckbox UI_PulmonaryFunctionTests;
    private SCM_MergeFieldCheckbox UI_HospitalAdmisNotes;
    private SCM_MergeFieldCheckbox UI_IGELevels;
    private SCM_MergeFieldCheckbox UI_DenialLetters;
    private SCM_MergeFieldCheckbox UI_AppealLetters;
    private SCM_MergeFieldCheckbox UI_EOB;
    private SCM_MergeFieldCheckbox UI_Claims;
    private SCM_MergeFieldCheckbox UI_XOL_chkExhaustedOptions;
    
    private SCM_MergeFieldCheckbox UI_Other;         
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    
    private SCM_MF_OtherDocuments  OtherDoc4;
    private SCM_MF_OtherDocuments  OtherDoc5;
    private SCM_MF_OtherDocuments  OtherDoc6;
    private SCM_MF_OtherDocuments  OtherDoc7;
    private SCM_MF_OtherDocuments  OtherDoc8; 
    private SCM_MF_OtherDocuments  OtherDoc9;
    private SCM_MF_OtherDocuments  OtherDoc10;
    private SCM_MF_OtherDocuments  OtherDoc11;
    private SCM_MF_OtherDocuments  OtherDoc12;

    
    
    public SCM_MD_FAX_DenialOfCoverage_XOL(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    
     public override void createMergeFields() {
        
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String productName = selectedCase.Product_gne__c;      

        //1.CaseID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //2.PatientID
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //3.CR_Phone ( key CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_PhoneShort
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //4.CR_Fax (key CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //5.CR_URL ( key CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //6.ATTN (key ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        //7.RECNAME_FACPHY(key RECNAME_Name)     
        this.mergeRecipientInfo.add(new SCM_MF_FaxAdrsTo(selectedCase.Case_Treating_Physician_gne__r.Id));
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //8.RECFAX (key RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
        
        //9.From //10.Ext 
          String recordType = selectedCase.RecordType.Name;
             
            if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
            }
            else if (recordType.equals('GATCF - Standard Case')) {
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
            }  
        
        //11.DateShort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
       
        //12.PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
       
        //13.DOB(key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        
        //14.DRUG (key DRUG)
        //this.mergeRecipientInfo.add(new SCM_MF_DRUG2(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase.Product_gne__c));
        
        //15.PrivacyNotice
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
       
       
        //17.ConfidNotice
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //Denial Reason (key DenialReason)
        this.mergeRecipientInfo.add(new SCM_MF_BI_DenialReason(selectedCase.Id));
            
         //---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Documentation :';
        formInformation.key = 'Documentation';     
                        
        //Merge Sections       
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
                                                                 
        //  SMNComplete
        UI_SMNComplete = new SCM_MergeFieldCheckbox('SMNComplete','SMN(Completed and signed)');       
        UI_SMNComplete.fieldValue ='SMN (Completed and signed)\r\n';
        UI_SMNComplete.totalWidth = '190';
        formInformation.subFields.add(UI_SMNComplete);
  
        //  UI_InitHistoryPhysical   
        UI_InitHistoryPhysical = new SCM_MergeFieldCheckbox('InitHisPhys','Initial History & Physical');       
        UI_InitHistoryPhysical.fieldValue ='Initial History/Physical \r\n';
        UI_InitHistoryPhysical.totalWidth = '210';
        UI_InitHistoryPhysical.isNewLine = false;
        formInformation.subFields.add(UI_InitHistoryPhysical);
        
        // UI_Prescription      
         UI_Prescription = new SCM_MergeFieldCheckbox('Prescription','Prescription');       
        UI_Prescription.fieldValue ='Prescription \r\n';
        UI_Prescription.totalWidth = '170';
        UI_Prescription.isNewLine = false;
        formInformation.subFields.add(UI_Prescription);
        
        //  UI_SkinAllergyTest 
         UI_SkinAllergyTest  = new SCM_MergeFieldCheckbox('SkinTestRes','Skin/Allergy Test Results');       
        UI_SkinAllergyTest.fieldValue ='Skin/Allergy Test Results \r\n';
        UI_SkinAllergyTest.totalWidth = '190';
        formInformation.subFields.add(UI_SkinAllergyTest );
        
         // UI_PatAuthNoticeRelInfo
        UI_PatAuthNoticeRelInfo = new SCM_MergeFieldCheckbox('PatReleaseInfo','Patient Authorization Notification');       
        UI_PatAuthNoticeRelInfo.fieldValue ='Patient Authorization Notification \r\n';
        UI_PatAuthNoticeRelInfo.totalWidth = '210';
        UI_PatAuthNoticeRelInfo.isNewLine = false;
        formInformation.subFields.add(UI_PatAuthNoticeRelInfo);
        
         //  UI_PrioAuthForm      
         UI_PrioAuthForm = new SCM_MergeFieldCheckbox('PriorAuth','Prior Authorization Form');       
        UI_PrioAuthForm.fieldValue ='Prior Authorization Form\r\n';
        UI_PrioAuthForm.totalWidth = '170';
        UI_PrioAuthForm.isNewLine = false;
        formInformation.subFields.add(UI_PrioAuthForm);
        
        //  UI_XolairTreatmentPlan
        UI_XolairTreatmentPlan = new SCM_MergeFieldCheckbox('TreatPlan','Xolair Treatment Plan');       
        UI_XolairTreatmentPlan.fieldValue ='Xolair Treatment Plan:';
        UI_XolairTreatmentPlan.totalWidth = '200';
        UI_XolairTreatmentPlan.isNewLine = false;
        formInformation.subFields.add(UI_XolairTreatmentPlan);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('Treatplntxt', '');
        OtherDoc1.label='';
        OtherDoc1.isNewLine = false;
        OtherDoc1.totalWidth = '270';
        OtherDoc1.width = '250';
        formInformation.subFields.add(OtherDoc1);
      
        //  UI_ProgressNotes
        UI_ProgressNotes = new SCM_MergeFieldCheckbox('ProNotes','Progress Notes');       
        UI_ProgressNotes.fieldValue ='Progress Notes:';
        UI_ProgressNotes.totalWidth = '200';
        UI_ProgressNotes.isNewLine = false;
        formInformation.subFields.add(UI_ProgressNotes);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('pronotetxt', '');
        OtherDoc2.label='';
        OtherDoc2.isNewLine = false;
        OtherDoc2.totalWidth = '270';
        OtherDoc2.width = '250';
        formInformation.subFields.add(OtherDoc2);
        
         // UI_PulmonaryFunctionTests     
        UI_PulmonaryFunctionTests = new SCM_MergeFieldCheckbox('pultest','Pulmonary Function Tests');       
        UI_PulmonaryFunctionTests.fieldValue ='Pulmonary Function Tests:';
        UI_PulmonaryFunctionTests.totalWidth = '200';
        UI_PulmonaryFunctionTests.isNewLine = false;
        formInformation.subFields.add(UI_PulmonaryFunctionTests);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('pulfuntxt', '');
        OtherDoc3.label='';
        OtherDoc3.isNewLine = false;
        OtherDoc3.totalWidth = '270';
        OtherDoc3.width = '250';
        formInformation.subFields.add(OtherDoc3);       
         
        //  UI_HospitalAdmisNotes
        UI_HospitalAdmisNotes = new SCM_MergeFieldCheckbox('ERNotes','Hospital Admission/ER Notes');       
        UI_HospitalAdmisNotes.fieldValue ='Hospital Admission/ER Notes:';
        UI_HospitalAdmisNotes.totalWidth = '200';
        UI_HospitalAdmisNotes.isNewLine = false;
        formInformation.subFields.add(UI_HospitalAdmisNotes);
        
        OtherDoc4 = new SCM_MF_OtherDocuments('admnotestxt', '');
        OtherDoc4.label='';
        OtherDoc4.isNewLine = false;
        OtherDoc4.totalWidth = '270';
        OtherDoc4.width = '250';
        formInformation.subFields.add(OtherDoc4);
      
        //  UI_IGELevels
        UI_IGELevels = new SCM_MergeFieldCheckbox('igelvl','IgE Levels/Reports');       
        UI_IGELevels.fieldValue ='IgE Levels/Reports:';
        UI_IGELevels.totalWidth = '200';
        UI_IGELevels.isNewLine = false;
        formInformation.subFields.add(UI_IGELevels);
        
        OtherDoc5 = new SCM_MF_OtherDocuments('igelvltxt', '');
        OtherDoc5.label='';
        OtherDoc5.isNewLine = false;
        OtherDoc5.totalWidth = '270';
        OtherDoc5.width = '250';
        formInformation.subFields.add(OtherDoc5);
        
         // UI_DenialLetters     
        UI_DenialLetters = new SCM_MergeFieldCheckbox('denlttr','Denial Letter(s)');       
        UI_DenialLetters.fieldValue ='Denial Letter(s):';
        UI_DenialLetters.totalWidth = '200';
        UI_DenialLetters.isNewLine = false;
        formInformation.subFields.add(UI_DenialLetters);
        
        OtherDoc6 = new SCM_MF_OtherDocuments('denlttrtxt', '');
        OtherDoc6.label='';
        OtherDoc6.isNewLine = false;
        OtherDoc6.totalWidth = '270';
        OtherDoc6.width = '250';
        formInformation.subFields.add(OtherDoc6);
        
         //  UI_IGELevels
        UI_AppealLetters = new SCM_MergeFieldCheckbox('appeallttr','Appeal Letter(s)');       
        UI_AppealLetters.fieldValue ='Appeal Letter(s):';
        UI_AppealLetters.totalWidth = '200';
        UI_AppealLetters.isNewLine = false;
        formInformation.subFields.add(UI_AppealLetters);
        
        OtherDoc7 = new SCM_MF_OtherDocuments('appeallttrtxt', '');
        OtherDoc7.label='';
        OtherDoc7.isNewLine = false;
        OtherDoc7.totalWidth = '270';
        OtherDoc7.width = '250';
        formInformation.subFields.add(OtherDoc7);
        
         // UI_EOB     
        UI_EOB = new SCM_MergeFieldCheckbox('EOB','Explaination of Benefits(EOB)');       
        UI_EOB.fieldValue ='Explaination of Benefits(EOB):';
        UI_EOB.totalWidth = '200';
        UI_EOB.isNewLine = false;
        formInformation.subFields.add(UI_EOB);
        
        OtherDoc8 = new SCM_MF_OtherDocuments('beneftxt', '');
        OtherDoc8.label='';
        OtherDoc8.isNewLine = false;
        OtherDoc8.totalWidth = '270';
        OtherDoc8.width = '250';
        formInformation.subFields.add(OtherDoc8);
        
         //  UI_Claims
        UI_Claims = new SCM_MergeFieldCheckbox('claim','Claims');       
        UI_Claims.fieldValue ='Claims:';
        UI_Claims.totalWidth = '200';
        UI_Claims.isNewLine = false;
        formInformation.subFields.add(UI_Claims);
        
        OtherDoc9 = new SCM_MF_OtherDocuments('claimtxt', '');
        OtherDoc9.label='';
        OtherDoc9.isNewLine = false;
        OtherDoc9.totalWidth = '270';
        OtherDoc9.width = '250';
        formInformation.subFields.add(OtherDoc9);
        
          //Other Documentation
        OtherDoc10 = new SCM_MF_OtherDocuments('OtherDoc10', '');
        OtherDoc10.label = 'Other Documentation :';       
        OtherDoc10.totalWidth = '481';
        formInformation.subFields.add(OtherDoc10);
               
        OtherDoc11 = new SCM_MF_OtherDocuments('OtherDoc11', '');
        OtherDoc11.totalWidth = '481';
        OtherDoc11.isNewLine = false;
        formInformation.subFields.add(OtherDoc11);
        
        OtherDoc12 = new SCM_MF_OtherDocuments('OtherDoc12', '');
        OtherDoc12.totalWidth = '481';
        OtherDoc12.isNewLine = false;
        formInformation.subFields.add(OtherDoc12);
        
        //MergeSection
        UI_XOL_ExhaustedOptions = new SCM_MergeSection();        
        UI_XOL_ExhaustedOptions.key = 'UI_XOL_ExhaustedOptions';
        UI_XOL_ExhaustedOptions.visible = false;
        this.mergeSections.add(UI_XOL_ExhaustedOptions);      
           
          //  UI_XOL_chkExhausted Options
        UI_XOL_chkExhaustedOptions = new SCM_MergeFieldCheckbox('ExhOpt','Access');       
        UI_XOL_chkExhaustedOptions.fieldValue ='';
        UI_XOL_chkExhaustedOptions.displayLabel=false;
        UI_XOL_chkExhaustedOptions.displayExtraHTML = true;
        UI_XOL_chkExhaustedOptions.extraHTML='Access Solutions '
                +'has exhausted all options and has referred this case to the <br>'
                +'GATCF for review. You may reach them by calling (800) 704-6614.';
        UI_XOL_chkExhaustedOptions.totalWidth = '600';
        formInformation.subFields.add(UI_XOL_chkExhaustedOptions);
               
        this.mergeFields.add(formInformation); 
        
         //Comments
        this.mergeFields.add(new SCM_MF_Comments());
        
     }
     
     
     public override void getLatestValues()
        {
      
            if(UI_SMNComplete.checked == false && UI_InitHistoryPhysical.checked == false 
            && UI_Prescription.checked == false && UI_SkinAllergyTest.checked == false && UI_PrioAuthForm.checked == false 
            && UI_PatAuthNoticeRelInfo.checked == false && UI_XolairTreatmentPlan.checked==false &&
            UI_ProgressNotes.checked==false && UI_PulmonaryFunctionTests.checked==false && UI_HospitalAdmisNotes.checked==false &&
            UI_IGELevels.checked==false && UI_DenialLetters.checked==false && UI_AppealLetters.checked==false &&
            UI_EOB.checked==false && UI_Claims.checked==false && OtherDoc10.fieldValue == '' && OtherDoc11.fieldValue == '' && OtherDoc12.fieldValue == ''
            )
            {
                UI_Additional_Docs.visible = false;
            }
            else
            {
                UI_Additional_Docs.visible = true;
            }
            
           if (UI_XolairTreatmentPlan.checked==false)
           	OtherDoc1.mergeValue = '';
           if (UI_ProgressNotes.checked==false)
            OtherDoc2.mergeValue = '';
           if (UI_PulmonaryFunctionTests.checked==false)
            OtherDoc3.mergeValue = ''; 
           if (UI_HospitalAdmisNotes.checked==false)
            OtherDoc4.mergeValue = '';
           if (UI_IGELevels.checked==false)
            OtherDoc5.mergeValue = '';
           if (UI_DenialLetters.checked==false)
            OtherDoc6.mergeValue = '';
           if (UI_AppealLetters.checked==false)
            OtherDoc7.mergeValue = '';
           if (UI_EOB.checked==false)
            OtherDoc8.mergeValue = '';
           if (UI_Claims.checked==false)
            OtherDoc9.mergeValue = '';         
            
           if (UI_XOL_chkExhaustedOptions.checked == true)
           { UI_XOL_ExhaustedOptions.visible=true;}
           else 
           { 
            UI_XOL_ExhaustedOptions.visible=false;
            
            }
        }
}