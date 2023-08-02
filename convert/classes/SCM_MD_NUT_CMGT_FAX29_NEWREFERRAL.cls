/********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : NUT-CMGT-FAX-29 NEW REFERRAL
    // PRODUCT GROUP     : NUTROPIN
    // Type              : Fax coversheet(C&R STANDARD, C&R CONTINUOUS CARE, GATCF)
    // Word Template     : NUT-CMGT-FAX-29
    // Label in SF       : Nutropin CMGT FAX29 NEW REFERRAL
    
/********************************************************************/
public class SCM_MD_NUT_CMGT_FAX29_NEWREFERRAL extends SCM_MergeDocument implements IStandardComboBox
{ 
      //Merge sections
      private SCM_MergeSection UI_DocsRequiredList;
     
      //Checkboxes
      private SCM_MergeFieldCheckbox UI_SMNCompleted;
      private SCM_MergeFieldCheckbox UI_KaryotypeResults;
      private SCM_MergeFieldCheckbox UI_BoneAgeReport;
      private SCM_MergeFieldCheckbox UI_HisPhysTreat;
      private SCM_MergeFieldCheckbox UI_ProgressNotes;
      private SCM_MergeFieldCheckbox UI_RenalFunctionResultsCRIOnly;
      
      private SCM_MergeFieldCheckbox UI_GrowthChart;
      private SCM_MergeFieldCheckbox UI_Prescription;
      private SCM_MergeFieldCheckbox UI_StimTestsReports;
      private SCM_MergeFieldCheckbox UI_PrioAuthForm;
      private SCM_MergeFieldCheckbox UI_PCPReferral;
      private SCM_MergeFieldCheckbox other;
       
      //Textboxes 
      private SCM_MF_OtherDocuments  OtherDoc1;    
      private SCM_MF_OtherDocuments  OtherDoc2;   
      private SCM_MF_OtherDocuments  OtherDoc3;   
      
      public SCM_MD_NUT_CMGT_FAX29_NEWREFERRAL(String caseID, String argLookupId)
      {
            super(caseID, argLookupId);
            caseId = caseID;
      }
      public override void createMergeFields()  
      {
        //Case ID(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //Patient ID(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //CR_PhoneShort(CR_PhoneShort)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //CR_Phone(CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax(CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
           
        // Addressed To (RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    
        // Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
       
        // From and EXt(From,Ext)
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
        
        //Patient full name (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Patient DOB(Patient_DOB)
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
        UI_DocsRequiredList = new SCM_MergeSection();        
        UI_DocsRequiredList.key = 'UI_DocsRequiredList';
        this.mergeSections.add(UI_DocsRequiredList);
        
        
        //Initial statement
        
        SCM_MergeField Theory = new SCM_MergeField();
        Theory.key = '';
        Theory.checked = false;
        Theory.displayCheck = false;
        Theory.displayTextBox = false;
        Theory.displayLabel = true;
        Theory.isNewLine = true;
        Theory.IsRequired = false;
        Theory.label='Additional document(s) required by the payor before SPOC can submit for prior authorization';
        Theory.fieldValue='';
        Theory.totalWidth = '600';
        formInformation.subFields.add(Theory);
        
        //UI_SMNCompleted
        UI_SMNCompleted = new SCM_MergeFieldCheckbox('UI_SMNCompleted','SMN (Completed)');       
        UI_SMNCompleted.fieldValue ='SMN (Completed)';
        UI_SMNCompleted.totalWidth = '150';
        UI_SMNCompleted.isNewLine = true;  
        UI_SMNCompleted.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_SMNCompleted);
        
         //UI_HisPhysTreat
        UI_HisPhysTreat = new SCM_MergeFieldCheckbox('UI_HisPhysTreat','History/Physical/Treatment Plan');       
        UI_HisPhysTreat.fieldValue ='History/Physical/Treatment Plan';
        UI_HisPhysTreat.totalWidth = '275';
        UI_HisPhysTreat.isNewLine = false;  
        UI_HisPhysTreat.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_HisPhysTreat);
        
        
         //UI_GrowthChart
        UI_GrowthChart = new SCM_MergeFieldCheckbox('UI_GrowthChart','Growth Chart');       
        UI_GrowthChart.fieldValue ='Growth Chart';
        UI_GrowthChart.totalWidth = '150';
        UI_GrowthChart.isNewLine = false;  
        UI_GrowthChart.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_GrowthChart);
        
        
        
        //UI_KaryotypeResults
        UI_KaryotypeResults = new SCM_MergeFieldCheckbox('UI_KaryotypeResults','Karyotype Results');       
        UI_KaryotypeResults.fieldValue ='Karyotype Results';
        UI_KaryotypeResults.totalWidth = '150';
        UI_KaryotypeResults.isNewLine = true;  
        UI_KaryotypeResults.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_KaryotypeResults);
        
         //UI_ProgressNotes
        UI_ProgressNotes = new SCM_MergeFieldCheckbox('UI_ProgressNotes','Progress Notes');       
        UI_ProgressNotes.fieldValue ='Progress Notes';
        UI_ProgressNotes.totalWidth = '275';
        UI_ProgressNotes.isNewLine = false;  
        UI_ProgressNotes.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_ProgressNotes);
        
        
         //UI_Prescription
        UI_Prescription = new SCM_MergeFieldCheckbox('UI_Prescription','Prescription');       
        UI_Prescription.fieldValue ='Prescription';
        UI_Prescription.totalWidth = '150';
        UI_Prescription.isNewLine = false;  
        UI_Prescription.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_Prescription);
        
        
        
        //UI_BoneAgeReport
        UI_BoneAgeReport = new SCM_MergeFieldCheckbox('UI_BoneAgeReport','Bone Age Report');       
        UI_BoneAgeReport.fieldValue ='Bone Age Report';
        UI_BoneAgeReport.totalWidth = '150';
        UI_BoneAgeReport.isNewLine = true;  
        UI_BoneAgeReport.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_BoneAgeReport);
        
        
        //UI_PrioAuthForm
        UI_PrioAuthForm = new SCM_MergeFieldCheckbox('UI_PrioAuthForm','Prior Authorization Form');       
        UI_PrioAuthForm.fieldValue ='Prior Authorization Form (signed & completed)';
        UI_PrioAuthForm.totalWidth = '275';
        UI_PrioAuthForm.isNewLine = false;  
        UI_PrioAuthForm.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_PrioAuthForm);
        
         //UI_PCPReferral
        UI_PCPReferral = new SCM_MergeFieldCheckbox('UI_PCPReferral','PCP Referral');       
        UI_PCPReferral.fieldValue ='PCP Referral';
        UI_PCPReferral.totalWidth = '150';
        UI_PCPReferral.isNewLine = false;  
        UI_PCPReferral.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_PCPReferral);
        
         //UI_Prescription
        UI_StimTestsReports = new SCM_MergeFieldCheckbox('UI_StimTestsReports','Stim Test(s) Report(s)');       
        UI_StimTestsReports.fieldValue ='Stim Test(s) Report(s)';
        UI_StimTestsReports.totalWidth = '150';
        UI_StimTestsReports.isNewLine = true;  
        UI_StimTestsReports.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_StimTestsReports);
        
         //UI_RenalFunctionResultsCRIOnly
        UI_RenalFunctionResultsCRIOnly = new SCM_MergeFieldCheckbox('UI_RenalFunctionResultsCRIOnly','Renal Function Results (CRI Only)');       
        UI_RenalFunctionResultsCRIOnly.fieldValue ='Renal Function Results (CRI Only)';
        UI_RenalFunctionResultsCRIOnly.totalWidth = '275';
        UI_RenalFunctionResultsCRIOnly.isNewLine = false;  
        UI_RenalFunctionResultsCRIOnly.requireNewLineInTemplate=true;
        formInformation.subFields.add(UI_RenalFunctionResultsCRIOnly);
        
        
        
         
        
        
        //other docuemntation
                  
        SCM_MergeField OtherDocumentation = new SCM_MergeField();
        OtherDocumentation.key = 'OtherDoc1';
        OtherDocumentation.checked = false;
        OtherDocumentation.displayCheck = false;
        OtherDocumentation.displayTextBox = true;
        OtherDocumentation.displayLabel = true;
        OtherDocumentation.isNewLine = true;
        OtherDocumentation.IsRequired = false;
        OtherDocumentation.label='Other Documentation';
        OtherDocumentation.totalWidth = '220';
        OtherDocumentation.requireNewLineInTemplate=true;
        formInformation.subFields.add(OtherDocumentation);
       
             
       
        OtherDoc2 = new SCM_MF_OtherDocuments('OtherDoc2', '');
        OtherDoc2.isNewLine = true;
        OtherDoc2.totalWidth = '150';
        OtherDoc2.requireNewLineInTemplate=true;
        formInformation.subFields.add(OtherDoc2);
        
      
        
        OtherDoc3 = new SCM_MF_OtherDocuments('OtherDoc3', '');
        OtherDoc3.isNewLine = true;
        OtherDoc3.totalWidth = '150';
        OtherDoc3.requireNewLineInTemplate=true;
        formInformation.subFields.add(OtherDoc3);
        
        
        this.mergeFields.add(formInformation);         
       
        //Comments
        SCM_MergeFieldGroup comments = new SCM_MF_Comments();        
        this.mergeFields.add(comments);  
       
       
      
      }
      
       public override void getLatestValues()
        {
            if(UI_KaryotypeResults.checked == false && UI_BoneAgeReport.checked == false 
            && UI_HisPhysTreat.checked == false && UI_ProgressNotes.checked == false 
            && UI_RenalFunctionResultsCRIOnly.checked == false  && UI_GrowthChart.checked == false && UI_Prescription.checked == false 
            && UI_StimTestsReports.checked == false && UI_PrioAuthForm.checked == false && UI_PCPReferral.checked == false
            && UI_SMNCompleted.checked == false)
            {
                UI_DocsRequiredList.visible = false;
            }
            else
            {
                UI_DocsRequiredList.visible = true;
            }
         
          
        }
        
}