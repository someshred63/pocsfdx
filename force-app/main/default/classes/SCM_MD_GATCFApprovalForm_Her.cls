/********************************************************************/
    // Developer Name    : Vishwanath 
    // Document Name     : 51 – HER - GATCF Approval Form
    // PRODUCT GROUP     : Oncology / Herceptin
    // Type              : System Document
    // Word Template     : Final HER-CMGT-FAX-51 - GATCF Approval Form.doc
   
/********************************************************************/  
   

public class SCM_MD_GATCFApprovalForm_Her extends SCM_MergeDocument
{
     
    public SCM_MD_GATCFApprovalForm_Her(String caseID,String argLookupID) 
     {
        super(caseId, argLookupID);
     }   
 
    public override void createMergeFields() 
    {
        //1. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //2. Date Long
        SCM_MF_DateLong dateLong = new SCM_MF_DateLong();
        this.mergeRecipientInfo.add(dateLong);
        
        // Gatcf Fax SCM_MF_Product_Fax_GATCF
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
                
        // Gatcf Phone 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        // Purchase Number 
        this.mergeRecipientInfo.add(new SCM_MF_PurNum(selectedCase.Id));
        
        // Document Number 
        this.mergeRecipientInfo.add(new SCM_MF_DocandPurNum(selectedCase.Id));
        
        
        //Physician title  (PhysicianTitle)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(selectedCase.Case_Treating_Physician_gne__c));
         
        
        //Physician Full Name (RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.id));
        
        
        //Physician street address
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
         
        //Physician City/State/Zip
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianCityStateZip('',selectedCase.Address_gne__r.id)); 
       
        //Physician Fax (PhysContactFax)  
         this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(Selectedcase));
         
          
        //Patient Full Name
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
      
        //upp_approval_date
          this.mergeRecipientInfo.add(new SCM_MF_ApprovalDateUPP(selectedCase.Id));
          
        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
                 
         //foundationspecialist
          this.mergeRecipientInfo.add(new SCM_MF_FoundationSpecialist(selectedCase));
           
                             
    }
}