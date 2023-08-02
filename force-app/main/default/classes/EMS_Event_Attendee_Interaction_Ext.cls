global without sharing class EMS_Event_Attendee_Interaction_Ext {

    // **** OBJECTS AND IDS **** //
    public EMS_Event__c event { get; set; }

    // **** CONSTRUCTOR **** //
    public EMS_Event_Attendee_Interaction_Ext(ApexPages.StandardController stdController) {
        event = (EMS_Event__c) stdController.getRecord();
    }

    // **** GETTERS **** //
    public Boolean getIsEMSCanadaUser() {
        if (EMS_Util.getUserApplication() == 'EMS-Canada') {
            return true;
        }
        return false;
    }

    public String getUserRole {
        get {
            return EMS_Util.getUserRole();
        }
    }

    public Boolean canActivateException {
        get {
            return EMS_Access.canActivateAttendeeException();
        }
    }

    public Boolean canUnlockException {
        get {
            return EMS_Access.canUnlockException();
        }
    }

    public Boolean canUpdateFMV {
        get {
            return EMS_Access.canUpdateFMV(event);
        }
    }

    public Boolean getCanEdit() {
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Id, Name, Cost_Center_gne__c, Cost_Center_Type_gne__c, Percentage_Contribution_gne__c, Product_Indication_gne__c, Allocated_Budget_gne__c, Approver_gne__c, Budget_Owner_gne__c, Budget_Owner_gne__r.Name, Status_gne__c, Submitted_By_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :event.Id];
        Boolean isReadOnlyRole = EMS_Access.isMedOpsUser() || EMS_Access.isAPUser() || EMS_Util.isReadOnly();
        Boolean isBudgetOwnerApprover = EMS_Access.isBudgetAllocationDelegeatedUser(budgetAllocations);
        Boolean isEventOwnerRequestor = EMS_Util.isEventOwnerRequestor(event);
        Boolean isBPSEditable = EMS_Access.isBPS() && !EMS_Util.isClosedCancelledEvent(event);
        Boolean isEditable = (EMS_Util.isRecordEditable(event.Id) || EMS_Util.hasEditRights(event)) && !EMS_Util.isClosedCancelledEvent(event);

        if (EMS_Util.isAdmin() || isBPSEditable) {
            return true;
        } else if (isReadOnlyRole || (isBudgetOwnerApprover && !isEventOwnerRequestor)) {
            return false;
        } else {
            return isEditable && getIsEMSCanadaUser();
        }
    }

    public Boolean getCanRequestPayment() {
        if (EMS_Access.isAdmin()) {
            return true;
        } else if (EMS_Access.isBPS()) {
            return event.Status_gne__c == 'Signed Agreement Received' || event.Status_gne__c == 'Payment Request Initiated' || event.Status_gne__c == 'Closed';
        } else {
            return false;
        }
    }

    public Boolean getOldDataFieldsVisible() {
        return EMS_Util.oldDataFieldsVisible(event.CreatedDate);
    }

    public Boolean getOldFMVPreceptorshipsHcpToRoche() {
        return EMS_Util.oldFMVPreceptorshipsHcpToRoche(event.CreatedDate);
    }

    public Boolean getIsEventOwnerRequestor() {
        return EMS_Util.isEventOwnerRequestor(event);
    }

    public Boolean getIsEventLockedByRecordType() {
        return EMS_Util.isEventLockedByRecordType(event);
    }

    public Boolean getDisplayTieringColumns() {
        return event.CreatedDate.year() >= 2017;
    }

    public Boolean getDisplayTierException() {
        return event.Event_Sub_Type_gne__c != 'Journal Club / Post Congress / In Kind'
                && event.Event_Sub_Type_gne__c != 'Journal Club / Post Congress'
                && event.Event_Sub_Type_gne__c != 'Journal Club'
                && event.Event_Sub_Type_gne__c != 'Institutional/Clinic Session - Product Training';
    }

    global static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchInternationalSpeakers(String searchString, Integer recordLimit) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
        for (EMS_International_Speaker_gne__c ihcp : [
                SELECT Id, Name, First_Name_gne__c, Last_Name_gne__c, Address_gne__c, Country_gne__c
                FROM EMS_International_Speaker_gne__c
                WHERE (
                        First_Name_gne__c LIKE :searchString
                        OR Last_Name_gne__c LIKE :searchString
                        OR Name LIKE :searchString
                )
                AND Is_Active_gne__c = TRUE
                LIMIT :recordLimit
        ]) {
            GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper = new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(new Account(), null);
            wrapper.accountId = ihcp.Id;
            wrapper.accountDescription = ihcp.Last_Name_gne__c + ', ' + ihcp.First_Name_gne__c;
            wrapper.recordType = 'iHCP';
            if (ihcp.Country_gne__c != null && ihcp.Address_gne__c != null) {
                wrapper.addressDescription = ihcp.Address_gne__c + ', ' + ihcp.Country_gne__c;
            } else if (ihcp.Country_gne__c != null) {
                wrapper.addressDescription = ihcp.Country_gne__c;
            } else {
                wrapper.addressDescription = '';
            }
            wrapper.isContact = false;
            wrapper.isUser = false;

            result.add(wrapper);
        }
        return result;
    }


    // **** UPSERT METHODS **** //
    private static Map<String, String> upsertRocheAttendees(Id eventId, List<AttendeeWrapper> attendees, Boolean skipEventTriggers) {
        List<EMS_Roche_Attendee_gne__c> toUpsert = new List<EMS_Roche_Attendee_gne__c>();
        for (AttendeeWrapper attendee : attendees) {
            EMS_Roche_Attendee_gne__c attendeeRecord = new EMS_Roche_Attendee_gne__c(
                    EMS_Event_gne__c = eventId,
                    User_gne__c = attendee.attendeeId,
                    Territory_Id_gne__c = attendee.territoryId
            );
            if (attendee.recordId != null) {
                attendeeRecord.Id = attendee.recordId; // existing attendee which has to be updated
            }
            toUpsert.add(attendeeRecord);
        }

        Map<String, String> attendeeIdToRecordId = new Map<String, String>();
        if (!toUpsert.isEmpty()) {
            if (skipEventTriggers) {
                EMS_Event_Trigger_Helper.skipTrigger = true;
            }
            upsert toUpsert;

            for (EMS_Roche_Attendee_gne__c upsertedRecord : toUpsert) {
                if (upsertedRecord.User_gne__c != null) {
                    attendeeIdToRecordId.put(upsertedRecord.User_gne__c, upsertedRecord.Id);
                }
            }
        }
        return attendeeIdToRecordId;
    }

    private static Map<String, String> upsertAttendees(Id eventId, List<AttendeeWrapper> attendees, Boolean skipEventTriggers) {
        List<EMS_Attendee_gne__c> toUpsert = new List<EMS_Attendee_gne__c>();
        for (AttendeeWrapper attendee : attendees) {
            SObjectType parentObjectType = String.isBlank(attendee.attendeeId) ?
                    null : attendee.attendeeId.getSobjectType();
            SObjectType attendeeSObjectType = String.isBlank(attendee.recordId) ?
                    null : attendee.recordId.getSobjectType();
            EMS_Attendee_gne__c attendeeRecord = new EMS_Attendee_gne__c(
                    EMS_Event_gne__c = eventId,
                    Role_gne__c = attendee.role,
                    Status_gne__c = attendee.status,
                    Contract_gne__c = attendee.contract,
                    Milestone_Payment_gne__c = attendee.milestonePayment
            );
            if (attendee.exceptionActivated == 'now') {
                attendeeRecord.Exception_accepted_at_gne__c = Datetime.now();
                attendee.exceptionActivated = String.valueOf(attendeeRecord.Exception_accepted_at_gne__c);
            }
            if (attendee.recordId != null && attendeeSObjectType == EMS_Attendee_gne__c.SObjectType) {
                attendeeRecord.Id = attendee.recordId; // existing attendee which has to be updated
            } else {
                if (parentObjectType == Account.SObjectType) {
                    attendeeRecord.Account_gne__c = attendee.attendeeId;
                } else if (parentObjectType == EMS_International_Speaker_gne__c.SObjectType) {
                    attendeeRecord.EMS_International_Speaker_gne__c = attendee.attendeeId;
                }
            }
            if(String.isBlank(attendee.attendeeId) && String.isNotBlank(attendee.attendeeName)) {
                attendeeRecord.Non_Stakeholder_Name__c = attendee.attendeeName;
            }
            toUpsert.add(attendeeRecord);
        }

        Map<String, String> attendeeIdToRecordId = new Map<String, String>();
        if (!toUpsert.isEmpty()) {
            if (skipEventTriggers) {
                EMS_Event_Trigger_Helper.skipTrigger = true;
            }
            upsert toUpsert;

            for (EMS_Attendee_gne__c upsertedRecord : toUpsert) {
                String attendeeId;
                if(String.isNotBlank(upsertedRecord.Account_gne__c)) {
                    attendeeId = upsertedRecord.Account_gne__c;
                } else if(String.isNotBlank(upsertedRecord.EMS_International_Speaker_gne__c)) {
                    attendeeId = upsertedRecord.EMS_International_Speaker_gne__c;
                } else {
                    attendeeId = upsertedRecord.Id;
                }

                if (attendeeId != null) {
                    attendeeIdToRecordId.put(attendeeId, upsertedRecord.Id);
                }
            }
        }

        return attendeeIdToRecordId;
    }

    // **** REMOTE METHODS **** //

    // Getters

    @RemoteAction
    public static List<AttendeeWrapper> getEventAttendees(Id eventId) {
        List<AttendeeWrapper> attendees = new List<AttendeeWrapper>();
        Map<Id, User> usersMap = new Map<Id, User>([
                SELECT Id, Name
                FROM User
                WHERE Id IN (
                        SELECT User_gne__c
                        FROM EMS_Roche_Attendee_gne__c
                        WHERE EMS_Event_gne__c = :eventId
                        AND Is_Watcher_gne__c = FALSE
                )
        ]);
        Map<Id, Account> accountsMap = new Map<Id, Account>([
                SELECT Id, Name, IsPersonAccount
                FROM Account
                WHERE Id IN (
                        SELECT Account_gne__c
                        FROM EMS_Attendee_gne__c
                        WHERE EMS_Event_gne__c = :eventId
                )
        ]);
        Map<Id, EMS_International_Speaker_gne__c> ihcpMap = new Map<Id, EMS_International_Speaker_gne__c>([
                SELECT Id, Name, First_Name_gne__c, Last_Name_gne__c
                FROM EMS_International_Speaker_gne__c
                WHERE Id IN (
                        SELECT EMS_International_Speaker_gne__c
                        FROM EMS_Attendee_gne__c
                        WHERE EMS_Event_gne__c = :eventId
                )
        ]);

        if (eventId != null) {
            for (EMS_Attendee_gne__c ia : [
                    SELECT Type_of_HCP_gne__c, Milestone_Payment_gne__c, Account_gne__c, Account_gne__r.HCP_Stakeholder_Type_gne__c,
                            Account_gne__r.Tier_Level_gne__c, Account_gne__r.IsPersonAccount, Account_gne__r.Account_Type_gne__c,
                            EMS_International_Speaker_gne__c, Status_gne__c, Total_Honoraria_gne__c, Role_gne__c, Contract_gne__c,
                            Exception_comment_gne__c, Exception_accepted_at_gne__c, Exception_requested_at_gne__c, Field_of_Expertise__c
                    FROM EMS_Attendee_gne__c
                    WHERE EMS_International_Speaker_gne__c != NULL
                    AND EMS_Event_gne__c = :eventId
            ]) {
                if (String.isNotBlank(ia.EMS_International_Speaker_gne__c) && ihcpMap.containsKey(ia.EMS_International_Speaker_gne__c)) {
                    attendees.add(new AttendeeWrapper(ia, ihcpMap.get(ia.EMS_International_Speaker_gne__c)));
                }
            }
            // EMS attendees
            for (EMS_Attendee_gne__c ea : [
                    SELECT Type_of_HCP_gne__c, Milestone_Payment_gne__c, Account_gne__c, Account_gne__r.HCP_Stakeholder_Type_gne__c,
                            Account_gne__r.Tier_Level_gne__c, Account_gne__r.Name, Account_gne__r.IsPersonAccount, Account_gne__r.Account_Type_gne__c,
                            EMS_International_Speaker_gne__c, Status_gne__c, Total_Honoraria_gne__c, Role_gne__c, Contract_gne__c, Exception_accepted_at_gne__c,
                            Exception_comment_gne__c, Exception_requested_at_gne__c, Field_of_Expertise__c
                    FROM EMS_Attendee_gne__c
                    WHERE Account_gne__c != NULL AND EMS_Event_gne__c = :eventId
            ]) {
                if (String.isNotBlank(ea.Account_gne__c) && accountsMap.containsKey(ea.Account_gne__c)) {
                    attendees.add(new AttendeeWrapper(ea, accountsMap.get(ea.Account_gne__c)));
                }
            }
            // Roche attendees
            for (EMS_Roche_Attendee_gne__c ra : [
                    SELECT Id, User_gne__c, Territory_Id_gne__c
                    FROM EMS_Roche_Attendee_gne__c
                    WHERE EMS_Event_gne__c = :eventId
                    AND Is_Watcher_gne__c = FALSE
            ]) {
                if (String.isNotBlank(ra.User_gne__c) && usersMap.containsKey(ra.User_gne__c)) {
                    attendees.add(new AttendeeWrapper(ra, usersMap.get(ra.User_gne__c)));
                }
            }
        }
        return attendees;
    }

    @RemoteAction
    public static List<EMS_Event_Product_gne__c> getEventProducts(Id eventId) {
        return [
                SELECT Id, Product_Indication_gne__r.Name, Product_Indication_gne__c, Product_Strategy_gne__c, Product_Strategy_gne__r.Name, Event_gne__c
                FROM EMS_Event_Product_gne__c
                WHERE Event_gne__c = :eventId
                ORDER BY Product_Indication_gne__r.Name, CreatedDate ASC
        ];
    }

    //noinspection ApexUnusedDeclaration
    @RemoteAction
    public static Map<Id, List<EMS_Util.EMS_Territory>> getUserTerritories(Id eventId, List<Id> rocheAttendeeIds) {
        return EMS_Util.getUserTerritories(new Set<Id>(rocheAttendeeIds));
    }

    // New common method
    @RemoteAction
    public static List<RocheAttendeeWrapper> getRocheAttendeesWithTerritories(Id eventId) {
        List<RocheAttendeeWrapper> rocheAttendees_w = new List<RocheAttendeeWrapper>();
        Set<Id> rocheAttendeeUsersID = new Set<Id>();
        for (EMS_Roche_Attendee_gne__c rocheAttendee : getRocheAttendees(eventId)) {
            rocheAttendees_w.add(new RocheAttendeeWrapper(
                    rocheAttendee,
                    rocheAttendee.User_gne__c
            ));
            rocheAttendeeUsersID.add(rocheAttendee.User_gne__c);
        }
        Map<Id, List<EMS_Util.EMS_Territory>> userIdToUserTerritoryMap = EMS_Util.getUserTerritories(rocheAttendeeUsersID);
        for (RocheAttendeeWrapper rocheAttendee_w : rocheAttendees_w) {
            if (userIdToUserTerritoryMap.containsKey(rocheAttendee_w.userId)) {
                rocheAttendee_w.addTerritories(userIdToUserTerritoryMap.get(rocheAttendee_w.userId));
            }
        }
        return rocheAttendees_w;
    }

    @RemoteAction
    public static List<EMS_Roche_Attendee_gne__c> getRocheAttendees(Id eventId) {
        return [
                SELECT Id, User_gne__c, User_gne__r.Name, Territory_Id_gne__c
                FROM EMS_Roche_Attendee_gne__c
                WHERE EMS_Event_gne__c = :eventId AND Is_Watcher_gne__c = FALSE
                ORDER BY CreatedDate ASC
        ];
    }

    @RemoteAction
    public static List<EMS_Attendee_gne__c> getNonStakeholderAttendee(Id eventId) {
        return [
                SELECT Id, Name_gne__c, Payable_To_Name_gne__c, Role_gne__c, Contract_gne__c, Status_gne__c, Total_Honoraria_gne__c
                FROM EMS_Attendee_gne__c
                WHERE EMS_Event_gne__c = :eventId AND (Account_gne__c = NULL AND EMS_International_Speaker_gne__c = NULL)
                ORDER BY CreatedDate ASC
        ];
    }

    @RemoteAction
    public static List<AttendeeWrapper> getHCPsAndiHCPsAttendee(Id eventId) {
        List<EMS_Attendee_gne__c> attendees = [
                SELECT Id, Account_gne__r.Name, Account_gne__r.IsPersonAccount, Account_gne__c, EMS_International_Speaker_gne__c, EMS_International_Speaker_gne__r.Name
                FROM EMS_Attendee_gne__c
                WHERE EMS_Event_gne__c = :eventId AND (Account_gne__c != NULL OR EMS_International_Speaker_gne__c != NULL)
                ORDER BY CreatedDate ASC
        ];

        List<AttendeeWrapper> attendees_w = new List<AttendeeWrapper>();
        for (EMS_Attendee_gne__c attendee : attendees) {
            if (attendee.Account_gne__c != null) {                           // HCP Attendee
                attendees_w.add(new AttendeeWrapper(
                        attendee.Id,
                        attendee.Account_gne__r.Name,
                        attendee.Account_gne__c,
                        attendee.Account_gne__r.IsPersonAccount ? 'HCP' : 'HCO',
                        null,
                        null,
                        null,
                        null,
                        null
                ));
            } else if (attendee.EMS_International_Speaker_gne__c != null) {  // iHCP Attendee
                attendees_w.add(new AttendeeWrapper(
                        attendee.Id,
                        attendee.EMS_International_Speaker_gne__r.Name,
                        attendee.EMS_International_Speaker_gne__c,
                        'iHCP',
                        null,
                        null,
                        null,
                        null,
                        null
                ));
            }
        }
        return attendees_w;
    }

    @RemoteAction
    public static List<EMS_Interaction_gne__c> getEventInteractions(Id eventId) {
        return [
                SELECT Id, EMS_Roche_Attendee__r.Id, EMS_Roche_Attendee__r.User_gne__r.Name,
                        EMS_Attendee_gne__r.Id, EMS_Attendee_gne__r.Account_gne__c,
                        EMS_Attendee_gne__r.Account_gne__r.Name, EMS_Attendee_gne__r.Contact_gne__c,
                        EMS_Attendee_gne__r.EMS_International_Speaker_gne__r.Name,
                        Interaction_gne__r.Id, Interaction_gne__r.Account_vod__c,
                        Interaction_gne__r.User_vod__c, Interaction_gne__r.Territory_vod__c,
                        Call_Detail_gne__r.Id, Call_Discussion_gne__r.Id, Call_Detail_gne__r.Product_vod__c,
                        Call_Discussion_gne__r.Product_Strategy_vod__c, Call_Discussion_gne__r.Reaction_gne__c,
                        Call_Discussion_gne__r.Product_vod__c, Call_Discussion_gne__r.Product_Tactic_vod__c,
                        Account_gne__c, Contact_gne__c, Product_gne__c, Product_gne__r.Name,
                        Product_Strategy_gne__c, Product_Strategy_gne__r.Name, Reaction_gne__c,
                        Territory_gne__c, EMS_Roche_Attendee__r.User_gne__c, Quantity_gne__c, Tool_gne__c, Tool_gne__r.Name
                FROM EMS_Interaction_gne__c
                WHERE EMS_Event__c = :eventId
                ORDER BY Product_gne__r.Name, CreatedDate ASC
        ];
    }

    @RemoteAction
    public static Map<Id, List<Product_vod__c>> getProductTools() {
        Map<Id, List<Product_vod__c>> result = new Map<Id, List<Product_vod__c>>();
        for (Product_vod__c product : [
                SELECT Id, Name, Product_Type_vod__c, Parent_Product_vod__c
                FROM Product_vod__c
                WHERE active__c = TRUE
                AND Product_Type_vod__c NOT IN ('Detail', 'Market', 'Sample')
                ORDER BY Product_Type_vod__c, Name
        ]) {
            if (!result.containsKey(product.Parent_Product_vod__c)) {
                result.put(product.Parent_Product_vod__c, new List<Product_vod__c>());
            }
            result.get(product.Parent_Product_vod__c).add(product);
        }
        return result;
    }

    @RemoteAction
    global static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> getAffiliatedAccounts(List<Id> selectedAccountIds) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
        List<Id> accountIds = new List<Id>();
        Integer resultSizeLimit = 100;
        Integer counter = 0;
        if (selectedAccountIds.size() > 0) {
            for (Affiliation_vod__c affiliation : [
                    SELECT Id, Name, From_Account_vod__c, To_Account_Type_gne__c, To_Account_vod__c, To_Contact_vod__c
                    FROM Affiliation_vod__c
                    WHERE From_Account_vod__c IN :selectedAccountIds
                    AND To_Account_vod__c != NULL
            ]) {
                accountIds.add(affiliation.To_Account_vod__c);
            }

            for (Account acc : [
                    SELECT Id, FirstName, LastName, Territory_vod__c, Name, IsPersonAccount
                    FROM Account
                    WHERE Id IN :accountIds
                    AND IsPersonAccount = TRUE
                    ORDER BY LastName, FirstName
                    LIMIT 100
            ]) {
                if (counter++ > resultSizeLimit) {
                    break;
                }
                result.add(new GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper(acc, null));
            }
        }
        return result;
    }

    // CRUD Methods

    @RemoteAction
    public static CustomRemoteResponse saveEventAttendees(Id eventId, String eventAttendeesJSON, Boolean skipEventTriggers) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;

        List<AttendeeWrapper> eventAttendees = (List<AttendeeWrapper>) JSON.deserialize(eventAttendeesJSON, List<AttendeeWrapper>.class);
        List<AttendeeWrapper> attendees = new List<AttendeeWrapper>();
        List<AttendeeWrapper> rocheAttendees = new List<AttendeeWrapper>();
        for (AttendeeWrapper att : eventAttendees) {
            if (att.type == 'Employee') {
                rocheAttendees.add(att);
            } else {
                attendees.add(att);
            }
        }

        CustomRemoteResponse customResponse = new CustomRemoteResponse();
        Map<String, String> attendeeIdToRecordId = new Map<String, String>();
        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            attendeeIdToRecordId.putAll(upsertAttendees(eventId, attendees, skipEventTriggers));
            attendeeIdToRecordId.putAll(upsertRocheAttendees(eventId, rocheAttendees, skipEventTriggers));
        } catch (DmlException ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>();

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }
        customResponse.response = response;
        customResponse.attendeeIdToRecordId = attendeeIdToRecordId;
        return customResponse;
    }

    @RemoteAction
    public static EMS_Remote_Response deleteEventAttendees(String idsJSON, Boolean skipEventTriggers) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;

        Set<Id> ids = (Set<Id>) JSON.deserialize(idsJSON, Set<Id>.class);
        try {
            if (skipEventTriggers) {
                EMS_Event_Trigger_Helper.skipTrigger = true;
                EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            }
            delete [SELECT Id FROM EMS_Attendee_gne__c WHERE Id IN :ids];
            delete [SELECT Id FROM EMS_Roche_Attendee_gne__c WHERE Id IN :ids];
        } catch (DmlException ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>();

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response saveNonHCPAttendees(Id eventId, Integer nonHCPAttendees) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;

        EMS_Event__c event = [SELECT Non_HCP_Attendees_gne__c FROM EMS_Event__c WHERE Id = :eventId LIMIT 1];
        try {
            event.Non_HCP_Attendees_gne__c = nonHCPAttendees;
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            update event;
        } catch (DmlException ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>();

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }
        return response;
    }

    @RemoteAction
    public static CustomRemoteResponse saveTierExceptionRequest(String attendeesMapJSON) {
        List<AttendeeWrapper> attendees = (List<AttendeeWrapper>) JSON.deserialize(attendeesMapJSON, List<AttendeeWrapper>.class);
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;
        CustomRemoteResponse customResponse = new CustomRemoteResponse();
        Map<String, String> attendeesIdsToComment = new Map<String, String>();
        Map<String, String> attendeeIdToRecordId = new Map<String, String>();

        for (AttendeeWrapper att : attendees) {
            attendeesIdsToComment.put(att.recordId, att.exceptionComment);
        }

        List<EMS_Attendee_gne__c> attendeesToUpsert = [
                SELECT Id, Exception_comment_gne__c, Exception_requested_at_gne__c
                FROM EMS_Attendee_gne__c
                WHERE Id IN :attendeesIdsToComment.keySet()
        ];
        for (EMS_Attendee_gne__c att : attendeesToUpsert) {
            att.Exception_comment_gne__c = attendeesIdsToComment.get(att.Id);
            att.Exception_requested_at_gne__c = Datetime.now();
        }
        try {
            if (!attendeesToUpsert.isEmpty()) {

                upsert attendeesToUpsert;

                for (EMS_Attendee_gne__c upsertedRecord : attendeesToUpsert) {
                    String attendeeId = (upsertedRecord.Account_gne__c != null) ? upsertedRecord.Account_gne__c : upsertedRecord.EMS_International_Speaker_gne__c;
                    if (attendeeId != null) {
                        attendeeIdToRecordId.put(attendeeId, upsertedRecord.Id);
                    }
                }
            }
        } catch (DmlException ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>();

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }
        customResponse.response = response;
        customResponse.attendeeIdToRecordId = attendeeIdToRecordId;
        return customResponse;
    }

    @RemoteAction
    public static EMS_Remote_Response upsertEventInteraction(EMS_Interaction_gne__c interaction) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            upsert interaction;
            response.isSuccess = true;
            response.responseObject = interaction;
        } catch (DmlException ex) {
            response.errorMessages = new List<String>();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }

        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response deleteEventInteractions(List<String> interactionsID) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            delete [SELECT Id FROM EMS_Interaction_gne__c WHERE Id IN:interactionsID];
            response.isSuccess = true;
        } catch (DmlException ex) {
            response.errorMessages = new List<String>();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }
        return response;
    }

    @RemoteAction
    public static void refreshInteractions(Id eventId) {
        refreshInteractionsOnProductUpdate(eventId);
        refreshInteractionsOnAttendeeUpdate(eventId);
    }

    // Refresh page section
    @RemoteAction
    public static void refreshInteractionsOnProductUpdate(Id eventId) {
        Set<Id> eventProductsIds = new Set<Id>();
        Set<Id> strategyIds = new Set<Id>();
        for (EMS_Event_Product_gne__c eventProduct : [
                SELECT Id, Product_Indication_gne__c, Product_Strategy_gne__c, Event_gne__c
                FROM EMS_Event_Product_gne__c
                WHERE Event_gne__c = :eventId
        ]) {
            eventProductsIds.add(eventProduct.Product_Indication_gne__c);
            strategyIds.add(eventProduct.Product_Strategy_gne__c);
        }

        List<EMS_Interaction_gne__c> interactionsToDelete = [
                SELECT Id
                FROM EMS_Interaction_gne__c
                WHERE EMS_Event__c = :eventId
                AND (
                        Product_gne__c NOT IN :eventProductsIds
                        OR Product_Strategy_gne__c NOT IN :strategyIds
                )
        ];
        delete interactionsToDelete;
    }

    @RemoteAction
    public static void refreshInteractionsOnAttendeeUpdate(Id eventId) {
        List<EMS_Attendee_gne__c> eventAttendees = new List<EMS_Attendee_gne__c>([
                SELECT Id
                FROM EMS_Attendee_gne__c
                WHERE EMS_Event_gne__c = :eventId
        ]);
        List<EMS_Roche_Attendee_gne__c> rocheAttendees = new List<EMS_Roche_Attendee_gne__c>([
                SELECT Id
                FROM EMS_Roche_Attendee_gne__c
                WHERE EMS_Event_gne__c = :eventId AND Is_Watcher_gne__c = TRUE
        ]);

        Database.delete([
                SELECT Id
                FROM EMS_Interaction_gne__c
                WHERE EMS_Event__c = :eventId
                AND EMS_Roche_Attendee__c NOT IN :rocheAttendees
                AND EMS_Attendee_gne__c NOT IN :eventAttendees
        ]);
    }

    //Search methods
    @RemoteAction
    global static List<EMS_SearchUtils.AccountWrapper> searchAccountsEmployees(String searchString, Boolean allAccounts, Boolean myAccounts, Boolean myTargets, Boolean tieredAccounts) {
        List<EMS_SearchUtils.AccountWrapper> result = new List<EMS_SearchUtils.AccountWrapper>();
        Integer recordsLimit = 50;

        String whereClause = 'WHERE name LIKE :searchString AND (NOT (Account_Type_gne__c in (\'Physician\', \'Pharmacist\') AND MRM_Status_can_gne__c <> \'ACTIVE\'))';
        //noinspection ApexUnusedDeclaration
        String searchType = '';
        if (allAccounts) {
            whereClause += ' ORDER BY Name limit :recordLimit';
        } else if (myAccounts) {
            whereClause += ' AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c in :terrNames) ORDER BY Name limit :recordLimit';
        } else if (myTargets) {
            whereClause += ' AND Id IN (SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c in :terrNames AND My_Target_vod__c = true) ORDER BY Name limit :recordLimit';
        } else if (tieredAccounts) {
            whereClause += ' AND HCP_Stakeholder_Type_gne__c != null ORDER BY Name limit :recordLimit';
        }

        result.addAll(EMS_SearchUtils.searchAccounts(searchString, recordsLimit, whereClause));
        result.addAll(EMS_SearchUtils.searchEmployees(searchString, recordsLimit - result.size(), 'EMS-Canada'));
        result.addAll(EMS_SearchUtils.searchInternationalSpeakers(searchString, recordsLimit - result.size()));

        return result;
    }

    @RemoteAction
    global static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchAccountsContactsEmployees(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean myTargetsOnly, Id callAccountId) {
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result = GNE_SFA2_SearchAccounts_Controller.searchAccountsEmployees(searchString, recordLimit, allAccounts, onlyPersonAccounts, myTargetsOnly, new List<Id>{
                callAccountId
        }, 'EMS-Canada');
        result.addAll(searchInternationalSpeakers(searchString, recordLimit));
        return result;
    }

    // **** HONORARIUM POPUP METHODS **** //

    private static Map<String, List<String>> prepareMapWithConditions(Map<String, List<String>> result, EMS_FMV_Configuration_gne__c config, String recordType, Boolean speakerTour) {
        if (String.isNotBlank(config.Attendee_Status_gne__c) && recordType == 'Attendee Status Config') {
            // "Attendee Status Config Layout" Record Type conditions
            // List values for Attendee Status dropdown
            result.put(String.valueOf(config.Attendee_Status_gne__c), null);
        }

        if (String.isNotBlank(config.Attendee_Contract_gne__c) && recordType == 'Attendee Contract Config') {
            // "Attendee Contract Config Layout" Record Type conditions
            // List values for Attendee Contract dropdown
            result.put(String.valueOf(config.Attendee_Contract_gne__c), null);
        }

        if (String.isNotBlank(config.Available_Role_gne__c) && recordType == 'Available Roles Config') {
            // "Available Role Config Layout" Record Type conditions
            // List Role values for Attendee to control FMV form visibility (show/hide FMV icon)
            String keyRole = String.valueOf(config.Available_Role_gne__c);
            String valueFMVAvailable = String.valueOf(config.FMV_Form_Available_gne__c);
            result = populateMap(result, keyRole, valueFMVAvailable);
        }

        if (String.isNotBlank(config.Disturbance_Fee_gne__c) && recordType == 'KM (Round trip) Config') {
            // Dist Fee value controls visibility and values of KM field
            String keyDisturbanceFee = String.valueOf(config.Disturbance_Fee_gne__c);
            String valueRoundTrip = String.valueOf(config.KM_round_trip_gne__c);
            result = populateMap(result, keyDisturbanceFee, valueRoundTrip);
        }

        if (recordType == 'Activity Time Config') {
            // "Attendee Role" and "HCP Type" control Activity Time values
            String keyRole = String.valueOf(config.Available_Role_gne__c)
                    // Allow config without "HCP Type"
                    + (String.isBlank(config.Type_of_HCP_gne__c) ? '' : '_' + String.valueOf(config.Type_of_HCP_gne__c));
            String valuePreparationTime = String.valueOf(config.Activity_Time_gne__c);
            result = populateMap(result, keyRole, valuePreparationTime);
        }

        if (recordType == 'Preparation Time Config') {
            String keyRole = String.valueOf(config.Available_Role_gne__c);
            String valuePreparationTime = String.valueOf(config.Preparation_Time_gne__c);
            result = populateMap(result, keyRole, valuePreparationTime);
        }

        if (recordType == 'Disturbance Fee Config') {
            // REMEMBER "ORDER BY Speaker_Tour_gne__c DESC NULLS LAST" should be always in the SOQL for the logic below
            String keyType = String.valueOf(config.Disturbance_Fee_gne__c) + '_' + String.valueOf(config.Type_of_HCP_gne__c);
            String valueAmount = String.valueOf(config.Disturbance_Fee_Amount_gne__c);

            // If for Speaker Tour event there are no FMV Config records, the logic gets settings from Non Speaker Tour Record
            Boolean notSpeakerTour = speakerTour == false && config.Speaker_Tour_gne__c == false;
            Boolean asSpeakerTour = !result.containsKey(keyType) && speakerTour == true;
            Boolean isSpeakerTour = speakerTour == true && config.Speaker_Tour_gne__c == true;
            if (notSpeakerTour || asSpeakerTour || isSpeakerTour) {
                result = populateMap(result, keyType, valueAmount);
            }
        }

        if (recordType == 'Hourly Rate Config') {
            String keyType = String.valueOf(config.Type_of_HCP_gne__c);
            String valueRate = String.valueOf(config.Hourly_Rate_of_HCP_gne__c);
            if (result.containsKey(keyType)) {
                result.get(keyType).clear();
            }
            result = populateMap(result, keyType, valueRate);
        }

        if (recordType == 'Type of HCP Config') {
            String value = String.valueOf(config.Type_of_HCP_gne__c);
            String order = String.valueOf(config.Order_gne__c);
            result = populateMap(result, order, value);
        }

        return result;
    }

    private static Map<String, List<String>> populateMap(Map<String, List<String>> valueMap, String mapKey, String newValue) {
        if (valueMap.get(mapKey) != null) {
            // Remove Duplicates
            Set<String> tempList = new Set<String>(valueMap.get(mapKey));
            tempList.add(newValue);
            valueMap.put(mapKey, new List<String>(tempList));
        } else {
            valueMap.put(mapKey, new List<String>{
                    newValue
            });
        }
        return valueMap;
    }

    @RemoteAction
    public static EMS_Attendee_gne__c getHCPAttendeeData(String attendeeId) {
        return [
                SELECT Preparation_Time_1_gne__c, Preparation_Time_2_gne__c, Preparation_Time_3_gne__c, Preparation_Time_4_gne__c, Preparation_Time_5_gne__c, Preparation_Time_6_gne__c,
                        Account_gne__r.Name, EMS_International_Speaker_gne__r.Name, Activity_Time_gne__c, Address_gne__c, Disturbance_Fee__c, Email_address_gne__c, Hourly_Rate_of_HCP_gne__c,
                        EMS_Event_gne__r.Start_Date_gne__c, EMS_Event_gne__r.End_Date_gne__c,EMS_Event_gne__r.Status_gne__c, Event_Start_Time_gne__c, Event_End_Time_gne__c, Payable_To_Name_gne__c,
                        km_gne__c, Name_and_email_of_the_contact_person_gne__c, Role_gne__c, Type_of_HCP_other_gne__c, HCP_hourly_rate_table_gne__c, Type_of_HCP_gne__c,
                        Preferred_way_to_contact_the_speaker_gne__c, Special_Request_additional_inf_gne__c, Topic_and_Intent_gne__c, Telephone_number_gne__c, RecordType.Name,
                        Total_Honoraria_gne__c, Activity_Time_1_gne__c,Activity_Time_2_gne__c, Activity_Time_3_gne__c, Activity_Time_4_gne__c, Activity_Time_5_gne__c, Activity_Time_6_gne__c,
                        Hourly_Rate_of_HCP_2_gne__c, Disturbance_Fee_Amount_gne__c, Activity_Amount_gne__c, Talk_Prep_Amount_gne__c, Prep_Time_gne__c, Prep_Amount_gne__c, New_FMV_Form_gne__c,
                        Exception_accepted_at_gne__c, Exception_comment_gne__c, Exception_requested_at_gne__c, Account_gne__r.HCP_Stakeholder_Type_gne__c, Account_gne__r.Tier_Level_gne__c,
                        Topic_and_Intent_1_gne__c, Topic_and_Intent_2_gne__c, Topic_and_Intent_3_gne__c, Topic_and_Intent_4_gne__c, Topic_and_Intent_5_gne__c, Topic_and_Intent_6_gne__c,
                        Account_gne__r.Account_Type_gne__c, Field_of_Expertise__c, Status_gne__c, Name_gne__c, Not_Licensed_HCP__c
                FROM EMS_Attendee_gne__c
                WHERE Id = :attendeeId
                LIMIT 1
        ];
    }

    @RemoteAction
    public static EMS_Event__c getEventData(String eventId) {
        return [SELECT Start_Date_gne__c, End_Date_gne__c FROM EMS_Event__c WHERE Id = :eventId LIMIT 1];
    }

    @RemoteAction
    public static EMS_Remote_Response saveHonorariumPopup(EMS_Attendee_gne__c att) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;
        try {
            upsert att;
        } catch (DmlException ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.isSuccess = false;
            response.errorMessages = new List<String>{
                    ex.getMessage()
            };
        }
        return response;
    }

    @RemoteAction
    public static List<EMS_Speaker_Role_gne__c> getPaymentRequests(String eventId, String attendeeId) {
        return [
                SELECT Id,Name,HCP_HCO_iHCP_gne__c,Account_Type_gne__c,Total_Amount_gne__c,CreatedDate,Status_gne__c, (SELECT Id, Name FROM EMS_Expenses__r)
                FROM EMS_Speaker_Role_gne__c
                WHERE EMS_Event_gne__c = :eventId
                AND (
                        EMS_International_Speaker_gne__c = :attendeeId
                        OR HCP_gne__c = :attendeeId
                )
        ];
    }

    @RemoteAction
    public static String getFMVSettings(String type, String subtype, Boolean speakerTour) {
        Map<String, Map<String, List<String>>> results = new Map<String, Map<String, List<String>>>();
        List<EMS_FMV_Configuration_gne__c> configsFMV = [
                SELECT RecordType.Name, Activity_Time_gne__c, Attendee_Contract_gne__c, Attendee_Status_gne__c, Available_Role_gne__c,
                        Disturbance_Fee_gne__c, Disturbance_Fee_Amount_gne__c, EMS_Event_Configuration_gne__c, FMV_Form_Available_gne__c, Hourly_Rate_of_HCP_gne__c,
                        KM_round_trip_gne__c, Preparation_Time_gne__c, Speaker_Tour_gne__c, Type_of_HCP_gne__c, Order_gne__c
                FROM EMS_FMV_Configuration_gne__c
                WHERE (EMS_Event_Configuration_gne__r.Event_Type_gne__c = :type
                AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :subtype)
                OR EMS_Event_Configuration_gne__c = NULL
                ORDER BY EMS_Event_Configuration_gne__c NULLS FIRST, Speaker_Tour_gne__c DESC NULLS LAST
        ];

        for (EMS_FMV_Configuration_gne__c config : configsFMV) {
            String recordType = config.RecordType.Name;
            if (results.get(recordType) == null) {
                results.put(recordType, new Map<String, List<String>>());
            }

            Map<String, List<String>> settingsMap = prepareMapWithConditions(results.get(recordType), config, recordType, speakerTour);
            results.put(recordType, settingsMap);
        }
        return JSON.serialize(results);
    }

    // **** WRAPPERS **** //
    public class CustomRemoteResponse {
        public EMS_Remote_Response response;
        Map<String, String> attendeeIdToRecordId;
    }

    public class AttendeeWrapper {
        public Id recordId { get; set; }
        public String attendeeName { get; set; }
        public Id attendeeId { get; set; }
        public String type { get; set; }
        public Id territoryId { get; set; }
        public String role { get; set; }
        public String status { get; set; }
        public String contract { get; set; }
        public Decimal amount { get; set; }
        public String tier { get; set; }
        public String stakeholder { get; set; }
        public String accountType { get; set; }
        public String exceptionRequested { get; set; }
        public String exceptionActivated { get; set; }
        public String exceptionComment { get; set; }
        public Boolean isEmployee { get; set; }
        public Boolean milestonePayment { get; set; }

        public AttendeeWrapper(EMS_Attendee_gne__c attendee, Account account) {
            recordId = attendee.Id;
            attendeeName = account.Name;
            attendeeId = attendee.Account_gne__c;
            territoryId = null;
            role = attendee.Role_gne__c;
            status = attendee.Status_gne__c;
            contract = attendee.Contract_gne__c;
            amount = attendee.Total_Honoraria_gne__c;
            isEmployee = false;
            milestonePayment = attendee.Milestone_Payment_gne__c == null ? false : Boolean.valueOf(attendee.Milestone_Payment_gne__c);

            exceptionRequested = String.valueOf(attendee.Exception_requested_at_gne__c);
            exceptionActivated = String.valueOf(attendee.Exception_accepted_at_gne__c);

            if (attendee.Account_gne__r != null) {
                tier = attendee.Account_gne__r.Tier_Level_gne__c;
                stakeholder = attendee.Account_gne__r.HCP_Stakeholder_Type_gne__c;
                accountType = attendee.Account_gne__r.Account_Type_gne__c;
                type = attendee.Account_gne__r.IsPersonAccount ? 'HCP' : 'HCO';
            } else {
                tier = account.Tier_Level_gne__c;
                stakeholder = account.HCP_Stakeholder_Type_gne__c;
                accountType = account.Account_Type_gne__c;
                type = account.IsPersonAccount ? 'HCP' : 'HCO';
            }
            exceptionComment = attendee.Exception_comment_gne__c;
        }

        public AttendeeWrapper(EMS_Roche_Attendee_gne__c attendee, User user) {
            recordId = attendee.Id;
            attendeeName = user.Name;
            attendeeId = attendee.User_gne__c;
            type = 'Employee';
            territoryId = attendee.Territory_Id_gne__c;
            role = null;
            status = null;
            contract = null;
            amount = null;
            isEmployee = true;
            milestonePayment = false;
        }

        public AttendeeWrapper(EMS_Attendee_gne__c attendee, EMS_International_Speaker_gne__c ihcp) {
            recordId = attendee.Id;
            attendeeName = ihcp.Name;
            attendeeId = attendee.EMS_International_Speaker_gne__c;
            type = 'iHCP';
            territoryId = null;
            role = attendee.Role_gne__c;
            status = attendee.Status_gne__c;
            contract = attendee.Contract_gne__c;
            amount = attendee.Total_Honoraria_gne__c;
            isEmployee = false;
            milestonePayment = attendee.Milestone_Payment_gne__c;

            exceptionRequested = String.valueOf(attendee.Exception_requested_at_gne__c);
            exceptionActivated = String.valueOf(attendee.Exception_accepted_at_gne__c);

            if (attendee.Account_gne__r != null) {
                tier = attendee.Account_gne__r.Tier_Level_gne__c;
                stakeholder = attendee.Account_gne__r.HCP_Stakeholder_Type_gne__c;
                accountType = attendee.Account_gne__r.Account_Type_gne__c;
            } else {
                tier = '';
                stakeholder = '';
                accountType = '';
            }
            exceptionComment = attendee.Exception_comment_gne__c;
        }

        public AttendeeWrapper(Id recordId, String attendeeName, Id attendeeId, String type, Id territoryId, String role, String status, String contract, Decimal amount) {
            this.recordId = recordId;
            this.attendeeName = attendeeName;
            this.attendeeId = attendeeId;
            this.type = type;
            this.territoryId = territoryId;
            this.role = role;
            this.status = status;
            this.contract = contract;
            this.amount = amount;
            this.milestonePayment = false;
        }
    }

    public class RocheAttendeeWrapper {
        String Id { get; private set; }
        String userId { get; private set; }
        List<EMS_Util.EMS_Territory> userTerritories { get; private set; }
        EMS_Roche_Attendee_gne__c record { get; private set; }

        public RocheAttendeeWrapper(EMS_Roche_Attendee_gne__c record, String userId) {
            this.record = record;
            this.Id = record.Id;
            this.userId = userId;
            userTerritories = new List<EMS_Util.EMS_Territory>();
        }

        public void addTerritories(List<EMS_Util.EMS_Territory> ts) {
            userTerritories.addAll(ts);
        }
    }
}