public with sharing class EMS_Roche_Attendee_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {
    public EMS_Roche_Attendee_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Roche_Attendee_Layout');
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (controller.getRecord().Id == null) {
            EMS_Roche_Attendee_gne__c newAttendee = new EMS_Roche_Attendee_gne__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');
            String eventId = ApexPages.currentPage().getParameters().get('objectId');

            if (preSetRecordTypeId != null) {
                newAttendee.RecordTypeId = (Id) preSetRecordTypeId;
            }

            if (eventId != null) {
                newAttendee.EMS_Event_gne__c = (Id) eventId;
            }

            myObject = newAttendee;
        }
        super.initController(controller);
    }
}