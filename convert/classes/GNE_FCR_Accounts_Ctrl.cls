public class GNE_FCR_Accounts_Ctrl{ 
	
	public Id accountToDelete {get; set;}
	private String lastViewedPageName;

	public Boolean getIsFE(){
		return GNE_FCR_Util.getIsFE();
	}
	
	public PageReference deleteAccount(){
		delete new AP_Account_User_gne__c(Id = accountToDelete);
		return null;
	}
	
	public List<AP_Account_User_gne__c> getAccounts(){
		if(getIsFE()){
			return GNE_FCR_DAO.getAvailableAccounts(UserInfo.getUserId());
		}else{
			return [SELECT Id, Name, Account_CSUser_gne__c, CS_User_gne__c, AP_Account_gne__r.Name, AP_Account_gne__r.OrgId_gne__c, AP_Account_gne__r.Address_gne__c, AP_Account_gne__c
					FROM AP_Account_User_gne__c ORDER BY Name DESC LIMIT 100];
		}
	}
	
	public Pagereference synchronizedAccounts(){
		Pagereference lastViewedPage = redirectToLastViewedPage();
		if(lastViewedPage != null) {
			return lastViewedPage;
		}
		
		setLastVisitedPage();

		if(GNE_FCR_Util.getIsFE() && ApexPages.currentPage().getParameters().containsKey('parameters')){
			Map<String, AP_Account_gne__c>accountsToUpdate = new Map<String, AP_Account_gne__c>(); 
			for(String entry : ApexPages.currentPage().getParameters().get('parameters').split(';')){
				AP_Account_gne__c apAccount = new AP_Account_gne__c();
				for(String params : entry.split('#')){
					String[] keyValues = params.split(':');
					if(keyValues[0].equalsIgnoreCase('orgid')){
						apAccount.OrgId_gne__c = keyValues[1];
					}else if(keyValues[0].equalsIgnoreCase('accountname')) {
						apAccount.Name = keyValues[1]; 
					}else if(keyValues[0].equalsIgnoreCase('addressname')) {
						apAccount.Address_gne__c = keyValues[1];
					}
				}
				if(String.isNotEmpty(apAccount.OrgId_gne__c) && String.isNotEmpty(apAccount.Name)){
					accountsToUpdate.put(apAccount.OrgId_gne__c, apAccount);
				}
			}
			
			Map<String, AP_Account_gne__c>existingAccounts = new Map<String, AP_Account_gne__c>();
			for(AP_Account_gne__c apAccount : [SELECT Id, Name, OrgId_gne__c, Address_gne__c FROM AP_Account_gne__c WHERE OrgId_gne__c IN :accountsToUpdate.keySet()]){
				existingAccounts.put(apAccount.OrgId_gne__c, apAccount);
			}
			
			List<AP_Account_gne__c> upsertAPAccounts = new List<AP_Account_gne__c>();
			for(String orgId: accountsToUpdate.keySet()){
				AP_Account_gne__c apAccount;
				if(existingAccounts.containsKey(orgId)){
					 apAccount = existingAccounts.get(orgId);
				}else{
					apAccount = new AP_Account_gne__c();
				}
				apAccount.Name = accountsToUpdate.get(orgId).Name;
				apAccount.Address_gne__c = accountsToUpdate.get(orgId).Address_gne__c;
				apAccount.OrgId_gne__c = orgId;
				upsertAPAccounts.add(apAccount);
			}
			upsert upsertAPAccounts;
			
			Map<String, AP_Account_User_gne__c> accountUserMap = new Map<String, AP_Account_User_gne__c>();
			for(AP_Account_User_gne__c apUserAccounts : [SELECT Account_CSUser_gne__c, AP_Account_gne__c, AP_Account_gne__r.OrgId_gne__c FROM AP_Account_User_gne__c ORDER WHERE CS_User_gne__c = :Userinfo.getUserId() AND AP_Account_gne__r.OrgId_gne__c IN :accountsToUpdate.keySet()]){
				accountUserMap.put(apUserAccounts.AP_Account_gne__r.OrgId_gne__c, apUserAccounts);    
			}
			List<AP_Account_User_gne__c> apAccountUserList = new List<AP_Account_User_gne__c>();
			
			for(AP_Account_gne__c apAccount : upsertAPAccounts){
				if(!accountUserMap.containsKey(apAccount.OrgId_gne__c)){
					AP_Account_User_gne__c apAccountUser = new AP_Account_User_gne__c();
					apAccountUser.AP_Account_gne__c = apAccount.Id;
					apAccountUser.CS_User_gne__c = UserInfo.getUserId();
					apAccountUser.Account_CSUser_gne__c = apAccount.Id +'-'+ Userinfo.getUserId();
					apAccountUserList.add(apAccountUser);
				}
			}
			if(!apAccountUserList.isEmpty()){
				Database.upsert(apAccountUserList);
			}
		}
		return null;
	}

	private PageReference redirectToLastViewedPage() {
        try{
			lastViewedPageName = [SELECT Last_page_visited_gne__c FROM SFA2_User_Preferences_gne__c WHERE CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1].Last_page_visited_gne__c;

			if(String.isNotBlank(lastViewedPageName) 
				&& !lastViewedPageName.contains('GNE_FCR_MyAccounts')
				&& lastViewedPageName.contains('GNE_FCR_SalesData')) {
             	lastViewedPageName = lastViewedPageName.substringBefore(';'); 
				PageReference lastPage = new PageReference ('/apex/' + lastViewedPageName);
				return lastPage;
			}
		}
		catch(Exception e) {			
		}

		return null;
	}

	public void setLastVisitedPage() {
		GNE_FCR_Navigation_Controller.setLastVisitedPage();		
	}
}