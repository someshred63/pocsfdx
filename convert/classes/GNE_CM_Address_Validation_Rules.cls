public with sharing class GNE_CM_Address_Validation_Rules
{	
	public static void onBeforeUpdate (List<Address_vod__c> triggerOld, List<Address_vod__c> triggerNew)
	{   
		if(!GNE_SFA2_Util.isMergeMode()) { 
			Set<Id> addressIds = new Set<Id>();
			for (Address_vod__c address : triggerNew)
			{
				addressIds.add(address.Id);
			}
	        
	        Set<Id> addressesWithActiveCases = new Set<Id>();
	        
	        // get active or recently closed cases associated with the updated addresses
	  		// and from that build a set of addresses associated with active cases
	        for (Case c : [SELECT Id, Address_gne__c FROM Case WHERE Address_gne__c IN :addressIds AND (Status = 'Active' OR ClosedDate >: DateTime.now().addYears(-1))])
	        {	
	        	addressesWithActiveCases.add(c.Address_gne__c);
	        }	
	        
	        // check every updated address
	        for (Address_vod__c address : triggerNew)
	        {
	        	// prevent setting inactive status on address that is associated with an active/recently closed case
	        	if (addressesWithActiveCases.contains(address.Id) && address.Status_gne__c == 'Inactive')
	        	{
	            	address.Status_gne__c.addError(System.Label.Address_cannot_be_inactive_while_has_case_assigned);
	            	GNE_SFA2_Address_Trigger_Helper.setFailedValidation(address.Id);
	            }       
	        }
		}	
	}
	
}