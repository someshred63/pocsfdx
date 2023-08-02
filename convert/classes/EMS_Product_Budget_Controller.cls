public with sharing class EMS_Product_Budget_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        //PageReference newToT = new PageReference('/' + describeResult.getKeyPrefix() + '/e');
        PageReference newBP = Page.EMS_Budget_Product_Edit_Create_Layout;
        newBP.getParameters().put('retURL', '/apex/EMS_Product_Budget');
        return newBP;
    }

    public EMS_Product_Budget_Controller() {
        super('EMS_Budget_Product_gne__c');
        thisController = this;
    }
}