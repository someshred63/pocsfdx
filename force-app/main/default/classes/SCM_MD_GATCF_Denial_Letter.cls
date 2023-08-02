/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : LUC-CMGT-FAX-52 GATCF Denial Letter.doc
    // PRODUCT GROUP     : Opthalmology / Lucentis
    // Type              : System Document
    // Word Template     : GATCF_Denial_Form.doc    
    // Label in SF       : GATCF Denial Form
    
/********************************************************************/
public class SCM_MD_GATCF_Denial_Letter extends SCM_MergeDocument{

 public SCM_MD_GATCF_Denial_Letter(String caseId, String argLookupId) {
        super(caseId, argLookupId);
 }
 
  public override void createMergeFields() {
        String patId = selectedCase.Patient_gne__r.Id;
        String recordType = selectedCase.RecordType.Name;
                 
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient Id              
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));

        //Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
    
    this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
    
     this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
        //Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //AgeBasedFullName
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patId));
        
        //AgeBasedStAddress
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patId));
        
        //AgeBasedCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patId));

        //Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patId));

        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));

        //Case Worker
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
  }     
}