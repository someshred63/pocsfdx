public without sharing class EMS_Event_Email_Notifications {

    private static final Set<String> approvedStatuses = new Set<String>{
            'Approved',
            'Med Ops Approved',
            'Committee Approved',
            'MAC Committee Approved',
            'Manager Approved',
            'Director / Manager Approved',
            'Signed Agreement Received',
            'Payment Request Initiated'
    };
    private static final EMS_Email_Boxes__c bpsMailbox = EMS_Email_Boxes__c.getValues('BPS');
    private static Map<String, EMS_Event_Configuration_gne__c> eventConfigurations = EMS_Util.getEventConfigurations();

    public static void onAfterUpdate(List<EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        Map<Id, EMS_Event__c> triggerOldMap = new Map<Id, EMS_Event__c>(triggerOld);
		notifyBPSMembers(triggerOldMap, triggerNew);
        notifyRequestorOwnerOnEventClosureCancel(triggerOldMap, triggerNew);
        notifyOwnerOnAgendaChange(triggerOldMap, triggerNew);
        notifyOwnerRequestorOnBudgetNotReached(triggerOldMap, triggerNew);
        EMS_Email.send();
    }

    private static EMS_Event_Configuration_gne__c getConfig(EMS_Event__c event) {
        String key = (event.Event_Type_gne__c + event.Event_Sub_Type_gne__c);
        return eventConfigurations.get(key);
    }

    private static void notifyBPSMembers(Map<Id, EMS_Event__c> triggerOldMap, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event :triggerNew) {
            Boolean allowUploadContracts = (getConfig(event) != null && getConfig(event).AARC_Uploads_Contract_gne__c != null) ? getConfig(event).AARC_Uploads_Contract_gne__c : false;
            if (event.Overall_Status_gne__c != 'Draft' && allowUploadContracts) {
                Boolean startTimeChanged = (triggerOldMap.get(event.Id).Start_Date_gne__c == null && event.Start_Date_gne__c != null)
                        || (triggerOldMap.get(event.Id).Start_Date_gne__c != event.Start_Date_gne__c);
                Boolean endTimeChanged = (triggerOldMap.get(event.Id).End_Date_gne__c == null && event.End_Date_gne__c != null)
                        || (triggerOldMap.get(event.Id).End_Date_gne__c != event.End_Date_gne__c);
                Boolean overallStatusChanged = (event.Overall_Status_gne__c != triggerOldMap.get(event.Id).Overall_Status_gne__c);
                Boolean isBudgetApproved = (event.Overall_Status_gne__c == 'Budget Approved');
                Boolean isPendingApproval = (event.Status_gne__c == 'Pending Approval');
                Boolean isAdmin = (EMS_Util.getUserRole() == 'Admin');

                if ((startTimeChanged || endTimeChanged) && !(isPendingApproval && isAdmin)) {
                    EMS_Email.prepareSingleEmail('EMS_BPS_Date_Change_Notification', event.Id, new List<String>{
                            bpsMailbox.Main_Address__c
                    });
                }
                if (overallStatusChanged && isBudgetApproved) {
                    EMS_Email.prepareSingleEmail('EMS_AARC_Notification', event.Id, new List<String>{
                            bpsMailbox.Main_Address__c
                    });
                }
            }
        }
    }

    private static void notifyRequestorOwnerOnEventClosureCancel(Map<Id, EMS_Event__c> triggerOldMap, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event :triggerNew) {
            if (EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id)) {
                continue;
            }

            String tName = null;
            Boolean isClosedNow = (triggerOldMap.get(event.Id).Status_gne__c != 'Closed' && event.Status_gne__c == 'Closed');
            Boolean isCancelledNow = (triggerOldMap.get(event.Id).Status_gne__c != 'Cancelled' && event.Status_gne__c == 'Cancelled');
            if (isClosedNow) {
                tName = 'EMS_Closed_Event_Notification';
            }
            if (isCancelledNow) {
                tName = 'EMS_Cancelled_Event_Notification';
            }
            if (tName == null) {
                continue;
            }

            EMS_Email.prepareSingleEmail(tName, event.Id, event.Event_Requestor_gne__c);
            EMS_Email.prepareSingleEmail(tName, event.Id, event.Event_Owner_gne__c);
        }
    }

    private static void notifyOwnerOnAgendaChange(Map<Id, EMS_Event__c> triggerOldMap, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event :triggerNew) {
            if (EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id)) {
                continue;
            }
            Boolean hasNewAgenda = (triggerOldMap.get(event.Id).Agenda_Comments_gne__c != null && event.Agenda_Comments_gne__c != triggerOldMap.get(event.Id).Agenda_Comments_gne__c);
            if (hasNewAgenda && approvedStatuses.contains(event.Status_gne__c)) {
                EMS_Email.prepareSingleEmail('EMS_Event_Agenda_Objectives_Changed', event.Id, event.Event_Requestor_gne__c);
                EMS_Email.prepareSingleEmail('EMS_Event_Agenda_Objectives_Changed', event.Id, event.Event_Owner_gne__c);
            }
        }
    }

    private static void notifyOwnerRequestorOnBudgetNotReached(Map<Id, EMS_Event__c> triggerOldMap, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event :triggerNew) {
            if (EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id)) {
                continue;
            }
            Boolean isBudgetApprovalFine = (triggerOldMap.get(event.Id).Budget_Approval_Failed_gne__c == false && event.Budget_Approval_Failed_gne__c == true);
            if (isBudgetApprovalFine) {
                EMS_Email.prepareSingleEmail('EMS_Budget_Not_Reached_Notification', event.Id, event.Event_Requestor_gne__c);
                EMS_Email.prepareSingleEmail('EMS_Budget_Not_Reached_Notification', event.Id, event.Event_Owner_gne__c);
            }
        }
    }
}