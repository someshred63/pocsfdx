global class EM3_PopulateSpeakersNameBatch implements Database.Batchable<sObject> {

	global EM3_PopulateSpeakersNameBatch(){
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC){
    	return Database.getQueryLocator('Select me.Aprimo_Event_ID_gne__c,me.parent_medical_event_gne__c From Medical_Event_vod__c me where me.parent_medical_event_gne__c = null');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	for(Medical_Event_vod__c medicalEvent : (List<Medical_Event_vod__c>)scope){
    	
    		String aprimoEventId = medicalEvent.Aprimo_Event_ID_gne__c;
    		
	    	//collect locations
	    	List<Medical_Event_vod__c> locations = [Select ID,Speakers_Name_gne__c from Medical_Event_vod__c me where me.parent_medical_event_gne__c != null and me.Aprimo_Event_ID_gne__c=:aprimoEventId];
	    	
	    	//get list of attendees
	    	Map<String,List<Event_Attendee_vod__c>> eventAttendees = new Map<String,List<Event_Attendee_vod__c>>(); 
	    	for(Event_Attendee_vod__c attendee : [Select e.Role_gne__c, e.Account_vod__c, e.Account_vod__r.Name, e.Contact_vod__c, e.Contact_vod__r.Name, e.Medical_Event_vod__c, e.Medical_Event_vod__r.Id, e.User_vod__c, e.User_vod__r.Name 
	    											from 
	    												Event_Attendee_vod__c e 
	    											where 
	    												e.Medical_Event_vod__c IN :locations
	    												and e.Role_gne__c includes ('Speaker')]){
	 		   	if(!eventAttendees.keySet().contains(attendee.Medical_Event_vod__r.Id)){
	            	eventAttendees.put(attendee.Medical_Event_vod__r.Id, new List<Event_Attendee_vod__c>());                                                           
	            } 
	 		   	eventAttendees.get(attendee.Medical_Event_vod__r.Id).add(attendee);
	    	}
	    	
	    	for(Medical_Event_vod__c location : locations){
	    		
				List<Event_Attendee_vod__c> selectedEventAttendees = eventAttendees.get(location.ID);
				if(selectedEventAttendees != null){
					location.Speakers_Name_gne__c = '';
					for(Event_Attendee_vod__c selectedAttendee : selectedEventAttendees){
						String attendeeName = '';
						if(selectedAttendee.Contact_vod__c != null){
							attendeeName = selectedAttendee.Contact_vod__r.Name;
						}
						if(selectedAttendee.User_vod__c != null){
							attendeeName = selectedAttendee.User_vod__r.Name;
						}
						if(selectedAttendee.Account_vod__c != null){
							attendeeName = selectedAttendee.Account_vod__r.Name;
						}
						String toCheckSize = location.Speakers_Name_gne__c + attendeeName; 
						if(toCheckSize.length()+3>255){
							location.Speakers_Name_gne__c = location.Speakers_Name_gne__c + '...';
							break;
						}
						
						if(location.Speakers_Name_gne__c == null || location.Speakers_Name_gne__c == ''){
							location.Speakers_Name_gne__c = attendeeName;
						}else{
							location.Speakers_Name_gne__c = location.Speakers_Name_gne__c + '; '+ attendeeName; 
						}
					}
				}
				 
	    	}
	    	
	    	upsert(locations);
    	}
    }
    
    global void finish(Database.BatchableContext BC){
    }

}