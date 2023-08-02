/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : LUC-CMGT-FAX-23 Distributor Referral.doc
    // PRODUCT GROUP     : Opthalmology / Lucentis
    // Type              : Fax Coversheet
    // Word Template     : Distributor_Referral_Lucentis.doc    
    // Label in SF       : Distributor Referral 
    
/********************************************************************/
   
public class SCM_MD_Fax_DistributorReferral_Luc extends SCM_MergeDocument {
    
    private String caseRecordType;
    private SCM_MergeSection UiInsuranceInfo;
    private SCM_MergeSection UiCoordinateShipment;
    private SCM_MergeSection UiObtainInsuranceAuth;
    private SCM_MergeSection UiOneOffSP;
    protected String PhysicianId;
    protected String PatientId;
    
    private SCM_MergeFieldCheckbox UiInsuranceInfoChk;
    private SCM_MergeFieldCheckbox UiCoordinateShipmentChk;
    private SCM_MergeFieldCheckbox UiObtainInsuranceAuthChk;
    private SCM_MergeFieldCheckbox UiOneOffSPChk;
    
    public SCM_MD_Fax_DistributorReferral_Luc(String caseID, String argLookupId) {
        super(caseID, argLookupId);
        caseId = caseID;
    }
    
    public override void createMergeFields() {
       
       
        PhysicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        PatientId = selectedCase.patient_gne__r.id;     
       
        // 0 Case Number
        SCM_MF_CaseNumber caseNumber = new SCM_MF_CaseNumber(selectedCase);
        this.mergeRecipientInfo.add(caseNumber);          
         
        // 1 Patient Number
        SCM_MF_PatientId patientID = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patientId);   
        
        //3.CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //4. CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //5. CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        // 5 Attn       
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter_TextBox(selectedcase.id));
        
        // 6 Addressed To      
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentAddressTo(selectedcase.id));
        
        // 7 Fax No
         this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber(selectedcase.id));
     
      
        //From and Ext
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }
        //9 Extension
       
        // 10 Current Date
        this.mergeRecipientinfo.add(new SCM_MF_CurrentDate());
        
        // 11 Patient Full Name
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
         
        // 12  Date Of Birth
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        
         // 13 Patient Full Address
        this.mergeRecipientInfo.add( new SCM_MF_PatAddressCityStateZip(selectedCase.patient_gne__r.id));
       
        // 14 Patient Prime Contact FullName
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(selectedCase.Patient_gne__r.Id));
        
        // 15 Patient Prime Contact Home Phone number
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientHomePhone(selectedCase.Patient_gne__r.Id));
        
        // 16 Patient Prime contact Work Phone Number
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientWorkPhone(selectedCase.Patient_gne__r.Id));   

    	// Provider NPI(ProviderNPI)  
        this.mergeRecipientInfo.add( new SCM_MF_ProviderNPINew(physicianId));
        
        // Facility NPI  (FacilityNPI)      
        this.mergeRecipientInfo.add( new SCM_MF_FacilityNPI(selectedCase));
   
        //19 Confidential Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //------------------------------------------Second Screen ------------------------------------------//
        
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.headerText = 'Form Information';               
        formInfo.key = 'Form Information';
        
        //Checkboxes
        UiInsuranceInfoChk = 
            new SCM_MergeFieldCheckbox('UiInsuranceInfoChk',
                'Access Solutions Has obtained coverage for the above Lucentis patient');
        UiInsuranceInfoChk.fieldValue = '' ;                    
        UiInsuranceInfoChk.totalWidth = '900';
        formInfo.subFields.add(UiInsuranceInfoChk); 
        
        UiCoordinateShipmentChk = 
            new SCM_MergeFieldCheckbox('UiCoordinateShipmentChk',
                'Coordinate shipment with patient listed above');
        UiCoordinateShipmentChk.fieldValue = '' ;                    
        UiCoordinateShipmentChk.totalWidth = '900';
        formInfo.subFields.add(UiCoordinateShipmentChk); 
        
        UiObtainInsuranceAuthChk = 
           new SCM_MergeFieldCheckbox('UiObtainInsuranceAuthChk',
                    'Obtain Insurance Authorization');
        UiObtainInsuranceAuthChk.fieldValue = '' ;                    
        UiObtainInsuranceAuthChk.totalWidth = '900';
        formInfo.subFields.add(UiObtainInsuranceAuthChk); 
        
        UiOneOffSPChk = new SCM_MergeFieldCheckbox('UiOneOffSPChk','One Off SP');
        UiOneOffSPChk.fieldValue = '' ;                    
        UiOneOffSPChk.totalWidth = '900';
        formInfo.subFields.add(UiOneOffSPChk);    
        
        this.mergeFields.add(formInfo); 
        
        //Merge Sections       
        UiInsuranceInfo = new SCM_MergeSection();        
        UiInsuranceInfo.key = 'UI_InsuranceInfo';
        this.mergeSections.add(UiInsuranceInfo);
        
        UiCoordinateShipment = new SCM_MergeSection();        
        UiCoordinateShipment.key = 'UI_CoordinateShipment1';
        this.mergeSections.add(UiCoordinateShipment);
        
        UiObtainInsuranceAuth = new SCM_MergeSection();        
        UiObtainInsuranceAuth.key = 'UI_ObtainInsuranceAuthorization';
        this.mergeSections.add(UiObtainInsuranceAuth);
        
        UiOneOffSP = new SCM_MergeSection();        
        UiOneOffSP.key = 'UI_OneOffSP';
        this.mergeSections.add(UiOneOffSP);
         
        //comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
    
    public override void getLatestValues()
    {
        UiInsuranceInfo.visible = UiInsuranceInfoChk.checked;
        UiCoordinateShipment.visible = UiCoordinateShipmentChk.checked;
        UiObtainInsuranceAuth.visible = UiObtainInsuranceAuthChk.checked;
        UiOneOffSP.visible = UiOneOffSPChk.checked;
    }
}