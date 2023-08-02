/********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : AVA_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
    // PRODUCT GROUP     : Oncology / Avastin
    // Type              : Fax Coversheet
    // Word Template     : GATCF_Info_Doc_Retrieval.doc    
    // Label in SF       : GATCF Information / Documentation Retrieval
    
/********************************************************************/
 
public class SCM_MD_Fax_INFODOCRETRIEVAL_Avastin extends SCM_MergeDocument implements IStandardComboBox
{
	  
	private SCM_MergeSection UICompletedGATCFApp;
	/**
	private SCM_MergeSection UI_PANandReleaseofInfo;
	private SCM_MergeSection UI_FlowSheetsInfusionRecords;
	private SCM_MergeSection UI_InsDenialEOB;
	private SCM_MergeSection UI_PatientsICD;
	private SCM_MergeSection UI_GrossIncome100K;
	private SCM_MergeSection UI_ShippingInstructions;
	private SCM_MergeSection UI_DateandorPhySig;
	*/
	private SCM_MergeFieldCheckbox UICompletedGATCFAppChk;
	private SCM_MergeFieldCheckbox UI_PANandReleaseofInfoChk;
	private SCM_MergeFieldCheckbox UI_FlowSheetsInfusionRecordsChk;
	private SCM_MergeFieldCheckbox UI_InsDenialEOBChk;
	private SCM_MergeFieldCheckbox UI_PatientsICDChk;
	private SCM_MergeFieldCheckbox UI_GrossIncome100KChk;
	private SCM_MergeFieldCheckbox UI_ShippingInstructionsChk;
	private SCM_MergeFieldCheckbox UI_DateandorPhySigChk;
			
    public SCM_MD_Fax_INFODOCRETRIEVAL_Avastin(String caseID, String argLookupId)
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
        
        //Phone (800) 530-3083 (GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //Fax (877) 428-2326 (GATCF_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
         
        //url www.AvastinAcessSolutions.com (GATCF_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
        
        // Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
          
        // Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
  
        // Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
       
       // From and EXt
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  


        //Patient full name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));

        
        // Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //Patient DOB 
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));

        
        //product name 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase)); 
         
         
        //privacy notice Avastin
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase)); 
               
        //confid notice
       	this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase)); 
        
        //---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Additional Information Required';       
        formInformation.key = 'Additional Information Required';
        
        //Merge Sections       
        UICompletedGATCFApp = new SCM_MergeSection();        
        UICompletedGATCFApp.key = 'UI_CompletedGATCFApp';
        this.mergeSections.add(UICompletedGATCFApp);
        
        //Checkboxes
        UICompletedGATCFAppChk =  new SCM_MergeFieldCheckbox('UI_CompletedGATCFApp','A completed Genentech® Access To Care Foundation Application Form');
        UICompletedGATCFAppChk.fieldValue = 'A completed Genentech® Access To Care Foundation Application Form \r\n';
        UICompletedGATCFAppChk.totalWidth = '900';
        formInformation.subFields.add(UICompletedGATCFAppChk);
        
        UI_PANandReleaseofInfoChk =  new SCM_MergeFieldCheckbox('UI_PANandReleaseofInfo','Genentech® Patient Authorization Notification & Release of Information form');
        UI_PANandReleaseofInfoChk.fieldValue = 'Genentech® Patient Authorization Notification & Release of Information form \r\n';
        UI_PANandReleaseofInfoChk.totalWidth = '900';
        formInformation.subFields.add(UI_PANandReleaseofInfoChk);        
       
        UI_FlowSheetsInfusionRecordsChk = 
                new SCM_MergeFieldCheckbox('UI_FlowSheetsInfusionRecords','Flow sheets/Infusion records that reflect administration of product');
        UI_FlowSheetsInfusionRecordsChk.fieldValue = 'Flow sheets/Infusion records that reflect administration of product \r\n';
        UI_FlowSheetsInfusionRecordsChk.totalWidth = '900';
        formInformation.subFields.add(UI_FlowSheetsInfusionRecordsChk);        
        
        UI_InsDenialEOBChk =  new SCM_MergeFieldCheckbox('UI_InsDenialEOB','Insurance denial letter/EOB or a statement on your office letterhead confirming patient\'s lack of insurance');
        UI_InsDenialEOBChk.fieldValue = 'Insurance denial letter/EOB or a statement on your office letterhead confirming patient\'s lack of insurance \r\n';
        UI_InsDenialEOBChk.totalWidth = '900';
        formInformation.subFields.add(UI_InsDenialEOBChk);        
               
        UI_PatientsICDChk =new SCM_MergeFieldCheckbox('UI_PatientsICD','Patient\'s ICD-9 code/Diagnosis');
        UI_PatientsICDChk.fieldValue = 'Patient\'s ICD-9 code/Diagnosis \r\n';
        UI_PatientsICDChk.totalWidth = '900';
        formInformation.subFields.add(UI_PatientsICDChk);        
        
        UI_GrossIncome100KChk =new SCM_MergeFieldCheckbox('UI_GrossIncome100K','Patient\'s Household Adjusted Gross Income is less than $100,000');
        UI_GrossIncome100KChk.fieldValue = 'Patient\'s Household Adjusted Gross Income is less than $100,000 \r\n';
        UI_GrossIncome100KChk.totalWidth = '900';
        formInformation.subFields.add(UI_GrossIncome100KChk);        
               
        UI_ShippingInstructionsChk =new SCM_MergeFieldCheckbox('UI_ShippingInstructions','Shipping Instructions');
        UI_ShippingInstructionsChk.fieldValue = 'Shipping Instructions \r\n';
        UI_ShippingInstructionsChk.totalWidth = '900';
        formInformation.subFields.add(UI_ShippingInstructionsChk);        
       
        UI_DateandorPhySigChk =new SCM_MergeFieldCheckbox('UI_DateandorPhySig','Date and/or Physician Signature');
        UI_DateandorPhySigChk.fieldValue = 'Date and/or Physician Signature \r\n';
        UI_DateandorPhySigChk.totalWidth = '900';
        formInformation.subFields.add(UI_DateandorPhySigChk);        
        this.mergeFields.add(formInformation); 
             
		
		/**       

        UI_PANandReleaseofInfo = new SCM_MergeSection();        
        UI_PANandReleaseofInfo.key = 'UI_PANandReleaseofInfo';
        this.mergeSections.add(UI_PANandReleaseofInfo);
         
        UI_FlowSheetsInfusionRecords = new SCM_MergeSection();        
        UI_FlowSheetsInfusionRecords.key = 'UI_FlowSheetsInfusionRecords';
        this.mergeSections.add(UI_FlowSheetsInfusionRecords);
        
        UI_InsDenialEOB = new SCM_MergeSection();        
        UI_InsDenialEOB.key = 'UI_InsDenialEOB';
        this.mergeSections.add(UI_InsDenialEOB);
                            
        UI_PatientsICD = new SCM_MergeSection();        
        UI_PatientsICD.key = 'UI_PatientsICD';
        this.mergeSections.add(UI_PatientsICD);
        
        UI_GrossIncome100K = new SCM_MergeSection();        
        UI_GrossIncome100K.key = 'UI_GrossIncome100K';
        this.mergeSections.add(UI_GrossIncome100K);
        
        UI_ShippingInstructions = new SCM_MergeSection();        
        UI_ShippingInstructions.key = 'UI_ShippingInstructions';
        this.mergeSections.add(UI_ShippingInstructions);
        
        UI_DateandorPhySig = new SCM_MergeSection();        
        UI_DateandorPhySig.key = 'UI_DateandorPhySig';
        this.mergeSections.add(UI_DateandorPhySig);
         */                                                        
        SCM_MergeFieldGroup comments = new SCM_MF_Comments();        
        this.mergeFields.add(comments);  
    }
    
     public override void getLatestValues()
    {
    	/**
        UICompletedGATCFApp.visible = UICompletedGATCFAppChk.checked;
        UI_PANandReleaseofInfo.visible = UI_PANandReleaseofInfoChk.checked;
        UI_FlowSheetsInfusionRecords.visible = UI_FlowSheetsInfusionRecordsChk.checked;
        UI_InsDenialEOB.visible = UI_InsDenialEOBChk.checked;
        UI_PatientsICD.visible = UI_PatientsICDChk.checked;
        UI_GrossIncome100K.visible = UI_GrossIncome100KChk.checked;
        UI_ShippingInstructions.visible = UI_ShippingInstructionsChk.checked;
        UI_DateandorPhySig.visible = UI_DateandorPhySigChk.checked;
        */
        	
        	if ( (UICompletedGATCFAppChk.checked == false)&&
        		(UI_PANandReleaseofInfoChk.checked == false)&&
        		(UI_FlowSheetsInfusionRecordsChk.checked == false)&&
        		(UI_InsDenialEOBChk.checked == false)&&
        		(UI_PatientsICDChk.checked == false) &&
        		(UI_GrossIncome100KChk.checked == false)&&
        		(UI_ShippingInstructionsChk.checked == false)&&
        		(UI_DateandorPhySigChk.checked == false))
        		{
        			UICompletedGATCFApp.visible = false;
        		}
        	else
        	{
        			UICompletedGATCFApp.visible = true;
        	}	
        
        //UICompletedGATCFApp.visible = true;
    }
}