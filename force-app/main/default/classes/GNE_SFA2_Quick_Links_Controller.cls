/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-28
*  Description: This is a controller class for GNE_SFA2_Quick_Links
*  
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class GNE_SFA2_Quick_Links_Controller {
    
    public List<SFA2_UI_Setting_gne__c> quickLinksSettings { get; set; }
    //private GNE_SFA2_User_App_Context_gne__c GNE_SFA2_Application_Cache.userApplicationContext = GNE_SFA2_Util.getGNE_SFA2_Application_Cache.userApplicationContext();
    
    public GNE_SFA2_Quick_Links_Controller() {
        loadSettings();
        populateAllInteractionsReportLink();
    }
    
    private void loadSettings() {
        /*GNE_SFA2_Selected_Application selectedApplication;
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosters = GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId());        
        if (userSalesRosters.size() > 0){           
            selectedApplication = new GNE_SFA2_Selected_Application(userSalesRosters);
        }*/
        if(GNE_SFA2_Application_Cache.userApplicationContext != null) {
            quickLinksSettings = [ SELECT Link_Label_gne__c, Link_URL_gne__c, Open_In_New_Tab_gne__c FROM SFA2_UI_Setting_gne__c WHERE Type_gne__c = 'Sidebar'
                AND Is_Active_gne__c = true AND Sidebar_Item_Type_gne__c = 'Quick Link' AND Brand_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c 
                AND Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c AND Application_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c ORDER BY Order_gne__c ];
        }
    }
    
    private void populateAllInteractionsReportLink() {
        User currentUser = [SELECT Username from User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        
        for(Integer i = 0; i < quickLinksSettings.size(); i++) {
            if(quickLinksSettings[i].Link_Label_gne__c.contains('All Interactions')) {
                quickLinksSettings[i].Link_URL_gne__c += currentUser.Username;
            }
        }        
    }
}