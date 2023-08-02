public abstract class SPCM_eWorkflowBaseUtils
{

    // abstract methods (must be overridden in subclass)
    protected abstract Integer GetMaxConcurrentApprovers();
    protected abstract String GetEmailRecallTemplate();
    protected abstract String GetObjectType();
    protected abstract String GetHistoryKeyField();

    // virtual handler for before insert events
    public virtual void HandleBeforeInsert(List<SObject> newRecords)
    {

        // reset some system fields (necessary for after clone operation)
        for (SObject record : newRecords)
        {

            // reset request fields
            record.put('Approval_Status__c', 'New');
            record.put('Initiated_By__c', UserInfo.getUserId());
            record.put('Submitted_Date__c', null);
            record.put('Actual_Final_Approval_Date__c', null);
            record.put('Reason_Code__c', null);

            // reset approval fields
            record.put('Appr_Approval_Level__c', null);
            record.put('Appr_Prior_Approval_Level__c', null);
            record.put('Appr_Update_Date__c', null);
            for (integer fieldNum = 1; fieldNum <= GetMaxConcurrentApprovers(); fieldNum++)
            {
                record.put('Appr_Approver_' + fieldNum + '__c', null);
                record.put('Appr_Approver_' + fieldNum + '_Original__c', null);
                record.put('Appr_Approver_' + fieldNum + '_Process_Level__c', null);
                record.put('Appr_Prior_Approver_' + fieldNum + '__c', null);
                record.put('Appr_Prior_Approver_' + fieldNum + '_Original__c', null);
                record.put('Appr_Prior_Approver_' + fieldNum + '_Process_Level__c', null);
            }
        }

        // update record type for new records
        UpdateRecordType(newRecords);
    }

    // virtual handler for before update events
    public virtual void HandleBeforeUpdate(List<SObject> oldRecords,
        List<SObject> newRecords)
    {

        // loop through records
        List<SObject> approvalNewRecords = new List<SObject>();
        List<SObject> approvalOldRecords = new List<SObject>();
        List<SObject> recalledRecords = new List<SObject>();
        List<String> syncRecords = new List<String>();
        for (integer i = 0; i < oldRecords.size(); i++)
        {

            // extract approval events
            if (oldRecords[i].get('Appr_Approval_Level__c') != newRecords[i].get('Appr_Approval_Level__c'))
            {

                // add to new and old lists
                approvalNewRecords.add(newRecords[i]);
                approvalOldRecords.add(oldRecords[i]);

                // if this record should have history sync'd
                if (newRecords[i].get('Appr_Approval_Level__c') != null ||
                    newRecords[i].get('Approval_Status__c') == 'Rejected' ||
                    newRecords[i].get('Approval_Status__c') == 'Recalled')
                {
                    syncRecords.add(newRecords[i].Id);
                }
            }

            // extract recall events
            if (newRecords[i].get('Approval_Status__c') == 'Recalled' &&
                oldRecords[i].get('Approval_Status__c') != newRecords[i].get('Approval_Status__c'))
            {
                recalledRecords.add(newRecords[i]);
            }
        }

        // if there are any approval events
        if (approvalNewRecords.size() > 0)
        {

            // create helper objects
            SPCM_ApprovalProcessConfig processConfig = new SPCM_ApprovalProcessConfig();
            GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            SPCM_ApprovalManager approvalMgr = new SPCM_ApprovalManager(roleConfig, processConfig);

            // handle approval events
            HandleApprovalEvents(approvalNewRecords, approvalOldRecords, processConfig, roleConfig, approvalMgr);

            Map<Id, List<String>> recordPriorApprIds = new Map<Id, List<String>>();
            Map<Id, List<String>> recordPriorOrigApprIds  = new Map<Id, List<String>>();
            Map<Id, List<String>> recordPriorApprLevelIds  = new Map<Id, List<String>>();
            Map<Id, Map<String, Datetime>> recordPriorDates  = new Map<Id, Map<String, Datetime>>();
            Map<Id, Boolean> finalApprovalDateSet = new Map<Id, Boolean>();

            for (SObject record : approvalNewRecords) {
                // loop through approver fields
                List<String> priorApprIds = new List<String>();
                List<String> priorOrigApprIds = new List<String>();
                List<String> priorApprLevelIds = new List<String>();
                Map<String, Datetime> priorDates = new Map<String, Datetime>();
                for (integer fieldNum = 1; fieldNum <= GetMaxConcurrentApprovers(); fieldNum++)
                {

                    // if this is the second or later approver fields
                    if (fieldNum > 1)
                    {

                        // if this approver field equals the last, then break loop as we are now
                        // hitting dup approvers
                        if (String.valueOf(record.get('Appr_Prior_Approver_' + fieldNum + '_Original__c')) ==
                            String.valueOf(record.get('Appr_Prior_Approver_' + (fieldNum - 1) + '_Original__c')))
                        {
                            break;
                        }
                    }

                    // add approver field values to various lists
                    priorApprIds.add(String.valueOf(record.get('Appr_Prior_Approver_' + fieldNum + '__c')));
                    priorOrigApprIds.add(String.valueOf(record.get('Appr_Prior_Approver_' + fieldNum + '_Original__c')));
                    priorApprLevelIds.add(String.valueOf(record.get('Appr_Prior_Approver_' + fieldNum + '_Process_Level__c')));
                    priorDates.put(String.valueOf(record.get('Appr_Prior_Approver_' + fieldNum + '__c')), null);
                }

                recordPriorApprIds.put(record.Id, priorApprIds);
                recordPriorOrigApprIds.put(record.Id, priorOrigApprIds);
                recordPriorApprLevelIds.put(record.Id, priorApprLevelIds);
                recordPriorDates.put(record.Id, priorDates);
                finalApprovalDateSet.put(record.Id, record.get('Actual_Final_Approval_Date__c') != null);
            }
            // sync approval history
            system.enqueueJob(new SyncApprovalHistory(syncRecords, GetObjectType(), GetHistoryKeyField(), GetMaxConcurrentApprovers(), recordPriorApprIds, recordPriorOrigApprIds, recordPriorApprLevelIds, recordPriorDates, finalApprovalDateSet));
        }

        // if there are any recall events
        if (recalledRecords.size() > 0)
        {
            SPCM_EmailUtils.SendRecallNotifications(recalledRecords, GetEmailRecallTemplate());
        }

        // update record type for new records
        UpdateRecordType(newRecords);
    }

    // virtual handler for before delete events
    public virtual void HandleBeforeDelete(List<SObject> records)
    {

        // loop through records to get ids
        Set<Id> recordIds = new Set<Id>();
        for (SObject record : records)
        {
            recordIds.add(record.Id);
        }

        // query for custom approval history
        List<SPCM_Approval_History__c> history = Database.query(
            'SELECT Id FROM SPCM_Approval_History__c WHERE ' + GetHistoryKeyField() + ' IN :recordIds');

        // if there are records to delete
        if (history.size() > 0)
        {
            delete(history);
        }
    }

    // method to handle approval events (triggered by current approval level field update)
    protected abstract void HandleApprovalEvents(List<SObject> newRecords,
        List<SObject> oldRecords, SPCM_ApprovalProcessConfig processConfig,
        GNE_BusinessRoleConfig roleConfig, SPCM_ApprovalManager approvalMgr);

    // method to return generic approval error message
    protected virtual String GetApprovalErrorMessage(String approvalType, Decimal approvalLevel)
    {
        return ('Request requires approval but approver definition is incorrect. ' +
                    'Please contact the administrator. Approval Type: ' + approvalType + '; ' +
                    'Approval Level: ' + approvalLevel);
    }

    // updates record type based on approval status
    private virtual void UpdateRecordType(List<SObject> records)
    {

        // get object type
        String objectType = records.size() > 0 ? String.valueOf(records[0].getSObjectType()) : '';

        // create record type map
        Map<String, Id> recordTypes = new Map<String, Id>();
        for (RecordType recordType : [SELECT Id, Name FROM RecordType WHERE SObjectType =
            :objectType])
        {
            recordTypes.put(recordType.Name, recordType.Id);
        }

        // loop through records
        for (SObject record : records)
        {

            // if completed
            String approvalStatus = String.valueOf(record.get('Approval_Status__c'));
            if (approvalStatus == 'Approved' || approvalStatus == 'Rejected' ||
                approvalStatus == 'Withdrawn')
            {
                record.put('RecordTypeId', recordTypes.get('ReadOnly'));
            }
            else
            {
                record.put('RecordTypeId', recordTypes.get('Editable'));
            }
        }
    }

    public class SyncApprovalHistory implements Queueable {
        private List<String> recordIds;
        private String objectType;
        private String historyKeyField;
        private Integer maxConcurrentApprovers;
        private Map<Id, List<String>> recordPriorApprIds;
        private Map<Id, List<String>> recordPriorOrigApprIds;
        private Map<Id, List<String>> recordPriorApprLevelIds;
        private Map<Id, Map<String, Datetime>> recordPriorDates;
        private Map<Id, Boolean> finalApprovalDateSet;

        public SyncApprovalHistory(List<String> recordIds, String objectType, String historyKeyField,
            Integer maxConcurrentApprovers, Map<Id, List<String>> recordPriorApprIds, Map<Id, List<String>> recordPriorOrigApprIds,
            Map<Id, List<String>> recordPriorApprLevelIds, Map<Id, Map<String, Datetime>> recordPriorDates, Map<Id, Boolean> finalApprovalDateSet)  {
            this.recordIds = recordIds;
            this.objectType = objectType;
            this.historyKeyField = historyKeyField;
            this.maxConcurrentApprovers = maxConcurrentApprovers;
            this.recordPriorApprIds = recordPriorApprIds;
            this.recordPriorOrigApprIds = recordPriorOrigApprIds;
            this.recordPriorApprLevelIds = recordPriorApprLevelIds;
            this.recordPriorDates = recordPriorDates;
            this.finalApprovalDateSet = finalApprovalDateSet;
        }

        public void execute(QueueableContext context) {
            List<CommentsWrapper> allComments = new List<CommentsWrapper>();
            // check if running test
            Boolean isRunningTest = Test.isRunningTest();

            // instantiate helper objects
            SPCM_ApprovalProcessConfig processConfig = new SPCM_ApprovalProcessConfig();
            GNE_BusinessRoleConfig roleConfig = new GNE_BusinessRoleConfig();
            SPCM_ApprovalManager approvalMgr = new SPCM_ApprovalManager(roleConfig, processConfig);

            // query for custom approval history for records
            Set<Id> customHistory = new Set<Id>();
            List<SPCM_Approval_History__c> historyRecords = Database.query(
                'SELECT Id, name, Process_Step_ID__c, Comments__c, ' + historyKeyField +
                ' FROM SPCM_Approval_History__c WHERE ' + historyKeyField + ' IN :recordIds' +
                ' ORDER BY ' + historyKeyField + ' ASC, CreatedDate ASC');
            for (SPCM_Approval_History__c historyRecord : historyRecords)
            {
                if (!customHistory.contains(historyRecord.Process_Step_ID__c))
                {
                    customHistory.add(historyRecord.Process_Step_ID__c);
                }
            }

            // query records to get details and process instance history
            List<SPCM_Approval_History__c> newHistoryRecords = new List<SPCM_Approval_History__c>();
            String priorApproverFields = '';
            for (integer fieldNum = 1; fieldNum <= maxConcurrentApprovers; fieldNum++)
            {
                priorApproverFields += 'Appr_Prior_Approver_' + fieldNum + '__c, ';
                priorApproverFields += 'Appr_Prior_Approver_' + fieldNum + '_Original__c, ';
                priorApproverFields += 'Appr_Prior_Approver_' + fieldNum + '_Process_Level__c, ';
            }
            List<SObject> records = Database.query(
                'SELECT Id, Appr_Prior_Approval_Level__c, ' + priorApproverFields + 'Initiated_By__c, (SELECT Id,' +
                ' ProcessInstanceId, CreatedDate, StepStatus, ActorId, OriginalActorId, Comments FROM ProcessSteps' +
                ' WHERE IsPending = false ORDER BY CreatedDate ASC) FROM ' + objectType +
                ' WHERE Id IN :recordIds ORDER BY Id ASC');

            for (SObject record : records)
            {

                // setup various approver lists
                List<String> priorApprIds = recordPriorApprIds.get(record.Id);
                List<String> priorOrigApprIds = recordPriorOrigApprIds.get(record.Id);
                List<String> priorApprLevelIds = recordPriorApprLevelIds.get(record.Id);
                Map<String, Datetime> priorDates = recordPriorDates.get(record.Id);

                // loop through process history for record
                List<SObject> processSteps = record.getSObjects('ProcessSteps');
                if (processSteps == null)
                {
                    processSteps = new List<SObject>();
                }

                // workaround for testing purposes
                if (isRunningTest)
                {

                    // artificially create a process step
                    processSteps.add(new ProcessInstanceHistory());
                }

                // loop through process history records
                for (integer ph = 0; ph < processSteps.size(); ph++)
                {

                    // retrieve process history details
                    ProcessInstanceHistory step = (ProcessInstanceHistory)processSteps[ph];
                    String stepId = isRunningTest ? record.Id : step.Id;
                    String stepStatus = isRunningTest ? 'Started' : step.StepStatus;
                    String actorId = isRunningTest ? priorApprIds[0] : step.ActorId;
                    String originalActorId = isRunningTest ? priorOrigApprIds[0] : step.OriginalActorId;
                    Datetime createdDate = isRunningTest ? Datetime.now() : step.CreatedDate;

                    String processLevelName = '';

                    // if not yet in custom history
                    if (!customHistory.contains(stepId))
                    {

                        // determine values to use
                        String priorApprId = '';
                        String priorOrigApprId = '';
                        String priorApprLevelId = '';

                        // loop through prior approver id list
                        for (integer pi = 0; pi < priorApprIds.size(); pi++)
                        {

                            // if process history original actor equals prior approver or
                            // step is first (started)
                            if (originalActorId == priorApprIds[pi] || stepStatus == 'Started')
                            {

                                // retrieve values from lists
                                priorApprId = priorApprIds[pi];
                                priorOrigApprId = priorOrigApprIds[pi];
                                priorApprLevelId = priorApprLevelIds[pi];

                                // setup values to use
                                String apprId = actorId;
                                String delApprId = stepStatus == 'Started' ? null : priorApprId != priorOrigApprId ?
                                    priorApprId : null;
                                String origApprId = stepStatus == 'Started' ? actorId : priorOrigApprId;
                                Datetime priorEnd = priorDates.containsKey(priorApprId) ? priorDates.get(priorApprId) : null;
                                Datetime startDate = stepStatus == 'Started' ? createdDate : priorEnd == null ?
                                    createdDate : priorEnd;
                                Datetime endDate = createdDate;
                                String apprStatus = stepStatus == 'Started' ? 'Submitted' : stepStatus == 'Removed' ?
                                    'Recalled' : stepStatus == 'NoResponse' ? 'No Response' : stepStatus;

                                // get process level information for role and level name
                                SPCM_Approval_Process_Level__c processLevel = approvalMgr.GetProcessLevelById(priorApprLevelId);
                                String apprRole = '';
                                String apprLevelName = '';
                                if (processLevel != null)
                                {
                                    apprRole = processLevel.Business_Role__r.Name;
                                    apprLevelName = processLevel.Name;
                                }
                                apprLevelName = stepStatus == 'Started' ? 'Approval Request Submitted' :
                                    stepStatus == 'Removed' ? 'Approval Request Recalled' : apprLevelName;

                                // create new custom history record
                                SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c(
                                    Process_Step_ID__c = stepId,
                                    Original_Approver__c = origApprId,
                                    Delegated_Approver__c = delApprId,
                                    Actual_Approver__c = apprId,
                                    Comments__c = step.Comments,
                                    Start_Date__c = startDate,
                                    Approval_Status__c = apprStatus,
                                    End_Date__c = endDate,
                                    Approval_Role__c = apprRole,
                                    Name = apprLevelName);
                                newHistoryRecord.put(historyKeyField, record.Id);
                                newHistoryRecords.add(newHistoryRecord);

                                // update this approver prior date value
                                priorDates.put(priorApprId, endDate);

                                //set process level name for new record
                                processLevelName = apprLevelName;
                            }
                        }
                    }
                    else
                    {
                        // update all approver prior dates
                        for (String key : priorDates.keySet())
                        {
                            priorDates.put(key, createdDate);
                        }
                    }

                    // get all history comments
                    // get all history process levels
                    List<SPCM_Approval_History__c> processLevel = [select name from SPCM_Approval_History__c where Process_Step_ID__c = :step.id];
                    // if not found for current item, processLevelName is already set
                    processLevelName = processLevel.isEmpty() ? processLevelName : processLevel[0].name;

                    // get approver name from processStep actorId
                    String actorName = [select name from user where id = :actorId].name;
                }
            }
            // insert custom history records if necessary
            if (newHistoryRecords.size() > 0)
            {
                insert(newHistoryRecords);
                // Get all Comments to notification email
                for (SObject o: Database.query('SELECT Id FROM ' + objectType + ' WHERE Id IN :recordIds'))
                {
                    String id = o.Id;
                    for (SObject h: Database.query(
                            'SELECT id, name, Process_Step_ID__c, Comments__c, Actual_Approver__r.Name ' +
                                    'FROM SPCM_Approval_History__c ' +
                                    'WHERE ' +
                                    historyKeyField + ' = :id ' +
                                    'ORDER BY End_Date__c'))
                    {
                        SPCM_Approval_History__c history = (SPCM_Approval_History__c) h;
                        System.debug(h);
                        allComments.add(new CommentsWrapper(history.Actual_Approver__r.Name ,history.Comments__c, history.Name));
                    }
                }
                for(SPCM_Approval_History__c historyRecord : newHistoryRecords){
                    if (historyRecord.Approval_Status__c == 'Approved' || historyRecord.Approval_Status__c == 'Rejected')
                    {
                        system.debug(loggingLevel.error, finalApprovalDateSet.keySet());
                        system.debug(loggingLevel.error, historyKeyField);
                        system.debug(loggingLevel.error, (ID)historyRecord.get(historyKeyField));

                        SPCM_EmailNotifier.Notify((string)historyRecord.get(historyKeyField), historyRecord.Comments__c, allComments, historyRecord.Approval_Status__c, finalApprovalDateSet.get((Id)historyRecord.get(historyKeyField)));
                    }

                }
            }
        }
    }

    public class CommentsWrapper
    {
        public CommentsWrapper(string approver, string comment, string levelName)
        {
            this.Approver = approver;
            this.Comment = comment;
            this.LevelName = levelName;
        }
        public String Approver {get; set;}
        public String Comment {get; set;}
        public String LevelName {get; set;}
    }
}