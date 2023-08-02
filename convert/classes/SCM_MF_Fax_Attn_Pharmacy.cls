//condition is as  follows
// assign attn to a static value 'Pharmacy'
public class SCM_MF_Fax_Attn_Pharmacy extends SCM_MergeField
{
  public SCM_MF_Fax_Attn_Pharmacy()
   {
    key='ATTN_COPAY';
    checked=false;
    displayCheck=false;
    displayTextBox=true;
    displayLabel=true;
    fieldType = SCM_MergeField.FieldTypes.textboxField;
    label='Attn';
    fieldValue='Pharmacy';
    className='SCM_MF_Fax_Attn_Pharmacy';
   } 
   
   public override String getFieldvalue()
   { 
    return fieldValue;
   }
}