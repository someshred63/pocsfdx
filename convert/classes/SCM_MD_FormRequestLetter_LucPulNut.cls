/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : CMGT-FAX-43 - Form Request Letter Form Analysis v1.1-FINAL.Doc
    // Type              : System Document
    // Word Template     : FormRequestLetterForm_Lucentis.doc    
    // Label in SF       : Form Request Letter Form
    
/********************************************************************/
public class SCM_MD_FormRequestLetter_LucPulNut extends SCM_MergeDocument {
    
    public SCM_MD_FormRequestLetter_LucPulNut(String caseID,String argLookupID) {
        super(caseID, argLookupID);          
    } 
 
    public override void createMergeFields() {
        Integer patientContactcount = 0;
        string patientid = selectedCase.patient_gne__r.Patient_id_gne__c;
                 
        //0 Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
     
        //1 Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //2 CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //3 CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //4 system Current Date
        
         //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
                       
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        
        
            //5. Patient First and last Name               
            this.mergeRecipientInfo.add(new SCM_MF_AgeBasedFullName(patientId));
            
            
            // 6.Patient Address 
            this.mergeRecipientInfo.add(new SCM_MF_AgeBasedStAddress(patientId));
            
            //7.Patient CityStateZip
             this.mergeRecipientInfo.add(new SCM_MF_AgeBasedCityStZip(patientId));
            
            // 8.Addressed To
            
            this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedcase.Patient_gne__r.Id) );
            
        
        
        
        //9. RE field               
       //we dont need to repeat this field   
        
        
        
        //10. Case Manager Name (Field Mame: CASE_MGR)

        this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));   
        
        //11 CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        
        
        
    }   
}