global virtual with sharing class CHV_AuthorizedDistributorBaseWrapper {
	public String id;
	public CHV_AccountManagerBaseWrapper accountManager;
	
	global CHV_AuthorizedDistributorBaseWrapper(CHV_Authorized_Distributor__c ad){
		this.id = ad.Id;
	}
}