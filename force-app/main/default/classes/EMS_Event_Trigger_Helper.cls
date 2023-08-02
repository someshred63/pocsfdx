public without sharing class EMS_Event_Trigger_Helper {

    public static boolean skipTriggerValidationRules = false;
    public static boolean skipTrigger = false;
    public static boolean typeHasChanged = false; // this variable is being set in event/page.js "quickUpdate" method.
    private static Set<Id> alreadyProcessedSet = new Set<Id>();
    private static Set<Id> alreadySubmittedSet = new Set<Id>();
    private static Map<String, Set<String>> possibleBudgetAllocations;
    private static Map<Id, List<EMS_Attendee_gne__c>> attendeesForEvent;
    private static Map<Id, List<EMS_Roche_Attendee_gne__c>> rocheAttendeesForEvent;
    private static Map<String, Integer> productBudgetCount;
    private static Map<String, Integer> regionBudgetCount;
    private static Map<String, Integer> territoryBudgetCount;
    private static Map<String, Id> emailTemplatesMap;
    private static Map<String, EMS_Event_Configuration_gne__c> eventConfigurations;
    private static Map<String, String> budgetOwnerToCostCenterType;
    private static Map<Id, GNE_User_Delegation__c> userDelegations;
    private static Map<Id, List<EMS_Budget_Allocation_gne__c>> budgetAllocations;

    public static boolean isAlreadyProcessed(Id eventId) {
        return alreadyProcessedSet.contains(eventId);
    }

    public static void addToProcessed(Id eventId) {
        alreadyProcessedSet.add(eventId);
    }

    public static void addToProcessed(List<EMS_Event__c> events) {
        for (EMS_Event__c event : events) {
            alreadyProcessedSet.add(event.Id);
        }
    }

    public static void clearProcessedSet() {
        alreadyProcessedSet.clear();
    }

    public static boolean isAlreadySubmitted(Id eventId) {
        return alreadySubmittedSet.contains(eventId);
    }

    public static void addToSubmitted(Id eventId) {
        alreadySubmittedSet.add(eventId);
    }

    public static void resetToNullAttendeesForEvent() {
        attendeesForEvent = null;
    }

    public static Map<String, Set<String>> getPossibleBudgetAllocations() {
        if (possibleBudgetAllocations == null) {
            possibleBudgetAllocations = new Map<String, Set<String>>();
            for (EMS_Possible_Budget_Allocation_gne__c budgetAllocation : [SELECT Budget_Type_gne__r.Name, EMS_Event_Configuration_gne__r.Event_Type_gne__c, EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c FROM EMS_Possible_Budget_Allocation_gne__c]) {
                if (possibleBudgetAllocations.get(budgetAllocation.EMS_Event_Configuration_gne__r.Event_Type_gne__c + budgetAllocation.EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c) == null) {
                    possibleBudgetAllocations.put(budgetAllocation.EMS_Event_Configuration_gne__r.Event_Type_gne__c + budgetAllocation.EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c, new Set<String>());
                }
                possibleBudgetAllocations.get(budgetAllocation.EMS_Event_Configuration_gne__r.Event_Type_gne__c + budgetAllocation.EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c).add(budgetAllocation.Budget_Type_gne__r.Name);
            }
        }

        return possibleBudgetAllocations;
    }

    public static void clearAttendeeForEvents() {
        attendeesForEvent = null;
    }

    public static Map<Id, List<EMS_Attendee_gne__c>> getAttendeeForEvents(Set<Id> events) {
        if (attendeesForEvent == null) {
            attendeesForEvent = new Map<Id, List<EMS_Attendee_gne__c>>();

            for (EMS_Attendee_gne__c att : [SELECT Id, EMS_Event_gne__c FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :events]) {
                if (!attendeesForEvent.containsKey(att.EMS_Event_gne__c)) {
                    attendeesForEvent.put(att.EMS_Event_gne__c, new List<EMS_Attendee_gne__c>());
                }
                attendeesForEvent.get(att.EMS_Event_gne__c).add(att);
            }
        }

        return attendeesForEvent;
    }

    public static Map<Id, List<EMS_Roche_Attendee_gne__c>> getRocheAttendeeForEvents(Set<Id> events) {
        if (rocheAttendeesForEvent == null) {
            rocheAttendeesForEvent = new Map<Id, List<EMS_Roche_Attendee_gne__c>>();
            for (EMS_Roche_Attendee_gne__c att : [SELECT Id, EMS_Event_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :events]) {
                if (!rocheAttendeesForEvent.containsKey(att.EMS_Event_gne__c)) {
                    rocheAttendeesForEvent.put(att.EMS_Event_gne__c, new List<EMS_Roche_Attendee_gne__c>());
                }
                rocheAttendeesForEvent.get(att.EMS_Event_gne__c).add(att);
            }
        }

        return rocheAttendeesForEvent;
    }

    public static Map<Id, List<EMS_Attachment_gne__c>> getAttachmentsForEvents(Set<Id> events) {
        Map<Id, List<EMS_Attachment_gne__c>> attachmentsForEvent = new Map<Id, List<EMS_Attachment_gne__c>>();

        for (EMS_Attachment_gne__c att : [SELECT Id, Type_gne__c, EMS_Event_gne__c FROM EMS_Attachment_gne__c WHERE EMS_Event_gne__c IN :events]) {
            if (!attachmentsForEvent.containsKey(att.EMS_Event_gne__c)) {
                attachmentsForEvent.put(att.EMS_Event_gne__c, new List<EMS_Attachment_gne__c>());
            }
            attachmentsForEvent.get(att.EMS_Event_gne__c).add(att);
        }
        return attachmentsForEvent;
    }

    public static List<EMS_Event__c> getExpensesForEvent(Set<Id> eventIds) {
        List<EMS_Event__c> lst = new List<EMS_Event__c>([SELECT id, (SELECT id FROM EMS_Expenses__r where isDeleted = false) FROM EMS_Event__c WHERE id IN:eventIds]);
        return lst;
    }

    public static Map<String, Integer> getProductBudgetCount() {
        if (productBudgetCount == null) {
            productBudgetCount = new Map<String, Integer>();
            for (EMS_Budget_Product_gne__c productBudget : [SELECT Assigned_to_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Product_gne__c WHERE Status_gne__c = 'Active']) {
                if (productBudgetCount.get(productBudget.Assigned_to_gne__c + productBudget.Cost_Center_Type_gne__c) == null) {
                    productBudgetCount.put(productBudget.Assigned_to_gne__c + productBudget.Cost_Center_Type_gne__c, 0);
                }
                Integer currentCount = productBudgetCount.get(productBudget.Assigned_to_gne__c + productBudget.Cost_Center_Type_gne__c);
                productBudgetCount.put(productBudget.Assigned_to_gne__c + productBudget.Cost_Center_Type_gne__c, ++currentCount);
            }
        }

        return productBudgetCount;
    }

    public static Map<String, Integer> getRegionBudgetCount() {

        if (regionBudgetCount == null) {
            regionBudgetCount = new Map<String, Integer>();
            for (EMS_Budget_Region_gne__c regionBudget : [SELECT Assigned_to_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Region_gne__c WHERE Status_gne__c = 'Active']) {
                if (regionBudgetCount.get(regionBudget.Assigned_to_gne__c + regionBudget.Cost_Center_Type_gne__c) == null) {
                    regionBudgetCount.put(regionBudget.Assigned_to_gne__c + regionBudget.Cost_Center_Type_gne__c, 0);
                }
                Integer currentCount = regionBudgetCount.get(regionBudget.Assigned_to_gne__c + regionBudget.Cost_Center_Type_gne__c);
                regionBudgetCount.put(regionBudget.Assigned_to_gne__c + regionBudget.Cost_Center_Type_gne__c, ++currentCount);
            }
        }

        return regionBudgetCount;
    }

    public static Map<String, Integer> getTerritoryBudgetCount() {
        if (territoryBudgetCount == null) {
            territoryBudgetCount = new Map<String, Integer>();
            for (EMS_Budget_Territory_gne__c territoryBudget : [SELECT Assigned_to_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Territory_gne__c WHERE Status_gne__c = 'Active']) {
                if (territoryBudgetCount.get(territoryBudget.Assigned_to_gne__c + territoryBudget.Cost_Center_Type_gne__c) == null) {
                    territoryBudgetCount.put(territoryBudget.Assigned_to_gne__c + territoryBudget.Cost_Center_Type_gne__c, 0);
                }
                Integer currentCount = territoryBudgetCount.get(territoryBudget.Assigned_to_gne__c + territoryBudget.Cost_Center_Type_gne__c);
                territoryBudgetCount.put(territoryBudget.Assigned_to_gne__c + territoryBudget.Cost_Center_Type_gne__c, ++currentCount);
            }
        }
        return territoryBudgetCount;
    }

    public static Map<String, EMS_Event_Configuration_gne__c> getEventConfigurations() {
        if (eventConfigurations == null) {
            eventConfigurations = new Map<String, EMS_Event_Configuration_gne__c>();
            for (EMS_Event_Configuration_gne__c eventConfiguration : [SELECT Event_Type_gne__c, Event_Sub_Type_gne__c, Budget_Approved_Label_gne__c FROM EMS_Event_Configuration_gne__c]) {
                eventConfigurations.put(eventConfiguration.Event_Type_gne__c + eventConfiguration.Event_Sub_Type_gne__c, eventConfiguration);
            }
        }

        return eventConfigurations;
    }

    public static Map<String, String> getCostCenterTypes() {
        if (budgetOwnerToCostCenterType == null) {
            budgetOwnerToCostCenterType = new Map<String, String>();
            for (EMS_Budget_Product_gne__c productBudget : [SELECT Assigned_to_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Product_gne__c WHERE Year_gne__c = :String.valueOf(Date.today().year())]) {
                budgetOwnerToCostCenterType.put(productBudget.Assigned_to_gne__c, productBudget.Cost_Center_Type_gne__c);
            }

            for (EMS_Budget_Region_gne__c regionBudget : [SELECT Assigned_to_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Region_gne__c WHERE Year_gne__c = :String.valueOf(Date.today().year())]) {
                budgetOwnerToCostCenterType.put(regionBudget.Assigned_to_gne__c, regionBudget.Cost_Center_Type_gne__c);
            }

            for (EMS_Budget_Territory_gne__c territoryBudget : [SELECT Assigned_to_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Territory_gne__c WHERE Year_gne__c = :String.valueOf(Date.today().year())]) {
                budgetOwnerToCostCenterType.put(territoryBudget.Assigned_to_gne__c, territoryBudget.Cost_Center_Type_gne__c);
            }
        }

        return budgetOwnerToCostCenterType;
    }

    public static Map<Id, GNE_User_Delegation__c> getUserDelegations(List<EMS_Event__c> triggerNew) {
        if (userDelegations == null) {
            userDelegations = new Map<Id, GNE_User_Delegation__c>();
            Id emsUserDelegationRT = Schema.SObjectType.GNE_User_Delegation__c.RecordTypeInfosByName.get('EMS').RecordTypeId;
            Set<Id> availableUsers = new Set<Id>();

            for (EMS_Event__c event : triggerNew) {
                if (event.Event_Owner_gne__c != null) {
                    availableUsers.add(event.Event_Owner_gne__c);
                }
            }

            for (GNE_User_Delegation__c ud : [SELECT Delegated_User__c, Username__c, OwnerId FROM GNE_User_Delegation__c WHERE Is_Delegation_Active__c = 'Yes' AND RecordTypeId = :emsUserDelegationRT AND Username__c IN :availableUsers]) {
                userDelegations.put(ud.Username__c, ud);
            }
        }

        return userDelegations;
    }

    public static void sendStatusesToFRT(Map<Id, EMS_Event__c> emsEventsByIds, List<EMS_Event__c> emsEvents) {
        for(EMS_Event__c event : emsEvents) {
            EMS_Event__c oldEvent = emsEventsByIds.get(event.Id);

            if(event.Status_gne__c != oldEvent.Status_gne__c && EMS_FRT_Webservice.allowedStatuses.contains(event.Status_gne__c)) {
                EMS_FRT_Webservice.sendEventStatusFuture(event.Id);
            }
        }
    }
}