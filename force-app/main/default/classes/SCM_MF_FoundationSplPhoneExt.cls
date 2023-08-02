// Added By: Paras Sharma
// For getting the Foundation specialist ph ext

public class SCM_MF_FoundationSplPhoneExt extends SCM_MergeField{

	protected User foundSpl;
	
	public SCM_MF_FoundationSplPhoneExt(String userId) {
		
		key = 'Foundation_Spl_Ext' ;
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = false;
        this.fieldType = SCM_MergeField.FieldTypes.extensionField; 
       	this.totalWidth = '70';
       	this.width = '40';
       	this.isNewLine = false;
        
        List<User> foundSplList = [Select u.Extension From User u
        where u.Id = :userId LIMIT 1];
        
        if(foundSplList.size()>=1)
            foundSpl = foundSplList[0];
        else
        {
            foundSpl = null;
        } 
	}
	
	public override String getFieldValue() {		
		if(foundSpl != null){			
  			return  foundSpl.Extension;   		
		}
		else {
			return '';
		}
  	}
}