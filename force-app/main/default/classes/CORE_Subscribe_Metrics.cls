public class CORE_Subscribe_Metrics {

    public enum MetricType {
        TOTAL, DETAIL
    }

    public MetricType mType { get; set; }

    public Datetime startTime { get; set; }
    public Datetime endTime { get; set; }

    public Integer partiesNumber { get; set; }
    public Integer validationErrors { get; set; }
    public transient Map<Id, List<CORE_Subscribe_Error__c>> partyToErrors { get; set; }
    public transient Map<Id, CORE_Subscribe_Error__c> partyToValidationErrors { get; set; }

    public String sourceObject { get; set; }
    public String targetObject { get; set; }

    public Integer insertCount { get; set; }
    public Integer updateCount { get; set; }
    public Integer upsertCount { get; set; }
    public Integer errorsCount { get; set; }
    public Integer deleteCount { get; set; }
    public String summary { get; set; }

    public transient List<SObject> upsertedRecords { get; set; }

    public List<CORE_Subscribe_Metrics> relatedMetrics { get; set; }

    public CORE_Subscribe_Metrics() {
        mType = MetricType.TOTAL;
        partiesNumber = 0;
        validationErrors = 0;
        insertCount = 0;
        updateCount = 0;
        upsertCount = 0;
        errorsCount = 0;
        deleteCount = 0;
        partyToErrors = new Map<Id, List<CORE_Subscribe_Error__c>>();
        partyToValidationErrors = new Map<Id, CORE_Subscribe_Error__c>();
        relatedMetrics = new List<CORE_Subscribe_Metrics>();
        upsertedRecords = new List<SObject>();
        startTime = Datetime.now();
    }
}