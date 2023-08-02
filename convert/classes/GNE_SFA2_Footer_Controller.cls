/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-30
*  Description: This is a controller class for GNE_SFA2_Footer
*  
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class GNE_SFA2_Footer_Controller {
	
	public static List<SFA2_UI_Setting_gne__c> footerSettings { get; set; }
	public String footerText { get; set; }
	public Boolean isFooterRendered { get; set; }
	public Boolean isSfaBrandUser { get; private set; }
	
	public GNE_SFA2_Footer_Controller() {
		isFooterRendered = false;
		if(footerSettings == null) {
			loadSettings();
		}
		isSfaBrandUser = GNE_SFA2_Util.isBrandUser();
	}
	
	private void loadSettings() {
        if(GNE_SFA2_Application_Cache.userApplicationContext != null) {
			footerSettings = [ SELECT Footer_Text_gne__c FROM SFA2_UI_Setting_gne__c WHERE Type_gne__c = 'Footer'
				AND	Is_Active_gne__c = true AND Brand_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c AND Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c AND Application_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c LIMIT 1 ];
			
			if(footerSettings.size() > 0) {
				footerText = footerSettings[0].Footer_Text_gne__c;
				isFooterRendered = true;
			}
        }
	}	
}