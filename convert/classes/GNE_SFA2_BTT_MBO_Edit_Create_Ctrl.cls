public with sharing class GNE_SFA2_BTT_MBO_Edit_Create_Ctrl {

    public SFA2_PREP_MBO_gne__c Mbo { get; set; }
    public String retURL { get; private set; }

    public GNE_SFA2_BTT_MBO_Edit_Create_Ctrl() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(id))
            Mbo = [SELECT Id, 
                        Name, 
                        External_Id_gne__c, 
                        Active_for_Account_gne__c, 
                        Active_for_Call_gne__c, 
                        Short_Description_gne__c,
                        Testing_Strategy_ref_gne__c,
                        Active_gne__c,
                        Default_Status_gne__c,
                        Definition_gne__c  
                        FROM SFA2_PREP_MBO_gne__c WHERE Id = :id];
        else
            Mbo = new SFA2_PREP_MBO_gne__c();

        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }

    public PageReference goBack() {
        String route;

        if (String.isNotBlank(retURL))
            route = retURL;
        else
            route = '/';

        return new PageReference(route);
    }

    public PageReference submit() {
        Savepoint sp = Database.setSavepoint();
        try {
            upsert Mbo;

            PageReference ref = new PageReference('/apex/GNE_SFA2_BTT_Admin_Panel');
            ref.setRedirect(true);

            return  ref;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            System.debug('ERROR! > ' + e.getMessage());
            Database.rollback(sp);
            return null;
        }
    }

    public PageReference quickSubmit() {
        Savepoint sp = Database.setSavepoint();
        try {
            upsert Mbo;

            PageReference ref = new PageReference('/apex/GNE_SFA2_BTT_MBO_Edit_Create?retURL=/apex/GNE_SFA2_BTT_Admin_Panel');
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