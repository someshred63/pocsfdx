/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : Consolidated CMGT-FAX-42 PAN Request final
    // Type              : System Document
    // Word Template     : CMGT-FAX-42 PAN Request.doc    
    // Label in SF       : PAN Request Consolidated
    
/********************************************************************/

public class SCM_MD_PANReqConsol_AvHeRiTaRaAcRa extends SCM_MergeDocument {
    
    public SCM_MD_PANReqConsol_AvHeRiTaRaAcRa(String caseID, String argLookupId) {
        super(caseID, argLookupId);        
    }
    public override void createMergeFields() {
        
        String patientId = selectedCase.Patient_gne__r.Id;
        String recordType = selectedCase.RecordType.Name;
        
        //  CR_Logo
        this.mergeimages.add(new SCM_MI_Logo(selectedCase));
            
        //Case ID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
                
        //CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));    
        
             
        //CR_PhoneShort
       	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
       
            
        //CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));        

        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));        
            
        //DateLong
        this.mergeRecipientInfo.add(new SCM_MF_DateLong()); 
                      
        //AgeBasedFullName(AgeBasedFullName)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patientId));
        
        //AgeBasedStAddress(AgeBasedStAddress) 
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patientId));
        
        //AgeBasedCityStateZip(AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patientId));
        
        //Patient Full Name(Patient_First_And_Last_Name)       
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));   
                 
        //Access Solutions
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        
        // Case Worker
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
    }
}