public with sharing class EDM_ABM_Dispatcher_Controller {
	
	public PageReference selectApplicationAndNavigate() {
		GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
		if (userApplicationContext == null || userApplicationContext.App_Name_gne__c == 'gFRS' || String.isEmpty(userApplicationContext.App_Name_gne__c)) {
			return redirectToApp('ABM');
		}
		else {
			return redirectToApp(null);
		}
	}

	private PageReference redirectToApp(String appName) {
		String url = '/apex/GNE_SFA2_Application_Dispatcher' + (String.isNotBlank(appName) ? '?application=' + appName : '');
		PageReference pageRef = new PageReference(url);
		pageref.setredirect(true);
		return pageRef;
	}
}