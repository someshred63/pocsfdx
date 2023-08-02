public class SCM_MF_Appeal_FieldFactory {

public static SCM_MergeField AppealLevel(Appeal_Level_gne__c AL)
    {
      SCM_MergeField mf = createMergeField('AppealLevel');
      if (AL == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = AL.Level_of_Appeal_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }    
    
  public static SCM_MergeField NumberOfAppeals(Appeal_gne__c AL)
    {
      SCM_MergeField mf = createMergeField('NumAppeals');
      if (AL == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = string.valueof(AL.Num_of_Appeal_Levels_Allowed_gne__c);
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }    

  private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        
        return mf;
    }
}