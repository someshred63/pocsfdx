public with sharing class EMS_Expense_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public Boolean isAdmin { get {return EMS_Util.isAdmin();} }

    public EMS_Expense_Controller() {
        super('EMS_Expense_gne__c');
        thisController = this;
    }
}