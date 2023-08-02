@RestResource(urlMapping='/DBCacheManager/init/*')
global without sharing class GNE_SFA2_DBCacheManager {
    private static final String RECORD_TYPE_HCO = 'Hospital_vod';
    private static final String RECORD_TYPE_HCP = 'Professional_vod';
    private static final String RECORD_TYPE_ADDRESS = 'RepMaintained';
    
    @RemoteAction @HttpPost
    global static void initDmlCache(Boolean syncMode) {
        if(syncMode == true || System.isFuture() || System.isQueueable() || System.isBatch() || System.isScheduled()) {
            intInitDmlCache();
        } else {
            initDmlCacheFuture();
        }
    }
    
    public static void initDmlCache() {
        initDmlCache(false);
    }
    
    @future
    private static void initDmlCacheFuture() {
        intInitDmlCache();
    }
        
    private static void intInitDmlCache() {
        System.savepoint sp = Database.setSavePoint();
        
        try {
            insertRecords();
        } finally {
            Database.rollback(sp);
        }
    }
    
    private static void insertRecords() {
        Map<String, Id> rtName2Id = createMapRT();
        List<SObject> recs = createRecords(rtName2Id);
        saveRecords(recs);  
        
    }
    
    private static void saveRecords(List<SObject> recs) {
        Database.SaveResult[] sResults = Database.insert(recs, false);        
        handleErrors(sResults);
    }
    
    private static void handleErrors(List<Database.SaveResult> sResults){
        for(Database.SaveResult sr : sResults) {
            if(!sr.isSuccess()) {
                handleException(sr.getErrors());
            }
        }        
    }
    
    private static List<SObject> createRecords(Map<String, Id> rtName2Id){
        return new List<SObject>{
            new Account(FirstName = 'Init', LastName = 'DB Cache', RecordTypeId = rtName2Id.get(RECORD_TYPE_HCP), MDMID_gne__c = 'InitDBCacheHCP'),
            new Account(Name = 'Init DB Cache', RecordTypeId = rtName2Id.get(RECORD_TYPE_HCO), MDMID_gne__c = 'InitDBCacheHCO'),
            new Address_vod__c(Account_vod__r = new Account(MDMID_gne__c = 'InitDBCacheHCP'), RecordTypeId = rtName2Id.get(RECORD_TYPE_ADDRESS),
                Name = 'Init', City_vod__c = 'DB Cache', State_vod__c = 'AL', Zip_vod__c = '11111'),
            new Address_vod__c(Account_vod__r = new Account(MDMID_gne__c = 'InitDBCacheHCO'), RecordTypeId = rtName2Id.get(RECORD_TYPE_ADDRESS),
                Name = 'Init', City_vod__c = 'DB Cache', State_vod__c = 'AL', Zip_vod__c = '11111')
        };
    }
    
    private static Map<String, Id> createMapRT(){
        Map<String,Id> rtName2Id = new Map<String,Id>();
        
        for(RecordType rt : [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE SObjectType IN ('Account','Address_vod__c')
                AND DeveloperName IN (:RECORD_TYPE_HCP, :RECORD_TYPE_HCO, :RECORD_TYPE_ADDRESS)
        ]) {
            rtName2Id.put(rt.DeveloperName, rt.Id);
        }
        return rtName2Id;
    }
    
    private static void handleException(Database.Error[] errors) {
        for(Database.Error err : errors) {
            System.debug('Init DB Cache Error: ' + err.getMessage());
        }
    }
}