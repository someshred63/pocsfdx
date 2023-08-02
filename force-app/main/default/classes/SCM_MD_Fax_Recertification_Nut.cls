/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : NUT_CMGT_FAX_20_ RECERTIFICATION.doc
    // Product           : Growth Hormone / Nutropin
    // Type				 : Fax Coversheet
    // Word Template     : CMGT_FAX20_Recertification_Nut.doc  
    // Label in SF       : Recertification
    
/********************************************************************/

public class SCM_MD_Fax_Recertification_Nut extends SCM_MergeDocument implements IStandardComboBox {

	protected String caseId;
    
    public SCM_MD_Fax_Recertification_Nut(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
    public override void createMergeFields() {
    	
    	String caseRecordType = selectedCase.RecordType.Name;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c; 
    	
    	//0. Attn 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        //this.mergeRecipientInfo.add(new SCM_MF_AttnFax(physicianId));
        /**
        SCM_MF_PhysicianContactName phyContName = 
        	new SCM_MF_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id);
        phyContName.label='Attn:';
        phyContName.key = 'ATTN_Attn';
        string phyContNameVal = phyContName.getFieldValue();
        phyContName.fieldValue = phyContNameVal;
        phyContName.fieldType = SCM_MergeField.FieldTypes.fullNameField;
        this.mergeRecipientInfo.add(phyContName);
        */    
        
        //1. Addressed To        
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        //SCM_MF_FaxAdrsTo AddressedTo = new SCM_MF_FaxAdrsTo(selectedCase.Case_Treating_Physician_gne__r.Id);
        //AddressedTo.key = 'RECNAME';
        //this.mergeRecipientInfo.add(AddressedTo);
        /**
        String toValue ;
        SCM_MF_PhysicianFirstMidAndLastName addressedTo = 
         new SCM_MF_PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.Id);
        addressedTo.label='Addressed To:';
        string addressedToVal = addressedTo.getFieldValue();
        toValue = addressedToVal;
        if(toValue.Trim() != '')
        {
            toValue = toValue + ', M.D.' ;
        }               
        addressedTo.fieldValue = toValue;
        addressedTo.fieldType = SCM_MergeField.FieldTypes.fullNameField;        
        this.mergeRecipientInfo.add(addressedTo);
        */

        //2. Fax No
        this.mergeRecipientInfo.add(new SCM_MF_FaxRECFAX(physicianId));
        /**
        SCM_MF_PhysicianContactFax phyContFax = 
        	new SCM_MF_PhysicianContactFax(selectedCase.Case_Treating_Physician_gne__r.Id);
        phyContFax.label='Fax:';
        phyContFax.key = 'RECFAX_Fax';
        string phyContFaxVal = phyContFax.getFieldValue();
        phyContFax.fieldValue = phyContFaxVal;
        phyContFax.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;        
        this.mergeRecipientInfo.add(phyContFax);
        */
        
        //3 & 4. From and Ext
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        /**
        if(selectedCase.RecordType.Name != null)
        {
        	if(selectedCase.RecordType.Name == 'C&R - Continuous Care Case' ||
        		 selectedCase.RecordType.Name == 'C&R - Standard Case')
        	{
        		//From
        		SCM_MF_CaseMangFirstAndLastName caseMangName = 
		        	new SCM_MF_CaseMangFirstAndLastName(selectedCase.Case_Manager__r.Id);       
		        caseMangName.label='From:';
		        caseMangName.key = 'From';
		        string caseMangNameVal = caseMangName.getFieldValue();   
		        caseMangName.fieldValue = caseMangNameVal;          
		       	caseMangName.fieldType = SCM_MergeField.FieldTypes.fullNameField;
		       	caseMangName.isRequired = false;                    
		        this.mergeRecipientInfo.add(caseMangName);
		        
		        // Ext
		        SCM_MF_CaseMangPhoneExt extNo = 
		        	new SCM_MF_CaseMangPhoneExt(selectedCase.Case_Manager__r.Id);		
			    extNo.label='Ext#:';
			    extNo.key = 'Ext';
			    string extNoVal = extNo.getFieldValue();
			    extNo.fieldValue = extNoVal;
			    extNo.fieldType = SCM_MergeField.FieldTypes.extensionField;
			    extNo.isRequired = false;
			    this.mergeRecipientInfo.add(extNo);
        	}
        	if(selectedCase.RecordType.Name == 'GATCF - Standard Case')
        	{
        		//From
        		SCM_MF_FoundationSplName foundSpl = 
        			new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id);
		        foundSpl.label = 'From:';
		        foundSpl.key = 'From';
		        string foundSplVal = foundSpl.getFieldValue();
		        foundSpl.fieldValue = foundSplVal;
		        foundSpl.fieldType = SCM_MergeField.FieldTypes.fullNameField;
		        foundSpl.isRequired = false;
		        this.mergeRecipientInfo.add(foundSpl);
		        
		        //Ext
		        SCM_MF_FoundationSplPhoneExt extNo = 
		        	new SCM_MF_FoundationSplPhoneExt(selectedCase.Foundation_Specialist_gne__r.Id);		
			    extNo.label='Ext#:';
			    extNo.key = 'Ext';
			    string extNoVal = extNo.getFieldValue();
			    extNo.fieldValue = extNoVal;
			    extNo.fieldType = SCM_MergeField.FieldTypes.extensionField;
			    extNo.isRequired = false;
			    this.mergeRecipientInfo.add(extNo);
        	}
        }
        */
        
        //5. Case Number
     	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
     	/**
     	SCM_MF_CaseNumber casNum = new SCM_MF_CaseNumber(selectedCase);
		string casNumVal = casNum.getFieldValue();
		casNum.fieldValue = (casNumVal == null)?'':casNumVal;
		this.mergeRecipientInfo.add(casNum);
		*/
	    
	    //6. Patient Id
	    this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
	    /**
	    SCM_MF_PatientId patId = new SCM_MF_PatientId(selectedCase);
		string patIdVal = patId.getFieldValue();
		patId.fieldValue = (patIdVal == null)?'':patIdVal;
		this.mergeRecipientInfo.add(patId);
		*/
		
		//7. NUT_Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
		/**
		SCM_MergeField nutPh = new SCM_MergeField();
        nutPh.fieldValue = '(866) NUTROPIN / (866) 688-7674';
        nutPh.key = 'NUT_Phone';     
        nutPh.checked = false;
        nutPh.displayCheck = false;
        nutPh.displayTextBox = false;
        nutPh.displayLabel = false;
        nutPh.className = 'SCM_MergeField';
        this.mergeRecipientInfo.add(nutPh);
        */
        
        //8. Phone Short [Key: 'CR_PhoneShort']
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //9. NUT_FAX
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        /**
        SCM_MergeField nutFax = new SCM_MergeField();
        nutFax.fieldValue = '(800) 545-0612';
        nutFax.key = 'NUT_Fax';     
        nutFax.checked = false;
        nutFax.displayCheck = false;
        nutFax.displayTextBox = false;
        nutFax.displayLabel = false;
        nutFax.className = 'SCM_MergeField';
        this.mergeRecipientInfo.add(nutFax);
        */
        
        //10. URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        /**
        SCM_MergeField nutUrl = new SCM_MergeField();
        nutUrl.fieldValue = 'www.NutropinAccessSolutions.com';
        nutUrl.key = 'NUT_URL';     
        nutUrl.checked = false;
        nutUrl.displayCheck = false;
        nutUrl.displayTextBox = false;
        nutUrl.displayLabel = false;
        nutUrl.className = 'SCM_MergeField';
        this.mergeRecipientInfo.add(nutUrl);
        */
        
        //11. Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        /**
        SCM_MF_CurrentDate curDate = new SCM_MF_CurrentDate();
        this.mergeRecipientInfo.add(curDate);
        */
         
        //12. PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        //this.mergeRecipientInfo.add(new SCM_MF_PatientFirstAndLastName(selectedCase));
        /**
        SCM_MF_PatientFirstAndLastName patName = new SCM_MF_PatientFirstAndLastName(selectedCase);
        string patNameVal = patName.getFieldValue();
        patName.fieldValue = patNameVal;  
        this.mergeRecipientInfo.add(patName);
        */
        
        //13. DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        //this.mergeRecipientInfo.add(new SCM_MF_Patient_DOB(patientNumber));
        /**
        SCM_MF_PatientDOB patDob = new SCM_MF_PatientDOB(selectedCase.Patient_gne__r.Id);
		string patDobVal = patDob.getFieldValue();
		patDob.fieldValue = patDobVal;
		this.mergeRecipientInfo.add(patDob);
		*/
		
		//14. Product (Key: 'Product')
		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
		/**
		SCM_MF_ProductName prodName = new SCM_MF_ProductName(selectedCase);
        string prodNameVal = prodName.getFieldValue();
        prodName.fieldValue = prodNameVal;  
        this.mergeRecipientInfo.add(prodName);
        */
        
        //15. PrivacyNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        /**
        SCM_MF_PrivacyNotice_Nut nutPrivyNot = new SCM_MF_PrivacyNotice_Nut();
        string nutPrivyNotVal = nutPrivyNot.getFieldValue();
        nutPrivyNot.fieldValue = nutPrivyNotVal;  
        this.mergeRecipientInfo.add(nutPrivyNot);
        */
        
        //16. InsuranceName (Key: 'InsuranceName')
        this.mergeRecipientInfo.add(new SCM_MF_CompanyInsurance(selectedCase.CaseNumber));
        /**
        SCM_MF_CompanyInsurance insName = new SCM_MF_CompanyInsurance(selectedCase.Id);
        string insNameVal = insName.getFieldValue();
        insName.fieldValue = insNameVal;  
        this.mergeRecipientInfo.add(insName);*/
        
        //17. ConfidNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        /**
        SCM_MF_ConfidNotice_Nut nutConNot = new SCM_MF_ConfidNotice_Nut();
        string nutConNotVal = nutConNot.getFieldValue();
        nutConNot.fieldValue = nutConNotVal;  
        this.mergeRecipientInfo.add(nutConNot);
        */
        
        /////////-------Second Screen ------
        
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Documentation:';
        docu.headerText = 'The Payor is requesting the following updated document(s):';       
        docu.key = 'Documentation';
        
        SCM_MergeFieldCheckbox Checkbox1 = 
        		new SCM_MergeFieldCheckbox('UI_SMNComplete', 'SMN (Completed)');		
		Checkbox1.fieldValue = 'SMN (Completed) \r\n';
        Checkbox1.totalWidth = '270';
        Checkbox1.isNewLine = true;
        docu.subFields.add(Checkbox1);
        
        SCM_MergeFieldCheckbox Checkbox2 = 
        		new SCM_MergeFieldCheckbox('UI_KaryotypeResults', 'Karyotype Results');
   		Checkbox2.fieldValue = 'Karyotype Results \r\n';
        Checkbox2.totalWidth = '270';
        Checkbox2.isNewLine = false; 		 
        docu.subFields.add(Checkbox2);
        
        SCM_MergeFieldCheckbox Checkbox3 = 
        		new SCM_MergeFieldCheckbox('UI_BoneAgeReport', 'Recent Bone Age Report');			
  		Checkbox3.fieldValue = 'Bone Age Report \r\n';		
        Checkbox3.totalWidth = '270';
        Checkbox3.isNewLine = true;
        docu.subFields.add(Checkbox3);
        
        SCM_MergeFieldCheckbox Checkbox4 = new SCM_MergeFieldCheckbox('UI_HisPhysTreat', 'History/Physical/Treatment Plan');			
  		Checkbox4.fieldValue = 'History/Physical/TreamentPlan \r\n';		
        Checkbox4.totalWidth = '270';
        Checkbox4.isNewLine = false;
        docu.subFields.add(Checkbox4);
        
        SCM_MergeFieldCheckbox Checkbox5 = 
        	new SCM_MergeFieldCheckbox('UI_ProgressNotes', 'Recent Progress Notes');			
  		Checkbox5.fieldValue = 'Progress Notes \r\n';		
        Checkbox5.totalWidth = '270';
        Checkbox5.isNewLine = true;
        docu.subFields.add(Checkbox5);
        
        SCM_MergeFieldCheckbox Checkbox6 = 
        	new SCM_MergeFieldCheckbox('UI_RenalFunctionResultsCRIOnly', 'Renal Function Results (CRI Only)');			
  		Checkbox6.fieldValue = 'Renal Function Results (CRI Only) \r\n';		
        Checkbox6.totalWidth = '270';
        Checkbox6.isNewLine = false;
        docu.subFields.add(Checkbox6);
        
        SCM_MergeFieldCheckbox Checkbox7 = new SCM_MergeFieldCheckbox('UI_GrowthChart', 'Current Growth Chart');			
  		Checkbox7.fieldValue = 'Growth Chart \r\n';		
        Checkbox7.totalWidth = '270';
        Checkbox7.isNewLine = true;
        docu.subFields.add(Checkbox7);
        
        SCM_MergeFieldCheckbox Checkbox8 = 
        	new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');			
  		Checkbox8.fieldValue = 'Prescriptions \r\n';		
        Checkbox8.totalWidth = '270';
        Checkbox8.isNewLine = false;
        docu.subFields.add(Checkbox8);
        
        SCM_MergeFieldCheckbox Checkbox9 = 
        	new SCM_MergeFieldCheckbox('UI_StimTestReport', 'Stim Test(s) Report(s)');			
  		Checkbox9.fieldValue = 'Stim Test(s) Report(s) \r\n';		
        Checkbox9.totalWidth = '270';
        Checkbox9.isNewLine = true;  
        docu.subFields.add(Checkbox9);
        
        SCM_MergeFieldCheckbox Checkbox10 = 
        	new SCM_MergeFieldCheckbox('UI_PrioAuthForm', 'Prior Authorization Form (signed & completed)');			
  		//Checkbox10.fieldValue = 'Prior Authorization Form (signed & completed) \r\n';
  		Checkbox10.displayExtraHTML = true; 
        Checkbox10.extraHTML='Prior Authorization Form (signed & completed) \r\n';
        Checkbox10.displayLabel = false; 		
        Checkbox10.totalWidth = '270';
        Checkbox10.isNewLine = false;
        docu.subFields.add(Checkbox10);
        
        SCM_MergeFieldCheckbox Checkbox11 = 
        	new SCM_MergeFieldCheckbox('UI_PCPReferral', 'PCP Referral');			
  		Checkbox11.fieldValue = 'PCP Referral \r\n';		
        Checkbox11.totalWidth = '270';
        Checkbox11.isNewLine = true;
        docu.subFields.add(Checkbox11);
        
        //SCM_MergeFieldCheckbox Checkbox12 = 
        	//new SCM_MergeFieldCheckbox('Other', 'Other');			
  		//Checkbox12.fieldValue = 'PCP Referral \r\n';		
        //Checkbox12.totalWidth = '270';
        //Checkbox12.isNewLine = false;
        //docu.subFields.add(Checkbox12);
        
        SCM_MergeField OtherDoc1 = new SCM_MF_OtherDocuments('UI_OtherDoc1', 'Other Documentation');
        SCM_MergeField OtherDoc2 = new SCM_MF_OtherDocuments('UI_OtherDoc2', '');
        SCM_MergeField OtherDoc3 = new SCM_MF_OtherDocuments('UI_OtherDoc3', '');
        docu.subFields.add(OtherDoc1);
        docu.subFields.add(OtherDoc2);
        docu.subFields.add(OtherDoc3);
        
        this.mergeFields.add(docu);
        
        SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        
        comments.headerText = 'Comments: ';       
        comments.key = 'Comments';                                  
        comments.subFields.add(CommentField);
        this.mergeFields.add(comments);
        
    }
    
    
}