/********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : XOL-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis
    // PRODUCT GROUP     : Xolair
    // Type              : Fax coversheet(C&R Standard / C&R Continuous Care)
    // Word Template     : 
    // Label in SF       : 
    
/********************************************************************/

public class SCM_MD_Xol_Fax08_ReqAddInfo extends SCM_MergeDocument implements IStandardComboBox
{
      //Merge sections
      private SCM_MergeSection UI_InitialRequest;
      private SCM_MergeSection UI_Additional_Docs;
      
      //mergefield
      private SCM_MergeField UI_InitialRequestDate;
    
      //only checkboxes
      private SCM_MergeFieldCheckbox UI_XOL_SMN;
      private SCM_MergeFieldCheckbox UI_XOL_InitialHistoryPhysical;
      private SCM_MergeFieldCheckbox UI_Prescription;
      private SCM_MergeFieldCheckbox UI_SkinAllergyTestResults;
      private SCM_MergeFieldCheckbox UI_PatientAuthorizationNotification;
      private SCM_MergeFieldCheckbox UI_PrioAuthForm;
      //checkbox+textbox
      private SCM_MergeFieldCheckbox UI_XOL_TreatmentPlan;
      private SCM_MergeFieldCheckbox UI_ProgressNotes;
      private SCM_MergeFieldCheckbox UI_XOL_PulmonaryFunctionTests;
      private SCM_MergeFieldCheckbox UI_HospitalAdmissionNotesER;
      private SCM_MergeFieldCheckbox UI_IgELevelsReports;
      private SCM_MergeFieldCheckbox UI_DenialLetter;
      private SCM_MergeFieldCheckbox UI_AppealLetter;
      private SCM_MergeFieldCheckbox UI_ExpOfBenefits;
      private SCM_MergeFieldCheckbox UI_Claims;
      
      //only textboxes
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
      private SCM_MF_OtherDocuments OtherDocumentation;
	  private SCM_MF_OtherDocuments  MyDoc1;
	  private SCM_MF_OtherDocuments  MyDoc2;
	  private SCM_MF_OtherDocuments  MyDoc3;
	        
      
      public SCM_MD_Xol_Fax08_ReqAddInfo(String caseID, String argLookupId)
      {
            super(caseID, argLookupId);
            caseId = caseID;
      }

      public override void createMergeFields()  
      {
        //1 Case ID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //2 Patient ID
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
           
        // Addressed To (RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    
        // Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        // From and EXt
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case'))
        {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case'))
        {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
       
        // Date (Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //Patient full name (Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Patient DOB 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        
        //Drug (DRUG)
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //privacy notice (PrivacyNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
       
        //Confid notice
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));
         
        //---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Documentation';       
        formInformation.key = 'Documentation';    
        
        //Merge Sections       
        UI_InitialRequest = new SCM_MergeSection();        
        UI_InitialRequest.key = 'UI_InitialRequest';
        this.mergeSections.add(UI_InitialRequest);
        
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
        //Initial statement
        
        SCM_MergeField Theory = new SCM_MergeField();
        Theory.key = '';
        Theory.checked = false;
        Theory.displayCheck = false;
        Theory.displayTextBox = false;
        Theory.displayLabel = true;
        Theory.isNewLine = true;
        Theory.IsRequired = false;
        Theory.label='Access Solutions has not yet received the document(s) required initially on';
        Theory.fieldValue='';
        Theory.totalWidth = '420';
        formInformation.subFields.add(Theory);
        
         
        
        UI_InitialRequestDate = new SCM_MergeField();
        UI_InitialRequestDate.key = 'UI_InitialRequestDate';
        UI_InitialRequestDate.checked = false;
        UI_InitialRequestDate.displayCheck = false;
        UI_InitialRequestDate.displayTextBox = true;
        UI_InitialRequestDate.displayLabel = false;
        UI_InitialRequestDate.isNewLine = false;
        UI_InitialRequestDate.IsRequired = false;
        UI_InitialRequestDate.fieldValue=Date.today().format();
        //UI_InitialRequestDate.fieldValue='';
        UI_InitialRequestDate.totalWidth = '130';
        UI_InitialRequestDate.width = '80';
        UI_InitialRequestDate.fieldType = SCM_MergeField.FieldTypes.dateField;
        formInformation.subFields.add(UI_InitialRequestDate);
        
        SCM_MergeField onlyTheory = new SCM_MergeField();
        onlyTheory.key = '';
        onlyTheory.checked = false;
        onlyTheory.displayCheck = false;
        onlyTheory.displayTextBox = false;
        onlyTheory.displayLabel = true;
        onlyTheory.isNewLine = true;
        onlyTheory.IsRequired = false;
        onlyTheory.label='Please fax the soon as possible so we can expedite the autorization/appeal process';
        onlyTheory.fieldValue='';
        onlyTheory.totalWidth = '500';
        formInformation.subFields.add(onlyTheory);
         
        //Only checkboxes
        UI_XOL_SMN = new SCM_MergeFieldCheckbox('UI_XOL_SMN','SMN(Completed and signed)');       
        UI_XOL_SMN.fieldValue ='• SMN(Completed and signed)';
        UI_XOL_SMN.totalWidth = '600';
        UI_XOL_SMN.isNewLine = true;  
        UI_XOL_SMN.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_XOL_SMN);
        
        //UI_XOL_InitialHistoryPhysical
        UI_XOL_InitialHistoryPhysical = new SCM_MergeFieldCheckbox('UI_XOL_InitialHistoryPhysical','Initial History/Physical');       
        UI_XOL_InitialHistoryPhysical.fieldValue ='• Initial History/Physical';
        UI_XOL_InitialHistoryPhysical.totalWidth = '600';
        UI_XOL_InitialHistoryPhysical.isNewLine = true;
        UI_XOL_InitialHistoryPhysical.requireNewLineInTemplate=true;  
        formInformation.subFields.add(UI_XOL_InitialHistoryPhysical);
     
        //UI_Prescription
        UI_Prescription = new SCM_MergeFieldCheckbox('UI_Prescription','Prescription');       
        UI_Prescription.fieldValue ='• Prescription';
        UI_Prescription.totalWidth = '600';
        UI_Prescription.isNewLine = true;  
        UI_Prescription.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_Prescription);
        
       
        //UI_PatientAuthorizationNotification
        UI_PatientAuthorizationNotification = new SCM_MergeFieldCheckbox('UI_PatientAuthorizationNotification','Patient Authorization Notification');       
        UI_PatientAuthorizationNotification.fieldValue ='• Patient Authorization Notification';
        UI_PatientAuthorizationNotification.totalWidth = '600';
        UI_PatientAuthorizationNotification.isNewLine = true; 
        UI_PatientAuthorizationNotification.requireNewLineInTemplate = true;   
        formInformation.subFields.add(UI_PatientAuthorizationNotification);
        
        
        //UI_SkinAllergyTestResults
        UI_SkinAllergyTestResults = new SCM_MergeFieldCheckbox('UI_SkinAllergyTestResults','Skin/Allergy Test Results');       
        UI_SkinAllergyTestResults.fieldValue ='• Skin/Allergy Test Results';
        UI_SkinAllergyTestResults.totalWidth = '600';
        UI_SkinAllergyTestResults.isNewLine = true;  
        UI_SkinAllergyTestResults.requireNewLineInTemplate = true;   
        formInformation.subFields.add(UI_SkinAllergyTestResults);


        //UI_PrioAuthForm
        UI_PrioAuthForm = new SCM_MergeFieldCheckbox('UI_PrioAuthForm','Prior Authorization Form');       
        UI_PrioAuthForm.fieldValue ='• Prior Authorization Form';
        UI_PrioAuthForm.totalWidth = '600';
        UI_PrioAuthForm.isNewLine = true; 
        UI_PrioAuthForm.requireNewLineInTemplate = true;   
        formInformation.subFields.add(UI_PrioAuthForm);
               
        //checkboxes+textbox
        //UI_XOL_TreatmentPlan     
        UI_XOL_TreatmentPlan = new SCM_MergeFieldCheckbox('UI_XOL_TreatmentPlan','Xolair Treatment Plan');       
        UI_XOL_TreatmentPlan.fieldValue ='• Xolair Treatment Plan: ';
        UI_XOL_TreatmentPlan.totalWidth = '250';
        //UI_XOL_TreatmentPlan.isNewLine = true; 
        //UI_XOL_TreatmentPlan.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_XOL_TreatmentPlan);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('UI_XOL_TreatmentPlan_Txt', '');
        OtherDoc1.isNewLine = false;
        OtherDoc1.label='';
        OtherDoc1.totalWidth = '270';
        OtherDoc1.width = '250';
        formInformation.subFields.add(OtherDoc1);
        
        //UI_ProgressNotes
        UI_ProgressNotes = new SCM_MergeFieldCheckbox('UI_ProgressNotes','Progress Notes');       
        UI_ProgressNotes.fieldValue ='• Progress Notes: ';
        UI_ProgressNotes.totalWidth = '250';
        //UI_ProgressNotes.isNewLine = true;  
        //UI_ProgressNotes.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_ProgressNotes);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('UI_ProgressNotes_Txt', '');
        OtherDoc2.isNewLine = false;
        OtherDoc2.totalWidth = '270';
        OtherDoc2.width = '250';
        formInformation.subFields.add(OtherDoc2);
        
        //UI_XOL_PulmonaryFunctionTests
        UI_XOL_PulmonaryFunctionTests = new SCM_MergeFieldCheckbox('UI_XOL_PulmonaryFunctionTests','Pulmonary Function Tests');       
        UI_XOL_PulmonaryFunctionTests.fieldValue ='• Pulmonary Function Tests: ';
        UI_XOL_PulmonaryFunctionTests.totalWidth = '250';
        //UI_XOL_PulmonaryFunctionTests.isNewLine = true;  
        //UI_XOL_PulmonaryFunctionTests.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_XOL_PulmonaryFunctionTests);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('UI_XOL_PulmonaryFunctionTests_Txt', '');
        OtherDoc3.isNewLine = false;
        OtherDoc3.totalWidth = '270';
        OtherDoc3.width = '250';
        formInformation.subFields.add(OtherDoc3);
              
        //UI_HospitalAdmissionNotesER
        UI_HospitalAdmissionNotesER = new SCM_MergeFieldCheckbox('UI_HospitalAdmissionNotesER','Hospital Admission Notes/ER Notes');       
        UI_HospitalAdmissionNotesER.fieldValue ='• Hospital Admission Notes/ER Notes: ';
        UI_HospitalAdmissionNotesER.totalWidth = '250';
        UI_HospitalAdmissionNotesER.isNewLine = true;  
        //UI_HospitalAdmissionNotesER.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_HospitalAdmissionNotesER);
        
        OtherDoc4 = new SCM_MF_OtherDocuments('UI_HospitalAdmissionNotesER_Txt', '');
        OtherDoc4.isNewLine = false;
        OtherDoc4.totalWidth = '270';
        OtherDoc4.width = '250';
        formInformation.subFields.add(OtherDoc4);
        
        
        //UI_IgELevelsReports
        UI_IgELevelsReports = new SCM_MergeFieldCheckbox('UI_IgELevelsReports','IgE Levels/Reports');       
        UI_IgELevelsReports.fieldValue ='• IgE Levels/Reports: ';
        UI_IgELevelsReports.totalWidth = '250';
        UI_IgELevelsReports.isNewLine = true;  
        //UI_IgELevelsReports.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_IgELevelsReports);
        
        OtherDoc5 = new SCM_MF_OtherDocuments('UI_IgELevelsReports_Txt', '');
        OtherDoc5.isNewLine = false;
        OtherDoc5.totalWidth = '270';
        OtherDoc5.width = '250';
        formInformation.subFields.add(OtherDoc5);
        
        
        //UI_DenialLetter
        UI_DenialLetter = new SCM_MergeFieldCheckbox('UI_DenialLetter','Denial Letter(s)');       
        UI_DenialLetter.fieldValue ='• Denial Letter(s): ';
        UI_DenialLetter.totalWidth = '250';
        UI_DenialLetter.isNewLine = true;  
        //UI_DenialLetter.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_DenialLetter);
        
        OtherDoc6 = new SCM_MF_OtherDocuments('UI_DenialLetter_Txt', '');
        OtherDoc6.isNewLine = false;
        OtherDoc6.totalWidth = '270';
        OtherDoc6.width = '250';
        formInformation.subFields.add(OtherDoc6);
        
        //UI_AppealLetter
        UI_AppealLetter = new SCM_MergeFieldCheckbox('UI_AppealLetter','Appeal Letter(s)');       
        UI_AppealLetter.fieldValue ='• Appeal Letter(s): ';
        UI_AppealLetter.totalWidth = '250';
        UI_AppealLetter.isNewLine = true;  
        //UI_AppealLetter.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_AppealLetter);
        
        OtherDoc7 = new SCM_MF_OtherDocuments('UI_AppealLetter_Txt', '');
        OtherDoc7.isNewLine = false;
        OtherDoc7.totalWidth = '270';
        OtherDoc7.width = '250';
        formInformation.subFields.add(OtherDoc7);
        
        //UI_ExpOfBenefits
        UI_ExpOfBenefits = new SCM_MergeFieldCheckbox('UI_ExpOfBenefits','Explanation of Benefits (EOB)');       
        UI_ExpOfBenefits.fieldValue ='• Explanation of Benefits (EOB): ';
        UI_ExpOfBenefits.totalWidth = '250';
        UI_ExpOfBenefits.isNewLine = true;  
        //UI_ExpOfBenefits.requireNewLineInTemplate = true;  
        formInformation.subFields.add(UI_ExpOfBenefits);
        
        OtherDoc8 = new SCM_MF_OtherDocuments('UI_ExpOfBenefits_Txt', '');
        OtherDoc8.isNewLine = false;
        OtherDoc8.totalWidth = '270';
        OtherDoc8.width = '250';
        formInformation.subFields.add(OtherDoc8);
        
        //UI_Claims
        UI_Claims = new SCM_MergeFieldCheckbox('UI_Claims','Claims');       
        UI_Claims.fieldValue ='• Claims: ';
        UI_Claims.totalWidth = '250';
        UI_Claims.isNewLine = true;  
        formInformation.subFields.add(UI_Claims);
        
        OtherDoc9 = new SCM_MF_OtherDocuments('UI_Claims_Txt', '');
        OtherDoc9.isNewLine = false;
        OtherDoc9.totalWidth = '270';
        OtherDoc9.width = '250';
        formInformation.subFields.add(OtherDoc9);
             
        //other docuemntation                  
        OtherDocumentation = new SCM_MF_OtherDocuments('OtherDoc1b', 'Other Documentation :');       
        OtherDocumentation.displayLabel = true;
        OtherDocumentation.isNewLine = true;    
        OtherDocumentation.totalWidth = '531';   
        formInformation.subFields.add(OtherDocumentation);
       
        OtherDoc10 = new SCM_MF_OtherDocuments('OtherDoc2b', '');
        OtherDoc10.isNewLine = true;
        OtherDoc10.totalWidth = '531';      
        formInformation.subFields.add(OtherDoc10);
        
        OtherDoc11 = new SCM_MF_OtherDocuments('OtherDoc3b', '');
        OtherDoc11.isNewLine = true;
        OtherDoc11.totalWidth = '531';     
        formInformation.subFields.add(OtherDoc11);
        
        this.mergeFields.add(formInformation);         
       
        //Comments
        SCM_MergeFieldGroup comments = new SCM_MF_Comments();        
        this.mergeFields.add(comments);  
        
         /*System.Debug('----------------------------------------------------------------------------------------------------------');
         System.debug('DateLocal:'+UI_InitialRequestDate.fieldValue); 
         System.Debug('----------------------------------------------------------------------------------------------------------');
         
         System.Debug('----------------------------------------------------------------------------------------------------------');
         System.debug('DateLocalmergedvalue:'+UI_InitialRequestDate.mergeValue); 
         System.Debug('----------------------------------------------------------------------------------------------------------');*/  
            
      }
      
      public override void getLatestValues()
      {
      	
      	
      	
      	
		mydoc1 = new SCM_MF_OtherDocuments('OtherDoc1', '');
        mydoc1.isNewLine = true;
        mydoc1.totalWidth = '531';
        this.mergeFields.add(mydoc1);
        mydoc2 = new SCM_MF_OtherDocuments('OtherDoc2', '');
        mydoc2.isNewLine = true;
        mydoc2.totalWidth = '531';    	
      	this.mergeFields.add(mydoc2);
      	mydoc3 = new SCM_MF_OtherDocuments('OtherDoc3', '');
        mydoc3.isNewLine = true;
        mydoc3.totalWidth = '531';    	
        this.mergeFields.add(mydoc3);  	
        
        if (OtherDocumentation.mergeValue != null && OtherDocumentation.mergeValue != '') {
        	mydoc1.FieldValue = '• ' + OtherDocumentation.mergeValue;
        }
         if (OtherDoc10.mergeValue != null && OtherDoc10.mergeValue != '') {
        	mydoc2.FieldValue = '• ' + OtherDoc10.mergeValue;
        }
         if (OtherDoc11.mergeValue != null && OtherDoc11.mergeValue != '') {
        	mydoc3.FieldValue = '• ' + OtherDoc11.mergeValue;
        }
      
            if (UI_XOL_TreatmentPlan.checked==false)
            OtherDoc1.mergeValue = '';
            else
            {
            	if ((UI_XOL_TreatmentPlan.checked==true) && (OtherDoc1.mergeValue == ''))
            	 OtherDoc1.mergeValue = ' ';
            }
            if (UI_ProgressNotes.checked==false)
            OtherDoc2.mergeValue = '';
            else
            {
            	if ((UI_ProgressNotes.checked==true) && (OtherDoc2.mergeValue == ''))
            	 OtherDoc2.mergeValue = ' ';
            }
            if (UI_XOL_PulmonaryFunctionTests.checked==false)
            OtherDoc3.mergeValue = '';
            else
            {
            	if ((UI_XOL_PulmonaryFunctionTests.checked==true) && (OtherDoc3.mergeValue == ''))
            	 OtherDoc3.mergeValue = ' ';
            }
            if (UI_HospitalAdmissionNotesER.checked==false)
            OtherDoc4.mergeValue = '';
            else
            {
            	if ((UI_HospitalAdmissionNotesER.checked==true) && (OtherDoc4.mergeValue == ''))
            	 OtherDoc4.mergeValue = ' ';
            }
            if (UI_IgELevelsReports.checked==false)
            OtherDoc5.mergeValue = '';
            else
            {
            	if ((UI_IgELevelsReports.checked==true) && (OtherDoc5.mergeValue == ''))
            	 OtherDoc5.mergeValue = ' ';
            }
            if (UI_DenialLetter.checked==false)
            OtherDoc6.mergeValue = '';
            else
            {
            	if ((UI_DenialLetter.checked==true) && (OtherDoc6.mergeValue == ''))
            	 OtherDoc6.mergeValue = ' ';
            }
            if (UI_AppealLetter.checked==false)
            OtherDoc7.mergeValue = '';
            else
            {
            	if ((UI_AppealLetter.checked==true) && (OtherDoc7.mergeValue == ''))
            	 OtherDoc7.mergeValue = ' ';
            }
            if (UI_ExpOfBenefits.checked==false)
            OtherDoc8.mergeValue = '';
            else
            {
            	if ((UI_ExpOfBenefits.checked==true) && (OtherDoc8.mergeValue == ''))
            	 OtherDoc8.mergeValue = ' ';
            }
            if (UI_Claims.checked==false)
            OtherDoc9.mergeValue = '';
            else
            {
            	if ((UI_Claims.checked==true) && (OtherDoc9.mergeValue == ''))
            	 OtherDoc9.mergeValue = ' ';
            }
            /*if(UI_InitialRequestDate.fieldValue==null || UI_InitialRequestDate.fieldValue=='')
            UI_InitialRequest.visible = false;
            else
            UI_InitialRequest.visible = true;*/
           
            if(UI_InitialRequestDate.mergeValue==null || UI_InitialRequestDate.mergeValue=='')
            UI_InitialRequest.visible = false;
            else
            UI_InitialRequest.visible = true;
        
            if(UI_XOL_SMN.checked == false && UI_XOL_InitialHistoryPhysical.checked == false 
            && UI_Prescription.checked == false && UI_PatientAuthorizationNotification.checked == false 
            && UI_SkinAllergyTestResults.checked == false  && UI_PrioAuthForm.checked == false && UI_XOL_TreatmentPlan.checked == false 
            && UI_ProgressNotes.checked == false && UI_XOL_PulmonaryFunctionTests.checked == false && UI_HospitalAdmissionNotesER.checked == false
            && UI_IgELevelsReports.checked == false && UI_DenialLetter.checked == false && UI_AppealLetter.checked == false
            && UI_ExpOfBenefits.checked == false && UI_Claims.checked == false && OtherDocumentation.mergeValue == '' && OtherDoc10.mergeValue == ''
            && OtherDoc11.mergeValue == '')
            {
                UI_Additional_Docs.visible = false;
            }
            else
            {
                UI_Additional_Docs.visible = true;
            }
         
      }
      
}