public class SCM_MD_GATCF_APPROVAL_Form  extends SCM_MergeDocument{
 
  public SCM_MD_GATCF_APPROVAL_Form(String caseID, String argLookupId)
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
     
        this.mergeRecipientInfo.add(new SCM_MF_PurNum(selectedCase.Id));
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedcase));
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedcase));
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedcase));
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugType(selectedcase));
        
        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));        
        
        // Document Number 
        this.mergeRecipientInfo.add(new SCM_MF_DocandPurNum(selectedCase.Id));
        
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