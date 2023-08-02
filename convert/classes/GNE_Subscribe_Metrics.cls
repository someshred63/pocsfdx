public class GNE_Subscribe_Metrics {
    public enum MetricTypeName {INSERT_UPDATE, ERROR, UNALIGN}
    public enum EntityTypeName {ACCOUNT, ADDRESS, ACCOUNT_EXTERNAL, ADDRESS_EXTERNAL, STATE_MEDICAL_LICENSE, ERROR, TOTAL, UNDEFINED, STAGING_ALIGNMENT, ACCOUNT_SHARE, TSF}    
    public EntityTypeName entityType; 
    public Integer upsertCount;
    public Integer deleteCount;   
    public Integer errorCount;    
    public List<SObject> upsertList;
    public List<GNE_Subscribe_Metrics> relatedSubscribeMetrics;    
    
    public GNE_Subscribe_Metrics() {
        entityType 				= EntityTypeName.TOTAL; 
        upsertCount 			= 0;
        deleteCount				= 0;
        errorCount  			= 0;
        upsertList 				= new List<SObject>();
        relatedSubscribeMetrics = new List<GNE_Subscribe_Metrics>();
    }
    
    public void resetUpsertLists() {
    	upsertList = new List<SObject>();
		for (Integer i = 0; i < relatedSubscribeMetrics.size(); i++) {
			relatedSubscribeMetrics[i].upsertList = new List<SObject>();
		}
    }
}