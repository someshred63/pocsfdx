public with sharing class GNE_CAN_Subscribe_JobExt 
{
	public Stg_SFA_Subscribe_Apex_Job__c job {get; private set;} 
		
	public GNE_CAN_Subscribe_JobExt(ApexPages.StandardController controller)
	{   
		this.job = (Stg_SFA_Subscribe_Apex_Job__c)controller.getRecord();	
	}	
	
	public PageReference pageOnLoadAction()
	{		
		return null;
	}
	
	
	
}