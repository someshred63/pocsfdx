public with sharing class GNE_SFA2_Medical_Event_Validation_Rules {
	
	
	public static void onBeforeInsert(List<Medical_Event_vod__c> triggerNewList){
		runMedicalEventValidations(triggerNewList);
	}
	
	public static void onBeforeUpdate(List<Medical_Event_vod__c> triggerNewList){
		
		runMedicalEventValidations(triggerNewList);
	}
	
	
	public static void onBeforeDelete(Set<ID> triggerOld,List<Medical_Event_vod__c> triggerOldList){
		
		 runMedicalEventValidations_OnDelete(triggerOld,triggerOldList);
	}
	
	
	
	public static void runMedicalEventValidations(List<Medical_Event_vod__c> triggerNewList){
		
		for(Medical_Event_vod__c medE : triggerNewList){
			if(medE.Start_Date_vod__c!=null && medE.End_Date_vod__c!=null){
				if(medE.Start_Date_vod__c>medE.End_Date_vod__c){
					medE.Start_Date_vod__c.addError(System.Label.StartDateBeforeEndDate);
				}
			}
		}
	}
	
	public static void runMedicalEventValidations_OnDelete(Set<ID> triggerOld,List<Medical_Event_vod__c> triggerOldList){
	
	Map <Id,Medical_Event_vod__c> medMap
	= new Map<Id,Medical_Event_vod__c> (
	[Select Id,
	(Select Id From Call2_Discussion_vod__r LIMIT 1), 
	(Select Id From Call2_vod__r LIMIT 1),
	(Select Id,Signature_Datetime_vod__c From Event_Attendee_vod__r WHERE Signature_Datetime_vod__c != null LIMIT 1) 
	from Medical_Event_vod__c
	where Id in :triggerOld]);
	
	for(Medical_Event_vod__c medEold : triggerOldList){
		Medical_Event_vod__c med = medMap.get(medEold.Id);
		Integer k = 0;
		Integer j = 0;
		
		for (Call2_vod__c cal2 : med.Call2_vod__r) {
			k++;
		}
		
		for (Call2_Discussion_vod__c cal2 : med.Call2_Discussion_vod__r) {
			k++;
		}
		
		for (Event_Attendee_vod__c attendee : med.Event_Attendee_vod__r) {
			j++;
		}
		
		if (k > 0) 
		medEold.addError(System.Label.Cannot_Delete_Object_Call_References);
		
		if (j > 0)
		medEold.addError(System.Label.Signed_Medical_Event_Delete_Lock_Label);
	 }
	}
}