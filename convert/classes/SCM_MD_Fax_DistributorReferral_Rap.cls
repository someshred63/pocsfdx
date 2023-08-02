/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : RAP-CMGT-FAX-23_Ditributor_Referral_FinalAnalysis.doc 
    // PRODUCT GROUP     : Dermatology / Raptiva
    // Type				 : Fax Coversheet
    // Word Template     : DistributorReferral_Rap
    // Label in SF       : Distributor Referral 
    
/********************************************************************/
public class SCM_MD_Fax_DistributorReferral_Rap extends SCM_MergeDocument {
	private SCM_MergeSection UiRAPInsuranceInfo;
    private SCM_MergeSection UiObtInsuranceAutho;
    private SCM_MergeSection UiCoordShipment;
    private SCM_MergeSection UiShipReplacement;
    
    private SCM_MergeField CoordInjectionTrainingYes;
    private SCM_MergeField CoordInjectionTrainingNo;
    
    private SCM_MergeFieldCheckbox UiRAPInsuranceInfoChk;
    private SCM_MergeFieldCheckbox UiObtInsuranceAuthoChk;
    private SCM_MergeFieldCheckbox UiCoordShipmentChk;
    private SCM_MergeFieldCheckbox UiShipReplacementChk;
    private SCM_MergeFieldCheckbox UiCoordInjectionTraining;
    
    protected String caseId;
	public SCM_MD_Fax_DistributorReferral_Rap(String caseId, String argLookupId) {
		super(caseID, argLookupId);
		caseId = caseID;
	}
	
	public override void createMergeFields() {
		String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String caseRecordType = selectedCase.RecordType.Name;
        
        //0. Attn(key 'ATTN_Attn')
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter_TextBox(selectedcase.id));
        
        //1. Addressed To(key 'Dispensing Center')('RECNAME_To')
        //this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedcase.id));
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulfillmentAddressTo(selectedcase.id));
        
        //2. Fax No(key 'RECFAX_Fax')
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber(selectedcase.id));
        
        //3. From
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        
        //4. Extension        
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        
        //5. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //6. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //7. CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //8. CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //9. CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //10. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11. PatientFullName(key 'Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        
        //12. Patient DOB(key 'Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        //13. Drug
        this.mergeRecipientInfo.add(new SCM_MF_Drug_Tnk(selectedCase));
        
        //14. Patient Full Address(Key 'PatientCityStateZip')
        //this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(selectedCase.Patient_gne__r.Id));
        //14. Patient Full Address(PatientAddressCityStateZip)
  		this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(selectedCase.Patient_gne__r.Id));
        
        //15. Patient Prime Contact FullName(key 'PatientPrimeConFullName')(PatientFullName)
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(selectedCase.Patient_gne__r.Id));
        //this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientContactFullName(selectedCase.Patient_gne__r.Id));
        
        //16. Patient Prime Contact Home Phone number(key 'Pat_Home_Ph')
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(selectedCase.Patient_gne__r.Id));
        
        //17. Patient Prime contact Work Phone Number(key 'Pat_Work_Ph')
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(selectedCase.Patient_gne__r.Id));
        
        //16 Provider NPI(ProviderNPI)  
        this.mergeRecipientInfo.add( new SCM_MF_ProviderNPI(physicianId));
        
        //17 Facility NPI  (FacilityNPI)      
        this.mergeRecipientInfo.add( new SCM_MF_FacilityNPI(selectedCase));
        
        //'NewStart', 'ContinuedTherapy', 'Restart'
  		this.mergeRecipientInfo.add(new SCM_MF_ChkNewStart(selectedCase, true, true));
  		this.mergeRecipientInfo.add(new SCM_MF_ChkContTherapy(selectedCase, true, true));
  		this.mergeRecipientInfo.add(new SCM_MF_ChkRestartTherapy(selectedCase, true, true));
        
        //ConfidNotice
    	this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    	
        
        //------------------------------------------Second Screen ------------------------------------------//
        
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.headerText = 'Form Information';
        //formInfo.label = 'Insurance Information:';               
        formInfo.key = 'Form Information';
        
        //Ui RAP Insurance Info MergeField
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = 'UiRAPInsuranceInfoMergeField';
        mf.label = 'Insurance Information:';       
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = true;
        mf.isRequired = false;
        formInfo.subFields.add(mf);
        
        //Checkboxes
        UiRAPInsuranceInfoChk = 
            new SCM_MergeFieldCheckbox('UiRAPInsuranceInfoChk',
                'Access Solutions has obtained coverage for the above patient');
        UiRAPInsuranceInfoChk.fieldValue = '' ;                    
        UiRAPInsuranceInfoChk.totalWidth = '900';
        formInfo.subFields.add(UiRAPInsuranceInfoChk);
        
        this.mergeFields.add(formInfo);
        
        SCM_MergeFieldGroup formInfo1 = new SCM_MergeFieldGroup();
        formInfo1.key = 'Form Information1';
        
        //Ui RAP Services RequestedMergeField
        SCM_MergeField mf1 = new SCM_MergeField();
        mf1.key = 'UiRAPInsuranceInfoMergeField';
        mf1.label = 'Services Requested:';       
        mf1.checked = false;
        mf1.displayCheck = false;
        mf1.displayTextBox = false;
        mf1.displayLabel = true;
        mf1.isRequired = false;
        formInfo1.subFields.add(mf1); 
        
        UiCoordInjectionTraining = 
            new SCM_MergeFieldCheckbox('UiRAPInsuranceInfoChk',
                'Coordinate Injection Training');
        UiCoordInjectionTraining.fieldValue = 'Yes' ;                    
        UiCoordInjectionTraining.totalWidth = '900';
        formInfo1.subFields.add(UiCoordInjectionTraining); 
        
        //UI_CoordInjectionTrainingYes
        CoordInjectionTrainingYes = new SCM_MergeField();
        CoordInjectionTrainingYes.key = 'UI_CoordTrainingYes';     
        CoordInjectionTrainingYes.checked = false;
        CoordInjectionTrainingYes.displayCheck = false;
        CoordInjectionTrainingYes.displayTextBox = false;
        CoordInjectionTrainingYes.displayLabel = false;
        CoordInjectionTrainingYes.fieldValue = SCM_CheckBox_Values.unChecked;
        this.mergeRecipientInfo.add(CoordInjectionTrainingYes);
        
        //UI_CoordInjectionTrainingNo
        CoordInjectionTrainingNo = new SCM_MergeField();
        CoordInjectionTrainingNo.key = 'UI_CoordTrainingNo';     
        CoordInjectionTrainingNo.checked = false;
        CoordInjectionTrainingNo.displayCheck = false;
        CoordInjectionTrainingNo.displayTextBox = false;
        CoordInjectionTrainingNo.displayLabel = false;
        CoordInjectionTrainingNo.fieldValue = SCM_CheckBox_Values.unChecked;
        this.mergeRecipientInfo.add(CoordInjectionTrainingNo);
        
        UiObtInsuranceAuthoChk = 
           new SCM_MergeFieldCheckbox('UiObtInsuranceAuthoChk',
           			'Obtain Insurance Authorization');
        UiObtInsuranceAuthoChk.fieldValue = 'Yes' ;                    
        UiObtInsuranceAuthoChk.totalWidth = '900';
        formInfo1.subFields.add(UiObtInsuranceAuthoChk); 
        
        UiCoordShipmentChk = 
            new SCM_MergeFieldCheckbox('UiCoordShipmentChk',
                'Coordinate Shipment with patient upon approval from the insurance');
        UiCoordShipmentChk.fieldValue = '' ;                    
        UiCoordShipmentChk.totalWidth = '900';
        formInfo1.subFields.add(UiCoordShipmentChk);                                
        
        UiShipReplacementChk = 
            new SCM_MergeFieldCheckbox('UiShipReplacementChk',
                'Ship Replacement Criteria Met');
        UiShipReplacementChk.fieldValue = '' ;                    
        UiShipReplacementChk.totalWidth = '900';
        formInfo1.subFields.add(UiShipReplacementChk);
                
        
        this.mergeFields.add(formInfo1);            
         
        
        //Merge Sections       
        UiRAPInsuranceInfo = new SCM_MergeSection();        
        UiRAPInsuranceInfo.key = 'UI_RAPInsuranceInfo';
        this.mergeSections.add(UiRAPInsuranceInfo);
        
        UiObtInsuranceAutho = new SCM_MergeSection();        
        UiObtInsuranceAutho.key = 'UI_ObtInsuranceAutho';
        this.mergeSections.add(UiObtInsuranceAutho);
        
        UiCoordShipment = new SCM_MergeSection();        
        UiCoordShipment.key = 'UI_CoordShipment';
        this.mergeSections.add(UiCoordShipment);
        
        UiShipReplacement = new SCM_MergeSection();        
        UiShipReplacement.key = 'UI_ShipReplacement';
        this.mergeSections.add(UiShipReplacement);
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());
      
        //SCM_MergeFieldGroup comments = new SCM_MergeFieldGroup();
        //SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
            
        //comments.headerText = 'Comments: ';       
        //comments.key = 'Comments1';
        //CommentField.key = 'Comments';                                  
        //comments.subFields.add(CommentField);
        //this.mergeFields.add(comments);	
	}
	 public override void getLatestValues(){
        UiRAPInsuranceInfo.visible = UiRAPInsuranceInfoChk.checked;
        UiObtInsuranceAutho.visible = UiObtInsuranceAuthoChk.checked;
        UiCoordShipment.visible = UiCoordShipmentChk.checked;
        UiShipReplacement.visible = UiShipReplacementChk.checked;
        
        if(!UiCoordInjectionTraining.getMergeValue().startsWith('Yes')){
		
			//InjectionTrainingText.visible = true;	
			CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.Unchecked;
        	CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.Checked;
        }	
		else{
			//InjectionTrainingText.visible = false;	
			CoordInjectionTrainingYes.mergeValue = SCM_CheckBox_Values.Checked;
        	CoordInjectionTrainingNo.mergeValue = SCM_CheckBox_Values.Unchecked;
        }
                  
   }
}