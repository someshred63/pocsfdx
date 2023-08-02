public with sharing class EMS_Expense_Ext extends EMS_DynamicVFLoader {

    public EMS_Expense_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Expense_Layout');
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Expense_Edit_Create_Layout?id=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

}