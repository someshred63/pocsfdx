/************************************************************
*  @author: Sebastian Wajrych, Roche
*  Date: 14-September-2010 
*  Description: EDM Monitoring solution
*************************************************************/
public with sharing class GNE_EM3_Monitoring {

	private static final String TRANSACTION_STATUS_SUCCESS = 'Success';
	private static final String TRANSACTION_STATUS_FAILURE = 'Failure';
	private static Set<String> alraedyInserted = new Set<String>();
	/**
	* 
	* A T T E N D E E   L O G G I N G 
	*
	*/
	
	public static void insertEventAttendeeLogSuccess(New_Event_Creation_WS.new_attendee attendee, New_Event_Creation_WS.New_Event newEvent){
		List<New_Event_Creation_WS.new_attendee> attendees = new List<New_Event_Creation_WS.new_attendee>();
		attendees.add(attendee);
		GNE_EM3_Monitoring.insertEventAttendeeLogSuccess(attendees, newEvent);
	}
	
	public static void insertEventAttendeeLogSuccess(List<New_Event_Creation_WS.new_attendee> attendees, New_Event_Creation_WS.New_Event newEvent){
		List<Event_Attendee_Log_gne__c> newEventAttendeeLogs = new List<Event_Attendee_Log_gne__c>(); 
		attendees = unconatenateGlobalTransactionIds(attendees);
		try{
			for(New_Event_Creation_WS.new_attendee attendee : attendees){
				if(!alraedyInserted.contains(attendee.globalTransactionIdentifier)){
					Event_Attendee_Log_gne__c newEventAttendeeLog = new Event_Attendee_Log_gne__c(
						Attendee_Landing_ID_gne__c = Decimal.valueOf(attendee.globalTransactionIdentifier),
						Event_Landing_ID_gne__c = Decimal.valueOf(newEvent.globalTransactionIdentifier),
						Error_Message_gne__c = '',
						First_name_gne__c = attendee.first_name,
						Role_gne__c = attendee.role,
						Last_name_gne__c = attendee.last_name,
						Transaction_Date_gne__c = Date.today(),
						Transaction_Status_gne__c = TRANSACTION_STATUS_SUCCESS
					);
					newEventAttendeeLogs.add(newEventAttendeeLog);
					alraedyInserted.add(attendee.globalTransactionIdentifier);
				}
			}			
			insert(newEventAttendeeLogs);
		} catch(Exception e){
            System.debug('FAILURE CREATING Event_Attendee_Log_gne__c:'+e.getMessage());
        }
        
        System.debug('SW: log to remove XXXXXXXXXXXXXXXXXXXXXXX 46 ' + alraedyInserted);
	}
	
	public static void insertEventAttendeeLogFailure(String message, New_Event_Creation_WS.new_attendee attendee, New_Event_Creation_WS.New_Event newEvent){
		List<New_Event_Creation_WS.new_attendee> attendees = new List<New_Event_Creation_WS.new_attendee>();
		attendees.add(attendee);
		GNE_EM3_Monitoring.insertEventAttendeeLogFailure(message, attendees, newEvent);
	}
	
	public static void insertEventAttendeeLogFailure(String message, List<New_Event_Creation_WS.new_attendee> attendees, New_Event_Creation_WS.New_Event newEvent){
		List<Event_Attendee_Log_gne__c> newEventAttendeeLogs = new List<Event_Attendee_Log_gne__c>();
		attendees = unconatenateGlobalTransactionIds(attendees);
		try{
			for(New_Event_Creation_WS.new_attendee attendee : attendees){
				if(!alraedyInserted.contains(attendee.globalTransactionIdentifier)){
					Event_Attendee_Log_gne__c newEventAttendeeLog = new Event_Attendee_Log_gne__c(
						Attendee_Landing_ID_gne__c = Decimal.valueOf(attendee.globalTransactionIdentifier),
						Event_Landing_ID_gne__c = Decimal.valueOf(newEvent.globalTransactionIdentifier),
						Error_Message_gne__c = message,
						First_name_gne__c = attendee.first_name,
						Role_gne__c = attendee.role,
						Last_name_gne__c = attendee.last_name,
						Transaction_Date_gne__c = Date.today(),
						Transaction_Status_gne__c = TRANSACTION_STATUS_FAILURE
					);
					newEventAttendeeLogs.add(newEventAttendeeLog);
					alraedyInserted.add(attendee.globalTransactionIdentifier);
				}
			}
			insert(newEventAttendeeLogs);
		} catch(Exception e){
            System.debug('FAILURE CREATING Event_Attendee_Log_gne__c:'+e.getMessage());
        }
        
        System.debug('SW: log to remove XXXXXXXXXXXXXXXXXXXXXXX 78 ' + alraedyInserted);
	}

	
	/**
	* 
	* E V E N T    L O G G I N G 
	*
	*/
	
	public static void insertTransactionLogSuccess(New_Event_Creation_WS.New_Event newEvent){
		try{
			Transaction_Log_gne__c newTransactionLog = new Transaction_Log_gne__c(
				Event_Landing_ID_gne__c = Decimal.valueOf(newEvent.globalTransactionIdentifier),
				External_Vendor_ID_gne__c = newEvent.source_system_id,
				Transaction_Date_gne__c = Date.today(),
				Transaction_Status_gne__c = TRANSACTION_STATUS_SUCCESS,
				Error_Message_gne__c = ''
			);
			insert(newTransactionLog);
		} catch(Exception e){
            System.debug('FAILURE CREATING Transaction_Log_gne__c:'+e.getMessage());
        }
	}

	public static void insertTransactionLogFailure(String message, New_Event_Creation_WS.New_Event newEvent){
		try{
			Transaction_Log_gne__c newTransactionLog = new Transaction_Log_gne__c(
				Event_Landing_ID_gne__c = Decimal.valueOf(newEvent.globalTransactionIdentifier),
				External_Vendor_ID_gne__c = newEvent.source_system_id,
				Transaction_Date_gne__c = Date.today(),
				Transaction_Status_gne__c = TRANSACTION_STATUS_FAILURE,
				Error_Message_gne__c = message
			);
			insert(newTransactionLog);
		} catch(Exception e){
            System.debug('FAILURE CREATING Transaction_Log_gne__c:'+e.getMessage());
        }
	}
	
	
	
	/**
	* 
	*     U T I L S    M E T H O D S 
	*
	*/
	
	
	/**
	*	Find concatenated globalTransactionIds and prepare separate new_attendee object for each
	*/
	private static List<New_Event_Creation_WS.new_attendee> unconatenateGlobalTransactionIds(List<New_Event_Creation_WS.new_attendee> attendees){
		Map<String,New_Event_Creation_WS.new_attendee> separatedAttendees = new Map<String,New_Event_Creation_WS.new_attendee>();
		for(New_Event_Creation_WS.new_attendee attendee : attendees){
			system.debug('PP attendee in monitoring: ' + attendee);
			if(attendee.globalTransactionIdentifier != null && attendee.globalTransactionIdentifier.contains(';')){
				List<String> parts = attendee.globalTransactionIdentifier.split(';');
				List<String> roles = attendee.role.split(';');
				for(Integer i = 0; i<parts.size(); i++){
					//New_Event_Creation_WS.new_attendee newAttendee = attendee.clone();
					New_Event_Creation_WS.new_attendee newAttendee = New_Event_Creation_WS.cloneNew_attendee(attendee);
					newAttendee.globalTransactionIdentifier = parts[i];
					newAttendee.role = roles[i];
					separatedAttendees.put(newAttendee.globalTransactionIdentifier, newAttendee);
				}

			}else{
				separatedAttendees.put(attendee.globalTransactionIdentifier, attendee);
			}
		}
		System.debug('SW:Log to remove XXXXXXXXXXXXXXXXXXXXX '+separatedAttendees);
		return separatedAttendees.values();
	}

}