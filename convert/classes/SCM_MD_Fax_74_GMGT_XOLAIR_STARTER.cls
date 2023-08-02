public class SCM_MD_Fax_74_GMGT_XOLAIR_STARTER extends SCM_MergeDocument {

    SCM_MergeField mf1;
    SCM_MergeField mf2;

    SCM_MergeField UI_MDOffice;
    SCM_MergeField UI_HOPD;
    SCM_MergeField UI_AIC;
    SCM_MergeField UI_InitialShipment;    
    SCM_MergeField UI_2ndShipment;
    SCM_MergeField UI_3rdShipment;

    public SCM_MD_Fax_74_GMGT_XOLAIR_STARTER(String caseID, String argLookupId) {
        super(caseID, argLookupId);
        
    }
    
    public override void createMergeFields() {
        // Case Number (CaseID)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        // Adding this getting the details in the metadata
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_PhoneShort
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    
        //CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 

        // Access Solution
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));

        // Attn:
        SCM_MergeField ATTN_Attn = SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id);
        ATTN_Attn.fieldValue = 'Xolair Starter Pharmacy';
        this.mergeRecipientInfo.add(ATTN_Attn);
        
        // To RECNAME_To:
        SCM_MergeField RECNAME = SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id);
        RECNAME.fieldValue = 'RxCrossroads';
        this.mergeRecipientInfo.add(RECNAME);
        
        // Fax RECFAX_Fax
        SCM_MergeField RECFAX_Fax = SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id);
        RECFAX_Fax.fieldValue = '(866)300-6426';
        this.mergeRecipientInfo.add(RECFAX_Fax);

        // Custom ATTN_Attn
        //SCM_MergeField ATTN_Attn= new SCM_MergeField();
        //ATTN_Attn.key = 'ATTN_Attn';
        //ATTN_Attn.displayLabel = true;
        //ATTN_Attn.label = 'Attn: ';
        //ATTN_Attn.displayTextbox = true;
        //ATTN_Attn.displayCheck = false;
        //ATTN_Attn.fieldValue = 'Xolair Starter Pharmacy';
        //this.mergeRecipientInfo.add(ATTN_Attn);
        
        // Custom RECNAME
        //SCM_MergeField RECNAME = new SCM_MergeField();
        //RECNAME.key = 'RECNAME';
        //RECNAME.displayLabel = true;
        //RECNAME.label = 'To: ';
        //RECNAME.displayTextbox = true;
        //RECNAME.displayCheck = false;
        //RECNAME.fieldValue = 'RxCrossroads';
        //this.mergeRecipientInfo.add(RECNAME);
        
        // Custom RECFAX_Fax
        //SCM_MergeField RECFAX_Fax = new SCM_MergeField();
        //RECFAX_Fax.key = 'RECFAX_Fax';
        //RECFAX_Fax.displayLabel = true;
        //RECFAX_Fax.label = 'Fax: ';
        //RECFAX_Fax.displayTextbox = true;
        //RECFAX_Fax.displayCheck = false;
        //RECFAX_Fax.fieldValue = '(866)300-6426';
        //this.mergeRecipientInfo.add(RECFAX_Fax);
        
        // From 
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, selectedCase.RecordType.Name));
        
        // Extension        
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, selectedCase.RecordType.Name)); 

        //Patient name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.Id));
        
        //Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.Id));

        // Patient AddressCityStateZip
        this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(selectedCase.patient_gne__r.Id));

        // Patient PrimeConFullName
        this.mergeRecipientInfo.add(new SCM_MF_PatientPrimeConFullName(selectedCase.patient_gne__r.Id));

        //SCM_MF_PatientRelationship
        this.mergeRecipientInfo.add(new SCM_MF_PatientRelationship2(selectedCase.patient_gne__r.Id));
        
        // PatientPrimeConHmPh
        this.mergeRecipientInfo.add(new SCM_MF_PatientPrimeConHmPh2(selectedCase.patient_gne__r.Id));

        // Patient_Work_Phone
        this.mergeRecipientInfo.add(new SCM_MF_PatientPrimeConWkPh2(selectedCase.patient_gne__r.Id));

        //---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Service Requested'; 
        formInformation.key = 'Service Requested';

        mf1 = new SCM_MergeField();
        mf1.displayRadio = true;
        mf1.displayLabel = false;
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.IsRequired = false;
        mf1.fieldValue = '';
        mf1.isFormField = false;

        mf1.selectionItems.add(new SelectOption('Initial Shipment','Initial Shipment'));
        mf1.selectionItems.add(new SelectOption('2nd Shipment','2nd Shipment'));
        mf1.selectionItems.add(new SelectOption('3rd Shipment','3rd Shipment'));
        mf1.selectionItems.add(new SelectOption(' ','None'));
        
        // Set default radio button
        mf1.fieldValue= 'Initial Shipment';
        mf1.setKey('SelectedShipment');
        
        formInformation.subfields.add(mf1);
        
        this.mergeFields.add(formInformation);

        // PhysicianFirstLastName
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));

        // PhysicianFullAddress
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianFullAddress(selectedCase));
        
        // PhysicianOfficePhone
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficePhone(selectedCase));
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianPhone(selectedCase.Case_Treating_Physician_gne__r.Id));

        // PhysicianOfficeFax
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficeFax(selectedCase));
        //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax2(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // PhysicianContactFullName
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase));

        // PhysicianContactPhone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));

        // PhysicianContactFax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));

        SCM_MergeFieldGroup formInformation2 = new SCM_MergeFieldGroup();
        formInformation2.headerText = 'Ship To'; 
        formInformation2.key = 'Ship To';

        mf2 = new SCM_MergeField();
        mf2.displayRadio = true;
        mf2.displayLabel = false;
        mf2.displayCheck = false;
        mf2.displayTextbox = false;
        mf2.IsRequired = false;
        //mf2.totalWidth = '250';
        mf2.fieldValue = '';
        mf2.isFormField = false;
        mf2.selectionItems.add(new SelectOption('MD Office','MD Office' ));
        mf2.selectionItems.add(new SelectOption('HOPD','HOPD' ));
        mf2.selectionItems.add(new SelectOption('AIC','AIC' ));
        
        // Set default radio button
        mf2.fieldValue  = 'MD Office';
        mf2.setKey('SelectedShipTo');
        
        formInformation2.subfields.add(mf2);

        this.mergeFields.add(formInformation2);

        // FacilityName
        //this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));

        // FacilityAddress
        //this.mergeRecipientInfo.add(new SCM_MF_FacilityAddress(selectedCase));

        // FacilityContactName
        //this.mergeRecipientInfo.add(new SCM_MF_FacilityContact(selectedCase));

        // FacilityPhone
        //this.mergeRecipientInfo.add(new SCM_MF_FacilityPhone(selectedCase));
        
        // FacilityFax
        //this.mergeRecipientInfo.add(new SCM_MF_FacilityFax(selectedCase));

        SCM_MergeFieldGroup formInformation3 = new SCM_MergeFieldGroup();
        formInformation3.headerText = 'Facility Information'; 
        formInformation3.key = 'Facility Information';

        // Custom FacilityName
        SCM_MergeField FacilityName= new SCM_MergeField();
        FacilityName.key = 'FacilityName';
        FacilityName.displayLabel = true;
        FacilityName.label = 'Facility Name: ';
        FacilityName.displayTextbox = true;
        FacilityName.displayCheck = false;
        FacilityName.fieldValue = '';
        FacilityName.isRequired = false;
        formInformation3.subfields.add(FacilityName);
        
        // Custom FacilityAddress
        SCM_MergeField FacilityAddress= new SCM_MergeField();
        FacilityAddress.key = 'FacilityAddress';
        FacilityAddress.displayLabel = true;
        FacilityAddress.label = 'Facility Address: ';
        FacilityAddress.displayTextbox = true;
        FacilityAddress.displayCheck = false;
        FacilityAddress.fieldValue = '';
        FacilityAddress.isRequired = false;
        formInformation3.subfields.add(FacilityAddress);
        
        // Custom FacilityContact
        SCM_MergeField FacilityContact= new SCM_MergeField();
        FacilityContact.key = 'FacilityContact';
        FacilityContact.displayLabel = true;
        FacilityContact.label = 'Facility Contact: ';
        FacilityContact.displayTextbox = true;
        FacilityContact.displayCheck = false;
        FacilityContact.fieldValue = '';
        FacilityContact.isRequired = false;
        formInformation3.subfields.add(FacilityContact);
        
        // Custom FacilityPhone
        SCM_MergeField FacilityPhone= new SCM_MergeField();
        FacilityPhone.key = 'FacilityPhone';
        FacilityPhone.displayLabel = true;
        FacilityPhone.label = 'Phone: ';
        FacilityPhone.displayTextbox = true;
        FacilityPhone.displayCheck = false;
        FacilityPhone.fieldValue = '';
        FacilityPhone.isRequired = false;
        FacilityPhone.setFieldType(SCM_MergeField.FieldTypes.phoneNumberField);
        formInformation3.subfields.add(FacilityPhone);
        
        // Custom FacilityFax
        SCM_MergeField FacilityFax = new SCM_MergeField();
        FacilityFax.key = 'FacilityFax';
        FacilityFax.displayLabel = true;
        FacilityFax.label = 'Fax: ';
        FacilityFax.displayTextbox = true;
        FacilityFax.displayCheck = false;
        FacilityFax.fieldValue = '';
        FacilityFax.isRequired = false;
        FacilityFax.setFieldType(SCM_MergeField.FieldTypes.phoneNumberField);
        formInformation3.subfields.add(FacilityFax);

        this.mergeFields.add(formInformation3);

        //Comments
        this.mergeFields.add(new SCM_MF_Comments());
        
        //Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));


        //MD Office
        UI_MDOffice = new SCM_MergeField();
        UI_MDOffice.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_MDOffice.key = 'UI_MDOffice';
        UI_MDOffice.displayLabel = false;
        UI_MDOffice.displayTextbox = false;
        UI_MDOffice.displayCheck = false;
        mergeRecipientInfo.add(UI_MDOffice);

        //MD Office
        UI_HOPD= new SCM_MergeField();
        UI_HOPD.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_HOPD.displayLabel = false;
        UI_HOPD.displayTextbox = false;
        UI_HOPD.displayCheck = false;
        UI_HOPD.key = 'UI_HOPD';
        mergeRecipientInfo.add(UI_HOPD);
        
        //UI_AIC
        UI_AIC= new SCM_MergeField();
        UI_AIC.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_AIC.key = 'UI_AIC';
        UI_AIC.displayLabel = false;
        UI_AIC.displayTextbox = false;
        UI_AIC.displayCheck = false;
        mergeRecipientInfo.add(UI_AIC);
        
        //MD Office
        UI_InitialShipment= new SCM_MergeField();
        UI_InitialShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_InitialShipment.key = 'UI_InitialShipment';
        UI_InitialShipment.displayLabel = false;
        UI_InitialShipment.displayTextbox = false;
        UI_InitialShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_InitialShipment);
        
        //MD Office
        UI_2ndShipment= new SCM_MergeField();
        UI_2ndShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_2ndShipment.key = 'UI_2ndShipment';
        UI_2ndShipment.displayLabel = false;
        UI_2ndShipment.displayTextbox = false;
        UI_2ndShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_2ndShipment);
        
        //MD Office
        UI_3rdShipment= new SCM_MergeField();
        UI_3rdShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_3rdShipment.key = 'UI_3rdShipment';
        UI_3rdShipment.displayLabel = false;
        UI_3rdShipment.displayTextbox = false;
        UI_3rdShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_3rdShipment);

    }
    
     public override void getLatestValues()
      {
              if(mf1.getMergeValue().contains('Initial Shipment'))
              {
                  UI_InitialShipment.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
              if(mf1.getMergeValue().contains('2nd Shipment'))
              {
                  UI_2ndShipment.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
              if(mf1.getMergeValue().contains('3rd Shipment'))
              {
                  UI_3rdShipment.mergeValue = SCM_CheckBox_Values.Checked;
              } 
              
              if(mf2.getMergeValue().contains('MD Office'))
              {
                  UI_MDOffice.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
              if(mf2.getMergeValue().contains('HOPD'))
              {
                  UI_HOPD.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
              if(mf2.getMergeValue().contains('AIC'))
              {
                  UI_AIC.mergeValue = SCM_CheckBox_Values.Checked;
              } 
      }

}