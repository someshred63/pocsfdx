/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : HER_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL
    // PRODUCT GROUP     : Oncology / Herceptin
    // Type              : Fax Coversheet
    // Word Template     : GATCF_InfoDocRet_Her.doc    
    // Label in SF       : GATCF_InfoDocRet_Her 
    
/********************************************************************/
public class SCM_MD_FAX_INF_DOC_RET_HER extends SCM_MergeDocument implements IStandardComboBox {
    
     private string caseRecordType;
     private string pid;
     
     private SCM_MergeSection CompletedGATCFAppInfo;
     private SCM_MergeSection PANandReleaseofInfoSec;
     private SCM_MergeSection FlowSheetsInfusionRecordsInfo;
     private SCM_MergeSection InsDenialEOBChkInfo;
     private SCM_MergeSection PatientsICDChkInfo;
     private SCM_MergeSection GrossIncome100KChkInfo;
     private SCM_MergeSection ShippingInstructionsChkInfo;
     private SCM_MergeSection DateandorPhySigChkInfo;
     
     private SCM_MergeFieldCheckbox CompletedGATCFAppChk;
     private SCM_MergeFieldCheckbox PANandReleaseofInfoChk;
     private SCM_MergeFieldCheckbox FlowSheetsInfusionRecordsChk ;
     private SCM_MergeFieldCheckbox InsDenialEOBChk;
     private SCM_MergeFieldCheckbox PatientsICDChk;
     private SCM_MergeFieldCheckbox GrossIncome100KChk;
     private SCM_MergeFieldCheckbox ShippingInstructionsChk;
     private SCM_MergeFieldCheckbox DateandorPhySigChk;
      
     public SCM_MD_FAX_INF_DOC_RET_HER(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }        
    public override void createMergeFields() {
        
        String patientId = selectedCase.patient_gne__r.Id;
        caseRecordType = selectedCase.RecordType.Name ;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        string pid = selectedCase.Patient_gne__c;
                
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        //2. GATCF Phone Herceptin
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));        
        //3. GATCF Fax Herceptin
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));        
        //4. URL Herceptin
        string productName = selectedCase.Product_gne__c;
        if ( productName == 'Herceptin'){ 
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        }        
        // 5 Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));                       
        // 6 Addressed To (RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        // 7 Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        //this.mergeRecipientInfo.add(new SCM_MF_FaxRECFAX(physicianId));        
        // 8 From
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));        
        // 9 Extension        
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));         
        //10. Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        //11. Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        //12. Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        //13. Product Name
        this.mergeRecipientInfo.add(new  SCM_MF_Product_Name(selectedCase));
        //14. Privacy Notice
        if ( productName == 'Herceptin'){
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        }        
        //15. Confidentiality Notice
        if ( productName == 'Herceptin'){
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        }        
        //---------------------------------second page-----------------------------------------//              
        //  Documentation:
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.label = 'Additional Information Required:';
        formInfo.headerText = 'Additional Information Required:';               
        formInfo.key = 'Form Information';
       
        //1. Completed GATCF App
        CompletedGATCFAppChk = 
                new SCM_MergeFieldCheckbox('UI_CompletedGATCFApp', 'A completed Genentech Access'+
                                                ' To Care Foundation Application Form');       
        //CompletedGATCFAppChk.fieldValue = '';
        CompletedGATCFAppChk.totalWidth = '270';
        CompletedGATCFAppChk.displayLabel=false;
        CompletedGATCFAppChk.displayExtraHTML = true; 
        CompletedGATCFAppChk.extraHTML='A completed Genentech Access'+
                                                ' To Care Foundation Application Form';
        CompletedGATCFAppChk.isNewLine = true;
        formInfo.subFields.add(CompletedGATCFAppChk);

        //2. PAN and Release of Info
        PANandReleaseofInfoChk = 
                new SCM_MergeFieldCheckbox('UI_PANandReleaseofInfo', 'Genentech Patient Authorization '+
                                                'Notification & Release of Information form');       
        //PANandReleaseofInfoChk.fieldValue = '';
        PANandReleaseofInfoChk.totalWidth = '270';
        PANandReleaseofInfoChk.displayLabel=false;
        PANandReleaseofInfoChk.displayExtraHTML = true; 
        PANandReleaseofInfoChk.extraHTML='Genentech Patient Authorization '+
                                                'Notification & Release of Information form';
        PANandReleaseofInfoChk.isNewLine = false;
        formInfo.subFields.add(PANandReleaseofInfoChk);
        
        //3. Flow Sheets Infusion Records
        FlowSheetsInfusionRecordsChk = 
                new SCM_MergeFieldCheckbox('UI_FlowSheetsInfusionRecords', 'Flow sheets/Infusion'+
                                        ' records that reflect administration of product');       
        //FlowSheetsInfusionRecordsChk.fieldValue = '';
        FlowSheetsInfusionRecordsChk.totalWidth = '270';
        FlowSheetsInfusionRecordsChk.displayLabel=false;
        FlowSheetsInfusionRecordsChk.displayExtraHTML = true; 
        FlowSheetsInfusionRecordsChk.extraHTML='Flow sheets/Infusion'+
                                        ' records that reflect administration of product';
        FlowSheetsInfusionRecordsChk.isNewLine = true;
        formInfo.subFields.add(FlowSheetsInfusionRecordsChk);
        
        //4. Insurance Denial Letter/EOB
        InsDenialEOBChk = 
                new SCM_MergeFieldCheckbox('UI_InsDenialEOB', 'Insurance denial letter/EOB or a '+ 
                    'statement on your office letterhead confirming patient\'s lack of insurance');       
        //InsDenialEOBChk.fieldValue = '';
        InsDenialEOBChk.totalWidth = '320';
        InsDenialEOBChk.displayLabel=false;
        InsDenialEOBChk.isNewLine = false;
        InsDenialEOBChk.displayExtraHTML = true; 
        InsDenialEOBChk.extraHTML='Insurance denial letter/EOB or a '+ 
                    'statement on your office letterhead confirming patient\'s lack of insurance';
        formInfo.subFields.add(InsDenialEOBChk);
        
        //5. Patients ICD
        PatientsICDChk = 
                new SCM_MergeFieldCheckbox('UI_PatientsICD', 'Patient\'s ICD-9 code/Diagnosis');       
        PatientsICDChk.fieldValue = '';
        PatientsICDChk.totalWidth = '270';
        PatientsICDChk.isNewLine = true;
        formInfo.subFields.add(PatientsICDChk);
        
        //6. UI_GrossIncome100K
        GrossIncome100KChk = 
                new SCM_MergeFieldCheckbox('UI_GrossIncome100K', 'Patient\'s Household Adjusted '+
                                                'Gross Income is less than $100,000');       
        GrossIncome100KChk.fieldValue = '';
        GrossIncome100KChk.totalWidth = '270';
        GrossIncome100KChk.displayLabel=false;
        GrossIncome100KChk.displayExtraHTML = true; 
        GrossIncome100KChk.extraHTML='Patient\'s Household Adjusted '+
                                                'Gross Income is less than $100,000';
        GrossIncome100KChk.isNewLine = false;
        formInfo.subFields.add(GrossIncome100KChk);
        
        //7. Shipping Instructions
        ShippingInstructionsChk = 
                new SCM_MergeFieldCheckbox('UI_ShippingInstructions', 'Shipping Instructions');       
        ShippingInstructionsChk.fieldValue = '';
        ShippingInstructionsChk.totalWidth = '270';
        ShippingInstructionsChk.isNewLine = true;
        formInfo.subFields.add(ShippingInstructionsChk);
        
        //8. Date and or Phy Signature
        DateandorPhySigChk = 
                new SCM_MergeFieldCheckbox('UI_DateandorPhySig', 'Date and/or Physician Signature');       
        DateandorPhySigChk.fieldValue = '';
        DateandorPhySigChk.totalWidth = '270';
        DateandorPhySigChk.isNewLine = false;
        formInfo.subFields.add(DateandorPhySigChk);  
        
        this.mergeFields.add(formInfo);
        
        //comments
        //this.mergeFields.add(new SCM_MF_Comments());
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        comments.headerText = 'Comments: ';       
        comments.key = 'Comment';           
        
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        CommentField.key = 'Comments';                       
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);       
        
        // Merge Sections
                
        CompletedGATCFAppInfo = new SCM_MergeSection();                 
        //CompletedGATCFAppInfo.key = 'CompletedGATCFApp';
        CompletedGATCFAppInfo.key = 'UI_CompletedGATCFApp';        
        this.mergeSections.add(CompletedGATCFAppInfo);
        
        PANandReleaseofInfoSec = new SCM_MergeSection();                 
        //PANandReleaseofInfoSec.key = 'PANandReleaseofInfo';
        PANandReleaseofInfoSec.key = 'UI_PANandReleaseofInfo';
        this.mergeSections.add(PANandReleaseofInfoSec);      
        
        FlowSheetsInfusionRecordsInfo = new SCM_MergeSection();                 
        //FlowSheetsInfusionRecordsInfo.key = 'FlowSheetsInfusionRecords';
        FlowSheetsInfusionRecordsInfo.key = 'UI_FlowSheetsInfusionRecords';
        this.mergeSections.add(FlowSheetsInfusionRecordsInfo);
        
        InsDenialEOBChkInfo = new SCM_MergeSection();                 
        //InsDenialEOBChkInfo.key = 'InsDenialEOB';
        InsDenialEOBChkInfo.key = 'UI_InsDenialEOB';
        this.mergeSections.add(InsDenialEOBChkInfo);
        
        PatientsICDChkInfo = new SCM_MergeSection();                 
        //PatientsICDChkInfo.key = 'PatientsICD';
        PatientsICDChkInfo.key = 'UI_PatientsICD';
        this.mergeSections.add(PatientsICDChkInfo);
        
        GrossIncome100KChkInfo = new SCM_MergeSection();                 
        //GrossIncome100KChkInfo.key = 'GrossIncome100K';
        GrossIncome100KChkInfo.key = 'UI_GrossIncome100K';
        this.mergeSections.add(GrossIncome100KChkInfo);
        
        ShippingInstructionsChkInfo = new SCM_MergeSection();                 
        //ShippingInstructionsChkInfo.key = 'ShippingInstructions';
        ShippingInstructionsChkInfo.key = 'UI_ShippingInstructions';
        this.mergeSections.add(ShippingInstructionsChkInfo);
        
        DateandorPhySigChkInfo = new SCM_MergeSection();                 
        //DateandorPhySigChkInfo.key = 'DateandorPhySig';
        DateandorPhySigChkInfo.key = 'UI_DateandorPhySig';
        this.mergeSections.add(DateandorPhySigChkInfo);
        
    }
    
     public override void getLatestValues()  {
        CompletedGATCFAppInfo.visible = CompletedGATCFAppChk.checked;
        PANandReleaseofInfoSec.visible = PANandReleaseofInfoChk.checked;  
        FlowSheetsInfusionRecordsInfo.visible = FlowSheetsInfusionRecordsChk.checked;
        InsDenialEOBChkInfo.visible = InsDenialEOBChk.checked; 
        PatientsICDChkInfo.visible = PatientsICDChk.checked;
        GrossIncome100KChkInfo.visible = GrossIncome100KChk.checked;
        ShippingInstructionsChkInfo.visible = ShippingInstructionsChk.checked;       
        DateandorPhySigChkInfo.visible = DateandorPhySigChk.checked;       
    }
    
}