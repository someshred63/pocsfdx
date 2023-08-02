/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : PUL-CMGT-FAX-17 REQUEST FOR PRIOR AUTHORIZATION - PREDETERMINATION.doc 
    // PRODUCT GROUP     : Pulmonary / Pulmozyme
    // Type				 : Fax Coversheet
    // Word Template     : RequestForPriorAuthPre-Det_PUL.doc
    // Label in SF       : Request for Prior Authorization / Pre-Determination 
    
/********************************************************************/
public class SCM_MD_Fax_ReqForPriAuthDet_Pul extends SCM_MergeDocument {
	private SCM_MergeField UIInjectionTrainingReqRadBtn;
	
	private SCM_MergeField InjectionTrainingReqYes;
    private SCM_MergeField InjectionTrainingReqNo;
	
	protected String caseId;
	public SCM_MD_Fax_ReqForPriAuthDet_Pul(String caseId, String argLookupId) {
		super(caseID, argLookupId);
		caseId = caseID;
	}
	
	public override void createMergeFields() {
		String patientNumber = selectedCase.patient_gne__r.id;
		String recordType = selectedCase.RecordType.Name;
		
        // Attn (Key: 'ATTN_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAContactName(selectedCase.Id));
        
        //RECNAME_Payor
        this.mergeRecipientInfo.add(new SCM_MF_InsPAPayor(selectedCase.Id));
        
		//RECFAX_PA
		this.mergeRecipientInfo.add(new SCM_MF_InsPAContactFax(selectedCase.Id));
		
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        
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
        
        // SubscriberID_PA (Key: 'SubscriberID_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPASubscriberId(selectedCase.Id));
        
        // GroupNum_PA (Key: 'GroupNum_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAGroupNum(selectedCase.Id));
        
        //'NewStart', 'ContinuedTherapy', 'Restart'
  		this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase, true, true));
  		this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase, true, true));
  		this.mergeRecipientInfo.add(new SCM_MF_ChkRestartTherapy(selectedCase, true, true));
        
        //ConfidNotice
    	this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    	
    	//UI_InjectionTrainingReqYes
        InjectionTrainingReqYes = new SCM_MergeField();
        InjectionTrainingReqYes.key = 'UI_InjTraingReqYes';     
        InjectionTrainingReqYes.checked = false;
        InjectionTrainingReqYes.displayCheck = false;
        InjectionTrainingReqYes.displayTextBox = false;
        InjectionTrainingReqYes.displayLabel = false;
        InjectionTrainingReqYes.fieldValue = SCM_CheckBox_Values.unChecked;
        this.mergeRecipientInfo.add(InjectionTrainingReqYes); 
        
        //UI_InjectionTrainingReqNo
        InjectionTrainingReqNo = new SCM_MergeField();
        InjectionTrainingReqNo.key = 'UI_InjTraingReqNo';     
        InjectionTrainingReqNo.checked = false;
        InjectionTrainingReqNo.displayCheck = false;
        InjectionTrainingReqNo.displayTextBox = false;
        InjectionTrainingReqNo.displayLabel = false;
        InjectionTrainingReqNo.fieldValue = SCM_CheckBox_Values.unChecked;
        this.mergeRecipientInfo.add(InjectionTrainingReqNo);
        
        //------------------------------------------Second Screen ------------------------------------------//
        
        
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.headerText = 'Injection Training:';
        formInfo.key = 'Form Information';
        
        // Label
        SCM_MergeField injTrainLabel = new  SCM_MergeField();
        injTrainLabel.label = 'Injection Training Required';
        injTrainLabel.fieldValue = '';
        injTrainLabel.displayCheck = false;
        injTrainLabel.displayTextBox = false;
        injTrainLabel.isRequired=false;
        injTrainLabel.isNewLine=false;
        injTrainLabel.totalWidth = '150';
        formInfo.subFields.add(injTrainLabel); 
        
        UIInjectionTrainingReqRadBtn = new SCM_MergeField();
        UIInjectionTrainingReqRadBtn.displayRadio = true;
        UIInjectionTrainingReqRadBtn.isNewLine = false;
        UIInjectionTrainingReqRadBtn.displayLabel = false;
        UIInjectionTrainingReqRadBtn.displayCheck = false;
        UIInjectionTrainingReqRadBtn.displayTextbox = false;
        UIInjectionTrainingReqRadBtn.isRequired = false;
        UIInjectionTrainingReqRadBtn.totalWidth = '90';
        
        UIInjectionTrainingReqRadBtn.selectionItems.add(new SelectOption('Yes','Yes'));
        UIInjectionTrainingReqRadBtn.selectionItems.add(new SelectOption('No','No'));
        
        UIInjectionTrainingReqRadBtn.Key = 'RadioButtonValue';
        UIInjectionTrainingReqRadBtn.fieldValue = 'No';
        formInfo.subFields.add(UIInjectionTrainingReqRadBtn);
        
        //TextBox(UI_Payor)         
        SCM_MergeField UIPayer = new SCM_MF_OtherDocuments('UI_Payor', 'Payor:');
        UIPayer.isRequired = false;
        UIPayer.totalWidth = '400';
        UIPayer.isNewLine = false;
        UIPayer.requireNewLineInTemplate = false;
        formInfo.subFields.add(UIPayer);
        this.mergeFields.add(formInfo);
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());	
		
	}
	public override void getLatestValues()  {
        if(UIInjectionTrainingReqRadBtn.getMergeValue() != null && UIInjectionTrainingReqRadBtn.getMergeValue().startsWith('Yes')){
			InjectionTrainingReqYes.mergeValue = SCM_CheckBox_Values.Checked;
        }	
		if(UIInjectionTrainingReqRadBtn.getMergeValue() != null && UIInjectionTrainingReqRadBtn.getMergeValue().startsWith('No')){
			InjectionTrainingReqNo.mergeValue = SCM_CheckBox_Values.Checked;
        }		            
    }
}