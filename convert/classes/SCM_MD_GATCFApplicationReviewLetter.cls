/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : LUC-CMGT-FAX-60 GATCF Application Review Letter.doc
    // Type              : System Document
    // Word Template     : GATCFApplicationReviewLetterForm_LUCENTIS.doc    
    // Label in SF       : GATCF Application Review Letter Form
    
/********************************************************************/

public class SCM_MD_GATCFApplicationReviewLetter extends SCM_MergeDocument 
{
   
    public SCM_MD_GATCFApplicationReviewLetter(String caseID,String argLookupID) 
    {
        super(caseID, argLookupID);          
    } 
    
    public override void createMergeFields() 
    {
        
        // 0 Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // 1 Case Number
         this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));        
        
        //2 GATCF_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //3 GATCF_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
              
       // CR Fax (key CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //4 Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());   
       
        //5 Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //6 Physician Street Address 
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
         
       //7 Physician City Zip State Address
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianCityStateZip(selectedcase.Case_Treating_Physician_gne__c));
        
       // patient full name
       this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
       
        // Drug
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
 
         //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));       
        
        this.mergeRecipientInfo.add(new SCM_MF_XolairPlus(SelectedCase.Product_gne__c));
        //ProdScientific
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
         this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
           this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));    
         
       //Case Worker
         if(selectedCase.RecordType.Name != null)
        {
            if(selectedCase.RecordType.Name 
            == 'C&R - Continuous Care Case' || selectedCase.RecordType.Name == 'C&R - Standard Case')
            {   // key'From'
                this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            }
            if(selectedCase.RecordType.Name == 'GATCF - Standard Case')
            {  // key'From'
               this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            }
        }
        
       
           
    }
}