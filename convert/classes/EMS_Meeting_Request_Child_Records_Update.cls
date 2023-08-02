public without sharing class EMS_Meeting_Request_Child_Records_Update {

    public static void onAfterUpdate(Map<Id, EMS_Meeting_Request_gne__c> triggerOld, Map<Id, EMS_Meeting_Request_gne__c> triggerNew) {
        sendEventForReapprovalOnMeetingRequestSectionChange(triggerOld, triggerNew);
    }

    public static void onAfterInsert(Map<Id, EMS_Meeting_Request_gne__c> triggerNew) {

    }

    // Action methods
    private static void sendEventForReapprovalOnMeetingRequestSectionChange(Map<Id, EMS_Meeting_Request_gne__c> triggerOld, Map<Id, EMS_Meeting_Request_gne__c> triggerNew) {
        Map <String, Schema.SObjectField> objectFieldsMap = Schema.getGlobalDescribe().get('EMS_Meeting_Request_gne__c').getDescribe().fields.getMap();
        Set<Id> eventIdsOfChanedRequest = new Set<Id>();
        Set<String> fieldsToCheck = new Set<String>{
                'Number_of_Attendees_gne__c', 'Number_of_Rooms__c', 'Additional_Comments_gne__c', 'Business_Unit_gne__c', 'Catering_Requirements_gne__c',
                'Hotel_1_City_gne__c', 'Hotel_2_City_gne__c', 'Hotel_3_City_gne__c', 'Dates_From_gne__c', 'Dates_To_gne__c', 'EMS_Event_gne__c', 'Flip_Charts_gne__c', 'Hotel_1_Name_gne__c',
                'Hotel_2_Name_gne__c', 'Hotel_3_Name_gne__c', 'Internet_Access_gne__c', 'LCD_Projector_gne__c', 'Meals_gne__c', 'Microphone_gne__c', 'Requestor_Name__c', 'Phone_Ext_gne__c',
                'Screen_gne__c', 'Separate_Room_Required_gne__c'
        };

        for (EMS_Meeting_Request_gne__c mr : triggerNew.values()) {
            Boolean wasChanged = false;
            for (String fieldname : fieldsToCheck) {
                if (triggerOld.get(mr.Id).get(objectFieldsMap.get(fieldname)) != (triggerNew.get(mr.Id).get(objectFieldsMap.get(fieldname)))) {
                    wasChanged = true;
                }
            }
            if (wasChanged == true) {
                eventIdsOfChanedRequest.add(mr.EMS_Event_gne__c);
            }

        }
        String cancellApprovalComment = 'Approval process cancelled due to Meeting Request form modification.';
        String submitApprovalComment = 'Re-approval required due to changes in Meeting Request form.';
        EMS_Util.restartEventApprovalProcess(eventIdsOfChanedRequest, cancellApprovalComment, submitApprovalComment);

    }

}