/* This class checks the valdiation rules on Event_Attendee_vod__c object . 


*/

public with sharing class GNE_SFA2_Event_Attendee_Validation_Rules {
	
	
	
	public static void onBeforeInsert(List<Event_Attendee_vod__c> triggerNewList){
		runEventAttendeeValidations(triggerNewList);
		
	}
	
	public static void onBeforeUpdate(List<Event_Attendee_vod__c> triggeroldList,List<Event_Attendee_vod__c> triggerNewList){
		runEventAttendeeValidations(triggerNewList);
		
	}
	
	public static void onBeforeDelete(List<Event_Attendee_vod__c> TriggerOldEvents){
		
		for (Event_Attendee_vod__c attendee : TriggerOldEvents) {
        if (attendee.Signature_Datetime_vod__c != null){
            attendee.addError(System.Label.Signed_Attendee_Delete_Lock_Label);
         //   return;
        }
     }
		
  }
	
	
	
	public static void runEventAttendeeValidations(List<Event_Attendee_vod__c> trigger_New){
		
	  for(Event_Attendee_vod__c event : trigger_New){
	  	
	  	//make sure one of the fields Account, contact or User is selected 
	  	
	  	if(event.Account_vod__c==null)
	  	{
	  		if(event.Contact_vod__c==null)
	  		{
	  			if(event.User_vod__c==null)
	  			{
	  			   event.addError(System.Label.Account_Contact_User_Required);	
	  			   //continue;
	  			}
	  			
	  			
	  		}
	  	}
	  	
	  	//Make sure only one of Account,Contact or User is selected . 
	  	
	  	if(event.Account_vod__c !=null){
	  		
	  		if((event.Contact_vod__c!=null) || (event.User_vod__c!=null)){
	  			
	  		 event.addError(System.Label.OnlyOne_Account_Contact_User);
	  		 //continue;
	  			
	  		}
	  	}
	  	
	  	else if(event.Contact_vod__c !=null){
	  		
	  		if((event.Account_vod__c!=null) || (event.User_vod__c!=null)){
	  			
	  		 event.addError(System.Label.OnlyOne_Account_Contact_User);
	  		 //continue;
	  			
	  		}
	  	}
	  	else if(event.User_vod__c !=null){
	  		
	  		if((event.Contact_vod__c!=null)|| (event.Account_vod__c!=null)){
	  			
	  		 event.addError(System.Label.OnlyOne_Account_Contact_User);
	  		 //continue;
	  			
	  		}
	  	}
	  }
	}// end of method runEventAttendeeValidations
  

}