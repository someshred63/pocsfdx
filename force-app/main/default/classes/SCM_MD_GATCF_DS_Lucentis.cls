/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : LUC-CMGT-FAX-64 GATCF Denial Spanish Letter.doc
    // Type              : System Document
    // Word Template     : GATCF_Denial_Spanish_Letter_Luc.doc   
    // Label in SF       : GATCF Denial Spanish Letter
    
/********************************************************************/


public class SCM_MD_GATCF_DS_Lucentis extends SCM_MergeDocument {
  
    protected String caseId;
    protected Patient_gne__c patient;
    protected string streetVal = '';
    protected string cityStateZipVal = '';
    
    
    public SCM_MD_GATCF_DS_Lucentis(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
    
    public override void createMergeFields() {
       
          string pid = selectedcase.patient_gne__r.Patient_ID_gne__c;
            //name
            this.mergeRecipientInfo.add(new SCM_MF_AgeBasedFullName(pid));
            //street
            this.mergeRecipientInfo.add(new SCM_MF_AgeBasedStAddress(pid));
            //citySateZip
            this.mergeRecipientInfo.add(new SCM_MF_AgeBasedcityStZip(pid));
            
        
        
       
        //DateShort
        
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // PatientFullName
        this.mergeRecipientInfo.add(new SCM_MF_PatientFirstAndLastName(selectedCase));
        
        // Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        
        // LUC_GATCF_Phone
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone(selectedcase));
        
        // LUC_GATCF_Fax
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax(selectedcase));
         
        // CaseWorker
                    this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedcase));

        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));    
    }
       
    }