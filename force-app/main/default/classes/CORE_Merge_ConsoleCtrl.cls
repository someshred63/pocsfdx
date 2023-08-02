public without sharing class CORE_Merge_ConsoleCtrl {
    
    public Boolean forceIsJobInProgress {get; private set;}
    public String mergeDataAsJson {get; set;}
    private Id mergeObjectId;
    
    private transient Boolean isJobInProgress;
    private transient Boolean canEditMergeObject;
    private transient Boolean hasAccessToMergeBatch;
    private transient Boolean hasAccessToPopulateCandidatesBatch;
    private transient Boolean canExecuteMerge;
    private transient Boolean canExecuteMergeInPreviewMode;
    private transient Boolean canExecutePopulateCandidates;
    private transient CORE_Merge_Util.MergeJobWrapper currentMergeJob;
    private transient List<CORE_Merge_Util.MergeObjectWrapper> mergeObject;
    private transient Map<System.Type,Boolean> hasAccessToClass;
    
    public static final String ERROR_MESSAGE_PROCESS_IS_ALREADY_RUNNING = 'Merge Job already in progress.';
    public static final String ERROR_MESSAGE_INSUFFICIENT_PRIVILEGES = 'You do not have sufficient privileges to execute this process. Please contact your System Administrator.';
    
    private Datetime stopingTime;
    private Datetime stopingTimeTEmp;
    private Boolean isStoped;
    private Boolean isOnInit;
    
    public CORE_Merge_ConsoleCtrl(ApexPages.StandardController controller) {
        this(controller.getRecord());
    }
    
    public CORE_Merge_ConsoleCtrl() {
        this((SObject)null);
    }
    
    public CORE_Merge_ConsoleCtrl(SObject rec) {
        if(rec!=null) {
            if(rec instanceof CORE_Merge_Object__c) {
                mergeObjectId = rec.Id;
            } else if(rec instanceof CORE_Merge_Job__c) {
                for(CORE_Merge_Job__c mj : [SELECT Merge_Object_gne__c FROM CORE_Merge_Job__c WHERE Id = :rec.Id LIMIT 1]) {
                    mergeObjectId = mj.Merge_Object_gne__c;
                }
            } else if(rec instanceof CORE_Merge_Candidate__c) {
                for(CORE_Merge_Candidate__c mc : [SELECT Merge_Object_gne__c FROM CORE_Merge_Candidate__c WHERE Id = :rec.Id LIMIT 1]) {
                    mergeObjectId = mc.Merge_Object_gne__c;
                }
            }
        }
        
        if(mergeObjectId==null) {
            Integer regionCode = 1;
            
            try {
                Id userId = UserInfo.getUserId();
                for(User u : Database.query('SELECT Region_Code_gne__c FROM User WHERE Id = :userId')) {
                    regionCode = Integer.valueOf(u.get('Region_Code_gne__c'));
                }
            } catch(Exception ex) {}
            
            for(CORE_Merge_Object__c mObj : [SELECT Id FROM CORE_Merge_Object__c WHERE Region_Code_gne__c = :regionCode AND Parent_Merge_Object_gne__c = null LIMIT 1]) {
                mergeObjectId = mObj.Id;
            }
        }
        
        if(getIsJobInProgress()) {
            addJobProgressInfo();
        }
        isOnInit = true;
    }
    
    private CORE_Merge_Util.MergeObjectWrapper getMergeObject() {
        if(this.mergeObject==null) {
            try {
                this.mergeObject = new List<CORE_Merge_Util.MergeObjectWrapper>{new CORE_Merge_Util.MergeObjectWrapper(new CORE_Merge_Object__c(Id = mergeObjectId))};
                this.mergeObject[0].getMergeObject();
            } catch(Exception ex) {
                this.mergeObject = new List<CORE_Merge_Util.MergeObjectWrapper>{null};
            } 
        }
        
        return this.mergeObject[0];
    }
    
    private CORE_Merge_Util.MergeJobWrapper getCurrentMergeJob() {
        if(this.forceIsJobInProgress==true) {
            this.currentMergeJob=null;
        }
        
        if(this.currentMergeJob==null) {
            this.currentMergeJob = CORE_Merge_Util.getCurrentJob();
        }
        
        return this.currentMergeJob;
    }
    
    public Boolean getIsJobInProgressExtended() {    
        Boolean isInProgress = getCurrentMergeJob().isInProgress();
        Boolean isJobInProgressTemp = isInProgress;

        DateTime dt = System.now(); 

        if(isJobInProgressTemp != true && isStoped == false && isOnInit == false){ 
            stopingTime = dt.addMinutes(1);
            isStoped = true;
            isJobInProgressTemp = true;
        } else if(isJobInProgressTemp != true && isStoped == true && isOnInit == false) {
            System.debug('STOPED stopingTime '+stopingTime);            
        } else if(isInProgress) {
            isStoped = false;
            stopingTime = dt;
        }

        if(stopingTime > System.now()){
            isJobInProgressTemp = true;
        }

        isOnInit = false;
        
        return isJobInProgressTemp;
    }
    
    public Boolean getIsJobInProgress() {
        if(this.forceIsJobInProgress==true) {
            this.isJobInProgress=null;
        }
        
        if(this.isJobInProgress==null) {
            this.isJobInProgress = getCurrentMergeJob().isInProgress();
        }
        
        return this.isJobInProgress;
    }
    
    public Boolean getCanEditMergeObject() {
        if(this.canEditMergeObject==null) {
            Id userId = UserInfo.getUserId();
            Id mObjId = getMergeObject()!=null ? getMergeObject().getMergeObject().Id : null;
            this.canEditMergeObject = mObjId!=null && ![SELECT RecordId FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :mObjId AND HasEditAccess = true LIMIT 1].isEmpty(); 
        }
        
        return this.canEditMergeObject;
    }
    
    
    
    public Boolean getHasAccessToMergeBatch() {
        if(this.hasAccessToMergeBatch==null) {
            this.hasAccessToMergeBatch = getMergeObject()!=null && hasAccessToClass(UserInfo.getUserId(), UserInfo.getProfileId(), CORE_Merge_Engine_Batch.class);
        }
        
        return this.hasAccessToMergeBatch;
    }
    
    public Boolean getCanExecuteMerge() {
        if(this.canExecuteMerge==null) {
            this.canExecuteMerge = !getIsJobInProgress() && getMergeObject()!=null && getHasAccessToMergeBatch();
        }
        
        return this.canExecuteMerge;
    }
    
    public Boolean getCanExecuteMergeInPreviewMode() {
        if(this.canExecuteMergeInPreviewMode==null) {
            this.canExecuteMergeInPreviewMode = getCanExecuteMerge();
        }
        
        return this.canExecuteMergeInPreviewMode;
    }
    
    public Boolean getHasAccessToPopulateCandidatesBatch() {
        if(this.hasAccessToPopulateCandidatesBatch==null) {
            this.hasAccessToPopulateCandidatesBatch = getMergeObject()!=null && getMergeObject().isPopulateCandidatesEnabled() && hasAccessToClass(UserInfo.getUserId(), UserInfo.getProfileId(), CORE_Merge_Populate_Candidates_Batch.class);
        }
        
        return this.hasAccessToPopulateCandidatesBatch;
    }
    
    public Boolean getCanExecutePopulateCandidates() {
        if(this.canExecutePopulateCandidates==null) {
            this.canExecutePopulateCandidates = !getIsJobInProgress() && getHasAccessToPopulateCandidatesBatch();
        }
        
        return this.canExecutePopulateCandidates;
    }
    
    private Boolean hasAccessToClass(Id userId, Id profileId, System.Type classType) {
        if(this.hasAccessToClass==null) {
            this.hasAccessToClass = new Map<System.Type, Boolean>();
        }
        
        if(!this.hasAccessToClass.containsKey(classType)) {
            String className = classType.getName().substringBefore('.');
            this.hasAccessToClass.put(classType,![
                SELECT Id
                FROM SetupEntityAccess
                WHERE
                        SetupEntityId IN (SELECT ID FROM ApexClass WHERE Name = :className)
                    AND ParentId IN (SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId)
            ].isEmpty() || ![
                SELECT Id
                FROM SetupEntityAccess
                WHERE
                        SetupEntityId IN (SELECT ID FROM ApexClass WHERE Name = :className)
                    AND Parent.ProfileId = :profileId
            ].isEmpty());
        }
        
        return this.hasAccessToClass.get(classType);
    }
    
    public PageReference executeMerge() {
        MergeData mData = (MergeData)JSON.deserialize(mergeDataAsJson,MergeData.class);
        Boolean canExecute = mData.isPreviewMode() ? getCanExecuteMergeInPreviewMode() : getCanExecuteMerge();
        
        if(canExecute) {
            this.forceIsJobInProgress = true;
            getMergeObject().executePreProcessJob(mData.isPreviewMode(), mData.getWinnerIds(), mData.getScopeLimit(), mData.getDurationLimit());            
            addJobProgressInfo();
        } else {
            displayError();
        }
        
        return null;   
    }
    
    public PageReference executePopulateCandidates() {
        if(getCanExecutePopulateCandidates()) {
            this.forceIsJobInProgress = true;
            getMergeObject().executePopulateCandidatesJob();
            addJobProgressInfo();
        } else {
            displayError();
        }
        
        return null;
    }
    
    private void displayError() {
        if(getIsJobInProgress()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, ERROR_MESSAGE_PROCESS_IS_ALREADY_RUNNING));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ERROR_MESSAGE_INSUFFICIENT_PRIVILEGES));
        }
    }
    
    public PageReference actionPollerSupport() {
        addJobProgressInfo();
        this.forceIsJobInProgress = false;
        return null;
    }
    
    private void addJobProgressInfo() {
        CORE_Merge_Util.MergeJobWrapper job = getCurrentMergeJob();
        String jobProgressHtml = String.format('Current {0}<br/><progress value="{1}" max="{2}"></progress>', new String[]{
            job.getProgressDescription(true).replaceAll('\\n','<br/>'),
            String.valueOf(job.getProcessedBatchesSize()),
            String.valueOf(job.getAllBatchesSize())
        });
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,jobProgressHtml));
    }
    
    public List<QuickLinkWrapper> getQuickLinks() {
        List<QuickLinkWrapper> result = new List<QuickLinkWrapper>();
        
        List<Schema.SObjectType> sObjectTypes = new List<Schema.SObjectType>{
            CORE_Merge_Job__c.sObjectType,
            CORE_Merge_Configuration__c.sObjectType,
            CORE_Merge_Candidate__c.sObjectType,
            CORE_Merge_Archive_Record__c.sObjectType,
            CORE_Merge_Error__c.sObjectType
        };
        
        for(Schema.SObjectType soType : sObjectTypes) {
            Schema.DescribeSObjectResult soDescribe = soType.getDescribe();
            
            if(soDescribe.isAccessible()) {
                QuickLinkWrapper link = new QuickLinkWrapper('/' + soDescribe.getKeyPrefix(), soDescribe.getLabelPlural(), result.isEmpty(), false);
                result.add(link);
            }
        }
        
        String wikiUrl = CORE_Merge_Configuration.getPropertyStringValue(new CORE_Merge_Object__c(Id = mergeObjectId), CORE_Merge_Configuration.MergeProperty.WikiPage);
        
        if(String.isNotBlank(wikiUrl)) {
            result.add(new QuickLinkWrapper(wikiUrl, 'Wiki Page', result.isEmpty(), true));
        }

        return result;
    }
    
    public class QuickLinkWrapper {
        public String url {get; private set;}
        public String title {get; private set;}
        public Boolean isFirst {get; private set;}
        public Boolean isTargetBlank {get; private set;}
        
        public QuickLinkWrapper(String url, String title, Boolean isFirst, Boolean isTargetBlank) {
            this.url = url;
            this.title = title;
            this.isFirst = isFirst;
            this.isTargetBlank = isTargetBlank;
        }
    }
    
    @TestVisible private class MergeData {
        @TestVisible private Boolean previewMode;
        @TestVisible private Integer scopeLimit;
        @TestVisible private Long durationLimit;
        @TestVisible private List<String> winnerIds;
        
        @TestVisible private MergeData(Boolean previewMode, List<String> winnerIds, Integer scopeLimit, Long durationLimit) {
            this.previewMode = previewMode;
            this.winnerIds = winnerIds;
            this.scopeLimit = scopeLimit;
            this.durationLimit = durationLimit;   
        }
        
        private Boolean isPreviewMode() {
            return previewMode==true;
        }
        
        private Integer getScopeLimit() {
            return scopeLimit;
        }
        
        private Long getDurationLimit() {
            return durationLimit;
        }
        
        private Set<String> getWinnerIds() {
            return winnerIds!=null ? new Set<String>(winnerIds) : null;
        }
    }
}