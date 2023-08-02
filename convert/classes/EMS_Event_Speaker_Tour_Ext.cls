global with sharing class EMS_Event_Speaker_Tour_Ext {
    public EMS_Event__c event { get; set; }

    private static final List<String> SUBTYPES = new List<String>{
            // Learning Programs
            'OLA Implementation',
            'OLA/Accredited CHE Development',
            'HCP Initiated OLA Implementation',
            'Accredited CHE',
            'Accredited CHE Implementation',

            'Development - OLA',
            'Development - CHE',
            'Implementation - OLA/CHE',
            'Preceptorships (HCP to HCP)'
    };
    private static final String TYPE = 'Learning Programs';
    private static final Integer EVENTSEARCHLIMIT = 100;
    private static final Set<String> excludedStatuses = new Set<String>{
            'Cancelled'
    };

    public EMS_Event_Speaker_Tour_Ext(ApexPages.StandardController stdController) {
        event = (EMS_Event__c) stdController.getRecord();
    }

    public Boolean getCanEdit() {
        return EMS_Access.isSpeakerTourEditable(event);
    }

    // Speaker Tour Methods
    public List<EMS_Event__c> speakerTourEvents {
        get {
            //Also add parent (current event) to the Speaker Tour Section
            List<EMS_Event__c> relatedEvents = [
                    SELECT Name, Event_Name_gne__c, Planned_Expenses_gne__c, Total_Expenses_gne__c
                    FROM EMS_Event__c
                    WHERE Parent_Speaker_Tour_Event_gne__c = :event.Id OR Id = :event.Id
                    LIMIT 1000
            ];
            return relatedEvents;
        }
        private set;
    }

    public String speakerTourEventsJSON {
        get {
            return JSON.serialize(speakerTourEvents);
        }
    }

    public String cumulativeExpValue {
        get {
            Decimal comulative = 0;
            for (EMS_Event__c event : speakerTourEvents) {
                if (event.Total_Expenses_gne__c != null) {
                    comulative = comulative + event.Total_Expenses_gne__c;
                }
            }
            return String.valueOf(comulative);
        }
    }


    @RemoteAction
    public static EMS_Remote_Response createOLACHEEvent(String parentId) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        EMS_Event__c ev = [
                SELECT Id, Event_Name_gne__c, Event_Sub_Type_gne__c, Event_Type_gne__c
                FROM EMS_Event__c
                WHERE Id = :parentId
        ];
        String eventType = ev.Event_Type_gne__c;
        String eventSubType = ev.Event_Type_gne__c == 'Collaboration' ?
                'Collaboration Activity' : ev.Event_Sub_Type_gne__c;

        Savepoint savePoint = Database.setSavepoint();
        try {
            EMS_Event__c event = new EMS_Event__c(
                    Status_gne__c = 'Unplanned',
                    Country_gne__c = 'Canada',
                    Parent_Speaker_Tour_Event_gne__c = (Id) parentId,
                    Event_Type_gne__c = eventType,
                    Event_Sub_Type_gne__c = eventSubType,
                    Event_Requestor_gne__c = UserInfo.getUserId()
            );
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            insert event;

            response.objectList1 = new List<EMS_Event__c>{
                    event
            };
            response.isSuccess = true;
        } catch (Exception e) {
            Database.rollback(savePoint);
            response.isSuccess = false;
            response.addError(e.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response relateOLAEvents(List<String> idsToRelate, String parentId) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        Map<Id, EMS_Event__c> eventListToUpdate = new Map<Id, EMS_Event__c>([
                SELECT Name, Event_Name_gne__c, Planned_Expenses_gne__c, Total_Expenses_gne__c, Parent_Speaker_Tour_Event_gne__c
                FROM EMS_Event__c
                WHERE Id IN :idsToRelate
        ]);
        if (eventListToUpdate.isEmpty()) {
            response.isSuccess = false;
        } else {
            for (EMS_Event__c eventItem : eventListToUpdate.values()) {
                eventItem.Parent_Speaker_Tour_Event_gne__c = (Id) parentId;
            }
            try {
                EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
                update eventListToUpdate.values();
                response.objectList1 = eventListToUpdate.values();
                response.isSuccess = true;
            } catch (DmlException ex) {
                for (Integer i = 0; i < ex.getNumDml(); i++) {
                    response.addError(ex.getDmlMessage(i));
                }
                response.isSuccess = false;
            }
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response detachOLAEvent(String eventIdToUpdate) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;

        try {
            EMS_Event__c eventToUpdate = [
                    SELECT Parent_Speaker_Tour_Event_gne__c
                    FROM EMS_Event__c
                    WHERE Id = :eventIdToUpdate
                    LIMIT 1
            ];
            eventToUpdate.Parent_Speaker_Tour_Event_gne__c = null;
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            update eventToUpdate;
            response.isSuccess = true;
        } catch (DmlException ex) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.addError(ex.getDmlMessage(i));
            }
            response.isSuccess = false;
        }
        return response;
    }

    @RemoteAction
    public static List<EMS_Event__c> searchOLAEventsBYKeyword(String keyword, String eventRequestorId, String parentId) {
        List<EMS_Event__c> eventList = new List<EMS_Event__c>();
        String phrase = '%' + String.escapeSingleQuotes(keyword) + '%';
        EMS_Event__c parentEvent = [
                SELECT Event_Type_gne__c, Event_Sub_Type_gne__c
                FROM EMS_Event__c
                WHERE Id = :parentId
        ];

        if(parentEvent.Event_Type_gne__c == 'Collaboration') {
            eventList = [
                    SELECT Id, Name, Event_Name_gne__c, Event_Type_gne__c, Event_Sub_Type_gne__c, Planned_Expenses_gne__c, Total_Expenses_gne__c
                    FROM EMS_Event__c
                    WHERE Parent_Speaker_Tour_Event_gne__c = NULL
                    AND Speaker_Tour_gne__c = FALSE
                    AND (Name LIKE :phrase OR Event_Name_gne__c LIKE :phrase)
                    AND Status_gne__c NOT IN :excludedStatuses
                    AND Event_Sub_Type_gne__c != NULL
                    AND Event_Sub_Type_gne__c != 'Collaboration'
                    ORDER BY Name DESC
                    LIMIT :EVENTSEARCHLIMIT
            ];
        } else {
            eventList = [
                    SELECT Id, Name, Event_Name_gne__c, Event_Type_gne__c, Event_Sub_Type_gne__c, Planned_Expenses_gne__c, Total_Expenses_gne__c
                    FROM EMS_Event__c
                    WHERE Parent_Speaker_Tour_Event_gne__c = NULL
                    AND Event_Requestor_gne__c = :eventRequestorId
                    AND Event_Type_gne__c = :TYPE
                    AND Event_Sub_Type_gne__c IN :SUBTYPES
                    AND Speaker_Tour_gne__c = FALSE
                    AND (Name LIKE :phrase OR Event_Name_gne__c LIKE :phrase)
                    AND Status_gne__c NOT IN :excludedStatuses
                    ORDER BY Name DESC
                    LIMIT :EVENTSEARCHLIMIT
            ];
        }
        return eventList;
    }


}