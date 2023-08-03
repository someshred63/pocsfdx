trigger MA_ReferralRoster_Trigger on MA_Referral_Roster__c (before insert, before update, before delete, after undelete) {
    if(!GNE_SFA2_Util.isAdminMode()) {
        GNE_SFA2_ReferralUtil.validateOnReferralRosterDml(Trigger.isDelete ? Trigger.old : Trigger.new);
        
        if(Trigger.isInsert) {
            GNE_SFA2_ReferralUtil.onReferralRosterUpsert(Trigger.new, null);
        } else if(Trigger.isUpdate) {
            GNE_SFA2_ReferralUtil.onReferralRosterUpsert(Trigger.new, Trigger.old);
        }
    }
}