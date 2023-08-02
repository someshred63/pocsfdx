/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : AVA-CMGT-FAX-68_APA Program Non Qualify Letter.doc
    // Type              : System Document
    // PRODUCT GROUP     : Avastin
    // Word Template     : CMGTAPAProgramNonQualifyLetterAVST.doc    
    // Label in SF       : CMGT APA Prog Non Qualify Letter AVST
    
/********************************************************************/
public class SCM_MD_APAProgNonQualify_AVST extends SCM_MergeDocument {
	protected String caseId;
	public SCM_MD_APAProgNonQualify_AVST (String caseId, String argLookupId) {
		super(caseID, argLookupId);
		caseId = caseID;
	}
	
	public override void createMergeFields() {
		String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
		String patientNumber = selectedCase.patient_gne__r.id;
		
		//0.InfusionTotal
		this.mergeRecipientInfo.add(new SCM_MF_InfusionTotal(selectedCase.Id));
		
		//1.CR_Fax
		this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
		
		//2.CR_Phone
		this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
		
		//3.Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //4.CaseWorker
        this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
        
        //5.DateLong
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //6.PatientFullName('Patient_First_And_Last_Name')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientNumber));
        
        //7.PhysicianCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //8. Physician Full Name ('Physician First Last Name')
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
    	//9.PhysicianStAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
         
	}

}