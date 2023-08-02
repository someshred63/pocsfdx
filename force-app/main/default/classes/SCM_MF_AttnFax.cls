public class SCM_MF_AttnFax extends SCM_MergeField{
    private static String physicianIdLocal;
    public SCM_MF_AttnFax(String physicianId)
    {       
        physicianIdLocal = physicianId;
        this.label='Attn:';
        this.key = 'ATTN_Attn';        
        this.fieldValue = this.getFieldValue();
        this.fieldType = SCM_MergeField.FieldTypes.textboxField; 
        this.IsRequired = true;
        this.displayLabel = true;
        this.displayTextbox = true;
        this.displayCheck = false;           
        
    }
    
    public override String getFieldValue() {
        
        
        SCM_MF_PhysicianContactName phyContName = 
        	  new SCM_MF_PhysicianContactName(physicianIdLocal);
        String phyContNameVal = phyContName.getFieldValue();
        return fieldValue;
    }

}