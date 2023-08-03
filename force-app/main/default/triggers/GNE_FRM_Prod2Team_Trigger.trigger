trigger GNE_FRM_Prod2Team_Trigger on FRM_Prod_2_Team_gne__c (before insert, before update) {
    if (GNE_SFA2_Util.isAdminMode()){
        return;
    }

    if(Trigger.isBefore && Trigger.isInsert) {
        GNE_FRM_Prod2Team_TriggerHandlerLogic.checkFRMProductExists();
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        GNE_FRM_Prod2Team_TriggerHandlerLogic.checkFRMProductExists();  
    } else if(Trigger.isBefore && Trigger.isDelete) {            
            
    } else if(Trigger.isAfter && Trigger.isInsert) {
            
    } else if(Trigger.isAfter && Trigger.isUpdate) {
            
    } else if(Trigger.isAfter && Trigger.isDelete) {
                   
    }
}