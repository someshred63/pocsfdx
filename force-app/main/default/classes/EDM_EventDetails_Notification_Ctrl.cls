public without sharing class EDM_EventDetails_Notification_Ctrl {
	public Id eventID {get;set;}

	public EDM_IABP_gne__c getEventDetails(){

		EDM_IABP_gne__c event = [Select id,EDM_Parent_AABP_gne__r.EDM_Group_gne__c,
										   EDM_Parent_AABP_gne__r.EDM_Unit_gne__c,
										   EDM_Year_gne__c,
										   EDM_Team_gne__c,
										   EDM_Primary_AB_Lead_gne__r.Name,
										   EDM_Event_Name_gne__c,
										   EDM_Joint_AABP_gne__c,
										   EDM_End_Date_gne__c
								from EDM_IABP_gne__c where Id =:eventId];

		List<EDM_AABP_gne__c> jointAABP = EDM_IABP_Utils.getJointAABPs(event);

		return event;
	}


	public List<EDM_AABP_gne__c> getOtherAABP(){

		EDM_IABP_gne__c event = [Select id,EDM_Joint_AABP_gne__c from EDM_IABP_gne__c where Id =:eventId];

		return  EDM_IABP_Utils.getJointAABPs(event);

	}


	public EDM_EventDetails_Notification_Ctrl() {
		
	}

}