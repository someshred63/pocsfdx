trigger GNE_SFA2_Event_Curriculum_Trigger on Event_Curriculum_gne__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
    if(!GNE_SFA2_Util.isAdminMode()){
   	    if(Trigger.isBefore && Trigger.isInsert){
   	  	   	GNE_SFA2_Event_Curriculum_Field_Updates.onBeforeInsert(trigger.New);
   	   	} else if(Trigger.isBefore && Trigger.isUpdate){
            GNE_SFA2_Event_Curriculum_Field_Updates.onBeforeUpdate(trigger.New);
   	    } else if(Trigger.isBefore && Trigger.isDelete){
            GNE_SFA2_Curriculum_Child_Records_Update.deleteOrphanedEventCuriculumJoins(trigger.oldMap.keySet());
            GNE_SFA2_Curriculum_Child_Records_Update.deleteOrphanedSpeakerTrainings(trigger.oldMap.keySet());
        }
    }
}