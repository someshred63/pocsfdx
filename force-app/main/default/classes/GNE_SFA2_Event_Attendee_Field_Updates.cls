public with sharing class GNE_SFA2_Event_Attendee_Field_Updates {
	
	
  
  public static void onBeforeInsert(List<Event_Attendee_vod__c> TriggerBeforeInsert){
  	
 	 EventAttendeeBeforeFieldUpdates(TriggerBeforeInsert);
  	
  }
  
  public static void onBeforeUpdate(List<Event_Attendee_vod__c> TriggerOldBeforeUpdate,List<Event_Attendee_vod__c> TriggerNewBeforeUpdate){
  	
  	EventAttendeeBeforeFieldUpdates(TriggerNewBeforeUpdate);
  	
  }
  
  
 public static void EventAttendeeBeforeFieldUpdates(List<Event_Attendee_vod__c> eventList){
	
	Set<String> accountIds = new Set<String>();
	Set<String> contactIds = new Set<String>();
	Set<String> userIds = new Set<String>();
	
	for(Event_Attendee_vod__c event : eventList){
		
		if(event.Account_vod__c!=null){
			accountIds.add(event.Account_vod__c);
		}
		else if(event.Contact_vod__c !=null){
			contactIds.add(event.Contact_vod__c);
		}
		
		else if(event.user_vod__c!=null){
			userIds.add(event.user_vod__c);
		}
	}
	
	Map<ID,Account> accounts = null;
	if (accountIds.size() > 0) {
		accounts = new Map<ID,Account>([Select Id,Name From Account Where Id In :accountIds]);
	}
	Map<ID,Contact> contacts = null;
	if (contactIds.size() > 0) {
		contacts = new Map<ID,Contact>([Select Id,Name From Contact Where Id In :contactIds]);
	}
	
	Map<ID,User> users = null;
	if (userIds.size() > 0) {
		users = new Map<ID,User>([Select Id,Name From User Where Id In :userIds]);
	}

	
	
	
	
	for(Event_Attendee_vod__c event : eventList){
		String attendeeName = '';
		
		if(event.Account_vod__c !=null){
			Account acct = accounts.get(event.Account_vod__c);
			
			if (acct != null)
			attendeeName = acct.Name;
		}
		
		else if(event.Contact_vod__c !=null){
			Contact cont = contacts.get(event.Contact_vod__c);
			
			if (cont!= null)
			attendeeName = cont.Name;
		}
		
		else if(event.User_vod__c !=null){
			User user = users.get(event.user_vod__c);
			
			if (user!= null)
			attendeeName = user.Name;
		}
		
		event.Attendee_vod__c=attendeeName;
	}
	
}

	
	
	

}