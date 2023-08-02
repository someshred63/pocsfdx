public without sharing class EMS_Util {
    public class ConfigurationCopyUtil {
        public String newEventType { get; private set; }
        public String newEventSubType { get; private set; }
        public String oldEventType { get; private set; }
        public String oldEventSubType { get; private set; }

        public EMS_Event_Configuration_gne__c eventConfiguration { get; private set; }
        public List<EMS_FMV_Configuration_gne__c> fmvConfiguration { get; private set; }
        public List<EMS_Checklist_gne__c> checklist { get; private set; }
        public List<EMS_Possible_Budget_Allocation_gne__c> possibleBudgetAllocation { get; private set; }

        @SuppressWarnings('ApexUnusedDeclaration')
        public ConfigurationCopyUtil(String oldType, String oldSubType, String newType, String newSubType) {
            queryOldConfiguration(oldType, oldSubType);
            updateConfiguration(newType, newSubType);
        }

        @SuppressWarnings('ApexUnusedDeclaration')
        public ConfigurationCopyUtil(String oldType, String oldSubType) {
            queryOldConfiguration(oldType, oldSubType);
        }

        public void updateConfiguration(String newType, String newSubType) {
            newEventType = newType;
            newEventSubType = newSubType;

            eventConfiguration.Event_Type_gne__c = newType;
            eventConfiguration.Event_Sub_Type_gne__c = newSubType;
            for(EMS_Checklist_gne__c item : checklist) {
                item.Event_Type_gne__c = newType;
                item.Event_Sub_Type_gne__c = newSubType;
            }
        }

        public void saveNewConfiguration(String newType, String newSubType) {
            updateConfiguration(newType, newSubType);
            saveNewConfiguration();
        }

        public void saveNewConfiguration() {
            Savepoint sp = Database.setSavepoint();
            try {
                System.debug(Database.insert(eventConfiguration));

                for(EMS_Possible_Budget_Allocation_gne__c item : possibleBudgetAllocation) {
                    item.EMS_Event_Configuration_gne__c = eventConfiguration.Id;
                }
                for(EMS_FMV_Configuration_gne__c item : fmvConfiguration) {
                    item.EMS_Event_Configuration_gne__c = eventConfiguration.Id;
                }

                for(Database.SaveResult sr : Database.insert(possibleBudgetAllocation)) {
                    System.debug(sr);
                }
                for(Database.SaveResult sr : Database.insert(fmvConfiguration)) {
                    System.debug(sr);
                }
                for(Database.SaveResult sr : Database.insert(checklist)) {
                    System.debug(sr);
                }
            } catch (Exception ex) {
                System.debug('==== Exception: ' + ex);
                Database.rollback(sp);
            }
        }

        public void queryOldConfiguration(String oldType, String oldSubType) {
            oldEventType = oldType;
            oldEventSubType = oldSubType;

            eventConfiguration = [
                    SELECT AARC_Uploads_Contract_gne__c, Budget_Approval_Required_gne__c, Budget_Approved_Label_gne__c,
                            Concur_Allowed_Event_Statuses_gne__c, Description_gne__c, Event_Sub_Type_gne__c, Event_Type_gne__c,
                            External_Id_gne__c, Is_Visible_in_Concur_gne__c, Max_Attendee_Count_gne__c, Pending_Budget_Approval_Label_gne__c,
                            Region_Code_gne__c, Submit_to_Approval_Label_gne__c
                    FROM EMS_Event_Configuration_gne__c
                    WHERE Event_Type_gne__c = :oldType
                    AND Event_Sub_Type_gne__c = :oldSubType
            ].deepClone()[0];
            possibleBudgetAllocation = [
                    SELECT Budget_Type_gne__c, Cost_Elements_gne__c, EMS_Event_Configuration_gne__c, GSD_Type_gne__c,
                            Honorarium_gne__c, Region_Code_gne__c
                    FROM EMS_Possible_Budget_Allocation_gne__c
                    WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :oldType
                    AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :oldSubType
            ].deepClone();
            fmvConfiguration = [
                    SELECT Activity_Time_gne__c, Attendee_Contract_gne__c, Attendee_Status_gne__c, Available_Role_gne__c,
                            Disturbance_Fee_Amount_gne__c, Disturbance_Fee_gne__c, EMS_Event_Configuration_gne__c, FMV_Form_Available_gne__c,
                            Hourly_Rate_of_HCP_gne__c, KM_round_trip_gne__c, Order_gne__c, Preparation_Time_gne__c, RecordTypeId,
                            Speaker_Tour_gne__c, Type_of_HCP_gne__c
                    FROM EMS_FMV_Configuration_gne__c
                    WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :oldType
                    AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :oldSubType
            ].deepClone();
            checklist = [
                    SELECT Depends_On_gne__c, End_Date_gne__c, Event_Sub_Type_gne__c, Event_Type_gne__c, External_Id_gne__c,
                            Has_Depending_Items_gne__c, Has_Parent_gne__c, Index_gne__c, Is_Active_gne__c, Is_All_Choice_gne__c,
                            Is_Checked_gne__c, Is_Dependent_Required_gne__c, Is_Multi_Choice_gne__c, Is_Note_gne__c, Is_One_Choice_gne__c,
                            Is_Parent_gne__c, Item_gne__c, Parent_Index_gne__c, Region_Code_gne__c, Requires_Input_gne__c,
                            Start_Date_gne__c, Type_gne__c, Verison_Number_gne__c
                    FROM EMS_Checklist_gne__c
                    WHERE Event_Type_gne__c = :oldType
                    AND Event_Sub_Type_gne__c = :oldSubType
                    AND Is_Active_gne__c = TRUE
                    AND (End_Date_gne__c = null OR End_Date_gne__c >= :Date.today())
            ].deepClone();
        }
    }

    public static void startBatchJobs() {
        for(String jobName : EMS_ScheduledJobs_Runner.scheduledClasses.keySet()) {
            String jobClass = EMS_ScheduledJobs_Runner.scheduledClasses.get(jobName);
            String cronExpression = EMS_ScheduledJobs_Runner.jobExpressions.get(jobName);

            System.debug(
                    'EMS jobId ' +
                    System.schedule(
                            jobName,
                            cronExpression,
                            (Schedulable) Type.forName(null, jobClass).newInstance()
                    )
            );
        }
    }

    public static void stopBatchJobs() {
        Map<Id, CronJobDetail> cjds = new Map<Id, CronJobDetail>([
                SELECT Name, JobType
                FROM CronJobDetail
                WHERE Name IN :EMS_ScheduledJobs_Runner.scheduledClasses.keySet()
        ]);
        for (CronTrigger job : [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetailId IN :cjds.keySet()
        ]) {
            System.abortJob(job.Id);
        }
    }

    public static void restartEMSScheduledJobs() {
        Map<String, String> scheduledClasses = EMS_ScheduledJobs_Runner.scheduledClasses;

        String jobType = '7'; // Scheduled Apex (7)
        Map<Id, CronJobDetail> cjds = new Map<Id, CronJobDetail>([SELECT Name, JobType FROM CronJobDetail WHERE JobType = :jobType AND Name LIKE 'EMS%']);
        List<CronTrigger> cts = [SELECT CronExpression, State, CronJobDetailId FROM CronTrigger WHERE NextFireTime != NULL AND EndTime = NULL AND CronJobDetailId IN :cjds.keySet() LIMIT 150];

        EMS_ScheduledJobs_Runner scheduledJob = new EMS_ScheduledJobs_Runner();
        for (CronTrigger job : cts) {
            String jobName = cjds.get(job.CronJobDetailId).Name;
            String cronExpression = job.CronExpression;
            String schedulableClass = (scheduledClasses.containsKey(jobName)) ? scheduledClasses.get(jobName) : null;

            if (String.isNotBlank(schedulableClass)) {
                scheduledJob.addJob(jobName, cronExpression, schedulableClass);

                // stop a scheduled job
                System.abortJob(job.Id);
            }
        }

        Datetime nowTime = Datetime.now();
        String cronExpression = nowTime.addMinutes(EMS_ScheduledJobs_Runner.delay).format('ss mm HH dd MM ? yyyy');
        String jobID = System.schedule('EMS Scheduled Job Runner ' + nowTime.format('HH:mm dd/MM/yyyy'), cronExpression, scheduledJob);
    }

    /**
     * To unlock this class for modification please run "restartEMSScheduledJobs()";
     */

    private static Id canadaTaskRecordTypeId = Schema.SObjectType.Task.RecordTypeInfosByName.get('EMS Canada Task').RecordTypeId;
    private static Integer OCTOBER = 10;
    private static Map<Id, User> readOnlyUsers {
        get {
            if (readOnlyUsers == null) {
                readOnlyUsers = new Map<Id, User>([
                        SELECT Id, Email
                        FROM User
                        WHERE Id IN (
                                SELECT AssigneeId
                                FROM PermissionSetAssignment
                                WHERE PermissionSet.Name = 'EMS_Canada_ReadOnly'
                        )
                        AND IsActive = TRUE
                ]);
            }
            return readOnlyUsers;
        }
        private set;
    }
    private static Map<Id, User> CRUsers {
        get {
            if (CRUsers == null) {
                CRUsers = new Map<Id, User>([
                        SELECT Id, Email
                        FROM User
                        WHERE Id IN (
                                SELECT AssigneeId
                                FROM PermissionSetAssignment
                                WHERE PermissionSet.Name = 'EMS_Canada_CR'
                        )
                        AND IsActive = TRUE
                ]);
            }
            return CRUsers;
        }
        private set;
    }
    private static Map<Id, User> adminUsers {
        get {
            if (adminUsers == null) {
                adminUsers = new Map<Id, User>([
                        SELECT Id, Email
                        FROM User
                        WHERE Id IN (
                                SELECT AssigneeId
                                FROM PermissionSetAssignment
                                WHERE PermissionSet.Name = 'EMS_Canada_Admin'
                        )
                        AND IsActive = TRUE
                ]);
            }
            return adminUsers;
        }
        private set;
    }
    private static EMS_Event_Custom_Setting__c eventCustomSettings = EMS_Event_Custom_Setting__c.getValues('EMS_Event');

    public static Boolean oldDataFieldsVisible(DateTime createdDate) {
        if (createdDate < eventCustomSettings.Old_Data_Fields_Removal__c) {
            return true;
        } else {
            return false;
        }
    }

    public static Boolean oldFMVPreceptorshipsHcpToRoche(DateTime createdDate) {
        if (createdDate < eventCustomSettings.Old_FMV_Preceptorships_hcp_to_roche__c) {
            return true;
        } else {
            return false;
        }
    }

    public static Boolean oldFMVFormVisible(DateTime createdDate) {
        if (createdDate < eventCustomSettings.Old_FMV_Form_Change__c) {
            return true;
        } else {
            return false;
        }
    }

    public static Boolean oldDisturbanceFeeLabel(DateTime createdDate) {
        return createdDate.year() < 2017;
    }

    public static String concatenateErrorMessages(Database.UpsertResult result) {
        List<String> errorMessages = new List<String>();
        for (Database.Error error : result.getErrors()) {
            errorMessages.add(error.getStatusCode() + ' : ' + error.getMessage());
        }

        return String.join(errorMessages, '\n\n ------------------- \n\n');
    }

    public static String concatenateErrorMessages(Database.SaveResult result) {
        List<String> errorMessages = new List<String>();
        for (Database.Error error : result.getErrors()) {
            errorMessages.add(error.getStatusCode() + ' : ' + error.getMessage());
        }

        return String.join(errorMessages, '\n\n ------------------- \n\n');
    }

    private static Set<Id> userGroups {
        get {
            if (userGroups == null) {
                Set<Id> territoryIds = new Set<Id>();
                for (EMS_Territory t : EMS_Util.getUserTerritories(UserInfo.getUserId())) {
                    territoryIds.add(t.Id);
                }
                Map<Id, Id> relatedGroups = EMS_Util.getTerritoriesGroups(territoryIds);
                userGroups = new Set<Id>(relatedGroups.values());
            }
            return userGroups;
        }
        set;
    }

    public static String formatCurrency(Decimal amount) {
        String result = amount.setScale(2).format();
        if (result.contains('.')) {
            Integer index = result.lastIndexOf('.');
            Integer length = result.length();
            return (length - index) < 3 ? result + '0' : result;
        } else {
            return result + '.00';
        }
    }

    private static Map<Id, Boolean> recordEditableMap = new Map<Id, Boolean>();
    public static Boolean isRecordEditable(Id objectId) {
        if (recordEditableMap.containsKey(objectId)) {
            return recordEditableMap.get(objectId);
        } else {
            UserRecordAccess recordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :objectId LIMIT 1];
            if (recordAccess != null) {
                recordEditableMap.put(objectId, recordAccess.HasEditAccess);
                return recordAccess.HasEditAccess;
            }
        }
        return false;
    }

    public static Boolean hasEditRights(EMS_Event__c event) {
        List<EMS_Event__Share> eventShareList = [
                SELECT AccessLevel
                FROM EMS_Event__Share
                WHERE ParentId = :String.valueOf(event.Id)
                AND UserOrGroupId = :UserInfo.getUserId()
        ];
        Boolean hasEditRights = false;
        for (EMS_Event__Share share : eventShareList) {
            if (share.AccessLevel == 'Edit' || share.AccessLevel == 'All') {
                hasEditRights = true;
                break;
            }
        }
        return hasEditRights;
    }

    public static Boolean isEventAttendee(Id eventId) {
        List<EMS_Event__Share> eventShareList = [
                SELECT AccessLevel, UserOrGroupId
                FROM EMS_Event__Share
                WHERE ParentId = :String.valueOf(eventId)
                AND RowCause = :Schema.EMS_Event__Share.RowCause.Event_Attendee__c
                AND UserOrGroupId IN :userGroups
        ];
        return (eventShareList.size() > 0);
    }

    public static Boolean isEventOwnerRequestor(EMS_Event__c event) {
        return UserInfo.getUserId() == event.Event_Requestor_gne__c || UserInfo.getUserId() == event.Event_Owner_gne__c;
    }

    /* Get user access to the specific record */
    public static UserRecordAccess getUserRecordAccess(String userId, String recordId) {
        if (!String.isBlank(userId) && !String.isBlank(recordId)) {
            return [SELECT RecordId, HasEditAccess, HasReadAccess, HasTransferAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId];
        }
        return null;
    }

    public static String currency(Decimal i) {
        String s = (i.setScale(2) + 0.001).format();
        return s.subString(0, s.length() - 1);
    }

    public static String getUserRole() {
        GNE_SFA2_User_App_Context_gne__c appContext = GNE_SFA2_User_App_Context_gne__c.getValues(UserInfo.getUserId());
        if (appContext != null) {
            return appContext.Role_gne__c;
        }
        return null;
    }

    public static String getUserApplication() {
        GNE_SFA2_User_App_Context_gne__c appContext = GNE_SFA2_User_App_Context_gne__c.getValues(UserInfo.getUserId());
        if (appContext != null) {
            return appContext.App_Name_gne__c;
        }
        return null;
    }

    public static boolean getHasReadOnlyPermSet() {
        return readOnlyUsers.containsKey(UserInfo.getUserId());
    }

    public static Boolean isAdmin() {
        return EMS_Access.isAdmin();
    }

    public static Boolean isCR() {
        return CRUsers.containsKey(UserInfo.getUserId());
    }

    public static Boolean isReadOnly() {
        return (getUserRole() == 'ReadOnly' || getHasReadOnlyPermSet() == true);
    }

    public static Boolean isEventLockedByRecordType(EMS_Event__c event) {
        return event.RecordType.Name == 'EMS Cancelled Event' ||
                event.RecordType.Name == 'EMS Closed Event' ||
                event.RecordType.Name == 'EMS Locked Event';
    }

    public static Boolean isClosedCancelledEvent(EMS_Event__c event) {
        return (event.RecordType.Name == 'EMS Cancelled Event') || (event.RecordType.Name == 'EMS Closed Event');
    }

    public static GNE_SFA2_User_App_Context_gne__c getUserApplicationContext() {
        return GNE_SFA2_User_App_Context_gne__c.getInstance();
    }

    public static Map<String, List<User>> emsUserRoleMap {
        get {
            if (emsUserRoleMap == null) {
                emsUserRoleMap = new Map<String, List<User>>();
                for (SFA2_User_Sales_Roster_gne__c sr : [
                        SELECT Role_gne__c, User_gne__r.Id, User_gne__r.Name,
                                User_gne__r.FirstName, User_gne__r.LastName
                        FROM SFA2_User_Sales_Roster_gne__c
                        WHERE Sales_Roster_gne__r.Type_gne__c = 'EMS-Canada'
                        AND User_gne__r.IsActive = TRUE
                        AND Is_Active_gne__c = TRUE
                        ORDER BY User_gne__r.Name
                ]) {
                    if (emsUserRoleMap.containsKey(sr.Role_gne__c)) {
                        emsUserRoleMap.get(sr.Role_gne__c).add(sr.User_gne__r);
                    } else {
                        emsUserRoleMap.put(sr.Role_gne__c, new List<User>{
                                sr.User_gne__r
                        });
                    }
                }
            }
            return emsUserRoleMap;
        }
        private set;
    }

    // Get map of users roles
    public static Map<Id, String> getUsersRolesFromSR() {
        Map<Id, String> usersRoles = new Map<Id, String>();
        for (SFA2_User_Sales_Roster_gne__c sr : [SELECT Id, User_gne__c, Role_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE Sales_Roster_gne__r.Type_gne__c = 'EMS-Canada' AND Is_Active_gne__c = TRUE and User_gne__r.IsActive = true]) {
            usersRoles.put(sr.User_gne__c, sr.Role_gne__c);
        }
        return usersRoles;
    }

    // Get role from SFA2_User_Sales_Roster_gne_c
    public static String getUserRoleFromSR(Id userId) {
        String userRole = '';
        List<SFA2_User_Sales_Roster_gne__c> emsCanadaSalesRoster = [SELECT Id, Role_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE Sales_Roster_gne__r.Type_gne__c = 'EMS-Canada' AND User_gne__c = :userID LIMIT 1];
        if (!emsCanadaSalesRoster.isEmpty()) {
            userRole = emsCanadaSalesRoster[0].Role_gne__c;
        }
        return userRole;
    }

    //Get application admins emails
    public static List<String> getApplicationAdminsEmails() {
        List<String> mails = new List<String>();
        for (User u : adminUsers.values()) {
            mails.add(u.Email);
        }

        return mails;
    }

    public static void rejectApproval(Id workItemId) {
        // reject all approvals pending
        Approval.ProcessWorkitemRequest processWorkItemRequest = new Approval.ProcessWorkitemRequest();
        processWorkItemRequest.setComments('Related budget was deactivated.');
        processWorkItemRequest.setAction('Reject');
        //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});

        processWorkItemRequest.setWorkitemId(workItemId);

        // Submit the request for approval
        Approval.ProcessResult result = Approval.process(processWorkItemRequest);
    }

    /*Reject approval process for workItemIds and sets proper comment*/
    public static List<Approval.ProcessResult> rejectApprovals(List<Id> workItemIds, String comment) {
        // reject all approvals pending
        List<Approval.ProcessWorkitemRequest>processes = new List<Approval.ProcessWorkitemRequest>();
        for (Id workItemId : workItemIds) {
            Approval.ProcessWorkitemRequest processWorkItemRequest = new Approval.ProcessWorkitemRequest();
            processWorkItemRequest.setComments(comment);
            processWorkItemRequest.setAction('Reject');
            processWorkItemRequest.setWorkitemId(workItemId);
            processes.add(processWorkItemRequest);
        }
        // Submit the request for approval
        return Approval.process(processes);
    }


    public static String getCalendarYearForNewBudget() {
        Date today = System.today();
        if (today.month() < OCTOBER) {
            // default to the current year
            return String.ValueOf(today.year());
        } else {
            // default to the next year
            return String.ValueOf(today.year() + 1);
        }
    }

    public static void restartEventApprovalProcess(Set<id> eventIds, String cancellApprovalComment, String submitApprovalComment) {
        List<EMS_Event__c> eventsToReapprove = new List<EMS_Event__c>();
        Set<String> approvedStatuses = new Set<String>{
                'Pending Med Ops Review', 'Approved', 'Med Ops Approved', 'Committee Approved', 'MAC Committee Approved', 'Manager Approved', 'Director / Manager Approved', 'Signed Agreement Received', 'Payment Request Initiated'
        };

        eventsToReapprove = [SELECT Id, Status_gne__c, Is_Planned_gne__c FROM EMS_Event__c WHERE Id IN :eventIds AND Status_gne__c IN :approvedStatuses];

        Savepoint savePoint = Database.setSavepoint();
        try {
            // Cancel Approval
            List<ProcessInstanceWorkitem> piwItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN (SELECT Id FROM ProcessInstance WHERE TargetObjectId = :eventsToReapprove)];
            if (piwItems.size() > 0) {
                List<Approval.ProcessWorkitemRequest> approvalsToReject = new List<Approval.ProcessWorkitemRequest>();
                for (ProcessInstanceWorkitem piwItem : piwItems) {
                    Approval.ProcessWorkitemRequest rejectAppr = new Approval.ProcessWorkitemRequest();
                    rejectAppr.setComments(cancellApprovalComment);
                    rejectAppr.setAction('Removed');
                    rejectAppr.setWorkitemId(piwItem.Id);
                    approvalsToReject.add(rejectAppr);
                }
                List<Approval.ProcessResult> rejectResults = Approval.process(approvalsToReject);
            }

            // Send for approvall process
            Id startRT = Schema.SObjectType.EMS_Event__c.getRecordTypeInfosByName().get('EMS Event').getRecordTypeId();
            List<Approval.ProcessSubmitRequest> approvalsToProcess = new List<Approval.ProcessSubmitRequest>();

            for (EMS_Event__c event : eventsToReapprove) {
                // Prepare requests for approval
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setComments(submitApprovalComment);
                request.setObjectId(event.Id);
                approvalsToProcess.add(request);

                // Reset event status
                if (event.Is_Planned_gne__c == true) {
                    event.Status_gne__c = 'Planned';
                    event.RecordTypeId = startRT;
                } else {
                    event.Status_gne__c = 'Unplanned';
                    event.RecordTypeId = startRT;
                }

                event.Submitted_Date_gne__c = System.today();
                event.Submitted_By_gne__c = UserInfo.getUserId();
            }

            update eventsToReapprove;
            List<Approval.ProcessResult> approvalResults = Approval.process(approvalsToProcess);

        } catch (exception ex) {
            Database.rollback(savePoint);
            System.debug('Exception: ' + ex);
        }
    }

    public static Map<Id, GNE_User_Delegation__c> getUserDelegations() {
        return userDelegations;
    }

    private static Map<Id, GNE_User_Delegation__c> userDelegations {
        get {
            if (userDelegations == null) {
                userDelegations = new Map<Id, GNE_User_Delegation__c>();
                Id emsUserDelegationRT = Schema.SObjectType.GNE_User_Delegation__c.RecordTypeInfosByName.get('EMS').RecordTypeId;
                for (GNE_User_Delegation__c ud : [SELECT Delegated_User__c, Username__c, OwnerId FROM GNE_User_Delegation__c WHERE Is_Delegation_Active__c = 'Yes' AND RecordTypeId = :emsUserDelegationRT]) {
                    userDelegations.put(ud.Username__c, ud);
                }
            }
            return userDelegations;
        }
        private set;
    }

    public static Map<String, EMS_Event_Configuration_gne__c> getEventConfigurations() {
        Map<String, EMS_Event_Configuration_gne__c> result = new Map<String, EMS_Event_Configuration_gne__c>();
        for (EMS_Event_Configuration_gne__c eventConfiguration : [SELECT Event_Type_gne__c, Event_Sub_Type_gne__c, Pending_Budget_Approval_Label_gne__c, AARC_Uploads_Contract_gne__c, Budget_Approved_Label_gne__c FROM EMS_Event_Configuration_gne__c]) {
            result.put(eventConfiguration.Event_Type_gne__c + eventConfiguration.Event_Sub_Type_gne__c, eventConfiguration);
        }

        return result;
    }

    public static Map<Id, Set<Id>> getEventRocheAttendeeTerritories(Id eventId) {
        Map<Id, Set<Id>> result = new Map<Id, Set<Id>>();
        for (EMS_Roche_Attendee_gne__c rocheAttendee : [SELECT User_gne__c, Territory_Id_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c = :eventId]) {
            result.put(rocheAttendee.User_gne__c, new Set<Id>());
        }
        Map<Id, List<EMS_Territory>> temp = EMS_Util.getUserTerritories(result.keySet());
        for (Id userId : result.keySet()) {
            for (EMS_Territory territory : temp.get(userId)) {
                result.get(userId).add(territory.Id);
            }
        }
        return result;
    }

    /* Compare SObjects attributes; ignore non-existent attributes when new value is null
       Returns true if objects are the same, false if they are not equal */
    public static boolean compareSobjects(sObject pBeforeSo, sObject pAfterSo) {
        if (pBeforeSo != pAfterSo) {
            if (pBeforeSo != null && pAfterSo != null) {
                try {
                    map<string, object>beforeMap = (map<string, object>) JSON.deserializeUntyped(JSON.serialize(pBeforeSo));
                    map<string, object>afterMap = (map<string, object>) JSON.deserializeUntyped(JSON.serialize(pAfterSo));
                    for (string key : afterMap.keySet()) {
                        if (beforeMap.containsKey(key) ? afterMap.get(key) != beforeMap.get(key) && key != 'Self_invoice_sent_at__c' : afterMap.get(key) != null) {
                            if (beforeMap.containsKey(key))
                                system.debug('compareSobjects: failed - before/after missmatch for key: ' + key); else
                                    system.debug('compareSobjects: failed - after is not null for key: ' + key);
                            return false;
                        }
                    }
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'compareSobjects validation error. Please contact a system administrator. Error: ' + e.getMessage()));
                    return false;
                }
            } else {
                system.debug('compareSobjects: failed - on or more SObjects were null');
                return false;
            }
        }
        system.debug('compareSobjects: compare success');
        return true;
    }

    public static Map<Id, Set<String>> fetchBudgetUsersPermissions(List<EMS_Budget_Territory_gne__c > triggerNew) {
        Map<Id, Set<String>> result = new Map<Id, Set<String>>();

        for (EMS_Budget_Territory_gne__c budget : triggerNew) {
            result.put(budget.Assigned_to_gne__c, new Set<String>());
        }

        List<PermissionSetAssignment> assignments = [
                SELECT PermissionSet.Name, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId in :result.keySet()
        ];

        for (PermissionSetAssignment assignment : assignments) {
            result.get(assignment.AssigneeId).add(assignment.PermissionSet.Name);
        }

        return result;
    }

    public static Map<Id, Set<String>> fetchBudgetUsersPermissions(List<EMS_Budget_Region_gne__c > triggerNew) {
        Map<Id, Set<String>> result = new Map<Id, Set<String>>();

        for (EMS_Budget_Region_gne__c budget : triggerNew) {
            result.put(budget.Assigned_to_gne__c, new Set<String>());
        }

        List<PermissionSetAssignment> assignments = [
                SELECT PermissionSet.Name, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId in :result.keySet()
        ];

        for (PermissionSetAssignment assignment : assignments) {
            result.get(assignment.AssigneeId).add(assignment.PermissionSet.Name);
        }

        return result;
    }

    public static Map<Id, Set<String>> fetchBudgetUsersPermissions(List<EMS_Budget_Product_gne__c > triggerNew) {
        Map<Id, Set<String>> result = new Map<Id, Set<String>>();

        for (EMS_Budget_Product_gne__c budget : triggerNew) {
            result.put(budget.Assigned_to_gne__c, new Set<String>());
        }

        List<PermissionSetAssignment> assignments = [
                SELECT PermissionSet.Name, AssigneeId
                FROM PermissionSetAssignment
                WHERE AssigneeId in :result.keySet()
        ];

        for (PermissionSetAssignment assignment : assignments) {
            result.get(assignment.AssigneeId).add(assignment.PermissionSet.Name);
        }

        return result;
    }

    private static Map<Id, String> budgetOwnerAliases = new Map<Id, String>();
    public static Map<Id, String> queryBudgetOwners(Set<Id> budgetOwners) {
        budgetOwners.removeAll(budgetOwnerAliases.keySet());
        if(!budgetOwners.isEmpty()) {
            for (User owner : [
                    SELECT Id, Alias, External_ID_gne__c
                    FROM User
                    WHERE Id IN :budgetOwners
            ]) {
                budgetOwnerAliases.put(owner.Id, owner.Alias);
            }
        }
        return budgetOwnerAliases;
    }

    private static Map<String, EMS_Cost_Center_gne__c> costCenterMap = new Map<String, EMS_Cost_Center_gne__c>();
    public static EMS_Cost_Center_gne__c getCostCenter(String name) {
        queryCostCenters(new Set<String> { name });
        return costCenterMap.get(name);
    }

    public static List<EMS_Cost_Center_gne__c> getCostCenters(Set<String> names) {
        queryCostCenters(names);

        List<EMS_Cost_Center_gne__c> result = new List<EMS_Cost_Center_gne__c>();
        for(String name : names) {
            result.add(costCenterMap.get(name));
        }
        return result;
    }

    public static void queryCostCenters(Set<String> names) {
        Set<String> keys = names.clone();
        keys.removeAll(costCenterMap.keySet());
        if (keys.isEmpty()) return;

        for (EMS_Cost_Center_gne__c cc : [
                SELECT Id, Name, Cost_Center_External_ID_gne__c
                FROM EMS_Cost_Center_gne__c
                WHERE Id IN :keys OR Name IN :keys
        ]) {
            costCenterMap.put(cc.Id, cc);
            costCenterMap.put(cc.Name, cc);
            costCenterMap.put(cc.Cost_Center_External_ID_gne__c, cc);
        }
    }

    // Facade for GNE_SFA2_Utils.getTerritoryGroup implementation
    public static Id getTerritoryGroup(Id territoryId) {
        return getTerritoriesGroups(new Set<Id>{
                territoryId
        }).get(territoryId);
    }
    // Facade for GNE_SFA2_Utils.getTerritoriesGroups implementation
    public static Map<Id, Id> getTerritoriesGroups(Set<Id> territoryIds) {
        return GNE_SFA2_Util.getTerritoriesGroups(territoryIds);
    }

    // cache
    private static Map<String, EMS_Territory> territoryMap = new Map<String, EMS_Territory>();
    private static Map<Id, List<EMS_Territory>> userTerritoriesMap = new Map<Id, List<EMS_Territory>>();
    private static Map<String, Set<Id>> territoryUsersMap = new Map<String, Set<Id>>();

    public static EMS_Territory getTerritoryByName(String territoryName) {
        return getTerritoriesByNames(new Set<String>{
                territoryName
        }).get(territoryName);
    }
    public static Map<String, EMS_Territory> getTerritoriesByNames(Set<String> names) {
        queryTerritories(names);

        Map<String, EMS_Territory> result = new Map<String, EMS_Territory>();
        for (String name : names) {
            if (territoryMap.containsKey(name)) {
                result.put(name, territoryMap.get(name));
            }
        }
        return result;
    }

    public static Set<Id> getTerritoryUsers(String territoryId) {
        return getTerritoriesUsers(new Set<String>{
                territoryId
        }).get(territoryId);
    }
    public static Map<String, Set<Id>> getTerritoriesUsers(Set<String> territoryIds) {
        queryTerritoryMembers(territoryIds.clone());

        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        for (String territoryId : territoryIds) {
            result.put(territoryId, territoryUsersMap.get(territoryId));
        }
        return result;
    }

    private static void queryTerritories(Set<String> names) {
        if(names.isEmpty()) return;

        for (SObject territory : Database.query(
                'SELECT Id, Name FROM Territory2 WHERE Id IN :names OR Name IN :names'
        )) {
            EMS_Territory t = new EMS_Territory(territory);
            territoryMap.put(t.Name, t);
            territoryMap.put(t.Id, t);
        }
    }
    private static void queryTerritoryMembers(Set<String> territoryIds) {
        territoryIds.removeAll(territoryUsersMap.keySet());
        if(territoryIds.isEmpty()) return;

        for (String territoryId : territoryIds) territoryUsersMap.put(territoryId, new Set<Id>());

        // update user information
        for (SObject userTerritory : Database.query(
                'SELECT Territory2Id, UserId FROM UserTerritory2Association WHERE Territory2Id IN :territoryIds'
        )) {
            String territoryId = String.valueOf(userTerritory.get('Territory2Id'));
            String userId = String.valueOf(userTerritory.get('UserId'));

            territoryUsersMap.get(territoryId).add(userId);
        }
    }

    private static void queryUserTerritories(Set<Id> userIds) {
        userIds.removeAll(userTerritoriesMap.keySet());
        if(userIds.isEmpty()) return;

        for (Id userId : userIds) {
            if(!userTerritoriesMap.containsKey(userId)) {
                userTerritoriesMap.put(userId, new List<EMS_territory>());
            }

            for (SObject territory : Database.query(
                    'SELECT Id, Name, External_id_gne__c, ParentTerritory2Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c ' +
                    'FROM Territory2 ' +
                    'WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId) ORDER BY Name'
            )) {
                // update territory information
                EMS_Territory t = new EMS_Territory(territory);
                territoryMap.put(t.Name, t);
                territoryMap.put(t.Id, t);

                // update user territory assignment information
                userTerritoriesMap.get(userId).add(t);
            }
        }
    }

    public static List<EMS_Territory> getUserTerritories(Id userId) {
        return getUserTerritories(new Set<Id>{
                userId
        }).get(userId);
    }

    public static Map<Id, List<EMS_Territory>> getUserTerritories(Set<Id> userIds) {
        try {
            queryUserTerritories(userIds.clone());
        } catch(Exception ex) {}


        Map<Id, List<EMS_territory>> result = new Map<Id, List<EMS_territory>>();
        for (Id userId : userIds) {
            result.put(userId, userTerritoriesMap.get(userId));
        }
        return result;
    }

    public static List<SelectOption> getUserTerritorySelectOptions(Id userId) {
        return getUserTerritorySelectOptions(new Set<Id>{
                userId
        }).get(userId);
    }

    public static Map<Id, List<SelectOption>> getUserTerritorySelectOptions(Set<Id> userIds) {
        Map<Id, List<SelectOption>> result = new Map<Id, List<SelectOption>>();
        Map<Id, List<EMS_Territory>> territoryMap = getUserTerritories(userIds);
        for (Id userId : userIds) {
            // build result from territories
            result.put(userId, new List<SelectOption>());
            for (EMS_Territory et : territoryMap.get(userId)) {
                result.get(userId).add(et.toSelectOption());
            }

            // add select/none options
            if (result.get(userId).isEmpty()) {
                result.get(userId).add(new SelectOption('', '--None--'));
            } else if (result.get(userId).size() > 1) {
                result.get(userId).add(0, new SelectOption('', '--Select--'));
            }
        }

        return result;
    }

    public class EMS_Territory {
        public Id territoryId { get; private set; }
        public Id Id { get; private set; }
        public String Name { get; private set; }
        public Boolean IsActive { get; private set; }

        public EMS_Territory(SObject territory) {
            Id = String.valueOf(territory.get('Id')) ;
            Name = String.valueOf(territory.get('Name'));
            IsActive = true;
        }

        public EMS_Territory(Id territoryId, String name) {
            this.Id = territoryId;
            this.Name = name;
            this.IsActive = true;
        }

        public EMS_Territory(Id territoryId, String name, Boolean isActive) {
            this.Id = territoryId;
            this.Name = name;
            this.IsActive = isActive;
        }

        public SelectOption toSelectOption() {
            return new SelectOption(Name, Name);
        }
    }
}