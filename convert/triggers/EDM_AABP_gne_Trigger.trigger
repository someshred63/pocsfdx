trigger EDM_AABP_gne_Trigger on EDM_AABP_gne__c  (after delete, after insert, after undelete, after update, 
												before delete, before insert, before update) {
    if (!GNE_SFA2_Util.isAdminMode() ) {
    
        if (Trigger.isBefore && Trigger.isInsert){
            //EDM_IABP_Utils.onBeforeInsert(Trigger.old,Trigger.new);
        } 
        else if(Trigger.isBefore && Trigger.isUpdate) {
        	
        } 
        else if(Trigger.isBefore && Trigger.isDelete) {

        } 
        else if(Trigger.isAfter && Trigger.isInsert) {

            EDM_ABM_Email_Notifications.onAABPafterInsert(Trigger.new);
           
        } 
        else if(Trigger.isAfter && Trigger.isUpdate) {
            EDM_ABM_Email_Notifications.onAABPafterUpdate(Trigger.old,Trigger.newMap);
            for(Id aabpId : Trigger.newMap.keySet() )
            {
                if(Trigger.oldMap.get(aabpId).EDM_ABS_Manager_gne__c != Trigger.newMap.get(aabpId).EDM_ABS_Manager_gne__c) {
                    EDM_IABP_Utils.updateAbsManagerFromParentAABP(Trigger.newMap, Trigger.oldMap);
                }
            }
        }
        else if(Trigger.isAfter && Trigger.isDelete) {
        
        }
    }
}