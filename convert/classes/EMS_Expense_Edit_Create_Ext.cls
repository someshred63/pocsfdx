public with sharing class EMS_Expense_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create {

    public EMS_Expense_Edit_Create_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Expense_Layout');
    }

    protected override void initController(ApexPages.StandardController controller) {
        if (controller.getRecord().Id == null) {
            EMS_Expense_gne__c newExpense = new EMS_Expense_gne__c();
            String preSetRecordTypeId = ApexPages.currentPage().getParameters().get('preSetRecordType');
            String eventId = ApexPages.currentPage().getParameters().get('objectId');

            if (preSetRecordTypeId != null) {
                newExpense.RecordTypeId = (Id) preSetRecordTypeId;
            }

            if (eventId != null) {
                newExpense.EMS_Event_gne__c = (Id) eventId;
            }

            myObject = newExpense;
        }
        super.initController(controller);
    }
}