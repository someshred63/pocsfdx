public with sharing class GNE_User_Delegation_Ext extends EMS_DynamicVFLoader {

    public GNE_User_Delegation_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/GNE_User_Delegation_Layout');
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/GNE_User_Delegation_Edit_Create_Layout?id=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
}