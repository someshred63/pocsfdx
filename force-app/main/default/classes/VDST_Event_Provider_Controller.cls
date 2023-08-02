public class VDST_Event_Provider_Controller {

    public Boolean isLogisticVendorSelected { get; set; }
    public Boolean isContentVendorSelected { get; set; }
    private String retURL;

    public VDST_Event_Provider_Controller() {
        isLogisticVendorSelected = true;
        isContentVendorSelected = false;

        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }

    public List<VDST_EventProvider_gne__c> getVendors() {
        return [SELECT Id, VendorName_gne__c, VendorCode_gne__c
                FROM VDST_EventProvider_gne__c
                WHERE EventTypeProvideCode_gne__c =: isLogisticVendorSelected ? 'AdBoard - Logistics' : 'AdBoard - Content'
                ORDER BY VendorName_gne__c ASC];
    }

    public void enableLogisticVendorSection() {
        disableAllSections();
        isLogisticVendorSelected = true;
    }

    public void enableContentVendorSection() {
        disableAllSections();
        isContentVendorSelected = true;
    }

    private void disableAllSections() {
        isLogisticVendorSelected = false;
        isContentVendorSelected = false;
    }

    public PageReference goBack() {
        String route;

        if (String.isNotBlank(retURL))
            route = retURL;
        else
            route = '/';

        return new PageReference(route);
    }

    public PageReference createNewVendor() {
        return new PageReference('/apex/VDST_Event_Provider_Edit_Create?retURL=/apex/VDST_Event_Provider_Admin');
    }
}