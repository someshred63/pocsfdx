/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-28
*  Description: This is a controller class for GNE_SFA2_Sidebar
*  
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class GNE_SFA2_Sidebar_Controller {
	public Boolean isRecentItemsRendered { get; set; }
	public Boolean isRecycleBinRendered { get; set; }
	public Boolean isQuickLinksRendered { get; set; }
	private static Map<String, SFA2_UI_Setting_gne__c> sidebarSettingsMap = null;
	//private GNE_SFA2_User_App_Context_gne__c GNE_SFA2_Application_Cache.userApplicationContext = GNE_SFA2_Util.getGNE_SFA2_Application_Cache.userApplicationContext();
	
	public GNE_SFA2_Sidebar_Controller() {
		isRecentItemsRendered = false;
		isRecycleBinRendered = false;
		isQuickLinksRendered = false;
		if(sidebarSettingsMap == null) {
			loadSettings();
		}
	}
	
	private void loadSettings() {
		//GNE_SFA2_Selected_Application selectedApplication;
        //List<SFA2_User_Sales_Roster_gne__c> userSalesRosters = GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId());        
        //if (userSalesRosters.size() > 0){           
        //    selectedApplication = new GNE_SFA2_Selected_Application(userSalesRosters);
        //}
        if(GNE_SFA2_Application_Cache.userApplicationContext != null) {
			sidebarSettingsMap = new Map<String, SFA2_UI_Setting_gne__c>();
			List<SFA2_UI_Setting_gne__c> sidebarSettings = [ SELECT Sidebar_Item_Type_gne__c FROM SFA2_UI_Setting_gne__c WHERE Type_gne__c = 'Sidebar'
				AND	Is_Active_gne__c = true AND Brand_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c AND Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c AND Application_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c ];
				
			for(SFA2_UI_Setting_gne__c setting : sidebarSettings) {
				sidebarSettingsMap.put(setting.Sidebar_Item_Type_gne__c, setting);
			}
			
			isQuickLinksRendered = sidebarSettingsMap.containsKey('Quick Link');
			isRecycleBinRendered = sidebarSettingsMap.containsKey('Recycle Bin');
			isRecentItemsRendered = sidebarSettingsMap.containsKey('Recent Items');
        }
	}
    public Boolean getIsMenuVisible() {
        return !GNE_SFA2_Util.isCanadaINFUUser();
    }
}