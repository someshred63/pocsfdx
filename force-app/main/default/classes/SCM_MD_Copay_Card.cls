public class SCM_MD_Copay_Card extends SCM_MD_Standard {
public SCM_MD_Copay_Card(String caseID, String argLookupId) {
        super(caseID, argLookupId);
        
    }
    
    public override void createMergeFields() {
    	 
    	 // Attn:
        SCM_MergeField ATTN_Attn = SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id);
        ATTN_Attn.fieldValue = 'Co-pay Card Referral';
        this.mergeRecipientInfo.add(ATTN_Attn);
          
        // Fax RECFAX_Fax
        SCM_MergeField RECFAX_Fax = SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id);
        RECFAX_Fax.fieldValue = '877-776-0522';
        this.mergeRecipientInfo.add(RECFAX_Fax);
         // AccessSolutions
        SCM_MergeField mfaa = new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c);
        mfaa.key = 'AccessSolutionsUpper';
        mfaa.fieldValue = mfaa.fieldValue.toUpperCase().replace('GENENTECH','');
        this.mergeRecipientInfo.add(mfaa);
        //logo
        this.mergeImages.add(new SCM_MI_Logo(selectedCase));
        //Patient Gender
        this.mergeFields.add(SCM_MF_PatientFieldFactory.PatientGender(selectedCase.patient_gne__r.Id));
        //Patient Home ph
        this.mergeFields.add(SCM_MF_PatientFieldFactory.PatientHomePhone(selectedCase.patient_gne__r.Id));
         //Patient work ph
        this.mergeFields.add(SCM_MF_PatientFieldFactory.PatientWorkPhone(selectedCase.patient_gne__r.Id));
         //PatientCellPhone
        this.mergeFields.add(SCM_MF_PatientFieldFactory.PatientCellPhone(selectedCase.patient_gne__r.Id));
        //SCM_MF_PrimaryICD9Code
        this.mergeFields.add(new SCM_MF_PrimaryICD9Code(selectedcase.Id));
         
        //insurance name
        this.mergeFields.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase,'1'));
        //insurance GroupNumSMN
        this.mergeFields.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase,'1'));
        //insurance GroupNumSMN
        this.mergeFields.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase,'1'));
        //insurance InsurancePhoneSMN
        this.mergeFields.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase,'1'));
        //Dispensing Center	
        this.mergeFields.add(SCM_MF_Fulfillment_Factory.DispensingCenter(SelectedCase.ID));
         //co pay card	
        this.mergeFields.add(new SCM_MF_CopayCardID(SelectedCase.ID));
        // Additional Support's Benefit Level
        this.mergeFields.add(new SCM_MF_AdditionalSupport_BenefitLevel(SelectedCase.ID));
          //enroll smn date
        this.mergeFields.add(new SCM_MF_Enroll_SMNReceived(SelectedCase));
		//14 Patient State(PatientState)
        this.mergeRecipientInfo.add(new SCM_MF_Patient_State(selectedCase.Patient_gne__r.Patient_Id_gne__c));
        
        this.mergeRecipientInfo.add(new SCM_MF_Patient_Zip(selectedCase.Patient_gne__r.Patient_Id_gne__c));
        this.mergeFields.add(SCM_MF_PatientAddressFactory.Zip(selectedCase.patient_gne__r.Id));
        
        this.mergeFields.add(SCM_MF_PatientAddressFactory.City(selectedCase.patient_gne__r.Id));
        
        this.mergeFields.add(SCM_MF_PatientAddressFactory.PatientAddressLine1(selectedCase.patient_gne__r.Id));
this.mergeFields.add(SCM_MF_PatientAddressFactory.PatientAddressLine2(selectedCase.patient_gne__r.Id));
         
        this.mergeFields.add(new SCM_MF_PatientMailbox(selectedCase.patient_gne__r.Id));
        
        this.mergeFields.add(new SCM_MF_FacilityORPracticeName(selectedCase));
        
        this.mergeFields.add(SCM_MF_Physician_FieldFactory.PhysicianFirstName(SelectedCase.Case_Treating_Physician_gne__c));
        this.mergeFields.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(SelectedCase.Case_Treating_Physician_gne__c));
        super.createMergeFields();
    	 //Fix case worker field
    	 SCM_MergeField caseworker = this.GetMF(this.mergeRecipientInfo,'caseworker');
    	caseworker.displayField = false;
    	 caseworker.displayLabel = false;
    	 caseworker.displayTextBox = false;
    }
    private SCM_MergeField GetMF(List<SCM_MergeField> mfs, string key)
    {
    	for(SCM_MergeField mf:mfs){
    		if (mf.key == key){
    			return mf;	
    		}
    		
    	}	
    return null;
    }
    
}