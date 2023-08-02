// Added By: Paras Sharma
// For getting the Foundation specialist name

public class SCM_MF_FoundationSplName extends SCM_MergeField{

	protected User foundSpl;
	
	public SCM_MF_FoundationSplName(String userId) {
		
		key = 'Foundation_Spl_Name' ;
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = true;
        this.displayLabel = true;
        List<User> foundSplList;
        try{
        	foundSplList = [Select u.Name From User u
        				where u.Id = :userId LIMIT 1];
        }catch(Exception e){
              foundSpl = null;	
        }
        if(foundSplList.size()>=1)
            foundSpl = foundSplList[0];
        else
        {
            foundSpl = null;
        } 
	}
	
	public override String getFieldValue() {		
		if(foundSpl != null){
			string foundSplVal = foundSpl.Name;
			foundSplVal = foundSplVal.replace('&','');
            foundSplVal = foundSplVal.replace('?','');			
  			return  foundSplVal;   		
		}
		else {
			return '';
		}
  	}
}