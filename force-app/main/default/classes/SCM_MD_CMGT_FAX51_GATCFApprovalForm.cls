/********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : RA upfront MD approval - CMGT-FAX-51 - GATCF Approval Form
    // PRODUCT GROUP     : Rituxan RA
    // Type              : System Document
    // Word Template     : CMGT_FAX_51_ GATCF_Approval Form.doc  
    // Label in SF       : CMGT_FAX_51_ GATCF_Approval Form
    
/********************************************************************/

public class SCM_MD_CMGT_FAX51_GATCFApprovalForm  extends SCM_MergeDocument{
 
  public SCM_MD_CMGT_FAX51_GATCFApprovalForm(String caseID, String argLookupId)
    {
            super(caseID, argLookupId);
            caseId = caseID;
    }
    
    public override void createMergeFields()  
    {
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        //1 Case ID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //2 Patient ID
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // Date (DateLong)
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //Fax (GATCF_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase)); 
        
        //Phone (GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase)); 
  
        //PhysicianStAddress (PhysicianStreetAddrs)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //PhysicianCityStateZip (Physician City State and Zip)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //7. Physician Full Name (Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //Patient full name (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //PhysicianTitle (PhysicianTitle)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //Physican fax (PhysContactFax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
 
         //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
                
          this.mergeRecipientInfo.add(new SCM_MF_product_DrugName(selectedCase));
          this.mergeRecipientInfo.add(new SCM_MF_product_ScientificName(selectedCase));
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