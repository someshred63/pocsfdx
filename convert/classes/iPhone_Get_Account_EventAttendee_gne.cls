/*******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of EventAttendees for the specified accounts.             
********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountEventAttendees/*')
global with sharing class iPhone_Get_Account_EventAttendee_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountEventAttendeeResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, accountIds)    		
    	);     	    	    	    	
    } 
    
    class GetAccountEventAttendeeResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {   
		
		protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getEventAttendeesByAccountIds(args.accountIds);    		  
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountEventAttendeeRecord((Event_Attendee_vod__c)sObj); 		    		
    	}     	 	    	
    }
    			
	class GetAccountEventAttendeeRecord extends iPhone_Commons_gne.DeltaRecord {
		public String ai; // (accountId)	
		public String nm; // (name)
		public String st; // (status)
		public String rl; // (role list)
		public String wi; // (willing to interact)
		public String dd; // (departure date)
		public String at; // (attendee type)
		public String it; // (interaction type)
		public String me; // (medical event name)
		public String ad; // (arrival date)	
		public String es; //Event Status
		public String et; //Event Type
		public String est; //Event SubType
		public String ed; //Event Date
		public String etm; //Event Timing
		public String emt; //Event Setting
		public String el; //Event Location
		public String mc; //HCP Attendee GNE Meal Consumption
		public String eid; //Event ID
		public String tmz; //Timezone
		public String stm; //Start_Time_gne__c
					
		public GetAccountEventAttendeeRecord(Event_Attendee_vod__c eventAttendee) {						
			this.id = eventAttendee.id;  																	
			this.ai = eventAttendee.Account_vod__c;											
			this.nm = eventAttendee.Name; 													
			this.st = iPhone_StringUtil.getString(eventAttendee.Status_vod__c); 			
			this.rl = iPhone_StringUtil.getString(eventAttendee.Role_gne__c); 				
			this.wi = iPhone_StringUtil.getString(eventAttendee.Willing_to_Interact_gne__c);
			this.dd = iPhone_StringUtil.getStringDate(eventAttendee.Departure_Date_gne__c); 	
			this.at = iPhone_StringUtil.getString(eventAttendee.Attendee_Type_vod__c); 		
			this.it = iPhone_StringUtil.getString(eventAttendee.Interaction_type_gne__c); 	
			this.me = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.Name); 
			this.ad = iPhone_StringUtil.getStringDate(eventAttendee.Arrival_Date_gne__c);

			this.es = iPhone_StringUtil.getString(eventAttendee.Event_Status_gne__c);
			this.et = iPhone_StringUtil.getString(eventAttendee.Event_Type_gne__c);
			this.est = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.Event_Sub_Type_Code_gne__c);
			this.ed = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.Start_Date_vod__c);
			this.etm = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.timing_gne__c);
			this.emt = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.event_medium_type_gne__c);
			this.el = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.Location_gne__c);
			this.mc = iPhone_StringUtil.getString(eventAttendee.Meal_Consumption_Status_gne__c);														
			this.eid = iPhone_StringUtil.getString(eventAttendee.Event_ID_gne__c);
			this.tmz = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.Time_Zone_gne__c);
			this.stm = iPhone_StringUtil.getString(eventAttendee.Medical_Event_vod__r.Start_Time_gne__c);
		}   
	} 
}