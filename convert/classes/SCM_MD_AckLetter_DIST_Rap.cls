/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : RAP - CMGT-FAX-41B Acknowledgement Letter (DIST) final.doc
    // Type              : SYSTEM DOCUMENT
    // Word Template     : Ack_Letter_Dist_Rap.doc     
    // Label in SF       : Acknowledgement Letter(DIST)
    
/********************************************************************/
public class SCM_MD_AckLetter_DIST_Rap extends SCM_MergeDocument {
    protected String caseId;
    
    public SCM_MD_AckLetter_DIST_Rap(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
        public override void createMergeFields() {
            
            // Case Number
            this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
            
            //Date Long
            this.mergeRecipientInfo.add(new SCM_MF_DateLong());
            
            // ReferralOffice
            this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralOffice(selectedCase));
            
            // ReferralAttn
            this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralAttn(selectedCase));
            
            // ReferralStAddress
            this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralStAddress(selectedCase));
            
            // ReferralSuiteF1Unit
            this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralSuiteFlUnit(selectedCase));
            
            // ReferralCityStateZip
            this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralCityStateZip(selectedCase));
            
            //Referral ACKN Phone
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralPhone(Selectedcase));
		
		//Referral ACKN Fax
		this.mergeRecipientInfo.add(SCM_MF_ReferralACK_Factory.ReferralFax(Selectedcase));
            // PatientFullName 
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
            
            // PatientFirstName 
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(selectedCase.Patient_gne__r.Id));
            
            // DispencingCenter
            this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.Id));
            
            // DistributorContactPhone
            this.mergeRecipientInfo.add( new SCM_MF_FulFillmentPhone(selectedCase.id));
       
            // CR_Phone
            this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
       
            // CR_URL
            this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
            
            // CaseWorker
           // this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
            //CaseWorker
            String recordType = selectedCase.RecordType.Name;
            if (recordType.startsWith('C&R')) {
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            }
            else if (recordType.startsWith('GATCF')) {
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            }
    } 
}