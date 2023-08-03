trigger SFA2_SBC_Profiler_Log_Action_Trigger on SFA2_SBC_Profiler_Log_Action_gne__c (after insert) {
    if (GNE_SFA2_Util.isAdminMode() ) return;
    
    if(Trigger.isAfter && Trigger.isInsert) {
        SFA2_SBC_Profiler_Log_Action_Handler.onAfterInsert();
    }
}