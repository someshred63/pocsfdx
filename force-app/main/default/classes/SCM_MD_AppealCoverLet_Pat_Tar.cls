/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : 59B – Patient – Appeal Cover Letter
    // PRODUCT GROUP     : Tarceva
    // Type              : SystemDocument
    // Word Template     : CMGT-Fax-59B_AppCoverLet_Patient_Tar.doc
   
/********************************************************************/    


public class SCM_MD_AppealCoverLet_Pat_Tar extends SCM_MergeDocument 
{
	protected String patientIdLocal;
	
    public SCM_MD_AppealCoverLet_Pat_Tar(String caseId, String argLookupId)
    {
        super(caseId, argLookupId);
        setRequireSystemDocUI(true);    
    }

    public override void createMergeFields() 
    {
    	patientIdLocal = selectedCase.Patient_gne__r.Id; 
    	
     // caseId
     this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
      
     //CR_Phone
     this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
     
     //CR_Fax
     this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
     
     //DateLong(DateLong)
     this.mergeRecipientInfo.add(new SCM_MF_DateLong()); 
     
     //PatientFullName(key Patient_First_And_Last_Name)
      this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
    	  
     //7.PatientStAddresss  
     this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine1(selectedCase.Patient_gne__r.Id));
        
     //8.PatientCityStateZip         
     this.mergeRecipientInfo.add(new SCM_MF_PatientCityStateZip1(patientIdLocal));
        
     //PatientHomePhone
     this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.Patient_Home_Phone(patientIdLocal));
      
     //PayorAppealContact
      this.mergeRecipientInfo.add(new SCM_MF_PayorAppealContact(selectedCase.Id));
      
     //PhysicianLastName(key Physician Last Name)  
      this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
     //UI_Comments
     this.mergeFields.add(new SCM_MF_Comments());
     
     //AppealSpecialist
      this.mergeRecipientInfo.add(new SCM_MF_AppealSpecialistCollection(selectedCase.Id));
      
      this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedcase.Product_gne__c));
		this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedcase));         
         
        
        this.mergeImages.add(new SCM_MI_Logo(SelectedCase)); 
    }
}