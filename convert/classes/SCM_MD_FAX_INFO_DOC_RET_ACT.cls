/********************************************************************/
    // Developer Name    : Deepti(Deepak)
    // Document Name     : ACT_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
    // Product           : Activase / Activase
    // Type				 : Fax Coversheet
    // Word Template     : CMGT-FAX-01-GATCF-InformationDocumentRetrieval-Act.doc
    // Label in SF       : Information/Documentation Retrieval
    
/********************************************************************/
public class SCM_MD_FAX_INFO_DOC_RET_ACT extends SCM_MergeDocument implements IStandardComboBox{
     
 	private SCM_MergeSection addDocInfo;
	
	private SCM_MergeFieldCheckbox Checkbox1;
	private SCM_MergeFieldCheckbox Checkbox2;
	private SCM_MergeFieldCheckbox Checkbox3;
	private SCM_MergeFieldCheckbox Checkbox4;
	private SCM_MergeFieldCheckbox Checkbox5;
	private SCM_MergeFieldCheckbox Checkbox6;
	private SCM_MergeFieldCheckbox Checkbox7;
 	      
     public SCM_MD_FAX_INFO_DOC_RET_ACT(String caseId, String argLookupId) {
        super(caseId, argLookupId);
     }


     public override void createMergeFields() {
     	
     	String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
     	String caseRecordType = selectedCase.RecordType.Name;
     	
     	//-------------------------------------------------------------------------------------------
        //0. Case Number(key:Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //1. Patient ID (key:Patient Id)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		//-------------------------------------------------------------------------------------------    
		
     	//2. GATCF_Phone(Key:GATCF_Phone)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
     	
     	//3. GATCF_Fax(key:GATCF_Fax)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
     	
     	//4. DateShort(Key:Current_Date)
     	this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
     	
     	//5. PatientFullName(Key:Patient_First_And_Last_Name)
     	this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
     	
     	//6. DOB(Key:Patient_DOB)
     	this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
     	
     	//7. Drug(Key:Drug)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
     	
     	//8. PrivacyNotice(Key:PrivacyNotice)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
     	
     	//9. ConfidNotice(key:ConfidNotice)
     	this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
     	
     	/////////-------First Screen ------
     	
     	//10. Attn(Key:ATTN_Attn)
     	this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
     	
     	//11. Addressed To(Key:RECNAME_To)
     	this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
     	
     	//12. Fax(RECFAX_Fax)
     	this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
     	
     	//13&14. From and Ext#(Key:From and Ext)
     	this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase,caseRecordType));
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase,caseRecordType));
        
 		/////////-------Second Screen ------
 		
 		SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Additional Information Required:';
        docu.headerText = '';       
        docu.key = 'Documentation';

        
        // Merge Section
        // UI_AdditionalDoc
        addDocInfo = new SCM_MergeSection();                 
        addDocInfo.key = 'UI_AdditionalDoc';
        this.mergeSections.add(addDocInfo);

        
        // Checkboxes
        //1.UI_PatientInformation
 	    Checkbox1 = 
        		new SCM_MergeFieldCheckbox('UI_PatientInformation', 'Patient Info');		
		Checkbox1.fieldValue = 'Patient Information \r\n';
        Checkbox1.totalWidth = '270';
        Checkbox1.isNewLine = true;
        docu.subFields.add(Checkbox1);
        
        //2.UI_InsuranceInformation
        Checkbox2 = 
        		new SCM_MergeFieldCheckbox('UI_InsuranceInformation', 'Insurance Info');		
		Checkbox2.fieldValue = 'Insurance Information \r\n';
        Checkbox2.totalWidth = '270';
        Checkbox2.isNewLine = true;
        docu.subFields.add(Checkbox2);
     	
     	//3.UI_FacilityPhysInfo
        Checkbox3 = 
        		new SCM_MergeFieldCheckbox('UI_FacilityPhysInfo', 'Fac/Phy Info');		
		Checkbox3.fieldValue = 'Facility/Physician Information \r\n';
        Checkbox3.totalWidth = '270';
        Checkbox3.isNewLine = true;
        docu.subFields.add(Checkbox3);
     	
     	//4.UI_MedicalInfo
     	Checkbox4 = 
        		new SCM_MergeFieldCheckbox('UI_MedicalInfo', 'Medical Info');		
		Checkbox4.fieldValue = 'Medical Information \r\n';
        Checkbox4.totalWidth = '270';
        Checkbox4.isNewLine = true;
        docu.subFields.add(Checkbox4);
     	
     	//5.UI_ShippingDetails
        Checkbox5 = 
        		new SCM_MergeFieldCheckbox('UI_ShippingDetails', 'Shipping Details');		
		Checkbox5.fieldValue = 'Shipping Details \r\n';
        Checkbox5.totalWidth = '270';
        Checkbox5.isNewLine = true;
        docu.subFields.add(Checkbox5);
        
        //6.UI_AuthorizedSignDate
        Checkbox6 = 
        		new SCM_MergeFieldCheckbox('UI_AuthorizedSignDate', 'Authorized Sig/Date');		
		Checkbox6.fieldValue = 'Authorized Signature / Date \r\n';
        Checkbox6.totalWidth = '270';
        Checkbox6.isNewLine = true;
        docu.subFields.add(Checkbox6);
        
        //7.UI_IncomeVerification
        Checkbox7 = 
        		new SCM_MergeFieldCheckbox('UI_IncomeVerification', 'Income Verification');		
		Checkbox7.fieldValue = 'Income Verification \r\n';
        Checkbox7.totalWidth = '270';
        Checkbox7.isNewLine = true;
        docu.subFields.add(Checkbox7);
        
        this.mergeFields.add(docu);
        //  Comments
        this.mergeFields.add(new SCM_MF_Comments());
      
   }
    
    public override void getLatestValues()  {
        	
        	if ((Checkbox1.checked == false)&&
        		(Checkbox2.checked == false)&&
        		(Checkbox3.checked == false)&&
        		(Checkbox4.checked == false)&&
        		(Checkbox5.checked == false)&&
        		(Checkbox6.checked == false)&&
        		(Checkbox7.checked == false))
        	   {
        			addDocInfo.visible = false;
        	    }
        	else
        	   {
        			addDocInfo.visible = true;
        	    }	
    	}
    
  }