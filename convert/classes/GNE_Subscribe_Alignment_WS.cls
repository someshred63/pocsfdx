global class GNE_Subscribe_Alignment_WS {
	
    private final static Integer batchSize = GNE_Foun_Misc_Config_Items_gne__c.getValues('AlignmentBatchSize') != null ? Integer.valueOf(GNE_Foun_Misc_Config_Items_gne__c.getValues('AlignmentBatchSize').Configuration_Value_gne__c) : 10;
    
    private final static Boolean parallelMode = GNE_Foun_Misc_Config_Items_gne__c.getValues('ParallelMode') != null ? Boolean.valueOf(GNE_Foun_Misc_Config_Items_gne__c.getValues('ParallelMode').Configuration_Value_gne__c) : false;
    
    webService static String executeSubscribeProcess() {
    	return executeProcess(false);
    }
    
    webService static String executeProcess(Boolean prevMode) {
    	if (!parallelMode) {
	    	GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment(prevMode);
	    	GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(subscribe, GNE_Subscribe_Batch_Alignment.class, batchSize);
			return result.getStatus();
    	} else {
    		List<AsyncApexJob> activeJobs = [SELECT Id, ApexClass.Name, CreatedDate, JobItemsProcessed, TotalJobItems, ApexClassId
         			FROM AsyncApexJob 
         			WHERE Status NOT IN :GNE_Batch_Runner.excludedJobStatuses
         			AND JobType = 'BatchApex'
         			AND (ApexClass.Name = 'GNE_Subscribe_Batch_Preprocessing' OR ApexClass.Name = 'GNE_Subscribe_Batch_Alignment')];
         	if (activeJobs.isEmpty()) {
	    		Database.executeBatch(new GNE_Subscribe_Batch_Preprocessing(prevMode), 1000);
	    		return 'STARTED';
         	} else {
         		return 'PROCESSING';
         	}		
    	}
    }
    
    webService static String executeJob(String jobId, Boolean prevMode) {
    	GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment(jobId, prevMode);
    	Alignment_Job_gne__c alignmentJob = [SELECT id, Status_gne__c, Activation_Date_gne__c FROM Alignment_Job_gne__c WHERE id = :jobId];
    	if (alignmentJob.Status_gne__c == GNE_Subscribe_Batch_Base.STATUS_LOADED) {
    		if(prevMode == true || alignmentJob.Activation_Date_gne__c == null || alignmentJob.Activation_Date_gne__c < Date.today()){
	    		GNE_Batch_Runner.ExecuteResult result = GNE_Batch_Runner.executeBatch(subscribe, GNE_Subscribe_Batch_Alignment.class, batchSize);
				return result.getStatus();
    		} else {
    			return 'Cannot execute job with Activation Date in future.'; 
    		}
    	} else {
    		return 'Cannot execute job with status: ' + alignmentJob.Status_gne__c;
    	}
    }
}