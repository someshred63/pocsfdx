trigger EDM_IABP_Trigger on EDM_IABP_gne__c (after delete, after insert, after undelete, after update, 
												before delete, before insert, before update) {
    if (!GNE_SFA2_Util.isAdminMode() /*&& !GNE_SFA2_Util.isTriggerDisabled('EDM_IABP_gne__c')*/) {
    
        if (Trigger.isBefore && Trigger.isInsert){
            EDM_IABP_Trigger_Helper.onBeforeInsert(Trigger.old,Trigger.new);
        } 
        else if(Trigger.isBefore && Trigger.isUpdate) {
        	EDM_IABP_Trigger_Helper.onBeforeUpdate(Trigger.old,Trigger.newMap);
        } 
        else if(Trigger.isAfter && Trigger.isDelete) {
            EDM_IABP_Trigger_Helper.onAfterDelete(Trigger.oldMap);
        } 
        else if(Trigger.isAfter && Trigger.isInsert) {
            EDM_IABP_Trigger_Helper.onAfterInsert(Trigger.old,Trigger.new);
        } 
        else if(Trigger.isAfter && Trigger.isUpdate) {
            system.debug('XXXX Mick EDM_IABP_Trigger on :');
            EDM_IABP_Trigger_Helper.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
            EDM_IABP_DrawLoop.onAfterUpdate(Trigger.old,Trigger.newMap);
            EDM_ABM_Email_Notifications.onIABPafterUpdate(Trigger.old,Trigger.newMap);
        }         
    }
}