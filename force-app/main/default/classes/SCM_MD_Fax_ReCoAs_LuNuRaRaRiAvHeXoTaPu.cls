/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : CMGT-FAX-18_Referral_to_Copay_Assistance
    // Type              : Fax Coversheet
    // Word Template     : ReferralToCopayAssistance.doc   
    // Label in SF       : Referral To Copay Assistance 
    
/********************************************************************/

public class SCM_MD_Fax_ReCoAs_LuNuRaRaRiAvHeXoTaPu extends SCM_MergeDocument {
    
    public SCM_MD_Fax_ReCoAs_LuNuRaRaRiAvHeXoTaPu(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

		scm_MergeField UI_Besttimetocall = new scm_MergeField();
		scm_MergeField UI_OktoleaveMsg = new scm_MergeField();
		scm_MergeField UI_PatRetroAsst = new scm_MergeField();
		scm_MergeField UI_HowFarBack = new scm_MergeField();
		scm_MergeField UI_FCardReader = new scm_MergeField();
		SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
		private SCM_MergeField mf1;
    public override void createMergeFields() 
    {
        String caseRecordType = selectedCase.RecordType.Name;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c;  
        String patientId = selectedCase.Patient_gne__r.Id;
        String medicalHistory = selectedCase.Medical_History_gne__r.Id;
        
        system.debug('field 0');
        //0 Case Number 
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
        system.debug('field 1'); 
        //1 Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        system.debug('field 2');
        //2 ATTN_COPAY(ATTN_COPAY)
        this.mergeRecipientInfo.add(new SCM_MF_Fax_Attn_CopayAssistance());
        system.debug('field 3');
        //3 RECFAX_COPAY(RECFAX_COPAY)
        this.mergeRecipientInfo.add(new SCM_MF_Fax_CopayAssistance());// key:RECFAX_COPAY
        system.debug('field 4');
        //5 From 
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        system.debug('field 5');
        //6 Extension        
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));  
        system.debug('field 6');
        //4 CR_Phone (CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        system.debug('field 7');
        //7 Dateshort 
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate()); 
         string pid = selectedCase.Patient_gne__c;
         system.debug('field 8');
        //8 Patient Full Name(Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
         system.debug('field 9');
        //9 Gender(Gender)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGender(pid));
        system.debug('field 10');
        //10 DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        system.debug('field 11');
        //11 Patient StAddress(Patient AddressLine1)
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine1(pid));
        system.debug('field 12');
        //12 Patient Mailbox(PatientMailbox)
        this.mergeRecipientInfo.add(new SCM_MF_PatientMailbox(patientNumber));
        system.debug('field 13');
        //13 Patient City(PatientCity)
        SCM_MF_Patient_City city = new SCM_MF_Patient_City(selectedCase.Patient_gne__r.Patient_Id_gne__c);
        
        this.mergeRecipientInfo.add(city);
        system.debug('field 14');
        //14 Patient State(PatientState)
        this.mergeRecipientInfo.add(new SCM_MF_Patient_State(selectedCase.Patient_gne__r.Patient_Id_gne__c));
        system.debug('field 15');
        //15 PatientZip(PatientZip)
        this.mergeRecipientInfo.add(new SCM_MF_Patient_Zip(selectedCase.Patient_gne__r.Patient_Id_gne__c));
        system.debug('field 16');
        //16 Patient Home Phone(Pat_Home_Ph)
    scm_mergefield php = SCM_MF_PatientFieldFactory.PatientHomePhone(pid);
    php.isrequired = false;
        this.mergeRecipientInfo.add(php);
        system.debug('field 18');
        //17 Patient Work Phone(Pat_Work_Ph)
        SCM_Mergefield wf = SCM_MF_PatientFieldFactory.PatientWorkPhone(pid);
        wf.isrequired = false;
        this.mergeRecipientInfo.add(wf);
        system.debug('field 19');
        
        this.mergeFields.add(SCM_MF_patientfieldfactory.PatientCellPhone(pid));
        this.mergeFields.add(SCM_MF_patientfieldfactory.InterpreterNeeded(pid));
        this.mergeFields.add(SCM_MF_patientfieldfactory.PreferredLanguage(pid));
        //18 PatientPrimeConHmPh(PatientPrimeConHmPh)
       
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(pid) );
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(pid));
        system.debug('field 20');
        //19 PatientPrimeConWkPh(WkPh)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeworkPh(pid));
                system.debug('field 21');
        //20 PatientPrimeConFullName(PatientPrimeConFullName)

        
               
      system.debug('field 21');
        //21 PatientPrimeConRelationship(Relationship)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeRelationship(pid));
        system.debug('field 22');
        //22 ICD9CodeDescrptn(ICD9CodeDescrptn)
        this.mergeRecipientInfo.add(new SCM_MF_ICD9CodeDescrptn(medicalHistory));
        system.debug('field 23');
        //23 Product(Product)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        system.debug('field 24');
        //24 Insurance Name(InsuranceName)
        this.mergeRecipientInfo.add(new SCM_MF_CompanyInsurance(selectedCase.CaseNumber));
        system.debug('field 25');
        //25 MedPartDFlag(MedPartDFlag)
        this.mergeRecipientInfo.add(new SCM_MF_MedicarePart(selectedCase.CaseNumber));
        system.debug('field 26');
        //26 InsurancePhone(InsurancePhone)
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhone(selectedCase.Id));
        //The above did not work for case 00002509
        //this.mergeRecipientInfo.add(new SCM_MF_InsurancePhone(selectedCase.id));
        system.debug('field 27');
        //27 DispensingCenter(Dispensing Center)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.id));
        system.debug('field 28');
        //28 Physician Full Name(Physician First Last Name)
        scm_mergefield phyfirs = SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId);
        phyfirs.isrequired = false;
        this.mergeRecipientInfo.add(phyfirs);
        system.debug('field 29');
        //29 Facility Name(FacilityName)
        this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));
        system.debug('field 30');
        //30 Physician Full Address(PhysicianFullAddress)
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianFullAddress(selectedCase));
        system.debug('field 31');
        //31 Physician Contact Phone(PhysContactPh)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
        system.debug('field 32');
        //32 Physician Contact Fax(key:PhysContactFax)
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
        this.mergeRecipientInfo.add(    SCM_MF_PhysicianContactFactory.PhysicianContactFax(SelectedCase) );
        //this.mergeRecipientInfo.add( new SCM_MF_PhysicianPhoneSMN_Luc(selectedCase.Case_Treating_Physician_gne__r.Id, caseRecordType));
              system.debug('field 33');
        //33 Physician Contact Full Name(PhysContactFullName)
        this.mergeRecipientInfo.add(    SCM_MF_PhysicianContactFactory.PhysicianContactFullName(SelectedCase) );
        
        UI_Besttimetocall.displayCheck = false;
      	 UI_Besttimetocall.displayLabel = true;
      	 UI_Besttimetocall.isRequired = true;
      	 UI_Besttimetocall.label = 'Best time to call?';
      	UI_Besttimetocall.width = '200';
      	UI_Besttimetocall.isRequired = true;
      	 this.mergeFields.add(UI_Besttimetocall);
      	
      	
      	UI_OktoleaveMsg.displayCheck = false; 
		 UI_OktoleaveMsg.label = 'OK to leave a message?';
		 UI_OktoleaveMsg.displayTextBox = true;
		 UI_OktoleaveMsg.displayLabel = true;
		 UI_OktoleaveMsg.width = '200';
		 UI_OktoleaveMsg.isRequired = false;
		 this.mergeFields.add(UI_OktoleaveMsg);
		
		
		 UI_HowFarBack.displayCheck = false;
		 UI_HowFarBack.displaylabel = true;
		 UI_HowFarBack.label = 'How far back?';
		 UI_HowFarBack.displayTextBox = true;
		 UI_HowFarBack.width = '200';
		 UI_HowFarBack.isRequired = false;
		 this.mergeFields.add(UI_HowFarBack);
		
		
		 UI_PatRetroAsst.displayCheck = false;
		 UI_PatRetroAsst.displaylabel = true;
		 UI_PatRetroAsst.displayRadio = false;
		 UI_PatRetroAsst.displayDropDown = true;
		 UI_PatRetroAsst.label = 'Does patient need retro assistance?  ';
		 UI_PatRetroAsst.displayTextBox = false;
		
		  
		 UI_PatRetroAsst.selectionItems.add(new SelectOption('Yes','Yes'));            
         UI_PatRetroAsst.selectionItems.add(new SelectOption('No','No'));
         UI_PatRetroAsst.fieldValue = 'No';
   
         UI_PatRetroAsst.controlStyle = 'width:50px;';
		 this.mergeFields.add(UI_PatRetroAsst);
		/*
		mf1 = new SCM_MergeField();
        mf1.displayRadio = true;
        mf1.displayLabel = True;
        mf1.label = 'this is a test';
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.IsRequired = false; 
        mf1.totalWidth = '550';
        mf1.fieldValue = '';       
        mf1.fieldStyle='text-align: left;';
        mf1.selectionItems.add(new SelectOption('Yes','Yes'));            
        mf1.selectionItems.add(new SelectOption('No','No'));
        mf1.fieldValue  = 'No';
		this.mergeFields.add(mf1);
		*/
		 UI_FCardReader.displayCheck = false;
		 UI_FCardReader.displayDropDown = true;
		 UI_FCardReader.displaylabel = true;
		 UI_FCardReader.label = 'Facility Card Reader?';
		 UI_FCardReader.displayTextBox = false; 
		 UI_FCardReader.isRequired = false;
		 UI_FCardReader.selectionItems.add(new SelectOption('Yes','Yes'));            
         UI_FCardReader.selectionItems.add(new SelectOption('No','No'));
         UI_FCardReader.selectionItems.add(new SelectOption('',''));
         UI_FCardReader.fieldValue = '';
         UI_FCardReader.controlStyle = 'width:50px;';
		 this.mergeFields.add(UI_FCardReader);
		 
		
		 UI_Besttimetocall.key = 'UI_Besttimetocall1';
		UI_OktoleaveMsg.key = 'UI_OktoleaveMsg1';	
		UI_HowFarBack.key = 'UI_HowFarBack1';
		 
        
        
        
        
        
        
        system.debug('comments');
        //Comments
        //this.mergeFields.add(new SCM_MF_Comments());
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        comments.headerText = 'Comments: ';       
        comments.key = 'Comment';           
        
        
        CommentField.key = 'Comments';    
        CommentField.setFieldValue('');                   
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);  
        
    }
    public override void getLatestValues() {
    	string strOrigValue = '';
    	
    	
    	scm_MergeField UI_Besttimetocall2 = new scm_MergeField();
		scm_MergeField UI_OktoleaveMsg2 = new scm_MergeField();
		scm_MergeField UI_PatRetroAsst2 = new scm_MergeField();
		scm_MergeField UI_HowFarBack2 = new scm_MergeField();
		scm_MergeField UI_FCardReader2 = new scm_MergeField();
		
    	UI_Besttimetocall2.key = 'UI_Besttimetocall';
		UI_OktoleaveMsg2.key = 'UI_OktoleaveMsg';	
		UI_HowFarBack2.key = 'UI_HowFarBack';	
		UI_PatRetroAsst2.key = 'UI_PatRetroAsst'; 
    
		UI_FCardReader2.key = 'UI_FCardReader';
    	    	  
    	    	  this.mergeFields.add(UI_Besttimetocall2);
    	    	  this.mergeFields.add(UI_OktoleaveMsg2);
    	    	  this.mergeFields.add(UI_HowFarBack2);
    	    	  this.mergeFields.add(UI_PatRetroAsst2);
    	    	
    	    	  this.mergeFields.add(UI_FCardReader2);
    	    	  
    	if (UI_Besttimetocall.Mergevalue != '' && UI_Besttimetocall.Mergevalue != null)
    	{
    		strOrigValue = UI_Besttimetocall.Mergevalue;
    	
    		UI_Besttimetocall2.FieldValue =  'Best time to call: ' + strOrigValue +'\r\n';
    	}
    	if (UI_OktoleaveMsg.Mergevalue != '' && UI_OktoleaveMsg.Mergevalue != null)
    		{
    		strOrigValue = UI_OktoleaveMsg.Mergevalue;
    		UI_OktoleaveMsg2.FieldValue = 'Ok to leave a detailed voice message: ' + strOrigValue +'\r\n';
    	}
    	
    	
    		strOrigValue = UI_PatRetroAsst.Mergevalue;
    		UI_PatRetroAsst2.FieldValue = 'Does patient need retro assistance: ' + strOrigvalue + '\r\n';
    	
    	if (UI_HowFarBack.Mergevalue != '' && UI_HowFarBack.Mergevalue != null)
    	{
    		strOrigValue = UI_HowFarBack.Mergevalue;
    		UI_HowFarBack2.FieldValue = 'How far back: ' + strOrigValue +'\r\n';
    	}
    	if (UI_FCardReader.mergeValue != 'null' && UI_FCardReader.mergeValue != '' && UI_FCardReader.mergeValue != null)
    	{
    		strOrigValue = UI_FCardReader.Mergevalue;
    		UI_FCardReader2.FieldValue = 'Facility Card Reader: ' + strOrigValue +' \r\n';
    	}
    	
        	
    	
    	
    	
    }

}