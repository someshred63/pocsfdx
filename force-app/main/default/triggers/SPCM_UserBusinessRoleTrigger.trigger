trigger SPCM_UserBusinessRoleTrigger on User_Business_Role_gne__c (before insert, before delete, after insert, after delete, after update) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            SPCM_UserBusinessRoleUtils.handleAfterInsertUpdate(Trigger.new);
        }
    } else {
        if (Trigger.isDelete) {
            SPCM_UserBusinessRoleUtils.handleBeforeDelete(Trigger.old);
        }
    }
}