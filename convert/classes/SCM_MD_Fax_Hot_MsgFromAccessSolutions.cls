public class SCM_MD_Fax_Hot_MsgFromAccessSolutions extends SCM_MergeDocument_Hotline {
   public SCM_MD_Fax_Hot_MsgFromAccessSolutions(String hotLineId,String docLookupId)
    { 
        super(hotLineId,docLookupId);
    }
       
    public override void createMergeFields() 
    {
    	try
    	{
    	//String productName='Hotline';
    	// CurrentDate
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
    	
    	this.mergeRecipientInfo.add(new SCM_MF_HotlineID(selectedHotline)); 	
    	
    	if(selectedHotline.Product_gne__c!=null && selectedHotline.Product_gne__c!='')
    	 {
    	 	//-------------------------------------------------------------------------------------------
        	//2. CR Phone
        	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedHotline));
         	//-------------------------------------------------------------------------------------------
        	//2. CR PhoneShort
        	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedHotline));
     
        	//-------------------------------------------------------------------------------------------    
        	//3. CR Fax
        	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedHotline));
        	//-------------------------------------------------------------------------------------------         
        	//4. URL
			this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedHotline));  
			this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedHotline)); 
			this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedHotline));
			this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedHotline));
			this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedHotline.Product_gne__c)); 
			this.mergeImages.add(new SCM_MI_Logo(selectedHotline));
    	 }
    	else
    	{
    		String docProduct = sfDocumentRecord.Product__c;
    		    	 //-------------------------------------------------------------------------------------------
        	//2. CR Phone
        	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(docProduct));
         	//-------------------------------------------------------------------------------------------
        	//2. CR PhoneShort
        	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(docProduct));
     
        	//-------------------------------------------------------------------------------------------    
        	//3. CR Fax
        	this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(docProduct));
        	//-------------------------------------------------------------------------------------------         
        	//4. URL 
			this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(docProduct));  
			this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(docProduct)); 
			this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(docProduct));
			this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(docProduct));
			this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(docProduct)); 
			this.mergeImages.add(new SCM_MI_Logo(docProduct));
			  
    	}
		
		//-------------------------------------------------------------------------------------------         
        //5. ATTN_BLANK
		this.mergeRecipientInfo.add(BlankTextField('ATTN_BLANK','Attn:',true)); 
		
		//-------------------------------------------------------------------------------------------         
        //6. RECNAME_BLANK
		this.mergeRecipientInfo.add(BlankTextField('RECNAME_BLANK','Addressed To:',true)); 

		//-------------------------------------------------------------------------------------------         
        //7. RECFAX_BLANK
        SCM_MergeField fax=BlankTextField('RECFAX_BLANK','Fax Number:',true);
		fax.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
		this.mergeRecipientInfo.add(fax); 

		//-------------------------------------------------------------------------------------------         
        //8. From
		this.mergeRecipientInfo.add(BlankTextField('From','From:',false));
		
		SCM_MergeField mfname = new SCM_MergeField();
		mfname.key = 'patientName';
		mfname.fieldValue = '';
		mfname.displayCheck = false;
		mfname.displayTextBox = false;
		mfname.displayLabel = false;
		try {
			mfname.displayField = false;
			if (selectedhotline.Patient_First_Name_gne__c != null)
			{
				mfname.fieldValue = selectedhotline.Patient_First_Name_gne__c + ' ';
			}
			if (selectedhotline.Patient_Last_Name_gne__c != null)
			{
				mfname.fieldValue += selectedhotline.Patient_Last_Name_gne__c + ' ';
			}
				
			
		}
		catch(exception ex1){
			mfname.fieldvalue = '';
		}
		 this.mergeRecipientInfo.add(mfname);
	
		//-------------------------------------------------------------------------------------------         
        //9. Ext      
        SCM_MergeField extension=BlankTextField('Ext','Ext#:', false);
        extension.fieldType = SCM_MergeField.FieldTypes.extensionField; 
        extension.totalWidth = '90';
        extension.width = '40';
		this.mergeRecipientInfo.add(extension);
		

		// Page 2
		//-------------------------------------------------------------------------------------------         
        //10. Comments
		this.mergeFields.add(new SCM_MF_Comments());
		
		
    	}
    	catch(Exception exp)
    	{
    		 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Exception : SCM_MD_Fax_Hot_MsgFromAccessSolutions ' + exp.getMessage()));
    		printValues();
    	}
    } 
    
    
    private SCM_MergeField BlankTextField(String key,String label,Boolean isRequired)
    {
    	SCM_MergeField mf = new SCM_MergeField();
    	mf.displayTextbox=true;
    	mf.displayLabel=true;
    	mf.label=label;
    	mf.key= key;
    	mf.fieldValue='';
    	mf.displayCheck=false;
    	mf.isRequired=isRequired;
    	return mf;
    }
}