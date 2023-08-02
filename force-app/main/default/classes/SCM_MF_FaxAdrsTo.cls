public class SCM_MF_FaxAdrsTo extends SCM_MergeField {
	String physicianIdLocal;
	public SCM_MF_FaxAdrsTo(String physicianId)
    {   
    	physicianIdLocal  = physicianId;
        this.key = 'RECNAME_Name';
        this.checked = false;
        this.displayCheck = false;
        this.displayLabel = true;
        this.displayTextbox = true;
        this.label = 'Addressed To'; 
        this.fieldType = SCM_MergeField.FieldTypes.textboxField;
        this.isRequired = true; 
        this.IsNewLine = true;
        this.fieldValue = getFieldValue();          
    }
    
    public virtual override String getFieldValue() 
    {                
        String physicianName;
        SCM_MF_PhysicianFirstLastName phyName = new SCM_MF_PhysicianFirstLastName(physicianIdLocal);
        physicianName = phyName.getFieldValue();
        return physicianName;
    }
	
}