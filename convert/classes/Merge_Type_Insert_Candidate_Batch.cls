global class Merge_Type_Insert_Candidate_Batch implements Database.Batchable<SObject>, Database.Stateful  {
    Merge_Type_gne__c mergeType;    
    String uniqueSetFieldName = null;
    String groupByValue = null;    	
    List<Id> objectIdList = new List<Id>();
    List<SObject> uniqueRecsWithExternalIdToUpdate;
    
    // merge stats
	Integer TotalRecordCount = 0;
    Integer UniqueGroupCount  = 0;
    Integer RuntimeErrorCount = 0;
    List<Merge_Type_Candidate_Stage_gne__c> mtCandidates = new List<Merge_Type_Candidate_Stage_gne__c>();
    Merge_Type_Apex_Job_gne__c apexJob = null;
    DateTime lastExecutionDateTime = null;
    DateTime lastAccountExecutionDateTime = null;
    private Merge_Type_Engine_Batch_Scheduler.MergeTypeWrapper [] orderedObjectsToExecute;
    private Boolean bCheckMode;
    
    private Merge_Type_Insert_Candidate_Batch () {
    }
                
    public Merge_Type_Insert_Candidate_Batch (Merge_Type_Engine_Batch_Scheduler.MergeTypeWrapper [] orderedObjectsToExecute,Merge_Type_gne__c mergeType,Merge_Type_Apex_Job_gne__c job, Boolean bCheckMode) {
        this.orderedObjectsToExecute = orderedObjectsToExecute;
        this.mergeType = mergeType;
        this.apexJob = job;
        this.bCheckMode = bCheckMode;
    }           
 
    public Merge_Type_Insert_Candidate_Batch (Merge_Type_gne__c mergeType,Merge_Type_Apex_Job_gne__c job) {
        this.mergeType = mergeType;
        apexJob = job;
    }

    global Database.QueryLocator start(Database.batchableContext bc) {
    	system.debug('MergeTypeInsert starts with object name: ' + mergeType.Object_Name_gne__c);
        String query = Merge_Type_Util.getMergeTypeCandidateFindQueryString(mergeType.Id, apexJob);
        if (query == null) {
            throw new Merge_Type_Exception('Sort By Columns, Where Clause, Unique Set Field Name rules are required for Merge Type (Object Name) ' 
                                            + mergeType.Name + '(' + mergeType.Object_Name_gne__c + ')');
        }
        system.debug('Query: ' + query);
        uniqueSetFieldName = Merge_Type_Util.getMergeTypeUniqueSetFieldName(mergeType.Id);
        if(query.contains(':lastExecutionDateTime')) {
        	lastExecutionDateTime = Merge_Type_Util.getLastApexJobDateTime(mergeType.Id, apexJob);
        	System.debug('lastExecutionDateTime = ' + lastExecutionDateTime);
        }
        
        if(query.contains(':lastAccountExecutionDateTime')) {
        	lastAccountExecutionDateTime = Merge_Type_Util.getLastAccountApexJobDateTime(mergeType.Id);
        	System.debug('lastAccountExecutionDateTime = ' + lastAccountExecutionDateTime);
        }        
        Database.QueryLocator queryLocator = Database.getQueryLocator(query);
        return queryLocator;
    }
 
    global void execute(Database.BatchableContext BC, List<SObject> inputObjectList){
    	system.debug('MergeTypeInsert, execute with objectList: ' + inputObjectList);
    	uniqueRecsWithExternalIdToUpdate = inputObjectList.clone();
    	uniqueRecsWithExternalIdToUpdate.clear();
    	
    	for ( SObject record : inputObjectList ) {    	
    		TotalRecordCount++;	 
            String uniqueId = (String)record.get(this.uniqueSetFieldName);
            try {
            	if ( groupByValue == null ) {
                   this.groupByValue = uniqueId;                               
                }  
                
                if ( this.groupByValue.equalsIgnoreCase(uniqueId) == false )  { // new duplicate set
                    if (this.objectIdList.size() > 1 ){
                    	UniqueGroupCount++;
                    	insertMergeCandidates();	                    	    
                    } else if(this.objectIdList.size() == 1) { // unique rec, but we need to check if external id need to be updated.
                        Id recId = this.objectIdList[0];
                        uniqueRecsWithExternalIdToUpdate.add(recId.getSObjectType().newSObject(recId));
                    }
                    this.objectIdList.clear();              
                    this.groupByValue = uniqueId;                      
                }               
                objectIdList.add (record.id) ;
             } catch (Exception ex) {
                this.objectIdList.clear();
                this.groupByValue = uniqueId;              
                this.objectIdList.add(record.id);
                
                sendErrorEmail(ex);
                system.debug('MergeTypeInsert, Exception occured: ' + ex.getStackTraceString());
             }
        }// for
        
        if ( mtCandidates.size() > 0) {
            upsert mtCandidates Merge_Type_Candidate_Stage_gne__c.external_id_gne__c;
            mtCandidates.clear();
        }
        
        try { 
	        if(!uniqueRecsWithExternalIdToUpdate.isEmpty()) {
	            (new Merge_Type_Controller()).updateExternalId(uniqueRecsWithExternalIdToUpdate);
	        }                   		    	    	
        } catch (Exception ex) {
            sendErrorEmail(ex);
        }
    }  
    
    global void finish(Database.BatchableContext BC){
    	try {
            if ( this.groupByValue != null && this.objectIdList.size() > 1 ){            	
            	system.debug('Finish: insert candidates.');
            	UniqueGroupCount++;
                insertMergeCandidates();               
                upsert mtCandidates Merge_Type_Candidate_Stage_gne__c.external_id_gne__c;
            } else if( this.groupByValue != null && this.objectIdList.size() == 1 && uniqueRecsWithExternalIdToUpdate!=null) {
                Id recId = this.objectIdList[0];
                uniqueRecsWithExternalIdToUpdate.add(recId.getSObjectType().newSObject(recId));
                (new Merge_Type_Controller()).updateExternalId(uniqueRecsWithExternalIdToUpdate); 
            }
            
           	this.groupByValue = null;
            this.objectIdList.clear();
        } 
        catch (Exception ex) {        	
            system.debug('MergeTypeInsert, Exception occured: ' + ex.getStackTraceString());
            sendErrorEmail(ex);
        }
         
        Merge_Type_Util.finalizeBatch(BC.getJobId(), mergeType, apexJob, TotalRecordCount, UniqueGroupCount, RuntimeErrorCount);   
        if(orderedObjectsToExecute != null && !orderedObjectsToExecute.isEmpty()) {
            orderedObjectsToExecute.remove(0);
            if(!orderedObjectsToExecute.isEmpty()) {
                Merge_Type_Engine_Batch_Scheduler.MergeTypeWrapper  mtw = orderedObjectsToExecute[0];
                Merge_Type_gne__c mergeType = mtw.mergeType;
                Merge_Type_Apex_Job_gne__c job = new Merge_Type_Apex_Job_gne__c(Merge_Type_ref_gne__c = mergeType.Id, Apex_Job_Type_gne__c = mtw.apexJobType == Merge_Type_Util.APEX_JOB_TYPE_MERGE ?Merge_Type_Util.APEX_JOB_TYPE_MERGE : Merge_Type_Util.APEX_JOB_TYPE_INSERT_CANDIDATES);
                insert job;

                if(mtw.apexJobType == Merge_Type_Util.APEX_JOB_TYPE_MERGE){
                    Merge_Type_Engine_Batch asyncJob = new Merge_Type_Engine_Batch(orderedObjectsToExecute, mergeType, bCheckMode, job); 
                    Database.executeBatch (asyncJob, 10); 
                } else {
                    Merge_Type_Insert_Candidate_Batch asyncJob = new Merge_Type_Insert_Candidate_Batch(orderedObjectsToExecute, mergeType, job, bCheckMode);
                    Database.executeBatch (asyncJob, 2000); 
                }
            }                      
        }
    } 
    
    void sendErrorEmail (Exception e) {
        RuntimeErrorCount++;
        Merge_Type_Util.writeErrorLog(Merge_Type_Util.INSERT_CANDIDATE_JOB_BATCH_NAME, apexJob, mergeType, e);
    }   
        
    private void insertMergeCandidates() {
    	system.debug('ObjectIdList: ' + this.objectIdList);    
    	try{
	        Id winnerId = this.objectIdList[0]; 	                    	  
	        mtCandidates.addAll(Merge_Type_Util.prepareMergeTypeCandidates(winnerId, this.objectIdList, this.mergeType.id));    
    	}
    	catch(Exception ex){
    	 	sendErrorEmail(ex);
            system.debug('InsertMergeCandidates, Exception occured: ' + ex.getStackTraceString());	
    	}         	
    }
}