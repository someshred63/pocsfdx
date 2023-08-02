public with sharing class EMS_Cost_Center_Type_Ext extends EMS_DynamicVFLoader {
    private EMS_Cost_Center_Type_gne__c costCenterType;

    public EMS_Cost_Center_Type_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Cost_Center_Type_Layout');
        costCenterType = (EMS_Cost_Center_Type_gne__c) myObject;
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Cost_Center_Types_Edit_Create_Layout?id=' + costCenterType.Id);
        pageref.setredirect(true);
        return pageref;
    }
}