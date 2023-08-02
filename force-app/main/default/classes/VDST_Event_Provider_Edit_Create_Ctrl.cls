public without sharing class VDST_Event_Provider_Edit_Create_Ctrl {

    public VDST_EventProvider_gne__c Vendor { get; set; }
    public String retURL { get; private set; }
    public Boolean isEditable { get; private set; }

    public VDST_Event_Provider_Edit_Create_Ctrl() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(id))
            Vendor = [SELECT Id, VendorName_gne__c, VendorCode_gne__c, EventTypeProvideCode_gne__c
            FROM VDST_EventProvider_gne__c WHERE Id = :id];
        else
                Vendor = new VDST_EventProvider_gne__c();

        setMode();

        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }

    public List<SelectOption> getVendorTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('AdBoard - Content','AdBoard - Content'));
        options.add(new SelectOption('AdBoard - Logistics','AdBoard - Logistics'));

        return options;
    }

    private void setMode() {
        if (!'1'.equals(ApexPages.currentPage().getParameters().get('readonly')))
            isEditable = true;
        else
            isEditable = false;
    }

    public PageReference goBack() {
        String route;

        if (String.isNotBlank(retURL))
            route = retURL;
        else
            route = '/';

        return new PageReference(route);
    }

    public PageReference enterEditMode() {
        PageReference ref = new PageReference('/apex/VDST_Event_Provider_Edit_Create?id=' + Vendor.Id + '&retURL=' + retURL);
        ref.setRedirect(true);
        return  ref;
    }

    public PageReference submit() {
        Savepoint sp = Database.setSavepoint();
        try {
            upsertVendor();

            String route = '/apex/VDST_Event_Provider_Edit_Create?id=' + Vendor.Id + '&retURL=' + retURL + '&readonly=1';
            PageReference ref = new PageReference(route);
            ref.setRedirect(true);

            return  ref;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            System.debug('ERROR! > ' + e.getMessage());
            Database.rollback(sp);
            return null;
        }
    }

    private void upsertVendor() {
        upsert Vendor;
    }

    public PageReference quickSubmit() {
        Savepoint sp = Database.setSavepoint();
        try {
            upsertVendor();

            PageReference ref = new PageReference('/apex/VDST_Event_Provider_Edit_Create?retURL=/apex/VDST_Event_Provider_Admin');
            ref.setRedirect(true);

            return  ref;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            System.debug('ERROR! > ' + e.getMessage());
            Database.rollback(sp);
            return null;
        }
    }
}