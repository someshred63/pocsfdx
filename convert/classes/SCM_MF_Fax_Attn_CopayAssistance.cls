//condition is as  follows
// assign attn to a static value 'Co-pay assistance'
public class SCM_MF_Fax_Attn_CopayAssistance extends SCM_MergeField
{
  public SCM_MF_Fax_Attn_CopayAssistance()
   {
    key='ATTN_COPAY';
    checked=false;
    displayCheck=false;
    displayTextBox=true;
    displayLabel=true;
    fieldType = SCM_MergeField.FieldTypes.textboxField;
    label='Attn';
    fieldValue='Co-pay assistance';
    className='SCM_MF_Fax_Attn_CopayAssistance';
   } 
   
   public override String getFieldvalue()
   { 
    return fieldValue;
   }
}