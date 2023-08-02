public with sharing class Merge_Type_Console_Controller {
    @TestVisible private Merge_Type_gne__c mergeType = null;
    @TestVisible private Boolean bStarted;
    private transient String pageMsg;
    
    public boolean showPopulateMergeCandidates { 
    	get {
    		return mergeType.Name != 'Account' && mergeType.Name != 'Account Address' && 
    		       mergeType.Name != 'Person Account' && mergeType.Name != 'Person Account Address';   
    	}
    }
    
    public Boolean canLaunch {
    	get {
    		Boolean canLaunch = true;
    		String prevPageMsg = pageMsg;
	    	pageMsg = null;
	    	AsyncApexJob mergeJob = Merge_Type_Util.getCurrentMergeJob();
	    	AsyncApexJob insertCandidatesJob = Merge_Type_Util.getCurrentInsertCandidateJob();
	    	AsyncApexJob lastJob = mergeJob!=null ? (insertCandidatesJob!=null ? (mergeJob.CreatedDate>=insertCandidatesJob.CreatedDate ? mergeJob : insertCandidatesJob) : mergeJob) : insertCandidatesJob;
	    	
	    	if(lastJob!=null && Merge_Type_Util.isJobRunning(lastJob)) {
	        	pageMsg = Merge_Type_Util.getStatusMessageForJob(lastJob);
		        canLaunch = false;
		        bStarted = true;
	    	} else if(lastJob!=null && bStarted==true) {
	        	pageMsg = Merge_Type_Util.getStatusMessageForJob(lastJob);
		        bStarted = false;
	        }
	        
	        if(pageMsg!=null && prevPageMsg==null) {
		    	ApexPages.Message msg = new ApexPages.Message (ApexPages.Severity.INFO, pageMsg);
			    ApexPages.addMessage(msg);
		    }
    		
    		return canLaunch;
    	}
    }	
    
    public Merge_Type_Console_Controller(ApexPages.StandardController controller) {
        mergeType = (Merge_Type_gne__c )controller.getRecord();
        if ( mergeType != null && mergeType.Id != null) {
            mergeType = [select Id,Name,Object_Name_gne__c from Merge_Type_gne__c where id = :mergeType.Id];
        }
        
        if(!canLaunch) {
        	actionPollerSupport();
        }
    }
    
    public PageReference startBatch () {
        startBatch (false);
        return null;
    }

    public PageReference startBatchInCheckMode () {
        startBatch (true);
        return null;
    }
    
    public PageReference populateMergeCandidates() {     
        startInsertCanddiateBatch();
        return null;
    }

    void startInsertCanddiateBatch () {
        try {
        	if(canLaunch) {
	            String apexJobType = Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES;
	            Merge_Type_Apex_Job_gne__c job = new Merge_Type_Apex_Job_gne__c(Merge_Type_ref_gne__c = mergeType.Id, Apex_Job_Type_gne__c = apexJobType);
	            insert job;
	            Merge_Type_Insert_Candidate_Batch cBatch = new Merge_Type_Insert_Candidate_Batch(mergeType,job);
	            database.executeBatch (cBatch, 2000);            
	            bStarted = true;
        	} else {
        		ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Cannot launch new process. Batch is already in progress.'));
        	}            
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    void startBatch (Boolean checkMode) {
    	try {
    		if(canLaunch) {
	    		String apexJobType = Merge_Type_Util.APEX_JOB_TYPE_MERGE_CHECKMODE;
	    		if (checkMode == false) {
	    			apexJobType = Merge_Type_Util.APEX_JOB_TYPE_MERGE;
	    		}
		    	Merge_Type_Apex_Job_gne__c job = new Merge_Type_Apex_Job_gne__c(Merge_Type_ref_gne__c = mergeType.Id, Apex_Job_Type_gne__c = apexJobType);
		        insert job;
		        Merge_Type_Engine_Batch mbatch = new Merge_Type_Engine_Batch (mergeType, checkMode, job);
		        database.executeBatch ( mbatch, 10 );            
		        bStarted = true;
    		} else {
    			ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Cannot launch new process. Batch is already in progress.'));
    		}
    	} catch (Exception e) {
    		ApexPages.addMessages(e);
            ApexPages.Message msg = new ApexPages.Message (ApexPages.Severity.ERROR, 'Stacktrace  ' + e.getStackTraceString());
            ApexPages.addMessage(msg);
    	}
    }

    public PageReference actionPollerSupport(){
    	return null;
    }
}