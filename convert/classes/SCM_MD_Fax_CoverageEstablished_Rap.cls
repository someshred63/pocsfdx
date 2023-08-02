/********************************************************************/
    // Developer Name    : Rajesh Sinha
    // Document Name     : RAP-CMGT-FAX-13 COVERAGE ESTABLISHED.DOC
    // Type				 : Fax Coversheet
    // Word Template     : COVERAGEESTABLISHED_RAPTIVA   
    // Label in SF       : COVERAGE ESTABLISHED RAPTIVA 
    
/********************************************************************/
public class SCM_MD_Fax_CoverageEstablished_Rap extends SCM_MergeDocument implements IStandardComboBox {
	private SCM_MergeSection UiCopyBenefitInv;
    private SCM_MergeSection UiCoorShipment;

	private SCM_MergeFieldCheckbox UiCopyBenefitInvChk;
    private SCM_MergeFieldCheckbox UiCoorShipmentChk;
    
	protected String caseId;
	public SCM_MD_Fax_CoverageEstablished_Rap(String caseId, String argLookupId) {
		super(caseId, argLookupId);
		caseId = caseID;
	}
	
	public override void createMergeFields() {
		
		String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
		String caseRecordType = selectedCase.RecordType.Name;
		//0. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //1. Addressed To (RECNAME_To)
       // this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(physicianId));
        this.mergeRecipientInfo.add(new SCM_MF_FaxAdrsTo(selectedCase.Case_Treating_Physician_gne__r.Id));
   
        //2. Fax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
		
		//3 & 4. From and Extension   
        String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
		
		//3. From
	   // this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
	        
	    //4. Ext
	    //this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType)); 
	    
	    //5. Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
               
        //6. Patient Number
	    this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
	    
	    //7. CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //8. CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //9. CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //10. Dateshort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //11. PatientFullName(''Patient_First_And_Last_Name'')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
        
        //12. Patient DOB('Patient_DOB')
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        //13. Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        //14. Confidentiality Notice        
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //15. DispensingCenter
        this.mergeRecipientInfo.add(new SCM_MF_DispensingCenter(selectedCase.Id));
        
        //16. DispensingContactName
        this.mergeRecipientInfo.add(new SCM_MF_DispensingContactName(selectedCase.Id));
        
        //17. DispensingContactPhone
        this.mergeRecipientInfo.add(new SCM_MF_FulFillmentPhone(selectedCase.Id));
        
        
        // -------------UI - Second Screen -------------------
        SCM_MergeFieldGroup formInfo = new SCM_MergeFieldGroup();
        formInfo.label = 'Form Information';
        formInfo.key = 'Medical_Info_Reqd';
        
        //Merge Sections       
        UiCopyBenefitInv = new SCM_MergeSection();        
        UiCopyBenefitInv.key = 'UI_ CopyBenefitInv';
        this.mergeSections.add(UiCopyBenefitInv);
        
        UiCoorShipment = new SCM_MergeSection();        
        UiCoorShipment.key = 'UI_ CoorShipment';
        this.mergeSections.add(UiCoorShipment);
 
        
        //Checkboxes
        UiCopyBenefitInvChk = 
            new SCM_MergeFieldCheckbox('UiCopyBenefitInv',
                'A copy of the benefit investigation is attached');
        UiCopyBenefitInvChk.fieldValue = 'A copy of the benefit investigation is attached. \r\n' ;
        UiCopyBenefitInvChk.isNewLine = false;
        UiCopyBenefitInvChk.totalWidth = '900';
        formInfo.subFields.add(UiCopyBenefitInvChk);
        
        UiCoorShipmentChk = 
            new SCM_MergeFieldCheckbox('UiCoorShipment',
                'Access Solutions is coordinating the first/next shipment with the distributor');
        UiCoorShipmentChk.fieldValue = 'Raptiva Access Solutions is coordinating the first/next shipment with the distributor. \r\n' ;
        UiCoorShipmentChk.isNewLine = false;
        UiCoorShipmentChk.totalWidth = '900';
        formInfo.subFields.add(UiCoorShipmentChk);
        
        this.mergeFields.add(formInfo);
        
        //Comments       
	    this.mergeFields.add(new SCM_MF_Comments());
			 
	}
	public override void getLatestValues(){
        UiCopyBenefitInv.visible = UiCopyBenefitInvChk.checked;
        UiCoorShipment.visible = UiCoorShipmentChk.checked;
        }
	
		

}