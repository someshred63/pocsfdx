public without sharing class EMS_Record_History_Controller {

    private static Integer TIME_OFFSET_SECONDS = 5;
    private static final String systemName = 'System';

    private static Map<String, Set<String>> ignoredFields = new Map<String, Set<String>>{
            'EMS_Event__c' => new Set<String>{
                    'RecordType'
            }
    };
    private static Map<String, Set<String>> includedFields = new Map<String, Set<String>>{
            'EMS_Speaker_Role_gne__c' => new Set<String>{
                    'Batch_ID_gne__c', 'Self_invoice_generated_at__c', 'Self_invoice_sent_at__c'
            },
            'EMS_Attendee_gne__c' => new Set<String>{
            	'Exception_accepted_at_gne__c', 'Exception_requested_at_gne__c','Exception_accepted_at_gne__c','Exception_requested_at_gne__c'
            }
    };
    private static Map<String, String> nameFields = new Map<String, String> {
            'EMS_Roche_Attendee_gne__c' => 'User_gne__r.Name',
            'EMS_Attendee_gne__c' => 'Name_gne__c'
    };

    public Boolean childObjectsVisible { get; set; }
    public String childObjectsList { get; set; }
    public String sObjectName { get; set; }
    public String recordId { get; set; }

    public EMS_Record_History_Controller() {
        recordId = ApexPages.currentPage().getParameters().get('id');
        sObjectName = getSobjectAPINameById(recordId);
    }

    @RemoteAction
    public static List<HistoryItemWrapper> prepareTable(List<String> sObjectNamesList, Boolean showChildrenHistory, String recordId) {
        String sobjectAPIName = getSobjectAPINameById(recordId);
        Boolean isEvent = (sobjectAPIName == 'EMS_Event__c');
        Boolean replaceNameInHistory = false;
        Map<Id, String> dependentIDToName = new Map<Id, String>();

        Set<String> sObjectNames = new Set<String>();
        sObjectNames.addAll(sObjectNamesList);

        Map<Datetime, String> dateToComment = new Map<Datetime, String>();
        // Get approval history only for EMS_Event__c record
        if (isEvent) {
            for (ProcessInstanceStep pis : [SELECT Comments, CreatedDate FROM ProcessInstanceStep WHERE ProcessInstance.TargetObjectId = :recordId ORDER BY CreatedDate DESC]) {
                dateToComment.put(pis.CreatedDate, pis.Comments);
            }
        }
        // Get total history for current record
        String sobjHistoryQuery = 'SELECT Id, Field, NewValue, OldValue, CreatedDate, CreatedById, CreatedBy.Name, ParentId FROM ' + sobjectAPIName.left(sobjectAPIName.length() - 3) + '__History WHERE ParentId = \'' + recordId + '\'  ORDER BY CreatedDate DESC, ID DESC';
        List<sObject> sobjHistoryList = Database.query(sobjHistoryQuery);
        List<HistoryItemWrapper> historyToBeShown = new List<HistoryItemWrapper>();
        wrapHistoryRecords(sobjectAPIName, false, sobjHistoryList, historyToBeShown, replaceNameInHistory, dateToComment, dependentIDToName);

        // Check the relationships and find all dependents (childs)
        Map<String, List<AggregateResult>> childrenMap = new Map<String, List<AggregateResult>>();
        Schema.DescribeSObjectResult sObjectDescribeResult = Schema.getGlobalDescribe().get(sobjectAPIName).getDescribe();
        for (Schema.ChildRelationship rel : sObjectDescribeResult.getChildRelationships()) {
            String childObjectName = rel.getChildSObject().getDescribe().getName();
            if (sObjectNames.contains(childObjectName)) {
                if (!childrenMap.containsKey(childObjectName)) {
                    String nameField = 'Name';
                    if (nameFields.containsKey(childObjectName)) {
                        nameField = nameFields.get(childObjectName);
                    }
                    childrenMap.put(
                            childObjectName,
                            Database.query('SELECT Id, Max(' + nameField + ') Name FROM ' + childObjectName + ' WHERE ' + rel.getField().getDescribe().getName() + ' = \'' + recordId + '\' GROUP BY Id')
                    );
                }
                for (AggregateResult obj : childrenMap.get(childObjectName)) {
                    dependentIDToName.put((Id) obj.get('Id'), (String) obj.get('Name'));
                }
            }
        }
        Set<Id> dependentIDs = dependentIDToName.keySet();

        // Get history of child records
        if (!dependentIDs.isEmpty()) {
            for (String sobjectChildAPIName : sObjectNames) {
                String sobjectHistorydAPIName = sobjectChildAPIName.left(sobjectChildAPIName.length() - 3) + '__History';
                String query = 'SELECT Id, Field, NewValue, OldValue, CreatedDate, CreatedById, CreatedBy.Name, ParentId FROM ' + sobjectHistorydAPIName + ' WHERE ParentId IN :dependentIDs ORDER BY CreatedDate DESC, ID DESC';
                List<SObject> history = Database.query(query);

                wrapHistoryRecords(sobjectChildAPIName, true, history, historyToBeShown, replaceNameInHistory, dateToComment, dependentIDToName);
            }
        }

        historyToBeShown.sort();
        return historyToBeShown;
    }

    private static void wrapHistoryRecords(String sObjectName, Boolean isChild, List<sObject> objHistory, List<HistoryItemWrapper> allHistory, Boolean replaceNameInHistory, Map<Datetime, String> dateToComment, Map<Id, String> dependentIDToName) {
        for (sObject r : objHistory) {
            String fieldName = (String) r.get('Field');
            Datetime createdDate = (Datetime) r.get('CreatedDate');
            Object newValue = (Object) r.get('NewValue');
            Object oldValue = (Object) r.get('OldValue');

            Boolean isEvent = (sObjectName == 'EMS_Event__c');
            if (ignoredFields.containsKey(sObjectName) && ignoredFields.get(sObjectName).contains(fieldName)) {
                System.debug('skipping ignored field: ' + sObjectName + '.' + fieldName);
                // skip history for that object
                continue;
            }

            if (!includedFields.containsKey(sObjectName) || (includedFields.containsKey(sObjectName) && includedFields.get(sObjectName).contains(fieldName))) {
                if (isEvent && !isChild && fieldName == 'Status_gne__c' && (((String) oldValue).contains('Med Ops Rejected') || ((String) newValue).contains('Med Ops Rejected'))) {
                    for (Datetime key : dateToComment.keySet()) {
                        if (key.addSeconds(-TIME_OFFSET_SECONDS) <= createddate && createddate <= key.addSeconds(TIME_OFFSET_SECONDS) && dateToComment.get(key) != null && dateToComment.get(key).contains('Med Ops Review Recalled:')) {
                            if (((String) oldValue).contains('Med Ops Rejected')) {
                                oldValue = 'Recalled';
                            }
                            if (((String) newValue).contains('Med Ops Rejected')) {
                                newValue = 'Recalled';
                            }
                        }
                    }
                }

                // skip records which have only User Id change information
                if (isUserID(String.valueOf(oldValue)) && isUserID(String.valueOf(newValue))) {
                    continue;
                }

                Boolean trackChanges = true;
                Id createdById = (Id) r.get('CreatedById');
                String createdByName = (String) r.getSObject('CreatedBy').get('Name');

                if (!isChild && isEvent && fieldName == 'Auto_Closed_gne__c' && String.valueOf(oldValue) == 'false' && String.valueOf(newValue) == 'true') {
                    replaceNameInHistory = true;
                    trackChanges = false;
                    // while replaceNameInHistory = true, each next History record should contain replacement in the Name field
                }
                if (!isChild && isEvent && fieldName == 'Auto_Closed_gne__c' && String.valueOf(oldValue) == 'true' && String.valueOf(newValue) == 'false') {
                    replaceNameInHistory = false;
                    trackChanges = false;
                    // History records which follow next should contain correct name of User who changed something
                }

                if (replaceNameInHistory) {
                    // Here the logic to change the Name has to be implemented
                    if (isEvent && fieldName == 'Status_gne__c' && String.valueOf(newValue) == 'Closed' && !isChild) {
                        replaceNameInHistory = false;
                        createdById = null;
                        createdByName = systemName; // for autoclosed events Name in the history should be the "System"
                    }
                }

                if (trackChanges == false) {
                    // Skip history tracking
                    continue;
                }

                // add an item to the Hisotry list
                HistoryItemWrapper historyItem = new HistoryItemWrapper(
                        sObjectName,
                        dependentIDToName.get((Id) r.get('ParentId')),
                        isChild,
                        oldValue,
                        newValue,
                        fieldName,
                        createdByName,
                        createdById,
                        (Datetime) r.get('CreatedDate')
                );
                if (createdById == null) {
                    historyItem.modifiedByLink = null;
                }
                allHistory.add(historyItem);
            } else {
                System.debug('Not included in field list: ' + sObjectName + '.' + fieldName);
            }
        }
    }

    // Check if the passed variable is an ID
    private static Boolean isUserID(String theId) {
        Boolean isID = false;
        try {
            if (Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(theId).matches()) {
                // Try to assign it to an Id before checking the type
                Id id = theId;
                Type t = Type.forName('User');
                sObject sObj = (sObject) t.newInstance();
                sObj.Id = id;
                isID = true;
            }
        } catch (Exception e) {
        }

        // this is not an ID value
        return isID;
    }

    private static String getSobjectAPINameById(String recordId) {
        String keyCode = recordId.subString(0, 3);

        for (Schema.SObjectType objectInstance : Schema.getGlobalDescribe().values()) {
            if (String.isNotEmpty(objectInstance.getDescribe().getKeyPrefix()) && objectInstance.getDescribe().getKeyPrefix().equals(keyCode)) {
                return objectInstance.getDescribe().getName();
            }
        }
        return null;
    }
}