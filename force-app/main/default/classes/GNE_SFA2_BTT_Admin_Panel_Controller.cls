public class GNE_SFA2_BTT_Admin_Panel_Controller {

    public Boolean isStratSelected { get; set; }
    public Boolean isMBOSelected { get; set; }
    private String retURL;

    public GNE_SFA2_BTT_Admin_Panel_Controller() {
        isStratSelected = true;
        isMBOSelected = false;

        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }

    public List<SFA2_PREP_Testing_Strategy_gne__c> getStrategies() {
        return [SELECT 
                Id, 
                Name, 
                Active_for_Account_gne__c, 
                Active_for_Call_gne__c, 
                External_Id_calc_gne__c 
               FROM 
                SFA2_PREP_Testing_Strategy_gne__c
               ORDER BY
                CreatedDate DESC];
    }

    public List<SFA2_PREP_MBO_gne__c> getMBOs() {
        return [SELECT 
                    Id, 
                    Name,
                    Active_gne__c, 
                    Active_for_Account_gne__c, 
                    Active_for_Call_gne__c, 
                    Short_Description_gne__c,
                    Testing_Strategy_ref_gne__r.Id,
                    Testing_Strategy_ref_gne__r.Name
                FROM 
                    SFA2_PREP_MBO_gne__c
                ORDER BY
                    CreatedDate DESC];
    }

    public void enableStrategiesSection() {
        disableAllSections();
        isStratSelected = true;
    }

    public void enableMBOSection() {
        disableAllSections();
        isMBOSelected = true;
    }

    private void disableAllSections() {
        isMBOSelected = false;
        isStratSelected = false;
    }

    public PageReference goBack() {
        String route;

        if (String.isNotBlank(retURL))
            route = retURL;
        else
            route = '/';

        return new PageReference(route);
    }

    public PageReference createNewStartegy() {
        return new PageReference('/apex/GNE_SFA2_BTT_Strategy_Edit_Create?retURL=/apex/GNE_SFA2_BTT_Admin_Panel');
    }

    public PageReference createNewMBO() {
        return new PageReference('/apex/GNE_SFA2_BTT_MBO_Edit_Create?retURL=/apex/GNE_SFA2_BTT_Admin_Panel');
    }
}