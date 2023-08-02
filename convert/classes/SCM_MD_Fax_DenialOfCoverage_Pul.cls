/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : PUL-CMGT-FAX-12_Denial_of_Coverage.doc
    // PRODUCT GROUP     : Pulmonary / Pulmozyme
    // Type              : Fax Coversheet
    // Word Template     : DenialofCoverage.doc
    // Label in SF       : DenialofCoverage
    
/********************************************************************/
public class SCM_MD_Fax_DenialOfCoverage_Pul extends SCM_MergeDocument implements IStandardComboBox {
	
	private SCM_MergeSection UI_Additional_Docs;
	private SCM_MergeSection UI_PUL_ReferredtoGATCF;
	private SCM_MergeSection UI_PUL_ReferredtoAppeals;
	private SCM_MergeSection UI_PUL_FaxDenialLetter;
	
	private SCM_MergeFieldCheckbox UI_SMNComplete;
    private SCM_MergeFieldCheckbox UI_HisPhysTreat;
    private SCM_MergeFieldCheckbox UI_GrowthChart;
    private SCM_MergeFieldCheckbox UI_KaryotypeResults;
    private SCM_MergeFieldCheckbox UI_ProgressNotes;
    private SCM_MergeFieldCheckbox UI_Prescription;
    private SCM_MergeFieldCheckbox UI_BoneAgeReport;
    private SCM_MergeFieldCheckbox UI_RenalFunctionsResults;
    private SCM_MergeFieldCheckbox UI_StimTestReport;
    private SCM_MergeFieldCheckbox UI_PrioAuthForm;
    private SCM_MergeFieldCheckbox UI_PCPReferral;    
    private SCM_MergeFieldCheckbox UI_PUL_ReferredtoGATCFchk;
    private SCM_MergeFieldCheckbox UI_PUL_ReferredtoAppealschk;
    private SCM_MergeFieldCheckbox UI_PUL_FaxDenialLetterchk;
    private SCM_MergeFieldCheckbox UI_Other;   
        
    
    //Text Boxes 
	private SCM_MF_OtherDocuments UI_OtherDoc1;
    private SCM_MF_OtherDocuments UI_OtherDoc2;
    private SCM_MF_OtherDocuments UI_OtherDoc3;                          
        
    public SCM_MD_Fax_DenialOfCoverage_Pul(String caseId, String argLookupId) {         
        super(caseId, argLookupId);
    }
    
    public override void createMergeFields() {
    	//Case number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));     
        
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));  
        //3.CR_Phone ( key CR_Phone)
    		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        //CR_Phone
        this.mergefields.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));        
        
        //CR_Fax
        this.mergefields.add(new SCM_MF_Product_Fax_CR(selectedCase));        
        
        //CR_URL
        this.mergefields.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // Attn:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));        
        
        // To RECNAME_To:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // Fax RECFAX_Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));

        String recordType = selectedCase.RecordType.Name;        

		//Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
                
        // CurrentDate
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());  
        
        //Patient name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));                
        
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id)); 
        
        //Drug
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        // Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //DenialReason Notice
        this.mergeRecipientInfo.add(new SCM_MF_BI_DenialReason(selectedCase.id));
        
        //=======================================================Second Scrren===================================================================//
        
        SCM_MergeFieldGroup docsInfo = new SCM_MergeFieldGroup();
        docsInfo.headerText = 'The Payor will continue the medical review upon receipt of the following addtional document(s):' ;     
        docsInfo.label = 'Documentation:';         
        docsInfo.key = 'Documentation';
         
        // UI_SMNComplete Checkboxes
        UI_SMNComplete = 
            new SCM_MergeFieldCheckbox('UI_SMNComplete', 'SMN (Completed)');
        UI_SMNComplete.fieldValue = 'SMN (Completed)\r\n' ;                    
        UI_SMNComplete.totalWidth = '165';
        docsInfo.subFields.add(UI_SMNComplete);  
        
        // UI_HisPhysTreat Checkboxes
        UI_HisPhysTreat = 
            new SCM_MergeFieldCheckbox('UI_HisPhysTreat', 'History/Physical/Treatment Plan');
        UI_HisPhysTreat.fieldValue = 'History/Physical/Treatment Plan\r\n' ;                    
        UI_HisPhysTreat.totalWidth = '220';
        UI_HisPhysTreat.isNewLine = false;        
        docsInfo.subFields.add(UI_HisPhysTreat);
        
        // UI_GrowthChart Checkboxes
        UI_GrowthChart = 
            new SCM_MergeFieldCheckbox('UI_GrowthChart', 'Growth Chart');
        UI_GrowthChart.fieldValue = 'Growth Chart\r\n' ;                    
        UI_GrowthChart.totalWidth = '180';
        UI_GrowthChart.isNewLine = false;        
        docsInfo.subFields.add(UI_GrowthChart);       
        
        // UI_KaryotypeResults Checkboxes
        UI_KaryotypeResults = 
            new SCM_MergeFieldCheckbox('UI_KaryotypeResults', 'Karyotype Results');
        UI_KaryotypeResults.fieldValue = 'Karyotype Results\r\n' ;                    
        UI_KaryotypeResults.totalWidth = '165';
        UI_KaryotypeResults.isNewLine = true;        
        docsInfo.subFields.add(UI_KaryotypeResults);          
    	
        // UI_ProgressNotes Checkboxes
        UI_ProgressNotes = 
            new SCM_MergeFieldCheckbox('UI_ProgressNotes', 'Progress Notes');
        UI_ProgressNotes.fieldValue = 'Progress Notes\r\n' ;                    
        UI_ProgressNotes.totalWidth = '220';
        UI_ProgressNotes.isNewLine = false;        
        docsInfo.subFields.add(UI_ProgressNotes);   
        
      	// UI_Prescription Checkboxes
        UI_Prescription = 
            new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');
        UI_Prescription.fieldValue = 'Prescription\r\n' ;                    
        UI_Prescription.totalWidth = '180';
        UI_Prescription.isNewLine = false; 
        docsInfo.subFields.add(UI_Prescription);     
        
      	// UI_BoneAgeReport Checkboxes
        UI_BoneAgeReport = 
            new SCM_MergeFieldCheckbox('UI_BoneAgeReport', 'Bone Age Report');
        UI_BoneAgeReport.fieldValue = 'Bone Age Report\r\n' ;                    
        UI_BoneAgeReport.totalWidth = '165';
        UI_BoneAgeReport.isNewLine = true;        
        docsInfo.subFields.add(UI_BoneAgeReport);             
    	
     	// UI_RenalFunctionsResults Checkboxes
        UI_RenalFunctionsResults = 
            new SCM_MergeFieldCheckbox('UI_RenalFunctionsResults', 'Renal Functions Results (CRI Only)');
        UI_RenalFunctionsResults.fieldValue = 'Renal Functions Results (CRI Only)\r\n' ;                    
        UI_RenalFunctionsResults.totalWidth = '220';
        UI_RenalFunctionsResults.isNewLine = false;        
        docsInfo.subFields.add(UI_RenalFunctionsResults);   
        
     	// UI_StimTestReport Checkboxes
        UI_StimTestReport = 
            new SCM_MergeFieldCheckbox('UI_StimTestReport', 'Stim Test(s) Report(s)');
        UI_StimTestReport.fieldValue = 'Stim Test(s) Report(s)\r\n' ;                    
        UI_StimTestReport.totalWidth = '180';
        UI_StimTestReport.isNewLine = false;
        docsInfo.subFields.add(UI_StimTestReport);  
        
     	// UI_PrioAuthForm Checkboxes
        UI_PrioAuthForm = 
            new SCM_MergeFieldCheckbox('UI_PrioAuthForm', 'Prior Authorization Form');
        UI_PrioAuthForm.fieldValue = 'Prior Authorization Form\r\n' ;                    
        UI_PrioAuthForm.totalWidth = '165';
        UI_PrioAuthForm.isNewLine = true;
        docsInfo.subFields.add(UI_PrioAuthForm);
                         
     	// UI_PCPReferral Checkboxes
        UI_PCPReferral = 
            new SCM_MergeFieldCheckbox('UI_PCPReferral', 'PCP Referral');
        UI_PCPReferral.fieldValue = 'PCP Referral\r\n' ;                    
        UI_PCPReferral.totalWidth = '220';
        UI_PCPReferral.isNewLine = false;
        docsInfo.subFields.add(UI_PCPReferral);
        
		// UI_Other
        UI_Other = new SCM_MergeFieldCheckbox('Other','Other');       
        UI_Other.fieldValue ='Other';
        UI_Other.totalWidth = '65';
        UI_Other.isNewLine = true;
        docsInfo.subFields.add(UI_Other);

		//UI_OtherDoc1                
       	UI_OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1', 'Other Documentations');
        UI_OtherDoc1.isNewLine = true;
        UI_OtherDoc1.totalWidth = '400';
        docsInfo.subFields.add(UI_OtherDoc1);                     
		//UI_OtherDoc2                
       	UI_OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
        UI_OtherDoc2.isNewLine = true;
        UI_OtherDoc2.totalWidth = '400';
        docsInfo.subFields.add(UI_OtherDoc2);                     
        //UI_OtherDoc3        
       	UI_OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3', '');
        UI_OtherDoc3.isNewLine = true;
        UI_OtherDoc3.totalWidth = '400';
        docsInfo.subFields.add(UI_OtherDoc3);                     

 		this.mergeFields.add(docsInfo);       
 		
 		SCM_MergeFieldGroup referredTo = new SCM_MergeFieldGroup();
        referredTo.headerText = 'Referred To:';     
        referredTo.label = 'Referred To:' ;        
        referredTo.key = 'ReferredTo';                  
        
        //UI_PUL_ReferredtoGATCF
		UI_PUL_ReferredtoGATCFchk  =  
		  new SCM_MergeFieldCheckbox('UI_PUL_ReferredtoGATCFchk', 'Access Solutions has referred this case to the Genentech® Access to Care Foundation for review');
        UI_PUL_ReferredtoGATCFchk.fieldValue = '' ;                    
        UI_PUL_ReferredtoGATCFchk.totalWidth = '900';
        referredTo.subFields.add(UI_PUL_ReferredtoGATCFchk);     
                	
        //UI_PUL_ReferredtoAppeals
		UI_PUL_ReferredtoAppealschk  =  
		  new SCM_MergeFieldCheckbox('UI_PUL_ReferredtoAppealschk', 'Access Solutions has referred this case to the Appeals Department for review');
        UI_PUL_ReferredtoAppealschk.fieldValue = '' ;                    
        UI_PUL_ReferredtoAppealschk.totalWidth = '900';
        referredTo.subFields.add(UI_PUL_ReferredtoAppealschk);  
        
        //UI_PUL_FaxDenialLetter
		UI_PUL_FaxDenialLetterchk  =  
		  new SCM_MergeFieldCheckbox('UI_PUL_FaxDenialLetterchk', 'Please fax the denial letter to Access Solutions');
        UI_PUL_FaxDenialLetterchk.fieldValue = '' ;                    
        UI_PUL_FaxDenialLetterchk.totalWidth = '900';
        referredTo.subFields.add(UI_PUL_FaxDenialLetterchk);
             
        this.mergeFields.add(referredTo);     
        
         //comments
        this.mergeFields.add(new SCM_MF_Comments());    
        
         //Merge Sections       
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
        UI_PUL_ReferredtoGATCF = new SCM_MergeSection();        
        UI_PUL_ReferredtoGATCF.key = 'UI_PUL_ReferredtoGATCF';
        this.mergeSections.add(UI_PUL_ReferredtoGATCF);
        
        UI_PUL_ReferredtoAppeals = new SCM_MergeSection();        
        UI_PUL_ReferredtoAppeals.key = 'UI_PUL_ReferredtoAppeals';
        this.mergeSections.add(UI_PUL_ReferredtoAppeals);	
        
        UI_PUL_FaxDenialLetter = new SCM_MergeSection();        
        UI_PUL_FaxDenialLetter.key = 'UI_PUL_FaxDenialLetter';
        this.mergeSections.add(UI_PUL_FaxDenialLetter);	                	
                	
    }
    
    public override void getLatestValues() {
        UI_PUL_ReferredtoGATCF.visible = UI_PUL_ReferredtoGATCFchk.checked;
        UI_PUL_ReferredtoAppeals.visible = UI_PUL_ReferredtoAppealschk.checked;
        UI_PUL_FaxDenialLetter.visible = UI_PUL_FaxDenialLetterchk.checked;
        
        if (UI_SMNComplete.checked == false && UI_HisPhysTreat.checked == false && 
				UI_GrowthChart.checked == false && UI_KaryotypeResults.checked == false && 
				UI_ProgressNotes.checked == false && UI_Prescription.checked == false && 
				UI_BoneAgeReport.checked == false && UI_RenalFunctionsResults.checked == false && 
				UI_StimTestReport.checked == false && UI_PrioAuthForm.checked == false && 
				UI_PCPReferral.checked == false ){
										
        	UI_Additional_Docs.visible = false;
		}
		else {
			UI_Additional_Docs.visible = true;
		}
    }
}