global virtual with sharing class CHV_AccountManagerBaseWrapper {
	public String id;
	
	public CHV_AccountManagerBaseWrapper(CHV_Account_Manager__c am){
		this.id = am.Id;
	}
}