public with sharing class EMS_User_Ext {

    public String userId { get; set; }
    public Boolean assignToTerritories { get; set; }

    //temp
    public String userIdToViewLink { get; set; }

    public EMS_User_Ext(ApexPages.StandardController controller) {

        if (ApexPages.currentPage().getParameters().get('Id') != null) {
            userId = ApexPages.currentPage().getParameters().get('Id');
        } else {
            userId = UserInfo.getUserId();
        }
        assignToTerritories = false;
        getUserTerritories();
    }

    public List<EMS_Util.EMS_Territory> getUserTerritories() {
        return EMS_Util.getUserTerritories(userId);
    }

    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/EMS_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref;
    }
}