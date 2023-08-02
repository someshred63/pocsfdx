/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : XOL-CMGT-FAX-23_Distributor_Referral_FinalAnalysis.doc
    // PRODUCT GROUP     : Respiratory / Xolair
    // Type              : Fax Coversheet
    // Word Template     : CMGT-FAX-23-DistributorReferral-Xol.doc    
    // Label in SF       : Distributor Referral 
    
/********************************************************************/

public class SCM_MD_Fax_DistributorReferral_Xol extends SCM_MergeDocument {
	
	private SCM_MergeField injectionTrainingYes;
	private SCM_MergeField injectionTrainingNo;
	private SCM_MergeField CoordInjectionTrainingYes;
	private SCM_MergeField CoordInjectionTrainingNo;

	private SCM_MergeField Payor;
	private SCM_MergeField SubscriberName;
	private SCM_MergeField SubscriberID;
	private SCM_MergeField PayorConName;
	private SCM_MergeField GroupNum;
	private SCM_MergeField ProvidedBy;
	private SCM_MergeField PayorNum;
	
	private SCM_MergeField UI_Payor;
	private SCM_MergeField UI_SubscriberName;
	private SCM_MergeField UI_SubscriberID;
	private SCM_MergeField UI_PayorConName;
	private SCM_MergeField UI_GroupNum;
	private SCM_MergeField UI_ProvidedBy;
	private SCM_MergeField UI_PayorNum;
	
	
	private SCM_MergeFieldCheckbox XOLInsuranceInfoChk;
	private SCM_MergeFieldCheckbox CoordShipmentWPatChk;
	private SCM_MergeFieldCheckbox ObtXOLInsuranceAuthoChk;
	private SCM_MergeFieldCheckbox LastDosageDateChk;
	
	private SCM_MergeSection XOLInsuranceInfoChkInfo;
	private SCM_MergeSection CoordShipmentWPatChkInfo;
	private SCM_MergeSection ObtXOLInsuranceAuthoChkInfo;
	private SCM_MergeSection LastDosageDateChkInfo;
	
	private SCM_MergeSection InjectionTrainingText;
	
	protected String caseId;
	
	public SCM_MD_Fax_DistributorReferral_Xol(String caseID, String argLookupId) {
        super(caseID, argLookupId); 
        caseId = caseID;       
    }
    
    public override void createMergeFields() {
       
       
        String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String pid = selectedCase.Patient_gne__c;
        String caseRecordType = selectedCase.RecordType.Name ;
        
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));        
        // 2 CR_Phone(CR_Phone)
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));        
        // 3 CR_Fax(CR_Fax)        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));         
        // 4 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //---------------------------------Second Page-------------------------------------------------  
        // 5 ATTN_DIST(ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter_TextBox(selectedcase.id));
        
        // 6 Addressed To(RECNAME_To) 
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentAddressTo(selectedcase.id));
        //this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedcase.id));
        
        // 7 Fax No(RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber(selectedcase.id));
        
        // 8 From(From)         
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        // 9 Extension(Ext)
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        //------------------------------------------------------------------------------------------- 
        
        //10 DateShort(Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11 PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        //12 Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
        //13 Drug(Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase));
        
        //14 Patient Full Address(PatientCityStateZip)
        //this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(pId));
        this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(patientId));//PatientAddressCityStateZip
              
        //15 Patient Prime Contact FullName(PatientPrimeConFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(patientId));              
        //16 Patient Prime Contact Home Phone(Pat_Home_Ph)   
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(patientId));        
        //17 Patient Prime contact Work Phone(Pat_Work_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(patientId));
        
        //18  NewStart(NewStart)
        this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase,true,true));           
        //19 ContinuedTherapy(ContinuedTherapy)
        this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase,true,true));
         
        //20 Confidential Notice(ConfidNotice)
		this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
		 
			CoordInjectionTrainingNo = new SCM_MergeField();
			CoordInjectionTrainingNo.checked = false;
    		CoordInjectionTrainingNo.displayCheck = false;
    		CoordInjectionTrainingNo.displayTextBox = false;
    		CoordInjectionTrainingNo.displayLabel = false;
    		CoordInjectionTrainingNo.key = 'UI_CoordInjectionTrainingNo'; 	
			this.mergeRecipientInfo.add(CoordInjectionTrainingNo); 
			
			CoordInjectionTrainingYes = new SCM_MergeField();
			CoordInjectionTrainingYes.checked = false;
    		CoordInjectionTrainingYes.displayCheck = false;
    		CoordInjectionTrainingYes.displayTextBox = false;
    		CoordInjectionTrainingYes.displayLabel = false;
    		CoordInjectionTrainingYes.key = 'UI_CoordInjectionTrainingYes';
    		this.mergeRecipientInfo.add(CoordInjectionTrainingYes);
			
		//---------------------------------------------------------------------------------------------------
		
		//------------------------------------------Second Screen ------------------------------------------//
        
        //--------------------------------------Part 1------------------------------------------------
        // Injection Training
        SCM_MergeFieldGroup injectionTraining = new SCM_MergeFieldGroup();
        injectionTraining.headerText = 'Injection Training:';               
        injectionTraining.key = 'Injection Training';
        
        // Label
        SCM_MergeField injTrainLabel = new  SCM_MergeField();
        injTrainLabel.label = 'Injection Training Required';
        injTrainLabel.fieldValue = '';
        injTrainLabel.displayCheck = false;
        injTrainLabel.displayTextBox = false;
        injTrainLabel.isRequired=false;
        injTrainLabel.isNewLine=false;
        injTrainLabel.totalWidth = '600';    
        injectionTraining.subFields.add(injTrainLabel);        
        
        // Radio Button - 
        /**
        mf1 = new SCM_MergeField();
        mf1.isNewLine=false;
        mf1.displayRadio = true;
        mf1.displayLabel = false;
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.IsRequired = false;
        mf1.totalWidth = '230';
        
        mf1.selectionItems.add(new SelectOption(' ','Yes'));        
        mf1.selectionItems.add(new SelectOption(' ','No'));
        mf1.selectedValue = mf1.selectionItems[0].getValue();        
        mf1.setKey('RadioButtonValue');
        mf1.setFieldValue(mf1.selectedValue);        
        injectionTraining.subFields.add(mf1);
        //this.mergeFields.add(mf1); */ 
        
        injectionTrainingYes = new SCM_MergeField();
       
        injectionTrainingYes.displayLabel = true;
        injectionTrainingYes.displayCheck = true;
        injectionTrainingYes.displayTextbox = false;
        injectionTrainingYes.IsRequired = false; 
        injectionTrainingYes.totalWidth = '550';
        injectionTrainingYes.fieldValue = '';       
        injectionTrainingYes.fieldStyle='text-align: left;';
        injectionTrainingYes.label  = 'Yes';
        injectionTraining.subFields.add(injectionTrainingYes);                      
        
        injectionTrainingNo = new SCM_MergeField();
      
        injectionTrainingNo.displayLabel = true;
        injectionTrainingNo.displayCheck = true;
        injectionTrainingNo.displayTextbox = false;
        injectionTrainingNo.IsRequired = false; 
        injectionTrainingNo.totalWidth = '550';
        injectionTrainingNo.fieldValue = '';       
        injectionTrainingNo.fieldStyle='text-align: left;';
        injectionTrainingNo.label  = 'No';
        injectionTraining.subFields.add(injectionTrainingNo);  
        
        
         //---------Text Boxes---------
        Payor= new SCM_MF_OtherDocuments('Payor', '');
        //UI_Payor.label = 'Payor: ';
        Payor.isNewLine = false;
        Payor.displaylabel = false;
        Payor.displaytextbox = false;
        Payor.mergeValue = '';
        Payor.requireNewLineInTemplate = false;       
        //this.mergeRecipientInfo.add(Payor);
        //Payor.totalWidth = '400';
   
        UI_Payor= new SCM_MF_OtherDocuments('UI_Payor', 'Payor: ');
        //UI_Payor.label = 'Payor: ';
        UI_Payor.isNewLine = false;
        UI_Payor.totalWidth = '400';
        //UI_Payor.fieldValue = mf1.getMergeValue();
        
        SubscriberName= new SCM_MF_OtherDocuments('SubscriberName', '');
        SubscriberName.displaylabel = false;
        SubscriberName.displaytextbox = false;
        SubscriberName.mergeValue = '';
        SubscriberName.isNewLine = false;
        SubscriberName.requireNewLineInTemplate = false;
        //this.mergeRecipientInfo.add(SubscriberName);
     
        UI_SubscriberName = new SCM_MF_OtherDocuments('UI_SubscriberName', 'Subscriber Name:');
        //UI_SubscriberName.label = 'Subscriber Name: ';
        UI_SubscriberName.isNewLine = false;
        UI_SubscriberName.totalWidth = '400';
        
        SubscriberID= new SCM_MF_OtherDocuments('SubscriberID', '');
        SubscriberID.displaytextbox = false;
        SubscriberID.displaylabel = false;
        SubscriberID.mergeValue = '';
        SubscriberID.isNewLine = false;
        SubscriberID.requireNewLineInTemplate = false;
        //this.mergeRecipientInfo.add(SubscriberID);
     
        UI_SubscriberID = new SCM_MF_OtherDocuments('UI_SubscriberID', 'Subscriber ID:');
        //UI_SubscriberID.label = 'Subscriber ID: ';
        UI_SubscriberID.isNewLine = false;
        UI_SubscriberID.totalWidth = '400';
        
        PayorConName= new SCM_MF_OtherDocuments('PayorContactName', '');
        PayorConName.displaytextbox = false;
        PayorConName.displaylabel = false;
        PayorConName.mergeValue = '';
        PayorConName.isNewLine = false;
        PayorConName.requireNewLineInTemplate = false;
        //this.mergeRecipientInfo.add(PayorConName);
             
        UI_PayorConName = new SCM_MF_OtherDocuments('UI_PayorConName', 'Payor Contact:');
        //UI_PayorConName.label = 'Payor Contact:  ';
        UI_PayorConName.totalWidth = '400';
        UI_PayorConName.isNewLine = true;
        
        GroupNum= new SCM_MF_OtherDocuments('Group#', '');
        GroupNum.displaytextbox = false;
        GroupNum.displaylabel = false;
        GroupNum.mergeValue = '';
        GroupNum.isNewLine = false;
        GroupNum.requireNewLineInTemplate = false;
        //this.mergeRecipientInfo.add(GroupNum);
      
        UI_GroupNum = new SCM_MF_OtherDocuments('UI_GroupNum', 'Group#:');
        //UI_GroupNum.label = 'Group#:  ';
        UI_GroupNum.totalWidth='400';
        UI_GroupNum.isNewLine = false;
       
        ProvidedBy= new SCM_MF_OtherDocuments('ProvidedBy', '');
        ProvidedBy.displaytextbox = false;
        ProvidedBy.displaylabel = false;
        ProvidedBy.mergeValue = '';
        ProvidedBy.isNewLine = false;
        ProvidedBy.requireNewLineInTemplate = false;
        //this.mergeRecipientInfo.add(ProvidedBy);
         
        UI_ProvidedBy = new SCM_MF_OtherDocuments('UI_ProvidedBy', 'Provided By:');
        //UI_ProvidedBy.label = 'Provided By:  ';
        UI_ProvidedBy.isNewLine = true;
        UI_ProvidedBy.totalWidth = '400';
        
        PayorNum= new SCM_MF_OtherDocuments('Payor#', '');
        PayorNum.displaytextbox = false;
        PayorNum.displaylabel = false;
        PayorNum.mergeValue = '';
        PayorNum.isNewLine = false;
        PayorNum.requireNewLineInTemplate = false;
        //this.mergeRecipientInfo.add(PayorNum);
 
         UI_PayorNum = new SCM_MF_OtherDocuments('UI_PayorNum', 'Phone:');
        //UI_PayorNum.label = 'Phone: ';
        UI_PayorNum.isNewLine = true;
        UI_PayorNum.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        UI_PayorNum.totalWidth = '400';
        
        injectionTraining.subFields.add(Payor);
        injectionTraining.subFields.add(UI_Payor);        
        injectionTraining.subFields.add(SubscriberName);   
        injectionTraining.subFields.add(UI_SubscriberName);
        injectionTraining.subFields.add(SubscriberID);      
        injectionTraining.subFields.add(UI_SubscriberID);
        injectionTraining.subFields.add(PayorConName);
        injectionTraining.subFields.add(UI_PayorConName);
        injectionTraining.subFields.add(GroupNum);
        injectionTraining.subFields.add(UI_GroupNum);
        injectionTraining.subFields.add(ProvidedBy);     
        injectionTraining.subFields.add(UI_ProvidedBy);
        injectionTraining.subFields.add(PayorNum);      
        injectionTraining.subFields.add(UI_PayorNum);
        
        this.mergeFields.add(injectionTraining);
       
        //--------------------------------------Part 2-----------------------------------------------
        // Form Information
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.headerText = 'Form Information:';               
        formInfo.key = 'Form Information';
        
        //Checkboxes
        // 1 UI_XOLInsuranceInfo
        XOLInsuranceInfoChk = 
            new SCM_MergeFieldCheckbox('UI_XOLInsuranceInfo',
                'Access Solutions has obtained coverage for the above Xolair patient ');
        XOLInsuranceInfoChk.fieldValue = '' ;                    
        XOLInsuranceInfoChk.totalWidth = '900';
        formInfo.subFields.add(XOLInsuranceInfoChk);
        
        // 2 UI_CoordShipmentWPat 
        CoordShipmentWPatChk = new SCM_MergeFieldCheckbox('UI_XOLInsuranceInfo',
                'Coordinate Shipment with the patient listed above ');
        CoordShipmentWPatChk.fieldValue = '' ;                    
        CoordShipmentWPatChk.totalWidth = '900';
        formInfo.subFields.add(CoordShipmentWPatChk);
        
        // 3 UI_ObtXOLInsuranceAutho
        ObtXOLInsuranceAuthoChk = new SCM_MergeFieldCheckbox('UI_ObtXOLInsuranceAutho',
                'Obtain Xolair Insurance authorization ');
        ObtXOLInsuranceAuthoChk.fieldValue = '' ;                    
        ObtXOLInsuranceAuthoChk.totalWidth = '900';
        formInfo.subFields.add(ObtXOLInsuranceAuthoChk);
        
        // 4 UI_LastDosageDate
		LastDosageDateChk = new SCM_MergeFieldCheckbox('UI_ObtXOLInsuranceAutho',
                'Last Dosage was given on ');
        LastDosageDateChk.fieldValue = '' ;                    
        LastDosageDateChk.totalWidth = '200';
        formInfo.subFields.add(LastDosageDateChk);
        
        // UI_DosageDate
        SCM_MergeField DosageDate = new SCM_MF_OtherDocuments('UI_DosageDate', '');
        DosageDate.totalWidth = '300';
        DosageDate.fieldType = SCM_MergeField.Fieldtypes.dateField;
        DosageDate.isNewLine = false;
        DosageDate.requireNewLineInTemplate = false; 
        formInfo.subFields.add(DosageDate);
         
        this.mergeFields.add(formInfo);
        
        //comments
        this.mergeFields.add(new SCM_MF_Comments());
       
        // Merge Sections               
        XOLInsuranceInfoChkInfo = new SCM_MergeSection();        
        XOLInsuranceInfoChkInfo.key = 'UI_XOLInsuranceInfo';
        this.mergeSections.add(XOLInsuranceInfoChkInfo);
        
        CoordShipmentWPatChkInfo = new SCM_MergeSection();        
        CoordShipmentWPatChkInfo.key = 'UI_CoordShipmentWPat';
        this.mergeSections.add(CoordShipmentWPatChkInfo); 
        
        ObtXOLInsuranceAuthoChkInfo = new SCM_MergeSection();        
        ObtXOLInsuranceAuthoChkInfo.key = 'UI_ObtXOLInsuranceAutho';
        this.mergeSections.add(ObtXOLInsuranceAuthoChkInfo); 
        
        LastDosageDateChkInfo = new SCM_MergeSection();        
        LastDosageDateChkInfo.key = 'UI_LastDosageDate';
        this.mergeSections.add(LastDosageDateChkInfo);
        
        // UI_InjectionTrainingText
        InjectionTrainingText = new SCM_MergeSection();        
        InjectionTrainingText.key = 'UI_InjectionTrainingText';
        this.mergeSections.add(InjectionTrainingText);
        
    }
    
    public override void getLatestValues()  {
        XOLInsuranceInfoChkInfo.visible = XOLInsuranceInfoChk.checked;
        CoordShipmentWPatChkInfo.visible = CoordShipmentWPatChk.checked;  
        ObtXOLInsuranceAuthoChkInfo.visible = ObtXOLInsuranceAuthoChk.checked;
        LastDosageDateChkInfo.visible = LastDosageDateChk.checked; 
        
        //mf1.selectedValue = mf1.selectionItems[1].getValue();
        /**                       
        if( mf1.selectedValue == mf1.selectionItems[1].getValue() )
		{
			InjectionTrainingText.visible = false;   			       	        	   	
        	CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.Checked;        	 
		}	
		else 
		{
			InjectionTrainingText.visible = true;			        	
        	CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.Checked;        	        
		} */
		
               
      
		        
        	if((UI_Payor.mergeValue == ''))
        		Payor.mergeValue = '';
        	else
        		Payor.mergeValue = 'Payor : ';
        	
        	if((UI_SubscriberName.mergeValue == ''))
        		SubscriberName.mergeValue = '';
        	else
        		SubscriberName.mergeValue = 'Subscriber Name: ';
        		
        	if((UI_SubscriberID.mergeValue == ''))
        		SubscriberID.mergeValue = '';
        	else
        		SubscriberID.mergeValue = 'Subscriber ID: ';
        	if((UI_PayorConName.mergeValue == ''))
        		PayorConName.mergeValue = '';
        	else
        		PayorConName.mergeValue = 'Payor Contact Name: ';
        	if((UI_GroupNum.mergeValue == ''))
        		GroupNum.mergeValue = '';
        	else
        		GroupNum.mergeValue = 'Group#: ';
        	if((UI_ProvidedBy.mergeValue == ''))
        		ProvidedBy.mergeValue = '';
        	else
        		ProvidedBy.mergeValue = 'Provided By: ';
        	if((UI_PayorNum.mergeValue == ''))
        		PayorNum.mergeValue = '';
        	else
        		PayorNum.mergeValue = 'Payor#: ';
        
        	if(UI_Payor.mergeValue == '' && UI_SubscriberName.mergeValue == '' && UI_SubscriberID.mergeValue == '' &&
        		UI_PayorConName.mergeValue == '' && UI_GroupNum.mergeValue == '' && UI_ProvidedBy.mergeValue == '' &&
        		UI_PayorNum.mergeValue == '')
        	{
        		InjectionTrainingText.visible = false;   
        	}
        	else
        	{
        	InjectionTrainingText.visible = true;
        	}
				            
		if (injectionTrainingNo.checked && !injectionTrainingYes.checked)
        {
         InjectionTrainingText.visible = false;   			       	        	   	
         CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.Checked;     
         CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.unChecked;     
        }
         if (injectionTrainingYes.checked)
         {
         	InjectionTrainingText.visible = true;   			       	        	   	
         CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.unChecked;     
         CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.Checked;    
         }  
         if (!injectionTrainingYes.checked && !injectionTrainingNo.checked)
         {
         	InjectionTrainingText.visible = false;   			       	        	   	
         CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.UnChecked;     
         CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.unChecked;     
         }
         
               
    }   
    
}