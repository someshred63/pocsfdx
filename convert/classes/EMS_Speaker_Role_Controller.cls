public with sharing class EMS_Speaker_Role_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        //Schema.DescribeSObjectResult describeResult = Time_Off_Territory_gne__c.SObjectType.getDescribe();
        //PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        PageReference newSR = Page.EMS_Speaker_Role_Edit_Create_Layout;
        newSR.getParameters().put('retURL', '/apex/EMS_Speaker_Role');
        return newSR;
    }

    public EMS_Speaker_Role_Controller() {
        super('EMS_Speaker_Role_gne__c');
        thisController = this;
    }
}