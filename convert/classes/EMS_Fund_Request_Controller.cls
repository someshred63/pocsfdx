public with sharing class EMS_Fund_Request_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        //Schema.DescribeSObjectResult describeResult = Time_Off_Territory_gne__c.SObjectType.getDescribe();
        //PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        PageReference newFR = Page.EMS_Fund_Request_Edit_Create_Layout;
        newFR.getParameters().put('retURL', '/apex/EMS_Fund_Request');
        return newFR;
    }

    public EMS_Fund_Request_Controller() {
        super('EMS_Fund_Request_gne__c');
        thisController = this;
    }
}