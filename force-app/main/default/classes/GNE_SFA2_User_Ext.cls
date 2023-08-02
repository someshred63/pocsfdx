/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-02-01
*  Description: This is a extension controller for GNE_SFA2_User_Layout Page
*  and GNE_SFA2_MySetup Page
*
*  Modification History
*  Date        Name        Description
*  06-02-13    Lukasz Bieniawski    Added as extension to GNE_SFA2_MySetup Page
*************************************************************/
public with sharing class GNE_SFA2_User_Ext {

    public String userId {get;set;}
    public Boolean assignToTerritories {get;set;}

    //temp
    public String userIdToViewLink {get;set;}

    public GNE_SFA2_User_Ext(ApexPages.StandardController controller) {

        if(ApexPages.currentPage().getParameters().get('Id') != null) {
            userId = ApexPages.currentPage().getParameters().get('Id');
        } else {
            userId = UserInfo.getUserId();
        }
        assignToTerritories = false;
        getUserTerritories();
    }

    public Map<Territory2,UserTerritory2Association> getUserTerritories() {

        List<UserTerritory2Association> userTerritoriesList = [Select Territory2Id, IsActive from UserTerritory2Association where UserId =: userId];
        List<Territory2> territoriesList = [Select Id, Name from Territory2 where Id  IN (Select Territory2Id from UserTerritory2Association where UserId =: userId)];
        Map<Id,UserTerritory2Association> userTerrMap = new Map<Id,UserTerritory2Association>();
        for(UserTerritory2Association ut : userTerritoriesList) {
            userTerrMap.put(ut.Territory2Id, ut);
        }

        Map<Territory2,UserTerritory2Association> userTerritoriesMap = new Map<Territory2,UserTerritory2Association>();
        for(Territory2 t : territoriesList) {
            userTerritoriesMap.put(t, userTerrMap.get(t.Id));
        }

        if(userTerritoriesMap.size() > 0) {
            assignToTerritories = true;
        }

        return userTerritoriesMap;
    }

    public Boolean getIsEdit() {
        String currentProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        Boolean isAdminException = currentProfile.contains('Admin') && !currentProfile.startsWithIgnoreCase('GNE-TLS-');
        if(UserInfo.getUserId() == ApexPages.currentPage().getParameters().get('Id') || isAdminException) {
            return true;
        } else {
            return false;
        }
    }

    public PageReference clickEdit() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Edit_User_Layout?Id=' + userId);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref;
    }

}