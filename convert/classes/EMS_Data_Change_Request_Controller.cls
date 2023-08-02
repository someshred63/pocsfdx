public with sharing class EMS_Data_Change_Request_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        PageReference newBP = Page.EMS_Data_Change_Request_Edit_Create_Layo;
        newBP.getParameters().put('retURL', '/apex/EMS_Data_Change_Request');
        return newBP;
    }

    public EMS_Data_Change_Request_Controller() {
        super('EMS_Data_Change_Request_gne__c');
        thisController = this;
    }
}