trigger GNE_SFA2_Membership_Contracts_Trigger on Membership_Contracts_gne__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

    if (!GNE_SFA2_Util.isAdminMode()) {
        if(Trigger.isAfter && Trigger.isInsert){
            GNE_SFA2_Membership_Record_Updates.onAfterInsert(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isUpdate){
            GNE_SFA2_Membership_Record_Updates.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        } else if(Trigger.isAfter && Trigger.isDelete){
            GNE_SFA2_Membership_Record_Updates.onAfterDelete(Trigger.old);
        }
    }
}