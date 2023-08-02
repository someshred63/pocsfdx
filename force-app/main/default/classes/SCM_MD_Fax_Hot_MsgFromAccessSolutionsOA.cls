public class SCM_MD_Fax_Hot_MsgFromAccessSolutionsOA extends SCM_MergeDocument_Hotline {
   public SCM_MD_Fax_Hot_MsgFromAccessSolutionsOA(String hotLineId,String docLookupId)
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
    	
    	
		
		//-------------------------------------------------------------------------------------------         
        //5. ATTN_BLANK
		this.mergeRecipientInfo.add(BlankTextField('ATTN_BLANK','Attn:',true)); 
		
		//-------------------------------------------------------------------------------------------         
        //6. RECNAME_BLANK
		//this.mergeRecipientInfo.add(BlankTextField('RECNAME_BLANK','Addressed To:',true)); 

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