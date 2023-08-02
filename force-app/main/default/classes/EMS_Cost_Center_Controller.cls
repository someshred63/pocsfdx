public with sharing class EMS_Cost_Center_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public EMS_Cost_Center_Controller() {
        super('EMS_Cost_Center_gne__c');
        thisController = this;
    }

    public PageReference newClick() {
        PageReference newBP = Page.EMS_Cost_Center_Edit_Create_Layout;
        newBP.getParameters().put('retURL', '/apex/EMS_Cost_Center');
        return newBP;
    }
}