public without sharing class GNE_SFA2_PFG_SL_Rejection_Batch implements Database.Batchable<sObject>, Database.Stateful,
		GNE_Batch_Runner.BatchableBase, GNE_SFA2_PFG_Scheduler.SchedulerProcess {
    
    public System.Type getBatchClass() {
		return GNE_SFA2_PFG_SL_Rejection_Batch.class;
	}
	
	public String getBatchName() {
		return 'PFG SL Rejection Batch';
	}
    
    public void executeSchedulerProcess() {
        GNE_Batch_Runner.executeBatch(this, 10,
        	false, true, true, false);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
    	return GNE_Batch_Runner.doStart(this,BC);
    }
    
    public Database.QueryLocator intStart(Database.BatchableContext BC) {
        List<SFA2_PFG_Storage_Location_gne__c> pendingSLs = [
            SELECT Id
            FROM SFA2_PFG_Storage_Location_gne__c
            WHERE Status_gne__c = :GNE_SFA2_PFG_Util.STORAGE_LOCATION_STATUS_SUBMITTED
        ];
        
        return Database.getQueryLocator([
            SELECT Id, ProcessInstance.TargetObjectId
            FROM ProcessInstanceWorkItem
            WHERE ProcessInstanceId IN (
                SELECT ID
                FROM ProcessInstance 
                WHERE Status = :GNE_SFA2_PFG_Util.APPROVAL_STATUS_PENDING 
                    AND TargetObjectId IN :pendingSLs
                    AND LastModifiedDate < LAST_N_DAYS:30)]);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
    	GNE_Batch_Runner.doExecute(this,BC, scope);
    }
    
    public void intExecute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> slIds = new Set<Id>();
        for(ProcessInstanceWorkItem piwi : (List<ProcessInstanceWorkItem>)scope) {
            slIds.add(piwi.ProcessInstance.TargetObjectId);
        }
        
        GNE_SFA2_PFG_Util.approveOrRejectStorageLocations(UserInfo.getUserId(),slIds,false, GNE_SFA2_PFG_Util.STORAGE_LOCATION_30DAYS_REJECTED_COMMENT);
    }
    
    public void finish(Database.BatchableContext BC) {
        GNE_Batch_Runner.doFinish(this,BC);
    }
    
    
    public void intFinish(Database.BatchableContext BC) {
    
    }
    
    public String getKeyForRecord(SObject sObj) {return null;}
	public String getRecordDescription(SObject sObj) {return null;}
}