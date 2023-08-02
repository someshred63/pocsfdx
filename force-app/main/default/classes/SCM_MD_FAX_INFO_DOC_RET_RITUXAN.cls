/********************************************************************/
    // Developer Name    : Vishwanath 
    // Document Name     : RIT_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL
    // PRODUCT GROUP     : Oncology / Rituxan
    // Type              : Fax Coversheet
    // Word Template     : GATCF_Info_Doc_Retrieval_Rit.doc
   
/********************************************************************/    
public class SCM_MD_FAX_INFO_DOC_RET_RITUXAN extends SCM_MergeDocument implements IStandardComboBox
 {
 	private SCM_MergeSection UiCompletedGATCFApp;
    private SCM_MergeSection UiPANandReleaseofInfo;
    private SCM_MergeSection UiFlowSheetsInfusionRecords;
    private SCM_MergeSection UiInsDenialEOB;
    private SCM_MergeSection UiPatientsICD;
    private SCM_MergeSection UiGrossIncome100K;
    private SCM_MergeSection UiShippingInstructions;
    private SCM_MergeSection UiDateandorPhySig;
    
    private SCM_MergeFieldCheckbox UiCompletedGATCFAppChk;
    private SCM_MergeFieldCheckbox UiPANandReleaseofInfoChk;
    private SCM_MergeFieldCheckbox UiFlowSheetsInfusionRecordsChk;
    private SCM_MergeFieldCheckbox UiInsDenialEOBPChk;
    private SCM_MergeFieldCheckbox UiPatientsICDChk;
    private SCM_MergeFieldCheckbox UiGrossIncome100KChk;
    private SCM_MergeFieldCheckbox UiShippingInstructionsChk;
    private SCM_MergeFieldCheckbox UiDateandorPhySigChk;
    
    public SCM_MD_FAX_INFO_DOC_RET_RITUXAN(String caseId, String argLookupId)
    {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() 
    {
        
        String caseRecordType = selectedCase.RecordType.Name;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c;                 
        
        //1. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //2. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
            
        //3. Rit GATCF Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //4. Rit GATCF Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        //5. Rit URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));                          
        
        //6. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(new SCM_MF_AttnFax(physicianId));
                        
        //7. Addressed To (RECNAME)
        this.mergeRecipientInfo.add(new SCM_MF_FaxAdrsTo(physicianId));
        
        //8.Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_FaxRECFAX(physicianId));
        
        //9 From
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        
        //9. Extension        
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType)); 
           
        //10. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate()); 
        
        //11. Patient Full Name
        this.mergeRecipientInfo.add(new SCM_MF_PatientFirstAndLastName(selectedCase));
        
        //12. DOB
        this.mergeRecipientInfo.add(new SCM_MF_Patient_DOB(patientNumber));
        
        //13. Product
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        //14. Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //15. Confidentiality Notice        
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));        
        
        // -------------UI - Second Screen -------------------
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.headerText = 'Additional Information Required:';               
        formInfo.key = 'Additional_Inf_Reqd';
                       
        //Checkboxes
        UiCompletedGATCFAppChk = 
            new SCM_MergeFieldCheckbox('UiCompletedGATCFAppChk',
                'A completed Genentech Access To Care Foundation Application Form');
        UiCompletedGATCFAppChk.fieldValue = '' ;                    
        UiCompletedGATCFAppChk.totalWidth = '900';
        formInfo.subFields.add(UiCompletedGATCFAppChk); 
        
        UiPANandReleaseofInfoChk = 
            new SCM_MergeFieldCheckbox('UiPANandReleaseofInfoChk',
                'Genentech Patient Authorization Notification & Release of Information form');
        UiPANandReleaseofInfoChk.fieldValue = '' ;                    
        UiPANandReleaseofInfoChk.totalWidth = '900';
        formInfo.subFields.add(UiPANandReleaseofInfoChk); 
        
        UiFlowSheetsInfusionRecordsChk = 
           new SCM_MergeFieldCheckbox('UiFlowSheetsInfusionRecordsChk',
           			'Flow sheets/Infusion records that reflect administration of product');
        UiFlowSheetsInfusionRecordsChk.fieldValue = '' ;                    
        UiFlowSheetsInfusionRecordsChk.totalWidth = '900';
        formInfo.subFields.add(UiFlowSheetsInfusionRecordsChk); 
        
        UiInsDenialEOBPChk = new SCM_MergeFieldCheckbox('UiInsDenialEOBPChk'
        	,'Insurance denial letter/EOB or a statement on your office '
        	+ 'letterhead confirming patient\'s lack of insurance');
        	
        UiInsDenialEOBPChk.fieldValue = '' ;                    
        UiInsDenialEOBPChk.totalWidth = '900';
        formInfo.subFields.add(UiInsDenialEOBPChk);                                
        
         UiPatientsICDChk = 
           new SCM_MergeFieldCheckbox('UiPatientsICDChk',
           			'Patient\'s ICD-9 code/Diagnosis');
        UiPatientsICDChk.fieldValue = '' ;                    
        UiPatientsICDChk.totalWidth = '900';
        formInfo.subFields.add(UiPatientsICDChk);
        
         UiGrossIncome100KChk = 
           new SCM_MergeFieldCheckbox('UiGrossIncome100KChk',
           			'Patient\'s Household Adjusted Gross Income is less than $100,000');
        UiGrossIncome100KChk.fieldValue = '' ;                    
        UiGrossIncome100KChk.totalWidth = '900';
        formInfo.subFields.add(UiGrossIncome100KChk);
        
         UiShippingInstructionsChk = 
           new SCM_MergeFieldCheckbox('UiShippingInstructionsChk',
           			'Shipping Instructions');
        UiShippingInstructionsChk.fieldValue = '' ;                    
        UiShippingInstructionsChk.totalWidth = '900';
        formInfo.subFields.add(UiShippingInstructionsChk);
        
         UiDateandorPhySigChk = 
           new SCM_MergeFieldCheckbox('UiDateandorPhySigChk',
           			'Date and/or Physician Signature');
        UiDateandorPhySigChk.fieldValue = '' ;                    
        UiDateandorPhySigChk.totalWidth = '900';
        formInfo.subFields.add(UiDateandorPhySigChk);        
                    
        this.mergeFields.add(formInfo); 
        
        // Merge Sections
        UiCompletedGATCFApp = new SCM_MergeSection();        
        UiCompletedGATCFApp.key = 'UI_CompletedGATCFApp';
        this.mergeSections.add(UiCompletedGATCFApp);
        
        UiPANandReleaseofInfo = new SCM_MergeSection();        
        UiPANandReleaseofInfo.key = 'UI_PANandReleaseofInfo';
        this.mergeSections.add(UiPANandReleaseofInfo);
        
        UiFlowSheetsInfusionRecords = new SCM_MergeSection();        
        UiFlowSheetsInfusionRecords.key = 'UI_FlowSheetsInfusionRecords';
        this.mergeSections.add(UiFlowSheetsInfusionRecords);
        
        UiInsDenialEOB = new SCM_MergeSection();        
        UiInsDenialEOB.key = 'UI_InsDenialEOB';
        this.mergeSections.add(UiInsDenialEOB);
        
        UiPatientsICD = new SCM_MergeSection();        
        UiPatientsICD.key = 'UI_PatientsICD';
        this.mergeSections.add(UiPatientsICD);
        
        UiGrossIncome100K = new SCM_MergeSection();        
        UiGrossIncome100K.key = 'UI_GrossIncome100K';
        this.mergeSections.add(UiGrossIncome100K);
        
        UiShippingInstructions = new SCM_MergeSection();        
        UiShippingInstructions.key = 'UI_ShippingInstructions';
        this.mergeSections.add(UiShippingInstructions);
        
        UiDateandorPhySig = new SCM_MergeSection();        
        UiDateandorPhySig.key = 'UI_DateandorPhySig';
        this.mergeSections.add(UiDateandorPhySig);
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
    
    public override void getLatestValues()
    {
        UiCompletedGATCFApp.visible = UiCompletedGATCFAppChk.checked;
        UiPANandReleaseofInfo.visible = UiPANandReleaseofInfoChk.checked;
        UiFlowSheetsInfusionRecords.visible = UiFlowSheetsInfusionRecordsChk.checked;
        UiInsDenialEOB.visible = UiInsDenialEOBPChk.checked;
        UiPatientsICD.visible = UiPatientsICDChk.checked;
        UiGrossIncome100K.visible = UiGrossIncome100KChk.checked;
        UiShippingInstructions.visible = UiShippingInstructionsChk.checked;
        UiDateandorPhySig.visible = UiDateandorPhySigChk.checked;
    }
 }