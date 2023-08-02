/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : RA-CMGT-FAX-53_GATCF_Rx_Prefill.doc
    // PRODUCT GROUP     : Rheumatology / Rituxan RA
    // Type              : System Document
    // Word Template     : Rx_Prefill_RA.doc    
    // Label in SF       : Rx Prefill 
    
/********************************************************************/


public class SCM_MD_Rx_Prefill_RA extends SCM_MergeDocument
{
      private String caseRecordType;
      public SCM_MD_Rx_Prefill_RA(String caseID, String argLookupId)
      {
            super(caseID, argLookupId);
            caseId = caseID;
      }
      
       public override void createMergeFields()  
      {
        //Case ID(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //Patient ID(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //GATCF_Fax(GATCF_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        // GATCF_Phone(GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //Patient full name (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Patient DOB(Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
        
        //Physician Full Name (Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //PhysicianStAddress (PhysicianStreetAddrs)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //PhysicianCityStateZip (PhyCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //PhysContactPh(PhysContactPh)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
        
        //PhysicianDEA(Physician DEA)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianDEA(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //Case worker(caseworker) (Key From)
       // this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
      
         
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordType.equalsIgnoreCase('C&R - Standard Case')) {
         
         this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
          
          
        }        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) {
                        
          this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
      
        }
       
       
              
                
      }
}