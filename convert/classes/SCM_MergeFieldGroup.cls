public virtual class SCM_MergeFieldGroup extends SCM_MergeField {
     
     
    public SCM_MergeFieldGroup()
    {
        fieldType = FieldTypes.FIELDGROUP;
        isFieldGroup=true;
        isFormField = false;
        isRequired= false;
        displayTextBox=false;
        displayCheck = false;
        displayLabel = false;
        
    }
    
    private Boolean visible = true;
    
    public virtual Boolean getVisible()
    {
        return visible;
    } 
    public virtual void setVisible(Boolean arg)
    {
        visible = arg;
    }
     public static  testMethod void coverMergeCode()
    {
    	SCM_MergeFieldGroup g  = new SCM_MergeFieldGroup();
    	boolean test = g.getVisible();
    	g.setVisible(test);
    	
    	
    	
    }
   
}