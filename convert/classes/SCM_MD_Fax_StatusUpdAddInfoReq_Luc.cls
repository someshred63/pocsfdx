/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : LUC-CMGT-FAX-22_Status_Update-Additional_Information_Required.doc
    // Type              : Fax Coversheet
    // Word Template     : Status_Update_Add_Info_Req.doc    
    // Label in SF       : Status Update / Additional Information
    
/********************************************************************/

public class SCM_MD_Fax_StatusUpdAddInfoReq_Luc extends SCM_MergeDocument implements IStandardComboBox {

    protected String caseId;
    protected String PhysicianId;
    protected String PatientId;
    
    private SCM_MergeSection  UI_InitialRequest;
    private SCM_MergeSection  UI_Additional_Docs;
    private SCM_MergeField IniRequest;
    private SCM_MergeField OtherDoc1;
    private SCM_MergeField OtherDoc2; 
    private SCM_MergeField OtherDoc3;
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
    private SCM_MergeFieldCheckbox Checkbox12;           
    private SCM_MergeFieldCheckbox Checkbox13;
    private SCM_MergeFieldCheckbox Checkbox14;
    
        
    public SCM_MD_Fax_StatusUpdAddInfoReq_Luc(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
    public override void createMergeFields() {
    
        PhysicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        PatientId = selectedCase.patient_gne__r.id;
        
         //ATTN:
         this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(PhysicianId));    
        
        // Addressed To        
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(PhysicianId));

        // Fax No
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(PhysicianId));
        
        // From Ext
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  

        // Case Number
        SCM_MF_CaseNumber casNum = new SCM_MF_CaseNumber(selectedCase);
        this.mergeRecipientInfo.add(casNum);
        
        // Patient Id
        SCM_MF_PatientId patId = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patId);
        
        
        // Date
        SCM_MF_CurrentDate curDate = new SCM_MF_CurrentDate();
        this.mergeRecipientInfo.add(curDate);
        
        // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(PatientId));
        
        // DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(PatientId));
        
        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        // Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        /////////-------Second Screen ------
        
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Documentation:';
        docu.headerText = 'The following additional document(s) are required by the Payer';       
        docu.key = 'Documentation';
        
        //Merge Sections       
        UI_InitialRequest = new SCM_MergeSection();        
        UI_InitialRequest.key = 'UI_InitialRequest';
        this.mergeSections.add(UI_InitialRequest);
        
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);

        
        Checkbox1 = new SCM_MergeFieldCheckbox('SMNComplete', 'SMN (Completed)');       
        Checkbox1.fieldValue = 'SMN (Completed) \r\n';
        Checkbox1.totalWidth = '270';
        Checkbox1.isNewLine = true;
        docu.subFields.add(Checkbox1);
                 
        Checkbox2 = new SCM_MergeFieldCheckbox('HisPhysTreat', 'History/Physical/Treatment Plan');
        Checkbox2.fieldValue = 'History/Physical/Treatment Plan \r\n';
        Checkbox2.totalWidth = '270';
        Checkbox2.isNewLine = false;         
        docu.subFields.add(Checkbox2);  
             
        Checkbox3 = 
                new SCM_MergeFieldCheckbox('CurrentVA', 'Current VA');          
        Checkbox3.fieldValue = 'Current VA \r\n';       
        Checkbox3.totalWidth = '270';
        Checkbox3.isNewLine = true;
        docu.subFields.add(Checkbox3);
        
        Checkbox4 = new SCM_MergeFieldCheckbox('FA', 'FA');          
        Checkbox4.fieldValue = 'FA \r\n';       
        Checkbox4.totalWidth = '270';
        Checkbox4.isNewLine = false;
        docu.subFields.add(Checkbox4);
        
        Checkbox5 = 
            new SCM_MergeFieldCheckbox('ProgressNotes', 'Progress Notes');          
        Checkbox5.fieldValue = 'Progress Notes \r\n';       
        Checkbox5.totalWidth = '270';
        Checkbox5.isNewLine = true;
        docu.subFields.add(Checkbox5);
        
        Checkbox6 = 
            new SCM_MergeFieldCheckbox('Prescription', 'Prescription');         
        Checkbox6.fieldValue = 'Prescription \r\n';     
        Checkbox6.totalWidth = '270';
        Checkbox6.isNewLine = false;
        docu.subFields.add(Checkbox6);
        
        Checkbox7 = new SCM_MergeFieldCheckbox('OCT', 'OCT');            
        Checkbox7.fieldValue = 'OCT \r\n';      
        Checkbox7.totalWidth = '270';
        Checkbox7.isNewLine = true;
        docu.subFields.add(Checkbox7);
        
        Checkbox8 = 
            new SCM_MergeFieldCheckbox('VABeforeTreat', 'VA Before Treatment');         
        Checkbox8.fieldValue = 'VA Before Treatment \r\n';      
        Checkbox8.totalWidth = '270';
        Checkbox8.isNewLine = false;
        docu.subFields.add(Checkbox8);
        
        Checkbox9 = 
            new SCM_MergeFieldCheckbox('LesionSize', 'Lesion Size');            
        Checkbox9.fieldValue = 'LesionSize \r\n';       
        Checkbox9.totalWidth = '270';
        Checkbox9.isNewLine = true;
        docu.subFields.add(Checkbox9);
        
        Checkbox10 = 
            new SCM_MergeFieldCheckbox('PrioAuthForm', 'Prior Authorization Form');         
        Checkbox10.fieldValue = 'Prior Authorization Form (signed & completed) \r\n';       
        Checkbox10.totalWidth = '270';
        Checkbox10.isNewLine = false;
        docu.subFields.add(Checkbox10);
        
        Checkbox11 = 
            new SCM_MergeFieldCheckbox('PCPReferral', 'PCP Referral');          
        Checkbox11.fieldValue = 'PCP Referral \r\n';        
        Checkbox11.totalWidth = '270';
        Checkbox11.isNewLine = true;
        docu.subFields.add(Checkbox11);
        
        Checkbox12 = 
            new SCM_MergeFieldCheckbox('LesionType', 'Lesion Type');            
        Checkbox12.fieldValue = 'Lesion Type \r\n';     
        Checkbox12.totalWidth = '270';
        Checkbox12.isNewLine = false;
        docu.subFields.add(Checkbox12);
        
        Checkbox13 = 
            new SCM_MergeFieldCheckbox('LesionPosition', 'Lesion Position');            
        Checkbox13.fieldValue = 'Lesion Position \r\n';     
        Checkbox13.totalWidth = '270';
        Checkbox13.isNewLine = true;
        docu.subFields.add(Checkbox13);
        
        Checkbox14 = 
            new SCM_MergeFieldCheckbox('EyeAffected', 'Eye Affected (right, left, both)');          
        Checkbox14.fieldValue = 'Eye Affected (right, left, both) \r\n';        
        Checkbox14.totalWidth = '270';
        Checkbox14.isNewLine = false;
        docu.subFields.add(Checkbox14);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('OtherDoc1', 'Other Documentation 1');
        OtherDoc2 = new SCM_MF_OtherDocuments('OtherDoc2', 'Other Documentation 2');
        OtherDoc3 = new SCM_MF_OtherDocuments('OtherDoc3', 'Other Documentation 3');
        docu.subFields.add(OtherDoc1);
        docu.subFields.add(OtherDoc2);
        docu.subFields.add(OtherDoc3);
        
        
        IniRequest = new SCM_MergeField();
        IniRequest.fieldValue = '';
        IniRequest.key = 'IniRequest';     
        IniRequest.checked = false;
        IniRequest.totalWidth = '420';
        IniRequest.displayCheck = false;
        IniRequest.displayTextBox = true;
        IniRequest.fieldType = SCM_MergeField.Fieldtypes.dateField;
        IniRequest.displayLabel = true;
        IniRequest.Label = 'Initial Request';
        IniRequest.className = 'SCM_MergeField';
        IniRequest.isRequired = false;        
        docu.subFields.add(IniRequest);                                                        
        
        this.mergeFields.add(docu);
        
        
        
       //Comments        
        SCM_MF_Comments  comments = new SCM_MF_Comments();
        this.mergeFields.add(comments);
        
    }
    
     public override void getLatestValues()
    {
        if(IniRequest.getMergeValue() == null || IniRequest.getMergeValue().length() <= 0)
                UI_InitialRequest.visible = false;
         else
                UI_InitialRequest.visible = true;
        if((OtherDoc1.getMergeValue() == null || OtherDoc1.getMergeValue().length()<= 0 )         
           && (OtherDoc2.getMergeValue() == null || OtherDoc2.getMergeValue().length()<= 0 )   
           && (OtherDoc3.getMergeValue() == null || OtherDoc3.getMergeValue().length()<= 0 )
           && Checkbox1.checked == false && Checkbox2.checked == false && Checkbox3.checked == false && Checkbox4.checked == false 
           && Checkbox5.checked == false && Checkbox6.checked == false && Checkbox7.checked == false && Checkbox8.checked == false 
           && Checkbox9.checked == false && Checkbox10.checked == false && Checkbox11.checked == false 
           && Checkbox12.checked == false && Checkbox13.checked == false && Checkbox14.checked == false 
             )       
              UI_Additional_Docs.visible = false;
        else
              UI_Additional_Docs.visible = true;


                
    }

 }