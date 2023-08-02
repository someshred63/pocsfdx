/**************************************************************************************************
*  @author: Kaavya Karanam, Genentech (contractor)
*  @email: karanamk@gene.com
*  Created: 2013-07-14
*  Project: FCR
*  Description: Common utility classes used to generate webservices (REST) response.
***************************************************************************************************/
global without sharing class GNE_FCR_Util {

    public static final String FCR_NEW_STATUS = 'NewFCR';
    public static final String FCR_UNDER_REVIEW_STATUS = 'UnderReviewFCR';
    public static final String FCR_AWAITING_UPDATE_STATUS = 'UpdatingFCR';
    public static final String FCR_APPROVED_STATUS = 'ApprovedFCR';
    public static final String FCR_COMPLETED_STATUS = 'CompletedFCR';
    public static final String FCR_ARCHIVED_STATUS = 'ArchivedFCR';
    public static final String FCR_ACKNOWLEDGED_STATUS = 'AcknowledgedFCR';

    public static final String FCR_INTERNAL_ACCOUNT_PREFIX = 'FCR_INTERNAL_';

    public static final Pattern CS_PROFILE_PATTERN = Pattern.compile('GNE-SFA.*-CS*');
    public static final Pattern PS_PROFILE_PATTERN = Pattern.compile('GNE-SFA.*-PS');
    public static final Pattern SPECIALIST_PROFILE_PATTERN = Pattern.compile('GNE-SFA.*Specialist');

    private static List<Territory2> userChildTerritories;
    private static Boolean isUserAssignedToTerritory;

    private static Id fcrCompliancePermissionSetId;

    private static Map<Id, Boolean> userToLyticsMap;
    private static Map<Id, Boolean> userToGioModeMap;
    private static Map<Id, Boolean> userToNsdRsdMap;

    public static void sendEmail(String emailTemplate, FCR_Days_Plan_gne__c daysPlan, Id recipientId) {
        Messaging.SingleEmailMessage mail = createEmail(emailTemplate, daysPlan, recipientId);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

    public static void sendEmail(String emailTemplate, FCR_Days_Plan_gne__c daysPlan, Id recipientId, List<Messaging.EmailFileAttachment> attachments) {
        Messaging.SingleEmailMessage mail = createEmail(emailTemplate, daysPlan, recipientId);
        mail.setFileAttachments(attachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

    public static String getReportName(Id fcrDaysPlanId) {
        String name = '';
        if (fcrDaysPlanId != null) {
            FCR_Days_Plan_gne__c plan = [SELECT CS_User_gne__r.FirstName, CS_User_gne__r.LastName FROM FCR_Days_Plan_gne__c WHERE Id = :fcrDaysPlanId];
            name = plan.CS_User_gne__r.FirstName != null ? plan.CS_User_gne__r.FirstName + '_' : '';
            name += plan.CS_User_gne__r.LastName + '_' + System.now().format('dd_MM_yyyy');
        } else {
            name = UserInfo.getFirstName() != null ? UserInfo.getFirstName() + '_' : '';
            name += UserInfo.getLastName() + '_' + System.now().format('dd_MM_yyyy');
        }
        return name;
    }

    public static Blob generatePDF(PageReference pageRef, Id id, Boolean isAssesment, Boolean isSummary) {
        pageRef.getParameters().put('fcrId', id);
        if (isAssesment) {
            pageRef.getParameters().put('isAssesment', 'true');
        }
        if (isSummary) {
            pageRef.getParameters().put('isSummary', 'true');
        }
        Blob pdf;
        if (Test.isRunningTest()) {
            pdf = Blob.valueOf('UNIT.TEST');
        } else {
            pdf = pageRef.getContentAsPDF();
        }
        return pdf;
    }

    public static Blob generatePDF(PageReference pageRef, Id id) {
        return generatePDF(pageRef, id, false, false);
    }

    /*True if
    1. user is assigned to territory without child territories
    2. user is not assigned to any territory and has profile like GNE-SFA*CS*, GNE-SFA*PS albo GNE-SFA*Specialist
    */
    public static Boolean getIsFE() {
        if (isUserAssignedToTerritory == null) {
            isUserAssignedToTerritory = GNE_FCR_DAO.isUserAssignedToTerritory(UserInfo.getUserId());
        }

        if (userChildTerritories == null) {
            userChildTerritories = GNE_FCR_DAO.getUserChildTerritories(UserInfo.getUserId());
        }
        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        return ((isUserAssignedToTerritory && userChildTerritories.isEmpty()) || (!isUserAssignedToTerritory && (CS_PROFILE_PATTERN.matcher(profileName).matches() || PS_PROFILE_PATTERN.matcher(profileName).matches() || SPECIALIST_PROFILE_PATTERN.matcher(profileName).matches())));
    }

    public static Boolean getIsFE(Id userId) {
        if (isUserAssignedToTerritory == null) {
            isUserAssignedToTerritory = GNE_FCR_DAO.isUserAssignedToTerritory(userId);
        }

        if (userChildTerritories == null) {
            userChildTerritories = GNE_FCR_DAO.getUserChildTerritories(userId);
        }
        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        return ((isUserAssignedToTerritory && userChildTerritories.isEmpty()) || (!isUserAssignedToTerritory && (CS_PROFILE_PATTERN.matcher(profileName).matches() || PS_PROFILE_PATTERN.matcher(profileName).matches() || SPECIALIST_PROFILE_PATTERN.matcher(profileName).matches())));
    }

    /*True if user is assigned to territory with child territories. */
    public static Boolean getIsFR() {
        return !getIsFE();
    }

    public static Boolean getIsDataViewerAdmin() {
        Id permissionSetId = getFcrCompliancePermissionSetId();
        List<PermissionSetAssignment> assigment = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :permissionSetId AND AssigneeId = :UserInfo.getUserId()];
        return assigment.size() > 0;
    }

    public static Boolean isLyticsUser(Id userId) {
        if (userToLyticsMap == null) {
            userToLyticsMap = new Map<Id, Boolean>();
        }
        if (!userToLyticsMap.containsKey(userId)) {
            String profileName = GNE_SFA2_Util.getUserProfileName(userId);
            Boolean result = false;
            for (String configProfileName : GNE_FCR_Lytics_Profile_Names_gne__c.getAll().keySet()) {
                if (profileName.toUpperCase().trim() == configProfileName.toUpperCase().trim()) {
                    result = true;
                    break;
                }
            }
            userToLyticsMap.put(userId, result);
        }
        return userToLyticsMap.get(userId);
    }

    public static Boolean isGioUser(Id userId) {
        if (userToGioModeMap == null) {
            userToGioModeMap = new Map<Id, Boolean>();
        }
        if (!userToGioModeMap.containsKey(userId)) {
            String profileName = GNE_SFA2_Util.getUserProfileName(userId);
            Boolean result = false;
            for (String configProfileName : GNE_FCR_GIO_Profile_Names_gne__c.getAll().keySet()) {
                if (profileName.toUpperCase().trim() == configProfileName.toUpperCase().trim()) {
                    result = true;
                    break;
                }
            }
            userToGioModeMap.put(userId, result);
        }
        return userToGioModeMap.get(userId);
    }

    public static Boolean isNsdRsdUser(Id userId) {
        if (userToNsdRsdMap == null) {
            userToNsdRsdMap = new Map<Id, Boolean>();
        }
        if (!userToNsdRsdMap.containsKey(userId)) {
            String profileName = GNE_SFA2_Util.getUserProfileName(userId);
            Boolean result = false;
            for (String configProfileName : GNE_FCR_NSD_RSD_Profile_Names_gne__c.getAll().keySet()) {
                if (profileName.toUpperCase().trim() == configProfileName.toUpperCase().trim()) {
                    result = true;
                    break;
                }
            }
            userToNsdRsdMap.put(userId, result);
        }
        return userToNsdRsdMap.get(userId);
    }

    public static List<Integer> getAvailableFCRVersions() {
        return new List<Integer>{
                2, 3, 4, 5, 6, 7
        };
    }

    public static List<Integer> getSupportedFCRVersions(Id userId) {
        if (isGioUser(userId)) {
            return new List<Integer>{
                    2, 3, 4, 7
            };
        } else if (isNsdRsdUser(userId)) {
            return new List<Integer>{
                    2, 3, 4, 5
            };
        } else if (isLyticsUser(userId)) {
            return new List<Integer>{
                    6
            };
        } else {
            return new List<Integer>{
                    2
            };
        }
    }

    public static Integer getFCRWorkingVersion(Id userId) {
        if (isGioUser(userId)) {
            return 7;
        } else if (isNsdRsdUser(userId)) {
            return 5;
        } else if (isLyticsUser(userId)) {
            return 6;
        } else {
            return 2;
        }
    }

    public static void setDaysPlanActionAndStatus(FCR_Days_Plan_gne__c daysPlan, String statusActionKey) {
        GNE_FCR_DaysPlan_Key__c daysPlanKey = GNE_FCR_DaysPlan_Key__c.getValues(statusActionKey);
        if (daysPlanKey != null) {
            daysPlan.Action_gne__c = daysPlanKey.Action__c;
            daysPlan.Status_gne__c = daysPlanKey.Status__c;
        } else {
            daysPlan.Action_gne__c = statusActionKey;
            daysPlan.Status_gne__c = statusActionKey;
        }
    }

    public static String getDaysPlanStatus(String statusActionKey) {
        GNE_FCR_DaysPlan_Key__c daysPlanKey = GNE_FCR_DaysPlan_Key__c.getValues(statusActionKey);
        if (daysPlanKey == null) {
            return statusActionKey;
        }
        return daysPlanKey.Status__c;
    }

    public static List<SelectOption> getPicklistValues(String objectName, String fieldName, Boolean showLabel) {
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{
                objectName
        });
        Map<String, Schema.SObjectField> fieldMap = descResult[0].fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry entry : picklistValues) {
            if (showLabel) {
                options.add(new SelectOption(entry.getValue(), entry.getLabel()));
            } else {
                options.add(new SelectOption(entry.getValue(), ''));
            }
        }
        return options;
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static Messaging.EmailFileAttachment createAttachment(String attachmentType, String name, Blob body) {
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setContentType(attachmentType);
        attachment.setFileName(name);
        attachment.setInline(false);
        attachment.body = body;
        return attachment;
    }

    private static Messaging.SingleEmailMessage createEmail(String emailTemplate, FCR_Days_Plan_gne__c daysPlan, Id recipientId) {
        EmailTemplate et = [SELECT Id, IsActive, Name, OwnerId, FolderId, Subject, TemplateType, Body, Markup FROM EmailTemplate WHERE IsActive = TRUE AND DeveloperName = :emailTemplate LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(recipientId);
        mail.setWhatId(daysPlan.Id);
        mail.setTemplateId(et.Id);
        mail.setSaveAsActivity(false);
        return mail;
    }

    public static PageReference redirectToErrorPage(String errorMessage, String currentURL, String developerMessage) {
        PageReference pageref = Page.GNE_FCR_Error;
        pageref.setRedirect(true);
        pageref.getParameters().put('exMessage', errorMessage);
        pageref.getParameters().put('exUrl', currentURL);
        pageref.getParameters().put('developerMessage', developerMessage);
        return pageref;
    }

    public static List<String> buildStringList(List<SObject> sObjects, String fieldName) {
        List<String> resultList = new List<String>();
        for (SObject sObj : sObjects) {
            resultList.add(String.valueOf(sObj.get(fieldName)));
        }
        return resultList;
    }

    private static Id getFcrCompliancePermissionSetId() {
        if (fcrCompliancePermissionSetId == null) {
            fcrCompliancePermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'SFA_FCR_Compliance'].Id;
        }
        return fcrCompliancePermissionSetId;
    }

    public static void removeFcrSharing(Id fcrId) {
        List<FCR_Days_Plan_gne__Share>sharingList = [SELECT Id FROM FCR_Days_Plan_gne__Share WHERE ParentId = :fcrId AND RowCause = :Schema.FCR_Days_Plan_gne__Share.RowCause.Manual];
        if (!sharingList.isEmpty()) {
            delete sharingList;
        }
    }

    public static void deleteFCR(FCR_Days_Plan_gne__c fcr) {
        delete fcr;
    }

    public static Boolean isDateStringValid(String dateString) {
        Pattern userIdPattern = Pattern.compile('([0-9]{2})/([0-9]{2})/([0-9]{4})');
        Matcher myMatcher = userIdPattern.matcher(dateString);
        return myMatcher.matches();
    }

    public static Boolean isUserAllowedToSeeFCR(FCR_Days_Plan_gne__c fcr) {
        if (GNE_FCR_Util.getIsFE()) {
            if (fcr.CS_User_gne__c == UserInfo.getUserId()) {
                return true;
            }
        } else if (GNE_FCR_Util.getIsDataViewerAdmin()) {
            return true;
        } else {
            Set<Id>userTerritoriesId = new Set<Id>();
            for (Territory2 territory : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
                userTerritoriesId.add(territory.Id);
            }
            Set<Id>usersId = new Set<Id>();
            for (UserTerritory2Association ut : [SELECT UserId FROM UserTerritory2Association WHERE Territory2Id IN :userTerritoriesId]) {
                usersId.add(ut.UserId);
            }

            if (usersId.contains(fcr.FR_User_gne__c) || usersId.contains(fcr.CS_User_gne__c)) {
                return true;
            }
        }
        if (fcr.FR_User_gne__c == UserInfo.getUserId()) {
            return true;
        }
        return false;
    }

    public static Boolean isSupportedBySLDx(Id userId) {
        List<GNE_FCR_No_SLDx_Groups__c >noSLDxGroups = GNE_FCR_No_SLDx_Groups__c.getAll().values();
        List<Territory2> userTerritories = GNE_FCR_DAO.getTerritories(userId);
        Boolean isSupportedBySLDx = true;
        if (userTerritories.size() == 1) {
            String userSalesforceCode = userTerritories.get(0).Salesforce_Code_gne__c;
            for (GNE_FCR_No_SLDx_Groups__c g : noSLDxGroups) {
                if (g.Name == userSalesforceCode) {
                    isSupportedBySLDx = false;
                    break;
                }
            }
        } else {
            String userProfile = GNE_SFA2_Util.getCurrentUserProfileName();
            for (GNE_FCR_No_SLDx_Groups__c g : noSLDxGroups) {
                if (String.isNotEmpty(g.Profile_Mask_gne__c)) {
                    for (String mask : g.Profile_Mask_gne__c.split(',')) {
                        if (isMaskFitProfile(mask, userProfile)) {
                            isSupportedBySLDx = false;
                            break;
                        }
                    }
                }
            }
        }
        return isSupportedBySLDx;
    }

    private static Boolean isMaskFitProfile(String mask, String profileName) {
        return profileName.toUpperCase().startsWith(mask);
    }

    public static List<SelectOption> getPicklistJobAccountabilitiesTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = new List<SelectOption>();
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            for (String val : new List<String>{
                    'Does Not Meet',
                    'Partially Meets',
                    'Meets',
                    'Exceeds',
                    'Outstanding',
                    'Not Applicable'
            }) {
                result.add(
                        new SelectOption(val, showLabel ? val : '')
                );
            }
        } else {
            result = getPicklistValues('FCR_Daysplan_Job_Accountability_gne__c', 'Rating_gne__c', showLabel);
        }
        return result;
    }

    public static List<SelectOption> getPicklistGatherInsightsTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Assess_Gather_Insights_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistIdentifyingShiftsTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Assess_Identifying_Shifts_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistStrategicAccountPlanningTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Assess_Strategic_Account_Planning_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistCheckAssumptionsTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Clarify_Check_Assumptions_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistEffectiveProbingTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Clarify_Effective_Probing_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistReflectiveListeningTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Clarify_Reflective_Listening_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistAligningInformationTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Execute_Aligning_Information_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistObjectionHandlingTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Execute_Objection_Handling_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    public static List<SelectOption> getPicklistExecuteClosingTypes(Decimal fcrVersion, Boolean showLabel) {
        List<SelectOption> result = GNE_FCR_Util.getPicklistValues('FCR_DaysPlan_Job_Competency_gne__c', 'Execute_Closing_gne__c', false);
        if (Integer.valueOf(fcrVersion) == 4 || Integer.valueOf(fcrVersion) == 5) {
            result.add(new SelectOption('N/A', showLabel ? 'N/A' : ''));
        }
        return result;
    }

    /* OLD IPAD APPLICATION LOGIC */

    global abstract class RestResponse {
        public Boolean success = false;
        public ExceptionInfo error;
        public Map<String, String> debugInfo = new Map<String, String>();

        public void setSuccessStatus() {
            this.success = true;
            this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
            this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
            this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
        }

        public void setErrorStatus(Exception ex) {
            this.success = false;
            this.debugInfo.put('scriptStatements', Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements());
            this.debugInfo.put('queryStatements', Limits.getQueries() + '/' + Limits.getLimitQueries());
            this.debugInfo.put('queryRows', Limits.getQueryRows() + '/' + Limits.getLimitQueryRows());
            this.error = new ExceptionInfo(ex);
        }
    }

    global virtual class SObjectRestResponse extends RestResponse {
        public DeltaCalculator deltaCalculator;
        public List<SObject> updateRecords = new List<SObject>();
        public List<SObject> records = new List<SObject>();
        public List<SObject> deletedRecords = new List<SObject>();

        public void setRecords(List<SObject> records) {
            Boolean firstLoad = false;
            if (deltaCalculator == null) {
                firstLoad = true;
                deltaCalculator = new DeltaCalculator();
            }
            for (SObject record : records) {
                Integer delta = deltaCalculator.getDeltaStatus(record);
                if (delta == 1) {
                    this.records.add(record);
                } else if (delta == 0) {
                    updateRecords.add(record);
                } else if (delta == 2) {
                    deletedRecords.add(record);
                }
            }
            if (firstLoad) {
                updateRecords.clear();
                deletedRecords.clear();
            }
        }
    }

    global class CustomRestResponse extends RestResponse {
        public List<RestRecord> records = new List<RestRecord>();
    }

    public abstract class RestRecord {
    }

    public class ExceptionInfo {
        public String stackTrace;
        public String typeName;
        public String cause;
        public Integer lineNumber;
        public String message;

        public ExceptionInfo() {
        }

        public ExceptionInfo(Exception ex) {
            Exception cEx = ex.getCause();
            stackTrace = ex.getStackTraceString();
            typeName = ex.getTypeName();
            if (typeName == 'System.DmlException') {
                typeName = '' + ((DmlException) ex).getDmlType(0);
            }
            cause = cEx != null ? cEx.getMessage() : '';
            lineNumber = ex.getLineNumber();
            message = ex.getMessage();
        }
    }

    public static Datetime formatTimeStamp(String timestamp) {
        String offset = '';
        Integer index = 0;
        Integer hours = 0;
        Integer minutes = 0;
        timestamp = timestamp.replace('T', ' ');
        if ((index = timestamp.indexOf('+')) >= 0) {
            offset = timestamp.substring(index + 1, timestamp.length());
            hours = -(Integer.valueOf(offset.substring(0, 2)));
            minutes = -(Integer.valueOf(offset.substring(2, 4)));
        } else if ((index = timestamp.lastIndexOf('-')) >= 0) {
            offset = timestamp.substring(index + 1, timestamp.length());
            hours = Integer.valueOf(offset.substring(0, 2));
            minutes = Integer.valueOf(offset.substring(2, 4));
        }
        Datetime timeFormat = Datetime.valueOfGmt(timestamp);
        return timeFormat.addHours(hours).addMinutes(minutes);
    }

    public class DeltaCalculator {
        private Datetime lastSynchronized;

        public DeltaCalculator(String lastSyncDate) {
            this.lastSynchronized = formatTimeStamp(lastSyncDate);
        }

        public DeltaCalculator(Datetime lastSyncDate) {
            this.lastSynchronized = lastSyncDate ;
        }

        public DeltaCalculator() {
            this.lastSynchronized = Datetime.newInstance(0);
        }

        public Integer getDeltaStatus(SObject sObj) {
            Datetime created = (Datetime) sObj.get('CreatedDate');
            Datetime lastModified = (Datetime) sObj.get('LastModifiedDate');
            Boolean deleted = (Boolean) sObj.get('IsDeleted');
            if (lastModified >= lastSynchronized && deleted) {
                return 2;
            }
            if (created > lastSynchronized) {
                return 1;     // created AFTER last synchronization.
            } else {
                if (lastModified >= lastSynchronized) {
                    return 0; // created BEFORE last synchonization but updated AFTER last synchronization.
                } else {
                    return -1; // created and updated BEFORE last synchronization.
                }
            }
        }
    }

    public class FCRDocument {
        public Id docId { get; private set; }
        public String docName { get; private set; }
        public String docUrl { get; private set; }

        public FCRDocument(String docId, String docName) {
            this.docId = docId;
            this.docName = docName;
            this.docUrl = String.format('{0}/servlet/servlet.FileDownload?file={1}'
                    , new String[]{
                            System.Url.getSalesforceBaseUrl().toExternalForm(),
                            this.docId
                    }
            );
        }
    }
}