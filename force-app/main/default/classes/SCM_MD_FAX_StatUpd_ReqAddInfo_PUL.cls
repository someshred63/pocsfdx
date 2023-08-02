/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : PUL-CMGT-FAX-22_StatusUpdate_RequestAddt_Info_FinalAnalysis.doc
    // PRODUCT GROUP     : Pulmonary / Pulmozyme
    // Type              : Fax Coversheet
    // Word Template     : RequestforAdditionalInf.doc    
    // Label in SF       : Request for Additional Information 
    
/********************************************************************/

public class SCM_MD_FAX_StatUpd_ReqAddInfo_PUL extends SCM_MergeDocument implements IStandardComboBox
  { 
    private SCM_MergeSection UI_InitialRequest;
    private SCM_MergeSection UI_Additional_Docs;   
    private SCM_MergeField UI_Additional_Label; 
    
    private SCM_MergeFieldCheckbox UI_SMNComplete;
    private SCM_MergeFieldCheckbox UI_KaryotypeResults;
    private SCM_MergeFieldCheckbox UI_BoneAgeReport;
    private SCM_MergeFieldCheckbox UI_PrioAuthForm;
    private SCM_MergeFieldCheckbox UI_HisPhysTreat;
    private SCM_MergeFieldCheckbox UI_ProgressNotes;
    private SCM_MergeFieldCheckbox UI_FEVTestRpt;
    private SCM_MergeFieldCheckbox UI_PCPReferral;
    private SCM_MergeFieldCheckbox UI_GrowthChart;
    private SCM_MergeFieldCheckbox UI_Prescription;
    private SCM_MergeFieldCheckbox UI_StimTestReport;
    
    private SCM_MergeFieldCheckbox UI_Other;       
    private SCM_MergeField UI_InitialRequestDate;    
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    
    private SCM_MergeSection UI_FollowUp; 
    private SCM_MergeField UI_FollowUp_Label; 
    private SCM_MergeSection UI_GATCF;
    private SCM_MergeSection UI_GATCF_AttachedSMN; 
    private SCM_MergeSection UI_GATCF_Prescription; 
    private SCM_MergeSection UI_Starter;
     
    private SCM_MergeField UI_GATCF_Label;
    private SCM_MergeField UI_Starter_Label;
    
    private SCM_MergeFieldCheckbox UI_chkSMN; 
    private SCM_MergeFieldCheckbox UI_chkPrescription; 
    private SCM_MergeFieldCheckbox UI_chkStarter; 
    private SCM_MergeFieldCheckbox UI_chkGATCF; 
    
    
    public SCM_MD_FAX_StatUpd_ReqAddInfo_PUL(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
        
    public override void createMergeFields() {
        
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String productName = selectedCase.Product_gne__c;
        String recordType = selectedCase.RecordType.Name;

        // Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));   
        
        // Phone (800) 690-3023
        mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));

        // Fax (800) 963-1792
        mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));

        // URL www.PulmozymeAccessSolutions.com
        mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));

        // Attn:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // To RECNAME_To:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //RecFax
        SCM_MF_FaxRECFAX recFax = new SCM_MF_FaxRECFAX(selectedCase.Case_Treating_Physician_gne__r.Id);
        this.mergeRecipientInfo.add(recFax);      
               
        //From
        SCM_MF_FaxFrom faxfrom = new SCM_MF_FaxFrom(selectedCase,recordType);
        this.mergeRecipientInfo.add(faxfrom); 
        
        //Ext
        SCM_MF_FaxExtn Ext = new SCM_MF_FaxExtn(selectedCase,recordType);
        this.mergeRecipientInfo.add(Ext);
                       
        // Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstMiddleAndLastName(patientId));
        
        //DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
        
        //Drug 
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase)); 
        
        // Privacy Notice    
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        // Confidentiality Notice
        this.mergeRecipientInfo.add( new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
         //---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Documentation :';
        formInformation.key = 'Documentation';     
        
        //Merge Sections       
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
                          
        UI_Additional_Label = new SCM_MergeField();
        UI_Additional_Label.key = 'AdditionalLabel';
        UI_Additional_Label.displayCheck = false;
        UI_Additional_Label.displayTextBox = false;
        UI_Additional_Label.displayLabel = true;
        UI_Additional_Label.IsRequired = false;
        UI_Additional_Label.label='             The following additional document(s) are required by the Payor';       
        UI_Additional_Label.totalWidth = '400';
        formInformation.subFields.add(UI_Additional_Label);
                
        SCM_MergeField UI_FreeLine = new SCM_MergeField();
        UI_FreeLine.key = 'FreeLine';
        UI_FreeLine.displayCheck = false;
        UI_FreeLine.displayTextBox = false;
        UI_FreeLine.displayLabel = true;
        UI_FreeLine.IsRequired = false;
        UI_FreeLine.label='';       
        UI_FreeLine.totalWidth = '400';
        formInformation.subFields.add(UI_FreeLine);
        
        //  SMNComplete
        UI_SMNComplete = new SCM_MergeFieldCheckbox('SMNComplete','SMN (Completed)');       
        UI_SMNComplete.fieldValue ='SMN (Completed).\r\n';
        UI_SMNComplete.totalWidth = '180';
        formInformation.subFields.add(UI_SMNComplete);
  
        //  UI_HisPhysTreat   
        UI_HisPhysTreat = new SCM_MergeFieldCheckbox('HisPhys','History/Physical/Treatment Plan');       
        UI_HisPhysTreat.fieldValue ='History/Physical/Treatment Plan.\r\n';
        UI_HisPhysTreat.totalWidth = '250';
        UI_HisPhysTreat.isNewLine = false;
        formInformation.subFields.add(UI_HisPhysTreat);
        
        // UI_GrowthChart      
         UI_GrowthChart = new SCM_MergeFieldCheckbox('GrowthChart','Growth Chart');       
        UI_GrowthChart.fieldValue ='Growth Chart.\r\n';
        UI_GrowthChart.totalWidth = '150';
        UI_GrowthChart.isNewLine = false;
        formInformation.subFields.add(UI_GrowthChart);
        
        //  UI_KaryotypeResults
         UI_KaryotypeResults = new SCM_MergeFieldCheckbox('Karyotype','Karyotype Results ');       
        UI_KaryotypeResults.fieldValue ='Karyotype Results .\r\n';
        UI_KaryotypeResults.totalWidth = '180';
        formInformation.subFields.add(UI_KaryotypeResults);
        
         //  UI_ProgressNotes      
         UI_ProgressNotes = new SCM_MergeFieldCheckbox('Progress','Progress Notes');       
        UI_ProgressNotes.fieldValue ='Progress Notes.\r\n';
        UI_ProgressNotes.totalWidth = '250';
        UI_ProgressNotes.isNewLine = false;
        formInformation.subFields.add(UI_ProgressNotes);
            
        // UI_Prescription
        UI_Prescription = new SCM_MergeFieldCheckbox('Prescription','Prescription');       
        UI_Prescription.fieldValue ='Prescription.\r\n';
        UI_Prescription.totalWidth = '150';
        UI_Prescription.isNewLine = false;
        formInformation.subFields.add(UI_Prescription);
        
        //  UI_BoneAgeReport
        UI_BoneAgeReport = new SCM_MergeFieldCheckbox('BoneAge','BoneAge Report ');       
        UI_BoneAgeReport.fieldValue ='BoneAge Report .\r\n';
        UI_BoneAgeReport.totalWidth = '180';
        formInformation.subFields.add(UI_BoneAgeReport);
      
        //  UI_FEVTestRpt
        UI_FEVTestRpt = new SCM_MergeFieldCheckbox('FEVTest','Forced Expiratory Volume (FEV) Test Rpt.');       
        UI_FEVTestRpt.fieldValue ='Forced Expiratory Volume (FEV) Test Report(s).\r\n';
        UI_FEVTestRpt.totalWidth = '250';
        UI_FEVTestRpt.isNewLine = false;
        formInformation.subFields.add(UI_FEVTestRpt);
        
         // UI_StimTestReport     
         UI_StimTestReport = new SCM_MergeFieldCheckbox('StimTest','Stim Test(s) Report(s)');       
        UI_StimTestReport.fieldValue ='Stim Test(s) Report(s).\r\n';
        UI_StimTestReport.totalWidth = '150';
        UI_StimTestReport.isNewLine = false;
        formInformation.subFields.add(UI_StimTestReport);
          
         //  UI_PrioAuthForm
         UI_PrioAuthForm = new SCM_MergeFieldCheckbox('PrioAuth','Prior Authorization Form');       
        UI_PrioAuthForm.fieldValue ='Prior Authorization Form (signed & completed).\r\n';
        UI_PrioAuthForm.totalWidth = '180';
        formInformation.subFields.add(UI_PrioAuthForm);
          
        //  UI_PCPReferral
         UI_PCPReferral = new SCM_MergeFieldCheckbox('PCPReferral','PCP Referral');       
        UI_PCPReferral.fieldValue ='PCP Referral.\r\n';
        UI_PCPReferral.totalWidth = '250';
        UI_PCPReferral.isNewLine = false;
        formInformation.subFields.add(UI_PCPReferral);
            

        // UI_Other
        UI_Other = new SCM_MergeFieldCheckbox('Other','Other');       
        UI_Other.fieldValue ='Other';
        UI_Other.totalWidth = '700';
        UI_Other.isNewLine = true;
        formInformation.subFields.add(UI_Other);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('OtherDoc1', '');
        OtherDoc1.label = 'Other Documentation :';       
        OtherDoc1.totalWidth = '420';
        OtherDoc1.isNewLine = true;
        formInformation.subFields.add(OtherDoc1);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('OtherDoc2', '');
        OtherDoc2.totalWidth = '420';
        OtherDoc2.isNewLine = true;
        formInformation.subFields.add(OtherDoc2);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('OtherDoc3', '');
        OtherDoc3.totalWidth = '420';
        OtherDoc3.isNewLine = true;
        formInformation.subFields.add(OtherDoc3);
        
        SCM_MergeField IniRequest = new SCM_MergeField();
        IniRequest.fieldValue = '';
        IniRequest.key = 'UI_InitialRequest';     
        IniRequest.checked = false;
        IniRequest.displayCheck = false;
        IniRequest.displayTextBox = false;
        IniRequest.displayLabel = true;
        IniRequest.isNewLine = true;
        IniRequest.Label = 'Initial Request :';
        IniRequest.className = 'SCM_MergeField';
        IniRequest.isRequired = false;
        IniRequest.totalWidth='120';        
        formInformation.subFields.add(IniRequest); 
      
        UI_InitialRequestDate = new SCM_MergeField();
        UI_InitialRequestDate.key = 'UI_InitialRequestDate';
        UI_InitialRequestDate.checked = false;
        UI_InitialRequestDate.displayCheck = false;
        UI_InitialRequestDate.displayTextBox = true;
        UI_InitialRequestDate.displayLabel = false;
        UI_InitialRequestDate.isNewLine = false;
        UI_InitialRequestDate.IsRequired = false;
        UI_InitialRequestDate.fieldValue = '';
        UI_InitialRequestDate.totalWidth = '300';
        UI_InitialRequestDate.fieldType = SCM_MergeField.FieldTypes.dateField;
        formInformation.subFields.add(UI_InitialRequestDate);
        
        this.mergeFields.add(formInformation);   
        
        //Follow Up ----------------------------------------------------------------
        SCM_MergeFieldGroup followUp = new SCM_MergeFieldGroup();
        followUp.headerText = 'Follow Up';       
        followUp.key = 'followUp'; 
        
        //UI_FollowUp_Label
         UI_FollowUp_Label = new SCM_MergeField();
        UI_FollowUp_Label.key = 'FollowUpLabel';
        UI_FollowUp_Label.displayCheck = false;
        UI_FollowUp_Label.displayTextBox = false;
        UI_FollowUp_Label.displayLabel = true;
        UI_FollowUp_Label.IsRequired = false;
        UI_FollowUp_Label.label='To begin treatment now, please complete the following';       
        UI_FollowUp_Label.totalWidth = '400';
        followUp.subFields.add(UI_FollowUp_Label);
        
        SCM_MergeField UI_FreeLine2 = new SCM_MergeField();
        UI_FreeLine2.key = 'FreeLine2';
        UI_FreeLine2.displayCheck = false;
        UI_FreeLine2.displayTextBox = false;
        UI_FreeLine2.displayLabel = true;
        UI_FreeLine2.IsRequired = false;
        UI_FreeLine2.label='';       
        UI_FreeLine2.totalWidth = '400';
        followUp.subFields.add(UI_FreeLine2);
        
        //MergeSection
        UI_GATCF = new SCM_MergeSection();        
        UI_GATCF.key = 'UI_GATCF';
        UI_GATCF.visible = false;
        this.mergeSections.add(UI_GATCF);      
           
        //  UI_chkGATCF
        UI_chkGATCF = new SCM_MergeFieldCheckbox('GATCF','GATCF:');       
        UI_chkGATCF.fieldValue ='';
        UI_chkGATCF.displayLabel=false;
        UI_chkGATCF.displayExtraHTML = true;
        UI_chkGATCF.extraHTML='GATCF <br>'
                +'To facilitate the GATCF process, please <br>'
                +'complete the following medical documentation <br>'
                +'and fax directly to the GATCF pharmacy <br>'
                +'at (800) 545- 0612 .' ;
        UI_chkGATCF.isRequired=false;
        UI_chkGATCF.totalWidth = '280';
        UI_chkGATCF.isNewLine=true;
        followUp.subFields.add(UI_chkGATCF);
        
        //MergeSection
        UI_Starter = new SCM_MergeSection();        
        UI_Starter.key = 'UI_Starter';
        UI_Starter.visible = false;
        this.mergeSections.add(UI_Starter); 
        
         //  UI_chkStarter
        UI_chkStarter = new SCM_MergeFieldCheckbox('Starter','Starter:');       
        UI_chkStarter.fieldValue ='';
        UI_chkStarter.displayLabel=false;
        UI_chkStarter.displayExtraHTML = true;
        UI_chkStarter.extraHTML='STARTER: <br>'
                +'Please complete the attached Starter <br>'
                +'of Medical Necessity and fax directly to <br>'
                +' ACCESS SOLUTIONS at (800) 545- 0612 .' ;
        UI_chkStarter.isRequired=false;
        UI_chkStarter.totalWidth = '300';
        UI_chkStarter.isNewLine = false ;
        followUp.subFields.add(UI_chkStarter);
               
        //MergeSection
        UI_GATCF_AttachedSMN = new SCM_MergeSection();        
        UI_GATCF_AttachedSMN.key = 'UI_GATCF_AttachedSMN';
        UI_GATCF_AttachedSMN.visible = false;
        this.mergeSections.add(UI_GATCF_AttachedSMN);       
        
         //  UI_chkSMN
        UI_chkSMN = new SCM_MergeFieldCheckbox('SMN','Attached Statement of Medical Necessity (SMN).');       
        UI_chkSMN.fieldValue ='Attached Statement of Medical Necessity (SMN).\r\n';
        UI_chkSMN.totalWidth = '400';
        followUp.subFields.add(UI_chkSMN);
        
        //MergeSection
        UI_InitialRequest = new SCM_MergeSection();        
        UI_InitialRequest.key = 'UI_InitialRequest';
        this.mergeSections.add(UI_InitialRequest);
        
        UI_GATCF_Prescription = new SCM_MergeSection();        
        UI_GATCF_Prescription.key = 'UI_GATCF_Prescription';
        UI_GATCF_Prescription.visible = false;
        this.mergeSections.add(UI_GATCF_Prescription); 
        
         //  UI_chkPrescription
        UI_chkPrescription = new SCM_MergeFieldCheckbox('Prescription','Prescription');       
        UI_chkPrescription.fieldValue ='Prescription.\r\n';
        UI_chkPrescription.totalWidth = '400';
        followUp.subFields.add(UI_chkPrescription);
               
        this.mergeFields.add(followUp);   
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());
   
    }

        public override void getLatestValues()
        {
            if(UI_InitialRequestDate.getMergeValue() == null || UI_InitialRequestDate.getMergevalue().length() <= 0)
                UI_InitialRequest.visible = false;
            else
                UI_InitialRequest.visible = true;
            
      
            if(UI_SMNComplete.checked == false && UI_KaryotypeResults.checked == false 
            && UI_BoneAgeReport.checked == false && UI_PrioAuthForm.checked == false && UI_HisPhysTreat.checked == false 
            && UI_ProgressNotes.checked == false && UI_FEVTestRpt.checked == false  
            && UI_PCPReferral.checked == false && UI_GrowthChart.checked == false
            && UI_Prescription.checked == false && UI_StimTestReport.checked == false)
            {
                UI_Additional_Docs.visible = false;
            }
            else
            {
                UI_Additional_Docs.visible = true;
            }
            
            
            if(UI_Other.checked == false){
                OtherDoc1.mergeValue = '';
                OtherDoc2.mergeValue = '';
                OtherDoc3.mergeValue = '';}
                
           if (UI_chkGATCF.checked == true)
           { UI_GATCF.visible=true;}
           else { UI_GATCF.visible=false;}
           
           if (UI_chkSMN.checked == true)
           { UI_GATCF_AttachedSMN.visible=true;} 
             else { UI_GATCF_AttachedSMN.visible=false;}
             
           if (UI_chkPrescription.checked == true)
           { UI_GATCF_Prescription.visible=true;} 
             else { UI_GATCF_Prescription.visible=false;}
             
           if (UI_chkStarter.checked == true)
           { UI_Starter.visible=true;} 
            else { UI_Starter.visible=false;}   
       }
        
        
 }