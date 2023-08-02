public with sharing class EMS_Access {

    private static final Set<String> allowedStatusesForAARC = new Set<String>{
            'Med Ops Rejected',
            'Rejected',
            'Unplanned',
            'Signed Agreement Received',
            'Med Ops Approved',
            'Payment Request Initiated',
            'Awaiting Signature from HCP',
            'Budget Approved'
    };

    private static Boolean isAARCUserCanEdit(EMS_Event__c event) {
        Boolean isAARCAllowedStatus = false;
        try {
            isAARCAllowedStatus = (allowedStatusesForAARC.contains(event.Status_gne__c) || allowedStatusesForAARC.contains(event.Overall_Status_gne__c));
        } catch (Exception ex) {
            // Field is not in SOQL query
        }
        return isAARCAllowedStatus;
    }

    public static Boolean isBudgetAllocationDelegeatedUser(List<EMS_Budget_Allocation_gne__c> budgets) {
        Boolean isDelegatedUser = false;
        try {
            for (EMS_Budget_Allocation_gne__c budget : budgets) {
                if ((budget.Budget_Owner_gne__c == budget.Approver_gne__c && UserInfo.getUserId() == budget.Approver_gne__c) || (UserInfo.getUserId() == budget.Budget_Owner_gne__c)) {
                    isDelegatedUser = true;
                    break;
                }
            }
        } catch (Exception ex) {
            // Field is not in SOQL query
        }
        return isDelegatedUser;
    }

    public static Boolean isReadOnlyUser() {
        return EMS_Util.getUserRole() == 'ReadOnly' && EMS_Util.getHasReadOnlyPermSet();
    }

    public static Boolean isAPUser() {
        return EMS_Util.getUserRole() == 'AP';
    }

    public static Boolean isMedOpsUser() {
        return EMS_Util.getUserRole() == 'MedOps';
    }

    public static Boolean isFCUser() {
        return EMS_Util.getUserRole() == 'FC';
    }

    public static Boolean isMPUser() {
        return EMS_Util.getUserRole() == 'MP';
    }

    public static Boolean isAdmin() {
        return EMS_Util.getUserRole() == 'Admin';
    }

    public static Boolean isBPS() {
        return EMS_Util.getUserRole() == 'AARC';
    }

    public static Boolean isRep() {
        return EMS_Util.getUserRole() == 'Rep';
    }

    public static Boolean isPM() {
        return EMS_Util.getUserRole() == 'PM';
    }

    public static Boolean canActivateAttendeeException() {
        return EMS_Access.isAdmin() || EMS_Access.isMedOpsUser();
    }

    public static Boolean canUnlockException() {
        return EMS_Access.isAdmin() || !EMS_Access.isMedOpsUser();
    }

    public static Boolean canUpdateFMV(EMS_Event__c event) {
        Boolean isBPSEditable = isBPS() && !isClosedCancelledEvent(event);
        Boolean isUnlocked = !isLockedEvent(event) && !isClosedCancelledEvent(event);
        return EMS_Util.isAdmin() || isBPSEditable || isUnlocked;
    }

    private static Boolean isClosedCancelledEvent(EMS_Event__c event) {
        return EMS_Util.isClosedCancelledEvent(event);
    }

    private static Boolean isLockedEvent(EMS_Event__c event) {
        return EMS_Util.isEventLockedByRecordType(event);
    }

    private static Boolean isRecordEditable(SObject record) {
        return EMS_Util.isRecordEditable(record.Id);
    }

    private static Boolean hasEventAttendeeShare(EMS_Event__c event) {
        return EMS_Util.isEventAttendee(event.Id);
    }

    private static Boolean isEventOwner(EMS_Event__c event) {
        return event.Event_Owner_gne__c == UserInfo.getUserId();
    }

    private static Boolean isEventRequestor(EMS_Event__c event) {
        return event.Event_Requestor_gne__c == UserInfo.getUserId();
    }

    private static Boolean isEventOwnerRequestor(EMS_Event__c event) {
        return EMS_Util.isEventOwnerRequestor(event);
    }

    private static Boolean isConsultinMeetingEvent(EMS_Event__c event) {
        return event.Event_Type_gne__c == 'Consulting Meetings' || event.Event_Type_gne__c == 'Consultancy Meeting';
    }

    private static Boolean isGSDEvent(EMS_Event__c event) {
        return event.Is_GSD_Event_gne__c == true;
    }

    public static Boolean isEventEditable(EMS_Event__c event, List<EMS_Budget_Allocation_gne__c> budgets) {
        Boolean editable = false;
        if (EMS_Util.isAdmin()) {
            editable = true;
        } else if (EMS_Access.isBPS()) {
            editable = isAARCUserCanEdit(event);
        } else if (isReadOnlyUser() || isAPUser() || isClosedCancelledEvent(event) || isLockedEvent(event) || (isBudgetAllocationDelegeatedUser(budgets) && !isEventOwnerRequestor(event)) || isMedOpsUser()) {
            // Also check if current user is a Delegated User. 
            // The delegation process grants users Edit Access for budgets. 
            // It's done to avoid appearing UNKNOWN Exception (workflow email alert) during approval process
            editable = false;
        } else {
            editable = isRecordEditable(event);
        }
        return editable;
    }

    public static Boolean isLocationSectionEditable(EMS_Event__c event, List<EMS_Budget_Allocation_gne__c> budgets) {
        Boolean editable = isEventEditable(event, budgets);
        if (editable == false && isMPUser() && !isClosedCancelledEvent(event)) {
            editable = true;
        }
        return editable;
    }

    public static Boolean isAttachmentTravelSectionEditable(EMS_Event__c event, List<EMS_Budget_Allocation_gne__c> budgets) {
        Boolean editable = false;
        if (isReadOnlyUser() || (isBudgetAllocationDelegeatedUser(budgets) && !isEventOwnerRequestor(event)) || isAPUser() || isFCUser()) {
            editable = false;
        } else {
            editable = true;
        }
        return editable;
    }

    public static Boolean isEventProductEditable(EMS_Event__c event, List<EMS_Budget_Allocation_gne__c> budgets) {
        Boolean editable = false;
        if (EMS_Util.isAdmin()) {
            editable = true;
        } else if (isReadOnlyUser() || isClosedCancelledEvent(event) || isAPUser() || isMedOpsUser() || isFCUser() || (isBudgetAllocationDelegeatedUser(budgets) && !isEventOwnerRequestor(event))) {
            editable = false;
        } else {
            editable = isRecordEditable(event) || (isRecordEditable(event) && hasEventAttendeeShare(event));
        }
        return editable;
    }

    public static Boolean isEventPlanningSectionEditable(EMS_Event__c event) {
        Boolean editable = false;

        if (EMS_Util.isAdmin()) {
            editable = true;
        } else if (event.Overall_Status_gne__c == 'Draft' || event.Overall_Status_gne__c == 'Rejected') {
            editable = true;
        }

        return editable;
    }

    public static Boolean isWatcherEditable(EMS_Event__c event, List<EMS_Budget_Allocation_gne__c> budgets) {
        // the same access logic as for event products
        if (EMS_Util.isAdmin() && isClosedCancelledEvent(event)) {
            return false;
        } else {
            return isEventProductEditable(event, budgets);
        }
    }

    public static Boolean isSpeakerTourEditable(EMS_Event__c event) {
        // - can MEDOPS Edit Speaker Tour                                   ???
        // - is SpeakerTour seciton editable for CLOSED/CANCELLED events    ???
        Boolean editable = false;
        if (EMS_Util.isAdmin()) {
            editable = true;
        } else if (isReadOnlyUser() || isAPUser() || isFCUser()) {
            editable = false;
        } else {
            editable = isRecordEditable(event);
        }
        return editable;
    }

    public static Boolean isMeetingRequestEditable(EMS_Event__c event) {
        Boolean editable = false;
        if (EMS_Util.isAdmin() || isMPUser() || isEventRequestor(event)) {
            editable = true;
        }
        return editable;
    }

    public static Boolean isInvestmentEditable(EMS_Event__c event) {
        Boolean editable = false;
        if (EMS_Util.isAdmin()) {
            editable = true;
        } else if (isReadOnlyUser() || isLockedEvent(event)) {
            editable = false;
        } else {
            editable = isRecordEditable(event) && (isEventRequestor(event) || isEventOwner(event));
        }
        return editable;
    }

    public static Boolean isRocheDocumentationEditable(EMS_Event__c event) {
        Boolean editable = false;
        if (EMS_Util.isAdmin()) {
            editable = true;
        } else if (isLockedEvent(event)) {
            editable = false;
        } else if (isEventRequestor(event)) {
            editable = true;
        } else if (isEventOwner(event)) {
            try {
                Set<String> allowedStatusesForConsultingEvents = new Set<String>{
                        'Unplanned', 'Planned', 'Med Ops Rejected'
                };
                if (isConsultinMeetingEvent(event) && allowedStatusesForConsultingEvents.contains(event.Status_gne__c)) {
                    editable = true;
                }

                Set<String> allowedStatusesForGSDEvents = new Set<String>{
                        'Planned', 'Med Ops Rejected'
                };
                Boolean isGrandGSDEvent = event.Event_Type_gne__c.contains('Grant') && isGSDEvent(event);
                Boolean hasCorporationCostCenter = event.Cost_Center_Type_gne__c.contains('Corp');
                if (isGrandGSDEvent && allowedStatusesForGSDEvents.contains(event.Status_gne__c) && hasCorporationCostCenter) {
                    editable = true;
                }
            } catch (Exception ex) {
                // Field is not in SOQL query
            }
        }
        return editable;
    }
}