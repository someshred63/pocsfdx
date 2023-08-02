/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : LUC-CMGT-FAX-63 GATCF Approval Spanish Form.doc
    // Type              : System Document
    // Word Template     : GATCF_Approval_Spanish_Letter_Luc.doc 
    // Label in SF       : GATCF Approval Spanish Letter
    
/********************************************************************/

public class SCM_MD_GATCFApprovalSpanishLetter_Luc extends SCM_MergeDocument {

    protected String caseId;
    protected Patient_gne__c patient;
    protected string streetVal = '';
    protected string cityStateZipVal = '';
    
    public SCM_MD_GATCFApprovalSpanishLetter_Luc(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
     
    public override void createMergeFields() {
      
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
    string pid = selectedcase.patient_gne__r.Patient_ID_gne__c;
    
           //age based Name
           this.mergeRecipientInfo.add(new SCM_MF_AgeBasedFullName(pid));
            
           //age base street
            this.mergeRecipientInfo.add(new SCM_MF_AgeBasedStAddress(pid));
            //age based city state zip
            this.mergeRecipientInfo.add(new SCM_MF_AgeBasedCityStZip(pid));
        //Patient first and last name    
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(Selectedcase.patient_gne__c));
        
        // Case Number
     
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        // Patient Id
        
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // LUC_GATCF_Phone
        
        this.mergeRecipientInfo.add(new SCM_MF_product_phone(selectedcase));
        
        // LUC_GATCF_Fax
       
        this.mergeRecipientInfo.add(new SCM_MF_product_fax(selectedcase));
        
        // CaseWorker
          this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedcase));
        
        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));         
    
    }

}