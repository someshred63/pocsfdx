public with sharing class EMS_Event_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        try {
            EMS_Event__c event = new EMS_Event__c(
                Status_gne__c = 'Unplanned',
                Country_gne__c = 'Canada',
                Event_Requestor_gne__c = UserInfo.getUserId()
            );

            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            insert event;

            PageReference creatingEventPage = Page.EMS_Event_Layout;
            creatingEventPage.getParameters().put('id', event.ID);  // Record ID
            creatingEventPage.getParameters().put('new', '1');      // Defines if it is a new record
            creatingEventPage.getParameters().put('retURL', '/apex/EMS_Event');
            return creatingEventPage;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }

    public EMS_Event_Controller() {
        super(EMS_Event__c.sObjectType.getDescribe().getName());
        if (ApexPages.currentPage().getParameters().containsKey('msg')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, ApexPages.currentPage().getParameters().get('msg')));
        }
        thisController = this;
    }

    public override String getCustomFilterExpression(List_View_Setup_Ext.ConditionItem cItem) {
        String returnString = '';
        if (cItem.operator == 'in') {
            returnString = cItem.field + ' IN ' + cItem.value;
            if (returnString.containsIgnoreCase(':UserInfo.getUserId()')) {
                returnString = returnString.replace(':UserInfo.getUserId()', '\'' + UserInfo.getUserId() + '\'');
            }
        }
        return returnString;
    }
}