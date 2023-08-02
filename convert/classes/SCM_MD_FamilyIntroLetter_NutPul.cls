/****************************************************************************/    
    // Developer Name    : Jatin Setia		
    // Document Name     : NUT- PUL CMGT-FAX-46 Family Intro Letter final.doc
    // PRODUCT GROUP     : GROWTH HORMONE/NUTROPIN AND PULMONARY/PULMOZYME
    // Type              : System Document
    // Word Template     : CMGT-FAX-46-FamilyIntroLetter-NutPul.doc   
    // Label in SF       : Family Intro Letter 
    
/****************************************************************************/ 
public class SCM_MD_FamilyIntroLetter_NutPul extends SCM_MergeDocument {
	
	 public SCM_MD_FamilyIntroLetter_NutPul(String caseID,String argLookupID) {
	    super(caseId, argLookupID);
    }
 
    public override void createMergeFields()  {
        String pid = selectedCase.Patient_gne__c;
		String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
       	String patientId = selectedCase.Patient_gne__r.Id;
         
        //  CR_Logo(Logo) 
        this.mergeimages.add(new SCM_MI_Logo(selectedCase));              
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));           
        // 1 Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        // 2 CR_Phone(CR_Phone_Short)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
		// 2 CR_Phone(CR_Phone)
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));        
        // 3 CR_Fax(CR_Fax)        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));         
        // 4 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        // 5 DateLong(DateLong)
        this.mergeRecipientInfo.add(new SCM_MF_DateLong()); 
        
        // 6 AgeBasedFullName(AgeBasedFullName)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patientId));
                
        // 7 AgeBasedStAddress(AgeBasedStAddress) 
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patientId));        
        
        // 8 AgeBasedCityStateZip(AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patientId));
         
		// 9 ProductType(ProductType)
		this.mergeRecipientInfo.add(new SCM_MF_ProductType(selectedCase));
		
		//10 Patient Full Name(Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
        
        //11 Physcian Last Name(Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
        //12 Access Solutions(AccessSolutions)
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        
        //13 ProductNames(ProductNames_Nut)
        this.mergeRecipientInfo.add(new SCM_MF_ProductNames_Nutropin(selectedCase));
        
        //14 Drug(Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase));
        
        //15 Case Worker(caseworker)
      	String recordType = selectedCase.RecordType.Name;
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
    }         
}