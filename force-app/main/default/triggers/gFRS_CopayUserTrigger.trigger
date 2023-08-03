trigger gFRS_CopayUserTrigger on GFRS_CopayUser__c (before insert, before update) {
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {  
        for(GFRS_CopayUser__c copayUser : Trigger.New) {
            copayUser.Invite_Code__c = gFRS_Utilcopay.generateInviteCode(copayUser, Trigger.isUpdate);
        }  
    }
    
}