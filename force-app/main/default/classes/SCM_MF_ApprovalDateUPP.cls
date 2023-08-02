public class SCM_MF_ApprovalDateUPP extends SCM_MergeField
  
{
    
	protected Case ForCase;
	List<Case> ForCaseList;
	
	public SCM_MF_ApprovalDateUPP(String caseId)
    {
    	checked = false;
        displayCheck = false;
        displayTextBox = false; 
        displayLabel = true;
        key = 'Approval Date'; 
        
        try
        {
        ForCaseList = [Select c.Approval_Date_gne__c From Case c WHERE Id = :caseId  LIMIT 1];
        }
        catch(Exception ex)
        {
        	ForCaseList = null;
        }
    }
    
    public override String getFieldValue()
          {
    	     if(ForCaseList.size() >= 1)
    	       {
        	    ForCase = ForCaseList[0];
        	
        	    	if(ForCase.Approval_Date_gne__c != null)
        	    	{
        	     	return ForCase.Approval_Date_gne__c.format();
        	    	}
        	        else{return '';}                        
                }
            
             else
                {        	
        	     return '';       
                }
           }
}