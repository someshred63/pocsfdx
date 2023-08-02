@RestResource(urlMapping='/iPhoneGetDeletedRecords/*')
global class iPhone_Get_Deleted_gne {

    @HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, String otrVersion) {            
      return iPhone_Commons_gne.buildResponse(
          new iPhoneGetDeletedRecordsResponseBuilder(), 
          new DeltaArgs(lastSyncDate, otrVersion)
      );     
    }
    
    public class iPhoneGetDeletedRecordsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder { 
        
        private final Integer RECORDS_LIMIT;
        
        public iPhoneGetDeletedRecordsResponseBuilder(){
        	this.RECORDS_LIMIT = getServiceSettingValue('DeltaLimitGetDeletedRecords', 10000);
        }

        public iPhone_Commons_gne.RestResponse build(Object objArgs) {
            return buildResponse((DeltaArgs)objArgs);
        }

        private DeltaRecordsResponseWithIdList buildResponse(DeltaArgs args) {            
            List<SObject> sObjects = selectSObjects(args);
            sObjects = filterAccessibleSObjects(sObjects, args.unixId);
            return buildDeltaResponse(sObjects, args);
        }

        private DeltaRecordsResponseWithIdList buildDeltaResponse(List<SObject> sObjects, DeltaArgs args) {
            Set<String> xids = new Set<String>();
            Map<String,List<String>> recordIds = new Map<String,List<String>>();
            DateTime lastSyncDateQueryMore = null;            
            DeletedRecordsByDateInfo latestRecordsInfo = null;            
           	MyDeltaCalculator deltaCalculator = String.isNotBlank(args.lastSyncDate) ? new MyDeltaCalculator(args.lastSyncDate) : null;
           	Integer rindex = 0;
            for(SObject sObj: sObjects) {
                DateTime createdDate = (DateTime)sObj.get('CreatedDate');
               	if (rindex == RECORDS_LIMIT){
               		lastSyncDateQueryMore = createdDate;
               		break;
               	}
               	if (latestRecordsInfo == null){
               		latestRecordsInfo = new DeletedRecordsByDateInfo(createdDate);
               	}
               	if (latestRecordsInfo.createdDate != createdDate){
               		writeResults(latestRecordsInfo, xids, recordIds);               		
               		latestRecordsInfo.reset(createdDate);
               	}
               	latestRecordsInfo.xids.add(sObj.id);
               	if (deltaCalculator != null){
               		String deltaStatus = deltaCalculator.getDeltaStatus(sObj);
                   	if(deltaCalculator.STAT_INSERT == deltaStatus || deltaCalculator.STAT_UPDATE == deltaStatus) {
                   		  addDeletedRecordId(sObj, latestRecordsInfo.recordIds);
                   	}
               	} else {
               		addDeletedRecordId(sObj, latestRecordsInfo.recordIds);
               	}
                rindex++;       	
           }
           
           if (latestRecordsInfo != null && (lastSyncDateQueryMore == null || (lastSyncDateQueryMore != null && latestRecordsInfo.createdDate != lastSyncDateQueryMore))){
             	writeResults(latestRecordsInfo, xids, recordIds);             	                	
           }
           
           return new DeltaRecordsResponseWithIdList(new List<String>(xids), recordIds, lastSyncDateQueryMore, args);         
        }
        
        private void writeResults(DeletedRecordsByDateInfo latestRecordsInfo, Set<String> xids, Map<String,List<String>> recordIds){
        	xids.addAll(latestRecordsInfo.xids);
        	
        	for(String objectName : latestRecordsInfo.recordIds.keySet()) {
        		if(!recordIds.containsKey(objectName)) {
              recordIds.put(objectName, new List<String>());
            }
            
            recordIds.get(objectName).addAll(latestRecordsInfo.recordIds.get(objectName));
        	}
        }
        
        private void addDeletedRecordId(SObject sObj, Map<String,List<String>> recordIds) {
        	GetOTRDeletedRecord recWrapper = getAsRecord(sObj);
        	
        	if(!recordIds.containsKey(recWrapper.objectName)) {
        		recordIds.put(recWrapper.objectName, new List<String>());
        	}
        	
        	recordIds.get(recWrapper.objectName).add(recWrapper.deletedRecordId);
        }

        private List<SObject> filterAccessibleSObjects(List<SObject> sObjects, String unixId) {
            if(iPhone_StringUtil.hasValue(unixId)){
                User user = iPhone_DAO.getUserByExternalId(unixId);
                boolean useImpersonation = (Userinfo.getUserId() != user.id);
                if(useImpersonation){                                                           // perform filtering:
                    iPhone_Commons_gne.UserRecordAccessBasedSObjectsFilter sObjectsFilter = new iPhone_Commons_gne.UserRecordAccessBasedSObjectsFilter(user);
                    return sObjectsFilter.getAccessibleSObjects(sObjects);
                }
            }
            return sObjects;            
        }                       

        private List<sObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
        	if (String.isNotBlank(args.lastSyncDate)){
            	DateTime lastSynchronized = DateTime.valueofGmt(args.lastSyncDate);
            	return [SELECT id, Deleted_Record_Id__c, Object_name__c, Parent_Account_Id_gne__c, CreatedDate, LastModifiedDate FROM OTR_Deleted_Record_gne__c WHERE CreatedDate >= :lastSynchronized ORDER BY CreatedDate ASC, Id ASC LIMIT :(RECORDS_LIMIT + 1)];
        	} else {
        		return [SELECT id, Deleted_Record_Id__c, Object_name__c, Parent_Account_Id_gne__c, CreatedDate, LastModifiedDate FROM OTR_Deleted_Record_gne__c ORDER BY CreatedDate ASC LIMIT :(RECORDS_LIMIT + 1)];
        	}
        }   
                    
        private GetOTRDeletedRecord getAsRecord(SObject sObj) {
            return new GetOTRDeletedRecord((OTR_Deleted_Record_gne__c)sObj);                  
        }
        
        private Integer getServiceSettingValue(String key, Integer defaultValue){
        	Integer result = null;
        	GNE_SFA2_OTR_Services_Settings__c serviceSetting = GNE_SFA2_OTR_Services_Settings__c.getValues(key);
        	if (serviceSetting != null && String.isNotBlank(serviceSetting.Value_gne__c)){
        		result = integerTryParse(serviceSetting.Value_gne__c);
        	}
        	return result != null ? result : defaultValue;        	
        }        	
        
        private Integer integerTryParse(String valueStr){
        	Integer result = null;
        	try{
        		result = Integer.valueOf(valueStr);
        	} catch(Exception ex){}
        	return result;
        }
    }

    private class GetOTRDeletedRecord extends iPhone_Commons_gne.DeltaRecord{
    	public String timeOfDeletion;
      	public String objectName;
      	public String deletedRecordId;
      	public String parentAccountId;

      	public GetOTRDeletedRecord(OTR_Deleted_Record_gne__c sObj){
      		this.timeOfDeletion  = iPhone_StringUtil.getString(sObj.CreatedDate);
      		this.objectName  = iPhone_StringUtil.getString(sObj.Object_name__c);
      		this.deletedRecordId = iPhone_StringUtil.getString(sObj.Deleted_Record_Id__c);
      		this.parentAccountId = iPhone_StringUtil.getString(sObj.Parent_Account_Id_gne__c);
      	}
    }
    
    private class DeltaArgs extends iPhone_Commons_gne.DeltaArgs {
    	  
    	  public DeltaArgs(String lastSyncDate, String otrVersion) {
            super(lastSyncDate, null, null, true, otrVersion);
        }
    }

    private class DeltaRecordsResponseWithIdList extends iPhone_Commons_gne.RestResponse {    
        private transient final String DEFAULT_DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss.S';
        
        public final String lastSyncDate;
        public final List<String> ids;
        public final Map<String,List<String>> recordIds;
        public final List<String> xids;        
        
        public DeltaRecordsResponseWithIdList(List<String> xids, Map<String,List<String>> recordIds, DateTime lastSyncDateQueryMore, DeltaArgs args) {
            this.lastSyncDate = lastSyncDateQueryMore != null ? lastSyncDateQueryMore.formatGmt(DEFAULT_DATETIME_FORMAT) : '';
            
            if(args.isOtrVersionOrHigher('6.0.0')) {
              this.recordIds = recordIds;	
            } else {
            	this.ids = new List<String>();
            	
            	for(List<String> recIds : recordIds.values()) {
            		this.ids.addAll(recIds);
            	}
            	
            	this.xids = xids;
            }
        }           
    }
    
    private class MyDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator{
        
        public MyDeltaCalculator(String lastSyncDate){
            super(lastSyncDate);
        }
        
        public override String getDeltaStatus(sObject sObj ){
           return super.getDeltaStatus(sObj);
        }
    }
    
    private class DeletedRecordsByDateInfo {
    	public DateTime createdDate { get; private set; }
    	public Set<String> xids { get; set; }
    	public Map<String,List<String>> recordIds { get; set; }
    	
    	public DeletedRecordsByDateInfo(DateTime createdDate){
    		this.createdDate = createdDate;
    		this.xids = new Set<String>();
    		this.recordIds = new Map<String,List<String>>();
    	}
    	
    	public void reset(DateTime createdDate){
    		this.createdDate = createdDate;
    		this.xids.clear();
    		this.recordIds.clear();
    	}
    }
}