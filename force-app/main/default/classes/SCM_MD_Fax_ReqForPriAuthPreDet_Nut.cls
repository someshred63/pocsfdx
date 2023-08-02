/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : NUT-CMGT-FAX-17 REQUEST FOR PRIOR AUTHORIZATION - PREDETERMINATION.doc
    // Product           : Growth Hormone / Nutropin
    // Type				 : Fax Coversheet
    // Word Template     : Request_For_Prior_Auth_PreDet_Nut.doc  
    // Label in SF       : Request for Prior Authorization / Pre-Determination
    
/********************************************************************/
public class SCM_MD_Fax_ReqForPriAuthPreDet_Nut extends SCM_MergeDocument{
	protected String caseId;
	private SCM_MergeField injTrainNo;
	private SCM_MergeField injTrainYes;
	private SCM_MergeField mf1;
    
    public SCM_MD_Fax_ReqForPriAuthPreDet_Nut(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
    }
        
    public override void createMergeFields() {
    	String recordType = selectedCase.RecordType.Name;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientId = selectedCase.Patient_gne__r.Id;
        String productName = selectedCase.Product_gne__c;
        
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
        
        // Case Number
     	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
     	
     	// Patient Id
	    this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
	    
	    // CR_Phone
	    this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
	    
	    // CR_PhoneShort
	    this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
	    
	    // CR_FAX
	    this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
	    
	    // CR_URL
	    this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
	    
	    // Date
	    this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
	    
	    // PatientFullName
	    this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
	    
	    // DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
        
        // SubscriberID_PA (Key: 'SubscriberID_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPASubscriberId(selectedCase.Id));
        
        // GroupNum_PA (Key: 'GroupNum_PA')
        this.mergeRecipientInfo.add(new SCM_MF_InsPAGroupNum(selectedCase.Id));
        
        // Pediatric (Key: 'Pediatric')
        this.mergeRecipientInfo.add(new SCM_MF_ChkPediatric(selectedCase));
        
        // Adult (Key: 'Adult')
        this.mergeRecipientInfo.add(new SCM_MF_ChkAdult(selectedCase));
	    
	    // NewStart
	    this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase, true, true));
	    
	    // ContinuedTherapy
	    this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase, true, true));
	    
	    // Restart
	    this.mergeRecipientInfo.add(new SCM_MF_ChkRestartTherapy(selectedCase, true, true));
	    
	    // ConfidNotice (Key: 'ConfidNotice')
	    this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
	    
	    // Injection Training Checkboxes
	    injTrainNo = new SCM_MergeField();
		injTrainNo.checked = false;
		injTrainNo.displayCheck = false;
		injTrainNo.displayTextBox = false;
		injTrainNo.displayLabel = false;
		injTrainNo.key = 'UI_No';
		injTrainNo.fieldValue = SCM_CheckBox_Values.unChecked; 	
		this.mergeRecipientInfo.add(injTrainNo); 
		
		injTrainYes = new SCM_MergeField();
		injTrainYes.checked = false;
		injTrainYes.displayCheck = false;
		injTrainYes.displayTextBox = false;
		injTrainYes.displayLabel = false;
		injTrainYes.key = 'UI_Yes';
		injTrainYes.fieldValue = SCM_CheckBox_Values.unChecked;
		this.mergeRecipientInfo.add(injTrainYes);
	    
	    
	     /////////-------Second Screen ------
        
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.headerText = 'Injection Training:';       
        docu.key = 'Documentation';
        
        // Label
        SCM_MergeField injTrainLabel = new  SCM_MergeField();
        injTrainLabel.label = 'Injection Training Required';
        injTrainLabel.fieldValue = '';
        injTrainLabel.displayCheck = false;
        injTrainLabel.displayTextBox = false;
        injTrainLabel.isRequired=false;
        injTrainLabel.isNewLine=false;
        injTrainLabel.totalWidth = '150';
        docu.subFields.add(injTrainLabel); 
        
        mf1 = new SCM_MergeField();
        mf1.isNewLine=false;
        mf1.displayRadio = true;
        mf1.displayLabel = false;
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.IsRequired = false;
        mf1.totalWidth = '90';
        
        mf1.selectionItems.add(new SelectOption('Yes','Yes'));
        mf1.selectionItems.add(new SelectOption('No','No'));
        mf1.key = 'RadioButtonValue';
        mf1.fieldvalue = 'No';        
        docu.subFields.add(mf1);
        
        SCM_MergeField OtherDoc1 = new SCM_MF_OtherDocuments('UI_Payor', 'Payor');
        OtherDoc1.totalWidth = '400';
        OtherDoc1.isNewLine=false;
        OtherDoc1.requireNewLineInTemplate = false;
        OtherDoc1.fieldValue = '';
        docu.subFields.add(OtherDoc1);
        
        this.mergeFields.add(docu);
        this.mergeFields.add(new SCM_MF_Comments());
    
    }
    
    public override void getLatestValues()  {
		String radioVal = mf1.getMergeValue();
		
		if(radioVal != null && radioVal.startsWith('Yes'))
		{
			injTrainYes.mergeValue = SCM_CheckBox_Values.Checked;
        }	
		if(radioVal != null && radioVal.startsWith('No'))
		{
			injTrainNo.mergeValue = SCM_CheckBox_Values.Checked;
        }
    }
}