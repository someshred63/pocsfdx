/********************************************************************/
    // Developer Name    : Reji Joseph
    // Document Name     : PUL-CMGT-FAX-29 NEW REFERRAL.doc
    // PRODUCT GROUP     : Pulmonary / Pulmozyme
    // Type              : Fax Coversheet
    // Word Template     : New Referral Pulmozyme.doc
    // Label in SF       : 
/********************************************************************/
    
public class SCM_MD_FAX_NewReferral_Pul extends SCM_MergeDocument implements IStandardComboBox{

	private SCM_MergeSection UI_DocsRequiredStmnt;
    
	//only checkboxes
	private SCM_MergeFieldCheckbox UI_SMNComplete;
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

	//checkbox+textbox
    //private SCM_MergeFieldCheckbox UI_OtherDoc;

    //only textboxes
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
	
    public SCM_MD_FAX_NewReferral_Pul (String caseId, String argLookupId) {
        super(caseId, argLookupId);
    } 

    public override void createMergeFields() {
    	String patientId = selectedCase.patient_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        //-------------------------------------------------------------------------------------------
        //-------------------------------------------------------------------------------------------
        // Case Number (CaseID) (key Case Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // Patient ID (key Patient ID)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		//-------------------------------------------------------------------------------------------    	
        // CR Phone (key CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR Fax (key CR_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR URL (key CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    	//-------------------------------------------------------------------------------------------
        // Product Name (key Drug)
        this.mergeFields.add(new SCM_MF_Product_DrugName(selectedCase));
    	//-------------------------------------------------------------------------------------------
    	// PrivacyNotice (key PrivacyNotice)
    	this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
    	
        // Confidentiality Notice (key ConfidNotice)
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
		//-------------------------------------------------------------------------------------------
        // Current Date (key Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
		//-------------------------------------------------------------------------------------------
        // PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));

        // Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
    	//-------------------------------------------------------------------------------------------
    	// First Page
    	//-------------------------------------------------------------------------------------------
        // Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // Addressed To
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));

        // Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));

        // From and EXt (key From & Ext)
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
        
       	//-------------------------------------------------------------------------------------------
        // Second Page
        //-------------------------------------------------------------------------------------------
        //  Additional Information Required:
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.headerText = 'Documentation:';
        docu.label = 'Additional document(s) required by the payor before SPOC can submit for prior authorization';
        //docu.displayLabel = true;       
        docu.key = 'Documentation';
        
        //-------------------------------------------------------------------------------------------
        UI_DocsRequiredStmnt = new SCM_MergeSection();        
        UI_DocsRequiredStmnt.key = 'UI_DocsRequiredStmnt';
        this.mergeSections.add(UI_DocsRequiredStmnt);
        
        //-------------------------------------------------------------------------------------------
        // 1. SMN (Completed)
        UI_SMNComplete = new SCM_MergeFieldCheckbox('UI_SMNComplete', 'SMN (Completed)');       
        UI_SMNComplete.fieldValue = 'SMN (Completed) \r\n';        
        UI_SMNComplete.totalWidth = '165';
        UI_SMNComplete.isNewLine = true;
        docu.subFields.add(UI_SMNComplete); 

        //-------------------------------------------------------------------------------------------
        // 2. History/Physical/Treatment Plan
        UI_HisPhysTreat = new SCM_MergeFieldCheckbox('UI_HisPhysTreat', 'History/Physical/Treatment Plan');
        UI_HisPhysTreat.fieldValue = 'History/Physical/Treatment Plan \r\n';
        UI_HisPhysTreat.totalWidth = '220';
        UI_HisPhysTreat.isNewLine = false;        
        docu.subFields.add(UI_HisPhysTreat); 
        
        //-------------------------------------------------------------------------------------------
        // 3. Growth Chart
        UI_GrowthChart = new SCM_MergeFieldCheckbox('UI_GrowthChart', 'Growth Chart');          
        UI_GrowthChart.fieldValue = 'Growth Chart \r\n';       
        UI_GrowthChart.totalWidth = '180';
        UI_GrowthChart.isNewLine = false;
        docu.subFields.add(UI_GrowthChart);

        //-------------------------------------------------------------------------------------------
        // 4. Karyotype Results
        UI_KaryotypeResults = new SCM_MergeFieldCheckbox('UI_KaryotypeResults', 'Karyotype Results');          
        UI_KaryotypeResults.fieldValue = 'Karyotype Results \r\n';       
        UI_KaryotypeResults.totalWidth = '165';
        UI_KaryotypeResults.isNewLine = true;
        docu.subFields.add(UI_KaryotypeResults);
       
        //-------------------------------------------------------------------------------------------
        // 5. Progress Notes   
        UI_ProgressNotes = new SCM_MergeFieldCheckbox('UI_ProgressNotes', 'Progress Notes');          
        UI_ProgressNotes.fieldValue = 'Progress Notes \r\n';       
        UI_ProgressNotes.totalWidth = '220';
        UI_ProgressNotes.isNewLine = false;
        docu.subFields.add(UI_ProgressNotes);
        
        //-------------------------------------------------------------------------------------------
        // 6. Prescription
        UI_Prescription = new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');            
        UI_Prescription.fieldValue = 'Prescription \r\n';      
        UI_Prescription.totalWidth = '180';
        UI_Prescription.isNewLine = false;
        docu.subFields.add(UI_Prescription);
        
        //-------------------------------------------------------------------------------------------
        // 7. Bone Age Report
        UI_BoneAgeReport = new SCM_MergeFieldCheckbox('UI_BoneAgeReport', 'Bone Age Report');         
        UI_BoneAgeReport.fieldValue = 'Bone Age Report \r\n';      
        UI_BoneAgeReport.totalWidth = '165';
        UI_BoneAgeReport.isNewLine = true;
        docu.subFields.add(UI_BoneAgeReport);
        
        //-------------------------------------------------------------------------------------------
        // 8. Renal Function Results (CRI Only)
        UI_RenalFunctionResultsCRIOnly = new SCM_MergeFieldCheckbox('UI_RenalFunctionResultsCRIOnly', 'Renal Function Results (CRI Only)');         
        UI_RenalFunctionResultsCRIOnly.fieldValue = 'Renal Function Results (CRI Only) \r\n';      
        UI_RenalFunctionResultsCRIOnly.totalWidth = '220';
        UI_RenalFunctionResultsCRIOnly.isNewLine = false;
        docu.subFields.add(UI_RenalFunctionResultsCRIOnly);

        //-------------------------------------------------------------------------------------------
        // 9. Stim Test(s) Report(s)
        UI_StimTestsReports = new SCM_MergeFieldCheckbox('UI_StimTestsReports', 'Stim Test(s) Report(s)');         
        UI_StimTestsReports.fieldValue = 'Stim Test(s) Report(s) \r\n';      
        UI_StimTestsReports.totalWidth = '180';
        UI_StimTestsReports.isNewLine = false;
        docu.subFields.add(UI_StimTestsReports);
        
        //-------------------------------------------------------------------------------------------
        // 10. Prior Authorization Form (signed & completed)
        UI_PrioAuthForm = new SCM_MergeFieldCheckbox('UI_PrioAuthForm', 'Prior Authorization Form');         
        UI_PrioAuthForm.fieldValue = 'Prior Authorization Form \r\n';      
        UI_PrioAuthForm.totalWidth = '165';
        UI_PrioAuthForm.isNewLine = true;
        docu.subFields.add(UI_PrioAuthForm);
        
        //-------------------------------------------------------------------------------------------
        //  11. PCP Referral
        UI_PCPReferral = new SCM_MergeFieldCheckbox('UI_PCPReferral', 'PCP Referral');         
        UI_PCPReferral.fieldValue = 'PCP Referral \r\n';      
        UI_PCPReferral.totalWidth = '180';
        UI_PCPReferral.isNewLine = false;
        docu.subFields.add(UI_PCPReferral);
        
        //-------------------------------------------------------------------------------------------
        
		OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1_Txt', '');
	 	OtherDoc1.label = 'Other Documentation :';   
        OtherDoc1.isNewLine = true;
        OtherDoc1.totalWidth = '400';
        docu.subFields.add(OtherDoc1);

		OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2_Txt', '');
        OtherDoc2.isNewLine = true;
        OtherDoc2.totalWidth = '400';
        docu.subFields.add(OtherDoc2);

		OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3_Txt', '');
        OtherDoc3.isNewLine = true;
        OtherDoc3.totalWidth = '400';
        docu.subFields.add(OtherDoc3);

        //-------------------------------------------------------------------------------------------
        this.mergeFields.add(docu);
       
        //-------------------------------------------------------------------------------------------
        //  Comments
      	this.mergeFields.add(new SCM_MF_Comments());
      	
    }
    
	public override void getLatestValues()
  	{  
  		 
  	    if  (  UI_SMNComplete.checked == false 
  	    	&& UI_HisPhysTreat.checked == false 
  	    	&& UI_GrowthChart.checked == false 
  	    	&& UI_KaryotypeResults.checked == false 
  	    	&& UI_ProgressNotes.checked == false
            && UI_Prescription.checked == false
            && UI_BoneAgeReport.checked == false
            && UI_RenalFunctionResultsCRIOnly.checked == false
            && UI_StimTestsReports.checked == false
            && UI_PrioAuthForm.checked == false 
            && UI_PCPReferral.checked == false 
            && OtherDoc1.mergeVAlue == '' 
            && OtherDoc2.mergeVAlue == '' 
            && OtherDoc3.mergeVAlue == '')
            //&& UI_OtherDoc.checked == false ) 
            {
                UI_DocsRequiredStmnt.visible = false;
            }
            else
            {
                UI_DocsRequiredStmnt.visible = true;
            }

		
		//if (UI_OtherDoc.checked==false)
			//{
            	//OtherDoc1.mergeValue = '';
            	//OtherDoc2.mergeValue = '';
            	//OtherDoc3.mergeValue = '';
		//	}
			             
  	}
}