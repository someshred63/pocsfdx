/********************************************************************/
    // Developer Name    : Jatin Setia
    // Document Name     : NUT_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.doc
    // PRODUCT GROUP     : Growth Hormone / Nutropin
    // Type              : Fax Coversheet
    // Word Template     : CMGT-FAX-01-GATCF-InformationDocumentRetrieval.doc
    // Label in SF       : Information/Documentation Retrieval
    
/********************************************************************/

public class SCM_MD_FAX_INFO_DOC_RET_Nutropin extends SCM_MergeDocument implements IStandardComboBox{
	
	private SCM_MergeSection addDocInfo;
	
	private SCM_MergeFieldCheckbox Checkbox1;
	private SCM_MergeFieldCheckbox Checkbox2;
	private SCM_MergeFieldCheckbox Checkbox3;
	private SCM_MergeFieldCheckbox Checkbox4;
	private SCM_MergeFieldCheckbox Checkbox5;
	
    public SCM_MD_FAX_INFO_DOC_RET_Nutropin(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
    	String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String pid = selectedCase.Patient_gne__c;
        String caseRecordType = selectedCase.RecordType.Name ;
        
        //-------------------------------------------------------------------------------------------
        // 0 Case Number (CaseID) (key Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        // 1 Patient ID (key Patient Id)
    	this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		//-------------------------------------------------------------------------------------------    	
        // 2 GATCF Phone (key GATCF_Phone)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        // 3 GATCF Fax (key GATCF_Fax)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        // 4 GATCF URL (key GATCF_URL)
    	this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));
    	
    	// 5 DateShort(key Current_Date)
    	this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
    	
    	// 6 PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );

        // 7 Patient DOB (key Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(pid));
        
        // 8 Drug(Drug)
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase));
        
        // 9 PrivacyNotice (key PrivacyNotice)
    	this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));        
    	
        // 10 Confidentiality Notice (key ConfidNotice)
        this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        //------------------------------------------------------------------------------------
        //                               first page
        //-------------------------------------------------------------------------------------------
        // 11  Attn:(ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        // 12 Addressed To:(RECNAME_To)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        // 13 RECFax Number:(RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        // 14 From(From) 
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        // 15 Extension(Ext)
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType)); 
        //------------------------------------------------------------------------------------
        //                               second page
        //-------------------------------------------------------------------------------------------
        //  Additional Information Required:
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
        // 1 UI_ Physician Signature 
        Checkbox1 = new SCM_MergeFieldCheckbox('UI_ Physician Signature', 'Physician Signature (STAMPED signatures are invalid)');       
        Checkbox1.fieldValue = 'Physician Signature (STAMPED signatures are invalid) \r\n';
        Checkbox1.totalWidth = '400';
        docu.subFields.add(Checkbox1);
        
        // 2 UI_ Frequency  
        Checkbox2 = new SCM_MergeFieldCheckbox('UI_ Frequency', 'Frequency');       
        Checkbox2.fieldValue = 'Frequency \r\n';
        Checkbox2.totalWidth = '400';
        docu.subFields.add(Checkbox2);
        
        // 3 UI_Product
        Checkbox3 = new SCM_MergeFieldCheckbox('UI_Product', 'Product');       
        Checkbox3.fieldValue = 'Product \r\n';
        Checkbox3.totalWidth = '400';
        docu.subFields.add(Checkbox3);
        
        // 4 UI_NeedleSize
        Checkbox4 = new SCM_MergeFieldCheckbox('UI_NeedleSize', 'Needle Size and/or Diluent');       
        Checkbox4.fieldValue = 'Needle Size and /or Diluent \r\n';
        Checkbox4.totalWidth = '400';
        docu.subFields.add(Checkbox4);
        
         // 5 UI_InjectionTraining
        Checkbox5 = new SCM_MergeFieldCheckbox('UI_InjectionTraining', 'Injection Training');       
        Checkbox5.fieldValue = 'Injection Training \r\n';
        Checkbox5.totalWidth = '400';
        docu.subFields.add(Checkbox5);
        
        this.mergeFields.add(docu);
        
        //  Comments
        this.mergeFields.add(new SCM_MF_Comments());    
    }
        
        public override void getLatestValues()  {
        	
        	if ( (Checkbox1.checked == false)&&
        		(Checkbox2.checked == false)&&
        		(Checkbox3.checked == false)&&
        		(Checkbox4.checked == false)&&
        		(Checkbox5.checked == false) )
        		
        		{
        			addDocInfo.visible = false;
        		}
        	else
        	{
        			addDocInfo.visible = true;
        	}	
    	}
}