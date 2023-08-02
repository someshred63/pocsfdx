//Created By :Prabha

public class SCM_MF_BI_DenialReason extends SCM_MergeField{
	
	protected Benefit_Investigation_gne__c caseDenReason;
	List<Benefit_Investigation_gne__c> caseDenReasonList;
	List<Benefit_Investigation_gne__c> caseDeniedList;
	List<Benefit_Investigation_gne__c> caseDeniedModiByDescList;
	
	public SCM_MF_BI_DenialReason(String caseID)
	{
		key = 'DenialReason';
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		displayLabel = false;
		IsRequired = false;
 
		className = 'SCM_MF_BI_DenialReason';
		try
        {
		caseDenReasonList = [Select b.LastModifiedDate, b.Denial_Reason_gne__c, b.BI_BI_Status_gne__c 
        		From Benefit_Investigation_gne__c b 
                WHERE b.Case_BI_gne__r.Id = :caseID ];
        caseDeniedList = [Select b.LastModifiedDate, b.Denial_Reason_gne__c, b.BI_BI_Status_gne__c 
        		From Benefit_Investigation_gne__c b 
                WHERE b.Case_BI_gne__r.Id = :caseID and b.BI_BI_Status_gne__c = 'Denied' ];
		caseDeniedModiByDescList = [Select b.LastModifiedDate, b.Denial_Reason_gne__c, b.BI_BI_Status_gne__c 
        		From Benefit_Investigation_gne__c b 
                WHERE b.Case_BI_gne__r.Id = :caseID and b.BI_BI_Status_gne__c = 'Denied' Order by b.LastModifiedDate Desc ];
       
	        this.fieldValue = getFieldValue();
        }
        catch(Exception ex)
        {
        	this.fieldValue = '';
	    }
	}
	public override String getFieldValue()
  	{   if(caseDenReasonList.size() == 0)
  		{
  			return '';
  		}
  		else if(caseDenReasonList.size() == 1)
  		{
  			caseDenReason = caseDenReasonList[0];
  			return caseDenReason.Denial_Reason_gne__c;
  		}
  		else 
        {
            if(caseDeniedList.size() == 0)
  			{
  				return '';
  			}
  			else if(caseDeniedList.size() == 1)
  			{
  				caseDenReason = caseDeniedList[0];
  				return caseDenReason.Denial_Reason_gne__c;
  			}
  			else 
  			{
  				caseDenReason = caseDeniedModiByDescList[0];
  				return caseDenReason.Denial_Reason_gne__c;
            }
        }
    }
}