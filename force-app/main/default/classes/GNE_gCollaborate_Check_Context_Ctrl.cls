public with sharing class GNE_gCollaborate_Check_Context_Ctrl {
	
	public GNE_gCollaborate_Check_Context_Ctrl() {}

	public PageReference doRedirect() {
		PageReference pageref = new PageReference(System.currentPageReference().getParameters().get('url'));
		Set<String> appsNames = new Set<String>{'SFA-US','MCCO','TLCRM','MedAffairs'};
        List<GNE_SFA2_User_App_Context_gne__c> userAppContect = [SELECT App_Name_gne__c, Brand_gne__c, Role_gne__c, Run_in_SFA2_UI_gne__c, SFA2_Mode_gne__c FROM GNE_SFA2_User_App_Context_gne__c WHERE SetupOwnerId =: UserInfo.getUserId()];
		if(!appsNames.contains(userAppContect.get(0).App_Name_gne__c)) {
			List<SFA2_User_Sales_Roster_gne__c> userSalesRoster = getUserSalesRosters();
            if(!userSalesRoster.isEmpty()) {
               	userAppContect.get(0).App_Name_gne__c = userSalesRoster.get(0).Sales_Roster_gne__r.Type_gne__c;
                userAppContect.get(0).Brand_gne__c = userSalesRoster.get(0).Sales_Roster_gne__r.Brand_Name_gne__c;
                userAppContect.get(0).Role_gne__c = userSalesRoster.get(0).Role_gne__c;
                userAppContect.get(0).Run_in_SFA2_UI_gne__c = true;
                userAppContect.get(0).SFA2_Mode_gne__c = true;

                update userAppContect;
            }
		}
		pageref.setredirect(true);
        return pageref;
	} 

	private List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters() {
        return [SELECT Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Role_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE Sales_Roster_gne__r.Type_gne__c IN ('SFA-US', 'MCCO', 'TLCRM', 'MedAffairs') AND User_gne__c =: UserInfo.getUserId()];
    }
}