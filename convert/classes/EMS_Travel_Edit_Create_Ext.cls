public without sharing class EMS_Travel_Edit_Create_Ext extends EMS_Dynamic_VF_Edit_Create {

    public EMS_Travel_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Travel_Layout');
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (controller.getRecord().Id == null) {
            EMS_Travel_gne__c newTravel = new EMS_Travel_gne__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');
            String eventId = ApexPages.currentPage().getParameters().get('objectId');

            if (preSetRecordTypeId != null) {
                newTravel.RecordTypeId = (Id) preSetRecordTypeId;
            }

            if (eventId != null) {
                newTravel.EMS_Event_gne__c = (Id) eventId;
            }

            myObject = newTravel;
        }
        super.initController(controller);
    }
}