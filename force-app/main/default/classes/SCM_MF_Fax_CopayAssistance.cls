public class SCM_MF_Fax_CopayAssistance  extends SCM_MergeField{
   public SCM_MF_Fax_CopayAssistance()
   {
    key='RECFAX_COPAY';
    checked=false;
    displayCheck=false;
    displayTextBox=true;
    displayLabel=true;
    //fieldType = SCM_MergeField.FieldTypes.textboxField;
    fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
    label='Fax Number:';
    fieldValue='(866) 847-2382';
    className='SCM_MF_Fax_CopayAssistance';
   } 
   
   public override String getFieldvalue()
   {
    return fieldValue;
   }
}