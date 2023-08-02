trigger GNE_FRM_DST_Match_Winner_Trigger on DST_Match_Winner__c (before insert, before update) {
    if (GNE_SFA2_Util.isAdminMode()){
        return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert) {
        GNE_FRM_DST_MatchWinnerTriggerHandler.populateFields();
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        GNE_FRM_DST_MatchWinnerTriggerHandler.populateFields();
    } else if(Trigger.isBefore && Trigger.isDelete) {            
            
    } else if(Trigger.isAfter && Trigger.isInsert) {
            
    } else if(Trigger.isAfter && Trigger.isUpdate) {
            
    } else if(Trigger.isAfter && Trigger.isDelete) {
                   
    }
}