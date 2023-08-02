/********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : Consolidated NUT-PUL CMGT-FAX-43 Form request Letter final
    // PRODUCT GROUP     : NUTROPIN AND PULMONARY/PULMOZYME
    // Type              : SYSTEM DOCUMENT(C&R STANDARD, C&R CONTINUOUS CARE, GATCF)
    // Word Template     : NUT_PUL_CMGT_FAX_43
    // Label in SF       : Form request letter final
    
/********************************************************************/

public class SCM_MD_NUT_PULCMGT_FAX43_ReqLetfinal extends SCM_MergeDocument 
{ 
	  public SCM_MD_NUT_PULCMGT_FAX43_ReqLetfinal(String caseID, String argLookupId)
	  {
	  		super(caseID, argLookupId);
            caseId = caseID;
	  }
	     
	    public override void createMergeFields()  
      {
	     //CR_Logo
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
   
	    //Case ID(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //Patient ID(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
              
        //CR_Phone(CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax(CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
              
        // Date (DateLong)
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        String patId = selectedCase.Patient_gne__r.Id;
        
        //AgeBasedFullName(AgeBasedFullName)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patId));
        
         //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
         
        //AgeBasedStAddress(AgeBasedStAddress)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patId));
        
        //AgeBasedCityStateZip(AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patId));
      
        //Patient full name (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Access solutions(AccessSolutions)
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c)); 
        
        /**         
        string caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || caseRecordType.equalsIgnoreCase('C&R - Standard Case'))
        {
         this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
           
        }        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case'))
        {
         this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
      
        }
             //this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
   
        */
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