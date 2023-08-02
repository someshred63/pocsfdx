// Added By: Peter Duszkiewicz
// Merge Field for incomplete fields, returns field name
public class SCM_MergeField_Incomplete extends SCM_MergeField 
{
    public SCM_MergeField_Incomplete (string fieldId) 
    {
    	super();
    	setKey(fieldId);
    	setFieldValue(fieldId);
		className = 'SCM_MergeField_Incomplete';
    }
 	
 	public override String getFieldValue()
  	{     
    	return fieldValue;
 	}
 	public override String getKey()
  	{     
    	return key;
 	}
}