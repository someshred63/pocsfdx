public without sharing class SRW_CommunityEmailsContentController {
	public String url {get; set;}
	public String type {get; set;}
	public Id userId {get; set;}
	public User user {set; private get;}
	public SRW_Trading_Partner_Profile__c tradingPartner {set; private get;}

	public Boolean isWelcome;
	public Boolean isResetPassword;
	public Boolean isResetSecurityQA;
	public Boolean isForgotUsername;
	public Boolean isActivation;
	public Boolean isDeactivation;

	public SRW_CommunityEmailsContentController() {
		user = new User();
		tradingPartner = new SRW_Trading_Partner_Profile__c();
		url = SRW_Utils.getSettingByName('Community URL');
	}

	public User getUser(){
		system.debug('in user');
		return [SELECT id, contactId, username FROM User WHERE id =:userid];
	}

	public SRW_Trading_Partner_Profile__c getTradingPartner(){
		user = getUser();
		List<SRW_Trading_Partner_Profile__c> temp = [SELECT id, Trading_Partner_Name_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c FROM SRW_Trading_Partner_Profile__c WHERE Contact_gne__c = :user.contactId];
		system.debug('tp: ' + temp);
		return temp.isEmpty() ? new SRW_Trading_Partner_Profile__c(Trading_Partner_Name_gne__c='Friend') : temp[0];
	}

	public Boolean getIsWelcome(){
		return 'welcome'.equals(type);
	}
	public Boolean getIsResetPassword(){
		return 'resetPassword'.equals(type);
	}
	public Boolean getIsResetSecurityQA(){
		return 'resetSecurityQA'.equals(type);
	}
	public Boolean getIsForgotUsername(){
		system.debug('in forgotUsername: ' + type);
		return 'forgotUsername'.equals(type);
	}
	public Boolean getIsActivation(){
		return 'activation'.equals(type);
	}
	public Boolean getIsDeactivation(){
		return 'deactivation'.equals(type);
	}

}