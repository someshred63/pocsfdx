/*
	This class allows to launch subscribe batch for HCOs and HCPs. It encapsulates the batch state: its activity (isRunning: true| false) 
	and state description (stateMessage: started | running | completed).
*/
public with sharing class GNE_CAN_Subscribe_BatchRunner {
				
	final BatchRunChecker runChecker;
	
	final BatchableFactory batchfactory;    		
	 
	public static GNE_CAN_Subscribe_BatchRunner newInstanceForAllHCO(){	
		
		String batchClassName = GNE_CAN_Subscribe_Batch_OrgAccount.class.getName();
		String batchType = GNE_CAN_Subscribe_Util.HCO_CUSTOMER_CLASS_NAME;
		
		GNE_CAN_Subscribe_BatchRunner batchRunner = new GNE_CAN_Subscribe_BatchRunner(
			new BatchRunChecker(batchClassName, batchType),
			new AllHcoBatchableFactory()		
		);				
		return batchRunner;
	}
	
	public static GNE_CAN_Subscribe_BatchRunner newInstanceForHCO(Set<Id> stgIds){
		String batchClassName = GNE_CAN_Subscribe_Batch_OrgAccount.class.getName();
		String batchType = GNE_CAN_Subscribe_Util.HCO_CUSTOMER_CLASS_NAME;
		
		GNE_CAN_Subscribe_BatchRunner batchRunner = new GNE_CAN_Subscribe_BatchRunner(
			new BatchRunChecker(batchClassName, batchType),
			new HcoBatchableFactory(stgIds)	
		);				
		return batchRunner;
	}		
	
	public static GNE_CAN_Subscribe_BatchRunner newInstanceForAllHCP(){	
		
		
		String batchClassName = GNE_CAN_Subscribe_Batch_PersonAccount.class.getName();
		String batchType = GNE_CAN_Subscribe_Util.HCP_CUSTOMER_CLASS_NAME;
		
		GNE_CAN_Subscribe_BatchRunner batchRunner = new GNE_CAN_Subscribe_BatchRunner(
			new BatchRunChecker(batchClassName, batchType),
			new AllHcpBatchableFactory()	
		);				
		return batchRunner;		
	}
	
	public static GNE_CAN_Subscribe_BatchRunner newInstanceForHCP(Set<Id> stgIds){
		String batchClassName = GNE_CAN_Subscribe_Batch_PersonAccount.class.getName();
		String batchType = GNE_CAN_Subscribe_Util.HCP_CUSTOMER_CLASS_NAME;
		
		GNE_CAN_Subscribe_BatchRunner batchRunner = new GNE_CAN_Subscribe_BatchRunner(
			new BatchRunChecker(batchClassName, batchType),
			new HcpBatchableFactory(stgIds)	
		);				
		return batchRunner;
	}			   	    	
	
	public String stateMessage{
		get {
			return runChecker.getStatusMessage();
		}
	}
	 
	public Boolean isRunning{
		get{
			return runChecker.isRunning();    			
		}
	}
	    	    	    
	private GNE_CAN_Subscribe_BatchRunner(BatchRunChecker runChecker, BatchableFactory batchfactory){	
		this.runChecker = runChecker;
		this.batchfactory = batchfactory;		 					
	}
	
	public void run(){	
		
		if(this.isRunning)
			return;
					   
		try{			
    		Database.Batchable<sObject> batch = batchfactory.newInstance();
    		Database.executeBatch(batch, GNE_CAN_Subscribe_Util.BATCH_SIZE);        	
		} 
		catch(Exception e){
			throw e;
		}    		
	}    
	
	public void disableMessages(){
		if(this.isRunning)
			return;			
	}	    	    	
		
	private interface BatchableFactory{
		Database.Batchable<sObject> newInstance();
	}
	
	private class AllHcoBatchableFactory implements BatchableFactory {
		public Database.Batchable<sObject> newInstance(){
			return new GNE_CAN_Subscribe_Batch_OrgAccount();
		}
	} 
	
	private class HcoBatchableFactory implements BatchableFactory {		
		final Set<Id> stgIds;
		
		public HcoBatchableFactory(Set<Id> stgIds){
			this.stgIds = stgIds;
		}
		
		public Database.Batchable<sObject> newInstance(){
			return new GNE_CAN_Subscribe_Batch_OrgAccount(this.stgIds);
		}
	} 
	
	private class AllHcpBatchableFactory implements BatchableFactory {
		public Database.Batchable<sObject> newInstance(){
			return new GNE_CAN_Subscribe_Batch_PersonAccount();
		}
	}
	  
	private class HcpBatchableFactory implements BatchableFactory {
		final Set<Id> stgIds;
		
		public HcpBatchableFactory(Set<Id> stgIds){
			this.stgIds = stgIds;
		}
		public Database.Batchable<sObject> newInstance(){
			return new GNE_CAN_Subscribe_Batch_PersonAccount(this.stgIds);
		}
	}
	
	private class BatchRunChecker{
		
		final String batchClassName;
		final String batchType;		
		
		public BatchRunChecker(String batchClassName, String batchType){
			this.batchClassName = batchClassName;
			this.batchType = batchType;
		}
				
		public Boolean isRunning(){
			AsyncApexJob job = getCurrentJob();
			return job!=null && job.Status!=null && new Set<String>{'QUEUED', 'PROCESSING', 'PREPARING'}.contains(job.Status.toUpperCase());
		}
		 
		public String getStatusMessage(){
			return prepareStatusMessage();
		}
		
		private String prepareStatusMessage(){
			AsyncApexJob job = getCurrentJob();			
			if(job != null)	{
				return prepareStatusMessageForJob(job);
			}
			return null;			
		}
		
		private String prepareStatusMessageForJob(AsyncApexJob job){
			String msg = '';
			msg += '[' + this.batchType + '] Subscribe Batch '; 
        	if(job.Status=='Completed') {
        		msg += job.Status + 
        			', Total Batches: ' + job.TotalJobItems + 
        			', Failures: ' + job.NumberOfErrors;
        	} else if (job.Status=='Processing') {
        		msg += job.Status + 
        			', Progress: ' + job.JobItemsProcessed + '/' + job.TotalJobItems + 
        			', Failures: ' + job.NumberOfErrors;
        	} else {
        		msg += job.Status;
        	}			
			return msg;
		}
		
		private AsyncApexJob getCurrentJob(){
			AsyncApexJob result = null;
			
			for(AsyncApexJob job : [select Status, CreatedDate, CompletedDate, TotalJobItems, JobItemsProcessed, NumberOfErrors from AsyncApexJob
	            					where ApexClass.Name =: batchClassName
	            						and JobType = 'BatchApex'
	            					order by CreatedDate desc LIMIT 1]) {
				result = job;	            							            					
	        }
			
			return result;
		}	
	}		   
}