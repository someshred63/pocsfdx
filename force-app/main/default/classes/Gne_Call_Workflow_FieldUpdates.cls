/************************************************************
*  @author: Sreedhar karukonda
*  Date: 12/31/2012 
*  Description: Gne_Call_Workflow_FieldUpdates is class created to migrate Workflow field updates from Call2_vod__c workflows to Trigger WorkFlowFieldUpdates_to_Trigger.
*  Reason for this migration: As part of SFA2 Force.com project, validation rules moved to tigger, Workflow Field Updates invoke triggers but not Validation rules. So, Workflow field updates are moved to Before triggers.
*  Migrated Workflow Names:
*  	1. Completed Interaction
*  	2. Planned Interaction
*  	3. Removing Completed checkbox
*  	4. AssignMedAffairsnteractionRecordType
*  	5. Set In Office Interaction Location for FRM profiles
*  Disable above Workflow rules before deploying Trigger "WorkFlowFieldUpdates_to_Trigger" and Class "Gne_Call_Workflow_FieldUpdates"
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class Gne_Call_Workflow_FieldUpdates {
	
	// On Before insert method
	public static void OnBeforeInsert (Map<Id,Call2_vod__c> oldCallMap,  List<Call2_vod__c> newCallList){
		completedInteraction(null, newCallList);
		plannedInteraction(null, newCallList);
		removeCompletedCheckbox(null, newCallList);
		assignMedAffairsInteractionRecordType(null, newCallList);
		//setInOfficeInteractionLocationforFRMprofiles(null, newCallList);
	}
	// On Before update method
	public static void OnBeforeUpdate (Map<Id,Call2_vod__c> oldCallMap,  List<Call2_vod__c> newCallList){
		completedInteraction(oldCallMap, newCallList);
		removeCompletedCheckbox(oldCallMap, newCallList);
		assignMedAffairsInteractionRecordType(null, newCallList);
		//setInOfficeInteractionLocationforFRMprofiles(null, newCallList);
	}
	
	private static ID medAffairInteractionID{ 
		get{
			if(medAffairInteractionID == null) Map<ID, RecordType> temp = medAffairRecordTypes;
			return medAffairInteractionID;
		}
		set;
	 }
	private static Map<ID, RecordType> medAffairRecordTypes{
		get{
			if(medAffairRecordTypes == null){
				medAffairRecordTypes = new Map<ID, RecordType>([select Id, Name from RecordType where name in ('MedAffairs Interaction', 'MedAffairs Planned Interaction') and SObjectType='Call2_vod__c']);
				for(RecordType recType: medAffairRecordTypes.values()){
					if(recType.Name =='MedAffairs Interaction'){
						medAffairInteractionID = recType.ID;
						break;
					}
				}
			}
			return medAffairRecordTypes;
		}
		set; 
	}
	
	// Implemented Based on Workflow Completed Interaction (before insert, before update)
	private static void completedInteraction(map<id, Call2_vod__c> oldCallMap, List<Call2_vod__c> newCalls){
		for(Call2_vod__c call: newCalls){
			if(call.Completed_gne__c == true){
				call.Interaction_Status_gne__c = 'Completed';
			}
		}
	}
	
	// Implemented Based on Workflow Planned Interaction (before insert)
	private static void plannedInteraction(map<id, Call2_vod__c> oldCallMap, List<Call2_vod__c> newCalls){
		for(Call2_vod__c call: newCalls){
			if(call.Interaction_Status_gne__c == null && call.Completed_gne__c != true){
				call.Interaction_Status_gne__c = 'Planned';
			}
		}
	}
	
	// Implemented Based on Workflow Removing Completed checkbox (before insert, before update)
	private static void removeCompletedCheckbox(map<id, Call2_vod__c> oldCallMap, List<Call2_vod__c> newCalls){
		//(Call: Completed? EQUALS False) AND (Call: Interaction StatusEQUALSCompleted)
		for(Call2_vod__c call: newCalls){
			if(call.Completed_gne__c == false && call.Interaction_Status_gne__c == 'Completed'){
				call.Interaction_Status_gne__c = 'Planned';
			}
		}
	}
	
	// Implemented Based on Workflow assignMedAffairsInteractionRecordType (before insert, before update)
	private static void assignMedAffairsInteractionRecordType(map<id, Call2_vod__c> oldCallMap, List<Call2_vod__c> newCalls){
		//((Call: Record Type EQUALS MedAffairs Interaction) OR (Call: Record Type EQUALS MedAffairs Planned Interaction)) AND (Call: Completed? EQUALS True)
		for(Call2_vod__c call: newCalls){
			if( medAffairRecordTypes.containsKey(call.RecordTypeId) && call.Completed_gne__c == true){
				if(medAffairInteractionID == null) call.addError('MedAffairs Interaction Record Type is not created for Call2_vod__c');
				else call.RecordTypeId = medAffairInteractionID;
			}
		}
	}
	
	// Implemented Based on Workflow Set In Office Interaction Location for FRM profiles (before insert, before update)
	/*private static void setInOfficeInteractionLocationforFRMprofiles(map<id, Call2_vod__c> oldCallMap, List<Call2_vod__c> newCalls){
		
		Set<String> frmProfilesSet = GNE_SFA2_FRM_Profiles_prefixes_gne__c.getAll().keySet();
		String userProfileName = [Select name from Profile where id =:Userinfo.getProfileId() limit 1].name;
		for(String profilePrefix : frmProfilesSet){
			if(userProfileName.contains(profilePrefix)){
				for(Call2_vod__c call: newCalls){
					call.Interaction_location_gne__c = 'Face to Face: In Office';
				}
				break;
			}
		}
	}*/

}