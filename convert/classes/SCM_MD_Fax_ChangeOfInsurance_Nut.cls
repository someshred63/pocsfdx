/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : NUT-CMGT-FAX-25 Change of Insurance.doc
    // PRODUCT GROUP     : Growth Hormone / Nutropin
    // Type              : Fax Coversheet
    // Word Template     : Fax_ChangeOfInsurance_Nut.doc    
    // Label in SF       : Change Of Insurance 
    
/********************************************************************/



public class SCM_MD_Fax_ChangeOfInsurance_Nut extends SCM_MergeDocument implements IStandardComboBox {
	
	  
	 private SCM_MergeSection UI_GATCFInfo;
	 private SCM_MergeSection UI_StarterInfo;	
	 private SCM_MergeSection UI_DocsRequiredListInfo;
	 private SCM_MergeSection ContinuedTreatmentInfo;
	
	
	 private SCM_MergeFieldCheckbox UI_SMNCompletedChk;
	 private SCM_MergeFieldCheckbox UI_KaryotypeResultsChk;
	 private SCM_MergeFieldCheckbox UI_BoneAgeReportChk ;
	 private SCM_MergeFieldCheckbox UI_HisPhysTreatChk;
	 private SCM_MergeFieldCheckbox UI_ProgressNotesChk;
	 private SCM_MergeFieldCheckbox UI_RenalFunctionResultsCRIOnlyChk;
	 private SCM_MergeFieldCheckbox UI_GrowthChartChk;
	 private SCM_MergeFieldCheckbox UI_PrescriptionChk;
	 private SCM_MergeFieldCheckbox UI_StimTestsReportsChk;
	 private SCM_MergeFieldCheckbox UI_PrioAuthFormChk;
	 private SCM_MergeFieldCheckbox UI_PCPReferralChk ;
	 private SCM_MergeFieldCheckbox other;	
	 
	 private SCM_MergeFieldCheckbox UI_GATCFchk;
	 private SCM_MergeFieldCheckbox UI_ASCBChk;
	 private SCM_MergeFieldCheckbox UI_PRCBChk ;
	 private SCM_MergeFieldCheckbox UI_StarterChk;
	 private SCM_MergeFieldCheckbox FollowUp;
	 

	  
	 public SCM_MD_Fax_ChangeOfInsurance_Nut(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }        
    public override void createMergeFields() {
    	
    	String patientId = selectedCase.patient_gne__r.Id;
      	string caseRecordType = selectedCase.RecordType.Name ;
      	string pId= selectedCase.Patient_gne__c;
      	string physicianId=selectedCase.Case_Treating_Physician_gne__r.Id;
      	      	
      	//0. Case Number()
         this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //1. Patient Id()
         this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
         //2. Phone Nutropin()
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //3. Fax Nutopin()
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //4. URL Nutropin()
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        //changes
        
        //5. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //6. Addressed To (RECNAME)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //7. Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
     	String recordType = selectedCase.RecordType.Name;
     	//8 From()
        //this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
         //9. Extension         
        //this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
       
         
       	//10. Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
   
        //11. Patient Full Name(Patient_First_And_Last_Name)
       this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pId));
       
        //12. Patient DOB(Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pId));  
        
        //13. Privacy Notice
    	this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //14. Confidentiality Notice
		this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));     

	
        //---------------------------------second page-----------------------------------------//
               
        //  Documentation:
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.label = 'DOCUMENTATION';
		formInfo.headerText = 'The payor requires the following updated document(s):';                 
        formInfo.key = 'DOCUMENTATION';
       
        //1. SMN completed
        UI_SMNCompletedChk = 
                new SCM_MergeFieldCheckbox('UI_SMNCompletedChk', 'SMN (completed)');       
        UI_SMNCompletedChk.fieldValue = 'SMN (Completed)  \r\n';
        UI_SMNCompletedChk.totalWidth = '270';
        formInfo.subFields.add(UI_SMNCompletedChk);
        
           //5 History/Physical/Treatment Plan
        UI_HisPhysTreatChk = 
                new SCM_MergeFieldCheckbox('UI_HisPhysTreatChk', 'History/Physical/Treatment Plan');       
        UI_HisPhysTreatChk.fieldValue = 'History/Physical/Treatment Plan  \r\n';
        UI_HisPhysTreatChk.totalWidth = '270';
        UI_HisPhysTreatChk.isNewLine=false;
        formInfo.subFields.add(UI_HisPhysTreatChk);
        
        
         //9. Growth Chart
        UI_GrowthChartChk = 
                new SCM_MergeFieldCheckbox('UI_GrowthChartChk', 'Growth Chart');       
        UI_GrowthChartChk.fieldValue = 'Growth Chart  \r\n';
        UI_GrowthChartChk.totalWidth = '270';
        UI_GrowthChartChk.isNewLine=true;
        formInfo.subFields.add(UI_GrowthChartChk);
        
        

        //2. Karyotype Results
        UI_KaryotypeResultsChk = 
                new SCM_MergeFieldCheckbox('UI_KaryotypeResultsChk', 'Karyotype Results');       
        UI_KaryotypeResultsChk.fieldValue = 'Karyotype Results  \r\n';
        UI_KaryotypeResultsChk.totalWidth = '270';
        UI_KaryotypeResultsChk.isNewLine=false;
        formInfo.subFields.add(UI_KaryotypeResultsChk);
        
         //6. Progress Notes
        UI_ProgressNotesChk = 
                new SCM_MergeFieldCheckbox('UI_ProgressNotesChk', 'Progress Notes');       
        UI_ProgressNotesChk.fieldValue = 'Progress Notes  \r\n';
        UI_ProgressNotesChk.totalWidth = '270';
        UI_ProgressNotesChk.isNewLine=true;
        formInfo.subFields.add(UI_ProgressNotesChk);
        
        //10. Prescription
        UI_PrescriptionChk = 
                new SCM_MergeFieldCheckbox('UI_PrescriptionChk', 'Prescription');       
        UI_PrescriptionChk.fieldValue = 'Prescription  \r\n';
        UI_PrescriptionChk.totalWidth = '270';
        UI_PrescriptionChk.isNewLine=false;
        formInfo.subFields.add(UI_PrescriptionChk);  
        
	
        
        //3. Bone Age Report
        UI_BoneAgeReportChk = 
                new SCM_MergeFieldCheckbox('UI_BoneAgeReportChk', 'Bone Age Report');       
        UI_BoneAgeReportChk.fieldValue = 'Bone Age Report  \r\n';
        UI_BoneAgeReportChk.totalWidth = '270';
        UI_BoneAgeReportChk.isNewLine=true;
        formInfo.subFields.add(UI_BoneAgeReportChk);
        
            //7. Renal Function Results (CRI Only)
        UI_RenalFunctionResultsCRIOnlyChk = 
                new SCM_MergeFieldCheckbox('UI_RenalFunctionResultsCRIOnlyChk', 'Renal Function Results (CRI Only)');       
        UI_RenalFunctionResultsCRIOnlyChk.fieldValue = 'Renal Function Results (CRI Only)  \r\n';
        UI_RenalFunctionResultsCRIOnlyChk.displayLabel=true;
        UI_RenalFunctionResultsCRIOnlyChk.totalWidth = '270';
        UI_RenalFunctionResultsCRIOnlyChk.isNewLine=false;
        formInfo.subFields.add(UI_RenalFunctionResultsCRIOnlyChk);
        
        //11. Stim Test(s) Report(s)
        UI_StimTestsReportsChk = 
                new SCM_MergeFieldCheckbox('UI_StimTestsReportsChk', 'Stim Test(s) Report(s)');       
        UI_StimTestsReportsChk.fieldValue = 'Stim Test(s) Report(s)  \r\n';
        UI_StimTestsReportsChk.totalWidth = '270';
        UI_StimTestsReportsChk.isNewLine=true;
        formInfo.subFields.add(UI_StimTestsReportsChk);  
        
        
       
        
        //4.Prior Authorization Form (signed & completed)
        UI_PrioAuthFormChk = 
                new SCM_MergeFieldCheckbox('UI_PrioAuthFormChk', 'Prior Authorization Form (signed & completed)');       
        UI_PrioAuthFormChk.fieldValue = 'Prior Authorization Form (signed & completed)  \r\n';
          UI_PrioAuthFormChk.displayLabel=false;
  		UI_PrioAuthFormChk.displayExtraHTML = true;
		UI_PrioAuthFormChk.extraHTML='Prior Authorization Form (signed & completed)'; 
        UI_PrioAuthFormChk.totalWidth = '270';
        UI_PrioAuthFormChk.isNewLine=false;
        formInfo.subFields.add(UI_PrioAuthFormChk);   
      
        
        
	    //8. PCP Referral
        UI_PCPReferralChk = 
                new SCM_MergeFieldCheckbox('UI_PCPReferralChk', 'PCP Referral');       
        UI_PCPReferralChk.fieldValue = 'PCP Referral  \r\n';
        UI_PCPReferralChk.totalWidth = '270';
        UI_PCPReferralChk.isNewLine=true;
        formInfo.subFields.add(UI_PCPReferralChk);
	
	//12 other 
	  	other = 
        	new SCM_MergeFieldCheckbox('Other', 'Other');			
  	  	other.fieldValue='';			
      	other.totalWidth = '100';
      	formInfo.subFields.add(other);
       
	//13  
		 
        SCM_MergeField OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1', 'Other Documentation');
        SCM_MergeField OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
        SCM_MergeField OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3', '');

         
        formInfo.subFields.add(OtherDoc1);
        formInfo.subFields.add(OtherDoc2);
        formInfo.subFields.add(OtherDoc3);
        this.mergeFields.add(formInfo);
     
       //-------------------------------------*------------------------------------

		

	//  Follow Up:
        SCM_MergeFieldGroup formInfo1 = new SCM_MergeFieldGroup();
        formInfo1.label = 'FOLLOW UP';                 
        formInfo1.key = 'FOLLOW UP';
        formInfo1.headerText = 'Follow Up:';
        
        SCM_MergeField FollowLabel = new  SCM_MergeField();
        FollowLabel.label = 'To continue treatment while NUTROPIN Access Solutions is pursuing authorization, please complete the following:';
        FollowLabel.fieldValue = '';
        FollowLabel.displayCheck = false;
        FollowLabel.displayTextBox = false;
        FollowLabel.isRequired=false;
        FollowLabel.isNewLine=true;    
        FollowLabel.subFields.add(FollowLabel);

	
	 //11. GATCF 
        UI_GATCFChk = 
                new SCM_MergeFieldCheckbox('UI_GATCFChk', 'GATCF');       
        UI_GATCFChk.fieldValue = '';
        //
        UI_GATCFChk.displayLabel=false;
  		UI_GATCFChk.displayExtraHTML = true;
		UI_GATCFChk.extraHTML='GATCF <br>'
		+'To facilitate the GATCF process, please <br>'
		+'complete the following medical documentation <br>'
		+'and fax directly to the GATCF pharmacy <br>'
		+'at (800) 545- 0612 .' ;
		UI_GATCFChk.isRequired=false;
		//
        UI_GATCFChk.totalWidth = '270';
        UI_GATCFChk.isNewLine=true;
        formInfo1.subFields.add(UI_GATCFChk); 
        
        
           //11. Starter
        UI_StarterChk = 
                new SCM_MergeFieldCheckbox('UI_StarterChk', 'STARTER:');       
        UI_StarterChk.fieldValue = '';
        UI_StarterChk.displayLabel=false;
  		UI_StarterChk.displayExtraHTML = true;
		UI_StarterChk.extraHTML='STARTER: <br>'
		+'Please complete the attached Starter <br>'
		+'of Medical Necessity and fax directly to <br>'
		+' ACCESS SOLUTIONS at (800) 545- 0612 .' ;
		UI_StarterChk.isRequired=false;
        UI_StarterChk.totalWidth = '270';
        UI_StarterChk.isNewLine = false ;
        formInfo1.subFields.add(UI_StarterChk);
      
	 //11. Attached statement (SMN)
        UI_ASCBChk = 
                new SCM_MergeFieldCheckbox('UI_ASCBChk', 'Attached Statement of Medical Necessity (SMN)');       
         UI_ASCBChk.fieldValue = 'Attached Statement of Medical Necessity (SMN)\r\n';
         //UI_ASCBChk.totalWidth = '270';
         UI_ASCBChk.isNewLine=true; 
         formInfo1.subFields.add(UI_ASCBChk); 

	
	 //11. Prescription
        UI_PRCBChk = 
                new SCM_MergeFieldCheckbox('UI_PRCBChk', 'Prescription');       
        UI_PRCBChk.fieldValue = 'Prescription';
        UI_PRCBChk.totalWidth = '270';
        UI_PRCBChk.isNewLine=true;
        formInfo1.subFields.add(UI_PRCBChk); 
        this.mergeFields.add(formInfo1);
        
       
		
	
	
	//12. comments
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        comments.headerText = 'Comments: ';       
        comments.key = 'Comment';           
        
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        CommentField.key = 'Comments';                       
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments); 
	

	

	



//------------------------------------------------------


        // Merge Sections

	        
        UI_DocsRequiredListInfo = new SCM_MergeSection();                 
        UI_DocsRequiredListInfo.key = 'UI_DocsRequiredList';
        this.mergeSections.add(UI_DocsRequiredListInfo);
                
        UI_GATCFInfo = new SCM_MergeSection();                 
        UI_GATCFInfo.key = 'UI_GATCF';
        this.mergeSections.add(UI_GATCFInfo);
        
        UI_StarterInfo = new SCM_MergeSection();                 
        UI_StarterInfo.key = 'Starter';
        this.mergeSections.add(UI_StarterInfo);
        
         ContinuedTreatmentInfo = new SCM_MergeSection();                 
        ContinuedTreatmentInfo.key = 'ContinuedTreatement';
        this.mergeSections.add(ContinuedTreatmentInfo);
        
        
        
    }
       
    
    
     public override void getLatestValues()  {
     	
     	if(UI_GATCFChk.checked == false && UI_StarterChk.checked == false ) {
     	ContinuedTreatmentInfo.visible =false; 
     	}
     	else
     	{
     		ContinuedTreatmentInfo.visible = true; 
     	}
     	
     	if(UI_GATCFChk.checked == false) {
     	UI_GATCFInfo.visible =false; 
     	}
     	else
     	{
     		UI_GATCFInfo.visible = true; 
     	}
     	if(UI_StarterChk.checked == false) {
     	UI_StarterInfo.visible =false; 
     	}
     	else
     	{
     		UI_StarterInfo.visible = true; 
     	}
     	
     	if(UI_SMNCompletedChk.checked == true || 
     	UI_KaryotypeResultsChk.checked == true ||
     	UI_BoneAgeReportChk.checked == true || 
     	UI_HisPhysTreatChk.checked == true ||
     	UI_ProgressNotesChk.checked == true ||
     	UI_RenalFunctionResultsCRIOnlyChk.checked == true ||
     	UI_GrowthChartChk.checked == true ||
     	UI_PrescriptionChk.checked == true ||
     	UI_StimTestsReportsChk.checked == true ||
     	UI_PrioAuthFormChk.checked == true ||
     	UI_PCPReferralChk.checked == true ||
     	other.checked == true)
     	{
     		UI_DocsRequiredListInfo.visible=true;
     	}
     	else    
     	{
     		UI_DocsRequiredListInfo.visible=false;	
     	}
         
         
         
     }
     
    
    
	
     
     
     
}