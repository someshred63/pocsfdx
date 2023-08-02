public class SCM_MF_CaseManager_FieldFactory {

    private static User user;
    
    private static User getCaseManager(String userId)
    {
        if( user == null )
        {
            try{
                user = [SELECT u.FirstName, 
                               u.LastName, 
                               u.Extension 
                          FROM User u
                         WHERE u.Id = :userId LIMIT 1];
            }catch(Exception e){
                return null;
            }      
        }
        return user;
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
    
    public static SCM_MergeField CaseManagerFromFirstAndLastName(String caseManagerId)
    {
        SCM_MergeField mf = createMergeField('From');
        try {
        if( null != getCaseManager(caseManagerId) )
        {
            String firstName = getCaseManager(caseManagerId).FirstName;
            String lastName = getCaseManager(caseManagerId).LastName;
            
            if (firstName == null)
            	firstName = '';
            
            if (lastName == null)
            	lastName = '';
            	
            mf.fieldValue = firstName + ' ' + lastName;
        }
        else
        {
        	mf.fieldValue = '';
        }
        mf.displayTextBox = true;
        mf.displayLabel = true;
        mf.label='From:';
        //New code(Vinod)
        mf.isRequired = false;
        }catch (exception ex) {
        	 mf.fieldValue = '';
        	
        }
        return mf;
    }
    
    public static SCM_MergeField CaseManagerExtension(String caseManagerId)
    {   
        SCM_MergeField mf = createMergeField('Ext');
        try {
        if( null != getCaseManager(caseManagerId) )
        {
            mf.fieldValue = getCaseManager(caseManagerId).Extension;
        }
        else
        {
        	mf.fieldValue = '';
        }
        
        mf.displayTextBox = true;
        mf.displayLabel = true;
        mf.label='Ext #:';
        mf.isNewLine = false;
        mf.totalWidth = '90';
        mf.width = '40';
        mf.fieldType = SCM_MergeField.FieldTypes.extensionField; 
        mf.isRequired = false;
		if (mf.fieldValue == null)
			mf.fieldValue = '';
			}catch (exception ex) {
        	 mf.fieldValue = '';
        	
        }
        return mf;
    }
}