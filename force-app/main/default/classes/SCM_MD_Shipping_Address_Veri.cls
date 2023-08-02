//Modified by Sridhar
 public class SCM_MD_Shipping_Address_Veri extends SCM_MergeDocument
 {
     
    
    public SCM_MD_Shipping_Address_Veri(String caseId,String argLookupId)
    {       
        super(caseId,argLookupId);
        
    }            
    
    public override void createMergeFields()
    {
        //1. CaseID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));     

        //2.GATCF Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //3.GATCF Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        //4.PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //5.PatientStAddress1
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine1(selectedCase.Patient_gne__r.Id));    
        //5.PatientStAddress2
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine2(selectedCase.Patient_gne__r.Id));    
        
        //6.PatientCity
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.City(selectedCase.Patient_gne__r.Id) );
        //6.PatientState
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.State(selectedCase.Patient_gne__r.Id) );
        //6.PatientZip
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.Zip(selectedCase.Patient_gne__r.Id) );
        
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
        
                             
    }   

}