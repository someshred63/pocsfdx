public class SCM_MD_Fax_Wholesaler_Luc extends SCM_MergeDocument {
    public SCM_MD_Fax_Wholesaler_Luc(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    
    public override void createMergeFields() {
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
            
        //CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));

        //ATTN_Whole
        SCM_MF_OtherDocuments attn = new SCM_MF_OtherDocuments('ATTN_Whole', 'Attn:');
        attn.requireNewLineInTemplate = false;
        attn.fieldValue = 'Linda Thompson, Account Manager';
        attn.totalWidth = '350';
        attn.width = '230';
        attn.isRequired = true;
        this.mergeRecipientInfo.add(attn);
        
        //RECNAME_Whole
        SCM_MF_OtherDocuments addr = new SCM_MF_OtherDocuments('RECNAME_Whole', 'Addressed To:');
        addr.requireNewLineInTemplate = false;
        addr.fieldValue = 'Curascript';
        addr.totalWidth = '350';
        addr.width = '230';
        addr.isRequired = true;
        this.mergeRecipientInfo.add(addr);
        
        //RECFAX_Whole
        SCM_MF_OtherDocuments fax = new SCM_MF_OtherDocuments('RECFAX_Whole', 'Fax:');
        fax.requireNewLineInTemplate = false;
        fax.fieldValue = '(407) 804-3897';
        fax.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        fax.totalWidth = '350';
        fax.width = '230';
        fax.isRequired = true;
        this.mergeRecipientInfo.add(fax);
        
        //From and Extension   
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  

        //DateShort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
         
        //PhysicianFullName(Physician First And Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
     
        //DispensingCenter
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.Id));
        
        //DispensingContactPhone(Distributor_Contact_Phone)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingContactPhone(selectedCase.Id));
        
        //DispensingContactName(Distributor_Contact_Name)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingContactName(selectedCase.Id));
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());

        //ConfidNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
    
    }
}