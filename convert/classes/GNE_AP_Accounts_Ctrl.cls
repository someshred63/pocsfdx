public with sharing class GNE_AP_Accounts_Ctrl extends GNE_AP_Base_Class{
	
	public Id accountToDelete { get; set; }
	
	public AP_Account_Planning_gne__c accountPlanning {get; set;}
	
	public AP_Account_gne__c newAccount {get; set;}
	
	public GNE_AP_Accounts_Ctrl(){
		newAccount = new AP_Account_gne__c();
		if(String.isNotEmpty(accountPlanId)){
			accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
		}
	}
	
	public Pagereference createAccountObjects(){
		try{
			system.debug('isFE: ' + GNE_AP_Util.isFE());
			createAccountPlan();
			if(GNE_AP_Util.isFE() && accountPlanning == null){
				accountPlanning = GNE_AP_DAO.getActiveAccountPlan(UserInfo.getUserId());
			}
			if(GNE_AP_Util.isFE() && ApexPages.currentPage().getParameters().containsKey('parameters')){
				Map<String, AP_Account_gne__c>accountsToUpdate = new Map<String, AP_Account_gne__c>();
				system.debug(ApexPages.currentPage().getParameters().get('parameters'));
				for(String entry : ApexPages.currentPage().getParameters().get('parameters').split(';')){
					system.debug(entry);
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
		}catch(Exception ex){
			system.debug(ex.getMessage());
			if(ex.getMessage().contains('DUPLICATE_VALUE')){
				return GNE_AP_Util.redirectToErrorPage('Duplicate Account found!', Apexpages.currentPage().getUrl(), ex.getMessage());
			}
			return GNE_AP_Util.redirectToErrorPage('User account creation failed !', Apexpages.currentPage().getUrl(), ex.getMessage());
		}
		return null;
	}
	
	public List<AccountsWrapper> getAccountsList(){
		Set<Id> accountIds = new Set<Id>();
		for(AP_Detail_gne__c apDetail : [SELECT AP_Account_gne__c FROM AP_Detail_gne__c WHERE CS_User_gne__c = :csUserId AND AP_Account_Planning_gne__c = :accountPlanId]){
			accountIds.add(apDetail.AP_Account_gne__c);
		}
		
		List<AccountsWrapper>accounts = new List<AccountsWrapper>();
		
		for(AP_Account_User_gne__c accountRecord : GNE_AP_DAO.getUserAccounts(csUserId)){
			if(accountIds.contains(accountRecord.AP_Account_gne__c)){
				accounts.add(new AccountsWrapper(accountRecord, true));
			}else{
				accounts.add(new AccountsWrapper(accountRecord, false));
			}
		}
		return accounts;
	}
	
	public List<AccountsWrapper> getSharedAccountsList(){
		Set<Id> accountIds = new Set<Id>();
		Id activePlanId = GNE_AP_DAO.getActiveAccountPlan(UserInfo.getUserId()).Id;
		List<AP_Detail_gne__c>details = [SELECT AP_Account_gne__c, AP_Account_Planning_gne__c, AP_Account_Planning_gne__r.CS_User_gne__c FROM AP_Detail_gne__c WHERE AP_Account_Planning_gne__c != :activePlanId AND AP_Account_Planning_gne__r.Status_gne__c != :GNE_AP_Util.AP_ARCHIVED];
		for(AP_Detail_gne__c apDetail : details){
			accountIds.add(apDetail.AP_Account_gne__c);
		}
		
		List<AccountsWrapper>result = new List<AccountsWrapper>();
		
		Map<Id, AP_Account_gne__c> accounts = new Map<Id, AP_Account_gne__c>([SELECT Id, Name, OrgId_gne__c, Address_gne__c FROM AP_Account_gne__c WHERE Id IN :accountIds]);
		Set<String>uniqueness = new Set<String>();
		for(AP_Detail_gne__c detail: details){
			if(uniqueness.add(detail.AP_Account_Planning_gne__c+''+detail.AP_Account_gne__c)){
				system.debug(detail.Id);
				system.debug(detail.AP_Account_gne__c);
				system.debug(accounts.get(detail.AP_Account_gne__c));
				result.add(new AccountsWrapper(accounts.get(detail.AP_Account_gne__c), detail.AP_Account_Planning_gne__c, detail.AP_Account_Planning_gne__r.CS_User_gne__c));
			}
		}
		return result;
	}
	
	public Pagereference deleteAccountRecord(){
		try{
			delete new AP_Account_User_gne__c(Id = accountToDelete);
		}catch (Exception ex){
			return GNE_AP_Util.redirectToErrorPage('Account deletion failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}
		PageReference pageRef = new PageReference('/apex/GNE_AP_MyAccounts');
		pageRef.setRedirect(true);
		pageref.getParameters().put('planId', accountPlanId);
		pageref.getParameters().put('csUserId', csUserId);
		return pageRef;
	}
	
	class AccountsWrapper{
		public AP_Account_gne__c apAccount{get; set;}
		public AP_Account_User_gne__c account{get; set;}
		public Id planId{get; set;}
		public Id csUserId{get; set;}
		public Boolean hasPlan{get; set;}
		public Boolean isManuallyAdded{get; set;}
		
		public AccountsWrapper(AP_Account_User_gne__c account, Boolean hasPlan){
			this.account = account;
			this.hasPlan = hasPlan;
			if(this.account.AP_Account_gne__r.OrgId_gne__c.startsWith(GNE_AP_Util.AP_INTERNAL_ACCOUNT_PREFIX) || this.account.AP_Account_gne__r.OrgId_gne__c.startsWith(GNE_FCR_Util.FCR_INTERNAL_ACCOUNT_PREFIX)){
				isManuallyAdded = true;
			}else{
				isManuallyAdded = false;
			}
		}
		
		public AccountsWrapper(AP_Account_gne__c account, Id planId, Id csUserId){
			this.apAccount = account;
			this.hasPlan = String.isNotEmpty(planId);
			this.planId = planId;
			this.csUserId = csUserId;
			if(this.apAccount.OrgId_gne__c.startsWith(GNE_AP_Util.AP_INTERNAL_ACCOUNT_PREFIX) || this.apAccount.OrgId_gne__c.startsWith(GNE_FCR_Util.FCR_INTERNAL_ACCOUNT_PREFIX)){
				isManuallyAdded = true;
			}else{
				isManuallyAdded = false;
			}
		}
	}
	
	public PageReference addAccount(){
		if(String.isEmpty(newAccount.Name)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account name cannot be empty.'));
			return null;
		}
		for(AP_Account_User_gne__c accountRecord : GNE_AP_DAO.getUserAccounts(csUserId)){
			if(accountRecord.AP_Account_gne__r.Name == newAccount.Name){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Account name has to be unique.'));
				return null;
			}
		}
		newAccount.OrgId_gne__c = GNE_AP_Util.AP_INTERNAL_ACCOUNT_PREFIX + accountPlanId + GNE_FCR_Util.generateRandomString(50);
		insert newAccount;
		AP_Account_User_gne__c userAccount = new AP_Account_User_gne__c(AP_Account_gne__c=newAccount.Id, CS_User_gne__c=UserInfo.getUserId(), Account_CSUser_gne__c=newAccount.Id+'-'+UserInfo.getUserId());
		insert userAccount;
		newAccount = new AP_Account_gne__c();
		return null;
	}
	
	@RemoteAction
	public static List<User>getFMUsers(){
		return GNE_FCR_DAO.getAvailableFRs(UserInfo.getUserId());
	}
	
	public Boolean getIsSubmitButtonEnabled(){
		return GNE_AP_DAO.isPlanContainsDetails(accountPlanId);
	}
}