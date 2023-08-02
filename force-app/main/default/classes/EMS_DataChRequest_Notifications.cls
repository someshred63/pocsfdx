public without sharing class EMS_DataChRequest_Notifications {
    private static final EMS_Email_Boxes__c bpsMailbox = EMS_Email_Boxes__c.getValues('BPS');
    private static Map<Id, User> bpsUsers = new Map<Id, User>();

    public static void onAfterInsertUpdate(Map<Id, EMS_Data_Change_Request_gne__c> triggerOld, List<EMS_Data_Change_Request_gne__c> triggerNew) {
        fetchBpsEmails(triggerNew);
        notifyAdminsAboutNewDataChangeRequestSubmission(triggerOld, triggerNew);
        notidyUserWhenDCRisCompleted(triggerOld, triggerNew);

        EMS_Email.send();
    }

    private static void fetchBpsEmails(List<EMS_Data_Change_Request_gne__c> triggerNew) {
        Set<Id> userIds = new Set<Id>();
        for (EMS_Data_Change_Request_gne__c dcr : triggerNew) {
            if (String.isNotBlank(dcr.Assigned_BPS_gne__c)) {
                userIds.add(dcr.Assigned_BPS_gne__c);
            }
        }
        bpsUsers.putAll([SELECT Id, Email FROM User WHERE Id IN :userIds]);
    }

    private static void notidyUserWhenDCRisCompleted(Map<Id, EMS_Data_Change_Request_gne__c> triggerOld, List<EMS_Data_Change_Request_gne__c> triggerNew) {
        for (EMS_Data_Change_Request_gne__c dcr :triggerNew) {
            if (triggerOld != null && triggerOld.get(dcr.Id).Status_gne__c != 'Closed' && dcr.Status_gne__c == 'Closed') {
                EMS_Email.prepareSingleEmail('EMS_DCR_Closed_Notification', dcr.Id, dcr.CreatedById);
            }
        }
    }

    private static void notifyAdminsAboutNewDataChangeRequestSubmission(Map<Id, EMS_Data_Change_Request_gne__c> triggerOld, List<EMS_Data_Change_Request_gne__c> triggerNew) {
        Set<Id> admins = new Set<Id>();
        for (PermissionSetAssignment pAssignment : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'EMS_Canada_Admin']) {
            admins.add(pAssignment.AssigneeId);
        }

        for (EMS_Data_Change_Request_gne__c dcr :triggerNew) {
            Boolean isInserted = triggerOld == null || !triggerOld.containsKey(dcr.Id);
            Boolean isUpdated = triggerOld != null && triggerOld.containsKey(dcr.Id) && triggerOld.get(dcr.Id).Status_gne__c != 'Submitted';
            Boolean isSubmitted = dcr.Status_gne__c == 'Submitted' && (isInserted || isUpdated);

            if (!isSubmitted) {
                continue;
            }

            if(dcr.Assigned_BPS_gne__c != null) {
                EMS_Email.prepareSingleEmail('EMS_Data_Change_Request_Notification', dcr.Id, new List<String>{
                        bpsMailbox.Main_Address__c,
                        bpsUsers.get(dcr.Assigned_BPS_gne__c).Email
                });
            } else {
                for (Id adminID :admins) {
                    EMS_Email.prepareSingleEmail('EMS_Data_Change_Request_Notification', dcr.Id, adminID);
                }
            }
        }
    }
}