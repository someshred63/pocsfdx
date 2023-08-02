public class SCM_MD_Fax_Hot_InoResourceLetter extends SCM_MergeDocument_Hotline{
    public SCM_MD_Fax_Hot_InoResourceLetter(String hotLineId,String docLookupId)
    { 
        super(hotLineId,docLookupId);
    }
    
    
    public override void createMergeFields() 
    {
    	String productName='Hotline';
    	// CurrentDate
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
    	
    	this.mergeRecipientInfo.add(new SCM_MF_HotlineID(selectedHotline));
    	// RECFAX_BLANK
        SCM_MergeField fax=BlankTextField('RECFAX_BLANK','Fax Number:',true);
		fax.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
		this.mergeRecipientInfo.add(fax); 
		
		//5. ATTN_BLANK
		SCM_MergeField attn=BlankTextField('ATTN_BLANK','',false);
		attn.displayTextbox=false;
		attn.displayLabel=false;
		this.mergeRecipientInfo.add(attn); 
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