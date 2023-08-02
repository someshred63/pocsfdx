/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-03
*  Description: This is a helper class for handling Contact field updates
*  Test class: GNE_SFA2_Contact_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Contact_Field_Updates {
	
	/* Works in conjunction with the GNE_Last_Interaction_Update trigger on the Call object preventing
	any update to the field with a older date as the Calls are blindly trying to load in their dates. 
	This trigger ensures the Last Interaction Date remains in the Last Interaction Date field. */
	private static void updateLastInteractionDates(List<Contact> triggerOld, List<Contact> triggerNew) {
		for (Integer i = 0; i < triggerNew.size(); i++) {

	       Contact newContact = triggerNew[i];
	       Contact oldContact = triggerOld[i];
	
	       if (newContact.MCL_Last_Interaction_Date_gne__c < oldContact.MCL_Last_Interaction_Date_gne__c) {
	           newContact.MCL_Last_Interaction_Date_gne__c = oldContact.MCL_Last_Interaction_Date_gne__c;
	       }
	       if (newContact.PFT_Last_Interaction_Date_gne__c < oldContact.PFT_Last_Interaction_Date_gne__c){
	           newContact.PFT_Last_Interaction_Date_gne__c = oldContact.PFT_Last_Interaction_Date_gne__c;
	       }
		}
	}  

	private static void updateOptOutDate(List<Contact> triggerOld, List<Contact> triggerNew){
		for (Integer i = 0; i < triggerNew.size(); i++) {

			Contact newContact = triggerNew[i];
			Contact oldContact = triggerOld[i];

			if (newContact.Has_Opted_Out_Date_gne__c == oldContact.Has_Opted_Out_Date_gne__c && newContact.Has_Opted_Out_gne__c && !oldContact.Has_Opted_Out_gne__c) {
			   newContact.Has_Opted_Out_Date_gne__c = Datetime.now();
			}
		}
	}
	
	public static void onBeforeUpdate(List<Contact> triggerOld, List<Contact> triggerNew) {
		if(!GNE_SFA2_Util.isMergeMode()){
			updateLastInteractionDates(triggerOld, triggerNew);
			updateOptOutDate(triggerOld, triggerNew);
		}
	}

	public static void onAfterInsert(List<Contact> triggerNew){
		if(triggerNew.size() == 1 && !System.isBatch() && !System.isFuture() && triggerNew[0].Has_Opted_Out_gne__c != null && !triggerNew[0].Has_Opted_Out_gne__c){
			checkOptOutForEmail(triggerNew[0].Id, triggerNew[0].Email);
		}
	}

	@future(callout=true)
	private static void checkOptOutForEmail(Id contactId, String emailAddress){
		try{
			String dateTimeString = GNE_SFA2_CAN_SPAM_Get_Opt_Out.getOptOutForEmail(emailAddress);
			if(String.isNotBlank(dateTimeString)){
				Contact cont = [SELECT Id, Has_Opted_Out_gne__c, Has_Opted_Out_Date_gne__c FROM Contact WHERE Id = :contactId LIMIT 1];
				DateTime optOutDate = DateTime.valueofGmt(dateTimeString.replace('T', ' ').replace('Z', ' '));
				cont.Has_Opted_Out_gne__c = true;
				cont.Has_Opted_Out_Date_gne__c = optOutDate;
				update cont;
			}
		}catch(Exception ex){
			system.debug(ex);
		}
	}


}