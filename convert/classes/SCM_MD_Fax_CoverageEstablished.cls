public class SCM_MD_Fax_CoverageEstablished extends SCM_MergeDocument implements IStandardComboBox  {
    private SCM_MergeSection LUCJCode;
    private SCM_MF_Product_Name product;
    
    public SCM_MD_Fax_CoverageEstablished(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
    }
        
    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String recordType = selectedCase.RecordType.Name;
   
        //Logo
        this.mergeimages.add(new SCM_MI_Logo(selectedCase));
        
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient ID
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_PhoneShort
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    
        //CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        //Product
        product = new SCM_MF_Product_Name(selectedCase);
        this.mergeRecipientInfo.add(product);
        
        //Drug
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //ProdSceintific
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
        
        //Patient name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
        
        //Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //Attn
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));

        //Recname
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));       
        
        //Recfax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));        
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
    
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
                
        //Dispensing Center
        this.mergeRecipientInfo.add(new SCM_MF_DispensingCenter(selectedCase.Id));
        
        //Benefit Type
        this.mergeRecipientInfo.add(new SCM_MF_BI_Benefit_Type(patientId));

        //---------------Second screen-----------------
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Form Information'; 
        formInformation.key = 'Form Information';
        
        SCM_MergeFieldCheckbox Checkbox1 = new SCM_MergeFieldCheckbox('UI_BIAttached','A copy of the benefit investigation is attached');       
        Checkbox1.fieldValue = '\r\nA copy of the benefit investigation is attached.';
        Checkbox1.totalWidth = '900';
        formInformation.subFields.add(Checkbox1);
                 
        SCM_MergeFieldCheckbox Checkbox2 = 
                new SCM_MergeFieldCheckbox('UI_CoorWithDist','Access Solutions is coordinating the first next shipment with the distributor');
        Checkbox2.fieldValue = '\r\nAccess Solutions is coordinating the first next shipment with the distributor.';
        Checkbox2.totalWidth = '900';        
        formInformation.subFields.add(Checkbox2);    
                                     
        this.mergeFields.add(formInformation);
        this.mergeFields.add(new SCM_MF_Comments());
       
        LUCJCode = new SCM_MergeSection();
        LUCJCode.key = 'LUCJCode';
        LUCJCode.visible = false;
        this.mergeSections.add(LUCJCode);
    }

    
    public override void getLatestValues() {
        if (product.fieldValue.equals('Lucentis')) {
            LUCJCode.visible = true;
        }
    }
}