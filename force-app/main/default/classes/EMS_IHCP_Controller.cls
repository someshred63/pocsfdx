public with sharing class EMS_IHCP_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public EMS_IHCP_Controller() {
        super('EMS_International_Speaker_gne__c');
        thisController = this;
    }
}