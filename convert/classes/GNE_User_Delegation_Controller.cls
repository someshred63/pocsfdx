public with sharing class GNE_User_Delegation_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public PageReference newClick() {
        PageReference newRB = Page.GNE_User_Delegation_Edit_Create_Layout;
        newRB.getParameters().put('retURL', '/apex/GNE_User_Delegation');
        return newRB;
    }

    public GNE_User_Delegation_Controller() {
        super('GNE_User_Delegation__c');
        thisController = this;
    }
}