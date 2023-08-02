/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : CMGT-FAX-70 - APA Program Denial Letter Form Analysis v2.0 - FINAL
    // Type              : System Document
    // Word Template     : APA_Program_Denial_Letter_Ava.doc
    // Label in SF       : APA Program Denial Letter
    
/********************************************************************/


public class SCM_MD_APAProgramDenialLetter_Ava extends SCM_MergeDocument
{
    public SCM_MD_APAProgramDenialLetter_Ava(String caseID, String argLookupId) 
    {
            super(caseID, argLookupId);
           
    }
        
    public override void createMergeFields() 
    {
        String phyId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        //Case Id
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
         
        //Date Short
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //CR_Phone()
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax   (CR_Fax)  
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //PhysicianFullName (key Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(phyId));
         
        //PhysicianTitle (key PhysicianTitle) 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(phyId));
        
        //PhysContactFullName (key PhysContactFullName)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase));
        
        //PhysContactPhone
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(Selectedcase));
        
        //PhysContactFax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(Selectedcase));
       
        //PhysicianStAddress (PhysicianStreetAddrs)
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
       
        //PhysicianCityStateZip  (PhyCityStateZip) 
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));   
  
        //PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
    	
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