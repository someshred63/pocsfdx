public with sharing class EMS_Budget_Allocation_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {
    public EMS_Budget_Allocation_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Budget_Allocation_Layout');
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (controller.getRecord().Id == null) {
            EMS_Budget_Allocation_gne__c newAllocation = new EMS_Budget_Allocation_gne__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');
            String eventId = ApexPages.currentPage().getParameters().get('objectId');

            if (preSetRecordTypeId != null) {
                newAllocation.RecordTypeId = (Id) preSetRecordTypeId;
            }

            if (eventId != null) {
                newAllocation.EMS_Event_gne__c = (Id) eventId;
            }

            myObject = newAllocation;
        }
        super.initController(controller);
    }

    public override PageReference save() {
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        return super.save();
    }
}