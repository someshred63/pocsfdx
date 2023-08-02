trigger GNE_SFA2_SchedulerJob_Trigger on SFA2_Scheduler_Job_gne__c (before update, before delete) {
    if(!GNE_SFA2_Util.isAdminMode()) {
        if(Trigger.isUpdate) {
            GNE_SFA2_Scheduler.onUpdateSchedulerJob(Trigger.new, Trigger.old);
        } else if(Trigger.isDelete) {
            GNE_SFA2_Scheduler.onDeleteSchedulerJob(Trigger.old);
        }
    }
}