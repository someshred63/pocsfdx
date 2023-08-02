public class EM3_recal_speaker_gne {
	
	public static void insertSpeakers(List<Event_Attendee_vod__c> eaList){
		
		//map to hold event to account speaker
        Map<ID,ID> event_to_spkrMap = new Map<ID,ID>();
		
		set<ID> events = new set<ID>();		
                                                                                     		
		for(Event_Attendee_vod__c attendee : eaList){
			events.add(attendee.Medical_Event_vod__c);
			//for attendee's that are accounts and speakers put them in the map that holds
	        //the event and the account
	        if(attendee.Account_vod__c != null && attendee.role_gne__c.contains('Speaker')){
	           	event_to_spkrMap.put(attendee.medical_event_vod__c, attendee.account_vod__c);
	        }
		}
		
		//creates a list of all events related to this trigger
        List<Medical_Event_vod__c> events_list = [select ID, Speaker_gne__c, Name, start_date_vod__c, 
        end_date_vod__c, Event_Type_gne__c from Medical_Event_vod__c 
        where ID IN :events];
        
        //to hold events to be updated
        List<Medical_Event_vod__c> evtsToUpdate = new List<Medical_Event_vod__c>();
                
        //for all events related to new attendees, if the speaker field is empty
        //if the map of events to accounts who are speakers contains the current event
        //fill the speaker field and add it to the list to update
        for(Medical_Event_vod__c evt : events_list){
        	if(evt.Speaker_gne__c == null ){
        		if(event_to_spkrMap.containsKey(evt.id)){
        			evt.Speaker_gne__c = event_to_spkrMap.get(evt.id);
        			evtsToUpdate.add(evt);
        		}
        	}
        }
        
        //update event speakers
        try{
        	update(evtsToUpdate);
        }catch(DmlException e){System.debug(e.getMessage());}
	}
	
	public static void updateSpeakers(List<Event_Attendee_vod__c> eaList){
		//to hold accounts that have been deleted
    	set<ID> updatedAccts = new set<ID>();
    	//to hold all related events for event attendees that have been updated
    	set<ID> relEvents = new set<ID>();
    	
    	//for all updated attendees keep track of the attendes and related events for those who were accounts and speakers
		for(Event_Attendee_vod__c ea : eaList){
        	if(ea.Account_vod__c != null){
        		updatedAccts.add(ea.Account_vod__c);
        		relEvents.add(ea.Medical_Event_vod__c);
            	system.debug('DELETED:'+ea);
        	}                	
        }
        
        //retrieve all related medical events for those event attendees updated
	    Map<ID,Medical_Event_vod__c> relEventsMap = new Map<ID,Medical_Event_vod__c>([select id, Speaker_gne__c from Medical_Event_vod__c where id IN :relEvents]);
	    	    
	    List<Medical_Event_vod__c> posReCal = new List<Medical_Event_vod__c>();
	    
	    for(Medical_Event_vod__c evt : relEventsMap.values()){
	    	if(evt.speaker_gne__c == null){
	    		posReCal.add(evt);
	    	}else{
	    		for(Event_Attendee_vod__c ea : eaList){
	    			if(evt.Speaker_gne__c == ea.Account_vod__c && !ea.Role_gne__c.contains('Speaker')){
	    				posReCal.add(evt);	    				
	    			}
	    		}
	    	}
	    }
	    
	    List<Event_Attendee_vod__c> relAtt = [select ID, Medical_Event_vod__c, Account_vod__c, Role_gne__c from Event_Attendee_vod__c where Medical_Event_vod__c IN :posReCal and (Account_vod__c != null and Role_gne__c = 'Speaker') ];
					    
	    List<Medical_Event_vod__c> toUpdate = new List<Medical_Event_vod__c>();
	    	    
    	for(Event_Attendee_vod__c ea : relAtt){	    		
    		if(relEventsMap.containsKey(ea.Medical_Event_vod__c)){
    			Medical_Event_vod__c tempEvt = relEventsMap.get(ea.Medical_Event_vod__c);
    			tempEvt.speaker_gne__c = ea.Account_vod__c;
    			toUpdate.add(tempEvt);
    			relEventsMap.remove(tempEvt.id);
    		}
    	}
	    
	    try{
	    	update(toUpdate);
	    }catch(DmlException e){system.debug(e.getMessage());}
	}
	
	public static void recalSpeakers(List<Event_Attendee_vod__c> eaList){
		//to hold accounts that have been deleted
    	set<ID> deletedAccts = new set<ID>();
    	//to hold all related events for event attendees that have been deleted
    	set<ID> relEvents = new set<ID>();
    	
    	//for all deleted attendees keep track of the attendes and related events for those who were accounts and speakers
        for(Event_Attendee_vod__c ea : eaList){
        	if(ea.Account_vod__c != null && ea.Role_gne__c.contains('Speaker')){
        		deletedAccts.add(ea.Account_vod__c);
        		relEvents.add(ea.Medical_Event_vod__c);
            	system.debug('DELETED:'+ea);
        	}                	
        }               
        
        //retrieve all related medical events for those event attendees deleted
        //Map<ID,Medical_Event_vod__c> relEventsMap = new Map<ID,Medical_Event_vod__c>();//[select id, Speaker_gne__c from Medical_Event_vod__c where id IN :relEvents]);
        //system.debug('relEventsMap:'+relEventsMap);
        
        //to hold medical events which need to be recalibrated
        set<ID> reCal = new set<ID>();
        
        //for all deleted attendees check if the related event's speaker field was populatd by this attendee speaker
        //if so put the event in a list
        for(event_Attendee_vod__c ea : eaList){        	
        	if(ea.Account_vod__c != null && ea.Role_gne__c.contains('Speaker')){
        		if(ea.Speaker_Field_gne__c == 'True'){
        			reCal.add(ea.Medical_Event_vod__c);        			
        		}
        		/*if(relEventsMap.get(ea.Medical_Event_vod__c).Speaker_gne__c != null){
        			if(relEventsMap.get(ea.Medical_Event_vod__c).Speaker_gne__c == ea.Account_vod__c){
            			reCal.add(ea.Medical_Event_vod__c);
            		}
        		}*/	                	
        	}
        }
        System.debug('reCal:'+reCal);
		
		Map<ID,Medical_Event_vod__c> relEventsMap = new Map<ID,Medical_Event_vod__c>(
		[select 
			id, 
			Speaker_gne__c, 
			(select 
				ID, 
				Account_vod__c, 
				Medical_Event_vod__c 
			from 
				Event_Attendee_vod__r 
			where 
				(Medical_Event_vod__c IN :reCal) AND (Role_gne__c includes ('Speaker')) AND (Account_vod__c != null)
			) 
		from 
			Medical_Event_vod__c 
		where 
			id IN :relEvents]);
		        
        //retrieve all event attendees who are speakers and are accounts that are apart of those events that no longer have a speaker
        List<Event_Attendee_vod__c> replacementAtt = new List<Event_Attendee_vod__c>();
        for(ID evt : relEventsMap.keySet()){
        	if(!relEventsMap.get(evt).Event_Attendee_vod__r.isEmpty()){
        		for(Event_Attendee_vod__c relAttendee : relEventsMap.get(evt).Event_Attendee_vod__r){
        			replacementAtt.add(relAttendee);
        		}
        	}
        }
        
        //List<Event_Attendee_vod__c> replacementAtt = [select ID, Account_vod__c, Medical_Event_vod__c from Event_Attendee_vod__c where Medical_Event_vod__c IN :reCal AND (Role_gne__c = 'Speaker' AND Account_vod__c != null)];
        system.debug('replacementAtt:'+replacementAtt);
        
        //to hold all events to update speakers for
        List<Medical_Event_vod__c> evtsUpdate = new List<Medical_Event_vod__c>();
        
        if(!replacementAtt.isEmpty()){                
            //to hold event id's mapped to there new account speaker
            Map<ID,ID> repMap = new Map<ID,ID>();
            
            //for all events that need a speaker go through the related attendees and find an attendee for the same event and put them
            //in the map.  Only one is needed 
            for(ID eventID : reCal){                	
        		for(Event_Attendee_vod__c att : replacementAtt){
        			if(att.Medical_Event_vod__c == eventID){
        				repMap.put(eventID,att.Account_vod__c);
        				break;
        			}
        		}                	
            }
            
            system.debug('repMap:'+repMap);	                	                
            
            //for all events to be recalibrated retrieve the related account and update the event and put them in the previously
            //created list
            for(ID eventKey : repMap.keySet()){                	
            	Medical_Event_vod__c fixedEvent = relEventsMap.get(eventKey);
            	fixedEvent.Speaker_gne__c = repMap.get(eventKey);
            	evtsUpdate.add(fixedEvent);
            }
            
            system.debug('evtsUpdate:'+evtsUpdate);
        }else{                	
        	 for(ID eventID : reCal){
        	 	Medical_Event_vod__c tempEvt = relEventsMap.get(eventID);
        	 	tempEvt.speaker_gne__c = null;                	
        	 	evtsUpdate.add(tempEvt);	            		  	
            }
            system.debug('evtsUpdate:'+evtsUpdate);
        }   
            //update the events
            try{
            	update(evtsUpdate);
            }catch(DmlException e){system.debug(e.getMessage());}
	}
}