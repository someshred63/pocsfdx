/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : 
    // PRODUCT GROUP     : BIOONCOLOGY - CMGT-FAX-52
    // Type              : System Document
    // Word Template     : CMGT_FAX-52_GATCF_Denial_Form_BIOONCOLOGY
   
/********************************************************************/    
public class SCM_MD_GATCF_Denial_Form_BIOONCOLOGY extends SCM_MergeDocument
{
  
   public SCM_MD_GATCF_Denial_Form_BIOONCOLOGY(String caseId, String argLookupId)
   {
    super(caseId, argLookupId);
   }

   public override void createMergeFields() 
   {
       String patId = selectedCase.Patient_gne__r.Id;
       String recordType = selectedCase.RecordType.Name;
       
       //1. Case Number (CaseID)
       this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 

       //DateShort(Current_Date)
       this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
    
       //GATCF_Phone(GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
    
        //GATCF_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
    
        //Product(Product)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
    
    
        //AgeBasedFullName
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patId));
    
        //AgeBasedStAddress
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patId));
        
        //AgeBasedCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patId));
    
        //PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patId));

        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
             
        //FoundationSpecialist(Foundation_Spl_Name)
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
   }
}