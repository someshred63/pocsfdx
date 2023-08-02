/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : AVA-CMGT-FAX-66 APA Program Acknowledgement
    //					   Letter final.doc
    // PRODUCT GROUP     : ONCOLOGY/AVASTIN 
    // Type              : System Document
    // Word Template     : AVA-CMGT-FAX-66APAProgramAcknowledgement.doc    
    // Label in SF       : APA Program Acknowledge Form 
    
/********************************************************************/
public class SCM_MD_APAProgAcknowledgeForm_Ava extends SCM_MergeDocument {
          
    private String caseRecordType;        
    public SCM_MD_APAProgAcknowledgeForm_Ava(String caseID, String argLookupId) {
        super(caseID, argLookupId);        
    }
    
    public override void createMergeFields() {
    	// 0 Case Number
    	this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));   
    	     
        // 1 Patient Number
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        // 2 Fax_CR
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        // 3 Phone_CR
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        // 4 GATCF URL
        //key = GATCF_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));        
        // 5 Date        
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // 6 ReferralOffice         
        this.mergeRecipientInfo.add(new SCM_MF_ReferralOffice(selectedCase.Id));
        // 7 ReferralStAddress
        this.mergeRecipientInfo.add(new SCM_MF_ReferralStAddress(selectedCase));
        
        // 8 ReferralSuiteF1Unit
        this.mergeRecipientInfo.add(new SCM_MF_ReferralSuiteF1Unit(selectedCase));
        
        // 9 ReferralCityStateZip
        this.mergeRecipientInfo.add(new SCM_MF_ReferralCityStateZip(selectedCase.Referral_Address_Line_1_gne__r.Id, selectedCase));
      
        // 10 ReferralPhone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));  
        
        // 11 ReferralFax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));  
      
        // 12 Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
   
        // 13 CaseWorker
        //this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if (caseRecordType.startsWith('C&R')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (caseRecordType.startsWith('GATCF')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }                     
          /**  */
        // 14 ReferralAttn (Ticket#326)
        this.mergeRecipientInfo.add(new SCM_MF_ReferralAttn(selectedCase));
      
    }
}