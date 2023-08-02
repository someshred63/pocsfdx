/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : RA-CMGT-FAX-07 Appeal Information
    // PRODUCT GROUP     : Rheumatology / Rituxan RA
    // Type              : Fax Coversheet
    // Word Template     : CMGT_FAX_07_ AppealInformation.doc    
    // Label in SF       : CMGT FAX 07 Appeal Information
    
/********************************************************************/
public class SCM_MD_CMGT_FAX07_AppealInfo extends SCM_MergeDocument implements IStandardComboBox {
    
    private SCM_MergeSection UIRAAppealDenied_1;
    private SCM_MergeSection UIRAAppealDenied_2;
    private SCM_MergeSection UIRAAppealDenied;
    private SCM_MergeField UI_Deadline;
    private SCM_MergeField UIRAAppealDeniedRadBtn;
    private SCM_MergeField AppealDenApp;
    private SCM_MergeField TenDaysAfterCurrent;
    
    private SCM_MF_InsuranceAppealName objInsurance;
    
    private SCM_MergeField InsuranceNameAppeal;
    
    private String strInsuranceNameAppeal;
    private String InsuranceAppealStatus;
    
    
    public SCM_MD_CMGT_FAX07_AppealInfo (String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    
    public override void createMergeFields() {
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String caseRecordType = selectedCase.RecordType.Name;
        String patientNumber = selectedCase.patient_gne__r.id;
        
        //0. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        this.mergeRecipientInfo.add(new SCM_MF_product_DrugName(selectedCase));
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
        
        //1.RECNAME_FACPHY(key RECNAME_To) 
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianAddressTo1(selectedCase));
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(physicianId));
        
        //2. Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
        //3. From
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        
        //4. Extension        
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        
        //5. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //6. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //7. CR_Phone('Phone')
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone(selectedCase));
        
        //CR_PhoneShort
       	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
     
        
        //8. CR_Fax('Fax')
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax(selectedCase));
        
        //9. CR_URL('URL')
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //10. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11. PatientFullName('Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientNumber));
        
        //12. Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientNumber));
        
        //13. Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //14. Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c)); 
        //InsuranceName_Appeal(InsuranceName_Appeal)
        
        objInsurance = new SCM_MF_InsuranceAppealName();
         
        List<Account> appeals = objInsurance.getAppealInfo(selectedCase);
        
        strInsuranceNameAppeal = '';
        if( null != appeals)
        {
        	if(appeals.size() >0)
        	{
        		strInsuranceNameAppeal = appeals[0].Name;
        	} 
        }
         
        InsuranceNameAppeal =  new SCM_MF_OtherDocuments('InsuranceName_Appeal','');
        InsuranceNameAppeal.isRequired = false;
        InsuranceNameAppeal.displaytextbox = false;
        InsuranceNameAppeal.displayCheck = false;
        InsuranceNameAppeal.requireNewLineInTemplate = false;  
        InsuranceNameAppeal.fieldValue =strInsuranceNameAppeal;
        this.mergeRecipientInfo.add(InsuranceNameAppeal);
        
        //AppealDenApp(AppealDenApp)
        AppealDenApp = new SCM_MF_OtherDocuments('AppealDenApp', '');
        AppealDenApp.isRequired = false;
        AppealDenApp.displaytextbox = false;
        AppealDenApp.displayCheck = false;
        AppealDenApp.requireNewLineInTemplate = false;  
        AppealDenApp.fieldValue ='';
        this.mergeRecipientInfo.add(AppealDenApp);
       
        TenDaysAfterCurrent = new SCM_MF_OtherDocuments('TenDaysAfterCurrentDate', '');
        TenDaysAfterCurrent.isRequired = false;
        TenDaysAfterCurrent.displaytextbox = false;
        TenDaysAfterCurrent.displayCheck = false;
        TenDaysAfterCurrent.requireNewLineInTemplate = false;  
        //TenDaysAfterCurrent.fieldValue =Date.today().addDays(10).format();
        
        //TenDaysAfterFax('TenDaysAfterCurrent')
        this.mergeRecipientInfo.add(TenDaysAfterCurrent);
      
        
        //UI_PRIOR_TREAT_DESC(PRIOR_TREAT_DESC)
        
        // -------------UI - Second Screen -------------------                
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Appeal Information:';
        docu.key = 'Documentation';
        
        //TextBoxes 
        SCM_MergeField UIDatePayer = new SCM_MF_OtherDocuments('UI_DatePayer', 'Date Payor contacted :');
        UIDatePayer.isRequired = false;
        UIDatePayer.fieldType = SCM_MergeField.Fieldtypes.dateField;
        UIDatePayer.totalWidth = '440';
        UIDatePayer.requireNewLineInTemplate = false;   
        docu.subFields.add(UIDatePayer);
        
        SCM_MergeField UIDateService = new SCM_MF_OtherDocuments('UI_DateService', 'Dates of service:');
        UIDateService.isRequired = false;
        UIDateService.totalWidth = '420';
        UIDateService.requireNewLineInTemplate = false;   
        docu.subFields.add(UIDateService);
        
        //Merge Sections 
        //UI_RA_AppealDenied_1      
        UIRAAppealDenied_1 = new SCM_MergeSection();        
        UIRAAppealDenied_1.key = 'UI_RA_AppealDenied_1';
        UIRAAppealDenied_1.visible = false;
        this.mergeSections.add(UIRAAppealDenied_1);
        
        //UI_RA_AppealDenied_2
        UIRAAppealDenied_2 = new SCM_MergeSection();        
        UIRAAppealDenied_2.key = 'UI_RA_AppealDenied_2';
        UIRAAppealDenied_2.visible = false;
        this.mergeSections.add(UIRAAppealDenied_2);
        
        //UI_RA_AppealApproved
        UIRAAppealDenied = new SCM_MergeSection();        
        UIRAAppealDenied.key = 'UI_RA_AppealApproved';
        UIRAAppealDenied.visible = false;
        this.mergeSections.add(UIRAAppealDenied);
        
        
        UIRAAppealDeniedRadBtn = new SCM_MergeField();
        UIRAAppealDeniedRadBtn.displayRadio = true;
        UIRAAppealDeniedRadBtn.displayLabel = false;
        UIRAAppealDeniedRadBtn.displayCheck = false;
        UIRAAppealDeniedRadBtn.displayTextbox = false;
        UIRAAppealDeniedRadBtn.isRequired = false;
        UIRAAppealDeniedRadBtn.totalWidth = '600';
        UIRAAppealDeniedRadBtn.fieldStyle='text-align: left;';
        
        UIRAAppealDeniedRadBtn.selectionItems.add(new SelectOption('a', 'Denied. \n Please fax a copy of the denial(s) to Access Solutions. Upon receipt, \r\n'
                +' Access Solutions will review the case to determine if the next\r\n'
                + ' level of appeal is appropriate. Generally, a case is not considered for product replacement until \r\n'
                + ' two levels of appeal have been attemted.\r\n'
                + '\r\n'
                + ' Immediate response to denials is crucial as payers have appeal deadline [e.g. Medicare allows 120 days \r\n'
                + ' from the EOB remittance date to respond to a denial].* '
                + '\r\n' 
                + ' After reviewing the case, Access Solutions will be in contact with you.'
                + '\r\n' 
                + ' Please fax a copy of the denial letter(s) by (10 business days from fax), so that Access Solutions can proceed in timely \r\n' 
                + 'matter.\r\n'
                + '\r\n'
                + ' *Please note: Denials or Appeals that are beyond untimely filing are not eligible for\r\n'
                + 'product replacement.'));
        UIRAAppealDeniedRadBtn.totalWidth = '600';
        UIRAAppealDeniedRadBtn.selectionItems.add(new SelectOption('b','Denied. \n Please fax a copy of the denial to Access Solutions. Access Solutions has determined'
                + ' this case in not appropriate for the next level \r\n of appeal.'
                + '\r\n'
                + 'Upon receipt of the denial, this case will be referred to the Genentech ® Access To Care Foundation for \r\n'
                + 'consideration of product replacement.'
                + '\r\n'
                + 'Please fax a copy of the denial letters(s) by (10 business days from the fax), so that Access Solutions can proceed in timely \r\n'
                + 'matter.'));
        
        UIRAAppealDeniedRadBtn.selectionItems.add(new SelectOption('c','Approved. \nPayment should be expected within '));
        UIRAAppealDeniedRadBtn.fieldStyle='text-align: left;';      
        UIRAAppealDeniedRadBtn.Key = 'RadioButtonValue';
        UIRAAppealDeniedRadBtn.FieldValue = UIRAAppealDeniedRadBtn.selectedValue;
        UIRAAppealDeniedRadBtn.isnewline = true;
        docu.subFields.add(UIRAAppealDeniedRadBtn);
        
        UI_Deadline = new SCM_MF_OtherDocuments('PRIOR_TREAT_DESC', '');
        UI_Deadline.isRequired = false;
        UI_Deadline.Width = '60';
        //UI_Deadline.fieldStyle='text-align: right;';
        //UI_Deadline.fieldType = SCM_MergeField.FieldTypes.extensionField;
        UI_Deadline.fieldStyle='text-align: left; margin-top: -30px; margin-left: 280px;';      
        UI_Deadline.isnewline = false;
        UI_Deadline.totalWidth = '200';
        UI_Deadline.requireNewLineInTemplate = false;   
        docu.subFields.add(UI_Deadline);
 		
 		SCM_MergeField UI_Text = new SCM_MF_OtherDocuments('UI_Text', 'At this time, Access Solutions will close this case.');
        UI_Text.isRequired = false;
        UI_Text.displaytextbox = false;
        UI_Text.fieldStyle='text-align: left; margin-top: -30px; margin-left: 350px;';  
        UI_Text.isnewline = false;
        //UI_Text.totalWidth = '280';
        docu.subFields.add(UI_Text);
 		
        this.mergeFields.add(docu);
        
    }
    
   /*
    public override void getLatestValues(){
        
        if( UIRAAppealDeniedRadBtn.selectedValue == UIRAAppealDeniedRadBtn.selectionItems[0].getValue() ){
            UIRAAppealDenied_1.visible = true;
            
        }
        else if( UIRAAppealDeniedRadBtn.selectedValue == UIRAAppealDeniedRadBtn.selectionItems[1].getValue() ){
            UIRAAppealDenied_2.visible = true;
        }
        else if( UIRAAppealDeniedRadBtn.selectedValue == UIRAAppealDeniedRadBtn.selectionItems[2].getValue() ){
            UIRAAppealDenied_3.visible = true;
        }
        else {
            UIRAAppealDenied_1.visible = false;
            UIRAAppealDenied_2.visible = false;
            UIRAAppealDenied_3.visible = false;
        }
        
    }
   */
    public override void getLatestValues(){

   		
   		 objInsurance = new SCM_MF_InsuranceAppealName();
         
        List<Account> appeals = objInsurance.getAppealInfo(selectedCase);
        
        //InsuranceAppealStatus = '';
        //if( null != appeals)
        //{
        //	if(appeals.size() >0)
        //	{
        //		InsuranceAppealStatus = appeals[0].Appeal_Status_gne__c.contains('Not Appealable');
        //	}
        //}
        
        strInsuranceNameAppeal = '';
        if( null != appeals)
        {
        	if(appeals.size() >0)
        	{
        		strInsuranceNameAppeal = appeals[0].Name;
        	}
        }
    
         
        appeals = objInsurance.getApprovedAppealedList(selectedCase);
        
        String strApprovedInsurance ='';
        
    	if( null != appeals)
        {
        	if(appeals.size() >0)
        	{
        		strApprovedInsurance = appeals[0].Name;
        	}
        }
        
        if(UIRAAppealDeniedRadBtn.getMergeValue().startsWith('a')){
        	TenDaysAfterCurrent.mergeValue =Date.today().addDays(10).format();
        	if (strInsuranceNameAppeal != '')
        	 AppealDenApp.mergeValue ='denied';
            UIRAAppealDenied_1.visible = true;
            
        }
        else if(UIRAAppealDeniedRadBtn.getMergeValue().startsWith('b')){
        	TenDaysAfterCurrent.mergeValue =Date.today().addDays(10).format();
        	if (strInsuranceNameAppeal != '')        
        	 AppealDenApp.mergeValue ='denied';
            UIRAAppealDenied_2.visible = true;
        }
        else if(UIRAAppealDeniedRadBtn.getMergeValue().contains('c')){
        	if (strApprovedInsurance != '')
        	 AppealDenApp.mergeValue ='approved';
            UIRAAppealDenied.visible = true;
        }
        else {
            UIRAAppealDenied_1.visible = false;
            UIRAAppealDenied_2.visible = false;
            UIRAAppealDenied.visible = false;
        }
        
       //if(UIRAAppealDeniedRadBtn.getMergeValue().startsWith('c')){
         //   UIRAAppealDenied_3.visible = true;
        //UIRAAppealDeniedRadBtn
        
    }

}