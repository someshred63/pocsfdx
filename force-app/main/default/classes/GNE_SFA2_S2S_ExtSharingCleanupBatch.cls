public without sharing class GNE_SFA2_S2S_ExtSharingCleanupBatch implements Database.Batchable<sObject>, Database.Stateful, GNE_SFA2_Scheduler.Schedulable {
    private Map<Id,String> connectionIdToExtSystemMap;
    private Set<String> connectedObjectsNeedCleanup;
    private transient List<DmlError> dmlErrors;
    
    public GNE_SFA2_S2S_ExtSharingCleanupBatch() {
        this.connectionIdToExtSystemMap = new Map<Id,String>();
        
        for(String extSystem : GNE_SFA2_S2S_Config.getConnectionIdsMap().keySet()) {
            this.connectionIdToExtSystemMap.put(GNE_SFA2_S2S_Config.getConnectionId(extSystem), extSystem);
        }
        
        this.connectedObjectsNeedCleanup = GNE_SFA2_S2S_Config.getConnectedObjectsNeedCleanup();
    }
    
    public System.Type getSelfClass() {
        return GNE_SFA2_S2S_ExtSharingCleanupBatch.class;
    }
    
    public Set<Id> getConnectionIds() {
        return getConnectionIdToExtSystemMap().keySet();
    }
    
    public void execute(GNE_SFA2_Scheduler.SchedulableContext sc) {
        Database.executeBatch(this, 50);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT LocalRecordId, ConnectionId
            FROM PartnerNetworkRecordConnection
            WHERE Status IN :GNE_SFA2_S2S_Util.EXT_SHARING_INACTIVE_STATUSES
                AND ConnectionId IN :getConnectionIds()
                AND EndDate >= :getLastProcessExecutionTime(bc)
            ORDER BY LocalRecordId              
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        List<PartnerNetworkRecordConnection> pnrcs = (List<PartnerNetworkRecordConnection>)scope;
        Map<String,Set<Id>> sObjectToIdsMap = new Map<String,Set<Id>>();
        Map<String,String> sOBjectToExtSystemMap = new Map<String,String>();
        Set<String> extSystems = new Set<String>();
        
        for(PartnerNetworkRecordConnection pnrc : pnrcs) {
            if(pnrc.LocalRecordId!=null) {
                String soType = pnrc.LocalRecordId.getSObjectType().getDescribe().getName().toUpperCase();
                
                if(getConnectedObjectsNeedCleanup().contains(soType)) {
                    String extSystem = getConnectionIdToExtSystemMap().get(pnrc.ConnectionId);
                    extSystems.add(extSystem);
                    sOBjectToExtSystemMap.put(soType, extSystem);
                    
	                if(!sObjectToIdsMap.containsKey(soType)) {
	                    sObjectToIdsMap.put(soType, new Set<Id>());
	                }
	                
	                sObjectToIdsMap.get(soType).add(pnrc.LocalRecordId);
                }
            }
        }
        
        for(String soType : sObjectToIdsMap.keySet()) {
            String extSystem = sOBjectToExtSystemMap.get(soType);
            Set<Id> ids = sObjectToIdsMap.get(soType);
            List<SObject> recs = Database.query(String.format('SELECT Id FROM {0} WHERE {1}', new String[]{
                soType,
                'ID IN :ids'
            }));
            
            if(!recs.isEmpty()) {
                Database.DeleteResult[] dmlResults = Database.delete(recs, false);
                
                Integer idx=0;
                for(Database.DeleteResult dmlResult : dmlResults) {
                    SObject rec = recs[idx++];
                    
                    if(!dmlResult.isSuccess()) {
                        for(Database.Error err : dmlResult.getErrors()) {
                            addDmlError(new DmlError(soType, rec.Id, err.getMessage(), extSystem));
                        }
                    }
                }
            }
        }
        
        processDmlErrors(extSystems.size()==1 ? new List<String>(extSystems)[0] : null);
    }
    
    public void finish(Database.BatchableContext bc) {}
    
    private Map<Id,String> getConnectionIdToExtSystemMap() {
        return this.connectionIdToExtSystemMap;
    }
    
    private Set<String> getConnectedObjectsNeedCleanup() {
        return this.connectedObjectsNeedCleanup;
    }
    
    private List<DmlError> getDmlErrors() {
       if(this.dmlErrors==null) {
           this.dmlErrors = new List<DmlError>();
       }
       
       return this.dmlErrors;
    }
    
    private DateTime getLastProcessExecutionTime(Database.BatchableContext bc) {
        DateTime result = null;
        Id currentJobId = bc!=null ? bc.getJobId() : null;
        
        for(AsyncApexJob job : [SELECT CreatedDate 
                                FROM AsyncApexJob
                                WHERE ApexClass.Name = :getSelfClass().getName()
                                    AND Id <> :currentJobId
                                    AND ParentJobId = null
                                    AND JobType = 'BatchApex'
                                    AND Status = 'Completed'
                                    AND NumberOfErrors = 0
                                ORDER BY CreatedDate desc
                                LIMIT 1]) {
            result = job.CreatedDate; 
        }

        return result!=null ? result : DateTime.now().addDays(-60);        
    }
    
    private void addDmlError(DmlError err) {
        getDmlErrors().add(err);
    }
    
    private void processDmlErrors(String extSystem) {
        GNE_SFA2_S2S_Interface.EngineInterface engine = GNE_SFA2_S2S_ServiceEngine.getServiceEngine();
        
        
        if(String.isBlank(extSystem)) {
            Set<String> extSystems = new Set<String>();
            
            for(DmlError dmlError : getDmlErrors()) {
                extSystems.add(dmlError.getExternalSystem());
            }
            
            extSystem = extSystems.size()==1 ? new List<String>(extSystems)[0] : null;
        }
        
        
        engine.initServiceEngine(extSystem, GNE_SFA2_S2S_Util.SCHEDULER_JOB_EXT_SHARING_CLEANUP).saveLogs(getDmlErrors(), getDmlErrors().isEmpty());
    }
    
    private class DmlError implements GNE_SFA2_S2S_Interface.ErrorInterface {
        private String sObjectType;
        private Id recId;
        private String message;
        private String extSystem;
        
        private DmlError(String sObjectType, Id recId, String message, String extSystem) {
            this.sObjectType = sObjectType;
            this.recId = recId;
            this.message = message;
            this.extSystem = extSystem;
        }
        
        public String getLocalId() {
            return this.recId;    
        }
        
        public String getExtId() {
            return null;    
        }
        
        public String getErrorCode() {
            return this.sObjectType + '-DeleteError';
        }
        
        public String getErrorMessage() {
            return this.message;
        }
        
        public String getShortMessage() {
            return this.message;
        }
        
        public String getStackTrace() {
            return null;
        }
        
        private String getExternalSystem() {
            return this.extSystem;
        }
    }
}