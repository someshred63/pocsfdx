/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : NUT-CMGT-FAX-22_Status Update / Request for Additional Information
    // PRODUCT GROUP     : Nutropin
    // Type              : FaxCoverSheet
    // Word Template     : 
   
/********************************************************************/    


public class SCM_MD_Fax_StaUpd_ReqForAddInf_Nut extends SCM_MergeDocument implements IStandardComboBox  { 
    
  //Merge sections
    private SCM_MergeSection UI_Additional_Docs;
    private SCM_MergeSection UI_InitialRequest;
    private SCM_MergeSection UI_GATCF;
    private SCM_MergeSection UI_GATCF_AttachedSMN;
    private SCM_MergeSection  UI_GATCF_Prescription;
   	private SCM_MergeSection UI_Starter;
   
    private SCM_MergeFieldCheckbox Checkbox1;
    private SCM_MergeFieldCheckbox Checkbox2;
    private SCM_MergeFieldCheckbox Checkbox3;
    private SCM_MergeFieldCheckbox Checkbox4;
    private SCM_MergeFieldCheckbox Checkbox5;
    private SCM_MergeFieldCheckbox Checkbox6;
    private SCM_MergeFieldCheckbox Checkbox7;
    private SCM_MergeFieldCheckbox Checkbox8;
    private SCM_MergeFieldCheckbox Checkbox9;
    private SCM_MergeFieldCheckbox Checkbox10;
    private SCM_MergeFieldCheckbox Checkbox11;
    private SCM_MergeFieldCheckbox UI_Other;
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
    //check boxes
    private SCM_MergeFieldCheckbox UI_chkStarter;
    private SCM_MergeFieldCheckbox UI_chkPrescription;
    private SCM_MergeFieldCheckbox UI_chkSMN;
    private SCM_MergeFieldCheckbox UI_chkGATCF;
 
    //mergefield
    private SCM_MergeField UI_InitialRequestDate;
   
   
 public SCM_MD_Fax_StaUpd_ReqForAddInf_Nut(String caseId, String argLookupId){
    
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
        
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
   
    //7.RECNAME_FACPHY(key RECNAME_To) 
    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
    
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
    this.mergeRecipientInfo.add(new SCM_MF_DRUG2(selectedCase));
   
    //15.PrivacyNotice
    this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
   
   
    //17.ConfidNotice
    this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
 
    
    //---------------Second screen-----------------
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Documentation:';
        docu.headerText = 'The following additional document(s) are required by the Payer';       
        docu.key = 'Documentation';
        
        //Merge Sections       
        UI_InitialRequest = new SCM_MergeSection();        
        UI_InitialRequest.key = 'UI_InitialRequest';
        this.mergeSections.add(UI_InitialRequest);
        
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
      //only check boxes
       
        //UI_SMNComplete
        Checkbox1 =     new SCM_MergeFieldCheckbox('UI_SMNComplete', 'SMN (Completed)');        
        Checkbox1.fieldValue = 'SMN (Completed)';
        Checkbox1.totalWidth = '175';
        Checkbox1.isNewLine = true;
        Checkbox1.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox1);
        
       //UI_HisPhysTreat
         Checkbox2 = new SCM_MergeFieldCheckbox('UI_HisPhysTreat', 'History/Physical/Treatment Plan');      
        Checkbox2.fieldValue = 'History/Physical/Treatment Plan ';
        Checkbox2.totalWidth = '220';
        Checkbox2.isNewLine = false;
        Checkbox2.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox2);
        
        //UI_GrowthChart
      Checkbox3 = new SCM_MergeFieldCheckbox('UI_GrowthChart', 'Growth Chart');     
        Checkbox3.fieldValue = 'Growth Chart ';
        Checkbox3.totalWidth = '200';
        Checkbox3.isNewLine = false;
        Checkbox3.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox3);
        
         //UI_KaryotypeResults
         Checkbox4 = new SCM_MergeFieldCheckbox('UI_KaryotypeResults', 'Karyotype Results');        
        Checkbox4.fieldValue = 'Karyotype Results ';
        Checkbox4.totalWidth = '175';
        Checkbox4.isNewLine = true;
        Checkbox4.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox4);
       
       
        //UI_ProgressNotes
         Checkbox5 =    new SCM_MergeFieldCheckbox('UI_ProgressNotes', 'Progress Notes');       
        Checkbox5.fieldValue = 'Progress Notes ';
        Checkbox5.totalWidth = '220';
        Checkbox5.isNewLine = false;
        Checkbox5.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox5);
        
       //UI_Prescription
         Checkbox6 = new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');     
        Checkbox6.fieldValue = 'Prescription ';
        Checkbox6.totalWidth = '200';
        Checkbox6.isNewLine = false;
        Checkbox6.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox6);
       
       //UI_BoneAgeReport
         Checkbox7 = new SCM_MergeFieldCheckbox('UI_BoneAgeReport', 'BoneAgeReport');       
        Checkbox7.fieldValue = 'BoneAgeReport ';
        Checkbox7.totalWidth = '175';
        Checkbox7.isNewLine = true;
        Checkbox7.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox7);       
      
       //UI_RenalFunctResults
        Checkbox8 = new SCM_MergeFieldCheckbox('UI_RenalFunctResults', 'Renal Function Results(CRI Only)');     
        Checkbox8.fieldValue = 'Renal Function Results(CRI Only) ';
        Checkbox8.totalWidth = '220';
        Checkbox8.isNewLine = false;
        Checkbox8.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox8);   
            
      //UI_StimTestReport
        Checkbox9 = new SCM_MergeFieldCheckbox('UI_StimTestReport', 'Stim Test(s) Report(s)');      
        Checkbox9.fieldValue = 'Stim Test(s) Report(s) ';
        Checkbox9.totalWidth = '200';
        Checkbox9.isNewLine = false;
        Checkbox9.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox9);     
        
       //UI_PrioAuthForm
         Checkbox10 = new SCM_MergeFieldCheckbox('UI_PrioAuthForm', 'Prior Authorization Form');        
        Checkbox10.fieldValue = 'Prior Authorization Form (signed & completed)';
        Checkbox10.totalWidth = '175';
        Checkbox10.isNewLine = true;
        Checkbox10.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox10);   
        
         //UI_PCPReferral    
         Checkbox11 = new SCM_MergeFieldCheckbox('UI_PCPReferral', 'PCP Referral');     
        Checkbox11.fieldValue = 'PCP Referral ';
        Checkbox11.totalWidth = '220';
        Checkbox11.isNewLine = false;
        Checkbox11.requireNewLineInTemplate = true;
        docu.subFields.add(Checkbox11);   
        
      
      // UI_Other
        UI_Other = new SCM_MergeFieldCheckbox('Other','Other');       
        UI_Other.fieldValue ='Other';
        UI_Other.totalWidth = '700';
        UI_Other.isNewLine = true;
        docu.subFields.add(UI_Other);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('OtherDoc1', '');
        OtherDoc1.label = 'Other Documentation :';       
        OtherDoc1.totalWidth = '420';
        OtherDoc1.isNewLine = true;
        docu.subFields.add(OtherDoc1);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('OtherDoc2', '');
        OtherDoc2.totalWidth = '420';
        OtherDoc2.isNewLine = true;
        docu.subFields.add(OtherDoc2);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('OtherDoc3', '');
        OtherDoc3.totalWidth = '420';
        OtherDoc3.isNewLine = true;
        docu.subFields.add(OtherDoc3);
        
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
        docu.subFields.add(IniRequest); 
      
        UI_InitialRequestDate = new SCM_MergeField();
        UI_InitialRequestDate.key = 'UI_InitialRequestDate';
        UI_InitialRequestDate.checked = false;
        UI_InitialRequestDate.displayCheck = false;
        UI_InitialRequestDate.displayTextBox = true;
        UI_InitialRequestDate.displayLabel = false;
        UI_InitialRequestDate.isNewLine = false;
        UI_InitialRequestDate.IsRequired = false;
        UI_InitialRequestDate.fieldValue = Date.today().format();
        UI_InitialRequestDate.totalWidth = '300';
        UI_InitialRequestDate.fieldType = SCM_MergeField.FieldTypes.dateField;
        docu.subFields.add(UI_InitialRequestDate);
      
        this.mergeFields.add(docu);
       //.....................................................................
        
        SCM_MergeFieldGroup docu2 = new SCM_MergeFieldGroup();
        docu2.label = 'Follow Up:';
        docu2.headerText = 'To begin the treatment now,please complete the following';       
        docu2.key = 'Follow Up';
        
        //MergeSection
        UI_GATCF = new SCM_MergeSection();        
        UI_GATCF.key = 'UI_GATCF';
        this.mergeSections.add(UI_GATCF);      
        
        UI_chkGATCF = new SCM_MergeFieldCheckbox('UI_chkGATCF', 'GATCF');       
        UI_chkGATCF.fieldValue = '';
        UI_chkGATCF.displayLabel=false;
        UI_chkGATCF.displayExtraHTML = true;
        UI_chkGATCF.extraHTML='GATCF <br>'
        +'To facilitate the GATCF process, please <br>'
        +'complete the following medical documentation <br>'
        +'and fax directly to the GATCF pharmacy <br>'
        +'at (800) 545- 0612 .' ;
        UI_chkGATCF.isRequired=false;
        UI_chkGATCF.totalWidth = '280';
        UI_chkGATCF.checked = false; 
        UI_chkGATCF.isNewLine=true;
        docu2.subFields.add(UI_chkGATCF); 
        
        //MergeSection
        UI_Starter = new SCM_MergeSection();        
        UI_Starter.key = 'UI_Starter';
        this.mergeSections.add(UI_Starter); 
        
        //  UI_chkStarter
        UI_chkStarter = new SCM_MergeFieldCheckbox('UI_chkStarter', 'STARTER:');       
        UI_chkStarter.fieldValue = '';
        UI_chkStarter.displayLabel=false;
        UI_chkStarter.displayExtraHTML = true;
        UI_chkStarter.extraHTML='STARTER: <br>'
        +'Please complete the attached Starter <br>'
        +'of Medical Necessity and fax directly to <br>'
        +' ACCESS SOLUTIONS at (800) 545- 0612 .' ;
        UI_chkStarter.isRequired=false;
        UI_chkStarter.totalWidth = '300';
        UI_chkStarter.checked = false; 
        UI_chkStarter.isNewLine = false ;
        docu2.subFields.add(UI_chkStarter);
        
        
        //MergeSection
        UI_GATCF_AttachedSMN = new SCM_MergeSection();        
        UI_GATCF_AttachedSMN.key = 'UI_GATCF_AttachedSMN';
        this.mergeSections.add(UI_GATCF_AttachedSMN); 
        
        //  UI_chkSMN
        UI_chkSMN = new SCM_MergeFieldCheckbox('SMN','Attached Statement of Medical Necessity (SMN).');       
        UI_chkSMN.fieldValue ='Attached Statement of Medical Necessity (SMN).\r\n';
        UI_chkSMN.totalWidth = '900';
        UI_chkSMN.checked = false;       
        UI_chkSMN.isNewLine = true;
        docu2.subFields.add(UI_chkSMN);
                
        //MergeSection
        UI_GATCF_Prescription = new SCM_MergeSection();        
        UI_GATCF_Prescription.key = 'UI_GATCF_Prescription';
        this.mergeSections.add(UI_GATCF_Prescription); 
        
        //  UI_chkPrescription
        UI_chkPrescription = new SCM_MergeFieldCheckbox('Prescription','Prescription');       
        UI_chkPrescription.fieldValue ='Prescription.\r\n';
        UI_chkPrescription.totalWidth = '900';
        UI_chkPrescription.isNewLine = true;
        UI_chkPrescription.checked = false;
       
        docu2.subFields.add(UI_chkPrescription);
        
        this.mergeFields.add(docu2);   
        
   	 	//16.UI_Comments(Key CommentField)
    	this.mergeFields.add(new SCM_MF_Comments());
     
    }
    public override void getLatestValues()
    {
    
    	if(Checkbox1.checked == false && Checkbox2.checked == false && Checkbox3.checked == false && Checkbox4.checked == false 
       	&& Checkbox5.checked == false && Checkbox6.checked == false && Checkbox7.checked == false && Checkbox8.checked == false 
       	&& Checkbox9.checked == false && Checkbox10.checked == false && Checkbox11.checked == false && UI_Other.checked == false)
	       {
	        UI_Additional_Docs.visible = false;
	       }
	       else
	       {
	       UI_Additional_Docs.visible = true;
	       }
     
      if (UI_chkGATCF.checked == false)
     		UI_GATCF.visible=false;
      else 
      		UI_GATCF.visible= true;
     
      if (UI_chkSMN.checked == false) 
      		UI_GATCF_AttachedSMN.visible=false;
      else 
      		UI_GATCF_AttachedSMN.visible=true;
     
       if (UI_chkPrescription.checked == false) 
       		UI_GATCF_Prescription.visible=false; 
       else 
       		UI_GATCF_Prescription.visible=true; 
    
       if (UI_chkStarter.checked == false) 
       		UI_Starter.visible=false;
       else 
       		UI_Starter.visible=true;
      
       if(UI_Other.checked == false){
                OtherDoc1.mergeValue = '';
                OtherDoc2.mergeValue = '';
                OtherDoc3.mergeValue = '';}
           
           
         if(UI_InitialRequestDate.getMergeValue() == null || UI_InitialRequestDate.getMergeValue().length() <= 0)
                UI_InitialRequest.visible = false;
         else
            	UI_InitialRequest.visible = true;
    }
       
    
}