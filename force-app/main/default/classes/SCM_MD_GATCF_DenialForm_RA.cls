/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : RA CMGT-FAX-52 - GATCF Denial Form
    // Type              : System Document
    // Word Template     : CMGT-FAX-52-GATCFDenialForm.doc    
    // Label in SF       : Denial Form 
    
/********************************************************************/
public class SCM_MD_GATCF_DenialForm_RA extends SCM_MergeDocument {
    
    public SCM_MD_GATCF_DenialForm_RA(String caseId, String argLookupId)
    {
       super(caseId,argLookupId);             
    }
    
    public override void createMergeFields()
    { 
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        string pid = selectedCase.Patient_gne__c;
        
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));   
        
        // 1 Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        
        // 2 CurrentDate(Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());        
            
        // 3 GATCF_Phone (GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
          
          this.mergeRecipientInfo.add(new SCM_MF_product_DrugName(selectedCase));
          this.mergeRecipientInfo.add(new SCM_MF_product_ScientificName(selectedCase));
        // 4 GATCF_Fax (GATCF_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        // 5 PhysicianStAddress(PhysicianStreetAddrs)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        // 6 PhysicianCityStateZip (PhyCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        // 7 PhysicianFullName(Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        // 8 Patient Full Name(Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        
        // 9 PhysicianTitle(PhysicianTitle)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(physicianId));
        
        // 10 PhysicianFax(PhysContactFax)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(SelectedCase));
         
        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
         
        // 11 CaseWorker
        String recordType = selectedCase.RecordType.Name;        
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
    }     
}