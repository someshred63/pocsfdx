//condition is as  follows
// assign attn to a static value 'RxCrossroads'
public class SCM_MF_Fax_AddressedTo extends SCM_MergeField
{
   public SCM_MF_Fax_AddressedTo()
   {
    key='RECNAME_RX';
    checked=false;
    displayCheck=false;
    displayTextBox=true;
    displayLabel=true;
    fieldType = SCM_MergeField.FieldTypes.textboxField;
    label='Addressed To';
    fieldValue='RxCrossroads';
    className='SCM_MF_Fax_AddressedTo';
   } 
   
   public override String getFieldvalue()
   { 
    return fieldValue;
   }
}