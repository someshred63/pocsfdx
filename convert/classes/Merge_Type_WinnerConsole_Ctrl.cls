public with sharing class Merge_Type_WinnerConsole_Ctrl {
	private Id  recordId;
	private Decimal regionCode;
	private String objectName;
	private Merge_Type_gne__c mergeType;
	private Boolean bStarted;
	private transient String pageMsg;
    
	
	public Boolean isMergeComplete {get; private set;}
	
	public Boolean canLaunch{
    	get{
    		Boolean canLaunch = true;
    		String prevPageMsg = pageMsg;
	    	String pageMsg = null;
	    	AsyncApexJob mergeJob = Merge_Type_Util.getCurrentMergeJob();
	    	AsyncApexJob insertCandidatesJob = Merge_Type_Util.getCurrentInsertCandidateJob();
	    	AsyncApexJob lastJob = mergeJob!=null ? (insertCandidatesJob!=null ? (mergeJob.CreatedDate>=insertCandidatesJob.CreatedDate ? mergeJob : insertCandidatesJob) : mergeJob) : insertCandidatesJob;
	    	
	    	if(lastJob!=null && Merge_Type_Util.isJobRunning(lastJob)) {
	        	pageMsg = Merge_Type_Util.getStatusMessageForJob(lastJob);
		        canLaunch = false;
		        bStarted = true;
		    
		        if(lastJob==mergeJob) {
		    		isMergeComplete = false;
		        }
	        } else if(lastJob!=null && bStarted==true) {
	        	pageMsg = Merge_Type_Util.getStatusMessageForJob(lastJob);
		        bStarted = false;
		         
		        if(lastJob==mergeJob) {
		         	isMergeComplete = Merge_Type_Util.isJobCompleted(lastJob);
		        }
	        }
	        	
	        if(pageMsg!=null && prevPageMsg==null) {
	    		ApexPages.Message msg = new ApexPages.Message (ApexPages.Severity.INFO, pageMsg);
		       	ApexPages.addMessage(msg);
	    	}
    		
    		return canLaunch;
    	}
    }    

    public Merge_Type_WinnerConsole_Ctrl(ApexPages.StandardController stdController) {
    	isMergeComplete = false;       
        SObject sobjectInstance = stdController.getRecord();
        recordId = (String) sobjectInstance.get('Id');
        objectName = recordId.getSObjectType().getDescribe().getName();
        regionCode = (Decimal)Database.query('SELECT Region_Code_gne__c FROM ' + objectName + ' WHERE Id = :recordId')[0].get('Region_Code_gne__c');
        List<Merge_Type_gne__c> mts = [SELECT Id, Name, Object_Name_gne__c FROM Merge_Type_gne__c WHERE Region_Code_gne__c = :regionCode AND Object_Name_gne__c = :objectName];
        
        if(mts.size() == 2 && objectName == 'Account') {
        	String mergeTypeName = [SELECT IsPersonAccount FROM Account WHERE Id = :recordId].IsPersonAccount
        		? Merge_Type_Util.MERGE_TYPE_NAME_PERSON_ACCOUNT
        		: Merge_Type_Util.MERGE_TYPE_NAME_ACCOUNT;
        	
        	for(Merge_Type_gne__c mt : mts) {
        		if(mergeTypeName == mt.Name) {
        			mergeType = mt;
        		}
        	}
        } else if(!mts.isEmpty()){
        	mergeType = mts[0];
        }
        
        if(!canLaunch) {
        	checkMergeStatus();
        }
    }
    
    public Merge_Type_WinnerConsole_Ctrl getController() {
    	return this;
    }
    
    public PageReference checkMergeStatus() {
    	return null;        
    }
    
    public void callMergeInCheckMode() {    
        runMerge(True);        
    }
    
    public void CallMerge() {
        runMerge(False);    
    }

    private void runMerge(Boolean bCheckMode) {
        if (canLaunch) {
        	Merge_Type_Engine_Batch batch = new Merge_Type_Engine_Batch(mergeType, bCheckMode, new Set<String>{recordId}, null);
        	Database.executeBatch(batch, 1);
        } else {
        	ApexPages.addMessage(new ApexPages.Message (ApexPages.Severity.ERROR, 'Cannot launch new process. Batch is already in progress.'));
        }
    }
}