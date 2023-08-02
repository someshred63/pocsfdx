/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : LUC-CMGT-FAX-53_GATCF_Rx_Prefill.doc
    // Type				 : System Document
    // Word Template     : GATCFRxPrefill_Luc.doc    
    // Label in SF       : GATCF Rx Prefill
    
/********************************************************************/

public class SCM_MD_GATCFRxPrefill_Lucentis extends SCM_MergeDocument
{
	public SCM_MD_GATCFRxPrefill_Lucentis(String caseId, String argLookupId)
	{
		super(caseId, argLookupId);
	}
	
	public override void createMergeFields()
	{
    	 
    	 // 0 Case ID
		 this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
		 
		 // 1 Foundation Specialist 
    	 this.mergeRecipientInfo.add(new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id));
    	 
    	//GATCF_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
    	//GATCF_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
    	     	     	   	 
    	 // 4 Patient Full Name
    	 //SCM_MF_PatientFirstAndLastName patFullName = new SCM_MF_PatientFirstAndLastName(selectedCase);
    	 //String patFullNameVal = patFullName.getFieldValue();
    	 //patFullName.fieldValue = patFullNameVal;
    	 this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
    	 
    	 // 5 DOB
    	 //SCM_MF_PatientDOB patDob = new SCM_MF_PatientDOB(selectedCase.Patient_gne__r.Id);
    	 //String patDobVal = patDob.getFieldValue();
    	 //patDob.fieldValue = patDobVal;
    	 this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
    	 
    	 // 6 Physician Full Name
    	 //SCM_MF_PhysicianFirstMidAndLastName phyFullName = 
    	 //		new SCM_MF_PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.Id);
		 //String phyFullNameVal = phyFullName.getFieldValue();
    	 //phyFullName.fieldValue = phyFullNameVal;    	 		
    	 //this.mergeRecipientInfo.add(phyFullName);
    	 this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName_Invisible(selectedCase.Case_Treating_Physician_gne__r.Id));
    	 
    	 // 7 Physician StAddress
    	 //SCM_MF_PhysicianStAddress phyStAdd = new SCM_MF_PhysicianStAddress(selectedCase.id);
    	 //string phyStAddVal = phyStAdd.getFieldValue();
    	 //phyStAdd.fieldValue = phyStAddVal;
    	 this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
    	 
    	 // 8 Physician City State Zip
    	 //SCM_MF_PhyCityStateZip phyCityStateZip = new SCM_MF_PhyCityStateZip(selectedCase.id);
    	 //string phyCityStateZipVal = phyCityStateZip.getFieldValue();
    	 //phyCityStateZip.fieldValue = phyCityStateZipVal;
    	 this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
    	 
    	 // 9 Physician Contact Phone
    	 //SCM_MergeField_Incomplete phyConPhone = new SCM_MergeField_Incomplete('PhyContactPhone');
         //phyConPhone.fieldValue='';
          
         this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));
    	 
    	 // 10 Physician DEA
    	 this.mergeRecipientInfo.add(new SCM_MF_PhysicianDEA(selectedCase.Case_Treating_Physician_gne__r.Id));
    	 
      	 // 11 GATCF Disclaimer   	 
    	 this.mergeRecipientInfo.add(new SCM_MF_GATCFDisclaimer());	
    	 
  	}  	 
}