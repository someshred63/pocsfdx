public with sharing class GNE_SFA2_PFG_TransactionTrigger_Helper 
{
	private static Boolean inTansTrig = false;
  	private static Set<Id> failedValidations = new Set<Id>();
    private static String currentUserProfileName = null;
    
	public static void setTransTrig(Boolean p_inTansTrig) 
	{
		inTansTrig = p_inTansTrig;
	}
	public static Boolean inTansTrig()  
	{
		return inTansTrig;
	}
	public static void clearFailedValidations() 
	{
		failedValidations.clear();
	}
	public static Set<Id> getFailedValidations() 
	{
		return failedValidations;
	}
	public static void setFailedValidation(Id transId) 
	{
		failedValidations.add(transId);
	}
	public static Boolean getFailedValidation(Id transId) 
	{
		return failedValidations.contains(transId);
	}
	public static void removeFailedValidationRecords(List<SFA2_PFG_Transaction_gne__c> transIds) 
	{
		if(!transIds.isEmpty()) 
		{
	    	for(Integer i = transIds.size()-1;i>=0;i--) 
	    	{
	        	if(failedValidations.contains(transIds[i].Id)) 
	        	{
	          		transIds.remove(i);
	        	}
	      	}
	     }
	}
	public static String getCurrentUserProfileName() 
	{
		return GNE_SFA2_Util.getCurrentUserProfileName();
	}
}