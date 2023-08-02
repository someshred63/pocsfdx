global without sharing class GNE_Subscribe_LOA_Batch extends GNE_Subscribe_Batch_Base implements Database.Batchable<sObject>, Database.Stateful {
    public static final String COMMENT_USER_NOT_FOUND = 'Input Data Error: User not found.';
    public static final String COMMENT_DATES_VALIDATION = 'Input Data Error: LOA End Date cannot be prior LOA Start Date';
    private static final String BATCH_NAME = 'LOA';
    
    private List<Staging_User_LOA_gne__c> allStgObjs = new List<Staging_User_LOA_gne__c>();
    
    global GNE_Subscribe_LOA_Batch(Boolean prevMode) {
        previewMode = prevMode;
    }
    
    protected override String getBatchName() {
    	return BATCH_NAME;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
        	SELECT 
        		Id, 
        		Comment_gne__c, 
        		LOA_End_Date_gne__c, 
        		LOA_Start_Date_gne__c, 
        		Status_gne__c, 
        		User_UnixID_gne__c
        	FROM Staging_User_LOA_gne__c
        	WHERE Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_LOADED]);   
    }
    
    public override void initCache(List<SObject> stgObjs) {
    	super.initCache(stgObjs);
    	System.debug('BOS::stagingCache.keySet()' + stagingCache.keySet());
    	
    	Set<String> extIds = stagingCache.keySet();
        List<User> users = [
        	SELECT 
        		Id, 
        		LOA_Start_Date_gne__c, 
        		LOA_End_Date_gne__c, 
        		External_ID_gne__c 
        	FROM User 
        	WHERE External_ID_gne__c IN :stagingCache.keySet()];
        
        for(User usr : users) {
        	cacheTargetObject(usr);
        }
    }
    
    protected override String getKeyFromTargetObject(SObject targetObj) {
    	return ((User)targetObj).External_ID_gne__c.toUpperCase();
    }
    
    protected override String getKeyFromStagingObject(SObject stgObj) {
    	String key = ((Staging_User_LOA_gne__c)stgObj).User_UnixID_gne__c;
    	return String.isNotBlank(key) ? key.toUpperCase() : '';
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	List<Staging_User_LOA_gne__c> stgObjs = (List<Staging_User_LOA_gne__c>)scope;
    	allStgObjs.addAll(stgObjs);
    	initCache(stgObjs);
    	
    	List<User> usersToUpdate = new List<User>();
        
        for(Staging_User_LOA_gne__c stgObj : stgObjs) {
        	clearStagingObjectComment(stgObj);
        	User u = (User)getTargetForStagingObject(stgObj);
        	Date startDate = stgObj.LOA_Start_Date_gne__c;
        	Date endDate = stgObj.LOA_End_Date_gne__c;
        	
        	if(u==null) {
        		markStagingObjectWithError(stgObj, COMMENT_USER_NOT_FOUND);
        	} else if(startDate != null && endDate != null && startDate.daysBetween(endDate)<0) {
        		markStagingObjectWithError(stgObj, COMMENT_DATES_VALIDATION);
        	} else {
        		markStagingObjectAsProcessed(stgObj);
        		
        		if(u.LOA_Start_Date_gne__c!=startDate || u.LOA_End_Date_gne__c!=endDate) {
        			u.LOA_Start_Date_gne__c = startDate;
        			u.LOA_End_Date_gne__c = endDate;
        			usersToUpdate.add(u);
        		}
        	}
        }
        
        executeDml(usersToUpdate, GNE_Subscribe_Batch_Base.DmlType.TARGET_UPDATE);
    }
    
    global void finish(Database.BatchableContext BC) {
    	executeDml(allStgObjs, GNE_Subscribe_Batch_Base.DmlType.STAGING_UPDATE);
    	doFinish(BC);
    }
}