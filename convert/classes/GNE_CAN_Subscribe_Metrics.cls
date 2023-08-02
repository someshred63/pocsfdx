public class GNE_CAN_Subscribe_Metrics {
	
	public enum EntityTypeName {ACCOUNT, ADDRESS, TOTAL, UNDEFINED}
	public enum MetricTypeName {ERROR, SUCCESS}
    
    public EntityTypeName entityType; 
    public Integer upsertCount;
    public Integer insertCount;
    public Integer updateCount;
    public Integer deleteCount;
    public Integer errorCount;
    public Map<String,GNE_CAN_Subscribe_Metrics> relatedSubscribeMetrics;
    
    private String cachedOut;
    
    public GNE_CAN_Subscribe_Metrics() {
    	this(EntityTypeName.TOTAL);
    	
    	for(EntityTypeName entType : EntityTypeName.values()) {
    		if(entType != EntityTypeName.TOTAL) {
    			relatedSubscribeMetrics.put(entType.name(),new GNE_CAN_Subscribe_Metrics(entType));
    		}
    	}
    }
    
    public GNE_CAN_Subscribe_Metrics(EntityTypeName type) {
    	entityType 				= type; 
        upsertCount 			= 0;
        insertCount 			= 0;
        updateCount 			= 0;
        deleteCount 			= 0;
        errorCount  			= 0;
        relatedSubscribeMetrics = new Map<String,GNE_CAN_Subscribe_Metrics>();
    }
    
    public static EntityTypeName getEntityTypeForObject(SObject obj) {
    	EntityTypeName eType;
    	SObjectType objType = obj.getSObjectType();
    	
    	if (objType == Account.sObjectType || objType == Stg_SFA_Cust_Can__c.sObjectType) {
            eType = GNE_CAN_Subscribe_Metrics.EntityTypeName.ACCOUNT;        
    	} else if (objType == Address_vod__c.sObjectType || objType == Stg_SFA_Cust_Addr_Can__c.sObjectType) {
            eType = GNE_CAN_Subscribe_Metrics.EntityTypeName.ADDRESS;
    	} else {
            eType = GNE_CAN_Subscribe_Metrics.EntityTypeName.UNDEFINED;
    	}
    	
    	return eType;
    }
    
    public void updateMetricsWithObject(SObject obj, MetricTypeName metricType) {
    	updateMetricsWithObject(obj, metricType, false);
    }
    
    public void updateMetricsWithObject(SObject obj, MetricTypeName metricType, Boolean isNewRecord) {
    	EntityTypeName eType = GNE_CAN_Subscribe_Metrics.getEntityTypeForObject(obj);
    	SObjectType objType = obj.getSObjectType();
    	Boolean isError = metricType == MetricTypeName.ERROR;
    	
    	// we want to put SUCCESS into metrics only when obj is Account or Address  
    	if(isError || (objType==Account.sObjectType || objType==Address_vod__c.sObjectType)) {
	    		
	    	if (isError) {
	    		errorCount++;
	    	} else {
	    		upsertCount++;
	    		if(isNewRecord) {
	    			insertCount++;
	    		} else {
	    			updateCount++;
	    		}
	    		
	    	}
	    	if(relatedSubscribeMetrics.containsKey(eType.name())) {
	    		GNE_CAN_Subscribe_Metrics relatedMetric = relatedSubscribeMetrics.get(eType.name());
	    		if(isError) {
	    			relatedMetric.errorCount++;
	    		} else {
	    			relatedMetric.upsertCount++;
	    			if(isNewRecord) {
	    				relatedMetric.insertCount++;
	    			} else {
	    				relatedMetric.updateCount++;
	    			}
	    		}
	    	}
    	}
    }
    
    public String print() {
    	return print('');
    }
    
    public String print(String linePrefix) {
    	String out = '';
    	
    	if(this.entityType != GNE_CAN_Subscribe_Metrics.EntityTypeName.UNDEFINED) {
	    	out += linePrefix + 'Metrics for ' + this.entityType + ' (inserted/updated/total/errors): ' + this.insertCount + '/' + this.updateCount + '/' + this.upsertCount + '/' + this.errorCount;
		    out += '\n';
    	}
    	
        if (this.relatedSubscribeMetrics != null) {
	        for (GNE_CAN_Subscribe_Metrics m : this.relatedSubscribeMetrics.values()) {
	            out += m.print(linePrefix + ' ');
	        }
        }
        
        return out;
    }
    
    public String print(Stg_SFA_Subscribe_Apex_Job__c job) {
    	if(cachedOut!=null) {
    		return cachedOut;
    	}
    	
    	String out = print();
    	Integer errorSize = [SELECT count() FROM Stg_SFA_Subscribe_Apex_Job_Error__c WHERE Job_Id_can__c = :job.Id LIMIT 10001];
    	
    	if(errorSize <= 10000) {    	
	    	AggregateResult[] mainErrorTypesStats = 
		    	[SELECT Code_Type_can__c, count(Id) nor
		    	FROM Stg_SFA_Subscribe_Apex_Job_Error__c
		    	WHERE
		    		Job_Id_can__c = :job.Id
		    	GROUP BY Code_Type_can__c
		    	ORDER BY Code_Type_can__c asc];
		    	
		    List<String> mainErrorsDesc = new List<String>();
		    
		    for (AggregateResult ar : mainErrorTypesStats) {
		    	mainErrorsDesc.add(ar.get('Code_Type_can__c') + ' - ' + ar.get('nor'));
		    }
		    
		    if(!mainErrorsDesc.isEmpty()) {
		    	out += 'Reported Exceptions: ' + String.join(mainErrorsDesc, ',')  + '.\n';
		    }
		    
	    	AggregateResult[] knownErrorStats = 
		    	[SELECT Error_Type_can__c, count(Id) nor
		    	FROM Stg_SFA_Subscribe_Apex_Job_Error__c
		    	WHERE
		    		Job_Id_can__c = :job.Id
		    		AND Code_Type_can__c = :GNE_CAN_Subscribe_Util.SUBSCRIBE_ERROR_CODE
		    	GROUP BY Error_Type_can__c
		    	ORDER BY Error_Type_can__c asc];
		    	
		    List<String> knownExeptionDesc = new List<String>();
		    
		    for (AggregateResult ar : knownErrorStats) {
		    	knownExeptionDesc.add(ar.get('Error_Type_can__c') + ' - ' + ar.get('nor'));
		    }
		    
		    if(!knownExeptionDesc.isEmpty()) {
		    	out += 'Subscribe Exceptions Details: ' + String.join(knownExeptionDesc, ', ') + '.\n';
		    }
    	}
	    
	    cachedOut = out;
	    return out;
    }
    
}