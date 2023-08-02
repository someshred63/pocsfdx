public with sharing class EMS_Region_Budget_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        //Schema.DescribeSObjectResult describeResult = Time_Off_Territory_gne__c.SObjectType.getDescribe();
        //PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        PageReference newRB = Page.EMS_Budget_Region_Edit_Create_Layout;
        newRB.getParameters().put('retURL', '/apex/EMS_Region_Budget');
        return newRB;
    }

    public EMS_Region_Budget_Controller() {
        super('EMS_Budget_Region_gne__c');
        thisController = this;
    }
}