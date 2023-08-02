public class SCM_MD_BRAF_STARTER extends SCM_MergeDocument {

    SCM_MergeField mf1;
    SCM_MergeField mf2;

    SCM_MergeField UI_MDOffice;
    SCM_MergeField UI_PatientsAddress;
    SCM_MergeField UI_1stShipment;    
    SCM_MergeField UI_2ndShipment;
    SCM_MergeField UI_3rdShipment;
    SCM_MergeField UI_4thShipment;    
    SCM_MergeField UI_5thShipment;
    SCM_MergeField UI_6thShipment;
    SCM_MergeField UI_None;

    public SCM_MD_BRAF_STARTER(String caseID, String argLookupId) {
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
        ATTN_Attn.fieldValue = 'Zelboraf Starter Pharmacy';
        this.mergeRecipientInfo.add(ATTN_Attn);
        
        // To RECNAME_To:
        SCM_MergeField RECNAME = SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id);
        RECNAME.fieldValue = 'Biologics';
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

        mf1.selectionItems.add(new SelectOption('1st Shipment','1st Shipment'));
        mf1.selectionItems.add(new SelectOption('2nd Shipment','2nd Shipment'));
        mf1.selectionItems.add(new SelectOption('3rd Shipment','3rd Shipment'));
        mf1.selectionItems.add(new SelectOption('4th Shipment','4th Shipment'));
        mf1.selectionItems.add(new SelectOption('5th Shipment','5th Shipment'));
        mf1.selectionItems.add(new SelectOption('6th Shipment','6th Shipment'));
        mf1.selectionItems.add(new SelectOption('None','None'));
        
        // Set default radio button
        mf1.fieldValue= '1st Shipment';
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
        mf2.allowCache = false;
        //mf2.totalWidth = '250';

        mf2.isFormField = false;
        mf2.allowCache = false;
        mf2.selectionItems.add(new SelectOption('Patient\'s Address','Patient\'s Address' ));
        mf2.selectionItems.add(new SelectOption('MD Office','MD Office' ));
        
        // Set default radio button
        mf2.fieldValue  = 'Patient\'s Address';
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
        formInformation3.headerText = 'Shipment Information'; 
        formInformation3.key = 'Shipment Information';

        // Custom Patient Name
        SCM_MergeField PatientName= new SCM_MergeField();
        PatientName.key = 'UI_PatName';
        PatientName.displayLabel = true;
        PatientName.label = 'Patient Name: ';
        PatientName.displayTextbox = true;
        PatientName.displayCheck = false;
        PatientName.fieldValue = '';
        PatientName.isRequired = false;
        PatientName.CssClass = 'patient';
        formInformation3.subfields.add(PatientName);
        
        // Custom PatientAddress
        SCM_MergeField PatientAddress= new SCM_MergeField();
        PatientAddress.key = 'UI_PatAddress';
        PatientAddress.displayLabel = true;
        PatientAddress.label = 'Patient Address: ';
        PatientAddress.displayTextbox = true;
        PatientAddress.displayCheck = false;
        PatientAddress.fieldValue = '';
        PatientAddress.isRequired = false;
        PatientAddress.CssClass = 'patient';
        formInformation3.subfields.add(PatientAddress);
        
        // Custom PatientPhone
        SCM_MergeField PatientPhone= new SCM_MergeField();
        PatientPhone.key = 'UI_PatPhone';
        PatientPhone.displayLabel = true;
        PatientPhone.label = 'Patient Phone: ';
        PatientPhone.displayTextbox = true;
        PatientPhone.displayCheck = false;
        PatientPhone.fieldValue = '';
        PatientPhone.isRequired = false;
        PatientPhone.setFieldType(SCM_MergeField.FieldTypes.phoneNumberField);
        PatientPhone.CssClass = 'patient';
        formInformation3.subfields.add(PatientPhone);
        
        // Custom PatientPrimaryContact
        SCM_MergeField PatientPrimaryContact= new SCM_MergeField();
        PatientPrimaryContact.key = 'UI_PatPrimeContact';
        PatientPrimaryContact.displayLabel = true;
        PatientPrimaryContact.label = 'Patient Primary Contact: ';
        PatientPrimaryContact.displayTextbox = true;
        PatientPrimaryContact.displayCheck = false;
        PatientPrimaryContact.fieldValue = '';
        PatientPrimaryContact.isRequired = false;
        //PatientPrimaryContact.TotalWidth = '396';
        PatientPrimaryContact.width = '210';
        formInformation3.subfields.add(PatientPrimaryContact);
        
        // Custom PatientPrimaryContactPhone
        SCM_MergeField PatientPrimaryContactPhone= new SCM_MergeField();
        PatientPrimaryContactPhone.key = 'UI_PatPrimeContactPh';
        PatientPrimaryContactPhone.displayLabel = true;
        PatientPrimaryContactPhone.label = 'Patient Primary Contact Phone: ';
        PatientPrimaryContactPhone.displayTextbox = true;
        PatientPrimaryContactPhone.displayCheck = false;
        PatientPrimaryContactPhone.fieldValue = '';
        PatientPrimaryContactPhone.isRequired = false;
        PatientPrimaryContactPhone.setFieldType(SCM_MergeField.FieldTypes.phoneNumberField);
        //PatientPrimaryContactPhone.TotalWidth = '440';
        PatientPrimaryContactPhone.width = '180';
        formInformation3.subfields.add(PatientPrimaryContactPhone);

        // Custom FacilityName
        SCM_MergeField FacilityName= new SCM_MergeField();
        FacilityName.key = 'FacilityName';
        FacilityName.displayLabel = true;
        FacilityName.label = 'Facility Name: ';
        FacilityName.displayTextbox = true;
        FacilityName.displayCheck = false;
        FacilityName.fieldValue = '';
        FacilityName.isRequired = false;
        FacilityName.CssClass = 'facility';
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
        FacilityAddress.CssClass = 'facility';
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
        FacilityPhone.CssClass = 'facility';
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
        FacilityFax.CssClass = 'facility';
        FacilityFax.setFieldType(SCM_MergeField.FieldTypes.phoneNumberField);
        formInformation3.subfields.add(FacilityFax);

        //formInformation3.extraHTML = '<script type="text/javascript">jQuery("input[value=\'Patient\\\'s Address\']").click( function() { jQuery(".invalidField").removeClass("invalidField"); jQuery(".facility").removeClass("requiredField"); jQuery(".patient").addClass("requiredField"); }); jQuery("input[value=\'MD Office\']").click( function() { jQuery(".invalidField").removeClass("invalidField"); jQuery(".patient").removeClass("requiredField"); jQuery(".facility").addClass("requiredField"); });</script>';
        formInformation3.extraHTML = '<script type="text/javascript">jQuery("input[value=\'Patient\\\'s Address\']").click( function() { jQuery(".invalidField").removeClass("invalidField"); jQuery(".facility").removeClass("requiredField"); }); jQuery("input[value=\'MD Office\']").click( function() { jQuery(".invalidField").removeClass("invalidField"); jQuery(".patient").removeClass("requiredField"); jQuery(".facility").addClass("requiredField"); });</script>';

        formInformation3.displayExtraHTML = true;

        this.mergeFields.add(formInformation3);

        //Comments
        SCM_MergeField comments = new SCM_MF_Comments();
        //comments.extraHTML = '<script type="text/javascript">var orig_doSubmitTests = window.doSubmitTests; window.doSubmitTests=function(){orig_doSubmitTests(); if(jQuery("input[value=\'Patient\\\'s Address\']:checked").val()) { jQuery(".patient").addClass("requiredField"); }  if(jQuery("input[value=\'MD Office\']:checked").val()) { jQuery(".facility").addClass("requiredField"); } window.doSubmitTests = orig_doSubmitTests;}</script>';
        comments.extraHTML = '<script type="text/javascript">var orig_doSubmitTests = window.doSubmitTests; window.doSubmitTests=function(){orig_doSubmitTests(); if(jQuery("input[value=\'MD Office\']:checked").val()) { jQuery(".facility").addClass("requiredField"); } window.doSubmitTests = orig_doSubmitTests;}</script>';

        comments.displayExtraHTML = true;
        this.mergeFields.add(comments);
        
        //Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));


        //MD Office
        UI_MDOffice = new SCM_MergeField();
        UI_MDOffice.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_MDOffice.key = 'UI_ShipToMDO';
        UI_MDOffice.displayLabel = false;
        UI_MDOffice.displayTextbox = false;
        UI_MDOffice.displayCheck = false;
        mergeRecipientInfo.add(UI_MDOffice);      
        
        //Patient's Address
        UI_PatientsAddress= new SCM_MergeField();
        UI_PatientsAddress.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_PatientsAddress.key = 'UI_ShipToPatAdd';
        UI_PatientsAddress.displayLabel = false;
        UI_PatientsAddress.displayTextbox = false;
        UI_PatientsAddress.displayCheck = false;
        mergeRecipientInfo.add(UI_PatientsAddress);
        
        //1st Shipment
        UI_1stShipment= new SCM_MergeField();
        UI_1stShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_1stShipment.key = 'UI_Initial Shipment';
        UI_1stShipment.displayLabel = false;
        UI_1stShipment.displayTextbox = false;
        UI_1stShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_1stShipment);
        
        //2nd Shipment
        UI_2ndShipment= new SCM_MergeField();
        UI_2ndShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_2ndShipment.key = 'UI_2nd Shipment';
        UI_2ndShipment.displayLabel = false;
        UI_2ndShipment.displayTextbox = false;
        UI_2ndShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_2ndShipment);
        
        //3rd Shipment
        UI_3rdShipment= new SCM_MergeField();
        UI_3rdShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_3rdShipment.key = 'UI_3rd Shipment';
        UI_3rdShipment.displayLabel = false;
        UI_3rdShipment.displayTextbox = false;
        UI_3rdShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_3rdShipment);
        
        //4th Shipment
        UI_4thShipment= new SCM_MergeField();
        UI_4thShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_4thShipment.key = 'UI_4th Shipment';
        UI_4thShipment.displayLabel = false;
        UI_4thShipment.displayTextbox = false;
        UI_4thShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_4thShipment);

        //5th Shipment
        UI_5thShipment= new SCM_MergeField();
        UI_5thShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_5thShipment.key = 'UI_5th Shipment';
        UI_5thShipment.displayLabel = false;
        UI_5thShipment.displayTextbox = false;
        UI_5thShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_5thShipment);
        
        //6th Shipment
        UI_6thShipment= new SCM_MergeField();
        UI_6thShipment.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_6thShipment.key = 'UI_6th Shipment';
        UI_6thShipment.displayLabel = false;
        UI_6thShipment.displayTextbox = false;
        UI_6thShipment.displayCheck = false;
        mergeRecipientInfo.add(UI_6thShipment);
        
		//None
        UI_None= new SCM_MergeField();
        UI_None.fieldValue = SCM_CheckBox_Values.Unchecked;
        UI_None.key = 'UI_None';
        UI_None.displayLabel = false;
        UI_None.displayTextbox = false;
        UI_None.displayCheck = false;
        mergeRecipientInfo.add(UI_None);
    }
    
     public override void getLatestValues()
      {
              if(mf1.getMergeValue().contains('1st Shipment'))
              {
                  UI_1stShipment.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
              if(mf1.getMergeValue().contains('2nd Shipment'))
              {
                  UI_2ndShipment.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
              if(mf1.getMergeValue().contains('3rd Shipment'))
              {
                  UI_3rdShipment.mergeValue = SCM_CheckBox_Values.Checked;
              } 
              
              if(mf1.getMergeValue().contains('4th Shipment'))
              {
                  UI_4thShipment.mergeValue = SCM_CheckBox_Values.Checked;
              } 
              
              if(mf1.getMergeValue().contains('5th Shipment'))
              {
                  UI_5thShipment.mergeValue = SCM_CheckBox_Values.Checked;
              }

              if(mf1.getMergeValue().contains('6th Shipment'))
              {
                  UI_6thShipment.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
			  if(mf1.getMergeValue().contains('None'))
              {
                  UI_None.mergeValue = SCM_CheckBox_Values.Checked;
              }
              
              if(mf2.getMergeValue().contains('Patient\'s Address'))
              {
                  UI_PatientsAddress.mergeValue = SCM_CheckBox_Values.Checked;
              }
              	
              if(mf2.getMergeValue().contains('MD Office'))
              {
                  UI_MDOffice.mergeValue = SCM_CheckBox_Values.Checked;
              }
      }

}