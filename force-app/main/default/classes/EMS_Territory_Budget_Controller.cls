public with sharing class EMS_Territory_Budget_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        //Schema.DescribeSObjectResult describeResult = Time_Off_Territory_gne__c.SObjectType.getDescribe();
        //PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        PageReference newBT = Page.EMS_Budget_Territory_Edit_Create_Layout;
        newBT.getParameters().put('retURL', '/apex/EMS_Territory_Budget');
        return newBT;
    }

    public EMS_Territory_Budget_Controller() {
        super('EMS_Budget_Territory_gne__c');
        thisController = this;
    }
}