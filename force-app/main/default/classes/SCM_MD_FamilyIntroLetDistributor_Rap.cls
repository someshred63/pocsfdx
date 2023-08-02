/****************************************************************************/    
    // Developer Name    : Shobha Rawat
    // Document Name     : RAP-CMGT-FAX-46B Family Intro Letter-Distr.doc
    // PRODUCT GROUP     : DERMATOLOGY/RAPTIVA
    // Type              : System Document
    // Word Template     : FamilyIntroLetterDistr_Rap.doc   
    // Label in SF       : FAMILY INTRO LETTER DISTRIBUTOR
/****************************************************************************/     

public class SCM_MD_FamilyIntroLetDistributor_Rap extends SCM_MergeDocument {
	
	protected String caseId;
	protected string streetVal = '';
	protected string cityStateZipVal = '';

	public SCM_MD_FamilyIntroLetDistributor_Rap(String caseID,String argLookupID) {
        	super(caseId, argLookupID);
    }

	public override void createMergeFields()  {
		string pid = selectedCase.Patient_gne__c;
		String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
		String recordType = selectedCase.RecordType.Name;
       
		// 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        // 1  Patient Number()
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        
        //2 CR_Phone(CR_PhoneShort)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //3 CR_URL(CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //4 CR_Fax(CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //5 ConfidNotice(ConfidNotice)
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
		
		//6. Current Date(DateLong)
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //7. FullName(AgeBasedFullName)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(pid) );
        
        //8. AgeBasedSt(AgeBasedStAddress)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(pid) );
        
        //9. AgeBasedCityStateZip(AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(pid) );
        
        //10.PhysicianLastName(Physician Last Name)
         this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(physicianId));
        
        //11.Dispensing Center(Dispensing Center)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.Id));
        
         //12 DistributorContactPhone(FulFillment Phone)
        this.mergeRecipientInfo.add( new SCM_MF_FulFillmentPhone(selectedCase.id));
        
        //13.Case Worker(caseworker)       
       //	this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
       
        if (recordType.startsWith('C&R')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
       		      
	}
}