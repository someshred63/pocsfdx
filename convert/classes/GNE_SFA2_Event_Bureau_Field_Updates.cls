public with sharing class GNE_SFA2_Event_Bureau_Field_Updates {
	
	
	public static void onBeforeInsert(List<Event_Bureaus_gne__c> triggerNewList){
		
		 set<ID> related_events_set = new set<ID>(); 
		 for(Event_Bureaus_gne__c eb : triggerNewList){ 
		 	
		 	related_events_set.add(eb.Medical_Event_gne__c);
		 }
		 
		 Map<ID,Medical_Event_vod__c> ID_to_Events = New Map<ID,Medical_Event_vod__c>([select ID, Status_gne__c, Event_Type_gne__c,
                                                    Brands_gne__c, Indications_gne__c, Parent_Site_gne__c from Medical_Event_vod__c where ID IN :related_events_set]);

     //Iterate over the event bureuas in the trigger.new list and populate the event_type_gne__c & 
     //event_status_gne__c fields
     
     
       for(Event_Bureaus_gne__c eb : triggerNewList){
       	
       	
        if(ID_to_Events.get(eb.Medical_Event_gne__c).Event_Type_gne__c != null){
            eb.Parent_Site_gne__c = ID_to_Events.get(eb.Medical_Event_gne__c).Parent_Site_gne__c;
            eb.Event_Type_gne__c = ID_to_Events.get(eb.Medical_Event_gne__c).Event_Type_gne__c;         
            eb.Event_Status_gne__c = ID_to_Events.get(eb.Medical_Event_gne__c).Status_gne__c;
            eb.Brands_gne__c = ID_to_Events.get(eb.Medical_Event_gne__c).Brands_gne__c;
            eb.Indications_gne__c = ID_to_Events.get(eb.Medical_Event_gne__c).Indications_gne__c;    
        }
       }
	}
}