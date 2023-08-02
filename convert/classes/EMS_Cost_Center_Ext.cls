public with sharing class EMS_Cost_Center_Ext extends EMS_DynamicVFLoader {

    private EMS_Cost_Center_gne__c costCenter;

    public EMS_Cost_Center_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Budget_Region_Layout');
        costCenter = (EMS_Cost_Center_gne__c) myObject;
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Cost_Center_Edit_Create_Layout?id=' + costCenter.Id);
        pageref.setredirect(true);
        return pageref;
    }
}