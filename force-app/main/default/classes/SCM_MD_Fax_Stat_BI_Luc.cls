public class SCM_MD_Fax_Stat_BI_Luc extends SCM_MergeDocument implements IStandardComboBox{
			
	protected String caseId;
	public SCM_MD_Fax_Stat_BI_Luc(String caseId, String argLookupId) {
		super(caseID, argLookupId);
		caseId = caseID;
	}
	
	private scm_mergefield UI_BIAttached = new scm_mergefield();
	private scm_mergefield UI_Luc_CoorWithDist = new scm_mergefield();
	private scm_mergefield UI_ReferringDiag = new scm_mergefield();
	
	
	public override void createMergeFields() {
		String patientNumber = selectedCase.patient_gne__r.id;
		String recordType = selectedCase.RecordType.Name;
		
//6.  Attn (key ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
      
        // Addressed To (key RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
          
        // Fax (key RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
         this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //CR_Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //PatientFullName(key 'Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientNumber));
        
        //Patient DOB(key 'Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientNumber));
	
		this.mergeRecipientInfo.add( new SCM_MF_Product_ScientificName(selectedCase));

		this.mergeRecipientInfo.add( new SCM_MF_Product_Name(selectedCase));
		
		this.mergefields.add(new SCM_MF_Product_ConfidentialityNotice(SelectedCase));
		
		this.mergefields.add(new SCM_MF_Product_PrivacyNotice(SelectedCase));
		
		this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.id));
		//set up ui stuff
		UI_BIAttached.displayCheck = true;
		UI_BIAttached.displayLabel = true;
		UI_BIAttached.label = 'A copy of the benefit investigation is attached';
		UI_BIAttached.key = 'UI_BIAttached';
		UI_BIAttached.displayTextBox = false;
		UI_BIAttached.isRequired = false;
		this.mergefields.add(UI_BIAttached);
		
		UI_Luc_CoorWithDist.displayCheck = true;
		UI_Luc_CoorWithDist.displayLabel = true;
		UI_Luc_CoorWithDist.label = 'Access Solutions is coordinating the first/next shipment with the distributor.';
		UI_Luc_CoorWithDist.key = 'UI_Luc_CoorWithDist';
		UI_Luc_CoorWithDist.displayTextBox = false;
		UI_Luc_CoorWithDist.isRequired = false;
		UI_Luc_CoorWithDist.isFormField = true;
		UI_Luc_CoorWithDist.totalWidth = '650';
		this.mergefields.add(UI_Luc_CoorWithDist);
		
		UI_ReferringDiag.displayCheck = true;
		UI_ReferringDiag.displayLabel = true;
		UI_ReferringDiag.label = 'Referring Diagnosis';
		UI_ReferringDiag.key = 'UI_ReferringDiag';
		UI_ReferringDiag.displayTextBox = false;
		UI_ReferringDiag.isRequired = false;
		this.mergefields.add(UI_ReferringDiag);
		
		this.mergeFields.add(new scm_mf_comments());
		this.mergeImages.add(new scm_MI_logo(SelectedCase));
	}
	public override void getLatestValues()  {
	SCM_mergeSection sec_BIAttached = new SCM_mergeSection();
	SCM_mergeSection sec_Luc_CoorWithDist = new SCM_mergeSection();
	SCM_mergeSection sec_ReferringDiag = new SCM_mergeSection();
	sec_BIAttached.key = 'sec_BIAttached';
	sec_Luc_CoorWithDist.key = 'sec_Luc_CoorWithDist';
	sec_ReferringDiag.key = 'sec_ReferringDiag';
	this.mergeSections.add(sec_BIAttached);
	this.mergeSections.add(sec_Luc_CoorWithDist);
	this.mergeSections.add(sec_ReferringDiag);
	
	sec_BIAttached.visible = UI_BIAttached.checked;
	sec_Luc_CoorWithDist.visible = UI_Luc_CoorWithDist.checked;
	sec_ReferringDiag.visible = UI_ReferringDiag.checked;
	
	
	

	
	
	
	}
}