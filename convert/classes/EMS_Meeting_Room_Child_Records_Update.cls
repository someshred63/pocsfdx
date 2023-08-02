public without sharing class EMS_Meeting_Room_Child_Records_Update {

    public static void onAfterUpdate(Map<Id, EMS_Meeting_Room_gne__c> triggerOld, Map<Id, EMS_Meeting_Room_gne__c> triggerNew) {
        sendEventForReapprovalOnMeetingRoomSectionChange(triggerOld, triggerNew);
    }

    public static void onAfterInsert(Map<Id, EMS_Meeting_Room_gne__c> triggerNew) {

    }

    // Action methods
    private static void sendEventForReapprovalOnMeetingRoomSectionChange(Map<Id, EMS_Meeting_Room_gne__c> triggerOld, Map<Id, EMS_Meeting_Room_gne__c> triggerNew) {
        Map <String, Schema.SObjectField> objectFieldsMap = Schema.getGlobalDescribe().get('EMS_Meeting_Room_gne__c').getDescribe().fields.getMap();
        Set<Id> meetingRequestIdsOfChangedMRoom = new Set<Id>();
        Set<Id> emsEventIdsOfChangedMRooms = new Set<Id>();
        Set<String> fieldsToCheck = new Set<String>{
                'Number_of_Persons_gne__c', 'Any_Special_Requirements_gne__c', 'Break_Out_Room_gne__c',
                'Date_gne__c', 'Main_Plenary_gne__c', 'Room_Layout_gne__c', 'Time_gne__c'
        };

        for (EMS_Meeting_Room_gne__c mr : triggerNew.values()) {
            Boolean wasChanged = false;
            for (String fieldname : fieldsToCheck) {
                if (triggerOld.get(mr.Id).get(objectFieldsMap.get(fieldname)) != (triggerNew.get(mr.Id).get(objectFieldsMap.get(fieldname)))) {
                    wasChanged = true;
                }
            }
            if (wasChanged == true) {
                meetingRequestIdsOfChangedMRoom.add(mr.EMS_Meeting_Request_gne__c);
            }

        }
        List<EMS_Meeting_Request_gne__c> meetingRequestsForChangedMRooms = [SELECT EMS_Event_gne__c FROM EMS_Meeting_Request_gne__c WHERE Id IN :meetingRequestIdsOfChangedMRoom];
        for (EMS_Meeting_Request_gne__c mr : meetingRequestsForChangedMRooms) {
            emsEventIdsOfChangedMRooms.add(mr.EMS_Event_gne__c);
        }

        String cancellApprovalComment = 'Approval process cancelled due to Meeting Request form modification.';
        String submitApprovalComment = 'Re-approval required due to changes in Meeting Request form.';
        EMS_Util.restartEventApprovalProcess(emsEventIdsOfChangedMRooms, cancellApprovalComment, submitApprovalComment);

    }
}