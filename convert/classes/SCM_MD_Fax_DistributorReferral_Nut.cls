/********************************************************************/
    // Developer Name    : Deepti(Deepak)
    // Document Name     : NUT-CMGT-FAX-23_Distributor_Referral_FinalAnalysis.doc
    // Product           : Growth Hormone / Nutropin
    // Type				 : Fax Coversheet
    // Word Template     : CMGT-FAX-23-DistributorReferralFinalAnalysis-Nut.doc
    // Label in SF       : Distributor Referral
    
/********************************************************************/
public class SCM_MD_Fax_DistributorReferral_Nut extends SCM_MergeDocument{
     
     private SCM_MergeSection UI_InsuranceInfo;
	 private SCM_MergeSection UI_ObtGHInsuranceAuthoInfo;
	 private SCM_MergeSection UI_CoordShipmentWPatInfo;
	 private SCM_MergeSection UI_ShipReplacementInfo;
	 private SCM_MergeSection InjectionTrainingText;
	 //private SCM_MergeSection UI_SalesInfo;
	 
	 private SCM_MergeField mf1;
	 private SCM_MergeField CoordInjectionTrainingNo;
	 private SCM_MergeField CoordInjectionTrainingYes;

	private SCM_MergeField UI_Payor;
	private SCM_MergeField UI_SubscriberName;
	private SCM_MergeField UI_SubscriberID;
	private SCM_MergeField UI_PayorConName;
	private SCM_MergeField UI_GroupNum;
	private SCM_MergeField UI_ProvidedBy;
	private SCM_MergeField UI_PayorNum;


	 private SCM_MergeFieldCheckbox Checkbox1;
	 private SCM_MergeFieldCheckbox Checkbox2;
	 private SCM_MergeFieldCheckbox Checkbox3;
	 private SCM_MergeFieldCheckbox Checkbox4;
	 private SCM_MergeFieldCheckbox Checkbox5;
	 
     public SCM_MD_Fax_DistributorReferral_Nut(String caseId, String argLookupId) {
        super(caseId, argLookupId);
     }
     
     public override void createMergeFields() {
     	
     	//local variables
     	String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String pid = selectedCase.Patient_gne__c;
        String caseRecordType = selectedCase.RecordType.Name ;
     	
     	//-------------------------------------------------------------------------------------------
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));               
        // 1  Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));        
        // 2 CR_Phone(CR_PhoneShort)
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));        
        // 3 CR_Fax(CR_Fax)        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));         
        // 4 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        //5. DateShort(Key:Current_Date)
     	this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
     	//-----------------------------------------------------------------------------------------------
     	//6 PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        
        //7 Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
        //8 Drug(Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase));
        
        //9 Patient Full Address(PatientCityStateZip)
        //this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(pId));
        this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(patientId));//PatientAddressCityStateZip
              
        //10 Patient Prime Contact FullName(PatientPrimeConFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(patientId)); 
                     
        //11 Patient Prime Contact Home Phone(Pat_Home_Ph)   
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(patientId));    
            
        //12 Patient Prime contact Work Phone(Pat_Work_Ph)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(patientId));
        
        //---------------------------------------------------------------------------------------------------
     	//13. ProviderNPI(Key:ProviderNPI)
     	this.mergeRecipientInfo.add(new SCM_MF_ProviderNPI(selectedCase.Case_Treating_Physician_gne__r.Id));
     	
     	//14 Facility NPI  (FacilityNPI)      
        this.mergeRecipientInfo.add( new SCM_MF_FacilityNPI(selectedCase));
     	
     	//15. ConfidNotice(key:ConfidNotice)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
     	
     	//16. Physician Full Name(Key:Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
     	//--------------------------------------------------------------------------------------------------
     	
     	//17. Pediatric(Key:Pediatric)
     	this.mergeRecipientInfo.add(new SCM_MF_ChkPediatric(selectedCase));
     	
     	//18. Adult(Key:Adult)
     	this.mergeRecipientInfo.add(new SCM_MF_ChkAdult(selectedCase));
     	
     	//19. NewStart(NewStart)
        this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase,true,true));
        
        //20. ContinuedTherapy(ContinuedTherapy)
        this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase,true,true));
		//---------------------------------------------------------------------------------------------------
		
        //21. SalesRepName(Key:SalesRepName)
        SCM_MergeField SalesRepName =  SCM_MF_SalesFieldFactory.SalesRepName(selectedCase);
        SalesRepName.key='SalesRepName';
        this.mergeRecipientInfo.add(SalesRepName);
        
        //22. SalesRepEmail(Key:SalesRepEmail)
     	SCM_MergeField SalesRepEmail = SCM_MF_SalesFieldFactory.SalesRepEmail(selectedCase);
        SalesRepEmail.key='SalesRepEmail';
        this.mergeRecipientInfo.add(SalesRepEmail);
        
        /////////-------First Screen ------
     	 
     	// 23 ATTN_DIST(ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter_TextBox(selectedcase.id));
        
        // 24 Addressed To(RECNAME_To) 
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentAddressTo(selectedcase.id));
        //this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedcase.id));
        
        // 25 Fax No(RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber(selectedcase.id));
        
        // 26 From(From)         
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        // 28 Extension(Ext)
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        
        //-------------------------------------------------------------------------------------
           
        
        /////////-------Second Screen ------
        
        //Injection Training:
        SCM_MergeFieldGroup forminfo = new SCM_MergeFieldGroup();
        forminfo.label = 'Injection Training';
        forminfo.headerText = 'Injection Training';       
        forminfo.key = 'Injection Training';
        
        // Label
        SCM_MergeField injTrainLabel = new  SCM_MergeField();
        injTrainLabel.label = 'Injection Training Required';
        injTrainLabel.fieldValue = '';
        injTrainLabel.displayCheck = false;
        injTrainLabel.displayTextBox = false;
        injTrainLabel.isRequired=false;
        injTrainLabel.isNewLine=true;    
        forminfo.subFields.add(injTrainLabel);        
        //---------------------------------------------------Radio and Merge Fields----------------------------
        // Radio Button - 
        mf1 = new SCM_MergeField();
        mf1.isNewLine=false;
        mf1.displayRadio = true;
        mf1.displayLabel = false;
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.isRequired = false;
        mf1.fieldStyle='text-align: left;';
        mf1.selectionItems.add(new SelectOption('Yes','Yes'));      
        mf1.selectionItems.add(new SelectOption('No','No'));
                     mf1.fieldValue = 'No';
                     mf1.key = 'raido button';
        forminfo.subFields.add(mf1);
        //this.mergeFields.add(mf1);
        
        
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
        
        //---------Text Boxes---------
           
        UI_Payor= new SCM_MF_OtherDocuments('UI_Payor', 'Payor: ');
        //UI_Payor.label = 'Payor: ';
        UI_Payor.isNewLine = true;
        UI_Payor.totalWidth = '400';
        
        UI_SubscriberName = new SCM_MF_OtherDocuments('UI_SubscriberName', 'Subscriber Name:');
        //UI_SubscriberName.label = 'Subscriber Name: ';
        UI_SubscriberName.isNewLine = true;
        UI_SubscriberName.totalWidth = '400';
        
        UI_SubscriberID = new SCM_MF_OtherDocuments('UI_SubscriberID', 'Subscriber ID:');
        //UI_SubscriberID.label = 'Subscriber ID: ';
        UI_SubscriberID.isNewLine = false;
        UI_SubscriberID.totalWidth = '400';
        
        UI_PayorConName = new SCM_MF_OtherDocuments('UI_PayorConName', 'Payor Contact:');
        //UI_PayorConName.label = 'Payor Contact:  ';
        UI_PayorConName.totalWidth = '400';
        UI_PayorConName.isNewLine = true;
        
        UI_GroupNum = new SCM_MF_OtherDocuments('UI_GroupNum', 'Group#:');
        //UI_GroupNum.label = 'Group#:  ';
        UI_GroupNum.totalWidth='400';
        UI_GroupNum.isNewLine = false;
        
        
        UI_ProvidedBy = new SCM_MF_OtherDocuments('UI_ProvidedBy', 'Provided By:');
        //UI_ProvidedBy.label = 'Provided By:  ';
        UI_ProvidedBy.isNewLine = true;
        UI_ProvidedBy.totalWidth = '400';
        
        UI_PayorNum = new SCM_MF_OtherDocuments('UI_PayorNum', 'Phone:');
        //UI_PayorNum.label = 'Phone: ';
        UI_PayorNum.isNewLine = true;
        UI_PayorNum.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        UI_PayorNum.totalWidth = '400';
         
        formInfo.subFields.add(UI_Payor);
        formInfo.subFields.add(UI_SubscriberName);
        formInfo.subFields.add(UI_SubscriberID);
        formInfo.subFields.add(UI_PayorConName);
        formInfo.subFields.add(UI_GroupNum);
        formInfo.subFields.add(UI_ProvidedBy);
        formInfo.subFields.add(UI_PayorNum);
              
        //---------Checkbox----------
        // UI_SalesInfo
        
        
        //--------------------------------------**-------------------------------
        //Form Information
        SCM_MergeFieldGroup forminfo1 = new SCM_MergeFieldGroup();
        formInfo1.label = 'Form Information';                 
        formInfo1.key = 'Form Information';
        formInfo1.headerText = 'Form Information:';
        
        // Merge Section
        
        //UI_SalesInfo
        //UI_SalesInfo = new SCM_MergeSection();                 
        //UI_SalesInfo.key = 'UI_SalesInfo';
        //this.mergeSections.add(UI_SalesInfo);
        
        // UI_InsuranceInfo
        UI_InsuranceInfo = new SCM_MergeSection();                 
        UI_InsuranceInfo.key = 'UI_InsuranceInfo';
        this.mergeSections.add(UI_InsuranceInfo);
        
        // UI_ObtGHInsuranceAutho
        UI_ObtGHInsuranceAuthoInfo = new SCM_MergeSection();                 
        UI_ObtGHInsuranceAuthoInfo.key = 'UI_ObtGHInsuranceAutho';
        this.mergeSections.add(UI_ObtGHInsuranceAuthoInfo);
        
        // UI_CoordShipmentWPat
        UI_CoordShipmentWPatInfo = new SCM_MergeSection();                 
        UI_CoordShipmentWPatInfo.key = 'UI_CoordShipmentWPat';
        this.mergeSections.add(UI_CoordShipmentWPatInfo);
        
        // UI_ShipReplacement
        UI_ShipReplacementInfo = new SCM_MergeSection();                 
        UI_ShipReplacementInfo.key = 'UI_ShipReplacement';
        this.mergeSections.add(UI_ShipReplacementInfo);
        
        // InjectionTrainingText
        InjectionTrainingText=new SCM_MergeSection();
        InjectionTrainingText.key = 'UI_InjectionTrainingText';
        this.mergeSections.add(InjectionTrainingText);
        //-----------------------
        
        //Checkboxes
        //1.UI_InsuranceInfo
        Checkbox2 = 
        		new SCM_MergeFieldCheckbox('UI_AccessSolutions', 'Access Solutions has obtained coverage for the above growth hormone patient');		
		Checkbox2.fieldValue = ' ';
        Checkbox2.totalWidth = '600';
        Checkbox2.isNewLine = true;
        forminfo1.subFields.add(Checkbox2);
        
       //2.UI_ObtGHInsuranceAutho
        Checkbox3 = 
        		new SCM_MergeFieldCheckbox('UI_GrowthInsurance', 'Obtain Growth Hormone Insurance Authorization');		
		Checkbox3.fieldValue = ' ';
        Checkbox3.totalWidth = '400';
        Checkbox3.isNewLine = true;
        forminfo1.subFields.add(Checkbox3);
        
        //3.UI_CoordShipmentWPat
        Checkbox4 = 
        		new SCM_MergeFieldCheckbox('UI_CoordinateShipment', 'Coordinate Shipment with the patient listed above');		
		Checkbox4.fieldValue = ' ';
        Checkbox4.totalWidth = '400';
        Checkbox4.isNewLine = true;
        forminfo1.subFields.add(Checkbox4);
        
        //4.UI_ShipReplacement
        Checkbox5 = 
        		new SCM_MergeFieldCheckbox('UI_ShipReplacementInfo', 'Ship Replacement Criteria Met');		
		Checkbox5.fieldValue = ' ';
        Checkbox5.totalWidth = '400';
        Checkbox5.isNewLine = true;
        forminfo1.subFields.add(Checkbox5);
        
        this.mergeFields.add(forminfo1);
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());
        
     }
     
     public override void getLatestValues()  {
     	
        	
       	UI_InsuranceInfo.visible = Checkbox2.checked;
        UI_ObtGHInsuranceAuthoInfo.visible = Checkbox3.checked;  
        UI_CoordShipmentWPatInfo.visible = Checkbox4.checked;
        //UI_ShipReplacementInfo.visible = Checkbox4.checked;  
        	
        	 if (mf1.getMergeValue().contains('Yes'))
        	{
         		InjectionTrainingText.visible = true;            
         		CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.Checked;
         
        	}
        	else
        	{
        		InjectionTrainingText.visible = false;   
        	  		CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.UnChecked;
       
        	}
   		
        	
        	//if(UI_Payor.mergeValue == '') 
        	//{
        	//	UI_Payor.mergeValue = ' ';
        	//}
       	
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
        		if (mf1.getMergeValue().contains('No'))
        	{
         		InjectionTrainingText.visible = false;                           
         		CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.Checked;     
        	}
        	else
        	{
        	  		CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.UnChecked;
       
        	}
        	
        	
        	
        		
        	if (Checkbox5.checked == false)
        		UI_ShipReplacementInfo.visible = false;
        	else
        		UI_ShipReplacementInfo.visible = true;
        }
  }