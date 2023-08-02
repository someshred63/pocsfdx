public class SCM_MF_FaxRECFAX extends SCM_MergeField{
	String physicianIdLocal;
	public SCM_MF_FaxRECFAX(String physicianId)
    {   
    	physicianIdLocal  = physicianId;
        this.key = 'RECFAX_Fax';
        this.checked = false;
        this.displayCheck = false;
        this.displayLabel = true;
        this.displayTextbox = true;
        this.label = 'Fax'; 
        this.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
        this.isRequired = true; 
        this.IsNewLine = true;
        this.fieldValue = getFieldValue();          
    }
    
    public virtual override String getFieldValue() 
    {                
        String physicianFax;
        SCM_MF_Physician_Fax  phyFax = new SCM_MF_Physician_Fax(physicianIdLocal);
        physicianFax = phyFax.getFieldValue();
        return physicianFax;
    }

}