public virtual class SCM_MergeFieldCheckbox extends SCM_MergeField {
    
    public SCM_MergeFieldCheckbox()
    {
        super();
        this.displayCheck = true;
        this.displayLabel = true;
        this.displayTextbox = false;
        this.IsRequired = false;
        this.fieldType = SCM_MergeField.FieldTypes.checkboxField;
    }
    
    public SCM_MergeFieldCheckbox(String Key, String Label)
    {
        super(Key,Label,true);
        this.className ='SCM_MergeFieldCheckbox';
        this.displayCheck = true;
        this.displayLabel = true;
        this.displayTextbox = false;
        this.fieldType = SCM_MergeField.FieldTypes.checkboxField;
        this.IsRequired = false;
        this.key = Key;
        this.label = Label;
    }
    
   /********************************************************************/
    // Function Name    : getMergeValue
    // Argument         : 
    // Return Type      : 
    // Description      : For checkboxes we always call the getFieldValue()
    //                    method. This is the difference
    /********************************************************************/ 
    public override String getMergeValue()
    {
        mergeValue = getFieldValue();
        return mergeValue;
    }
    
    public override String getFieldValue() {
        //return checked ? 'True' : 'False';
        return checked ? fieldValue : '';
    }

}