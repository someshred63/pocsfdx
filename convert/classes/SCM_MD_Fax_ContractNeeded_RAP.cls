/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : RAP-CMGT-FAX-27 Contract Needed for Raptiva.doc
    // Type              : Fax Coversheet
    // Word Template     : Contract_Needed_For_Raptiva.doc   
    // Label in SF       : Contract Needed For Raptiva
    
/********************************************************************/

public class SCM_MD_Fax_ContractNeeded_RAP extends SCM_MergeDocument implements IStandardComboBox {
    protected String caseId;
    public SCM_MD_Fax_ContractNeeded_RAP(String caseId, String argLookupId) {
        super(caseID, argLookupId);
        caseId = caseID;
    }  
    
    public override void createMergeFields() {
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String caseRecordType = selectedCase.RecordType.Name;
        String patientNumber = selectedCase.patient_gne__r.id;
        
        //0. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //1. Addressed To (RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //2. Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
        //3. From
       // this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        
        //4. Extension        
       // this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        
           // From and EXt
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
        
        
        //5. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //6. Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //7. RAP_CR_Phone
        //this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
      
        //8. RAP_CR_FAX
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //9. RAP_CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //10. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11. Physician Full Name ('Physician First Last Name')
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        //12. PatientFullName('Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientNumber));
        
        //13. Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientNumber));
        
        //InsuranceName('InsuranceNameSMN' + rank)
        //this.mergeRecipientInfo.add(SCM_MF_InsuranceFactory.InsuranceNameSMN(selectedCase.Id, 'Primary'));
        //InsurancePhone('InsurancePhoneSMN' + rank)
        //this.mergeRecipientInfo.add(SCM_MF_InsuranceFactory.InsurancePhoneSMN(selectedCase.Id, 'Primary'));
        //InsuranceSubscriberName
        //this.mergeRecipientInfo.add(SCM_MF_InsuranceFactory.SubscriberNameSMN(selectedCase.Id, 'Primary'));
        //InsuranceSubscriberGroupNum
        //this.mergeRecipientInfo.add(SCM_MF_InsuranceFactory.GroupNumSMN(selectedCase.Id, 'Primary'));
        //SubscriberID
        //this.mergeRecipientInfo.add(SCM_MF_InsuranceFactory.SubscriberIDSMN(selectedCase.Id, 'Primary'));
        
        //InsuranceName
        this.mergeRecipientInfo.add(new SCM_MF_InsuranceNameRankBill(selectedCase.Id));
        
        //InsurancePhone
        this.mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhone(selectedCase.Id));
         
        //InsuranceSubscriberName
        this.mergeRecipientInfo.add(new SCM_MF_InsSubNameRankBill(selectedCase.Id));
        
        //SubscriberID
        this.mergeRecipientInfo.add(new SCM_MF_InsSubscriberIDRankBill(selectedCase.Id));
        
        //InsuranceSubscriberGroupNum
        this.mergeRecipientInfo.add(new SCM_MF_InsSubGroup_NumRankBill(selectedCase.Id));
              
        // Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));     
        
        
        /////////-------Second Screen ------
        // Comments 
        this.mergeFields.add(new SCM_MF_Comments());     
      
    }
    
}