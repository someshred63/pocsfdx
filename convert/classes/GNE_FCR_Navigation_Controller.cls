public class GNE_FCR_Navigation_Controller {
	
	public String url{get;set;}
	
	private final static Integer DEFAULT_LENGTH_LIMIT = 1900; 
	
	public Id fcrId {get;set;}

	private static SFA2_User_Preferences_gne__c userPref;

	static{
	 	try {
			userPref = [SELECT Id FROM SFA2_User_Preferences_gne__c WHERE CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1];
		}
		catch(Exception e) {
			userPref = new SFA2_User_Preferences_gne__c();			
		} 
	 }
	
	public GNE_FCR_Navigation_Controller() {		
	}
    
    public String getAplicationName() {
        String appName = 'gSFA';
        if(GNE_SFA2_Util.isCCCrmUser() ) {
            appName = 'CRM';
        }
        return appName;
    }

	public String getAccountsList(){
		String commaSepratedList ='';
		for(AP_Account_User_gne__c apAccount: [SELECT AP_Account_gne__r.OrgId_gne__c FROM AP_Account_User_gne__c WHERE CS_User_gne__c =:UserInfo.getUserId() ORDER BY lastModifiedDate DESC]){
			if(!apAccount.AP_Account_gne__r.OrgId_gne__c.startsWith(GNE_FCR_Util.FCR_INTERNAL_ACCOUNT_PREFIX)){
				if(commaSepratedList.length() + apAccount.AP_Account_gne__r.OrgId_gne__c.length() + 1 < DEFAULT_LENGTH_LIMIT){
					commaSepratedList += apAccount.AP_Account_gne__r.OrgId_gne__c + ',' ;
				}else{
					break;
				}
			}
		}
		commaSepratedList = commaSepratedList.removeEnd(',');
		return commaSepratedList;
	}
	
	public PageReference navigate(){
		PageReference redirect = new PageReference(url);
		redirect.setRedirect(true);
		try{
			if(String.isEmpty(fcrId)){
				fcrId = ApexPages.currentPage().getParameters().get('fcrId');
			}
		}catch (Exception ex){
			return GNE_FCR_Util.redirectToErrorPage('Navigation to the link failed !', Apexpages.currentPage().getUrl(), ex.getMessage());
		}

		return redirect;
	}

	public static void setLastVisitedPage() {
		String currentPageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
		userPref.Last_page_visited_gne__c = currentPageName;
		upsert userPref;
	}
	
	public static void setLastAndNextVisitedPage(String nextPageName) {
		String currentPageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');
		userPref.Last_page_visited_gne__c = currentPageName + ';' + nextPageName;
		upsert userPref;
	}

	public PageReference navigateToSalesData(){
		setLastAndNextVisitedPage('GNE_FCR_SalesData');
		PageReference pageRef; 
		if(GNE_FCR_Util.isSupportedBySLDx(UserInfo.getUserId())){
			String accountList = getAccountsList();			
			pageRef = new PageReference(envUrl);
			pageRef.getParameters().put('select', 'SFDCPlanFlag,'+accountList);
		}else{
			pageRef = Page.GNE_FCR_Days_Plan_PTP;			
		}		

		pageRef.setRedirect(true);
		return pageRef;
	}
	
	public String envUrl{
		get{
			return Utilities.getGlobalVariable('GNE_FCR_SalesData');
		}
		private set;
	}
	
	public Boolean getIsFE(){
		return GNE_FCR_Util.getIsFE();
	}
	
	public Boolean getIsDataViewerAdmin(){
		return GNE_FCR_Util.getIsDataViewerAdmin();
	}
}