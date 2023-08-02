/********************************************************************/
    // Developer Name    : Paras Sharma
    // Document Name     : RAP-CMGT-FAX-26 One Off.doc
    // Product           : Dermatology / Raptiva
    // Type				 : Fax Coversheet
    // Word Template     : One_Off_Rap.doc    
    // Label in SF       : One Off
    
/********************************************************************/

public class SCM_MD_Fax_OneOff_Rap extends SCM_MergeDocument implements IStandardComboBox{

	protected String caseId;
    
    public SCM_MD_Fax_OneOff_Rap(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
    public override void createMergeFields() {
    	
    	String caseRecordType = selectedCase.RecordType.Name;
    	
    	// Attn
       // SCM_MF_Attn attnName = new SCM_MF_Attn(selectedCase.Id, true);
       // String attnNameVal = attnName.getFieldValue();
       // attnName.fieldValue = attnNameVal ;
       // attnName.label='Attn:';
       // attnName.Key = 'ATTN_Attn';
       // attnName.fieldType = SCM_MergeField.FieldTypes.textboxField ;
       // this.mergeRecipientInfo.add(attnName);
         this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        // Addressed To
     //   this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulfillmentAddressTo(selectedCase.Id));     
         this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
        // Fax No
     //   this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber(selectedCase.Id));     
    	this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
    	// From and Ext
        //this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
        //this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType));
        String recordType = selectedCase.RecordType.Name; 
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
        /**
        if(selectedCase.RecordType.Name != null)
        {
        	if(selectedCase.RecordType.Name == 'C&R - Continuous Care Case' ||
        		 selectedCase.RecordType.Name == 'C&R - Standard Case')
        	{
        		//From
        		SCM_MF_CaseMangFirstAndLastName caseMangName = 
		        	new SCM_MF_CaseMangFirstAndLastName(selectedCase.Case_Manager__r.Id);       
		        caseMangName.label='From:';
		        caseMangName.key = 'From';
		        string caseMangNameVal = caseMangName.getFieldValue();   
		        caseMangName.fieldValue = caseMangNameVal;          
		       	caseMangName.fieldType = SCM_MergeField.FieldTypes.fullNameField;
		       	caseMangName.isRequired = false;                    
		        this.mergeRecipientInfo.add(caseMangName);
		        
		        // Ext
		        SCM_MF_CaseMangPhoneExt extNo = 
		        	new SCM_MF_CaseMangPhoneExt(selectedCase.Case_Manager__r.Id);		
			    extNo.label='Ext#:';
			    extNo.key = 'Ext';
			    string extNoVal = extNo.getFieldValue();
			    extNo.fieldValue = extNoVal;
			    extNo.fieldType = SCM_MergeField.FieldTypes.extensionField;
			    extNo.isRequired = false;
			    this.mergeRecipientInfo.add(extNo);
        	}
        	if(selectedCase.RecordType.Name == 'GATCF - Standard Case')
        	{
        		//From
        		SCM_MF_FoundationSplName foundSpl = 
        			new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id);
		        foundSpl.label = 'From:';
		        foundSpl.key = 'From';
		        string foundSplVal = foundSpl.getFieldValue();
		        foundSpl.fieldValue = foundSplVal;
		        foundSpl.fieldType = SCM_MergeField.FieldTypes.fullNameField;
		        foundSpl.isRequired = false;
		        this.mergeRecipientInfo.add(foundSpl);
		        
		        //Ext
		        SCM_MF_FoundationSplPhoneExt extNo = 
		        	new SCM_MF_FoundationSplPhoneExt(selectedCase.Foundation_Specialist_gne__r.Id);		
			    extNo.label='Ext#:';
			    extNo.key = 'Ext';
			    string extNoVal = extNo.getFieldValue();
			    extNo.fieldValue = extNoVal;
			    extNo.fieldType = SCM_MergeField.FieldTypes.extensionField;
			    extNo.isRequired = false;
			    this.mergeRecipientInfo.add(extNo);
        	}
        }
        */
        
        // Case Number
		this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
	    
	    // Patient Id
		this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
		
		// Phone 
        //this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
      
        // Phone Short [Key: 'CR_PhoneShort']
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        // Fax (Key: 'Fax')
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        // URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        // Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        // DOB
		this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
		
		// Confidentiality Notice
		this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));     
        
        /////////-------Second Screen ------
        
        this.mergeFields.add(new SCM_MF_Comments());
    
    }
}