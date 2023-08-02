/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : RAP-CMGT-Fax-54 Acknowlegement Letter.doc
    // PRODUCT GROUP     : DERMATOLOGY/RAPTIVA
    // Type              : System Document
    // Word Template     : Acknowlegement Letter Rap.doc    
    // Label in SF       : Acknowlegement Letter Raptiva 
  
/********************************************************************/

public class SCM_MD_AcknowledgementLetter_Rap extends SCM_MergeDocument 
{
    
 public SCM_MD_AcknowledgementLetter_Rap(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }
    
    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String phyId = selectedCase.Case_Treating_Physician_gne__c;
        String recordType = selectedCase.RecordType.Name;
        
        //1. Case Number
        mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //2. GATCF_Phone 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));   

        //3. GATCF_Fax 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));   

        //4. DateLong key = DateLong
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
               
        //5.PhysianFirstLastName key = Physician First Last Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(phyId));

        //6. Physician Title key = PhysicianTitle
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(phyId));

        //7. PhysicianContactFullName key = PhysContactFullName
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase));                
       
        //8. Physician Street Address key = Physician Street Address
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
      
        //9. Physician City State Zip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
     
        //10. PhysContactFax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(Selectedcase));
               
        //11. Patient name
        this.mergeRecipientInfo.add(new SCM_MF_PatientFirstAndLastName(selectedCase));
  
        //12.SCM_MF_GATCFDisclaimer ,'GATCF Disclaimer'
        this.mergeRecipientInfo.add(new SCM_MF_GATCFDisclaimer());

        //13.SCM_MF_Product_ScientificName(selectedCase),'ProdScientific'
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
       
        //14. Case Worker - key From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
 
        //15.Product
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        //16.Product Scientific
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(Selectedcase));
       }
}